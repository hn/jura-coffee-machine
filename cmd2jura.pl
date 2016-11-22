#!/usr/bin/perl
#
# cmd2jura.pl, V1.00
#
# Send control commands to a Jura coffee machine via the (serial) maintenance port
#
# (C) 2016 Hajo Noerenberg
#
# http://www.noerenberg.de/
# https://github.com/hn/jura-coffee-machine
#
# The Jura protocol has been reverse engineered by the guys from http://protocol-jura.do.am
#
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3.0 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/gpl-3.0.txt>.
#

# apt-get install libdevice-serialport-perl

use strict;
use Time::HiRes qw(usleep);
use Device::SerialPort qw( :PARAM :STAT 0.07 );

my $port="/dev/ttyAMA0";	# Raspberry GPIO UART: Pin6=GND, Pin8=TXD, Pin10=RXD
my $sp;

sub cmd2jura {
    foreach my $outbyte ( split( //, shift() . "\r\n" ) ) {
        my $outbits = unpack( 'b8', $outbyte );
        for ( my $i = 0 ; $i < 7 ; $i += 2 ) {
            $sp->write(
                pack( 'b8', '11' . substr( $outbits, $i + 0, 1 ) . '11' . substr( $outbits, $i + 1, 1 ) . '11' )
            );
        }
        usleep( 8 * 1000 );
    }

    my $inbytes;
    my $inbits;
    my $stime = time();
    while ( substr( $inbytes, -2 ) ne "\r\n" ) {
        my ( $count, $rawbyte ) = $sp->read(1);
        if ( $count > 0 ) {
            my $rawbits = unpack( 'b8', $rawbyte );
            $inbits .= substr( $rawbits, 2, 1 ) . substr( $rawbits, 5, 1 );
            if ( length($inbits) == 8 ) {
                $inbytes .= pack( 'b8', $inbits );
                $inbits = undef;
            }
        }
        if ( $stime + 5 < time() ) {
            print STDERR "Timeout reading result\n";
            return undef;
        }
    }

    return $inbytes;
}

if ( not defined $ARGV[0] ) {
    print STDERR "Usage: $0 <cmd>\n";
    print STDERR "Where <cmd> is a valid Jura control command depending on ";
    print STDERR "machine type, try searching the web for more information):\n";
    print STDERR " TY:   = get type of machine\n";
    print STDERR " AN:01 = turn machine on\n";
    print STDERR " AN:02 = turn machine off\n";
    print STDERR " RE:xx = read EEPROM word at address xx (00 .. 7F)\n";
    print STDERR " RT:xx = read EEPROM line (16 words) at address xx (00 .. 70)\n";
    print STDERR " RR:xx = read RAM line (16 bytes) at address xx (00 .. F0)\n";
    print STDERR " FA:xx = product (coffee small .. large .. steam .. flush)\n";
    print STDERR " FN:xx = mechanical components on/off (pump .. heat .. grinder)\n";
    print STDERR " [...]\n";
    print STDERR "WARNING: Wrong commands may damage your machine permanently!\n";
    exit 64;
}

$sp = new Device::SerialPort($port) || die "Can't open serial port: $!";
$sp->baudrate(9600);
$sp->databits(8);
$sp->parity("none");
$sp->stopbits(1);
$sp->handshake('none');
$sp->write_settings;

print cmd2jura( $ARGV[0] );

$sp->close;


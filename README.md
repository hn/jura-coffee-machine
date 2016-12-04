# jura-coffee-machine

## Tech
`jura-e65-coffee-machine.txt` lists some technical data (reverse engineered years ago) and `jura-e65-circuit-board.jpg` shows PCB photos of the Jura Impressa E65 coffee machine.

## Perl
`cmd2jura.pl` interfaces the coffee machine with the Raspberry Pi (Indeed it should work with any device having a serial port and Perl). Example output:

```
root@raspberrypi:~# ./cmd2jura.pl AN:01
ok:
root@raspberrypi:~# ./cmd2jura.pl TY:
ty:E30   MASK 3
root@raspberrypi:~# ./cmd2jura.pl RT:10
rt:33DA01B1000C0640AA1116B301180000000000001E02007100150000000009D5
root@raspberrypi:~# 
```

![Raspberry](https://github.com/hn/jura-coffee-machine/blob/master/jura-e65-raspberry-interface.jpg "Raspberry Pi connection 9600-8N1")


# MBR
A simple MBR implementation.

Currently it prints a Hello world message,
Prints whether the A20 line is enabled or disabled, 
changes it and checks again.
At the end the A20 line is enabled.

In order to run with qemu:

```
path\to\qemu> qemu-system-i386.exe -hda path\to\mbr.bin
```

For learning purposes !

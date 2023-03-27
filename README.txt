

  It Might Be NES, Copyright (C) 2001,2002,2003 Allan Blomquist
  All rights reserved.  Email: ablomquist@gmail.com


This package contains the source code for the Nintendo Entertainment
System emulator "It Might Be NES" released under the terms of the GNU
General Public License. Also included for convenience are the tools
used to build the source code and the files necessary to build a
burnable CD image on the win32 platform.

Thanks to Hitmen for their excellent docs and tools without which
imbNES would not exist. Check out http://www.hitmen-console.org


Suggested work flow:

Once you make your modifications to the source code, you can use the
included build.bat file to assemble the source into the program binary.
By default, nes.exe will be created in the .\out directory. At this
point you can run the .\out\rombank.exe program to build an ISO image
suitable for playing on a Playstation 1 or 2 console. Since burning CDs
each and every time you want to test your changes is impractical, you
can also use any Playstation emulator that supports loading ISOs for
testing. I have had good luck with "PSXeven" in the past, but there
may be something better out there these days. For an even faster
turn around time, include a single NES ROM into nes.exe itself during
development and modify the code to start executing it immediately on
boot. You could also extend the build script to create or patch an ISO
file automatically so there's nothing to do by hand to test each
iteration.

If you plan on making any changes other than minor cosmetic ones,
you should NOT rely on Playstation emulators for testing your
work. The runtime performance of imbNES depends heavily on having
decent CPU cache utilization, so no Playstation emulator is going to
give you an accurate sense of what performance on the real hardware is
going to be like. If you want to work on the emulation core itself,
you should have a setup that will enable you to run code on an actual
Playstation console.

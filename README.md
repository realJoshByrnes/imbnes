# It might be NES

Looking for Windows binaries? Check out [this](https://github.com/txuswashere/imbNES) GitHub repository.

````
    ______               _       __    __     ____          _   _____________
   /  _/ /_   ____ ___  (_)___ _/ /_  / /_   / __ )___     / | / / ____/ ___/
   / // __/  / __ `__ \/ / __ `/ __ \/ __/  / __  / _ \   /  |/ / __/  \__ \ 
 _/ // /_   / / / / / / / /_/ / / / / /_   / /_/ /  __/  / /|  / /___ ___/ / 
/___/\__/  /_/ /_/ /_/_/\__, /_/ /_/\__/  /_____/\___/  /_/ |_/_____//____/  
                       /____/     

Version 1.3.4

It Might be NES (imbNES) is a Nintendo Entertainment System (NES) emulator for the Sony PlayStation.
It allows NES games to be played on a Sony PlayStation console.

+---------------------+
| A bit of history... |
+---------------------+

It Might be NES was originally written by Allan Blomquist sometime around 2000, and updated for several years thereafter.
The last version released by Blomquist was 1.3.3-WIP1.
Due to a series of circumstances, the project was discontinued.
It was, at that point, a dead-end, since the source code for the project was not public.
In 2008, the original author released source code for version 1.3.2, under the GPL license on his website, as he was no longer planning to work on it due to having moved on, so that an interested person could start to make improvements to the emulator. Unfortunately nobody started to work again on the emulator and the emulator sat unmaintained until 2015, until being picked up again.

A note: source code for 1.3.3-WIP1 was never released, as it was probably lost.

+----------+
| Building |
+----------+

You need the following to build It Might be NES:
- PSXSDK (any version released in 2015 or later)
- C compiler for your system
- GNU Make
- an ISO creation program (either mkisofs or genisoimage)
  [if you are using genisoimage, change the relevant line in the Makefile]
  
  [if you are using *BSD, change every occurrence of the "make" command below to "gmake"]

*** STEP 1 ***

Before building imbNES, you need to generate a rombank file with the games you want to play.
To do so, first build the rombank program with "make rombank".
Then with the rombank program, generate the rombank file, by giving a list of files either on the command line or in a list file.

Examples:

To generate a rombank file with the ROMS smb1.nes,smb2.nes and smb3.nes, run:
"./rombank rombank.bin smb1.nes smb2.nes smb3.nes"

To generate a rombank file with the ROMS smb1.nes,smb2.nes and smb3.nes from a list file:
Create a list file, call it list.txt and write:
smb1.nes=Super Mario Bros.
smb2.nes=Super Mario Bros. 2
smb3.nes=Super Mario Bros. 3

Run "./rombank -l rombank.bin list.txt"

As you can see there is one line for each file, in the format <file name>=<game name>
The game name is how the game is called in the game selection menu; when generating a rombank file
from a list of files supplied on the command line, the games are always called after their filenames.

*** STEP 2 ***

Now we will do the actual build of imbNES. Run "make" and if everything went well, there will
be six files in the "cdimg" directory. They are the ISO .bin images, one for each region,
and their respective CUE sheets.
imbnes_e is for PAL PlayStations, imbnes_u for American PlayStations and imbnes_j for Japanese ones.

+----------------------+
| Running the emulator |
+----------------------+

You need a way to run homebrew software on your PlayStation console.
No need to repeat anything here, most probably you already know, otherwise, readme.txt in the PSXSDK
source code is a good read.

When you run the emulator, a splash screen will be displayed. After some seconds, the game selection menu will appear.
Here it is possible to select which game to play. The menu can be navigated with the directional pad buttons.
Choose the game with START.

Alternatively, you can go to the Options menu, by pressing Triangle. There it is possible to change several settings, most importantly the controller button assignments.

To return to the game selection menu, press L1+R1+START+SELECT on the first controller.

+---------------+
| Compatibility |
+---------------+

The emulator supports mappers 0, 1, 2, 3, 4, 7, 9, 10, 11, 33, 34, 38, 66, 70, 71, 79,
87, 140, 180 and 185.
Not all games are guaranteed to work correctly, and some games may have graphical glitches.

+-------------+
| Helping out |
+-------------+

To help out, you need a good knowledge of MIPS assembly language (yes, imbNES is written completely in assembly!),
and some knowledge of the NES hardware. The knowledge you need depends on what area of the hardware you want to help
out with. Mapper support, for instance, does not require as much expertise as fixing an annoying PPU bug.

The MIPS assembly language dialect used by imbNES is the one that the SPASM assembler by Hitmen used, and thus the one the nv-SPASM tool supplied in the PSXSDK understands. It is not the dialect used by the GNU MIPS assembler!
While the dialect is far from being a golden standard, it is what the emulator was written in, and porting the emulator source code to use another dialect would be a serious undertaking, as it uses mnay unique features of the SPASM dialect.
It does not take much effort to become familiar with the SPASM dialect, but it has some strange and annoying quirks.
There is no documentation about those quirks at the moment, so try to play it safe: do not bend the rules in new code, and pay attention to the delay slots, the assembler won't take care of them for you.

You can report bug reports at my (nextvolume's) email: tails92@gmail.com

Do not forget the official web-page: https://web.archive.org/web/20171020074544/http://unhaut.fav.cc/imbnes

Enjoy!

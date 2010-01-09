 
  @@@     @@@  @@@@@@@@@@@@  @@@@@@@@@@@   @@@@@@@@@@@  @@@@@@@@@@@  @@@@   @@@@  
  @@@     @@@  @@@@@@@@@@@@  @@@@@@@@@@@   @@@@@@@@@@@  @@@@@@@@@@@   @@@@ @@@@@  
  @@@     @@@       @@@@@@   @@@           @@@     @@@  @@@     @@@    @@@@@@@    
  @@@     @@@      @@@@@     @@@@@@@@@     @@@@@@@@@@   @@@     @@@     @@@@@     
  @@@     @@@    @@@@@@      @@@@@@@@@     @@@@@@@@@@@  @@@     @@@     @@@@@     
  @@@     @@@   @@@@@        @@@           @@@     @@@  @@@     @@@    @@@@@@@    
  @@@@@@@@@@@  @@@@@@@@@@@@  @@@@@@@@@@@   @@@@@@@@@@@  @@@@@@@@@@@   @@@@ @@@@@  
  @@@@@@@@@@@  @@@@@@@@@@@@  @@@@@@@@@@@   @@@@@@@@@@@  @@@@@@@@@@@  @@@@   @@@@  

          The Uzebox Project - A retro-minimalist open source console!  
	    All sources and content is licenced under the GNU GPL V3



Rev 3.0 Notes 
-------------------------

	Jan 8, 2010
	-------------
	-Major Refactoring: All video modes in their own files
	-New video modes: 3,4,6,7,8 (See the WIKI for details)
	-EEPROM functions
	-Assembly functions in their own sections to save flash
	-Added Vsync User callbacks
	-UART Receive buffer & functions
	-Color burst offset control
	-Packrom tool to make .uze file
	-SD card game loader/bootloader!
	-Various code cleanup & optimizations
	-Video mode 3 now has a -DSCROLLING=1 to enable XY scrolling.
	-SD/MMC low level functions ported to assembler to cut on flash utilization

Rev 2.0 Beta4 Notes
-------------------------

	Feb 1, 2009
	-----------
	The demos are beign re-aranged to use a 'master' kernel instead of having copies all over the place.
	Here's the changes:
	-Projects now uses custom Makefiles. Define the path of the kernel files and your custom compilation options in there. For the moment the kernel files and objects are still referenced in the game's makefiles. Eventually it will delegate to a kernel makefile.
	-All demos have been converted to use the WIP kernel
	-Added fadein/fadeout functions
	-Added Dave's UART and MMC functions in the kernel
	-Fixed a bug in the SetTile function
	-Cleanup of include files


	Initial
	-------
	This revision is still in development. It is stable and you can use it for new games.
	However I can not guarantee backward compatibility with the final release.
	All demos unser the /demos folder are not working with this code except Whack-a-Mole
	which support both the new video mode3 and the SNES mouse.

	New Features:
	-New video mode 3: 30x28 Tiles+Sprites using 8x8 tiles & sprites. Scrolling yet to be implemented. Currently, heavy CPU usage requires disabling one or more sound channels.
	-New EEPROM libraries to save game related data (ie: scores, progress, etc).
	-New switchable color correction for the composite output. It's been reported to screw some LCD TV, but for those, use the S-VIDEO output!
	-Support for the SNES mouse
	-Fixed mode1 to remove unrolled loop


Rev 2.0 Beta3 Notes
-------------------
	-Fixed stutter problem on LCD TVs. Note that NTSC signal is now much more standard. Side effect is that composite usual artifacts are more visible.
	-Added screen sections in video mode 2. Those are vertical sections or arbitrary height with independant scroll and tile memory. This removes the need for the overlay.
	-Added one more sprite per line (insure uzeboxVideoEngineCore.o is first in link list as it requires 8bits aligment)
	-Added an optional PCM channel that can replace the current noise channel.
	-Various optimizations
	-Cleanup of header files
	-Reorganized demos in their own subfolder


Rev 2.0 Beta2 Notes
-------------------
	-Removed unrolled loop for mode 1(tiles-only) and regained ~2K of flash.
	-Added SetMixerVoice() function to get direct control of music mixer
	-Overlay now supports priority with sprites (overlay can be on top or under sprites)
	-Fixed small sprites bugs
	-Optimized sprite buffer, recovered 64 bytes of RAM :P


Rev 2.0 Beta Notes
------------------
	Update highlights:
	-A new video mode that features a sprites engine and full screen scrolling
	-Supports SNES Joystick as baseline. NES is supported with a compilation option. Data read from joystick is now an int.
	-Added custom compilation options to reduce kernel code & RAM usage (see /kernel/defines.h)
	-Regrouped all API functions/defines in /kernel/uzebox.h
	-Improved the NTSC sync timings. It should be even better when I get my digital scope. ;)
	-Console can be reset with a joypad combination (Select+Start+A+B)
	-Improved code cleansing & documentation
	-And not the least, the GFX/Music conversion tools (under /tools) are now in the package! Don't know what happened for V1.0.

	This release contains 5 demos to help you get started. All HEX files of these demos are directly under the /demos

	-Tutorial: A basic Hello World!
	-Maze: A maze game by Clay Cowgill.
	-Megatris: A Tetris clone.
	-Sound Demo: Plays many NES classics.
	-Sprite Demo: Demonstrates the new sprites and scrolling engine.



Rev 1.0 - 24-Aug-2008
---------------------
	Initial release
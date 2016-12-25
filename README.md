# Ultima VII Usability Hacks
Some modifications to the 1992 video game _Ultima VII: The Black Gate_, written
as bits of (mostly 16-bit) x86 assembly, together with a program, written in
Java, that patches them into the game's executable.

Added functionality:
* select a party member, in many contexts, with the corresponding number key:
  * give an item to the Nth party member by pressing N while dragging
  * open the Nth party member's inventory, backpack, or stats by pressing N, Shift+N, or Alt+N
  * feed the Nth party member by pressing F and then pressing N
  * cast a spell on the Nth party member by pressing N while selecting the spell's target
* cast spells by typing their magic rune letters in real-time (start by pressing the / (Slash) key)
  * remove the last typed rune with Backspace
  * accept the typed runes with Enter
* use several bags to organize an inventory, as the amount of space taken up by a bag or backpack now depends upon its contents
* press K to find and use the key for a selected door or chest
* use many items by hotkey:
  * B: spellbook(s)
  * F: food items
  * G: abacus (to count party gold)
  * M: cloth map
  * O: Orb of the Moons
  * P: lockpicks
  * W: pocketwatch
  * X: sextant
* target an item to use (or attack) by pressing T
* see an item's weight by Shift+clicking it
* see an item's bulk/volume by Ctrl+clicking it
* close dialogs by right-clicking on them
* toggle cheats in-game by pressing Alt+\ (Alt+Backslash)
* use keyboard-friendlier controls in the Save dialog and quantity sliders
  * select save slots with number or arrow keys
  * adjust quantity with arrow keys (and Shift) and accept with Enter

Also, some overwhelmingly loud or frequent background sounds (such as the
flickering of fire swords) are silenced or attentuated.

The hacks take the form of assembly files written in NASM syntax, and rely on
some supporting macros that include metadata in the assembled output files
regarding overall placement in the patched executable file as well as the
locations of segment references (in particular, the segment portions of far
procedure calls) which necessitate edits to the patched executable's relocation
tables.

The Java project, UltimaPatcher, requires Java 1.8 or higher to compile and uses
the Apache Maven build system.

## How to Apply The Patches to Ultima VII

These patches are designed to be applied to version 3.4 of Ultima VII as
distributed by GOG.com.

U7.EXE should be backed up before proceeding, as should saved games.

NASM, a Java 1.8 JDK, and Maven should be installed and on the system path
before attepting to build the code and apply the patches. Git for Windows supplies
a Bash shell suitable for processing the listed commands.

The Java program _UltimaPatcher_ must be built by invoking Maven in the
`UltimaPatcher` directory:

`mvn compile package`

Applying the patches requires that the last overlay of the game's executable
(U7.EXE) first be expanded to provide room for several new procedures (this
increases the executable's size by several kilobytes). This is the first task
to be performed by the Java project built in the previous step (the jar should
be found in the `target` directory):

`java -jar UltimaPatcher.jar --exe=U7.EXE --expand_last_overlay`

NASM can then be invoked to assemble each .asm file in the `ultima7`
directory to a .o file:

`for a in *.asm ; do nasm $a -o ${a/.asm/.o} ; done`

Finally, _UltimaPatcher_ must be invoked again to apply each .o patch to the
executable:

`for o in *.o ; do java -jar UltimaPatcher.jar --exe=U7.EXE --patch=$o ; done`

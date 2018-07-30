# Ultima Hacks
Some modifications to the video games _Ultima VII: The Black Gate_ (1992) and
_Ultima Underworld II: Labyrinth of Worlds_ (1993), written as bits of (mostly
16-bit) x86 assembly, together with a program, written in Java, that patches
them into the game's executable.

The hacks take the form of assembly files written in NASM syntax, and rely on
some supporting macros that include metadata in the assembled output files
regarding overall placement in the patched executable file as well as the
locations of segment references (in particular, the segment portions of far
procedure calls) which necessitate edits to the patched executable's relocation
tables.

The Java project, UltimaPatcher, requires Java 1.9 or higher to compile and uses
the Apache Maven build system.

# Ultima VII: The Black Gate
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

# Ultima Underworld II: Labyrinth of Worlds
The biggest change is the addition of **mouse-look** (looking around by moving the mouse),
which can be toggled on and off with a keypress. In support of this, the allowed range
of vertical view angle has been greatly expanded, and the 3D rendering engine has been
hacked to have it draw the bits of the world that become visible when the player looks
sharply upward or downward.

The behavior of "adjusting" the player's heading when the player would back into a wall,
which could be very frustrating during combat, has been removed.

Skill points gained in training are now immediately reported in the message log.

A number of **keys** have been added or changed:
* ` (backquote): toggle mouse-look
* wasd: movement, typical of modern shooters
* Space: attack (last attack type, or slash)
* Shift: jump
* Ctrl+Shift: standing long jump
* Shift: fly up
* Ctrl: fly down
* LeftArrow: turn left
* RightArrow: turn right
* q: look at object in 3D view
* e: use object in 3D view
* c: display map
* r: flip to rune-bag panel
* f: flip to character panel
* g: activate compass
* h: activate health and mana flasks
* v: close container in inventory view
* Ctrl+Alt+\<letter\>: select a rune for spellcasting
* Ctrl+Alt+Space: cast the selected runes
* Ctrl+Alt+Backspace: clear selected runes

on Map screen:
* s: up one level
* w: down next level
* d: previous realm
* a: next realm
* c: go to Avatar's level

# How to Apply The Patches

These patches are intended to be applied to specific versions of the games
(3.4 of Ultima VII and vF1.99S of Ultima Underworld II, both as distributed by GOG.com).

Game executables, as well as saved games, should be backed up before proceeding.

NASM, a Java 1.9 or higher JDK, and Apache Maven should be installed and on the
system path before attepting to build the code and apply the patches. Git for
Windows supplies a Bash shell capable of processing the listed commands.

The Java program _UltimaPatcher_ must be built by invoking Maven in the
`UltimaPatcher` directory:

`mvn compile package`

Applying the patches requires that a particular overlay-segment of the game's
executable (U7.EXE / UW2.EXE) first be expanded to provide room for several new
procedures (this increases the executable's size by a few kilobytes). This is the
first task to be performed by the Java project built in the previous step (the jar
should be found in the `target` directory):

`java -jar UltimaPatcher.jar --exe=U7.EXE --expand_overlay_index=348 --expand_overlay_length=0x4000`

`java -jar UltimaPatcher.jar --exe=UW2.EXE --expand_overlay_index=93 --expand_overlay_length=0x4000`

NASM can then be invoked to assemble each .asm file in the `ultima7` or `uw2`
directory to a .o file:

`for a in *.asm ; do nasm $a -o ${a/.asm/.o} ; done`

Finally, _UltimaPatcher_ must be invoked again to apply each .o patch to the
executable:

`for o in *.o ; do java -jar UltimaPatcher.jar --exe=U7.EXE --patch=$o ; done`

`for o in *.o ; do java -jar UltimaPatcher.jar --exe=UW2.EXE --patch=$o ; done`

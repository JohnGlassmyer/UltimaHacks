%include "include/u7si-all-includes.asm"

%define controlsTitle "UltimaHacks/U7SI - Controls"

%define combatStatusLine "~l: show Combat Status"

%define altMb1Line "~Alt+MB1: show Magic Scroll spell"

%define frioRuneKeyLine "~Note: 'f' for Flam, 'F' for Frio."

%define keyUsableItemLineX2 \
		"~j: serpent jawbone", \
		"~w: pocketwatch"

%include "../u7-common/patch-eop-displayControls.asm"

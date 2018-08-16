%include "include/u7bg-all-includes.asm"

[bits 16]

startPatch EXE_LENGTH, rightClickToClose
	defineAddress 339, 0x07A5, Button_checkCoords
	defineAddress 339, 0x0836, Button_mouseInBounds
	defineAddress 339, 0x0923, Button_notPressed
	defineAddress 339, 0x0935, Button_notInBounds
	
	defineAddress 340, 0x1810, processInput_skipIfMouse2
	
	defineAddress 341, 0x0238, Container_checkCoords
	defineAddress 341, 0x02AA, Container_mouseInBounds
	defineAddress 341, 0x02E4, Container_returnCloseCode
	defineAddress 341, 0x0333, Container_notInBounds
	
	defineAddress 342, 0x04F5, Stats_checkCoords
	defineAddress 342, 0x0593, Stats_mouseInBounds
	defineAddress 342, 0x05B6, Stats_returnCloseCode
	defineAddress 342, 0x05D3, Stats_notInBounds
	
	defineAddress 348, 0x082E, Spellbook_checkCoords
	defineAddress 348, 0x0894, Spellbook_checkCoords_end
	defineAddress 348, 0x089D, Spellbook_returnCloseCode
	defineAddress 348, 0x08A8, Spellbook_mouseInBounds
	defineAddress 348, 0x0A80, Spellbook_notInBounds
	
	%include "../u7-common/block-rightClickToClose.asm"
	
	defineAddress 342, 0x1225, Character_checkCoords
	defineAddress 342, 0x12D1, Character_mouseInBounds
	defineAddress 342, 0x1596, Character_returnCloseCode
	defineAddress 342, 0x1868, Character_notInBounds
	
	startBlockAt addr_Character_checkCoords
		%assign off_mouseInBounds       off_Character_mouseInBounds
		%assign off_returnCloseCode     off_Character_returnCloseCode
		%assign off_notInBounds         off_Character_notInBounds
		
		%define pn_controlPosition      si+0x21
		%define pn_bounds               si+0x3F
		
		%assign arg_pn_mouseState       0x08
		%assign var_inBoundsReturn     -0x02
		%assign var_mouseX             -0x04
		%assign var_mouseY             -0x06
		%assign var_mouseXy            -0x0C
		
		checkMouseCoordsAndButton
		
		times 69 nop
	endBlockAt off_Character_mouseInBounds
endPatch

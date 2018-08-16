%include "include/u7si-all-includes.asm"

[bits 16]

startPatch EXE_LENGTH, rightClickToClose
	defineAddress 325, 0x086E, Button_checkCoords
	defineAddress 325, 0x08FF, Button_mouseInBounds
	defineAddress 325, 0x09E9, Button_notPressed
	defineAddress 325, 0x09FB, Button_notInBounds
	
	defineAddress 326, 0x0DEF, processInput_skipIfMouse2

	defineAddress 329, 0x0240, Container_checkCoords
	defineAddress 329, 0x02AA, Container_mouseInBounds
	defineAddress 329, 0x02E4, Container_returnCloseCode
	defineAddress 329, 0x0333, Container_notInBounds
	
	defineAddress 330, 0x067C, Stats_checkCoords
	defineAddress 330, 0x071A, Stats_mouseInBounds
	defineAddress 330, 0x073D, Stats_returnCloseCode
	defineAddress 330, 0x075A, Stats_notInBounds
	
	defineAddress 338, 0x0868, Spellbook_checkCoords
	defineAddress 338, 0x08CE, Spellbook_checkCoords_end
	defineAddress 338, 0x08D7, Spellbook_returnCloseCode
	defineAddress 338, 0x08E2, Spellbook_mouseInBounds
	defineAddress 338, 0x0ABA, Spellbook_notInBounds
	
	%include "../u7-common/block-rightClickToClose.asm"
	
	defineAddress 321, 0x074F, CombatStatus_checkCoords
	defineAddress 321, 0x07FC, CombatStatus_mouseInBounds
	defineAddress 321, 0x081D, CombatStatus_returnCloseCode
	defineAddress 321, 0x0C6E, CombatStatus_notInBounds
	
	startBlockAt addr_CombatStatus_checkCoords
		%assign off_mouseInBounds       off_CombatStatus_mouseInBounds
		%assign off_returnCloseCode     off_CombatStatus_returnCloseCode
		%assign off_notInBounds         off_CombatStatus_notInBounds
		
		%define pn_controlPosition      si+0x21
		%define pn_bounds               si+0x3F
		
		%assign arg_pn_mouseState       0x08
		%assign var_inBoundsReturn     -0x0A
		%assign var_mouseX             -0x04
		%assign var_mouseY             -0x06
		%assign var_mouseXy            -0x0C
		
		checkMouseCoordsAndButton
		
		times 72 nop
	endBlockAt off_CombatStatus_mouseInBounds
	
	defineAddress 330, 0x2C07, Character_checkCoords
	defineAddress 330, 0x2CB3, Character_mouseInBounds
	defineAddress 330, 0x3286, Character_returnCloseCode
	defineAddress 330, 0x33BB, Character_notInBounds
	
	startBlockAt addr_Character_checkCoords
		%assign off_mouseInBounds       off_Character_mouseInBounds
		%assign off_returnCloseCode     off_Character_returnCloseCode
		%assign off_notInBounds         off_Character_notInBounds
		
		%define pn_controlPosition      si+0x21
		%define pn_bounds               si+0x3F
		
		%assign arg_pn_mouseState       0x08
		%assign var_inBoundsReturn     -0x02
		%assign var_mouseX             -0x06
		%assign var_mouseY             -0x08
		%assign var_mouseXy            -0x0E
		
		checkMouseCoordsAndButton
		
		times 69 nop
	endBlockAt off_Character_mouseInBounds
	
	defineAddress 332, 0x0489, Jawbone_checkCoords
	defineAddress 332, 0x0530, Jawbone_mouseInBounds
	defineAddress 332, 0x06C7, Jawbone_returnCloseCode
	defineAddress 332, 0x06E0, Jawbone_notInBounds
	
	startBlockAt addr_Jawbone_checkCoords
		%assign off_mouseInBounds       off_Jawbone_mouseInBounds
		%assign off_returnCloseCode     off_Jawbone_returnCloseCode
		%assign off_notInBounds         off_Jawbone_notInBounds
		
		%define pn_controlPosition      si+0x21
		%define pn_bounds               si+0x3F
		
		%assign arg_pn_mouseState       0x08
		%assign var_inBoundsReturn     -0x02
		%assign var_mouseX             -0x06
		%assign var_mouseY             -0x08
		%assign var_mouseXy            -0x0E
		
		checkMouseCoordsAndButton
		
		times 64 nop
	endBlockAt off_Jawbone_mouseInBounds
	
	defineAddress 336, 0x017F, MagicScroll_checkCoords
	defineAddress 336, 0x0226, MagicScroll_mouseInBounds
	defineAddress 336, 0x0245, MagicScroll_returnCloseCode
	defineAddress 336, 0x028B, MagicScroll_notInBounds
	
	startBlockAt addr_MagicScroll_checkCoords
		%assign off_mouseInBounds       off_MagicScroll_mouseInBounds
		%assign off_returnCloseCode     off_MagicScroll_returnCloseCode
		%assign off_notInBounds         off_MagicScroll_notInBounds
		
		%define pn_controlPosition      si+0x21
		%define pn_bounds               si+0x3F
		
		%assign arg_pn_mouseState       0x08
		%assign var_inBoundsReturn     -0x0A
		%assign var_mouseX             -0x04
		%assign var_mouseY             -0x06
		%assign var_mouseXy            -0x0E
		
		checkMouseCoordsAndButton
		
		times 66 nop
	endBlockAt off_MagicScroll_mouseInBounds
endPatch

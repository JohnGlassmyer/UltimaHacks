%include "include/u7bg-all-includes.asm"

defineAddress 30, 0x0084, gameStep_callDiscardKeys

defineAddress 31, 0x0F9F, callTranslateKeyBeforeProcessKey
defineAddress 31, 0x0FB3, callTranslateKeyBeforeProcessKey_end

defineAddress 31, 0x07EB, keyMappingCode
defineAddress 31, 0x0924, keyMappingCode_end

defineAddress 31, 0x0924, mouseMove
defineAddress 31, 0x0941, mouseName
defineAddress 31, 0x0949, mouseAutoroute
defineAddress 31, 0x09DD, mouseUse
defineAddress 31, 0x09ED, exit
defineAddress 31, 0x09FD, combat
defineAddress 31, 0x0A27, save
defineAddress 31, 0x0A34, audio
defineAddress 31, 0x0A5E, inventory
defineAddress 31, 0x0A72, stats
defineAddress 31, 0x0A7F, version
defineAddress 31, 0x0A86, handedness

defineAddress 31, 0x0ADB, cheatsBlock
defineAddress 31, 0x0ADB, cheat_f1
defineAddress 31, 0x0AEC, cheat_f2
defineAddress 31, 0x0B0D, cheat_f3
defineAddress 31, 0x0B1F, cheat_f4
defineAddress 31, 0x0B46, cheat_f5
defineAddress 31, 0x0B58, cheat_f7
defineAddress 31, 0x0B72, cheat_f8
defineAddress 31, 0x0B84, cheat_f9
defineAddress 31, 0x0CFA, cheat_alt1
defineAddress 31, 0x0D0C, cheat_alt2
defineAddress 31, 0x0D2B, cheat_alt3
defineAddress 31, 0x0D97, cheat_alt4
defineAddress 31, 0x0DA9, cheat_alt5
defineAddress 31, 0x0DB1, cheat_f
defineAddress 31, 0x0DCA, cheat_o
defineAddress 31, 0x0DE0, cheat_w
defineAddress 31, 0x0DF6, cheat_d
defineAddress 31, 0x0E1A, cheatsBlock_end

defineAddress 31, 0x0E1A, directionKeys
defineAddress 31, 0x0E29, numberKeys

defineAddress 31, 0x0E42, afterKeyHandlers
defineAddress 31, 0x0ED5, endOfFunction

defineAddress 31, 0x0EDB, actionMappingTable
defineAddress 31, 0x0F77, actionMappingTable_end

%define reg_pn_stepsRemaining di

%macro gameSpecificKeyMappingCode 0
	%assign off_cheat_alt6 block_currentOffset
		jmp prompt_end
		prompt:
			db "Music # (-1 to stop)", 0
			prompt_end:
			%assign prompt_length (prompt_end - prompt)

		push si

		push prompt_length
		callFromLoadModule allocateNearMemory
		pop cx
		mov si, ax

		push cs
		push offsetInCodeSegment(prompt)
		push ds
		push si
		callFromLoadModule strcpy_far
		add sp, 8

		push si
		callFromLoadModule promptForIntegerWord
		pop cx

		push ax
		callFromLoadModule playMusic
		pop cx

		pop si

		jmp calcJump(off_afterKeyHandlers)

		times 61 nop
%endmacro

%include "../u7-common/patch-processKeyWithoutDialogs.asm"

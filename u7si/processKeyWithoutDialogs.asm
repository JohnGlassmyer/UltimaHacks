%include "include/u7si-all-includes.asm"

defineAddress 21, 0x0069, gameStep_callDiscardKeys

defineAddress 22, 0x1408, callTranslateKeyBeforeProcessKey
defineAddress 22, 0x141C, callTranslateKeyBeforeProcessKey_end

defineAddress 22, 0x080F, keyMappingCode
defineAddress 22, 0x096B, keyMappingCode_end

defineAddress 22, 0x096B, mouseMove
defineAddress 22, 0x0994, mouseName
defineAddress 22, 0x09B1, mouseAutoroute
defineAddress 22, 0x0A54, mouseUse
defineAddress 22, 0x0A70, exit
defineAddress 22, 0x0A80, combat
defineAddress 22, 0x0AB6, save
defineAddress 22, 0x0C37, audio
defineAddress 22, 0x0CCC, inventory
defineAddress 22, 0x0CEC, stats
defineAddress 22, 0x0D05, version
defineAddress 22, 0x0D18, handedness

defineAddress 22, 0x0AE8, spellbook
defineAddress 22, 0x0ACF, combatStatus
defineAddress 22, 0x0B45, jawbone
defineAddress 22, 0x0BA2, target
defineAddress 22, 0x0BF2, map
defineAddress 22, 0x0D9C, keyring
defineAddress 22, 0x0DEC, food
defineAddress 22, 0x0E0D, lockpick

defineAddress 22, 0x0E5E, cheatsBlock
defineAddress 22, 0x0E5E, cheat_f1
defineAddress 22, 0x0E7B, cheat_f2
defineAddress 22, 0x0E9C, cheat_f3
defineAddress 22, 0x0EBA, cheat_altP ; single-step
defineAddress 22, 0x0EE1, cheat_altf5
defineAddress 22, 0x0EFF, cheat_altf7 ; toggle debug printing
defineAddress 22, 0x0F25, cheat_altf8
defineAddress 22, 0x0F43, cheat_altf9
defineAddress 22, 0x0F61, cheat_backquote
defineAddress 22, 0x0FC7, cheat_alt1
defineAddress 22, 0x0FE5, cheat_alt2
defineAddress 22, 0x1010, cheat_alt3
defineAddress 22, 0x1094, cheat_alt4
defineAddress 22, 0x10B2, cheat_alt5
defineAddress 22, 0x10BA, cheat_alt6 ; sound
defineAddress 22, 0x10D8, cheat_alt7 ; expire item
defineAddress 22, 0x1133, cheat_alt8 ; frame limiter
defineAddress 22, 0x11A3, cheat_alt9 ; key array
defineAddress 22, 0x11C7, cheat_o
defineAddress 22, 0x11ED, watch
defineAddress 22, 0x1241, cheat_d
defineAddress 22, 0x1259, cheatsBlock_end

defineAddress 22, 0x126E, directionKeys
defineAddress 22, 0x127F, numberKeys

defineAddress 22, 0x128E, afterKeyHandlers
defineAddress 22, 0x1321, endOfFunction

defineAddress 22, 0x1327, actionMappingTable
defineAddress 22, 0x13E9, actionMappingTable_end

%define reg_pn_stepsRemaining si
%define reg_keyCode di

%macro gameSpecificKeyMappingCode 0
	; none
%endmacro

%include "../u7-common/patch-processKeyWithoutDialogs.asm"

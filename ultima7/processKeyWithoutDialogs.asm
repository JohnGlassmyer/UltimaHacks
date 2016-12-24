%include "include/UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

off_segmentZero                     EQU 0x19070

off_keyMappingCode                  EQU 0x1985B
off_keyMappingCode_end              EQU off_keyMappingCode + 199
off_toggleCheats                    EQU off_keyMappingCode_end
off_toggleCheats_end                EQU off_toggleCheats + 16
off_cheatMappingTable               EQU off_toggleCheats_end
off_cheatMappingTable_end           EQU 0x19994

off_mouseMove                       EQU 0x19994
off_mouseName                       EQU 0x199B1
off_mouseAutoroute                  EQU 0x199B9
off_mouseUse                        EQU 0x19A4D
off_exit                            EQU 0x19A5D
off_combat                          EQU 0x19A6D
off_save                            EQU 0x19A97
off_audio                           EQU 0x19AA4
off_inventory                       EQU 0x19ACE
off_stats                           EQU 0x19AE2
off_version                         EQU 0x19AEF
off_handedness                      EQU 0x19AF6

off_cheatsBlock                     EQU 0x19B4B
off_cheat_f1                        EQU 0x19B55
off_cheat_f2                        EQU 0x19B66
off_cheat_f3                        EQU 0x19B87
off_cheat_f4                        EQU 0x19B99
off_cheat_f5                        EQU 0x19BC0
off_cheat_f7                        EQU 0x19BD2
off_cheat_f8                        EQU 0x19BEC
off_cheat_f9                        EQU 0x19BFE
off_cheat_alt1                      EQU 0x19D74
off_cheat_alt2                      EQU 0x19D86
off_cheat_alt3                      EQU 0x19DA5
off_cheat_alt4                      EQU 0x19E11
off_cheat_alt5                      EQU 0x19E19
off_cheat_w                         EQU 0x19E57
off_cheat_f                         EQU 0x19E2B
off_cheat_o                         EQU 0x19E41
off_cheat_d                         EQU 0x19E6D
off_cheatsBlock_end                 EQU 0x19E8A

off_directionKeys                   EQU 0x19E8A
off_numberKeys                      EQU 0x19E99

off_afterKeyHandlers                EQU 0x19EB2
off_endOfFunction                   EQU 0x19F45

off_actionMappingTable              EQU 0x19F4B
off_actionMappingTable_end          EQU 0x19FE7

;-----------------------------------------------------------
;-----------------------------------------------------------

%define mapAction(keyCode, off_handler) \
        dw keyCode, (off_handler - off_segmentZero)
        
%define cseg_actionMappingTable off_actionMappingTable - off_segmentZero
responsiveAvatarActionMappingCount \
    EQU (responsiveAvatarActionMappingEnd - actionMappingStart) / 4
unresponsiveAvatarActionMappingCount \
    EQU (unresponsiveAvatarActionMappingEnd - actionMappingStart) / 4
    
%define cseg_cheatMappingTable (off_cheatMappingTable - off_segmentZero)
cheatMappingCount EQU (cheatMappingEnd - cheatMappingStart) / 4

;-----------------------------------------------------------
;-----------------------------------------------------------

startPatch EXPANDED_OVERLAY_U7_EXE_LENGTH, \
        no-dialogs key handling code - now calls eop-Keyactions for many things
        
    off_callTranslateKeyBeforeProcessKey     EQU 0x1A00F
    off_callTranslateKeyBeforeProcessKey_end EQU 0x1A023
    startBlockAt off_callTranslateKeyBeforeProcessKey
        ; don't translate key here, so that eop-keyActions
        ; can process keys even when a mouse button is held
    endBlockWithFillAt nop, off_callTranslateKeyBeforeProcessKey_end
    
    off_translateKey_pollkey     EQU 0x21557
    off_translateKey_pollkey_end EQU 0x21571
    startBlockAt off_translateKey_pollkey
        ; don't try to poll a key code in translateKey;
        ; instead, use the key code now passed from processKey (below)
        mov bx, [bp+0xA]
        xor ax, ax
        mov [bx], ax
        mov [di], ax
    endBlockWithFillAt nop, off_translateKey_pollkey_end
    
    startBlockAt off_keyMappingCode
        %assign arg_mouseY                      0x0A
        %assign arg_mouseX                      0x08
        %assign arg_keyCode                     0x06
        %assign var_keyActionsReturnValue      -0x02
        
        push 1
        callWithRelocation l_pollKey
        pop cx
        mov [bp+arg_keyCode], ax
        
        push dseg_avatarIbo
        callWithRelocation l_isNpcUnconscious
        pop cx
        or al, al
        jnz avatarUnresponsive
        
        avatarResponsive:
            cmp byte [di], 0
            jnz calcJump(off_afterKeyHandlers)
            
            push word [bp+arg_keyCode]
            callEopFromLoadModule 1, keyActions
            pop cx
            mov [bp+var_keyActionsReturnValue], ax
            
            lea ax, [bp+arg_mouseY]
            push ax
            lea ax, [bp+arg_mouseX]
            push ax
            lea ax, [bp+arg_keyCode]
            push ax
            callWithRelocation l_translateKeyWithoutDialogs
            add sp, 6
            
            mov bx, [bp+arg_keyCode]
            
            ; skip handling any "key" other than a translated mouse button
            ; if eop-keyActions has already handled the untranslated key
                cmp bx, 0x200
                jae notSkipKey
                cmp word [bp+var_keyActionsReturnValue], 0
                jz notSkipKey
                jmp calcJump(off_afterKeyHandlers)
                
            notSkipKey:
            
            cmp bx, '1'
            jb notTranslatedNumberKey
            cmp bx, '9'
            ja notTranslatedNumberKey
            jmp calcJump(off_numberKeys)
            notTranslatedNumberKey:
            
            cmp bx, 0x147
            jb notDirectionKey
            cmp bx, 0x151
            ja notDirectionKey
            jmp calcJump(off_directionKeys)
            notDirectionKey:
            
            mov cx, responsiveAvatarActionMappingCount
            
            jmp tryKeyMappings
            
        avatarUnresponsive:
            mov byte [di], 0
            
            cmp byte [dseg_playerActionSuspended], 0
            jnz calcJump(off_endOfFunction)
            
            mov cx, unresponsiveAvatarActionMappingCount
            
        tryKeyMappings:
            cmp word [bp+arg_keyCode], 0
            jz afterTryingMappings
            
            mov bx, cseg_actionMappingTable
            tryActionMapping:
            mov ax, [cs:bx]
            cmp ax, [bp+arg_keyCode]
            jnz notThisActionMapping
            jmp [cs:bx+2]
            notThisActionMapping:
            add bx, 4
            loop tryActionMapping
            
            cmp word [dseg_cheatsEnabled], 0
            jz afterCheats
            mov cx, cheatMappingCount
            mov bx, cseg_cheatMappingTable
            tryCheatMapping:
            mov ax, [cs:bx]
            cmp ax, [bp+arg_keyCode]
            jnz notThisCheatMapping
            jmp [cs:bx+2]
            notThisCheatMapping:
            add bx, 4
            loop tryCheatMapping
            afterCheats:
            
        afterTryingMappings:
        
        jmp calcJump(off_afterKeyHandlers)
    endBlockAt off_keyMappingCode_end
    
    startBlockAt off_toggleCheats
        callEopFromLoadModule 0, toggleCheats
        jmp calcJump(off_afterKeyHandlers)
    endBlockAt off_toggleCheats_end
    
    startBlockAt off_cheatMappingTable
        cheatMappingStart:
        
        mapAction(0x13B, off_cheat_f1)          ; F1
        mapAction(0x13C, off_cheat_f2)          ; F2
        mapAction(0x13D, off_cheat_f3)          ; F3
        mapAction(0x13E, off_cheat_f4)          ; F4
        mapAction(0x13F, off_cheat_f5)          ; F5
        mapAction(0x141, off_cheat_f7)          ; F7
        mapAction(0x142, off_cheat_f8)          ; F8
        mapAction(0x143, off_cheat_f9)          ; F9
        
        ; Alt+digit cheats moved to Alt+Fn
        ; as Alt+digit now opens party member Stats
        mapAction(0x168, off_cheat_alt1)        ; Alt+F1
        mapAction(0x169, off_cheat_alt2)        ; Alt+F2
        mapAction(0x16A, off_cheat_alt3)        ; Alt+F3
        mapAction(0x16B, off_cheat_alt4)        ; Alt+F4
        mapAction(0x16C, off_cheat_alt5)        ; Alt+F5
        
        ; Disabled because I'm not sure what these are supposed to do
        ; or whether they work, and they conflict with key-mappings
        ; that I use to do other things.
        ;mapAction(  'w', off_cheat_w)
        ;mapAction(  'f', off_cheat_f)
        ;mapAction(  'o', off_cheat_o)
        ;mapAction(  'd', off_cheat_d)
        
        cheatMappingEnd:
        
        times 35 nop
        
    endBlockAt off_cheatMappingTable_end
    
    ;-----------------------------------------------------------
    ;-----------------------------------------------------------
    
    startBlockAt off_actionMappingTable
        actionMappingStart:
        
        ; mappings which may be used by a conscious or unconscious Avatar
        mapAction(0x203, off_mouseUse)          ; left button double
        mapAction(0x12B, off_toggleCheats)      ; Alt+Backslash
        
        ; (many actions are now handled by eop-keyActions instead,
        ;   so that they are also available in dialog mode)
        
        unresponsiveAvatarActionMappingEnd:
        
        ; mappings which may only be used by a conscious Avatar
        mapAction(0x201, off_mouseName)         ; left button
        mapAction(0x205, off_mouseName)         ; left button held
        mapAction(0x202, off_mouseMove)         ; right button
        mapAction(0x206, off_mouseMove)         ; right button held
        mapAction(0x204, off_mouseAutoroute)    ; right button double
        
        responsiveAvatarActionMappingEnd:
        
        times 128 nop
    endBlockAt off_actionMappingTable_end
endPatch

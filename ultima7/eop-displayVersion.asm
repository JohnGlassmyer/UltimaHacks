%include "include/UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

; display Ultima VII version information in a scroll popup
;
; (also include text mentioning these usability hacks)
startPatch EXPANDED_OVERLAY_U7_EXE_LENGTH, \
        expanded overlay procedure: displayVersion
        
    startBlockAt off_eop_displayVersion
        push bp
        mov bp, sp
        
        ; bp-based stack frame:
        %assign ____callerIp            0x02
        %assign ____callerBp            0x00
        %assign var_hacksString        -0x28
        %assign var_string             -0xA8
        
        sub sp, 0xA8
        push si
        push di
        
        ; terminate the string at position 0 so strcat works as expected
        mov byte [bp+var_string], 0
        
        lea si, [bp+var_string]
        
        ; game title + newline
            push word [dseg_titleStringOffset]
            push si
            callWithRelocation o_strcat
            add sp, 4
            push dseg_tildeString
            push si
            callWithRelocation o_strcat
            add sp, 4
            
        ; copyright Origin + newline
            push word [dseg_copyrightStringOffset]
            push si
            callWithRelocation o_strcat
            add sp, 4
            push dseg_tildeString
            push si
            callWithRelocation o_strcat
            add sp, 4
            
        ; game version + newline
            push word [dseg_versionStringOffset]
            push si
            callWithRelocation o_strcat
            add sp, 4
            push dseg_tildeString
            push si
            callWithRelocation o_strcat
            add sp, 4
            
        ; newline + text mentioning these hacks
            push dseg_tildeString
            push si
            callWithRelocation o_strcat
            add sp, 4
            mov dword [bp+var_hacksString+0x00], 'with'
            mov dword [bp+var_hacksString+0x04], ' usa'
            mov dword [bp+var_hacksString+0x08], 'bili'
            mov dword [bp+var_hacksString+0x0C], 'ty h'
            mov dword [bp+var_hacksString+0x10], 'acks'
            mov dword [bp+var_hacksString+0x14], ' by '
            mov dword [bp+var_hacksString+0x18], 'John'
            mov dword [bp+var_hacksString+0x1C], ' Gla'
            mov dword [bp+var_hacksString+0x20], 'ssmy'
            mov dword [bp+var_hacksString+0x24], `er\0\0`
            lea ax, [bp+var_hacksString]
            push ax
            push si
            callWithRelocation o_strcat
            add sp, 4
            
        push ss
        lea ax, [bp+var_string]
        push ax
        callEopFromOverlay 2, popupScrollWithText
        add sp, 4
        
        pop di
        pop si
        mov sp, bp
        pop bp
        retn
        
    endBlockAt off_eop_displayVersion_end
endPatch

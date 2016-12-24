%include "include/UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

; Produce text to label a (clicked) item,
; substituting the item's weight or bulk in place of its name
; if the Shift key or Ctrl key, respectively, is held.
;
; The original game did not reveal any information about
; the bulk of items to the player other than by blocking attempts
; to place items inside of containers having insufficient space.
startPatch EXPANDED_OVERLAY_U7_EXE_LENGTH, \
        expanded overlay procedure:
        
    off_clickItemInWorld                EQU 0x6FFBF
    off_clickItemInWorld_end            EQU 0x7003A
    startBlockAt off_clickItemInWorld
        ; [bp-2] is ibo
        ; [bp-0x68] is string
        mov byte [bp-0x68], 0
        mov word [bp-0x17], 0
        
        push word [bp-2]
        lea ax, [bp-0x68]
        push ax
        callEopFromOverlay 2, produceItemLabelText
        add sp, 4
    endBlockWithFillAt nop, off_clickItemInWorld_end
    
    off_clickItemInInventory            EQU 0xA0E25
    off_clickItemInInventory_end        EQU 0xA0E97
    startBlockAt off_clickItemInInventory
        ; [bp+6] is iboRef
        ; [bp-0x60] is string
        mov bx, [bp+6]
        push word [bx]
        lea ax, [bp-0x60]
        push ax
        callEopFromOverlay 2, produceItemLabelText
        add sp, 4
    endBlockWithFillAt nop, off_clickItemInInventory_end
    
    startBlockAt off_eop_produceItemLabelText
        push bp
        mov bp, sp
        
        ; bp-based stack frame:
        %assign arg_ibo                 0x06
        %assign arg_dest                0x04
        %assign ____callerIp            0x02
        %assign ____callerBp            0x00
        %assign var_itemType           -0x02
        %assign var_itemFrame          -0x04
        %assign var_itemQuantity       -0x06
        %assign var_valueOfItem        -0x08
        %assign var_valueOfContents    -0x0A
        %assign var_capacityOfItem     -0x0C
        %assign var_valueString        -0x0E
        %assign var_valueLength        -0x10
        %assign var_templateVarCount   -0x12
        %assign var_templateBuffer     -0x62
        
        sub sp, 0x62
        push si
        push di
        
        mov es, word [dseg_itemBufferSegment]
        
        ; get type
        mov bx, [bp+arg_ibo]
        mov ax, [es:bx+4]
        and ax, 0x3FF
        mov [bp+var_itemType], ax
        
        callWithRelocation o_getLeftAndRightShiftStatus
        test al, al
        jnz produceWeightText
        
        callWithRelocation o_getCtrlStatus
        test al, al
        jnz produceBulkText
        
        jmp produceItemNameText
        
        weightString                    db 'weight', 0
        bulkString                      db 'bulk', 0
        
        itemTemplate                    db ': %d.%d', 0
        itemContentsTemplate            db ': %d.%d (contents: %d.%d)', 0
        itemContentsCapacityTemplate    db ': %d.%d (contents: %d.%d of %d.%d)', 0
        contentsTemplate                db ' of contents: %d.%d', 0
        
        produceWeightText:
            lea ax, [bp+arg_ibo]
            push ax
            callWithRelocation o_determineWeightWithQuantity
            add sp, 2
            mov word [bp+var_valueOfItem], ax
            
            lea ax, [bp+arg_ibo]
            push ax
            callWithRelocation o_determineWeightOfContents
            add sp, 2
            mov word [bp+var_valueOfContents], ax
            
            cmp word [bp+var_valueOfItem], 0
            jz dontIncludeWeightOfContents
            add word [bp+var_valueOfItem], ax
            dontIncludeWeightOfContents:
            
            mov word [bp+var_capacityOfItem], 0
            
            mov si, offsetInEopSegment(weightString)
            mov cx, 6
            
            jmp haveValues
            
        produceBulkText:
            push word [bp+arg_ibo]
            callEopFromOverlay 1, determineItemBulk
            add sp, 2
            mov word [bp+var_valueOfItem], ax
            
            lea ax, [bp+arg_ibo]
            push ax
            callWithRelocation o_determineBulkOfContents
            add sp, 2
            mov word [bp+var_valueOfContents], ax
            
            push word [bp+var_itemType]
            callWithRelocation o_getItemTypeBulk
            add sp, 2
            mov word [bp+var_capacityOfItem], ax
            
            mov si, offsetInEopSegment(bulkString)
            mov cx, 4
            
        haveValues:
            mov word [bp+var_valueLength], cx
            
            ; copy value string from code segment into stack
            push ds
            mov ax, cs
            mov ds, ax
            mov ax, ss
            mov es, ax
            lea di, [bp+var_templateBuffer]
            cld
            rep movsb
            pop ds
            
            mov word [bp+var_templateVarCount], 0
            
            %macro pushDiv10 1
                mov ax, %1
                mov dl, 10
                div dl
                xor cx, cx
                mov cl, ah
                push cx
                inc word [bp+var_templateVarCount]
                mov cl, al
                push cx
                inc word [bp+var_templateVarCount]
            %endmacro
            
            cmp word [bp+var_valueOfItem], 0
            jnz haveItem
            
            cmp word [bp+var_valueOfContents], 0
            jz procEnd
            
            mov si, offsetInEopSegment(contentsTemplate)
            pushDiv10 word [bp+var_valueOfContents]
            jmp applyTemplate
            
        haveItem:
            cmp word [bp+var_valueOfContents], 0
            jnz haveItemAndContents
            
            mov si, offsetInEopSegment(itemTemplate)
            pushDiv10 word [bp+var_valueOfItem]
            jmp applyTemplate
            
        haveItemAndContents:
            cmp word [bp+var_capacityOfItem], 0
            jnz haveItemAndContentsAndCapacity
            
            mov si, offsetInEopSegment(itemContentsTemplate)
            pushDiv10 word [bp+var_valueOfContents]
            pushDiv10 word [bp+var_valueOfItem]
            jmp applyTemplate
            
        haveItemAndContentsAndCapacity:
            mov si, offsetInEopSegment(itemContentsCapacityTemplate)
            pushDiv10 word [bp+var_capacityOfItem]
            pushDiv10 word [bp+var_valueOfContents]
            pushDiv10 word [bp+var_valueOfItem]
            
        applyTemplate:
            mov cx, 80
            sub cx, [bp+var_valueLength]
            
            ; copy template from code segment into stack
            push ds
            mov ax, cs
            mov ds, ax
            mov ax, ss
            mov es, ax
            lea di, [bp+var_templateBuffer]
            add di, [bp+var_valueLength]
            cld
            rep movsb
            pop ds
            
            sprintfTemplate:
            lea ax, [bp+var_templateBuffer]
            push ax
            push word [bp+arg_dest]
            callWithRelocation o_sprintf
            mov ax, [bp+var_templateVarCount]
            shl ax, 1
            add sp, ax
            
            jmp procEnd
            
        produceItemNameText:
        ; get frame
            mov bx, [bp+arg_ibo]
            mov ax, [es:bx+4]
            and ax, 0x7C00
            shr ax, 10
            mov [bp+var_itemFrame], ax
            
        ; get quantity
            mov ax, [bp+var_itemType]
            mov dx, 3
            imul dx
            mov bx, ax
            mov al, [dseg_itemTypeInfo+bx]
            and ax, 0xF
            cmp ax, 3
            jnz itemTypeHasNoQuantity
            
            lea ax, [bp+arg_ibo]
            push ax
            callWithRelocation o_Item_getQuantity
            add sp, 2
            mov word [bp+var_itemQuantity], ax
            jmp haveQuantity
            
            itemTypeHasNoQuantity:
                mov word [bp+var_itemQuantity], 0
                
        haveQuantity:
            push word [bp+var_itemFrame]
            push word [bp+var_itemQuantity]
            push word [bp+var_itemType]
            push word [bp+arg_dest]
            callWithRelocation o_produceItemDisplayName
            add sp, 8
            
        procEnd:
        
        pop di
        pop si
        mov sp, bp
        pop bp
        retn
        
    endBlockAt off_eop_produceItemLabelText_end
    
endPatch

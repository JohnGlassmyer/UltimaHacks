[bits 16]

startPatch EXE_LENGTH, itemLabels
	%macro produceTextOrBarkWithShape 0
		callVarArgsEopFromOverlay getKeyboardShiftBits, 0
		
		%%tryShift:
			test ax, KeyboardShiftBit_RIGHT_SHIFT | KeyboardShiftBit_LEFT_SHIFT
			jz .notShift
			
			mov ax, ItemLabelType_WEIGHT
			jmp %%haveLabelType
			
			.notShift:
			
		%%tryCtrl:
			test ax, KeyboardShiftBit_CTRL
			jz .notCtrl
			
			mov ax, ItemLabelType_BULK
			jmp %%haveLabelType
			
			.notCtrl:
			
		%%tryAlt:
			test ax, KeyboardShiftBit_ALT
			jz .notAlt
			
			push word [bp+var_ibo]
			callVarArgsEopFromOverlay shapeBarkForContent, 1
			pop cx
			
			jmp calcJump(off_end)
			
			.notAlt:
			
		mov ax, ItemLabelType_NAME
		
		%%haveLabelType:
		
		push ax
		push word [bp+var_ibo]
		lea ax, [bp+var_string]
		push ax
		callVarArgsEopFromOverlay produceItemLabelText, 3
		add sp, 6
	%endmacro
	
	startBlockAt addr_clickItemInWorld_produceText
		%assign var_ibo    -0x02
		%assign var_string -0x68
		
		%define off_end off_clickItemInWorld_end
		
		mov ax, [bp+var_ibo]
		produceTextOrBarkWithShape
		
		times 39 nop
	endBlockAt off_clickItemInWorld_produceText_end
	
	startBlockAt addr_clickItemInInventory_produceText
		%assign arg_pn_ibo  0x06
		%assign var_string -0x60
		%assign var_ibo    -0x60
		
		%define off_end off_clickItemInInventory_end
		
		mov bx, [bp+arg_pn_ibo]
		mov ax, [bx]
		mov [bp+var_ibo], ax
		produceTextOrBarkWithShape
		
		times 20 nop
	endBlockAt off_clickItemInInventory_produceText_end
endPatch

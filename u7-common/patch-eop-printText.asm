; An expanded-overlay procedure that prints text at a specified position on
;     screen with specified font and text alignment.
; Abstracts away the construction and configuration of the TextPrinter.

[bits 16]

startPatch EXE_LENGTH, eop-printText
	startBlockAt addr_eop_printText
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_pn_string           0x0E
		%assign arg_alignment           0x0C
		%assign arg_fontNumber          0x0A
		%assign arg_y                   0x08
		%assign arg_x                   0x06
		%assign arg_pn_viewport         0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_textPrinter        -0x10
		add sp, var_textPrinter
		
		push si
		push di
		
		lea bx, [bp+var_textPrinter]
		push bx
		callFromOverlay TextPrinter_new
		pop cx
		
		lea si, [bp+var_textPrinter]
		
		mov word [si+TextPrinter_pn_vtable], \
				dseg_pn_ProportionalTextPrinter_vtable
		
		mov ax, [bp+arg_pn_viewport]
		mov [si+TextPrinter_pn_viewport], ax
		mov ax, [bp+arg_x]
		mov [si+TextPrinter_x], ax
		mov ax, [bp+arg_y]
		mov [si+TextPrinter_y], ax
		
		push word [bp+arg_fontNumber]
		push si
		callFromOverlay TextPrinter_setFont
		pop cx
		pop cx
		
		applyHorizontalAlignment:
			test word [bp+arg_alignment], \
					TextAlignment_HORIZONTAL_CENTER | TextAlignment_RIGHT
			jz .afterHorizontal
			
			push word [bp+arg_pn_string]
			push si
			callFromOverlay TextPrinter_determineTextWidth
			pop cx
			pop cx
			
			test word [bp+arg_alignment], TextAlignment_HORIZONTAL_CENTER
			jz .afterCenter
			; to center, move by only half the width
			shr ax, 1
			.afterCenter:
			
			; move text position left
			sub [si+TextPrinter_x], ax
			
			.afterHorizontal:
			
		applyVerticalAlignment:
			test word [bp+arg_alignment], \
					TextAlignment_VERTICAL_CENTER | TextAlignment_BOTTOM
			jz .afterVertical
			
			push si
			callFromOverlay TextPrinter_getLineHeight
			pop cx
			
			test word [bp+arg_alignment], TextAlignment_VERTICAL_CENTER
			jz .afterCenter
			; to center, move by only half the height
			shr ax, 1
			.afterCenter:
			
			; move text position up
			add [si+TextPrinter_y], ax
			
			.afterVertical:
			
		; TODO: TextAlignment bit to bound to screen limits
		
		push word [bp+arg_pn_string]
		push si
		callFromOverlay TextPrinter_printString
		pop cx
		pop cx
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_printText_end
endPatch

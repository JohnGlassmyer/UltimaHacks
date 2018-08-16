; Display game version information in a scroll popup, also including text about
;     these UltimaHacks.

[bits 16]

startPatch EXE_LENGTH, eop-displayVersion
	startBlockAt addr_eop_displayVersion
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_farString          -0x04
		add sp, var_farString
		
		push si
		push di
		
		lea si, [bp+var_farString]
		
		push si
		callFromOverlay FarString_new
		pop cx
		
		%macro callAppendToFarString 2
			push %1
			push %2
			push si
			call appendToFarString
			add sp, 6
		%endmacro
		
		; game title + newline
		callAppendToFarString ds, dseg_titleString
		callAppendToFarString ds, dseg_tildeString
		
		; copyright Origin + newline
		callAppendToFarString ds, dseg_copyrightString
		callAppendToFarString ds, dseg_tildeString
		
		; copyright Origin + newline
		callAppendToFarString ds, dseg_versionString
		callAppendToFarString ds, dseg_tildeString
		
		; newline to separate
		callAppendToFarString ds, dseg_tildeString
		
		; text mentioning UltimaHacks
		callAppendToFarString cs, offsetInCodeSegment(hacksString)
		
		push TextDisplayType_SCROLL
		push si
		callVarArgsEopFromOverlay displayText, 2
		pop cx
		pop cx
		
		push 0 ; on stack; don't deallocate
		push si
		callFromOverlay FarString_destructor
		pop cx
		pop cx
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
		hacksString:
			db 'with UltimaHacks~'
			db '(assembled ', __DATE__, ')~'
			db 'https:// github.com / JohnGlassmyer / UltimaHacks'
			db 0
			
		appendToFarString:
			push bp
			mov bp, sp
			
			%assign .arg_ps_source    0x06
			%assign .arg_pn_farString 0x04
			
			push 1000
			push word [bp+.arg_ps_source+2]
			push word [bp+.arg_ps_source+0]
			mov bx, [bp+.arg_pn_farString]
			push word [bx+2]
			push word [bx+0]
			callFromOverlay strncat_far
			add sp, 10
			
			mov bx, [bp+.arg_pn_farString]
			les bx, [bx]
			mov byte [es:bx+999], 0
			
			mov sp, bp
			pop bp
			retn
			
	endBlockAt off_eop_displayVersion_end
endPatch

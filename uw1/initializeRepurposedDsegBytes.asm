%ifndef EXE_LENGTH
	%include "../UltimaPatcher.asm"
	%include "include/uw1.asm"
%endif

[bits 16]

startPatch EXE_LENGTH, \
		initialize repurposed bytes in dseg
		
	; zeroBytesInDseg numberOfBytes, dsegOffset
	%macro zeroBytesInDseg 2
		startBlockAt seg_dseg, %2
			times %1 db 0
		endBlockOfLength %1
	%endmacro
	
	zeroBytesInDseg 1, dseg_isMouseLookEnabled
	zeroBytesInDseg 1, dseg_wasMouseLookEnabledIn3dView
	zeroBytesInDseg 2, dseg_cursorXDuringMouseLook
	zeroBytesInDseg 2, dseg_cursorYDuringMouseLook
	zeroBytesInDseg 1, dseg_isDrawingBehindPlayer
	zeroBytesInDseg 1, dseg_wasLastBindingKey
	zeroBytesInDseg 2, dseg_pn_lastKeyOrMouseBinding
	zeroBytesInDseg 4, dseg_lastKeyBindingTime
	zeroBytesInDseg 1, dseg_haveWarnedAboutDrawQueueLimit
	zeroBytesInDseg 1, dseg_mouseLookOrientation
	
	startBlockAt seg_dseg, dseg_newlineString
		db `\n`, 0
	endBlock
	
	startBlockAt seg_dseg, dseg_trigScale
		; magnitude of 16-bit values
		; pi, as an angle; maximum magnitude of cos and sin values
		dd 0x8000
	endBlock
	
	startBlockAt seg_dseg, dseg_radianAngle
		; 0x8000 / pi
		dd 0x28BE
	endBlock
	
	startBlockAt seg_dseg, dseg_autoAttackType
		; 6 == slash attack-type
		db 6
	endBlock
endPatch

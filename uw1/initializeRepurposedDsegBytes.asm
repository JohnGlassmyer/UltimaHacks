%include "../UltimaPatcher.asm"
%include "include/uw1.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		initialize repurposed bytes in dseg
		
	; zeroBytesInDseg numberOfBytes, dsegOffset
	%macro zeroBytesInDseg 2
		startBlockAt off_dseg_segmentZero + %2
			times %1 db 0
		endBlockAt startAbsolute + %1
	%endmacro
	
	zeroBytesInDseg 1, dseg_isMouseLookEnabled
	zeroBytesInDseg 1, dseg_wasMouseLookEnabledIn3dView
	zeroBytesInDseg 2, dseg_cursorXDuringMouseLook
	zeroBytesInDseg 2, dseg_cursorYDuringMouseLook
	zeroBytesInDseg 1, dseg_isDrawingBehindPlayer
	zeroBytesInDseg 1, dseg_wasLastBindingKey
	zeroBytesInDseg 2, dseg_pn_lastKeyOrMouseBinding
	zeroBytesInDseg 4, dseg_lastKeyBindingTime
	zeroBytesInDseg 2, dseg_haveWarnedAboutDrawQueueLimit
	
	startBlockAt off_dseg_segmentZero + dseg_newlineString
		db `\n`, 0
	endBlockAt startAbsolute + 2
	
	startBlockAt off_dseg_segmentZero + dseg_trigScale
		; magnitude of 16-bit values
		; pi, as an angle; maximum magnitude of cos and sin values
		dd 0x8000
	endBlockAt startAbsolute + 4
	
	startBlockAt off_dseg_segmentZero + dseg_radianAngle
		; 0x8000 / pi
		dd 0x28BE
	endBlockAt startAbsolute + 4
	
	startBlockAt off_dseg_segmentZero + dseg_autoAttackType
		; 6 == slash attack-type
		db 6
	endBlockAt startAbsolute + 1
endPatch

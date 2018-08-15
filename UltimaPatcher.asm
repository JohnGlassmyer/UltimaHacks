%macro startPatch 2
	%assign patch_targetFileLength %1
	%defstr patch_description %2
	%strlen patch_descriptionLength patch_description
	%assign patch_blockCount 0
%endmacro

%macro startBlockAt 2
	%assign block_segmentIndex %1
	%assign block_startOffset %2
	%assign block_relativeStart ($ - $$)
	%assign block_relocationCount 0
%endmacro

%define block_currentRelativePosition (($ - $$) - block_relativeStart)

; inserts metadata regarding the preceding block of code
; (absolute start address and relocation sites)
%macro endBlockWithFillAt 2
	%assign block_endOffset %2
	
	%if block_endOffset > 0x10000
		%error block runs beyond offset 0xFFFF
	%endif
	
	%assign block_codeLength block_currentRelativePosition
	%assign block_totalLength block_endOffset - block_startOffset
	
	; fill remainder of patched block
	%assign block_fillLength block_totalLength - block_codeLength
	%if block_fillLength < 0
		%error block overrun
	%endif
	times block_fillLength %1
	
	dd block_totalLength
	
	%rep block_relocationCount
		dd %$relocationBase + %$relocationOffset - block_relativeStart
	%pop blockRelocationContext
	%endrep
	
	dd block_relocationCount
	
	dd block_startOffset
	dd block_segmentIndex
	
	%assign patch_blockCount patch_blockCount + 1
	
	%assign lastBlock_endOffset block_endOffset
%endmacro

%macro endBlockOfLength 1
	%assign endBlockOfLength_pos block_currentRelativePosition
	
	%if %1 != endBlockOfLength_pos
		%error block length expected to be %1, but is endBlockOfLength_pos
	%endif
	
	endBlockAt block_startOffset + %1
%endmacro

%macro endBlockAt 1
	endBlockWithFillAt hlt, %1
%endmacro

%macro endBlockWithFill 1
	endBlockWithFillAt %1, block_startOffset + block_currentRelativePosition
%endmacro

%macro endBlock 0
	endBlockWithFill hlt
%endmacro

%macro endPatch 0
	dd patch_blockCount
	dd patch_targetFileLength
	db patch_description
	dd patch_descriptionLength
%endmacro

; calculates the delta to a location within the same segment \
;	but outside of the local patch block
%define calcJump(targetOffset) \
		$ + (targetOffset - block_startOffset - block_currentRelativePosition)
		
; callWithRelocation 0xssss:0xoooo
; makes note of the site to be included in relocation metadata
%macro callWithRelocation 1
	%push blockRelocationContext
	%assign %$relocationOffset 3
	%$relocationBase:
	call %1
	%assign block_relocationCount block_relocationCount + 1
%endmacro

%macro pushWithRelocation 1
	%push blockRelocationContext
	%assign %$relocationOffset 1
	%$relocationBase:
	push strict word %1
	%assign block_relocationCount block_relocationCount + 1
%endmacro

%macro dwWithRelocation 1
	%push blockRelocationContext
	%assign %$relocationOffset 0
	%$relocationBase:
	dw %1
	%assign block_relocationCount block_relocationCount + 1
%endmacro

; defineSegment segmentIndex, segmentFromOverlay, segmentFromLoadModule, name
%macro defineSegment 3-4
	%assign segmentFromOverlay_%[%1] %2
	%assign segmentFromLoadModule_%[%1] %3
	%if %0 = 4
		%assign seg_%[%4] %1
		%assign segmentFromOverlay_%[%4] segmentFromOverlay_%[%1]
		%assign segmentFromLoadModule_%[%4] segmentFromLoadModule_%[%1]
	%endif
%endmacro

; defineAddress segmentIndex, offset, name
%macro defineAddress 3
	%assign seg_%[%3]                   %1
	%assign segmentFromOverlay_%[%3]    segmentFromOverlay_%[%1]
	%assign segmentFromLoadModule_%[%3] segmentFromLoadModule_%[%1]
	%assign off_%[%3]                   %2
	
	%define addr_%[%3] seg_%[%3], off_%[%3]
%endmacro

; callFromOverlay procName
%macro callFromOverlay 1
	callWithRelocation segmentFromOverlay_%[%1]:off_%[%1]
%endmacro

; callFromLoadModule procName
%macro callFromLoadModule 1
	callWithRelocation segmentFromLoadModule_%[%1]:off_%[%1]
%endmacro

%define offsetInCodeSegment(label) \
		(label - block_relativeStart) + block_startOffset

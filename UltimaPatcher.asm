%macro startPatch 2
	%push patch
	
	%assign patch_targetFileLength %1
	%defstr patch_description %2
	%strlen patch_descriptionLength patch_description
	%assign patch_blockCount 0
%endmacro

%macro startBlockAt 2
	%push block
	
	%assign block_segmentIndex %1
	%assign block_startOffset %2
	%assign block_relativeStart ($ - $$)
	%assign block_relocationCount 0
	
	; a unique non-local label at the start of the block
	;   to enable local labels within the block
	startOfBlock_ %+ block_segmentIndex %+ _ %+ block_startOffset:
%endmacro

%define block_currentRelativePosition (($ - $$) - block_relativeStart)

%define block_currentOffset (block_startOffset + block_currentRelativePosition)

; inserts metadata regarding the preceding block of code
; (absolute start address and relocation sites)
%macro endBlock 0
	%assign %%length block_currentRelativePosition
	%assign %%endOffset block_currentOffset
	
	%if %%endOffset > 0x10000
		%error block runs beyond offset 0xFFFF
	%endif
	
	dd %%length
	
	%rep block_relocationCount
		dd %$relocationBase + %$relocationOffset - block_relativeStart
		%pop blockRelocationContext
	%endrep
	
	dd block_relocationCount
	
	dd block_startOffset
	dd block_segmentIndex
	
	%assign patch_blockCount patch_blockCount + 1
	
	%assign lastBlock_endOffset %%endOffset
	
	%pop block
%endmacro

%macro endBlockOfLength 1
	%assign %%expectedLength %1
	%assign %%actualLength block_currentRelativePosition
	
	%if %%actualLength != %%expectedLength
		%error block length: %%actualLength, expected: %%expectedLength
	%endif
	
	endBlock
%endmacro

%macro endBlockWithFillAt 2
	%define %%fillByte %1
	%assign %%expectedEndOffset %2
	
	%assign %%fillLength %%expectedEndOffset - block_currentOffset
	
	%if %%fillLength < 0
		%error block overrun
	%elifenv 'BLOCK_SIZING_HINTS'
		%assign %%length block_currentRelativePosition
		%warning block length: %%length fillLength: %%fillLength
	%endif
	
	times %%fillLength %%fillByte
	
	endBlock
%endmacro

%macro endBlockAt 1
	%assign %%expectedEndOffset %1
	
	endBlockWithFillAt nop, %%expectedEndOffset
%endmacro

%macro endPatch 0
	dd patch_blockCount
	dd patch_targetFileLength
	db patch_description
	dd patch_descriptionLength
	
	%pop patch
%endmacro

; calculates the delta to a location within the same segment \
;	but outside of the local patch block
%define calcJump(targetOffset) ($ + (targetOffset - block_currentOffset))
		
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
	%define segmentFromOverlay_%[%3]    segmentFromOverlay_%[%1]
	%define segmentFromLoadModule_%[%3] segmentFromLoadModule_%[%1]
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

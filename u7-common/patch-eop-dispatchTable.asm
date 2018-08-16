; An array containing the offsets of all eops defined in the eop segment.
; Used by the eop dispatchers to jump into the requested procedure.

[bits 16]

startPatch EXE_LENGTH, %[eopSegmentName]-dispatchTable
	startBlockAt addr_%[eopSegmentName]_dispatchTable
		%assign eopNumber 0
		%rep %[eopSegmentName]_nextEopNumber
			dw off_%[eopSegmentName]_%[eopNumber]
			
			%assign eopNumber eopNumber + 1
		%endrep
	endBlockAt off_%[eopSegmentName]_dispatchTable_end
endPatch

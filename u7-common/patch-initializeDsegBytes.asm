startPatch EXE_LENGTH, initializeDsegBytes
	; truncate the unused string so that, if someone unexpectedly tries to use
	;     it, they won't run over our repurposed bytes
	startBlockAt seg_dseg, dseg_repurposedString
		db 0
	endBlock
	
	startBlockAt seg_dseg, dseg_pn_dragArea
		dw 0
	endBlock
	
	startBlockAt seg_dseg, dseg_pn_dropArea
		dw 0
	endBlock
	
	startBlockAt seg_dseg, dseg_conversationKeys_mouseEvent
		db 0 ; press
		db 1 ; button
		dw 0 ; xX
		dw 0 ; y
		db 0 ; buttonBits
	endBlockOfLength 7
	
	startBlockAt seg_dseg, dseg_pf_castByKeyData
		dd 0
	endBlock
	
	startBlockAt seg_dseg, dseg_pf_targetKeysData
		dd 0
	endBlock
	
	startBlockAt seg_dseg, dseg_isSelectingFromEopTarget
		db 0
	endBlock
	
	startBlockAt seg_dseg, dseg_keepMoving_direction
		db -5
	endBlock
	
	startBlockAt seg_dseg, dseg_keepMoving_speed
		db 0
	endBlock
	
	startBlockAt seg_dseg, dseg_divideByZeroTemplate
		db '%s %04x:%04x %04x', 0
	endBlockOfLength 18
	
	startBlockAt seg_dseg, dseg_areBarksSuppressed
		db 0
	endBlock
	
	startBlockAt seg_dseg, dseg_flagNumberPromptString
		db 'Flag number?', 0
	endBlockOfLength 13
endPatch

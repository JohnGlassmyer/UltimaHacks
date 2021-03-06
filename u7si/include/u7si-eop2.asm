; =============================================================================
; Ultima VII: Serpent Isle Hacks -- expanded overlay 2
; -----------------------------------------------------------------------------

; a second eop segment for offloading large, less frequently called procedures
;     from the primary eop segment.

%assign eop2_nextEopNumber 0
%assign eop2_nextEopStart EOP2_NEW_CODE_START

eopProc eop2, 0x005, entry1
eopProc eop2, 0x005, entry2
eopProc eop2, 0x005, entry3

eopProc eop2, 0x040, varArgsDispatcher
eopProc eop2, 0x020, dispatchTable

eopProc eop2, 0x9A0, displayControls
eopProc eop2, 0x1D0, printDarkPathDestinations
eopProc eop2, 0x270, produceItemLabelText
eopProc eop2, 0x800, targetKeys

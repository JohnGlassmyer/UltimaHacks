; =============================================================================
; Ultima Underworld II Hacks -- expanded overlay
; -----------------------------------------------------------------------------

; assuming that the expanded overlay has been moved to the end of the file
off_eop_segmentZero                     EQU ORIGINAL_EXE_LENGTH

%assign nextEopNumber 0
; eopProc procName, length
%macro eopProc 2
    %assign eopNumber nextEopNumber
    
    %assign eopStart nextEopStart
    %assign eopEnd eopStart + %2
    
    off_eop_%[%1]     EQU eopStart
    off_eop_%[%1]_end EQU eopEnd
    
    off_eop_%[eopNumber]     EQU eopStart
    off_eop_%[eopNumber]_end EQU eopEnd
    
    eopNumber_%[%1] EQU eopNumber
    
    %assign nextEopStart eopEnd
    %assign nextEopNumber nextEopNumber + 1
%endmacro

%assign nextEopStart off_eop_segmentZero + ORIGINAL_EOP_LENGTH

eopProc varArgsDispatcher,              0x100 ; eop:0E2F
eopProc byteArgDispatcher,              0x100 ; eop:0F2F
eopProc byCallSiteDispatcher,           0x100 ; eop:102F

eopProc dispatchTable,                  0x100 ; (a table, not a procedure)

eopProc mouseLookOrMoveCursor,          0x100 ; TODO
eopProc toggleMouseLook,                0x100 ; TODO
eopProc interactAtCursor,               0x100 ; TODO
eopProc setInterfaceContext,            0x100 ; TODO
eopProc setMouseLookState,              0x100 ; TODO
eopProc attack,                         0x100 ; TODO
eopProc divideByZeroHandler,            0x100 ; TODO
eopProc enqueueDrawBlock,               0x100 ; TODO
eopProc enqueueGridCoords,              0x100 ; TODO
eopProc setupPerspectiveAndEnqueueDraw, 0x240 ; TODO
eopProc runeKey,                        0x100 ; TODO
eopProc tryKeyAndMouseBindings,         0x100 ; TODO
eopProc displayMap,                     0x100 ; TODO
eopProc mapControl,                     0x100 ; TODO
eopProc moreBindings,                   0x120 ; TODO
eopProc closeContainer,                 0x100 ; TODO
eopProc trainSkill,                     0x130 ; TODO
eopProc flipToPanel,                    0x100 ; TODO
eopProc slidePanel,                     0x100 ; TODO
eopProc clickFlasks,                    0x100 ; TODO

%define varArgsEopArg(eopName, argCount) \
        ((eopNumber_ %+ eopName) << 8) + argCount
        
%define byteArgEopArg(eopName, byteArg) \
        ((eopNumber_ %+ eopName) << 8) + byteArg
        
%define offsetInEopSegment(label) \
        (label - $$ - startRelative) + startAbsolute - off_eop_segmentZero

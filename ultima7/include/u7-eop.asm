%assign nextEopNumber 0
; eopProc length, procName
%macro eopProc 2
    %assign eopNumber nextEopNumber
    
    %assign eopStart nextEopStart
    %assign eopEnd eopStart + %1
    
    off_eop_%[%2]     EQU eopStart
    off_eop_%[%2]_end EQU eopEnd
    
    off_eop_%[eopNumber]     EQU eopStart
    off_eop_%[eopNumber]_end EQU eopEnd
    
    eopNumber_%[%2] EQU eopNumber
    
    %assign nextEopStart eopEnd
    %assign nextEopNumber nextEopNumber + 1
%endmacro

%assign nextEopStart EOP_ORIGINAL_CODE_LENGTH

eopProc 0x030, dispatcher

eopProc 0x040, barkOverItemInWorld
eopProc 0x500, castByKey
eopProc 0x060, determineItemBulk
eopProc 0x0A0, displayMemoryStats
eopProc 0x0F0, displayVersion
eopProc 0x040, doesItemHaveQuantity
eopProc 0x020, doSaveDialog
eopProc 0x060, findPartyItem
eopProc 0x080, findAllPartyItems
eopProc 0x020, getKeyboardAltStatus
eopProc 0x060, getPartyMemberIbo
eopProc 0x240, keyActions
eopProc 0x160, numberSelect
eopProc 0x0E0, placeItemOrReportNoCanDo
eopProc 0x080, popupScrollWithText
eopProc 0x0B0, processSliderInput
eopProc 0x300, produceItemLabelText
eopProc 0x030, promptToExit
eopProc 0x0A0, selectAndUseKey
eopProc 0x050, target
eopProc 0x0A0, toggleAudio
eopProc 0x080, toggleCheats
eopProc 0x040, toggleCombat
eopProc 0x050, toggleMouseHand
eopProc 0x060, usePartyItem

; callEopFromLoadModule numberOfArguments, procName
%macro callEopFromLoadModule 2
    push word %1
    push word off_eop_%[%2]
    callFromLoadModule eopDispatcher
    add sp, 4
%endmacro

; callEopFromOverlay numberOfArguments, procName
%macro callEopFromOverlay 2
    push word %1
    push word off_eop_%[%2]
    callFromOverlay eopDispatcher
    add sp, 4
%endmacro

%define offsetInEopSegment(label) \
        (label - block_relativeStart) + block_startOffset

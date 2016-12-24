off_eop_segmentZero                     EQU 0xA7710

off_eop_addedProc                       EQU off_eop_segmentZero + 0x0CD0

%assign nextEopStart off_eop_addedProc
; eopProc procName, length
%macro eopProc 2
    off_eop_%[%1]     EQU nextEopStart
    off_eop_%[%1]_end EQU nextEopStart + %2
    
    %assign nextEopStart nextEopStart + %2
%endmacro

eopProc dispatcher,                     0x030

eopProc barkOverItemInWorld,            0x040
eopProc castByKey,                      0x500
eopProc determineItemBulk,              0x060
eopProc displayMemoryStats,             0x0A0
eopProc displayVersion,                 0x0F0
eopProc doesItemHaveQuantity,           0x040
eopProc doSaveDialog,                   0x020
eopProc findPartyItem,                  0x060
eopProc findAllPartyItems,              0x080
eopProc getKeyboardAltStatus,           0x020
eopProc getPartyMemberIbo,              0x060
eopProc keyActions,                     0x240
eopProc numberSelect,                   0x160
eopProc placeItemOrReportNoCanDo,       0x0E0
eopProc popupScrollWithText,            0x080
eopProc processSliderInput,             0x0B0
eopProc produceItemLabelText,           0x300
eopProc promptToExit,                   0x030
eopProc selectAndUseKey,                0x0A0
eopProc target,                         0x050
eopProc toggleAudio,                    0x0A0
eopProc toggleCheats,                   0x080
eopProc toggleCombat,                   0x040
eopProc toggleMouseHand,                0x050
eopProc usePartyItem,                   0x060

; callEopFromLoadModule numberOfArguments, procName
%macro callEopFromLoadModule 2
    push word %1
    push word off_eop_%[%2] - off_eop_segmentZero
    callWithRelocation l_eopDispatcher
    add sp, 4
%endmacro

; callEopFromOverlay numberOfArguments, procName
%macro callEopFromOverlay 2
    push word %1
    push word off_eop_%[%2] - off_eop_segmentZero
    callWithRelocation o_eopDispatcher
    add sp, 4
%endmacro

%define offsetInEopSegment(label) \
        (label - $$ - startRelative) + startAbsolute - off_eop_segmentZero

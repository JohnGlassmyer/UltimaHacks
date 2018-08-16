; =============================================================================
; Ultima VII: The Black Gate Hacks -- expanded overlay 1
; -----------------------------------------------------------------------------

%assign eop1_nextEopNumber 0
%assign eop1_nextEopStart EOP1_NEW_CODE_START

eopProc eop1, 0x005, entry1
eopProc eop1, 0x005, entry2
eopProc eop1, 0x005, entry3

eopProc eop1, 0x040, varArgsDispatcher
eopProc eop1, 0x050, dispatchTable

eopProc eop1, 0x040, barkOverItemInWorld
eopProc eop1, 0x040, canItemAcceptItems
eopProc eop1, 0x560, castByKey
eopProc eop1, 0x070, cycleInventoryDialogs
eopProc eop1, 0x060, determineItemBulk
eopProc eop1, 0x0E0, displayMemoryStats
eopProc eop1, 0x110, displayVersion
eopProc eop1, 0x040, doesItemHaveQuantity
eopProc eop1, 0x020, doSaveDialog
eopProc eop1, 0x030, drawDarkenedWorld
eopProc eop1, 0x060, dropToPresetDestination
eopProc eop1, 0x1E0, ensureDragAndDropAreasInitialized
eopProc eop1, 0x020, feed
eopProc eop1, 0x080, findAllPartyItems
eopProc eop1, 0x050, findPartyItem
eopProc eop1, 0x030, getItemZ
eopProc eop1, 0x010, getKeyboardShiftBits
eopProc eop1, 0x070, getPartyMemberIbo
eopProc eop1, 0x040, getSpellRunes
eopProc eop1, 0x100, keepMoving
eopProc eop1, 0x280, keyActions
eopProc eop1, 0x190, openableItemForKey
eopProc eop1, 0x030, displayText
eopProc eop1, 0x080, printText
eopProc eop1, 0x0B0, processSliderInput
eopProc eop1, 0x030, promptToExit
eopProc eop1, 0x090, selectAndUseKey
eopProc eop1, 0x120, shapeBark
eopProc eop1, 0x0C0, shapeBarkForContent
eopProc eop1, 0x050, target
eopProc eop1, 0x0A0, toggleAudio
eopProc eop1, 0x080, toggleCheats
eopProc eop1, 0x030, toggleCombat
eopProc eop1, 0x040, toggleMouseHand
eopProc eop1, 0x060, usePartyItem

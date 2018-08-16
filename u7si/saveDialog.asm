%include "include/u7si-all-includes.asm"

defineAddress 325, 0x0A87, SaveSlot_processInput_loopForMouseUp

defineAddress 333, 0x0080, SaveDialog_appendChar_testSpecialKey
defineAddress 333, 0x009A, SaveDialog_appendChar_maybeTruncate
defineAddress 333, 0x00B8, SaveDialog_appendChar_afterTruncate
defineAddress 333, 0x00C4, SaveDialog_appendChar_append
defineAddress 333, 0x00D7, SaveDialog_appendChar_endProc

defineAddress 333, 0x1084, keyOrMouse
defineAddress 333, 0x1096, handleKeyWithActiveSlot

defineAddress 333, 0x10CE, handleKeyAfterBlinking
defineAddress 333, 0x11C0, determineSlotTextWidth

defineAddress 333, 0x1268, textNoLongerUnedited
defineAddress 333, 0x126D, enableOrDisableSaveButton

defineAddress 333, 0x1318, handleKey
defineAddress 333, 0x13E0, handleMouseButton1

defineAddress 333, 0x1402, triggerClose
defineAddress 333, 0x14E3, triggerSave
defineAddress 333, 0x150F, triggerLoad

defineAddress 333, 0x1556, saveSlotLoopStart

defineAddress 333, 0x1733, SaveDialog_processInput_end

%include "../u7-common/patch-saveDialog.asm"

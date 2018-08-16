%include "include/u7bg-all-includes.asm"

defineAddress 339, 0x09C1, SaveSlot_processInput_loopForMouseUp

defineAddress 344, 0x0080, SaveDialog_appendChar_testSpecialKey
defineAddress 344, 0x009A, SaveDialog_appendChar_maybeTruncate
defineAddress 344, 0x00B8, SaveDialog_appendChar_afterTruncate
defineAddress 344, 0x00C4, SaveDialog_appendChar_append
defineAddress 344, 0x00D7, SaveDialog_appendChar_endProc

defineAddress 344, 0x1060, keyOrMouse
defineAddress 344, 0x1072, handleKeyWithActiveSlot

defineAddress 344, 0x10AA, handleKeyAfterBlinking
defineAddress 344, 0x119C, determineSlotTextWidth

defineAddress 344, 0x1244, textNoLongerUnedited
defineAddress 344, 0x1249, enableOrDisableSaveButton

defineAddress 344, 0x12F4, handleKey
defineAddress 344, 0x13BC, handleMouseButton1

defineAddress 344, 0x13DE, triggerClose
defineAddress 344, 0x14BF, triggerSave
defineAddress 344, 0x14EB, triggerLoad

defineAddress 344, 0x1532, saveSlotLoopStart

defineAddress 344, 0x170F, SaveDialog_processInput_end

%include "../u7-common/patch-saveDialog.asm"

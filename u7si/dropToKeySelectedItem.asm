%include "include/u7si-all-includes.asm"

defineAddress 327, 0x08D7, dragItem_afterDragging
defineAddress 327, 0x0926, dragItem_afterDragging_end
defineAddress 327, 0x0946, dragItem_putItemBack
defineAddress 327, 0x098C, dragItem_determineWhereToPut
defineAddress 327, 0x09C6, dragItem_endProc

defineAddress 331, 0x01D5, loopDuringDrag_beforeLoop
defineAddress 331, 0x0267, loopDuringDrag_loopEnd

%include "../u7-common/patch-dropToKeySelectedItem.asm"

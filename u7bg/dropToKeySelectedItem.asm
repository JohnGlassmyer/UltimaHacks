%include "include/u7bg-all-includes.asm"

defineAddress 340, 0x0D6A, dragItem_afterDragging
defineAddress 340, 0x0DB9, dragItem_afterDragging_end
defineAddress 340, 0x0DD9, dragItem_putItemBack
defineAddress 340, 0x0E1F, dragItem_determineWhereToPut
defineAddress 340, 0x0E59, dragItem_endProc

defineAddress 343, 0x01D5, loopDuringDrag_beforeLoop
defineAddress 343, 0x0267, loopDuringDrag_loopEnd

%include "../u7-common/patch-dropToKeySelectedItem.asm"

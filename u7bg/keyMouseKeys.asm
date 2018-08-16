%include "include/u7bg-all-includes.asm"

defineAddress 56, 0x03FF, valueForKey
defineAddress 56, 0x04D8, valueForKey_end
defineAddress 56, 0x067B, mouseActionInAx
defineAddress 56, 0x0682, endProc

%include "../u7-common/patch-keyMouseKeys.asm"

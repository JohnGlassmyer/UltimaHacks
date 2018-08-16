%include "include/u7si-all-includes.asm"

defineAddress 119, 0x0410, valueForKey
defineAddress 119, 0x04E9, valueForKey_end
defineAddress 119, 0x068C, mouseActionInAx
defineAddress 119, 0x0693, endProc

%include "../u7-common/patch-keyMouseKeys.asm"

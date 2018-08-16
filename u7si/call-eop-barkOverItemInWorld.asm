%include "include/u7si-all-includes.asm"

defineAddress 310, 0x005A, usecodeCallSite
defineAddress 310, 0x0087, usecodeCallSite_end

%include "../u7-common/patch-call-eop-barkOverItemInWorld.asm"

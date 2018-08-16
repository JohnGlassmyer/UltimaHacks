%include "include/u7bg-all-includes.asm"

defineAddress 330, 0x005A, usecodeCallSite
defineAddress 330, 0x0087, usecodeCallSite_end

%include "../u7-common/patch-call-eop-barkOverItemInWorld.asm"

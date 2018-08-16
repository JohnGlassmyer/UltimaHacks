%include "include/u7bg-all-includes.asm"

defineAddress 169, 0x0006, enter
defineAddress 169, 0x0071, setRepCounts
defineAddress 169, 0x007F, setRepCounts_end
defineAddress 169, 0x00C3, stosDwordsAndBytes
defineAddress 169, 0x00CE, stosDwordsAndBytes_end

%include "../u7-common/patch-dontMessWithFsAndGs.asm"

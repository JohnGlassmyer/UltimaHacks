%include "include/u7si-all-includes.asm"

defineAddress 168, 0x0000, enter
defineAddress 168, 0x006B, setRepCounts
defineAddress 168, 0x0079, setRepCounts_end
defineAddress 168, 0x00BD, stosDwordsAndBytes
defineAddress 168, 0x00C8, stosDwordsAndBytes_end

%include "../u7-common/patch-dontMessWithFsAndGs.asm"

%include "include/u7si-all-includes.asm"

defineAddress 323, 0x022E, beginConversation_drawWorld
defineAddress 323, 0x0238, beginConversation_drawWorld_end

%include "../u7-common/patch-drawDarkenedWorldForConversation.asm"

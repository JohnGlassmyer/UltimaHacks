%include "include/u7bg-all-includes.asm"

defineAddress 337, 0x0222, beginConversation_drawWorld
defineAddress 337, 0x022C, beginConversation_drawWorld_end

%include "../u7-common/patch-drawDarkenedWorldForConversation.asm"

%include "include/u7bg-all-includes.asm"

defineAddress 234, 0x000F, havePlayerSelect_setUnusedField
defineAddress 234, 0x0039, havePlayerSelect_checkingForClick
defineAddress 234, 0x007B, havePlayerSelect_haveMouseXInDi
defineAddress 234, 0x00F9, havePlayerSelect_loopStart
defineAddress 234, 0x0105, havePlayerSelect_loopEndWithSelection

%include "../u7-common/patch-selectByKey.asm"

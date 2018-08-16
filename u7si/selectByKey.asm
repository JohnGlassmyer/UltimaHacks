%include "include/u7si-all-includes.asm"

defineAddress 223, 0x000F, havePlayerSelect_setUnusedField
defineAddress 223, 0x0039, havePlayerSelect_checkingForClick
defineAddress 223, 0x007B, havePlayerSelect_haveMouseXInDi
defineAddress 223, 0x00F9, havePlayerSelect_loopStart
defineAddress 223, 0x0105, havePlayerSelect_loopEndWithSelection

%include "../u7-common/patch-selectByKey.asm"

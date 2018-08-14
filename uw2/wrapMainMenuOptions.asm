%include "../UltimaPatcher.asm"
%include "include/uw2.asm"

defineAddress 147, 0x08B6, haveSelectedOption
defineAddress 147, 0x08C7, nextInput

%include "../uw1/wrapMainMenuOptions.asm"

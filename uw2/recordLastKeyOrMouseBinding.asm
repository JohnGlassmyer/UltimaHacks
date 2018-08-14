%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"
%include "include/additionalCharacterCodes.asm"

defineAddress 11, 0x03B9, redundantMouseHandlerAddressingStart
defineAddress 11, 0x03C6, redundantMouseHandlerAddressingEnd
defineAddress 11, 0x0447, redundantKeyHandlerAddressingStart
defineAddress 11, 0x0454, redundantKeyHandlerAddressingEnd

%include "../uw1/recordLastKeyOrMouseBinding.asm"

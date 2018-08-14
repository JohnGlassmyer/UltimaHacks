%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"
%include "include/additionalCharacterCodes.asm"
%include "include/bindKeyOrMouse.asm"

defineAddress 143, 0x01AD, bindsBegin
defineAddress 143, 0x071F, bindsEnd

%include "../uw1/keyAndMouseBindings.asm"

%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/additionalCharacterCodes.asm"

defineAddress 71, 0x0010, asciiForScancodeTable

%include "../uw1/addCharacterCodes.asm"

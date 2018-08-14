%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

defineAddress 16, 0x0DD5, tabJump
defineAddress 16, 0x0E15, shiftTabJump

%include "../uw1/eop-setMouseLookState.asm"

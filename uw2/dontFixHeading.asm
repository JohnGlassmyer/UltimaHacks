%include "../UltimaPatcher.asm"
%include "include/uw2.asm"

defineAddress 9, 0x0E91, maybeJumpOverAdjustment
defineAddress 9, 0x0EDF, afterAdjustment

%include "../uw1/dontFixHeading.asm"

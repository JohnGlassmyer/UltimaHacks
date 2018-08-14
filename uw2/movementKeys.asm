%include "../UltimaPatcher.asm"
%include "include/uw2.asm"

defineAddress 37, 0x0202, considerShiftStates
defineAddress 37, 0x024A, beginMovementKeyLoop
defineAddress 37, 0x026A, interpretScancode
defineAddress 37, 0x0344, nextMovementKey
defineAddress 37, 0x034D, endOfProc

%include "../uw1/movementKeys.asm"

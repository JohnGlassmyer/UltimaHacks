%include "include/u7bg-all-includes.asm"

defineAddress   6, 0x02A0, divideByZeroHandler
defineAddress   6, 0x02C5, divideByZeroHandler_end
defineAddress 236, 0x004D, exitWithErrorPrintf

%include "../u7-common/patch-printAddressOnDivideByZero.asm"

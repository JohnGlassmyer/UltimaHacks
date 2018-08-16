%include "include/u7si-all-includes.asm"

defineAddress   5, 0x029C, divideByZeroHandler
defineAddress   5, 0x02C1, divideByZeroHandler_end
defineAddress 224, 0x004D, exitWithErrorPrintf

%include "../u7-common/patch-printAddressOnDivideByZero.asm"

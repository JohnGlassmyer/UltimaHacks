%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

defineAddress 112, 0x02DF, setInterfaceMode_proc
defineAddress 112, 0x031A, setInterfaceMode_endp

%include "../uw1/call-eop-setInterfaceMode.asm"

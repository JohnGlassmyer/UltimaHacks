%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

defineAddress 13, 0x000B, tryHandlersInMainLoop

%include "../uw1/call-eop-tryKeyAndMouseBindings.asm"

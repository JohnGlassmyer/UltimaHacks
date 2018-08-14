%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

%assign off_drawQueueLimit     0xC77E

%include "../uw1/eop-enqueueDrawBlock.asm"

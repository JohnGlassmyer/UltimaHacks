%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

defineAddress 34, 0x0300, beforeSetupA  
defineAddress 34, 0x030E, afterEnqueueA  
defineAddress 34, 0x036A, beforeSetupB  
defineAddress 34, 0x037C, afterEnqueueB  

%include "../uw1/call-eop-setupPerspectiveAndEnqueueDraw.asm"

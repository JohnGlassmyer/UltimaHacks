%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

defineAddress 39, 0x0A30, animateSlidingPanel

%include "../uw1/call-eop-slidePanel.asm"

%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

defineAddress 16, 0x0A9B, moveCursor
defineAddress 16, 0x0AE3, doneMovingCursor

%assign var_mouseYDelta -0x0C
%define pushYDelta push word [bp+var_mouseYDelta]

%include "../uw1/call-eop-mouseLookOrMoveCursor.asm"

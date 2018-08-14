%include "../UltimaPatcher.asm"
%include "include/uw2.asm"

defineAddress 4, 0x3FD7, adjustSpriteVerticalPosition
defineAddress 4, 0x3FF6, adjustSpriteHeight

%include "../uw1/dontShrinkSprites.asm"

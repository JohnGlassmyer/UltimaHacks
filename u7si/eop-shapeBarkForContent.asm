%include "include/u7si-all-includes.asm"

%assign ItemType_LOCKED_CHEST 522

%macro isAxLockedItemType 0
	cmp ax, ItemType_LOCKED_CHEST
	jz %%isLocked
	
	xor ax, ax
	jmp %%end
	
	%%isLocked:
	mov ax, 1
	
	%%end:
%endmacro

%include "../u7-common/patch-eop-shapeBarkForContent.asm"

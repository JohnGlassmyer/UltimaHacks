%include "include/u7si-all-includes.asm"

%macro copyAudioStateStringToVar 2
	test %1, %1
	jz getDisabled
	mov ax, 247
	jmp haveId
	getDisabled:
	mov ax, 248
	
	haveId:
	push ax
	push word 3
	callFromOverlay getDisplayText
	pop cx
	pop cx
	
	push ds
	push ax
	push ss
	lea ax, %2
	push ax
	callFromOverlay strcpy_far
	add sp, 8
%endmacro

%include "../u7-common/patch-eop-toggleAudio.asm"

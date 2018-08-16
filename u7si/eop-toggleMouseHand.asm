%include "include/u7si-all-includes.asm"

%macro getRightHandedStringPnInAx 0
	push word 171
	push word 3
	callFromOverlay getDisplayText
	pop cx
	pop cx
%endmacro

%macro getLeftHandedStringPnInAx 0
	push word 172
	push word 3
	callFromOverlay getDisplayText
	pop cx
	pop cx
%endmacro

%include "../u7-common/patch-eop-toggleMouseHand.asm"
	

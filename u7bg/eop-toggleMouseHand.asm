%include "include/u7bg-all-includes.asm"

%macro getRightHandedStringPnInAx 0
	mov ax, dseg_rightHandedMouseString
%endmacro

%macro getLeftHandedStringPnInAx 0
	mov ax, dseg_leftHandedMouseString
%endmacro

%include "../u7-common/patch-eop-toggleMouseHand.asm"

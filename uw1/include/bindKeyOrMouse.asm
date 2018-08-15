%assign dKey_SIZE (5 * 2)

; dKey interfaceModeBitmask, keyCode, procName, arg
%macro dKey 4
	dwWithRelocation segmentFromOverlay_%[%3]
	dw off_%[%3]
	dw %1
	dw %4
	dw %2
%endmacro

; bindDKeyAt segmentRegister:offsetRegister
%macro bindDKeyAt 1
	push word [%1+0]
	push word [%1+2]
	push word [%1+4]
	push word [%1+6]
	push word [%1+8]
	callFromOverlay bindKey
	add sp, 10
%endmacro

%assign dMouse_SIZE (8 * 2)

; dMouse interfaceModeBitmask, minX, minY, maxX, maxY, procName, arg
; NB mouse Y is measured from the bottom of the screen up
%macro dMouse 7
	dwWithRelocation segmentFromOverlay_%[%6]
	dw off_%[%6]
	dw %1
	dw %7
	dw %5
	dw %4
	dw %3
	dw %2
%endmacro

; bindDMouseAt segmentRegister:offsetRegister
%macro bindDMouseAt 1
	push word [%1+0x0]
	push word [%1+0x2]
	push word [%1+0x4]
	push word [%1+0x6]
	push word [%1+0x8]
	push word [%1+0xA]
	push word [%1+0xC]
	push word [%1+0xE]
	callFromOverlay bindMouse
	add sp, 16
%endmacro

%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

; setSoundProbability
;   parameters: dividend, divisor,
;		dividend segment, dividend offset,
;		divisor segment, divisor offset
;   probability of sound being played ~= dividend / divisor
%macro setSoundProbability 6
	startBlockAt %3, %4
		dw %1
	endBlock
	
	startBlockAt %5, %6
		dw %2
	endBlock
%endmacro

startPatch EXE_LENGTH, \
		adjust the volume and frequency of ambient-sound playback

	;---------------------------
	; sounds of on-screen items 
	;---------------------------
	
	; ambient item sound max volume
	; originally 127
	startBlockAt 47, 0x01A8
		db 90
	endBlock
	
	; surf
	; originally 1/100
	setSoundProbability 3, 1000, 47, 0x04BB, 47, 0x04B0
	
	; magic sword, magebane, death scythe, hoe of destruction
	; originally 10/100
	setSoundProbability 0, 100, 47, 0x0691, 47, 0x0686
	
	; firepit, campfire, fire sword, firedoom staff, fire wand, etc.
	; originally 60/100
	setSoundProbability 0, 100, 47, 0x0491, 47, 0x0486
	
	;---------------------
	; night-time chirping
	;---------------------
	
	; originally 20/100
	setSoundProbability 8, 100, 47, 0x07C7, 47, 0x07BC
	
	startBlockAt 47, 0x07DD
		mov ax, 60 ; volume range (originally 100)
		push ax
		callFromLoadModule generateRandomIntegerInRange
		inc sp
		inc sp
		add ax, 10 ; volume base (originally 25)
	endBlockAt 0x07EB
endPatch

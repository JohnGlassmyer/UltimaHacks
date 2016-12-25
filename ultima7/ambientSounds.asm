%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

; setSoundProbability
;   parameters: dividend, divisor, dividend word in file, divisor word in file
;   probability of sound being played ~= dividend / divisor
%macro setSoundProbability 4
    startBlockAt %3
        dw %1
    endBlock
    
    startBlockAt %4
        dw %2
    endBlock
%endmacro

startPatch EXPANDED_OVERLAY_U7_EXE_LENGTH, \
        adjust the volume and frequency of ambient-sound playback

    ;---------------------------
    ; sounds of on-screen items 
    ;---------------------------
    
    ; ambient item sound max volume
    ; originally 127
    startBlockAt 0x1F6A8
        db 90
    endBlock
    
    ; surf
    ; originally 1/100
    setSoundProbability 3, 1000, 0x1F9BB, 0x1F9B0
    
    ; magic sword, magebane, death scythe, hoe of destruction
    ; originally 10/100
    setSoundProbability 0, 100, 0x1FB91, 0x1FB86
    
    ; firepit, campfire, fire sword, firedoom staff, fire wand, etc.
    ; originally 60/100
    setSoundProbability 0, 100, 0x1F991, 0x1F986
    
    ;---------------------
    ; night-time chirping
    ;---------------------
    
    ; originally 20/100
    setSoundProbability 8, 100, 0x1FCC7, 0x1FCBC
    
    startBlockAt 0x1FCDD
        mov ax, 60 ; volume range (originally 100)
        push ax
        callWithRelocation l_generateRandomIntegerInRange
        inc sp
        inc sp
        add ax, 10 ; volume base (originally 25)
    endBlockAt 0x1FCEB
endPatch

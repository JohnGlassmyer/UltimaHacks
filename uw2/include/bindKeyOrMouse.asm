; bindKey codeSeg, codeOff, context, arg, keyCode
%macro bindKey 5
    pushWithRelocation %1 ; codeSeg
    push %2 ; codeOff
    push %3 ; context
    push %4 ; arg
    push %5 ; keyCode
    callWithRelocation o_bindKey
    add sp, 10
%endmacro

; bindMouse codeSeg, codeOff, context, arg, minX, minY, maxX, maxY
; NB mouse Y is measured from the bottom of the screen up
%macro bindMouse 8
    pushWithRelocation %1 ; codeSeg
    push %2 ; codeOff
    push %3 ; context
    push %4 ; arg
    push %8 ; maxY
    push %7 ; maxX
    push %6 ; minY
    push %5 ; minX
    callWithRelocation o_bindMouse
    add sp, 16
%endmacro

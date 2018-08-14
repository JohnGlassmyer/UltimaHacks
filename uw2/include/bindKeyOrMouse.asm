; bindKey mode, keyCode, procName, arg
%macro bindKey 4
	; using "from overlay" segment because binds are executed from an overlay
    pushWithRelocation segmentFromOverlay_%[%3] ; codeSeg
    push off_%[%3] ; codeOff
    push %1 ; mode
    push %4 ; arg
    push %2 ; keyCode
    callFromOverlay bindKey
    add sp, 10
%endmacro

; bindMouse mode, minX, minY, maxX, maxY, procName, arg
; NB mouse Y is measured from the bottom of the screen up
%macro bindMouse 7
    pushWithRelocation segmentFromOverlay_%[%6] ; codeSeg
    push off_%[%6] ; codeOff
    push %1 ; mode
    push %7 ; arg
    push %5 ; maxY
    push %4 ; maxX
    push %3 ; minY
    push %2 ; minX
    callFromOverlay bindMouse
    add sp, 16
%endmacro

; these macros provides ways to safely copy bytes out of an overlay.
;
; (far-calling a function like fmemcpy to copy bytes from an overlay is not
;   safe; apparently the overlay manager sometimes temporarily unloads the
;   overlay during its far call; this could result in random bytes being copied
;   instead of the desired data from the overlay.)

%macro fmemcpy 5
	%define %%destSegment %1
	%define %%destOffset  %2
	%define %%srcSegment  %3
	%define %%srcOffset   %4
	%define %%length      %5
	
	%ifnidn %%dsegSegment, es
		push es
		push %%destSegment
		pop es
	%endif
	push di
	mov di, %%destOffset
	%ifnidn %%srcSegment, ds
		push ds
		push %%srcSegment
		pop ds
	%endif
	push si
	mov si, %%srcOffset
	%ifnidn %%length, cx
		; don't bother to preserve cx
		mov cx, %%length
	%endif
	
	shr cx, 1
	rep movsw
	adc cx, cx
	rep movsb
	
	pop si
	%ifnidn %%srcSegment, ds
		pop ds
	%endif
	pop di
	%ifnidn %%dsegSegment, es
		pop es
	%endif
%endmacro

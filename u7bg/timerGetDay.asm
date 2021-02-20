; Original U7BG has a bug, an inconsistency in timer code. Usecode intrinsic
;     function 101, intending to calculate the number of hours elapsed since
;     a given timer was set, calls one timer function that returns the hour of
;     the day and another that returns a day number. However, the latter
;     function returns not an absolute day number but rather day-of-the-week
;     (day mod 7). As a result, the number of elapsed hours returned to the
;     calling Usecode script may be inaccurate if the timer in question was
;     set prior to the start of the current in-game week. In particular, this
;     can break Jaana's 5-hour healing cooldown.
; This patch fixes that bug by skipping the mod-7 division in the get-day timer
;     function so that it simply returns the absolute day number. The function
;     is not called by anything other than that one Usecode intrinsic, so there
;     should not be any harmful side-effects.
; (In original U7SI, the get-day timer function returns the absolute day
;     number, not day-of-the-week, so it has no such bug.)

%include "include/u7bg-all-includes.asm"

defineAddress 22, 0x00AF, GameTimer_getDay_mod7
defineAddress 22, 0x00B8, GameTimer_getDay_mod7_end

[bits 16]

startPatch EXE_LENGTH, timerGetDay
	startBlockAt addr_GameTimer_getDay_mod7
		times 9 nop
	endBlockAt off_GameTimer_getDay_mod7_end
endPatch

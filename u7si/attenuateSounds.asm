%include "include/u7si-all-includes.asm"

defineAddress seg_dseg, 0x532E, rolandVolumes
defineAddress seg_dseg, 0x53B5, adlibVolumes

startPatch EXE_LENGTH, attenuateSounds
	%macro setVolume 3
		%assign %%soundNumber  %1
		%assign %%rolandVolume %2
		%assign %%adlibVolume  %3
		
		%assign %%off_rolandVolume off_rolandVolumes + %%soundNumber
		startBlockAt seg_dseg, %%off_rolandVolume
			db %%rolandVolume
		endBlockOfLength 1
		
		%assign %%off_adlibVolume off_adlibVolumes + %%soundNumber
		startBlockAt seg_dseg, %%off_adlibVolume
			db %%adlibVolume
		endBlockOfLength 1
	%endmacro
	
	; fire (was 80, 150)
	setVolume  45,  80,  90
	setVolume  46,  80,  90
	setVolume  47,  80,  90
	
	; energy field (was 127, 140)
	setVolume  71,  60, 120
	
	; surf (was 80, 127)
	setVolume 109,  80,  80
	
	; sleep or poison field (was 80, 160)
	setVolume 129,  80, 100
	
endPatch

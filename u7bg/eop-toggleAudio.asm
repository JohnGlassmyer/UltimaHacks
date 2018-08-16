%include "include/u7bg-all-includes.asm"

%macro copyAudioStateStringToVar 2
	jmp afterStrings
	
	audioEnabledString:
		db 'Audio on', 0
		audioEnabledString_end:
		
	audioDisabledString:
		db 'Audio off', 0
		audioDisabledString_end:
		
	afterStrings:
	
	test %1, %1
	jz copyDisabledString
	
	copyEnabledString:
		mov si, offsetInCodeSegment(audioEnabledString)
		mov cx, audioEnabledString_end - audioEnabledString
		jmp copyString
		
	copyDisabledString:
		mov si, offsetInCodeSegment(audioDisabledString)
		mov cx, audioDisabledString_end - audioDisabledString
		
	copyString:
		lea di, %2
		fmemcpy ss, di, cs, si, cx
%endmacro

%include "../u7-common/patch-eop-toggleAudio.asm"

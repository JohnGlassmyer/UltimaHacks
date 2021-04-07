%include "include/u7bg-all-includes.asm"

%macro defineGameSpecificKeyUsableItems 0
	defineKeyUsableItem 'o', 785, 0xFF, 0xFF ; Orb of the Moons
	defineKeyUsableItem 'w', 159, 0xFF, 0xFF ; pocketwatch
%endmacro

%macro defineGameSpecificKeyEops 0
	defineKeyEop 1, 0x17F, off_eop_toggleFrameLimiter
%endmacro

%include "../u7-common/patch-eop-keyActions.asm"

%include "include/u7si-all-includes.asm"

%assign COMBAT_STATUS_KEY 'l'

%macro defineGameSpecificKeyUsableItems 0
	defineKeyUsableItem 'w', 675, 21, 0xFF ; pocketwatch
%endmacro

%macro defineGameSpecificKeyEops 0
	; none
%endmacro

%include "../u7-common/patch-eop-keyActions.asm"

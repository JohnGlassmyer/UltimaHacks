%include "include/u7si-all-includes.asm"

%define ACCEPT_FRIO_RUNE                1

%assign ADD_RUNE_SOUND                  56
%assign REMOVE_RUNE_SOUND               61

%assign NUMBER_OF_SPELLS                72

%macro gameSpecificSpellRunes 0
; First Circle
	db 'imy', 0
	db 'an', 0
	db 'wj', 0
	db 'vaf', 0
	db 'vif', 0
	db 'il', 0
	db 'iw', 0
	db 'opy', 0
; Second Circle
	db 'az', 0
	db 'aj', 0
	db 'ry', 0
	db 'vF', 0
	db 'vl', 0
	db 'm', 0
	db 'van', 0
	db 'us', 0
; Third Circle
	db 'rFm', 0
	db 'ds', 0
	db 'oy', 0
	db 'wjy', 0
	db 'vus', 0
	db 'ap', 0
	db 'iz', 0
	db 'rw', 0
; Fourth Circle
	db 'rp', 0
	db 'axj', 0
	db 'ivl', 0
	db 'ame', 0
	db 'vds', 0
	db 'wq', 0
	db 'row', 0
	db 'ep', 0
; Fifth Circle
	db 'kx', 0
	db 'ag', 0
	db 'vFh', 0
	db 'vm', 0
	db 'sl', 0
	db 'vz', 0
	db 'kwc', 0
	db 'uvg', 0
; Sixth Circle
	db 'axe', 0
	db 'aq', 0
	db 'qw', 0
	db 'iFg', 0
	db 'kFg', 0
	db 'viFg', 0
	db 'ijy', 0
	db 'iox', 0
; Seventh Circle
	db 'isg', 0
	db 'ihgy', 0
	db 'vaz', 0
	db 'ivp', 0
	db 'ihn', 0
	db 'vkm', 0
	db 'age', 0
	db 'og', 0
; Eighth Circle
	db 'iF', 0
	db 'cp', 0
	db 'tvf', 0
	db 'py', 0
	db 'kFx', 0
	db 'kFxe', 0
	db 'kvFg', 0
	db 'ijpy', 0
; Ninth Circle
	db 'vch', 0
	db 'vc', 0
	db 'vsl', 0
	db 'uvjy', 0
	db 'ah', 0
	db 'kvx', 0
	db 'at', 0
	db 'kvag', 0
	
%endmacro

%include "../u7-common/patch-eop-castByKey.asm"

%include "include/u7si-all-includes.asm"

%define barkWithoutDialogs_ibo [bp+8]
defineAddress 210, 0x0267, barkWithoutDialogs_getItemZ
defineAddress 210, 0x028B, barkWithoutDialogs_getItemZ_end
defineAddress 210, 0x0291, barkWithoutDialogs_dontBark

%define barkWithDialogs_ibo [di]
defineAddress 326, 0x1055, barkWithDialogs_getItemZ
defineAddress 326, 0x1070, barkWithDialogs_getItemZ_end
defineAddress 326, 0x10F9, barkWithDialogs_dontBark

%include "../u7-common/patch-suppressBarks.asm"

%include "include/u7bg-all-includes.asm"

%define barkWithoutDialogs_ibo di
defineAddress 212, 0x0258, barkWithoutDialogs_getItemZ
defineAddress 212, 0x0279, barkWithoutDialogs_getItemZ_end
defineAddress 212, 0x027F, barkWithoutDialogs_dontBark

%define barkWithDialogs_ibo [di]
defineAddress 340, 0x1A83, barkWithDialogs_getItemZ
defineAddress 340, 0x1A9E, barkWithDialogs_getItemZ_end
defineAddress 340, 0x1B27, barkWithDialogs_dontBark

%include "../u7-common/patch-suppressBarks.asm"

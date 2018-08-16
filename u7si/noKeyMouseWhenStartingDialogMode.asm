%include "include/u7si-all-includes.asm"

defineAddress 326, 0x01D8, startDialogMode_enableKeyMouse
defineAddress 326, 0x01F4, startDialogMode_enableKeyMouse_end

%include "../u7-common/patch-noKeyMouseWhenStartingDialogMode.asm"

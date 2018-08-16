%include "include/u7bg-all-includes.asm"

defineAddress 340, 0x0289, startDialogMode_enableKeyMouse
defineAddress 340, 0x02A5, startDialogMode_enableKeyMouse_end

%include "../u7-common/patch-noKeyMouseWhenStartingDialogMode.asm"

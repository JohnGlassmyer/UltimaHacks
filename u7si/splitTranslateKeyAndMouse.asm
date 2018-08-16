%include "include/u7si-all-includes.asm"

defineAddress 119, 0x01C1, doKeyMouse
defineAddress 119, 0x01E7, doKeyMouse_end
defineAddress 119, 0x0217, readMouseState
defineAddress 119, 0x0222, haveKeyAndMouseState

%include "../u7-common/patch-splitTranslateKeyAndMouse.asm"

%include "include/u7bg-all-includes.asm"

defineAddress 56, 0x01BA, doKeyMouse
defineAddress 56, 0x01D6, doKeyMouse_end
defineAddress 56, 0x0206, readMouseState
defineAddress 56, 0x0211, haveKeyAndMouseState

%include "../u7-common/patch-splitTranslateKeyAndMouse.asm"

%include "include/u7si-all-includes.asm"

defineAddress 328, 0x01C7, doSlider_switchToKeyMouseMode
defineAddress 328, 0x01CE, doSlider_switchToKeyMouseMode_end
defineAddress 328, 0x01DA, doSlider_haveMouseState
defineAddress 328, 0x0207, doSlider_afterProcessInput

%include "../u7-common/patch-call-eop-processSliderInput.asm"

%include "include/u7bg-all-includes.asm"

defineAddress 340, 0x1C31, doSlider_switchToKeyMouseMode
defineAddress 340, 0x1C38, doSlider_switchToKeyMouseMode_end
defineAddress 340, 0x1C44, doSlider_haveMouseState
defineAddress 340, 0x1C71, doSlider_afterProcessInput

%include "../u7-common/patch-call-eop-processSliderInput.asm"

%include "../UltimaPatcher.asm"
%include "include/uw2.asm"

defineAddress 143, 0x0F87, pushCrystalBallPitchBound
defineAddress 143, 0x0F92, pushPlayerPitchBound

%include "../uw1/pitchBound.asm"

%include "include/u7bg-all-includes.asm"

defineAddress 314, 0x044D, setFlag_promptForFlagNumber
defineAddress 314, 0x046B, setFlag_havePositionedCursor
defineAddress 314, 0x04C4, setFlag_end

defineAddress 314, 0x04D2, inspectFlag_promptForFlagNumber
defineAddress 314, 0x04F0, inspectFlag_havePositionedCursor
defineAddress 314, 0x0517, inspectFlag_end

%include "../u7-common/patch-restoreGameFlagsCheatMenu.asm"

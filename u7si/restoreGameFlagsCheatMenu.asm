%include "include/u7si-all-includes.asm"

defineAddress 298, 0x044D, setFlag_promptForFlagNumber
defineAddress 298, 0x046B, setFlag_havePositionedCursor
defineAddress 298, 0x04C4, setFlag_end

defineAddress 298, 0x04D2, inspectFlag_promptForFlagNumber
defineAddress 298, 0x04F0, inspectFlag_havePositionedCursor
defineAddress 298, 0x0517, inspectFlag_end

%include "../u7-common/patch-restoreGameFlagsCheatMenu.asm"

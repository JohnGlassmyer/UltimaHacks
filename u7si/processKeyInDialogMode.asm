%include "include/u7si-all-includes.asm"

defineAddress 326, 0x0567, handleKeyInput
defineAddress 326, 0x0627, handleKeyInput_end
defineAddress 326, 0x06D7, mappingTable
defineAddress 326, 0x06EB, mappingTable_end

%include "../u7-common/patch-processKeyInDialogMode.asm"

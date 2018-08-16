%include "include/u7bg-all-includes.asm"

defineAddress 340, 0x0EC2, handleKeyInput
defineAddress 340, 0x0F80, handleKeyInput_end
defineAddress 340, 0x1030, mappingTable
defineAddress 340, 0x1044, mappingTable_end

%include "../u7-common/patch-processKeyInDialogMode.asm"

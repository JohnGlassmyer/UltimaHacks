%include "include/u7bg-all-includes.asm"

defineAddress 243, 0x03CF, clickItemInWorld_produceText
defineAddress 243, 0x044A, clickItemInWorld_produceText_end
defineAddress 243, 0x0467, clickItemInWorld_end

defineAddress 340, 0x1895, clickItemInInventory_produceText
defineAddress 340, 0x1907, clickItemInInventory_produceText_end
defineAddress 340, 0x1991, clickItemInInventory_end

%include "../u7-common/patch-itemLabels.asm"

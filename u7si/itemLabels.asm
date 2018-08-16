%include "include/u7si-all-includes.asm"

defineAddress 228, 0x0036, clickItemInWorld_produceText
defineAddress 228, 0x00A8, clickItemInWorld_produceText_end
defineAddress 228, 0x00C5, clickItemInWorld_end

defineAddress 326, 0x0E74, clickItemInInventory_produceText
defineAddress 326, 0x0ED9, clickItemInInventory_produceText_end
defineAddress 326, 0x0F63, clickItemInInventory_end

%include "../u7-common/patch-itemLabels.asm"

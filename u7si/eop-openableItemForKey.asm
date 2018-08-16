%include "include/u7si-all-includes.asm"

%assign BACKPACK_INVENTORY_SLOT InventorySlot_BACKPACK

%macro defineGameSpecificKeyOpenableItems 0
	defineKeyOpenableItem 'j',  555, 0xFF, 0xFF ; jawbone
%endmacro

%include "../u7-common/patch-eop-openableItemForKey.asm"

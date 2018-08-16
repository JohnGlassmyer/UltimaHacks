%include "include/u7bg-all-includes.asm"

%assign BACKPACK_INVENTORY_SLOT InventorySlot_BACK

%macro defineGameSpecificKeyOpenableItems 0
	; none for BG
%endmacro

%include "../u7-common/patch-eop-openableItemForKey.asm"

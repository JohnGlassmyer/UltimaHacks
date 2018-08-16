%include "include/u7bg-all-includes.asm"

%macro callProduceItemDisplayName 0
	push word [bp+var_itemFrame]
	push word [bp+var_itemQuantity]
	push word [bp+var_itemType]
	push word [bp+arg_pn_string]
	callFromOverlay produceItemDisplayName
	add sp, 8
%endmacro

%include "../u7-common/patch-eop-produceItemLabelText.asm"

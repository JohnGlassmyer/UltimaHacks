%include "include/u7si-all-includes.asm"

%macro callProduceItemDisplayName 0
	push word [bp+var_itemQuantity]
	lea ax, [bp+arg_ibo]
	push ax
	push word [bp+arg_pn_string]
	callFromOverlay produceItemDisplayName
	add sp, 6
%endmacro

%include "../u7-common/patch-eop-produceItemLabelText.asm"

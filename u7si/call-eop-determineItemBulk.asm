%include "include/u7si-all-includes.asm"

defineAddress 212, 0x1154, doesItemFit_getBulkOfItems
defineAddress 212, 0x1194, doesItemFit_getBulkOfItems_end
%define doesItemFit_reg_pn_droppedIbo             di
%define doesItemFit_reg_pn_destinationIbo         si
%assign doesItemFit_var_droppedItemBulk           -0x02
%assign doesItemFit_var_destinationCapacity       -0x04
%assign doesItemFit_var_destinationContentsBulk   -0x06

defineAddress 255, 0x0295, determineBulkOfContents_site
defineAddress 255, 0x02AA, determineBulkOfContents_site_end
%assign determineBulkOfContents_var_itemIbo       -0x06

%include "../u7-common/patch-call-eop-determineItemBulk.asm"

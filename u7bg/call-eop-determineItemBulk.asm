%include "include/u7bg-all-includes.asm"

defineAddress 214, 0x0ED3, doesItemFit_getBulkOfItems
defineAddress 214, 0x0F16, doesItemFit_getBulkOfItems_end
%define doesItemFit_reg_pn_droppedIbo             di
%define doesItemFit_reg_pn_destinationIbo         si
%assign doesItemFit_var_droppedItemBulk           -0x02
%assign doesItemFit_var_destinationCapacity       -0x04
%assign doesItemFit_var_destinationContentsBulk   -0x06

defineAddress 272, 0x0283, determineBulkOfContents_site
defineAddress 272, 0x0298, determineBulkOfContents_site_end
%assign determineBulkOfContents_var_itemIbo       -0x06

%include "../u7-common/patch-call-eop-determineItemBulk.asm"

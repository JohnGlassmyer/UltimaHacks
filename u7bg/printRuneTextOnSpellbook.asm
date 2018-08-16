%include "include/u7bg-all-includes.asm"

%assign SpellbookDialog_ibo 0x1D
%assign SpellbookDialog_containingIbo 0xAB

defineAddress 348, 0x0428, SpellbookDialog_update_printReagentCount
defineAddress 348, 0x04A1, SpellbookDialog_update_printReagentCount_end

defineAddress 348, 0x0C32, SpellbookDialog_updateReagentCounts
defineAddress 348, 0x0CD0, SpellbookDialog_updateReagentCounts_end

%include "../u7-common/patch-printRuneTextOnSpellbook.asm"

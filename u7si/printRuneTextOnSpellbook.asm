%include "include/u7si-all-includes.asm"

%assign SpellbookDialog_ibo 0x1D
%assign SpellbookDialog_containingIbo 0xAD

defineAddress 213, 0x0034, isAvatarWearingRingOfReagents

defineAddress 338, 0x042A, SpellbookDialog_update_printReagentCount
defineAddress 338, 0x04DB, SpellbookDialog_update_printReagentCount_end

defineAddress 338, 0x0C6C, SpellbookDialog_updateReagentCounts
defineAddress 338, 0x0D0A, SpellbookDialog_updateReagentCounts_end

%include "../u7-common/patch-printRuneTextOnSpellbook.asm"

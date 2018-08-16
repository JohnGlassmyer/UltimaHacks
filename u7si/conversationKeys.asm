%include "include/u7si-all-includes.asm"

defineAddress 323, 0x05C2, prepareConversationGump

defineAddress 323, 0x0C88, textLoop_procStart
defineAddress 323, 0x0CDD, textLoop_procEnd

defineAddress 323, 0x0C10, optionsLoop_beforeLoop
defineAddress 323, 0x0C65, optionsLoop_loopEnd

defineAddress 323, 0x0DC7, signLoop_start
defineAddress 323, 0x0DDB, signLoop_end

defineAddress 322, 0x0AA3, ConversationGump_checkGumpBounds
defineAddress 322, 0x0AFE, ConversationGump_callOptionsGump

defineAddress 322, 0x056E, OptionsGump_checkGumpBounds
defineAddress 322, 0x05E2, OptionsGump_notInBounds
defineAddress 322, 0x05E5, OptionsGump_considerOptions
defineAddress 322, 0x06D3, OptionsGump_checkOptionBounds
defineAddress 322, 0x073F, OptionsGump_withinOptionBounds
defineAddress 322, 0x07AC, OptionsGump_forOption

%macro callFunctionsInLoop 0
	callFromOverlay playAmbientSounds
	callFromOverlay cyclePalette
%endmacro

%include "../u7-common/patch-conversationKeys.asm"

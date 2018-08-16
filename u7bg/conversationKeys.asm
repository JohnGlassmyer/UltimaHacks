%include "include/u7bg-all-includes.asm"

defineAddress 337, 0x054E, prepareConversationGump

defineAddress 337, 0x096D, textLoop_procStart
defineAddress 337, 0x09C7, textLoop_procEnd

defineAddress 337, 0x08F0, optionsLoop_beforeLoop
defineAddress 337, 0x0948, optionsLoop_loopEnd

defineAddress 337, 0x0AAC, signLoop_start
defineAddress 337, 0x0AC0, signLoop_end

defineAddress 336, 0x0921, ConversationGump_checkGumpBounds
defineAddress 336, 0x097C, ConversationGump_callOptionsGump

defineAddress 336, 0x040D, OptionsGump_checkGumpBounds
defineAddress 336, 0x0481, OptionsGump_notInBounds
defineAddress 336, 0x0484, OptionsGump_considerOptions
defineAddress 336, 0x0572, OptionsGump_checkOptionBounds
defineAddress 336, 0x05DE, OptionsGump_withinOptionBounds
defineAddress 336, 0x0640, OptionsGump_forOption

%macro callFunctionsInLoop 0
	callFromOverlay playAmbientSounds
	callFromOverlay cyclePalette
	callFromOverlay continuePlayingSpeech
%endmacro

%include "../u7-common/patch-conversationKeys.asm"

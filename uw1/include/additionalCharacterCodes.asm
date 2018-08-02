; =============================================================================
; Ultima Underworld Hacks -- additional character mappings
; -----------------------------------------------------------------------------

; mapScancodeToCharacter scancode, character
%macro mapScancodeToCharacter 2
    %define scancode_%[mappedCharacterCount] %1
    %define character_%[mappedCharacterCount] %2
    
    %assign mappedCharacterCount mappedCharacterCount + 1
%endmacro

; mapScancodeToCharacter scancode, character, characterName
%macro mapScancodeToCharacter 3
    mapScancodeToCharacter %1, %2
    
    ; define a macro naming the character
    %define %3 %2
%endmacro

%assign mappedCharacterCount 0

; each key mapped with and without Shift modifier (S|):

mapScancodeToCharacter (  0x2A), 0xB0, LShift
mapScancodeToCharacter (S|0x2A), 0xB0

mapScancodeToCharacter (  0x36), 0xB1, RShift
mapScancodeToCharacter (S|0x36), 0xB1

mapScancodeToCharacter (  0x1D), 0xB2, LCtrl
mapScancodeToCharacter (S|0x1D), 0xB2

mapScancodeToCharacter   0x62, 0xB3, RCtrl
mapScancodeToCharacter S|0x62, 0xB3

mapScancodeToCharacter   0x38, 0xB4, LAlt
mapScancodeToCharacter S|0x38, 0xB4

mapScancodeToCharacter   0x65, 0xB5, RAlt
mapScancodeToCharacter S|0x65, 0xB5

%macro startPatch 2
    %assign targetFileLength %1
    %defstr patchDescription %2
    %strlen patchDescriptionLength patchDescription
    %assign blockCount 0
%endmacro

%macro startBlockAt 1
    %assign startAbsolute %1
    %assign startRelative ($-$$)
    %assign relocationCount 0
%endmacro

; inserts metadata regarding the preceding block of code
; (absolute start address and relocation sites)
%macro endBlockWithFillAt 2
    %assign codeLength ($-$$) - startRelative

    ; fill remainder of patched block
    %assign fillLength (%2 - startAbsolute) - codeLength
    %if fillLength < 0
        %error block overrun
    %endif
    times fillLength %1

    dd codeLength + fillLength

    %rep relocationCount
    dd %$relocationBase + %$relocationOffset - startRelative
    %pop
    %endrep

    dd relocationCount

    dd startAbsolute

    %assign blockCount blockCount + 1
    
    %assign lastBlockAbsoluteEnd startAbsolute + codeLength
%endmacro

%macro endBlockAt 1
    endBlockWithFillAt hlt, %1
%endmacro

%macro endBlockWithFill 1
    endBlockWithFillAt %1, startAbsolute + (($-$$) - startRelative)
%endmacro

%macro endBlock 0
    endBlockWithFill hlt
%endmacro

%macro endPatch 0
    dd blockCount
    dd targetFileLength
    db patchDescription
    dd patchDescriptionLength
%endmacro

%macro startBlock 0
    startBlockAt lastBlockAbsoluteEnd
%endmacro

; calculates the delta to a location outside of the local code block
%define calcJump(targetAbsolute) \
        $+(targetAbsolute - startAbsolute - (($-$$) - startRelative))
        
; callWithRelocation 0xssss:0xoooo
; makes note of the site to be included in relocation metadata
%macro callWithRelocation 1
    %push relocation
    %assign %$relocationOffset 3
    %$relocationBase:
    call %1
    %assign relocationCount relocationCount + 1
%endmacro

%macro pushWithRelocation 1
    %push relocation
    %assign %$relocationOffset 1
    %$relocationBase:
    push strict word %1
    %assign relocationCount relocationCount + 1
%endmacro

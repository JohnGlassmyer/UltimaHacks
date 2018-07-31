; =============================================================================
; Ultima Underworld Hacks -- main
; -----------------------------------------------------------------------------
; by John Glassmyer
; github.com/JohnGlassmyer/UltimaHacks

; assuming that overlay 117 was expanded and moved to the end of the executable:
; java -jar UltimaPatcher.jar --exe=UW2.EXE \
;     --expand_overlay_index=117 --expand_overlay_length=0x2400

; =============================================================================
; length of executable to be patched, and of expanded overlay
; -----------------------------------------------------------------------------
; assuming that the expanded overlay has been moved to the end of the file

ORIGINAL_EXE_LENGTH                     EQU 0x859B0
EXPANDED_OVERLAY_LENGTH                 EQU 0x2400
EXPANDED_OVERLAY_EXE_LENGTH             EQU \
        ORIGINAL_EXE_LENGTH + EXPANDED_OVERLAY_LENGTH
ORIGINAL_EOP_LENGTH                     EQU 0x108F

; =============================================================================
; absolute offsets in the executable file
; -----------------------------------------------------------------------------

off_dseg_segmentZero                    EQU 0x5DCC0

; =============================================================================
; data-segment offsets
; -----------------------------------------------------------------------------

; steal bytes from Borland's Turbo C++ copyright string
; (initialized in initializeRepurposedDsegBytes.asm)
dseg_isMouseLookEnabled                 EQU 0x0008
dseg_wasMouseLookEnabledIn3dView        EQU 0x0009
dseg_cursorXDuringMouseLook             EQU 0x000A
dseg_cursorYDuringMouseLook             EQU 0x000C
dseg_isDrawingBehindPlayer              EQU 0x000E
dseg_wasLastBindingKey                  EQU 0x000F
dseg_pn_lastKeyOrMouseBinding           EQU 0x0010
dseg_lastKeyBindingTime                 EQU 0x0012
dseg_newlineString                      EQU 0x0016
dseg_trigScale                          EQU 0x0018
dseg_radianAngle                        EQU 0x001C
dseg_autoAttackType                     EQU 0x0020
dseg_haveWarnedAboutDrawQueueLimit      EQU 0x0021

dseg_avatarMovementFlags                EQU 0x00D2
dseg_pn_inputState                      EQU 0x00E2
dseg_cursorX                            EQU 0x010E
dseg_cursorY                            EQU 0x0110
dseg_isCursorVisible                    EQU 0x0114
dseg_currentCursorAreaMinX              EQU 0x0120
dseg_lastKeyTime                        EQU 0x012E
dseg_currentAttackScancode              EQU 0x0244
dseg_isGettingFromLook                  EQU 0x0288
dseg_movementType                       EQU 0x075A
dseg_rotationSpeedBase                  EQU 0x075C
dseg_forwardThrottle                    EQU 0x0763
dseg_rotationThrottle                   EQU 0x0765
dseg_movementScancodesArray             EQU 0x076B
dseg_activePanelNumber                  EQU 0x0784
dseg_ps_shiftStates                     EQU 0x2334
dseg_ps_keyStates                       EQU 0x2344
dseg_ps_time                            EQU 0x2364
dseg_ps_perspective                     EQU 0x2378
dseg_cursorMinX                         EQU 0x2524
dseg_cursorMinY                         EQU 0x2526
dseg_cursorMaxX                         EQU 0x257E
dseg_cursorMaxY                         EQU 0x2580
dseg_currentCursorAreaMinY              EQU 0x258C
dseg_currentCursorAreaMaxX              EQU 0x25BC
dseg_currentCursorAreaMaxY              EQU 0x25BE
dseg_findItemThing                      EQU 0x2682
dseg_ps_itemAtCursor                    EQU 0x269E
dseg_cursorMode                         EQU 0x26AC
dseg_gridViewFlags                      EQU 0x2890
dseg_leftViewLimit                      EQU 0x2D00
dseg_rightViewLimit                     EQU 0x2D11
dseg_drawQueuing_currentColumn          EQU 0x2E0C
dseg_drawQueuing_currentRow             EQU 0x2E0E
dseg_pitch                              EQU 0x3588
dseg_mapDungeonLevel                    EQU 0x381E
dseg_mappedTerrain                      EQU 0x3820
dseg_interfaceMode                      EQU 0x565E
dseg_interfaceRoutinesSelector          EQU 0x5664
dseg_ps_cursorItem                      EQU 0x5B06
dseg_pn_avatarData                      EQU 0x7270
dseg_ps_avatarItem                      EQU 0x7274
dseg_avatarDungeonLevel                 EQU 0x7278
dseg_heading                            EQU 0x727A
dseg_3dViewHeight                       EQU 0x7280
dseg_3dViewLeftX                        EQU 0x7282
dseg_3dViewBottomY                      EQU 0x735E
dseg_3dViewWidth                        EQU 0x7364
dseg_ps_drawQueueEnd                    EQU 0x7452

; =============================================================================
; procedure far-call addresses
; -----------------------------------------------------------------------------

defineProc 0x0028, 0x0EC5, 0x1DFF, signedWordToString
defineProc 0x0028, 0x0EC5, 0x1E26, unsignedDwordToString
defineProc 0x0028, 0x0EC5, 0x290A, strcat

defineProc 0x0058, 0x1A6F, 0x0083, bindMouse
defineProc 0x0058, 0x1A6F, 0x0105, bindKey
defineProc 0x0058, 0x1A6F, 0x02B1, tryKeyAndMouseBindings

defineProc 0x0060, 0x1AB6, 0x00AF, setInterfaceRoutineBit

defineProc 0x0070, 0x1ADC, 0x0075, eraseCursorIfVisible
defineProc 0x0070, 0x1ADC, 0x0802, setCursorImage
defineProc 0x0070, 0x1ADC, 0x0868, updateCursorRegion
defineProc 0x0070, 0x1ADC, 0x0BE8, savePixelsAroundCursor
defineProc 0x0070, 0x1ADC, 0x0CF2, drawCursor
defineProc 0x0070, 0x1ADC, 0x0E29, moveCursor

defineProc 0x0078, 0x1BD8, 0x0B1B, playSoundEffect

defineProc 0x0098, 0x1DF0, 0x0001, enqueueGridCoords
defineProc 0x0098, 0x1DF0, 0x00C5, enqueueDrawWithinLimits
defineProc 0x0098, 0x1DF0, 0x0DBC, enqueueDrawBlock

defineProc 0x00A8, 0x1F3A, 0x0EAE, sinAndCosInterpolated

defineProc 0x00C8, 0x2121, 0x11BA, attack

defineProc 0x00D8, 0x22EF, 0x000F, flipCharPanel
defineProc 0x00D8, 0x22EF, 0x0032, clickCompass
defineProc 0x00D8, 0x22EF, 0x010F, clickFlasks
defineProc 0x00D8, 0x22EF, 0x08CA, findItemAtCursor
defineProc 0x00D8, 0x22EF, 0x09D0, describeClickedTerrain
defineProc 0x00D8, 0x22EF, 0x0CEC, talkModeProc
defineProc 0x00D8, 0x22EF, 0x0D20, lookModeProc
defineProc 0x00D8, 0x22EF, 0x0E3F, useModeProc
defineProc 0x00D8, 0x22EF, 0x13D5, activateMode

defineProc 0x00F0, 0x2674, 0x0A52, isItemCharacter

defineProc 0x0110, 0x2ABA, 0x0246, clearDrawQueue
defineProc 0x0110, 0x2ABA, 0x0396, setupPerspective
defineProc 0x0110, 0x2ABA, 0x05B4, setupViewLimits
defineProc 0x0110, 0x2ABA, 0x115E, applyViewLimits

defineProc 0x0128, 0x2D9C, 0x004E, move
defineProc 0x0128, 0x2D9C, 0x0334, easyMove

defineProc 0x0138, 0x2E9A, 0x03DF, setPanelState
defineProc 0x0138, 0x2E9A, 0x11B3, animateSlidingPanel
defineProc 0x0138, 0x2E9A, 0x1AD5, slidePanel

defineProc 0x0150, 0x32A8, 0x008D, getExternalizedString
defineProc 0x0150, 0x32A8, 0x090E, strcat_far

defineProc 0x0170, 0x3603, 0x02EA, printStringToScroll

; load-module segments < 0x5950 <= overlay segments

defineProc 0x02E0, 0x595C, 0x007A, changeMapLevel

defineProc 0x02F8, 0x597E, 0x0070, clickOtherTrade
defineProc 0x02F8, 0x597E, 0x0084, clickAvatarTrade

defineProc 0x0320, 0x599C, 0x003E, ark_say
defineProc 0x0320, 0x599C, 0x0075, selectConversationOption

defineProc 0x0368, 0x59D3, 0x0048, transitionToInterfaceMode

defineProc 0x03A8, 0x59FE, 0x0020, scrollInventoryDown
defineProc 0x03A8, 0x59FE, 0x002F, closeInventoryContainer
defineProc 0x03A8, 0x59FE, 0x0043, scrollInventoryUp
; eop dispatchers, inserted after the last proc in the expanded overlay
defineProc 0x03A8, 0x59FE, 0x005C+1*5, varArgsEopDispatcher
defineProc 0x03A8, 0x59FE, 0x005C+2*5, byteArgEopDispatcher
defineProc 0x03A8, 0x59FE, 0x005C+3*5, byCallSiteEopDispatcher

defineProc 0x03B8, 0x5A0B, 0x0020, tryToCast
defineProc 0x03B8, 0x5A0B, 0x0034, clickRunePanel

defineProc 0x0410, 0x5A3D, 0x007F, handleControlKey

defineProc 0x0430, 0x5A53, 0x0052, adjustPitch
defineProc 0x0430, 0x5A53, 0x0061, printVersion
defineProc 0x0430, 0x5A53, 0x0066, printDebug

defineProc 0x0478, 0x5A76, 0x008E, sleep
defineProc 0x0478, 0x5A76, 0x0093, track
defineProc 0x0478, 0x5A76, 0x0070, trainSkill

; =============================================================================
; structure offsets
; -----------------------------------------------------------------------------

InputState_relativeX                    EQU 0x00
InputState_relativeY                    EQU 0x02
InputState_mouseButton                  EQU 0x06
InputState_mode                         EQU 0x08

Perspective_x                           EQU 0x0A
Perspective_y                           EQU 0x12
Perspective_heading                     EQU 0x2C

ViewLimit_headingSin                    EQU 0x01
ViewLimit_headingCos                    EQU 0x03
ViewLimit_currentBlockX                 EQU 0x05
ViewLimit_intraBlockX                   EQU 0x06
ViewLimit_currentBlockY                 EQU 0x07
ViewLimit_intraBlockY                   EQU 0x08
ViewLimit_terrainGrid_ps                EQU 0x09

ShiftStates_shift                       EQU 0
ShiftStates_alt                         EQU 1
ShiftStates_ctrl                        EQU 2

; =============================================================================
; enumerations
; -----------------------------------------------------------------------------

%assign MapControl_LEVEL_UP             0
%assign MapControl_LEVEL_DOWN           1
%assign MapControl_AVATAR_LEVEL         4

%assign ReducedHeading_NORTH            0
%assign ReducedHeading_EAST             1
%assign ReducedHeading_SOUTH            2
%assign ReducedHeading_WEST             3

%assign SoundNumber_ERROR               45

%assign StringColor_DEFAULT             0 ; brown
%assign StringColor_AVATAR_SPEECH       1 ; gold
%assign StringColor_NARRATION           2 ; black
%assign StringColor_WHITE               3
%assign StringColor_ERROR               4 ; red
%assign StringColor_BLUE                5
%assign StringColor_MENU                6 ; dark green

%assign InterfaceMode_NORMAL            1
%assign InterfaceMode_MAP               2
%assign InterfaceMode_CONVERSATION      4

; =============================================================================
; other values
; -----------------------------------------------------------------------------

; how far up or down the player is allowed to look
; (original value is 4 * 1024; too-large values allow the view to wrap around)
%assign pitchBound                      12 * 1024

; key modifier bits
%assign S 0x080 ; Shift modifier bit
%assign C 0x100 ; Ctrl modifier bit
%assign A 0x200 ; Alt modifier bit
%assign H 0x400 ; High-bit scancode modifier bit

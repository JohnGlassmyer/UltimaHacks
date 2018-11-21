; =============================================================================
; Ultima Underworld Hacks -- main
; -----------------------------------------------------------------------------
; by John Glassmyer
; github.com/JohnGlassmyer/UltimaHacks

; assuming that overlay 117 was expanded and moved to the end of the executable:
; java -jar UltimaPatcher.jar --exe=UW.EXE --expand-overlay=117:0x2200 (...)

; =============================================================================
; length of executable to be patched, and of expanded overlay
; -----------------------------------------------------------------------------
; assuming that the expanded overlay has been moved to the end of the file

%assign ORIGINAL_EXE_LENGTH                     0x859B0
%assign EXPANDED_OVERLAY_LENGTH                 0x2200
%assign ORIGINAL_EOP_LENGTH                     0x108F

%assign EXE_LENGTH (ORIGINAL_EXE_LENGTH + EXPANDED_OVERLAY_LENGTH)

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
dseg_mouseLookOrientation               EQU 0x0022

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

defineSegment 4, 0x0020, 0x06E7

defineSegment 5, 0x0028, 0x0EC5
defineAddress 5, 0x1DFF, signedWordToString
defineAddress 5, 0x1E26, unsignedDwordToString
defineAddress 5, 0x290A, strcat

defineSegment 9, 0x0048, 0x193D

defineSegment 11, 0x0058, 0x1A6F
defineAddress 11, 0x0083, bindMouse
defineAddress 11, 0x0105, bindKey
defineAddress 11, 0x02B1, tryKeyAndMouseBindings

defineSegment 12, 0x0060, 0x1AB6
defineAddress 12, 0x00AF, setInterfaceRoutineBit

defineSegment 14, 0x0070, 0x1ADC
defineAddress 14, 0x0075, eraseCursorIfVisible
defineAddress 14, 0x0802, setCursorImage
defineAddress 14, 0x0868, updateCursorRegion
defineAddress 14, 0x0BE8, savePixelsAroundCursor
defineAddress 14, 0x0CF2, drawCursor
defineAddress 14, 0x0E29, moveCursor

defineSegment 15, 0x0078, 0x1BD8
defineAddress 15, 0x0B1B, playSoundEffect

defineSegment 19, 0x0098, 0x1DF0
defineAddress 19, 0x0001, enqueueGridCoords
defineAddress 19, 0x00C5, enqueueDrawWithinLimits
defineAddress 19, 0x0DBC, enqueueDrawBlock

defineSegment 21, 0x00A8, 0x1F3A
defineAddress 21, 0x0EAE, sinAndCosInterpolated

defineSegment 25, 0x00C8, 0x2121
defineAddress 25, 0x11BA, attack

defineSegment 27, 0x00D8, 0x22EF
defineAddress 27, 0x000F, flipCharPanel
defineAddress 27, 0x0032, clickCompass
defineAddress 27, 0x010F, clickFlasks
defineAddress 27, 0x08CA, findItemAtCursor
defineAddress 27, 0x09D0, describeClickedTerrain
defineAddress 27, 0x0CEC, talkModeProc
defineAddress 27, 0x0D20, lookModeProc
defineAddress 27, 0x0E3F, useModeProc
defineAddress 27, 0x13D5, activateMode

defineSegment 30, 0x00F0, 0x2674
defineAddress 30, 0x0A52, isItemCharacter

defineSegment 34, 0x0110, 0x2ABA
defineAddress 34, 0x0246, clearDrawQueue
defineAddress 34, 0x0396, setupPerspective
defineAddress 34, 0x05B4, setupViewLimits
defineAddress 34, 0x115E, applyViewLimits

defineSegment 36, 0x0120, 0x2D02
defineAddress 36, 0x043B, enqueueDrawItems

defineSegment 37, 0x0128, 0x2D9C
defineAddress 37, 0x004E, move
defineAddress 37, 0x0334, easyMove

defineSegment 39, 0x0138, 0x2E9A
defineAddress 39, 0x03DF, setPanelState
defineAddress 39, 0x11B3, animateSlidingPanel
defineAddress 39, 0x1AD5, slidePanel

defineSegment 42, 0x0150, 0x32A8
defineAddress 42, 0x008D, getExternalizedString
defineAddress 42, 0x090E, strcat_far

defineSegment 46, 0x0170, 0x3603
defineAddress 46, 0x02EA, printStringToScroll

defineSegment 72, 0x0240, 0x5624

defineSegment 92, 0x02E0, 0x595C
defineAddress 92, 0x007A, changeMapLevel

defineSegment 95, 0x02F8, 0x597E
defineAddress 95, 0x0070, clickOtherTrade
defineAddress 95, 0x0084, clickAvatarTrade

defineSegment 100, 0x0320, 0x599C
defineAddress 100, 0x003E, ark_say
defineAddress 100, 0x0075, selectConversationOption

defineSegment 109, 0x0368, 0x59D3
defineAddress 109, 0x0048, transitionToInterfaceMode

defineSegment 117, 0x03A8, 0x59FE, eop
defineAddress 117, 0x0020, scrollInventoryDown
defineAddress 117, 0x002F, closeInventoryContainer
defineAddress 117, 0x0043, scrollInventoryUp
defineAddress 117, 0x005C+1*5, varArgsEopDispatcher
defineAddress 117, 0x005C+2*5, byteArgEopDispatcher
defineAddress 117, 0x005C+3*5, byCallSiteEopDispatcher

defineSegment 119, 0x03B8, 0x5A0B
defineAddress 119, 0x0020, tryToCast
defineAddress 119, 0x0034, clickRunePanel

defineSegment 130, 0x0410, 0x5A3D
defineAddress 130, 0x007F, handleControlKey

defineSegment 134, 0x0430, 0x5A53
defineAddress 134, 0x0052, adjustPitch
defineAddress 134, 0x0061, printVersion
defineAddress 134, 0x0066, printDebug

defineSegment 138, 0x0450, 0x5A61

defineSegment 143, 0x0478, 0x5A76
defineAddress 143, 0x008E, sleep
defineAddress 143, 0x0093, track
defineAddress 143, 0x0070, trainSkill

defineSegment 155, 0x04D8, 0x5AAC, dseg

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

%assign MOUSE_LOOK_INVERT_Y 1
%assign MOUSE_LOOK_INVERT_X 2

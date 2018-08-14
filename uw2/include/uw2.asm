; =============================================================================
; Ultima Underworld II Hacks -- main
; -----------------------------------------------------------------------------
; by John Glassmyer
; github.com/JohnGlassmyer/UltimaHacks

; assuming that overlay 93 was expanded and moved to the end of the executable:
; java -jar UltimaPatcher.jar --exe=UW2.EXE --expand-overlay=93:0x2200 (...)

; =============================================================================
; length of executable to be patched, and of expanded overlay
; -----------------------------------------------------------------------------
; assuming that the expanded overlay has been moved to the end of the file

%assign ORIGINAL_EXE_LENGTH                     0xA4D70
%assign EXPANDED_OVERLAY_LENGTH                 0x2200
%assign ORIGINAL_EOP_LENGTH                     0x0E2F

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

dseg_avatarMovementFlags                EQU 0x00D2
dseg_pn_inputState                      EQU 0x00E4
dseg_cursorX                            EQU 0x0268
dseg_cursorY                            EQU 0x026A
dseg_isCursorVisible                    EQU 0x026E
dseg_currentCursorAreaMinX              EQU 0x027A
dseg_mouseHand                          EQU 0x0285
dseg_lastKeyTime                        EQU 0x028D
dseg_currentAttackScancode              EQU 0x0366
dseg_isGettingFromLook                  EQU 0x0389
dseg_movementType                       EQU 0x0773
dseg_rotationSpeedBase                  EQU 0x0775
dseg_forwardThrottle                    EQU 0x077C
dseg_rotationThrottle                   EQU 0x077E
dseg_movementScancodesArray             EQU 0x0784
dseg_activePanelNumber                  EQU 0x079E
dseg_ps_shiftStates                     EQU 0x2128
dseg_ps_keyStates                       EQU 0x2138
dseg_ps_time                            EQU 0x2158
dseg_ps_perspective                     EQU 0x2168
dseg_cursorMinX                         EQU 0x233C
dseg_cursorMinY                         EQU 0x233E
dseg_cursorMaxX                         EQU 0x2396
dseg_cursorMaxY                         EQU 0x2398
dseg_currentCursorAreaMinY              EQU 0x23A4
dseg_currentCursorAreaMaxX              EQU 0x23D4
dseg_currentCursorAreaMaxY              EQU 0x23D6
dseg_findItemThing                      EQU 0x24E4
dseg_ps_itemAtCursor                    EQU 0x24FC
dseg_cursorMode                         EQU 0x2506
dseg_gridViewFlags                      EQU 0x26EE
dseg_leftViewLimit                      EQU 0x2B5E
dseg_rightViewLimit                     EQU 0x2B6F
dseg_drawQueuing_currentColumn          EQU 0x2C6A
dseg_drawQueuing_currentRow             EQU 0x2C6C
dseg_pitch                              EQU 0x33D6
dseg_mapDungeonLevel                    EQU 0x36FA
dseg_mappedTerrain                      EQU 0x36FC
dseg_interfaceMode                      EQU 0x5D60
dseg_interfaceRoutinesSelector          EQU 0x5D66
dseg_ps_cursorItem                      EQU 0x6B0C
dseg_pn_avatarData                      EQU 0x828A
dseg_ps_avatarItem                      EQU 0x828E
dseg_avatarDungeonLevel                 EQU 0x8292
dseg_heading                            EQU 0x8294
dseg_3dViewHeight                       EQU 0x829C
dseg_3dViewLeftX                        EQU 0x829E
dseg_3dViewBottomY                      EQU 0x8626
dseg_3dViewWidth                        EQU 0x862C
dseg_ps_drawQueueEnd                    EQU 0x8720

; =============================================================================
; procedure far-call addresses
; -----------------------------------------------------------------------------

defineSegment 4, 0x0020, 0x065C

defineSegment 5, 0x0028, 0x0E72
defineAddress 5, 0x1D1B, signedWordToString
defineAddress 5, 0x1D42, unsignedDwordToString
defineAddress 5, 0x27F3, strcat

defineSegment 9, 0x0048, 0x191C

defineSegment 11, 0x0058, 0x1AB4
defineAddress 11, 0x0082, bindMouse
defineAddress 11, 0x0104, bindKey
defineAddress 11, 0x02A0, tryKeyAndMouseBindings

defineSegment 13, 0x0068, 0x1B44
defineAddress 13, 0x00AE, setInterfaceRoutineBit

defineSegment 15, 0x0078, 0x1B6B
defineAddress 15, 0x018B, handleControlKey

defineSegment 16, 0x0080, 0x1B8F
defineAddress 16, 0x0074, eraseCursorIfVisible
defineAddress 16, 0x0745, setCursorImage
defineAddress 16, 0x07AB, updateCursorRegion
defineAddress 16, 0x0B70, savePixelsAroundCursor
defineAddress 16, 0x0C70, drawCursor
defineAddress 16, 0x0DA7, moveCursor

defineSegment 17, 0x0088, 0x1C86
defineAddress 17, 0x1DB2, playSoundEffect

defineSegment 21, 0x00A8, 0x1FCD
defineAddress 21, 0x000C, enqueueGridCoords
defineAddress 21, 0x00D0, enqueueDrawWithinLimits
defineAddress 21, 0x0D3C, enqueueDrawBlock

defineSegment 23, 0x00B8, 0x2110
defineAddress 23, 0x0EAE, sinAndCosInterpolated

defineSegment 26, 0x00D0, 0x22FC
defineAddress 26, 0x134B, attack

defineSegment 28, 0x00E0, 0x2529
defineAddress 28, 0x05E7, findItemAtCursor
defineAddress 28, 0x073F, describeClickedTerrain
defineAddress 28, 0x0AFB, talkModeProc
defineAddress 28, 0x0B19, lookModeProc
defineAddress 28, 0x0C3A, useModeProc
defineAddress 28, 0x112A, setInteractionMode

defineSegment 31, 0x00F8, 0x28A1
defineAddress 31, 0x0A87, isItemCharacter

defineSegment 34, 0x0110, 0x2CAE
defineAddress 34, 0x024A, clearDrawQueue
defineAddress 34, 0x039A, setupPerspective
defineAddress 34, 0x05B8, setupViewLimits
defineAddress 34, 0x1162, applyViewLimits

defineSegment 36, 0x0120, 0x2F20
defineAddress 36, 0x0465, enqueueDrawItems

defineSegment 37, 0x0128, 0x2FBE
defineAddress 37, 0x0056, move
defineAddress 37, 0x0350, easyMove

defineSegment 39, 0x0138, 0x30D3
defineAddress 39, 0x02C8, setPanelState
defineAddress 39, 0x0A06, animateSlidingPanel
defineAddress 39, 0x136B, slidePanel

defineSegment 41, 0x0148, 0x3265
defineAddress 41, 0x008E, getExternalizedString
defineAddress 41, 0x090B, strcat_far

defineSegment 45, 0x0168, 0x342C
defineAddress 45, 0x01A0, printStringToScroll

defineSegment 71, 0x0238, 0x60B9

defineSegment 93, 0x02E8, 0x6417, eop
defineAddress 93, 0x0061, varArgsEopDispatcher
defineAddress 93, 0x0066, byteArgEopDispatcher
defineAddress 93, 0x006B, byCallSiteEopDispatcher

defineSegment 94, 0x02F0, 0x641E
defineAddress 94, 0x00A7, changeMapLevel

defineSegment 96, 0x0300, 0x643D

defineSegment 97, 0x0308, 0x6448
defineAddress 97, 0x007A, clickOtherTrade
defineAddress 97, 0x008E, clickAvatarTrade

defineSegment 103, 0x0338, 0x6469
defineAddress 103, 0x003E, ark_say
defineAddress 103, 0x007A, selectConversationOption

defineSegment 108, 0x0360, 0x6488

defineSegment 112, 0x0380, 0x64BF
defineAddress 112, 0x004D, transitionToInterfaceMode

defineSegment 121, 0x03C8, 0x64F7
defineAddress 121, 0x0020, scrollInventoryDown
defineAddress 121, 0x002F, closeInventoryContainer
defineAddress 121, 0x0043, scrollInventoryUp

defineSegment 123, 0x03D8, 0x6504
defineAddress 123, 0x0020, tryToCast
defineAddress 123, 0x0034, clickRunePanel

defineSegment 137, 0x0448, 0x654A
defineAddress 137, 0x0020, clickCompass
defineAddress 137, 0x002A, clickFlasks
defineAddress 137, 0x0043, flipCharPanel

defineSegment 143, 0x0478, 0x656A
defineAddress 143, 0x004D, adjustPitch
defineAddress 143, 0x005C, printVersion
defineAddress 143, 0x0061, printDebug

defineSegment 147, 0x0498, 0x6578

defineSegment 154, 0x04D0, 0x6599
defineAddress 154, 0x0057, trainSkill
defineAddress 154, 0x0093, sleep
defineAddress 154, 0x009D, track

defineSegment 167, 0x0538, 0x65E0
defineAddress 167, 0x0052, toggleBool

defineSegment 168, 0x0540, 0x65E9, dseg

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
%assign MapControl_REALM_UP             2
%assign MapControl_REALM_DOWN           3
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

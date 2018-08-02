; =============================================================================
; Ultima Underworld II Hacks -- main
; -----------------------------------------------------------------------------
; by John Glassmyer
; github.com/JohnGlassmyer/UltimaHacks

; assuming that overlay 93 was expanded and moved to the end of the executable:
; java -jar UltimaPatcher.jar --exe=UW2.EXE \
;     --expand_overlay_index=93 --expand_overlay_length=0x2800

; =============================================================================
; length of executable to be patched, and of expanded overlay
; -----------------------------------------------------------------------------
; assuming that the expanded overlay has been moved to the end of the file

ORIGINAL_EXE_LENGTH                     EQU 0xA4D70
EXPANDED_OVERLAY_LENGTH                 EQU 0x2800
EXPANDED_OVERLAY_EXE_LENGTH             EQU \
        ORIGINAL_EXE_LENGTH + EXPANDED_OVERLAY_LENGTH
ORIGINAL_EOP_LENGTH                     EQU 0x0E2F

; =============================================================================
; absolute offsets in the executable file
; -----------------------------------------------------------------------------

off_dseg_segmentZero                    EQU 0x68A90

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
dseg_lastKeyOrMouseBinding_pn           EQU 0x0010
dseg_lastKeyBindingTime                 EQU 0x0012
dseg_newlineString                      EQU 0x0016
dseg_trigScale                          EQU 0x0018
dseg_radianAngle                        EQU 0x001C
dseg_autoAttackType                     EQU 0x0020
dseg_haveWarnedAboutDrawQueueLimit      EQU 0x0021

dseg_avatarMovementFlags                EQU 0x00D2
dseg_inputState_pn                      EQU 0x00E4
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
dseg_shiftStates_ps                     EQU 0x2128
dseg_keyStates_ps                       EQU 0x2138
dseg_time_ps                            EQU 0x2158
dseg_perspective_ps                     EQU 0x2168
dseg_cursorMinX                         EQU 0x233C
dseg_cursorMinY                         EQU 0x233E
dseg_cursorMaxX                         EQU 0x2396
dseg_cursorMaxY                         EQU 0x2398
dseg_currentCursorAreaMinY              EQU 0x23A4
dseg_currentCursorAreaMaxX              EQU 0x23D4
dseg_currentCursorAreaMaxY              EQU 0x23D6
dseg_itemAtCursor_ps                    EQU 0x24FC
dseg_cursorMode                         EQU 0x2506
dseg_gridViewFlags                      EQU 0x26EE
dseg_leftViewLimit                      EQU 0x2B5E
dseg_rightViewLimit                     EQU 0x2B6F
dseg_drawQueuing_currentColumn          EQU 0x2C6A
dseg_drawQueuing_currentRow             EQU 0x2C6C
dseg_pitch                              EQU 0x33D6
dseg_mapDungeonLevel                    EQU 0x36FA
dseg_mappedTerrain_pn                   EQU 0x36FC
dseg_interfaceMode                      EQU 0x5D60
dseg_interfaceRoutinesSelector          EQU 0x5D66
dseg_cursorItem_ps                      EQU 0x6B0C
dseg_avatarData_pn                      EQU 0x828A
dseg_avatarItem_ps                      EQU 0x828E
dseg_avatarDungeonLevel                 EQU 0x8292
dseg_heading                            EQU 0x8294
dseg_3dViewHeight                       EQU 0x829C
dseg_3dViewLeftX                        EQU 0x829E
dseg_3dViewBottomY                      EQU 0x8626
dseg_3dViewWidth                        EQU 0x862C
dseg_drawQueueEnd_ps                    EQU 0x8720

; =============================================================================
; procedure far-call addresses
; -----------------------------------------------------------------------------

defineProc 0x0028, 0x0E72, 0x1D1B, signedWordToString
defineProc 0x0028, 0x0E72, 0x1D42, unsignedDwordToString
defineProc 0x0028, 0x0E72, 0x27F3, strcat

defineProc 0x0058, 0x1AB4, 0x0082, bindMouse
defineProc 0x0058, 0x1AB4, 0x0104, bindKey
defineProc 0x0058, 0x1AB4, 0x02A0, tryKeyAndMouseBindings

defineProc 0x0068, 0x1B44, 0x00AE, setInterfaceRoutineBit

defineProc 0x0078, 0x1B6B, 0x018B, handleControlKey

defineProc 0x0080, 0x1B8F, 0x0074, eraseCursorIfVisible
defineProc 0x0080, 0x1B8F, 0x0745, setCursorImage
defineProc 0x0080, 0x1B8F, 0x07AB, updateCursorRegion
defineProc 0x0080, 0x1B8F, 0x0B70, savePixelsAroundCursor
defineProc 0x0080, 0x1B8F, 0x0C70, drawCursor
defineProc 0x0080, 0x1B8F, 0x0DA7, moveCursor

defineProc 0x0088, 0x1C86, 0x1DB2, playSoundEffect

defineProc 0x00A8, 0x1FCD, 0x000C, enqueueGridCoords
defineProc 0x00A8, 0x1FCD, 0x00D0, enqueueDrawWithinLimits
defineProc 0x00A8, 0x1FCD, 0x0D3C, enqueueDrawBlock

defineProc 0x00B8, 0x2110, 0x0EAE, sinAndCosInterpolated

defineProc 0x00D0, 0x22FC, 0x134B, attack

defineProc 0x00E0, 0x2529, 0x05E7, findItemAtCursor
defineProc 0x00E0, 0x2529, 0x073F, describeClickedTerrain
defineProc 0x00E0, 0x2529, 0x0AFB, talkModeProc
defineProc 0x00E0, 0x2529, 0x0B19, lookModeProc
defineProc 0x00E0, 0x2529, 0x0C3A, useModeProc
defineProc 0x00E0, 0x2529, 0x112A, setInteractionMode

defineProc 0x00F8, 0x28A1, 0x0A87, isItemCharacter

defineProc 0x0110, 0x2CAE, 0x024A, clearDrawQueue
defineProc 0x0110, 0x2CAE, 0x039A, setupPerspective
defineProc 0x0110, 0x2CAE, 0x05B8, setupViewLimits
defineProc 0x0110, 0x2CAE, 0x1162, applyViewLimits

defineProc 0x0128, 0x2FBE, 0x0056, move
defineProc 0x0128, 0x2FBE, 0x0350, easyMove

defineProc 0x0138, 0x30D3, 0x02C8, setPanelState
defineProc 0x0138, 0x30D3, 0x0A06, animateSlidingPanel
defineProc 0x0138, 0x30D3, 0x136B, slidePanel

defineProc 0x0148, 0x3265, 0x008E, getExternalizedString
defineProc 0x0148, 0x3265, 0x090B, strcat_far

defineProc 0x0168, 0x342C, 0x01A0, printStringToScroll

defineProc 0x02E8, 0x6417, 0x0061, varArgsEopDispatcher
defineProc 0x02E8, 0x6417, 0x0066, byteArgEopDispatcher
defineProc 0x02E8, 0x6417, 0x006B, byCallSiteEopDispatcher

defineProc 0x02F0, 0x641E, 0x00A7, changeMapLevel

defineProc 0x0308, 0x6448, 0x007A, clickOtherTrade
defineProc 0x0308, 0x6448, 0x008E, clickAvatarTrade

defineProc 0x0338, 0x6469, 0x003E, ark_say
defineProc 0x0338, 0x6469, 0x007A, selectConversationOption

defineProc 0x0380, 0x64BF, 0x004D, transitionToInterfaceMode

defineProc 0x03C8, 0x64F7, 0x002F, closeInventoryContainer

defineProc 0x03D8, 0x6504, 0x0020, tryToCast
defineProc 0x03D8, 0x6504, 0x0034, clickRunePanel

defineProc 0x0448, 0x654A, 0x0020, clickCompass
defineProc 0x0448, 0x654A, 0x002A, clickFlasks
defineProc 0x0448, 0x654A, 0x0043, flipCharPanel

defineProc 0x04D0, 0x6599, 0x0057, trainSkill
defineProc 0x04D0, 0x6599, 0x0093, sleep
defineProc 0x04D0, 0x6599, 0x009D, track

defineProc 0x0478, 0x656A, 0x004D, adjustPitch
defineProc 0x0478, 0x656A, 0x005C, printVersion
defineProc 0x0478, 0x656A, 0x0061, printDebug

defineProc 0x0538, 0x65E0, 0x0052, toggleBool

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

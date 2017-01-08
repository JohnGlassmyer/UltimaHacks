; =============================================================================
; Ultima Underworld II Hacks -- main
; -----------------------------------------------------------------------------
; by John Glassmyer
; github.com/JohnGlassmyer/UltimaHacks

; assuming that overlay 93 was expanded and moved to the end of the executable:
; java -jar UltimaPatcher.jar --exe=UW2.EXE \
;     --expand_overlay_index=93 --expand_overlay_length=0x4000

; =============================================================================
; length of executable to be patched, and of expanded overlay
; -----------------------------------------------------------------------------
; assuming that the expanded overlay has been moved to the end of the file

ORIGINAL_EXE_LENGTH                     EQU 0xA4D70
EXPANDED_OVERLAY_LENGTH                 EQU 0x4000
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
dseg_cursorNumbersArray                 EQU 0x106C
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
dseg_drawQueuing_currentColumn          EQU 0x2C6A
dseg_drawQueuing_currentRow             EQU 0x2C6C
dseg_pitch                              EQU 0x33D6
dseg_mapDungeonLevel                    EQU 0x36FA
dseg_mappedTerrain_pn                   EQU 0x36FC
dseg_interfaceContext                   EQU 0x5D60
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

; TODO decide whether to keep, and sort into list above
    dseg_gridViewFlags                  EQU 0x26EE
    dseg_reducedHeading                 EQU 0x2B52
    dseg_perspectiveTerrainGrid_ps      EQU 0x2B58
    dseg_leftViewLimit                  EQU 0x2B5E
    dseg_rightViewLimit                 EQU 0x2B6F
    dseg_gridRowBeingDrawn              EQU 0x2C6C

; =============================================================================
; procedure far-call addresses
; -----------------------------------------------------------------------------
; l_xxx if calling from the load module
; o_xxx if calling from an overlay

%define l_redrawRegion                  0x0085:0x4AC1
%define o_redrawRegion                  0x0018:0x4AC1

%define l_signedWordToString            0x0E72:0x1D1B
%define o_signedWordToString            0x0028:0x1D1B
%define l_unsignedDwordToString         0x0E72:0x1D42
%define o_unsignedDwordToString         0x0028:0x1D42
%define l_memcpyFar                     0x0E72:0x1DF9
%define o_memcpyFar                     0x0028:0x1DF9
%define l_strcat                        0x0E72:0x27F3
%define o_strcat                        0x0028:0x27F3
%define l_strchr                        0x0E72:0x282C
%define o_strchr                        0x0028:0x282C
%define l_strlen                        0x0E72:0x28B5
%define o_strlen                        0x0028:0x28B5
%define l_allocateFarMemory             0x0E72:0x3344
%define o_allocateFarMemory             0x0028:0x3344

%define l_bindMouse                     0x1AB4:0x0082
%define o_bindMouse                     0x0058:0x0082
%define l_bindKey                       0x1AB4:0x0104
%define o_bindKey                       0x0058:0x0104
%define l_tryKeyAndMouseBindings        0x1AB4:0x02A0
%define o_tryKeyAndMouseBindings        0x0058:0x02A0

%define l_setInterfaceRoutineBit        0x1B44:0x00AE
%define o_setInterfaceRoutineBit        0x0068:0x00AE

%define l_eraseCursorIfVisible          0x1B8F:0x0074
%define o_eraseCursorIfVisible          0x0080:0x0074
%define l_setCursorImage                0x1B8F:0x0745
%define o_setCursorImage                0x0080:0x0745
%define l_updateCursorRegion            0x1B8F:0x07AB
%define o_updateCursorRegion            0x0080:0x07AB
%define l_handleCursorInput             0x1B8F:0x0B30
%define o_handleCursorInput             0x0080:0x0B30
%define l_savePixelsAroundCursor        0x1B8F:0x0B70
%define o_savePixelsAroundCursor        0x0080:0x0B70
%define l_drawCursor                    0x1B8F:0x0C70
%define o_drawCursor                    0x0080:0x0C70

%define l_loadXmiSequence               0x1C86:0x174B
%define o_loadXmiSequence               0x0088:0x174B
%define l_playSoundEffect               0x1C86:0x1DB2
%define o_playSoundEffect               0x0088:0x1DB2

%define l_enqueueGridCoords             0x1FCD:0x000C
%define o_enqueueGridCoords             0x00A8:0x000C
%define l_enqueueDrawWithinLimits       0x1FCD:0x00D0
%define o_enqueueDrawWithinLimits       0x00A8:0x00D0
%define l_enqueueDrawBlock              0x1FCD:0x0D3C
%define o_enqueueDrawBlock              0x00A8:0x0D3C

%define l_sinAndCosInterpolated         0x2110:0x0EAE
%define o_sinAndCosInterpolated         0x00B8:0x0EAE

%define l_attack                        0x22FC:0x134B
%define o_attack                        0x00D0:0x134B

%define l_findItemAtCursor              0x2529:0x05E7
%define o_findItemAtCursor              0x00E0:0x05E7
%define l_describeClickedTerrain        0x2529:0x073F
%define o_describeClickedTerrain        0x00E0:0x073F
%define l_talkModeProc                  0x2529:0x0AFB
%define o_talkModeProc                  0x00E0:0x0AFB
%define l_lookModeProc                  0x2529:0x0B19
%define o_lookModeProc                  0x00E0:0x0B19
%define l_useModeProc                   0x2529:0x0C3A
%define o_useModeProc                   0x00E0:0x0C3A

%define l_isItemCharacter               0x28A1:0x0A87
%define o_isItemCharacter               0x00F8:0x0A87

%define l_clearDrawQueue                0x2CAE:0x024A
%define o_clearDrawQueue                0x0110:0x024A
%define l_setupPerspective              0x2CAE:0x039A
%define o_setupPerspective              0x0110:0x039A
%define l_setupViewLimits               0x2CAE:0x05B8
%define o_setupViewLimits               0x0110:0x05B8
%define l_applyViewLimits               0x2CAE:0x1162
%define o_applyViewLimits               0x0110:0x1162

%define l_setPanelState                 0x30D3:0x02C8
%define o_setPanelState                 0x0138:0x02C8

%define l_getExternalizedString         0x3265:0x008E
%define o_getExternalizedString         0x0148:0x008E
%define l_strcat_far                    0x3265:0x090B
%define o_strcat_far                    0x0148:0x090B

%define l_printStringToScroll           0x342C:0x01A0
%define o_printStringToScroll           0x0168:0x01A0

%define l_varArgsEopDispatcher          0x6417:0x0061
%define o_varArgsEopDispatcher          0x02E8:0x0061
%define l_byteArgEopDispatcher          0x6417:0x0066
%define o_byteArgEopDispatcher          0x02E8:0x0066
%define l_byCallSiteEopDispatcher       0x6417:0x006B
%define o_byCallSiteEopDispatcher       0x02E8:0x006B

%define l_changeMapLevel                0x641E:0x00A7
%define o_changeMapLevel                0x02F0:0x00A7

%define l_ark_say                       0x6469:0x003E
%define o_ark_say                       0x0338:0x003E

%define l_exitWithErrorString           0x64D4:0x002A
%define o_exitWithErrorString           0x0390:0x002A

%define l_tryToThrowCursorItem          0x64F7:0x0039
%define o_tryToThrowCursorItem          0x03C8:0x0039
%define l_closeInventoryContainer       0x64F7:0x002F
%define o_closeInventoryContainer       0x03C8:0x002F

%define l_doSpiralingView               0x656A:0x003E
%define o_doSpiralingView               0x0478:0x003E

%define l_trainSkill                    0x6599:0x0057
%define o_trainSkill                    0x04D0:0x0057

; =============================================================================
; structure offsets
; -----------------------------------------------------------------------------

InputState_relativeX                    EQU 0x00
InputState_relativeY                    EQU 0x02
InputState_mouseButton                  EQU 0x06
InputState_context                      EQU 0x08

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

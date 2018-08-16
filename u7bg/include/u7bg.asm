; =============================================================================
; Ultima VII: The Black Gate Hacks -- main
; -----------------------------------------------------------------------------
; by John Glassmyer
; github.com/JohnGlassmyer/UltimaHacks

; =============================================================================
; length of executable to be patched, and of expanded overlay
; -----------------------------------------------------------------------------

%assign ORIGINAL_EXE_LENGTH                     0xA8460

%assign EXPANDED_OVERLAY_1_LENGTH               0x2A00
%assign EOP1_NEW_CODE_START                     0x0D80

%assign EXPANDED_OVERLAY_2_LENGTH               0x2100
%assign EOP2_NEW_CODE_START                     0x0B60

%assign EXE_LENGTH \
		(ORIGINAL_EXE_LENGTH \
				+ EXPANDED_OVERLAY_1_LENGTH + EXPANDED_OVERLAY_2_LENGTH)

; =============================================================================
; segment aliases
; -----------------------------------------------------------------------------

%assign seg_eop1 336
%assign seg_eop2 267
%assign seg_dseg 349

; =============================================================================
; data-segment offsets
; -----------------------------------------------------------------------------

; steal bytes from an unused string in the data segment
%assign dseg_repurposedString                   0x1055
;       dseg_stolenBytes_start                  0x1056
%assign dseg_pn_dragArea                        0x1056
%assign dseg_pn_dropArea                        0x1058
%assign dseg_conversationKeys_mouseEvent        0x105A
%assign dseg_conversationKeys_usedKeyInTextLoop 0x1061
%assign dseg_conversationKeys_optionIndex       0x1062
%assign dseg_conversationKeys_keyCode           0x1063
%assign dseg_pf_castByKeyData                   0x1065
%assign dseg_pf_targetKeysData                  0x1069
%assign dseg_isSelectingFromEopTarget           0x106D
%assign dseg_keepMoving_direction               0x106E
%assign dseg_keepMoving_speed                   0x106F
%assign dseg_divideByZeroTemplate               0x1070
%assign dseg_areBarksSuppressed                 0x1082
%assign dseg_flagNumberPromptString             0x1083
;       dseg_                                   0x1090
;       dseg_stolenBytes_end                    0x1101

%assign dseg_divideByZeroString                 0x05F6
%assign dseg_camera                             0x063E
%assign dseg_screenCenterWorldX                 0x085A
%assign dseg_screenCenterWorldY                 0x085C
%assign dseg_titleString                        0x100E
%assign dseg_versionString                      0x102A
%assign dseg_copyrightString                    0x1032
%assign dseg_shouldExitMainGameLoop             0x100C
%assign dseg_viewport                           0x159E
%assign dseg_pf_voodooXmsBlock                  0x15AE
%assign dseg_originalFreeMemoryStats            0x15BC
%assign dseg_conversationOptionList             0x1E30
%assign dseg_directionForDirectionKey           0x1ED0
%assign dseg_directionForNumberKey              0x1EDB
%assign dseg_isAudioDisabled                    0x1EE5
%assign dseg_movementDirection                  0x1EE6
%assign dseg_tildeString                        0x1EE7
%assign dseg_rightHandedMouseString             0x1EE9
%assign dseg_leftHandedMouseString              0x1EFC
%assign dseg_autorouteIbo                       0x2943
%assign dseg_mouseHand                          0x2974
%assign dseg_partyMemberIbos                    0x3089
%assign dseg_partySize                          0x30B9
%assign dseg_reagentCountForSpell               0x34C6
%assign dseg_spriteManager                      0x350E
%assign dseg_time                               0x351C
%assign dseg_polledKey                          0x368A
%assign dseg_isDialogMode                       0x3705
%assign dseg_isKeyMouseEnabled                  0x3706
%assign dseg_keyMouseXx                         0x3707
%assign dseg_keyMouseY                          0x3709
%assign dseg_previousCtrlStatus                 0x370B
%assign dseg_ctrlStatus                         0x370C
%assign dseg_mouseCursorImageNumber             0x3714
%assign dseg_mouseCursorBaseNumber              0x3718
%assign dseg_yellowTextPrinter                  0x3744
%assign dseg_pn_ProportionalTextPrinter_vtable  0x3773
%assign dseg_currentVehicleIbo                  0x37A2
%assign dseg_shapeManager                       0x380E
%assign dseg_itemTypeClassFlags                 0x4A96
%assign dseg_itemBufferSegment                  0x4B36
%assign dseg_ceilingZ                           0x4B7E
%assign dseg_avatarIbo                          0x4C0C
%assign dseg_conversationOptionCoords           0x643C
%assign dseg_pn_conversationGump                0x64DA
%assign dseg_isHackMoverEnabled                 0x6504
%assign dseg_openItemDialogsList                0x65BC
%assign dseg_pn_worldArea                       0x65D0
%assign dseg_dialogState                        0x65D4
%assign dseg_apn_barkTexts                      0x65D5
%assign dseg_pn_workstring                      0x6E5C
%assign dseg_cheatsEnabled                      0x7776
%assign dseg_mouseXx                            0x7810
%assign dseg_mouseY                             0x7812
%assign dseg_itemTypeInfo                       0x8FA8
%assign dseg_playerActionSuspended              0x9BA8

; =============================================================================
; segments and procedures (for far calls)
; -----------------------------------------------------------------------------

defineAddress   0, 0x0C8F, positionTextCursor
defineAddress   0, 0x1468, sprintf
defineAddress   0, 0x2A4D, strcat
defineAddress   0, 0x31B5, deallocateNearMemory
defineAddress   0, 0x31ED, allocateNearMemory
defineAddress   0, 0x4183, strncat_far

defineAddress   5, 0x07A4, ShapeManager_draw

defineAddress   6, 0x048A, List_bringToFront
defineAddress   6, 0x0540, List_removeAndDestroyAll
defineAddress   6, 0x0577, List_stepForward

defineAddress   7, 0x02B7, TextPrinter_new
defineAddress   7, 0x035F, TextPrinter_printString
defineAddress   7, 0x0E34, getCursorLength

defineAddress   8, 0x01E7, copyFrameBuffer
defineAddress   8, 0x0756, drawWorld

defineAddress  13, 0x0009, isAvatarInCombat

defineAddress  16, 0x0046, debugPrintfAtCoords

defineAddress  23, 0x0F4A, playSoundSimple

defineAddress  34, 0x016F, enqueueMouseEvent

defineAddress  43, 0x0065, generateRandomIntegerInRange

defineAddress  46, 0x007D, findItemInArea
defineAddress  46, 0x00F7, findItemInContainer
defineAddress  46, 0x024C, findItem

defineAddress  47, 0x071F, playAmbientSounds

defineAddress  53, 0x01DB, Timer_set
defineAddress  53, 0x0295, Timer_hasFinished

defineAddress  56, 0x0161, pollKeyAndTranslateWithMouse
defineAddress  56, 0x0178, translateKeyWithMouse
defineAddress  56, 0x02D7, pollKey
defineAddress  56, 0x0316, pollKeyToGlobalDiscarding
defineAddress  56, 0x0361, getCtrlStatus
defineAddress  56, 0x0375, getLeftAndRightShiftStatus
defineAddress  56, 0x0697, getLastMouseState
defineAddress  56, 0x06AD, updateAndGetMouseState
defineAddress  56, 0x06FF, updateAndCopyMouseState
defineAddress  56, 0x07DD, setMouseCursorPosition

defineAddress  57, 0x0676, selectMouseCursor

defineAddress  58, 0x0050, TextPrinter_setFont
defineAddress  58, 0x00C3, TextPrinter_getLineHeight
defineAddress  58, 0x00EF, TextPrinter_determineTextWidth

defineAddress  60, 0x198E, isCursorInBounds

defineAddress  61, 0x01CF, worldCoordsToScreen

defineAddress  64, 0x000C, reportNoCanDo

defineAddress  68, 0x0220, continuePlayingSpeech

defineAddress  70, 0x0040, getItemInSlot

defineAddress  75, 0x0009, compareWorldCoords

defineAddress  86, 0x0149, Item_getXAndY
defineAddress  86, 0x01EB, getItemZAndStuff
defineAddress  86, 0x0AF9, Item_getQuality
defineAddress  86, 0x0A2D, Item_getQuantity
defineAddress  86, 0x11F6, getContainedItem
defineAddress  86, 0x1EAF, placeItemInWorld
defineAddress  86, 0x21B1, getItemBeingDragged
defineAddress  86, 0x2572, Item_greatestDeltaToCoords

defineAddress  89, 0x000D, sprintfMemoryUsage

defineAddress  90, 0x0050, getNpcBufferForIbo
defineAddress  90, 0x0DFF, getNpcIbo
defineAddress  90, 0x0E29, Item_getNpcNumber
defineAddress  90, 0x125A, isNpcUnconscious

defineAddress 108, 0x0009, cyclePalette

defineAddress 177, 0x0006, allocateVoodooMemory

; load-module code segments < 206 <= overlay code segments

defineAddress 212, 0x003E, SpriteManager_playSpriteForItem
defineAddress 212, 0x0052, SpriteManager_barkOnItem

defineAddress 214, 0x0048, getOuterContainer
defineAddress 214, 0x0052, tryToPlaceItem

defineAddress 215, 0x002A, canAvatarReach
defineAddress 215, 0x002F, tryToCastSpell
defineAddress 215, 0x0034, canCastSpell

defineAddress 217, 0x0070, promptForIntegerWord

defineAddress 218, 0x0020, breakOffCombat
defineAddress 218, 0x0025, beginCombat

defineAddress 219, 0x006B, Item_setNpcTarget

defineAddress 234, 0x0020, havePlayerSelect

defineAddress 243, 0x0025, produceItemDisplayName

defineAddress 251, 0x002F, setAudioState

defineAddress 260, 0x0039, doesSpellbookHaveSpell
defineAddress 260, 0x0043, countReagentsInPossession

defineAddress 266, 0x0020, Item_isPartyMember
defineAddress 266, 0x0039, use
defineAddress 266, 0x003E, Item_canBeOpened

defineAddress seg_eop2, 0x0061, eop2_entry_varArgsDispatcher
defineAddress seg_eop2, 0x0066, eop2_entry_2
defineAddress seg_eop2, 0x006B, eop2_entry_3

defineAddress 272, 0x0020, determineBulkOfContents
defineAddress 272, 0x0025, determineWeightOfContents
defineAddress 272, 0x002F, getItemTypeBulk
defineAddress 272, 0x0034, Item_getWeight
defineAddress 272, 0x0039, getItemTypeWeight

defineAddress 322, 0x0048, usecode_getListNode

defineAddress 323, 0x0057, lookupLinkdep1

defineAddress 326, 0x0020, FarString_showInConversation
defineAddress 326, 0x0048, FarString_destructor
defineAddress 326, 0x004D, FarString_new

defineAddress seg_eop1, 0x00B1, eop1_entry_varArgsDispatcher
defineAddress seg_eop1, 0x00B6, eop1_entry_2
defineAddress seg_eop1, 0x00BB, eop1_entry_3

defineAddress 337, 0x0025, beginConversation
defineAddress 337, 0x0043, endConversation

defineAddress 339, 0x009D, AbstractInventoryDialog_destructor
defineAddress 339, 0x00AC, Control_setInvisible
defineAddress 339, 0x00CF, Control_isVisible
defineAddress 339, 0x00F2, List_insertNewNodeAtTail

defineAddress 340, 0x0043, startAndLoopNumberedDialog
defineAddress 340, 0x0075, updateOpenInventoryDialogs
defineAddress 340, 0x007A, getOpenItemDialogListNode
defineAddress 340, 0x0084, itemDialogInputLoop
defineAddress 340, 0x0089, dragItem
defineAddress 340, 0x0093, dropDraggedItem
defineAddress 340, 0x009D, redrawDialogs
defineAddress 340, 0x00A7, displayItemDialog
defineAddress 340, 0x00B6, startNumberedDialog

defineAddress 344, 0x0057, doYesNoDialog

defineAddress 347, 0x0025, Slider_stepDown
defineAddress 347, 0x0020, Slider_stepUp
defineAddress 347, 0x002A, Slider_processInput

; =============================================================================
; enumerations
; -----------------------------------------------------------------------------

%assign DialogState_NONE                0
%assign DialogState_INVENTORY           1
%assign DialogState_SHOW_SAVE           2
%assign DialogState_WORLD               5
%assign DialogState_CLOSE_ALL           6

%assign InventorySlot_BACK              0
%assign InventorySlot_LEFT_HAND         1
%assign InventorySlot_RIGHT_HAND        2
%assign InventorySlot_SIDEARM           3
%assign InventorySlot_NECK              4
%assign InventorySlot_TORSO             5
%assign InventorySlot_LEFT_FINGER       6
%assign InventorySlot_RIGHT_FINGER      7
%assign InventorySlot_QUIVER            8
%assign InventorySlot_HEAD              9
%assign InventorySlot_LEGS             10
%assign InventorySlot_FEET             11
%assign InventorySlot_BACKPACKS        12

%assign ItemType_SPELLBOOK            761

%assign MouseCursor_FINGER              0

%assign Sound_OPEN_DIALOG              14
%assign Sound_FIZZLE                   69
%assign Sound_CAN_NOT                  76

%assign TextDisplayType_BOOK           642
%assign TextDisplayType_SCROLL         797

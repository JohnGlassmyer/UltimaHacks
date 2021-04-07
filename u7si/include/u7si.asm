; =============================================================================
; Ultima VII: Serpent Isle Hacks -- main
; -----------------------------------------------------------------------------
; by John Glassmyer
; github.com/JohnGlassmyer/UltimaHacks

; =============================================================================
; length of executable to be patched, and of expanded overlay
; -----------------------------------------------------------------------------

%assign ORIGINAL_EXE_LENGTH                     0xB8240

%assign EXPANDED_OVERLAY_1_LENGTH               0x2200
%assign EOP1_NEW_CODE_START                     0x0520

%assign EXPANDED_OVERLAY_2_LENGTH               0x2400
%assign EOP2_NEW_CODE_START                     0x0B60

%assign EXE_LENGTH \
		(ORIGINAL_EXE_LENGTH \
				+ EXPANDED_OVERLAY_1_LENGTH + EXPANDED_OVERLAY_2_LENGTH)

; =============================================================================
; segment aliases
; -----------------------------------------------------------------------------

%assign seg_eop1 331
%assign seg_eop2 250
%assign seg_dseg 365

; =============================================================================
; data-segment offsets
; -----------------------------------------------------------------------------

; steal bytes from an unused string in the data segment
%assign dseg_repurposedString                   0x0A1B
;       dseg_stolenBytes_start                  0x0A1C
%assign dseg_pn_dragArea                        0x0A1C
%assign dseg_pn_dropArea                        0x0A1E
%assign dseg_conversationKeys_mouseEvent        0x0A20
%assign dseg_conversationKeys_usedKeyInTextLoop 0x0A27
%assign dseg_conversationKeys_optionIndex       0x0A28
%assign dseg_conversationKeys_keyCode           0x0A29
%assign dseg_pf_castByKeyData                   0x0A2B
%assign dseg_pf_targetKeysData                  0x0A2F
%assign dseg_isSelectingFromEopTarget           0x0A33
%assign dseg_keepMoving_direction               0x0A34
%assign dseg_keepMoving_speed                   0x0A35
%assign dseg_divideByZeroTemplate               0x0A36
%assign dseg_areBarksSuppressed                 0x0A48
%assign dseg_flagNumberPromptString             0x0A49
;       dseg_                                   0x0A56
;       dseg_stolenBytes_end                    0x0ADD

%assign dseg_divideByZeroString                 0x0635
%assign dseg_camera                             0x067E
%assign dseg_mapThing                           0x0683
%assign dseg_screenCenterWorldX                 0x089A
%assign dseg_screenCenterWorldY                 0x089C
%assign dseg_titleString                        0x09BE
%assign dseg_versionString                      0x09ED
%assign dseg_copyrightString                    0x09FE
%assign dseg_shouldExitMainGameLoop             0x09BC
%assign dseg_viewport                           0x0D7C
%assign dseg_pf_voodooXmsBlock                  0x0D8C
%assign dseg_originalFreeMemoryStats            0x0D9A
%assign dseg_directionForDirectionKey           0x1728
%assign dseg_isAudioDisabled                    0x173D
%assign dseg_movementDirection                  0x173E
%assign dseg_tildeString                        0x173F
%assign dseg_autorouteIbo                       0x178D
%assign dseg_partyMemberIbos                    0x1E43
%assign dseg_partySize                          0x1E73
%assign dseg_frameLimiterEnabled                0x208A
%assign dseg_prevFrameTime                      0x208B
%assign dseg_reagentCountForSpell               0x20A9
%assign dseg_spriteManager                      0x20F2
%assign dseg_yellowTextPrinter                  0x21B0
%assign dseg_pn_ProportionalTextPrinter_vtable  0x21EB
%assign dseg_isPlayerControlDisabled            0x2216
%assign dseg_currentVehicleIbo                  0x221A
%assign dseg_shapeManager                       0x2288
%assign dseg_emptyString                        0x2CB8
%assign dseg_itemTypeClassFlags                 0x2CD4
%assign dseg_itemBufferSegment                  0x2D74
%assign dseg_ceilingZ                           0x2DDA
%assign dseg_avatarIbo                          0x2E68
%assign dseg_conversationOptionList             0x468E
%assign dseg_conversationOptionCoords           0x49FC
%assign dseg_pn_conversationGump                0x4A84
%assign dseg_isHackMoverEnabled                 0x4AAE
%assign dseg_openItemDialogsList                0x4B72
%assign dseg_pn_worldArea                       0x4B86
%assign dseg_dialogState                        0x4B8A
%assign dseg_apn_barkTexts                      0x4B8B
%assign dseg_heyWeGotMoreThanSix                0x49CD
%assign dseg_mouseHand                          0x61EA
%assign dseg_time                               0x6203
%assign dseg_mouseCursorImageNumber             0x6222
%assign dseg_mouseCursorBaseNumber              0x6226
%assign dseg_polledKey                          0x6258
%assign dseg_isDialogMode                       0x62D3
%assign dseg_isKeyMouseEnabled                  0x62D4
%assign dseg_keyMouseXx                         0x62D5
%assign dseg_keyMouseY                          0x62D7
%assign dseg_previousCtrlStatus                 0x62D9
%assign dseg_ctrlStatus                         0x62DA
%assign dseg_isKeyMouseClicking                 0x62DB
%assign dseg_pn_workstring                      0x62DC
%assign dseg_cheatsEnabled                      0x6BD8
%assign dseg_itemTypeInfo                       0x7E6E
%assign dseg_playerActionSuspended              0x8A72
%assign dseg_mouseXx                            0x8BE2
%assign dseg_mouseY                             0x8BE4

; =============================================================================
; procedure addresses (for far calls)
; -----------------------------------------------------------------------------

defineAddress   0, 0x0CB8, positionTextCursor
defineAddress   0, 0x1491, sprintf
defineAddress   0, 0x2B42, strcat
defineAddress   0, 0x32AA, deallocateNearMemory
defineAddress   0, 0x32E2, allocateNearMemory
defineAddress   0, 0x41EF, strcpy_far
defineAddress   0, 0x4278, strncat_far

defineAddress   4, 0x07A0, ShapeManager_draw

defineAddress   5, 0x0486, List_bringToFront
defineAddress   5, 0x053C, List_removeAndDestroyAll
defineAddress   5, 0x0573, List_stepForward

defineAddress   6, 0x035E, TextPrinter_new
defineAddress   6, 0x0406, TextPrinter_printString
defineAddress   6, 0x14DE, getCursorLength

defineAddress   7, 0x0208, copyFrameBuffer
defineAddress   7, 0x0532, drawWorld

defineAddress  11, 0x0042, debugPrintfAtCoords
defineAddress  11, 0x011E, debugPromptfAtCoords

defineAddress  16, 0x0F96, playSoundSimple

defineAddress  29, 0x0076, findItemInArea
defineAddress  29, 0x00F0, findItemInContainer
defineAddress  29, 0x0245, findItem

defineAddress  34, 0x004F, TextPrinter_setFont
defineAddress  34, 0x00C2, TextPrinter_getLineHeight
defineAddress  34, 0x00EE, TextPrinter_determineTextWidth

defineAddress  36, 0x19EF, isCursorInBounds

defineAddress  37, 0x01CB, worldCoordsToScreen

defineAddress  40, 0x000A, reportNoCanDo

defineAddress  43, 0x003A, getItemInSlot

defineAddress  47, 0x000F, compareWorldCoords

defineAddress  59, 0x014E, Item_getXAndY
defineAddress  59, 0x01F0, getItemZAndStuff
defineAddress  59, 0x0A32, Item_getQuantity
defineAddress  59, 0x0AFE, Item_getQuality
defineAddress  59, 0x11FB, getContainedItem
defineAddress  59, 0x1EB4, placeItemInWorld
defineAddress  59, 0x21B6, getItemBeingDragged
defineAddress  59, 0x2577, Item_greatestDeltaToCoords

defineAddress  63, 0x0000, sprintfMemoryUsage

defineAddress  64, 0x0053, getNpcBufferForIbo
defineAddress  64, 0x0E79, getNpcIbo
defineAddress  64, 0x0EA3, Item_getNpcNumber
defineAddress  64, 0x12D4, isNpcUnconscious

defineAddress  92, 0x0000, cyclePalette

defineAddress 102, 0x000A, CombatStatus_new

defineAddress 108, 0x05D4, playAmbientSounds

defineAddress 113, 0x016B, enqueueMouseEvent

defineAddress 117, 0x01EC, Timer_set
defineAddress 117, 0x02A0, Timer_hasFinished

defineAddress 118, 0x067D, selectMouseCursor

defineAddress 119, 0x0168, pollKeyAndTranslateWithMouse
defineAddress 119, 0x017F, translateKeyWithMouse
defineAddress 119, 0x02E8, pollKey
defineAddress 119, 0x0327, pollKeyToGlobalDiscarding
defineAddress 119, 0x0372, getCtrlStatus
defineAddress 119, 0x0386, getLeftAndRightShiftStatus
defineAddress 119, 0x06A8, getLastMouseState
defineAddress 119, 0x06BE, updateAndGetMouseState
defineAddress 119, 0x0710, updateAndCopyMouseState
defineAddress 119, 0x07EE, setMouseCursorPosition

defineAddress 176, 0x0000, allocateVoodooMemory

; load-module segments < 207 <= overlay segments

defineAddress 210, 0x003E, SpriteManager_playSpriteForItem
defineAddress 210, 0x0052, SpriteManager_barkOnItem

defineAddress 212, 0x0048, getOuterContainer
defineAddress 212, 0x0052, tryToPlaceItem

defineAddress 213, 0x002A, canAvatarReach
defineAddress 213, 0x002F, tryToCastSpell
defineAddress 213, 0x0039, canCastSpell

defineAddress 214, 0x007A, promptForIntegerWord

defineAddress 223, 0x0025, havePlayerSelect

defineAddress 227, 0x0020, produceItemDisplayName

defineAddress 235, 0x002F, setAudioState

defineAddress 241, 0x0039, doesSpellbookHaveSpell
defineAddress 241, 0x0043, countReagentsInPossession

defineAddress 244, 0x002F, getDisplayText

defineAddress 249, 0x0020, Item_isPartyMember
defineAddress 249, 0x0039, use
defineAddress 249, 0x003E, Item_canBeOpened

defineAddress seg_eop2, 0x0061, eop2_entry_varArgsDispatcher
defineAddress seg_eop2, 0x0066, eop2_entry_byteArgDispatcher
defineAddress seg_eop2, 0x006B, eop2_entry3

defineAddress 255, 0x0020, determineBulkOfContents
defineAddress 255, 0x0025, determineWeightOfContents
defineAddress 255, 0x002F, getItemTypeBulk
defineAddress 255, 0x0034, Item_getWeight
defineAddress 255, 0x0039, getItemTypeWeight

defineAddress 299, 0x002A, runUsecode

defineAddress 301, 0x0048, usecode_getListNode

defineAddress 302, 0x0057, lookupLinkdep1

defineAddress 305, 0x0020, FarString_showInConversation
defineAddress 305, 0x0048, FarString_destructor
defineAddress 305, 0x004D, FarString_new

defineAddress 323, 0x0025, beginConversation
defineAddress 323, 0x006B, endConversation

defineAddress 325, 0x00B1, AbstractInventoryDialog_destructor
defineAddress 325, 0x00C0, Control_setInvisible
defineAddress 325, 0x00E3, Control_isVisible
defineAddress 325, 0x0106, List_insertNewNodeAtTail

defineAddress 326, 0x0043, startAndLoopNumberedDialog
defineAddress 326, 0x0075, updateOpenInventoryDialogs
defineAddress 326, 0x007A, getOpenItemDialogListNode
defineAddress 326, 0x0084, itemDialogInputLoop
defineAddress 326, 0x0089, redrawDialogs
defineAddress 326, 0x0098, startNumberedDialog

defineAddress 327, 0x0020, dragItem
defineAddress 327, 0x0025, dropDraggedItem
defineAddress 327, 0x002F, displayItemDialog

defineAddress seg_eop1, 0x0061, eop1_entry_varArgsDispatcher
defineAddress seg_eop1, 0x0066, eop1_entry_byteArgDispatcher
defineAddress seg_eop1, 0x006B, eop1_entry3

defineAddress 333, 0x0057, doYesNoDialog

defineAddress 337, 0x0020, Slider_stepUp
defineAddress 337, 0x0025, Slider_stepDown
defineAddress 337, 0x002A, Slider_processInput

defineAddress 347, 0x0020, breakOffCombat
defineAddress 347, 0x0025, beginCombat

defineAddress 348, 0x0070, Item_setNpcTarget

defineAddress 353, 0x003E, isAvatarInCombat

; =============================================================================
; enumerations
; -----------------------------------------------------------------------------

%assign DialogState_NONE                0
%assign DialogState_INVENTORY           1
%assign DialogState_SHOW_SAVE           2
%assign DialogState_SHOW_COMBAT_STATUS  3
%assign DialogState_WORLD               6
%assign DialogState_CLOSE_ALL           7

%assign Font_BLACK_OPHIDIAN             8
%assign Font_WHITE_OPHIDIAN_OUTLINE     9
%assign Font_YELLOW_OPHIDIAN_OUTLINE    10

%assign InventorySlot_LEFT_HAND         0
%assign InventorySlot_RIGHT_HAND        1
%assign InventorySlot_2                 2
%assign InventorySlot_NECK              3
%assign InventorySlot_HEAD              4
%assign InventorySlot_HANDS             5
%assign InventorySlot_USECODE_CONTAINER 6
%assign InventorySlot_LEFT_FINGER       7
%assign InventorySlot_RIGHT_FINGER      8
%assign InventorySlot_EARS              9
%assign InventorySlot_10                10
%assign InventorySlot_BELT              11
%assign InventorySlot_TORSO             12
%assign InventorySlot_FEET              13
%assign InventorySlot_LEGS              14
%assign InventorySlot_BACKPACK          15
%assign InventorySlot_LEFT_BACK         16
%assign InventorySlot_RIGHT_BACK        17

%assign ItemType_SPELLBOOK              761
%assign ItemType_KEYRING                485
%assign ItemType_MAGIC_SCROLL           715

%assign MouseCursor_FINGER              0

%assign ShapeNumber_MAGIC_SCROLL_BASE   1489

%assign Sound_CAN_NOT                   43
%assign Sound_FIZZLE                    48
%assign Sound_OPEN_DIALOG               94

%assign TextDisplayType_BOOK            642
%assign TextDisplayType_OPHIDIAN_BOOK   705
%assign TextDisplayType_OPHIDIAN_SCROLL 707
%assign TextDisplayType_SCROLL          797

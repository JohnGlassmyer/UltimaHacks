; =============================================================================
; Ultima VII: The Black Gate Hacks -- main
; -----------------------------------------------------------------------------
; by John Glassmyer
; github.com/JohnGlassmyer/UltimaHacks

; assuming that overlay 343 is expanded:
; java -jar UltimaPatcher.jar --exe=U7.EXE --expand-overlay=343,0x2000 (...)

; =============================================================================
; length of executable to be patched, and of expanded overlay
; -----------------------------------------------------------------------------

ORIGINAL_EXE_LENGTH                     EQU 0xA8460
EXPANDED_OVERLAY_LENGTH                 EQU 0x2000
EXE_LENGTH                              EQU ORIGINAL_EXE_LENGTH \
                                            + EXPANDED_OVERLAY_LENGTH
EOP_ORIGINAL_CODE_LENGTH                EQU 0x0520

EOP_START_IN_FILE                       EQU ORIGINAL_EXE_LENGTH

; =============================================================================
; data-segment offsets
; -----------------------------------------------------------------------------

dseg_titleStringOffset                  EQU 0x1000
dseg_versionStringOffset                EQU 0x1002
dseg_copyrightStringOffset              EQU 0x1004
dseg_shouldExitMainGameLoop             EQU 0x100C
dseg_voodooAllocationThing              EQU 0x15AE
dseg_originalFreeMemoryStats            EQU 0x15BC
dseg_isAudioDisabled                    EQU 0x1EE5
dseg_tildeString                        EQU 0x1EE7
dseg_rightHandedMouseString             EQU 0x1EE9
dseg_leftHandedMouseString              EQU 0x1EFC
dseg_mouseHand                          EQU 0x2974
dseg_partyMemberIbos                    EQU 0x3089
dseg_partySize                          EQU 0x30B9
dseg_graphicsThing                      EQU 0x350E
dseg_timeLow                            EQU 0x351C
dseg_timeHigh                           EQU 0x351E
dseg_polledKey                          EQU 0x368A
dseg_isDialogMode                       EQU 0x3705
dseg_isKeyMouseEnabled                  EQU 0x3706
dseg_keyMouseXxPosition                 EQU 0x3707
dseg_keyMouseYPosition                  EQU 0x3709
dseg_itemBufferSegment                  EQU 0x4B36
dseg_avatarIbo                          EQU 0x4C0C
dseg_hackMoverEnabled                   EQU 0x6504
dseg_dialogState                        EQU 0x65D4
dseg_workstring                         EQU 0x6E5C
dseg_cheatsEnabled                      EQU 0x7776
dseg_mouseXxPosition                    EQU 0x7810
dseg_mouseYPosition                     EQU 0x7812
dseg_itemTypeInfo                       EQU 0x8FA9
dseg_playerActionSuspended              EQU 0x9BA8

; =============================================================================
; segments and procedures (for far calls)
; -----------------------------------------------------------------------------

defineSegment 0, 0x0000, 0x0000
defineAddress 0, 0x1468, sprintf
defineAddress 0, 0x2A4D, strcat
defineAddress 0, 0x2A86, strchr
defineAddress 0, 0x2ABC, strcmp
defineAddress 0, 0x31B5, deallocateNearMemory
defineAddress 0, 0x31ED, allocateNearMemory

defineSegment 6, 0x0030, 0x0890
defineAddress 6, 0x0540, list_removeAndDestroyAll
defineAddress 6, 0x0577, list_stepForward

defineSegment 13, 0x0068, 0x0CBD
defineAddress 13, 0x0009, isAvatarInCombatMode

defineSegment 23, 0x00B8, 0x0DBF
defineAddress 23, 0x0F4A, playSoundSimple

defineSegment 46, 0x0170, 0x19BF
defineAddress 46, 0x00F7, findItemInContainer
defineAddress 46, 0x024C, findItem

defineSegment 56, 0x01C0, 0x1C3E
defineAddress 56, 0x0161, translateKeyWithoutDialogs
defineAddress 56, 0x02D7, pollKey
defineAddress 56, 0x0316, pollKeyToGlobalDiscarding
defineAddress 56, 0x0361, getCtrlStatus
defineAddress 56, 0x0375, getLeftAndRightShiftStatus
defineAddress 56, 0x06FF, readMouseStateIntoRef

defineSegment 57, 0x01C8, 0x1CCF
defineAddress 57, 0x0676, selectMouseCursor

defineSegment 60, 0x01E0, 0x1DE8
defineAddress 60, 0x198E, isCursorInBounds

defineSegment 64, 0x0200, 0x20D2
defineAddress 64, 0x000C, reportNoCanDo

defineSegment 70, 0x0230, 0x21F0
defineAddress 70, 0x0040, getItemInSlot

defineSegment 85, 0x02A8, 0x2807
defineAddress 85, 0x003B, getItemXCoordinate
defineAddress 85, 0x00C2, getItemYCoordinate
defineAddress 85, 0x0AF9, Item_getQuality
defineAddress 85, 0x0A2D, Item_getQuantity
defineAddress 85, 0x21B1, getItemBeingDragged

defineSegment 43, 0x0158, 0x19AA
defineAddress 43, 0x0065, generateRandomIntegerInRange

defineSegment 89, 0x02C8, 0x2BE2
defineAddress 89, 0x000D, sprintfMemoryUsage

defineSegment 90, 0x02D0, 0x2BEB
defineAddress 90, 0x0DFF, getNpcIbo
defineAddress 90, 0x0050, getNpcBufferForIbo
defineAddress 90, 0x125A, isNpcUnconscious

defineSegment 137, 0x0448, 0x3916
defineAddress 137, 0x0028, allocateFarMemory

defineSegment 177, 0x0588, 0x3AB8
defineAddress 177, 0x0006, allocateVoodooMemory

; load-module code segments < 206 <= overlay code segments

defineSegment 212, 0x06A0, 0x3D04
defineAddress 212, 0x0052, barkOnItemInWorld

defineSegment 214, 0x06B0, 0x3D0E
defineAddress 214, 0x0048, getOuterContainer
defineAddress 214, 0x0052, tryToPlaceItem

defineSegment 215, 0x06B8, 0x3D16
defineAddress 215, 0x0034, canCastSpell
defineAddress 215, 0x002F, tryToCastSpell

defineSegment 218, 0x06D0, 0x3D2A
defineAddress 218, 0x0020, breakOffCombat
defineAddress 218, 0x0025, beginCombat

defineSegment 234, 0x0750, 0x3D7E
defineAddress 234, 0x0020, havePlayerSelect

defineSegment 243, 0x0798, 0x3DAA
defineAddress 243, 0x0025, produceItemDisplayName

defineSegment 251, 0x07D8, 0x3DDA
defineAddress 251, 0x002F, setAudioState

defineSegment 260, 0x0820, 0x3E01
defineAddress 260, 0x0039, doesSpellbookHaveSpell

defineSegment 265, 0x0848, 0x3E19
defineAddress 265, 0x0020, reactToItemMovement

defineSegment 266, 0x0850, 0x3E20
defineAddress 266, 0x0039, use

defineSegment 272, 0x0880, 0x3E45
defineAddress 272, 0x0020, determineBulkOfContents
defineAddress 272, 0x0025, determineWeightOfContents
defineAddress 272, 0x002F, getItemTypeBulk
defineAddress 272, 0x0034, determineWeightWithQuantity

defineSegment 315, 0x09D8, 0x3ECD
defineAddress 315, 0x002A, runUsecode

defineSegment 322, 0x0A10, 0x3EF8
defineAddress 322, 0x0048, unicode_getListNode

defineSegment 326, 0x0A30, 0x3F13
defineAddress 326, 0x0020, FarString_showInConversation
defineAddress 326, 0x0034, FarString_append
defineAddress 326, 0x0048, FarString_destructor
defineAddress 326, 0x004D, FarString_new

defineSegment 337, 0x0A88, 0x3F57
defineAddress 337, 0x0025, beginConversation
defineAddress 337, 0x0043, endConversation

defineSegment 339, 0x0A98, 0x3F68
defineAddress 339, 0x009D, dragItem_secondDesctructor ; TODO: better name
defineAddress 339, 0x00AC, Control_setInvisible
defineAddress 339, 0x00B1, Control_setVisible
defineAddress 339, 0x00CF, Control_isVisible
defineAddress 339, 0x00F2, insertNewNodeAtTail

defineSegment 340, 0x0AA0, 0x3F7B
defineAddress 340, 0x0043, startDialogLoopWithDialogType
defineAddress 340, 0x0048, startDialogLoopWithIboRef
defineAddress 340, 0x007A, getOpenItemDialogListNode
defineAddress 340, 0x0084, itemDialogInputLoop
defineAddress 340, 0x009D, redrawDialogs
defineAddress 340, 0x00A7, displayItemDialog
defineAddress 340, 0x00B6, startDialogMode

defineSegment 343, 0x0AB8, 0x3FA4, eop
defineAddress 343, 0x0061, eopDispatcher

defineSegment 344, 0x0AC0, 0x3FAB
defineAddress 344, 0x0057, doYesNoDialog

defineSegment 347, 0x0AD8, 0x3FBA
defineAddress 347, 0x0025, Slider_stepDown
defineAddress 347, 0x0020, Slider_stepUp
defineAddress 347, 0x002A, Slider_processInput

defineSegment 349, 0x0AE8, 0x3FC8, dseg

; =============================================================================
; enumerations
; -----------------------------------------------------------------------------

InventorySlot_BACKPACK                  EQU 0
InventorySlot_LEFT_HAND                 EQU 1
InventorySlot_RIGHT_HAND                EQU 2

MouseCursor_Finger                      EQU 0

; =============================================================================
; structure offsets
; -----------------------------------------------------------------------------

MouseState_button                       EQU 1
MouseState_action                       EQU 7

List_SIZE                               EQU 4
List_head                               EQU 0
List_tail                               EQU 2

ListNode_next                           EQU 0
ListNode_prev                           EQU 2
ListNode_payload                        EQU 6

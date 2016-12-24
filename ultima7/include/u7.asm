; my convention: "ibo" for "item-buffer offset"
; (which I think the game's developers called a "ref")

; size of executable file to be patched
EXPANDED_OVERLAY_U7_EXE_LENGTH          EQU 0xB771E

; file offsets

off_dseg_segmentZero                    EQU 0x44C80

; dseg offsets

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

; proc addresses
;   l_xxx: call from load module
;   o_xxx: call from overlay
%define l_sprintf                       0x0000:0x1468
%define o_sprintf                       0x0000:0x1468
%define l_strcat                        0x0000:0x2A4D
%define o_strcat                        0x0000:0x2A4D
%define l_strchr                        0x0000:0x2A86
%define o_strchr                        0x0000:0x2A86
%define l_strcmp                        0x0000:0x2ABC
%define o_strcmp                        0x0000:0x2ABC
%define l_deallocateNearMemory          0x0000:0x31B5
%define o_deallocateNearMemory          0x0000:0x31B5
%define l_allocateNearMemory            0x0000:0x31ED
%define o_allocateNearMemory            0x0000:0x31ED

%define l_list_removeAndDestroyAll      0x0890:0x0540
%define o_list_removeAndDestroyAll      0x0030:0x0540
%define l_list_stepForward              0x0890:0x0577
%define o_list_stepForward              0x0030:0x0577

%define l_isAvatarInCombatMode          0x0CBD:0x0009
%define o_isAvatarInCombatMode          0x0068:0x0009

%define l_playSoundSimple               0x0DBF:0x0F4A
%define o_playSoundSimple               0x00B8:0x0F4A

%define l_findItemInContainer           0x19BF:0x00F7
%define o_findItemInContainer           0x0170:0x00F7
%define l_findItem                      0x19BF:0x024C
%define o_findItem                      0x0170:0x024C

%define l_translateKeyWithoutDialogs    0x1C3E:0x0161
%define o_translateKeyWithoutDialogs    0x01C0:0x0161
%define l_pollKey                       0x1C3E:0x02D7
%define o_pollKey                       0x01C0:0x02D7
%define l_pollKeyToGlobalDiscarding     0x1C3E:0x0316
%define o_pollKeyToGlobalDiscarding     0x01C0:0x0316
%define l_getCtrlStatus                 0x1C3E:0x0361
%define o_getCtrlStatus                 0x01C0:0x0361
%define l_getLeftAndRightShiftStatus    0x1C3E:0x0375
%define o_getLeftAndRightShiftStatus    0x01C0:0x0375
%define l_readMouseStateIntoRef         0x1C3E:0x06FF
%define o_readMouseStateIntoRef         0x01C0:0x06FF

%define l_selectMouseCursor             0x1CCF:0x0676
%define o_selectMouseCursor             0x01C8:0x0676

%define l_isCursorInBounds              0x1DE8:0x198E
%define o_isCursorInBounds              0x01E0:0x198E

%define l_reportNoCanDo                 0x20D2:0x000C
%define o_reportNoCanDo                 0x0200:0x000C

%define l_getItemInSlot                 0x21F0:0x0040
%define o_getItemInSlot                 0x0230:0x0040

%define l_getItemXCoordinate            0x2807:0x003B
%define o_getItemXCoordinate            0x02A8:0x003B
%define l_getItemYCoordinate            0x2807:0x00C2
%define o_getItemYCoordinate            0x02A8:0x00C2
%define l_Item_getQuality               0x2807:0x0AF9
%define o_Item_getQuality               0x02A8:0x0AF9
%define l_Item_getQuantity              0x2807:0x0A2D
%define o_Item_getQuantity              0x02A8:0x0A2D
%define l_getItemBeingDragged           0x2807:0x21B1
%define o_getItemBeingDragged           0x02A8:0x21B1

%define l_generateRandomIntegerInRange  0x19AA:0x0065
%define o_generateRandomIntegerInRange  0x0158:0x0065

%define l_sprintfMemoryUsage            0x2BE2:0x000D
%define o_sprintfMemoryUsage            0x02C8:0x000D

%define l_getNpcIbo                     0x2BEB:0x0DFF
%define o_getNpcIbo                     0x02D0:0x0DFF
%define l_getNpcBufferForIbo            0x2BEB:0x0050
%define o_getNpcBufferForIbo            0x02D0:0x0050
%define l_isNpcUnconscious              0x2BEB:0x125A
%define o_isNpcUnconscious              0x02D0:0x125A

%define l_allocateFarMemory             0x3916:0x0028
%define o_allocateFarMemory             0x0448:0x0028

%define l_allocateVoodooMemory          0x3AB8:0x0006
%define o_allocateVoodooMemory          0x0588:0x0006

%define l_reactToItemMovement           0x3E19:0x0020
%define o_reactToItemMovement           0x0848:0x0020

%define l_determineBulkOfContents       0x3E45:0x0020
%define o_determineBulkOfContents       0x0880:0x0020
%define l_determineWeightOfContents     0x3E45:0x0025
%define o_determineWeightOfContents     0x0880:0x0025
%define l_getItemTypeBulk               0x3E45:0x002F
%define o_getItemTypeBulk               0x0880:0x002F
%define l_determineWeightWithQuantity   0x3E45:0x0034
%define o_determineWeightWithQuantity   0x0880:0x0034

%define l_runUsecode                    0x3ECD:0x002A
%define l_startDialogLoopWithDialogType 0x3F7B:0x0043
%define o_startDialogLoopWithDialogType 0x0AA0:0x0043
%define l_startDialogLoopWithIboRef     0x3F7B:0x0048
%define o_startDialgoLoopWithIboRef     0x0AA0:0x0048
%define l_displayItemDialog             0x3F7B:0x00A7
%define o_displayItemDialog             0x0AA0:0x00A7

%define l_barkOnItemInWorld             0x3D04:0x0052
%define o_barkOnItemInWorld             0x06A0:0x0052

%define l_getOuterContainer             0x3D0E:0x0048
%define o_getOuterContainer             0x06B0:0x0048
%define l_tryToPlaceItem                0x3D0E:0x0052
%define o_tryToPlaceItem                0x06B0:0x0052

%define l_canCastSpell                  0x3D16:0x0034
%define o_canCastSpell                  0x06B8:0x0034
%define l_tryToCastSpell                0x3D16:0x002F
%define o_tryToCastSpell                0x06B8:0x002F

%define l_breakOffCombat                0x3D2A:0x0020
%define o_breakOffCombat                0x06D0:0x0020
%define l_beginCombat                   0x3D2A:0x0025
%define o_beginCombat                   0x06D0:0x0025

%define l_havePlayerSelect              0x3D7E:0x0020
%define o_havePlayerSelect              0x0750:0x0020

%define l_produceItemDisplayName        0x3DAA:0x0025
%define o_produceItemDisplayName        0x0798:0x0025

%define l_setAudioState                 0x3DDA:0x002F
%define o_setAudioState                 0x07D8:0x002F

%define l_doesSpellbookHaveSpell        0x3E01:0x0039
%define o_doesSpellbookHaveSpell        0x0820:0x0039

%define l_use                           0x3E20:0x0039
%define o_use                           0x0850:0x0039

%define l_unicode_getListNode           0x3EF8:0x0048
%define o_unicode_getListNode           0x0A10:0x0048

%define l_FarString_showInConversation  0x3F13:0x0020
%define o_FarString_showInConversation  0x0A30:0x0020
%define l_FarString_append              0x3F13:0x0034
%define o_FarString_append              0x0A30:0x0034
%define l_FarString_destructor          0x3F13:0x0048
%define o_FarString_destructor          0x0A30:0x0048
%define l_FarString_new                 0x3F13:0x004D
%define o_FarString_new                 0x0A30:0x004D

%define l_beginConversation             0x3F57:0x0025
%define o_beginConversation             0x0A88:0x0025
%define l_endConversation               0x3F57:0x0043
%define o_endConversation               0x0A88:0x0043

%define l_Control_setInvisible          0x3F68:0x00AC
%define o_Control_setInvisible          0x0A98:0x00AC
%define l_Control_setVisible            0x3F68:0x00B1
%define o_Control_setVisible            0x0A98:0x00B1
%define l_Control_isVisible             0x3F68:0x00CF
%define o_Control_isVisible             0x0A98:0x00CF
%define l_insertNewNodeAtTail           0x3F68:0x00F2
%define o_insertNewNodeAtTail           0x0A98:0x00F2

%define l_getOpenItemDialogListNode     0x3F7B:0x007A
%define o_getOpenItemDialogListNode     0x0AA0:0x007A
%define l_itemDialogInputLoop           0x3F7B:0x0084
%define o_itemDialogInputLoop           0x0AA0:0x0084
%define l_redrawDialogs                 0x3F7B:0x009D
%define o_redrawDialogs                 0x0AA0:0x009D
%define l_displayItemDialog             0x3F7B:0x00A7
%define o_displayItemDialog             0x0AA0:0x00A7
%define l_startDialogMode               0x3F7B:0x00B6
%define o_startDialogMode               0x0AA0:0x00B6

%define l_doYesNoDialog                 0x3FAB:0x0057
%define o_doYesNoDialog                 0x0AC0:0x0057

%define l_Slider_stepDown               0x3FBA:0x0025
%define o_Slider_stepDown               0x0AD8:0x0025
%define l_Slider_stepUp                 0x3FBA:0x0020
%define o_Slider_stepUp                 0x0AD8:0x0020
%define l_Slider_processInput           0x3FBA:0x002A
%define o_Slider_processInput           0x0AD8:0x002A

; expanded overlay procedure dispatcher
%define l_eopDispatcher                 0x3FC0:0x0075
%define o_eopDispatcher                 0x0AE0:0x0075

; enums

InventorySlot_BACKPACK                  EQU 0
InventorySlot_LEFT_HAND                 EQU 1
InventorySlot_RIGHT_HAND                EQU 2

MouseCursor_Finger                      EQU 0

; structures

MouseState_button                       EQU 1
MouseState_action                       EQU 7

List_SIZE                               EQU 4
List_head                               EQU 0
List_tail                               EQU 2

ListNode_next                           EQU 0
ListNode_prev                           EQU 2
ListNode_payload                        EQU 6

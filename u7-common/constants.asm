; =============================================================================
; enumerations
; -----------------------------------------------------------------------------

%assign FindItemFlagBit_1                       1
%assign FindItemFlagBit_2                       2
%assign FindItemFlagBit_ONLY_NPCS               4
%assign FindItemFlagBit_ONLY_ALIVE_NPCS         8
%assign FindItemFlagBit_INCLUDE_EGGS            16
%assign FindItemFlagBit_NO_NPCS                 32
%assign FindItemFlagBit_64                      64
%assign FindItemFlagBit_128                     128

%assign Font_YELLOW                             0
%assign Font_WOODEN_RUNIC                       1
%assign Font_SMALL_BLACK                        2
%assign Font_WHITE_RUNIC_OUTLINE                3
%assign Font_TINY_BLACK                         4
%assign Font_TINY_GLOWING_BLUE                  5
%assign Font_YELLOW_RUNIC_OUTLINE               6
%assign Font_RED                                7

%assign ItemLabelType_NAME                      0
%assign ItemLabelType_WEIGHT                    1
%assign ItemLabelType_BULK                      2

%assign ItemClassBit_NPC                        0x100

%assign KeyboardShiftBit_RIGHT_SHIFT            1
%assign KeyboardShiftBit_LEFT_SHIFT             2
%assign KeyboardShiftBit_CTRL                   4
%assign KeyboardShiftBit_ALT                    8
%assign KeyboardShiftBit_SCROLL_LOCK            16
%assign KeyboardShiftBit_NUM_LOCK               32
%assign KeyboardShiftBit_CAPS_LOCK              64
%assign KeyboardShiftBit_INSERT                 128

%assign MouseAction_NONE                        0
%assign MouseAction_PRESS                       1
%assign MouseAction_DOUBLE_CLICK                2
%assign MouseAction_RELEASE                     3
%assign MouseAction_MOVE                        4

%assign MouseRawAction_NONE                     0
%assign MouseRawAction_PRESS                    1
%assign MouseRawAction_RELEASE                  2

%assign TextAlignment_LEFT                      0
%assign TextAlignment_TOP                       0
%assign TextAlignment_HORIZONTAL_CENTER         1
%assign TextAlignment_VERTICAL_CENTER           2
%assign TextAlignment_RIGHT                     4
%assign TextAlignment_BOTTOM                    8

; =============================================================================
; structure offsets
; -----------------------------------------------------------------------------

%assign BarkText_timeCounter                    0x16

%assign Camera_isViewDarkened                   1

%assign CastByKey_isCastingInProgress           0x00
%assign CastByKey_pn_timer                      0x02
%assign CastByKey_selectedRuneCount             0x04
%assign CastByKey_selectedRunes                 0x08
%assign CastByKey_runeStrings                   0x10
%assign CastByKey_spellRunes                    CastByKey_runeStrings + 30 * 8
%assign CastByKey_SIZE                          CastByKey_spellRunes + 100 * 8

%assign ConversationGump_optionsGump            0x0E

%assign ConversationOptions_head                0x0E
%assign ConversationOptions_SIZE                0x12

%assign ConversationOptionsGump_xyBounds        0x0E

%assign ConversationOptionCoords_x              0
%assign ConversationOptionCoords_line           1

%assign FindItemQuery_ibo                       0x00
%assign FindItemQuery_SIZE                      0x2A

%assign InventoryArea_ibo                       0x000
%assign InventoryArea_draggedIbo                0x002
%assign InventoryArea_worldX                    0x004
%assign InventoryArea_worldY                    0x006
%assign InventoryArea_worldZ                    0x008
%assign InventoryArea_pn_vtable                 0x00C
%assign InventoryArea_setByDropDraggedItem      0x00E
%assign InventoryArea_vtable                    0x010
%assign InventoryArea_f00_drawTree              0x049
%assign InventoryArea_f04_getIbo                0x050
%assign InventoryArea_f05_tryToAccept           0x060
%assign InventoryArea_f06_getDraggedIbo         0x0F0
%assign InventoryArea_f07_getX1                 0x110
%assign InventoryArea_f08_getY1                 0x110
%assign InventoryArea_f09_getX2                 0x110
%assign InventoryArea_f10_getY2                 0x110
%assign InventoryArea_f11_recordXOffset         0x110
%assign InventoryArea_f12_recordYOffset         0x110
%assign InventoryArea_SIZE                      0x120

%assign List_pn_head                            0
%assign List_pn_tail                            2
%assign List_SIZE                               4

%assign ListNode_pn_next                        0
%assign ListNode_pn_prev                        2
%assign ListNode_payload                        6

%assign MouseState_rawAction                    0 ; db
%assign MouseState_button                       1 ; db
%assign MouseState_xx                           2 ; dw
%assign MouseState_y                            4 ; dw
%assign MouseState_buttonBits                   6 ; db
%assign MouseState_action                       7 ; db
%assign MouseState_time                         8 ; dd

%assign ShapeBark_shape                         0x00
%assign ShapeBark_frame                         0x02
%assign ShapeBark_x                             0x04
%assign ShapeBark_y                             0x06
%assign ShapeBark_pn_vtableA                    0x08
%assign ShapeBark_pn_vtableB                    0x0C
%assign ShapeBark_field0E                       0x0E
%assign ShapeBark_stringWithLength              0x12
%assign ShapeBark_timer                         0x16
%assign ShapeBark_vtableA                       0x1E
%assign ShapeBark_vtableB                       0x22
%assign ShapeBark_a00_destroy                   0x26
%assign ShapeBark_b00_drawTree                  0x27
%assign ShapeBark_SIZE                          0x60

%assign ShapeGump_x                             0x0E
%assign ShapeGump_y                             0x10
%assign ShapeGump_shape                         0x12
%assign ShapeGump_frame                         0x14

%assign Sprite_ibo                              0x0B

%assign TextPrinter_x                           0x0
%assign TextPrinter_y                           0x2
%assign TextPrinter_charSpacing                 0x4
%assign TextPrinter_lineSpacing                 0x6
%assign TextPrinter_pn_viewport                 0x8
%assign TextPrinter_pn_vtable                   0xA
%assign TextPrinter_field_0C                    0xC
%assign TextPrinter_field_0E                    0xE

%assign XyBounds_minX                           0
%assign XyBounds_minY                           2
%assign XyBounds_maxX                           4
%assign XyBounds_maxY                           6

; =============================================================================
; other constants
; -----------------------------------------------------------------------------

%assign VOODOO_SELECTOR                         0

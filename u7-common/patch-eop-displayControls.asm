; Display a book of text listing key and mouse controls.

[bits 16]

startPatch EXE_LENGTH, eop-displayControls
	startBlockAt addr_eop_displayControls
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_farString          -0x04
		add sp, var_farString
		
		push si
		
		lea si, [bp+var_farString]
		push si
		callFromOverlay FarString_new
		pop cx
		
		push offsetInCodeSegment(controlsText1)
		push si
		call displayCsTextInBook
		pop cx
		pop cx
		
		push offsetInCodeSegment(controlsText2)
		push si
		call displayCsTextInBook
		pop cx
		pop cx
		
		push offsetInCodeSegment(controlsText3)
		push si
		call displayCsTextInBook
		pop cx
		pop cx
		
		push offsetInCodeSegment(controlsText4)
		push si
		call displayCsTextInBook
		pop cx
		pop cx
		
		push 0 ; on stack; don't deallocate
		push si
		callFromOverlay FarString_destructor
		pop cx
		pop cx
		
		pop si
		
		mov sp, bp
		pop bp
		retn
		
		displayCsTextInBook:
			push bp
			mov bp, sp
			
			%assign .arg_textOffset   0x06
			%assign .arg_pn_farString 0x04
			
			mov bx, [bp+.arg_pn_farString]
			mov ax, [bp+.arg_textOffset]
			fmemcpy word [bx+2], word [bx+0], cs, ax, 1000
			
			mov bx, [bp+.arg_pn_farString]
			les bx, [bx]
			mov byte [es:bx+999], 0
			
			push TextDisplayType_BOOK
			push word [bp+.arg_pn_farString]
			callVarArgsEopFromOverlay displayText, 2
			pop cx
			pop cx
			
			mov sp, bp
			pop bp
			retn
			
		controlsText1:
			db controlsTitle
			db "~"
			db "~KEYS"
			db "~a: toggle audio"
			db "~c: toggle combat"
			db "~f: feed party member"
			db "~h: toggle mouse hand"
			db "~k: use keyring, or find+use key"
			db "~q: keep moving (see below)"
			db "~s: show Save dialog"
			db "~t: targeting (see below)"
			db "~v: show game version"
			db "~/: cast by key (see below)"
			db "~Alt+x: prompt to exit"
			db "~Alt+m: show memory stats"
			db "~Alt+\: toggle cheats"
			db "~Space: start key-mouse"
			db "~numpad/arrows: move"
			%ifdef combatStatusLine
				db combatStatusLine
			%else
				db "~"
			%endif
			db "~"
			db "~MOUSE"
			db "~MB1: name item"
			db "~Shift+MB1: show item weight"
			db "~Ctrl+MB1: show item volume"
			db "~Alt+MB1: show item content"
			%ifdef altMb1Line
				db altMb1Line
			%endif
			db "~2xMB1: use (in combat: attack)"
			db "~MB2: move"
			db "~2xMB2: move to point"
			db "~"
			db "~KEEP MOVING"
			db "~q,Q: engage; cycle speed"
			db "~"
			db "~Keeps the Avatar moving in the last specified direction."
			db " Walk/run/sprint. Numpad or arrows to change direction."
			db " Any other key to stop."
			db 0
			
		controlsText2:
			db "~PARTY MEMBERS BY NUMBER"
			db "~<n>: nth party member"
			db "~Shift+<n>: open <n>'s backpack"
			db "~Alt+Shift+<n>: show <n>'s stats"
			db "~drag item,<n>: give item to <n>"
			db "~"
			db "~Press a party member's number to open their inventory"
			db " or to target them when selecting with crosshairs."
			db "~"
			db "~USABLE ITEMS"
			db "~b: spellbook(s)"
			db "~g: abacus (to count money)"
			db "~m: world map"
			db "~p: lockpicks"
			db "~x: sextant"
			%ifdef keyUsableItemLineX2
				db keyUsableItemLineX2
			%else
				db "~"
				db "~"
			%endif
			db "~TARGETING"
			db "~While selecting with crosshairs."
			db "~"
			db "~<n>: select party member"
			db "~t,T: cycle NPCs"
			db "~r,R: cycle usable items"
			db "~a,A: cycle all items"
			db "~Enter: select/talk/use"
			db "~Esc: cancel"
			db "~"
			db "~g,G: cycle gettable items"
			db "~g,Enter: get to Avatar"
			db "~g,<n>: get to party member"
			db "~"
			db "~in combat:"
			db "~t,Enter: attack w/party"
			db "~t,<n>: attack w/<n>"
			db 0
			
		controlsText3:
			db "~CAST BY KEY"
			db "~Requires a spellbook."
			db "~"
			db "~/: start casting"
			db "~a-z: add rune to spell"
			db "~Enter: try to cast"
			db "~Esc: cancel casting"
			db "~"
			db "~To see which keys are recognized for each spell,"
			db " hold Shift while opening or flipping through the spellbook."
			db "~"
			%ifdef frioRuneKeyLine
				db frioRuneKeyLine
			%else
				db "~"
			%endif
			db "~"
			db "~"
			db "~"
			db "~"
			db "~"
			db "~CONVERSATION KEYS"
			db "~Enter/Space/Ctrl: advance text, select response"
			db "~(Shift+)Tab/Left/Right: cycle between responses"
			db "~"
			db "~The same keys will advance the text of"
			db " books, scrolls, and signs."
			db "~"
			db "~QUANTITY SLIDERS"
			db "~(Shift+)Left/Right: change value"
			db "~Up/Down: set value to min/max"
			db "~Enter or MB2: accept quantity"
			db "~"
			db "~INVENTORY DIALOGS"
			db "~Tab: cycle between inventories"
			db "~MB2: close dialog"
			db 0
			
		controlsText4:
			db "~EXAMPLES"
			db "~f,3: feed third party member"
			db "~"
			db "~t,2: talk to second party member"
			db "~"
			db "~/,v,m,Enter,4: cast Great Heal (Vas Mani)"
			db " on fourth party member"
			db "~"
			db "~t,g,g,3: have third party member get a nearby item"
			db "~"
			db "~t,t,t,2: (in combat) have second party member"
			db " attack a nearby NPC"
			db 0
			
	endBlockAt off_eop_displayControls_end
endPatch

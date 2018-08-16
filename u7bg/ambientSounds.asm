%include "include/u7bg-all-includes.asm"

[bits 16]

defineAddress 47, 0x04BB, surfDividend
defineAddress 47, 0x04B0, surfDivisor
defineAddress 47, 0x0691, magicSwordDividend
defineAddress 47, 0x0686, magicSwordDivisor
defineAddress 47, 0x0491, fireDividend
defineAddress 47, 0x0486, fireDivisor
defineAddress 47, 0x07C7, chirpingDividend
defineAddress 47, 0x07BC, chirpingDivisor
defineAddress 47, 0x07DD, determineChirpingVolume
defineAddress 47, 0x01A8, itemSoundVolume

startPatch EXE_LENGTH, \
		adjust the volume and frequency of ambient-sound playback
	
	;---------------------------
	; sounds of on-screen items 
	;---------------------------
	
	; on-screen item sound max volume
	; originally 127
	startBlockAt addr_itemSoundVolume
		db 90
	endBlock
	
	; surf
	; originally 1/100
	setSoundProbability 3, 1000, addr_surfDividend, addr_surfDivisor
	
	; magic sword, magebane, death scythe, hoe of destruction
	; originally 10/100
	setSoundProbability 0, 100, addr_magicSwordDividend, addr_magicSwordDivisor
	
	; firepit, campfire, fire sword, firedoom staff, fire wand, etc.
	; originally 60/100
	setSoundProbability 0, 100, addr_fireDividend, addr_fireDivisor
	
	;---------------------
	; night-time chirping
	;---------------------
	
	; originally 20/100
	setSoundProbability 8, 100, addr_chirpingDividend, addr_chirpingDivisor
	
	startBlockAt addr_determineChirpingVolume
		mov ax, 60 ; volume range (originally 100)
		push ax
		callFromLoadModule generateRandomIntegerInRange
		inc sp
		inc sp
		add ax, 10 ; volume base (originally 25)
	endBlockOfLength 14
endPatch

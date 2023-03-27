
;
; It Might Be NES, Copyright (C) 2001,2002,2003 Allan Blomquist
; All rights reserved.  Email: ablomquist@gmail.com
;
; This file is part of imbNES.
;
; imbNES is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; imbNES is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with imbNES.  If not, see <http://www.gnu.org/licenses/>.
;

map5write50

		jr		ra
		nop


map5write51

		subiu	at,t8,$05
		bnez	at,map5not5105
		nop
;------
; 5105
;------
		andi	a1,a1,$55			;is this correct at all?
		andi	a0,a1,$01			;is it even mirroring?
		srl		at,a1,$01
		andi	at,at,$02
		or		a0,a0,at
		srl		at,a1,$02
		andi	at,at,$04
		or		a0,a0,at
		srl		at,a1,$03
		andi	at,at,$08
		or		a0,a0,at
		sb		a0,mirrorSel
		li		a1,$01
		sb		a1,needToRender
		jr		ra
		nop

map5not5105
		subiu	at,t8,$15
		bnez	at,map5not5115
		nop
;------
; 5115
;------
		or		t8,ra,zero
		li		a0,$4
		jal		bankSwitch
		andi	a1,a1,$7E
		j		bankSwitch
		or		ra,t8,zero

map5not5115
		subiu	at,t8,$16
		bnez	at,map5not5116
		nop
;------
; 5116
;------
		li		a0,$6
		j		bankSwitch
		andi	a1,a1,$7F

map5not5116
		andi	at,t8,$F8
		li		v0,$20
		bne		at,v0,map5not5120_5127		;this sets the banks to use for
		nop									;rendering sprites
;-------------
; 5120 - 5127
;-------------
		la		a0,map5chrSingleVals
		andi	at,t8,$7
		addu	a0,a0,at
		sb		a1,$0000(a0)

		lbu		a0,map5chrMode
		nop
		bnez	a0,map5chrModeChangeToSingle
		nop

		or		a0,a1,zero
		;j		bufLoadVROM				; these are the sprite banks so
	jr ra								; don't really load them now
		andi	a1,t8,$7

map5chrModeChangeToSingle

		sb		zero,map5chrMode
		sw		ra,saveFP

		lbu		a0,map5chrSingleVals+0
		;jal		bufLoadVROM
		li		a1,$00
		lbu		a0,map5chrSingleVals+1
		;jal		bufLoadVROM
		li		a1,$01
		lbu		a0,map5chrSingleVals+2
		;jal		bufLoadVROM
		li		a1,$02
		lbu		a0,map5chrSingleVals+3
		;jal		bufLoadVROM
		li		a1,$03
		lbu		a0,map5chrSingleVals+4
		;jal		bufLoadVROM
		li		a1,$04
		lbu		a0,map5chrSingleVals+5
		;jal		bufLoadVROM
		li		a1,$05
		lbu		a0,map5chrSingleVals+6
		;jal		bufLoadVROM
		li		a1,$06
		lbu		a0,map5chrSingleVals+7
		;jal		bufLoadVROM
		li		a1,$07

		lw		ra,saveFP
		nop
		jr		ra
		nop

map5not5120_5127
		andi	at,t8,$FC
		li		v0,$28
		bne		at,v0,map5not5128_512B		;this sets the banks to use for
		nop									;rendering the BG
;------
; 5128 - 512B
;------
		la		a0,map5chrDoubleVals
		andi	at,t8,$3
		addu	a0,a0,at
		sb		a1,$0000(a0)

		sw		ra,saveFP

		lbu		a0,map5chrMode
		nop
		beqz	a0,map5chrModeChangeToDouble
		nop

		or		a0,a1,zero
		jal		bufLoadVROM
		andi	a1,t8,$3

		subiu	a0,a0,$01
		jal		bufLoadVROM
		addiu	a1,a1,$03

		lw		ra,saveFP
		nop
		jr		ra
		nop

map5chrModeChangeToDouble

		li		a0,$01
		sb		a0,map5chrMode

		lbu		a0,map5chrDoubleVals+0
		jal		bufLoadVROM
		li		a1,$00
		subiu	a0,a0,$01
		jal		bufLoadVROM
		addiu	a1,a1,$03
		lbu		a0,map5chrDoubleVals+1
		jal		bufLoadVROM
		li		a1,$01
		subiu	a0,a0,$01
		jal		bufLoadVROM
		addiu	a1,a1,$03
		lbu		a0,map5chrDoubleVals+2
		jal		bufLoadVROM
		li		a1,$02
		subiu	a0,a0,$01
		jal		bufLoadVROM
		addiu	a1,a1,$03
		lbu		a0,map5chrDoubleVals+3
		jal		bufLoadVROM
		li		a1,$03
		subiu	a0,a0,$01
		jal		bufLoadVROM
		addiu	a1,a1,$03

		lw		ra,saveFP
		nop
		jr		ra
		nop

map5not5128_512B
		jr		ra
		nop


map5write52

		subiu	at,t8,$03
		bnez	at,map5not5203
		nop
;------
; 5203
;------
		sb		a1,mapReg0			;set the target scanline for an IRQ
beqz a1,nobrk3
nop
nop
nobrk3
		jr		ra
		nop

map5not5203
		subiu	at,t8,$04
		bnez	at,map5not5204
		nop
;------
; 5204
;------
beqz a1,nobrk4
nop
nop
nobrk4
		li		t8,$0
		andi	at,a1,$80
		beqz	at,map5noIRQenable
		nop
		
		la		t8,mmc5hsync

map5noIRQenable
		sw		t8,mapHsyncFunc		;set the hsync function
		jr		ra
		nop

map5not5204
		jr		ra
		nop


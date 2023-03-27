
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

map1write

		andi	at,a1,$80
		bnez	at,map1reset		; reset if the high bit is set
		nop

		lbu		t8,map1lastaddr
		lbu		a3,map1tmp
		lbu		a2,map1pos
		andi	at,a0,$FE
		ori		t9,at,$08
		beq		t8,t9,nomap1reset
		nop
		li		a3,$0				;	 reset the reg if you're writing to a new addr
		li		a2,$0
nomap1reset
		sb		t9,map1lastaddr

		andi	a1,a1,$01		; put the data into the tmp reg
		sllv	a1,a1,a2
		or		a3,a3,a1
		sb		a3,map1tmp
		addiu	a2,a2,$01
		sb		a2,map1pos

		subiu	a2,a2,$05
		bnez	a2,map1return
		nop

		lw		v0,mapReg0			;load all 4 map1 regs
		srl		a0,a0,$01
		sll		at,a0,$03
		srlv	t8,v0,at
		andi	t8,t8,$FF		;t8 has old value
		sb		zero,map1tmp	; reset the reg
		sb		zero,map1pos
		beq		t8,a3,map1return
		nop
		la		a1,mapReg0
		addu	a1,a1,a0
		sb		a3,$0000(a1)		; save the value

		or		at,a0,zero
		or		a0,a3,zero			; existing code expects a0 to have val

		subiu	at,at,$01
		beqz	at,map1trigA
		subiu	at,at,$01
		beqz	at,map1trigC		; jump to handler
		subiu	at,at,$01
		beqz	at,map1trigE
		nop

;--------
map1trig8
;--------

		andi	a1,a0,$03
		la		at,map1mirrors			; select mirroring
		addu	at,at,a1
		lbu		a1,$0000(at)
		sb		s5,needToRender
		sb		a1,mirrorSel

		andi	t8,t8,$C
		andi	at,a0,$C
		bne		t8,at,map1bankChangeFrom8
		nop
		jr		ra
		nop

map1bankChangeFrom8
		srl		v0,v0,$08
		sll		v0,v0,$08
		or		v0,v0,a0			;fix reg0 in the old values word
		j		map1trigE
		srl		a0,v0,$18			;a0 should have bank value

;--------
map1trigA
;--------

		lbu		t9,chrCount
		andi	t8,t8,$10
		bnez	t9,map1doCharA
		andi	at,a0,$10

		bne		t8,at,map1bankChangeFromA
		nop
		
map1doCharA

		sll		a0,a0,$02		; convert input (# of 4k) to (# of 1k)
		sw		ra,saveFP
		andi	t8,v0,$10
		beqz	t8,map1swap8kchr
		nop

		li		a1,$00		; copy 4k to VRAM
		jal		bufLoadVROM
		nop
		jal		bufLoadVROM		;pattern 0
		nop
		jal		bufLoadVROM
		nop
		jal		bufLoadVROM
		nop

		lw		ra,saveFP
		nop
		jr		ra
		nop
		
map1swap8kchr
		andi	a0,a0,$F8		; just like 32k prg swap ignores a bit, this does too
								; bases loaded 2 needs this to be $F8

		li		a1,$00		; copy 8k to VRAM
		jal		bufLoadVROM
		nop
		jal		bufLoadVROM		;pattern 0
		nop
		jal		bufLoadVROM
		nop
		jal		bufLoadVROM
		nop

		jal		bufLoadVROM
		nop
		jal		bufLoadVROM		;pattern 1
		nop
		jal		bufLoadVROM
		nop
		jal		bufLoadVROM
		nop

		lw		ra,saveFP
		nop
		jr		ra
		nop

map1bankChangeFromA
		li		at,$FFFF00FF
		and		v0,v0,at
		sll		at,a0,$08
		or		v0,v0,at
		j		map1trigE
		srl		a0,v0,$18			;a0 should have bank value

;--------
map1trigC
;--------

		andi	t8,v0,$10
		beqz	t8,map1return
		nop

		lbu		t8,chrCount
		nop
		beqz	t8,map1return
		nop

		sll		a0,a0,$02		; always a number of 4k banks?
		sw		ra,saveFP
		li		a1,$04			; copy 4k to VRAM
		jal		bufLoadVROM
		nop
		jal		bufLoadVROM		;pattern 0
		nop
		jal		bufLoadVROM
		nop
		jal		bufLoadVROM
		nop

		lw		ra,saveFP
		nop
		jr		ra
		nop


;--------
map1trigE
;--------

domap1prg

		andi	v1,v0,$1000		; get 256k select
		srl		v1,v1,$08

		andi	at,v0,$08
		bnez	at,map1select16k
		nop

		andi	a0,a0,$FE		;for 32k, # of 16k banks must be even
		or		a0,a0,v1
		sll		a1,a0,$01		;change to # of 8k banks

		or		t8,ra,zero		;save return addr

		jal		bankSwitch
		li		a0,$4
		jal		bankSwitch		;smb/duck/track uses 32k switch to load game
		nop						;can use to verify this part of code
		jal		bankSwitch
		nop
		jal		bankSwitch
		nop

		jr		t8
		nop

map1select16k

		andi	at,v0,$04
		beqz	at,map1select16kC
		or		t8,ra,zero		;save return addr

		or		a0,a0,v1
		sll		a1,a0,$01		;change to # of 8k banks, save in t8

		jal		bankSwitch
		li		a0,$4
		jal		bankSwitch		;most mapper 1 games use this bank
		nop						;switch code, use any to test
	
		ori		a1,v1,$F
		sll		a1,a1,$01
		jal		bankSwitch
		li		a0,$06
		jal		bankSwitch
		nop

		jr		t8
		nop

map1select16kC

		or		a0,a0,v1
		sll		t9,a0,$01		;change to # of 8k banks, save in t9

		li		a1,$0
		jal		bankSwitch
		li		a0,$4
		jal		bankSwitch		;"tecmo world wrestling" uses this bank
		nop						;switching code, can use to test

		or		a1,t9,zero

		jal		bankSwitch
		li		a0,$06
		jal		bankSwitch
		nop

		jr		t8
		nop

map1reset
		lbu		v0,mapReg0
		sb		zero,map1tmp	;	 reset the reg
		sb		zero,map1pos
		ori		v0,v0,$C
		sb		v0,mapReg0
map1return
		jr		ra
		nop

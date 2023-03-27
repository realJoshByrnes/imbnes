
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

map4write8
		lbu		a0,mapReg0
		andi	at,t8,$01
		bne		at,zero,map481
		nop

		andi	v1,a1,$40
		sb		a1,mapReg0		; store the command
		andi	v0,a0,$40
		xor		at,v0,v1
		beqz	at,map4ret
		nop						; if the pos of bank sel 2 has changed...

		or		t9,ra,zero

		lbu		a1,map4prevs+12
		srl		a0,v1,$05			; correct the first page
		addiu	a0,a0,$04
		jal		bankSwitch
		xori	t8,v1,$40			; need to save that in t8

		srl		a0,t8,$05
		addiu	a0,a0,$04
		jal		bankSwitch			; correct where second to last goes
		li		a1,$FE				; (the other 2 don't change)

		or		ra,t9,zero
map4ret
		jr		ra
		nop

map481
		la		t8,map4prevs
		andi	at,a0,$07
		sll		t9,at,$01
		addu	t8,t8,t9
		lhu		t9,$0000(t8)
		sll		a2,a0,$08
		or		a2,a2,a1
		beq		t9,a2,map4ret
		sh		a2,$0000(t8)

		subiu	at,at,1
		beqz	at,map4cmd1
		subiu	at,at,1
		beqz	at,map4cmd2
		subiu	at,at,1
		beqz	at,map4cmd3
		subiu	at,at,1
		beqz	at,map4cmd4
		subiu	at,at,1
		beqz	at,map4cmd5
		subiu	at,at,1
		beqz	at,map4cmd6
		subiu	at,at,1
		beqz	at,map4cmd7
		nop

;-------
map4cmd0
;-------

		lbu     v0,chrCount
		nop
		beqz	v0,map4ret
		nop

		andi	a0,a0,$80		; selects switching at $0000 or $1000
		srl		t8,a0,$05

		sw		ra,saveFP
		andi	a0,a1,$FE		; select 1k banks
		li		a1,$00
		jal		bufLoadVROM
		xor		a1,a1,t8
		jal		bufLoadVROM
		nop

		lw		v0,saveFP
		nop
		jr		v0
		nop

;-------
map4cmd1
;-------

		lbu     v0,chrCount
		nop
		beqz	v0,map4ret
		nop

		andi	a0,a0,$80		; selects switching at $0000 or $1000
		srl		t8,a0,$05

		sw		ra,saveFP
		andi	a0,a1,$FE		; select 1k banks
		li		a1,$02
		jal		bufLoadVROM
		xor		a1,a1,t8
		jal		bufLoadVROM
		nop

		lw		v0,saveFP
		nop
		jr		v0
		nop

;-------
map4cmd2
;-------

		lbu     v0,chrCount
		nop
		beqz	v0,map4ret
		nop

		andi	a0,a0,$80		; selects switching at $0000 or $1000
		srl		t8,a0,$05

		sw		ra,saveFP
		or		a0,a1,zero		; select 1k bank
		li		a1,$04
		jal		bufLoadVROM
		xor		a1,a1,t8

		lw		v0,saveFP
		nop
		jr		v0
		nop

;-------
map4cmd3
;-------
		
		lbu     v0,chrCount
		nop
		beqz	v0,map4ret
		nop

		andi	a0,a0,$80		; selects switching at $0000 or $1000
		srl		t8,a0,$05

		sw		ra,saveFP
		or		a0,a1,zero		; select 1k bank
		li		a1,$05
		jal		bufLoadVROM
		xor		a1,a1,t8

		lw		v0,saveFP
		nop
		jr		v0
		nop

;-------
map4cmd4
;-------

		lbu     v0,chrCount
		nop
		beqz	v0,map4ret
		nop

		andi	a0,a0,$80		; selects switching at $0000 or $1000
		srl		t8,a0,$05

		sw		ra,saveFP
		or		a0,a1,zero		; select 1k bank
		li		a1,$06
		jal		bufLoadVROM
		xor		a1,a1,t8

		lw		v0,saveFP
		nop
		jr		v0
		nop

;-------
map4cmd5
;-------

		lbu     v0,chrCount
		nop
		beqz	v0,map4ret
		nop

		andi	a0,a0,$80		; selects switching at $0000 or $1000
		srl		t8,a0,$05

		sw		ra,saveFP
		or		a0,a1,zero		; select 1k bank
		li		a1,$07
		jal		bufLoadVROM
		xor		a1,a1,t8

		lw		v0,saveFP
		nop
		jr		v0
		nop

;-------
map4cmd6
;-------
		
		andi	a0,a0,$40
		srl		a0,a0,$05
		j		bankSwitch			;a1 already has page #
		addiu	a0,a0,$04

;-------
map4cmd7
;-------

		j		bankSwitch
		li		a0,$05

map4writeA
		andi	at,t8,$01
		bne		at,zero,map4A1
		nop

		andi	a1,a1,$01
		la		a0,map1mirrors+2
		addu	a0,a0,a1
		lbu		a0,$0000(a0)
		sb		s5,needToRender
		sb		a0,mirrorSel
		jr		ra
		nop

map4A1					;SRAM enable / disable, even games with no SRAM enable this
		jr		ra		;so i'm not bothering with it
		nop

map4writeC
		andi	at,t8,$01
		bne		at,zero,map4C1
		nop

		beqz	a1,zeroIRQ
		nop

		;subiu	t8,t7,$0154
		;bgtz	t8,secondhalfIRQ
		;nop

		addiu	a1,a1,$02
		sb		a1,map4irq
		jr		ra
		nop

;secondhalfIRQ
		;addiu	a1,a1,$01
		;sb		a1,map4irq
		;jr		ra
		;nop

zeroIRQ
		li		t8,$FF
		sb		t8,map4irq
		sw		zero,mapHsyncFunc
		jr		ra
		nop

map4C1
		sb		a1,map4latch
		jr		ra
		nop

map4writeE
		andi	at,t8,$01
		bne		at,zero,map4E1
		nop

		lbu		t9,map4latch
		sw		zero,mapHsyncFunc
		sb		t9,map4irq

		jr		ra
		nop

map4E1	
		la		t9,mmc3hsync
		sw		t9,mapHsyncFunc

		jr		ra
		nop

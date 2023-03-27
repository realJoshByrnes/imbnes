
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

read2002
		lbu		v1,PPULatch(s7)
		lbu		a1,$2002(s7)
		sb		zero,wantLo2006 ;reset the 2005/2006 toggle
		andi	at,a1,$80
		srl		v0,at,$02
		srl		at,at,$01
		or		at,at,v0
		and		v0,a1,at
		sb		v0,$2002(s7)

		andi	v1,v1,$1F
		or		a1,a1,v1

		addu	at,fp,s4
		subiu	at,at,$03
		lbu		v0,$0000(at)
		li		v1,$AD
		bne		v0,v1,noLDA
		li		v1,$02
		sb		v1,$0000(at)
		jr		ra
		nop
noLDA
		li		v1,$AE
		bne		v0,v1,noLDX
		li		v1,$03
		sb		v1,$0000(at)
		jr		ra
		nop
noLDX
		li		v1,$AC
		bne		v0,v1,noLDY
		li		v1,$04
		sb		v1,$0000(at)
		jr		ra
		nop
noLDY
		li		v1,$2C
		bne		v0,v1,noBIT
		li		v1,$07
		sb		v1,$0000(at)
		jr		ra
		nop
noBIT
		jr		ra
		nop

read2000
read2001
read2003
read2005
read2006
		lbu		a1,PPULatch(s7)		;just return the latch
		jr		ra
		nop

read2004
		lbu		v0,$2003(s7)
		la		v1,sprRAM
		addiu	at,v0,$01
		sb		at,$2003(s7)
		addu	v1,v1,v0
		lbu		a1,$0000(v1)
		jr		ra
		nop


read2007
		lhu		v0,$1800(s7)
		lbu		a1,PPULatch(s7)	; return the current contents of the reg

		lbu		a2,$1804(s7)
		andi	at,v0,$2000
		addu	t8,v0,a2
		andi	t8,t8,$3FFF
		bnez	at,notReadPPUPattern
		sh		t8,$1800(s7)
		
; check if CHR is disabled		
		la		t9,chrDisabled
		lbu		t8,0(t9)
		nop
		bnez		t8,readDisabledChr
		nop

		la		t8,patBlocks
		srl		at,v0,$08
		andi	at,at,$1C
		addu	t8,t8,at
		lw		t8,$0000(t8)
		andi	at,v0,$03FF
		addu	t8,t8,at
		lbu		t8,$0000(t8)
		nop
		jr		ra
		sb		t8,PPULatch(s7)

readDisabledChr ; if CHR is disabled, always return 0x12
		li		t8,$12
		jr		ra
		sb		t8,PPULatch(s7)

notReadPPUPattern
		andi	at,v0,$1000
		bnez	at,notReadPPUName
		nop

		lw		t8,mirrorSel
		lui		t9,$8002
		andi	at,v0,$C00
		srl		at,at,$0A
		srlv	t8,t8,at
		andi	t8,t8,$01
		sll		t8,t8,$0A
		or		t9,t9,t8
		andi	v0,v0,$3FF
		or		t9,t9,v0
		lbu		t8,$2000(t9)
		nop
		jr		ra
		sb		t8,PPULatch(s7)

notReadPPUName

		lui		t8,$8002
		andi	v0,v0,$1F
		or		t8,t8,v0
		lbu		t8,$3F00(t8)
		nop
		jr		ra
		sb		t8,PPULatch(s7)

write2007
		lhu		t8,$1800(s7)	; get vram addr
		lbu		v0,$1804(s7)
		andi	t8,t8,$3FFF
		srl		t9,t8,$0A
		andi	t9,t9,$0C
		la		at,PPUWrite
		addu	at,at,t9
		lw		at,$0000(at)
		addu	t9,t8,v0
		jr		at
		sh		t9,$1800(s7)	; save the new vram addr

PPUWritePat
		lui		at,$8002
		or		at,t8,at
		lbu		v0,$0000(at)
		sb		a1,$0000(at)	;store the byte
		
		beq		a1,v0,PPUreturn
		nop

		la		v0,dirty0tile		;set per tile dirty bit
		srl		at,t8,$07
		addu	v0,v0,at
		lbu		v1,$0000(v0)
		srl		at,t8,$04
		andi	at,at,$07
		sllv	at,s5,at
		or		v1,v1,at
		sb		v1,$0000(v0)

		la		v0,patBlocks
		srl		at,t8,$0A
		sll		v1,at,$02
		addu	v0,v0,v1
		lui		v1,$8002		;say that this is from vRAM
		andi	t9,t8,$FC00
		addu	v1,v1,t9
		sw		v1,$0000(v0)
		andi	at,at,$04
		la		v0,dirtyPat0
		addu	v0,v0,at
		lw		t9,$0000(v0)
		andi	v1,t8,$0FFF
		srl		v1,v1,$07
		sllv	at,s5,v1
		or		t9,t9,at
		sw		t9,$0000(v0)

PPUreturn
		jr		ra
		nop

PPUWriteName

		lw		at,mirrorSel
		srl		v0,t8,$0A
		andi	v0,v0,$03
		srlv	at,at,v0
		andi	at,at,$01

		sll		v0,at,$0A
		lui		v1,$8002
		or		v1,v1,v0			;store the byte
		andi	v0,t8,$03FF
		addu	t9,v1,v0
		lbu		a0,$2000(t9)		;get the old value to compare
		andi	s6,t9,$07FF
		sb		a1,$2000(t9)
		sll		s6,s6,$01
		addu	t9,s6,s7
		lhu		s6,$0800(t9)		;get the old timestamp

		beq		a0,a1,PPUreturn		;quit if it hasn't changed
		subiu	v1,v0,$03C0
		bltz	v1,namePart
		nop

;write to attrib table
attrPart
		sll		a2,at,$0A
		li		v0,34560
		multu	at,v0
		mflo	v0
		la		a0,bg1DMAlist
		addu	v0,v0,a0
		srl		at,v1,$03		;every 8 bytes is worth 4 tile rows
		sll		a0,at,$07		; worth 128 tiles
		or		a2,a2,a0
		li		a0,4608
		multu	at,a0
		mflo	a0
		addu	v0,v0,a0
		andi	at,v1,$07		;every MOD 8 bytes is worth 4 tiles
		sll		a0,at,$02
		or		a2,a2,a0		; worth 4 tiles here too (a2 has tile# for checking time stamps)
		li		a0,144
		multu	at,a0
		mflo	a0
		addu	v0,v0,a0			; v0 now has addr of the first prim to modify

		lhu		s6,renderTimeStamp
		lw		t8,lastChange
		sll		a2,a2,$01

		andi	a3,a1,$01
		sll		a3,a3,$01
		andi	at,a1,$02
		sll		at,at,$0F+$03
		or		at,a3,at

		srl		a1,a1,$02

		li		gp,$FFF7FFFD
		
		lw		a0,$0008(v0)
		lw		a3,$002C(v0)
		and		a0,a0,gp
		and		a3,a3,gp
		or		a0,a0,at
		or		a3,a3,at
		sw		a0,$0008(v0)
		sw		a3,$002C(v0)

		lw		a0,$0488(v0)
		lw		a3,$04AC(v0)
		and		a0,a0,gp
		and		a3,a3,gp
		or		a0,a0,at
		or		a3,a3,at
		sw		a0,$0488(v0)
		sw		a3,$04AC(v0)

		;sb		at,$0014(v0)
		;sw		a0,$0018(v0)
		;sb		at,$0038(v0)
		;sw		a0,$003C(v0)
		;sb		at,$0494(v0)
		;sw		a0,$0498(v0)
		;sb		at,$04B8(v0)
		;sw		a0,$04BC(v0)

		addu	t9,a2,s7
		lw		at,$0800(t9)	;load time for 2 tiles
		nop
		andi	a0,at,$FFFF
		beq		a0,s6,nolinkAtt11
		srl		at,at,$10

		sh		s6,$0800(t9)
		lw		a0,$0000(t8)
		lui		a3,$FF00
		and		a0,a0,a3
		li		a3,$00FFFFFF
		and		a3,a3,v0
		or		a0,a0,a3
		sw		a0,$0000(t8)
		or		t8,v0,zero

nolinkAtt11
		beq		at,s6,nolinkAtt12
		nop

		addiu	v0,v0,$0024
		sh		s6,$0802(t9)
		lw		a0,$0000(t8)
		lui		a3,$FF00
		and		a0,a0,a3
		li		a3,$00FFFFFF
		and		a3,a3,v0
		or		a0,a0,a3
		sw		a0,$0000(t8)
		or		t8,v0,zero
		subiu	v0,v0,$0024

nolinkAtt12
		lw		at,$0840(t9)	;load time for 2 tiles
		nop
		andi	a0,at,$FFFF
		beq		a0,s6,nolinkAtt21
		srl		at,at,$10

		addiu	v0,v0,$0480
		sh		s6,$0840(t9)
		lw		a0,$0000(t8)
		lui		a3,$FF00
		and		a0,a0,a3
		li		a3,$00FFFFFF
		and		a3,a3,v0
		or		a0,a0,a3
		sw		a0,$0000(t8)
		or		t8,v0,zero
		subiu	v0,v0,$0480

nolinkAtt21
		beq		at,s6,nolinkAtt22
		nop

		addiu	v0,v0,$04A4
		sh		s6,$0842(t9)
		lw		a0,$0000(t8)
		lui		a3,$FF00
		and		a0,a0,a3
		li		a3,$00FFFFFF
		and		a3,a3,v0
		or		a0,a0,a3
		sw		a0,$0000(t8)
		or		t8,v0,zero
		subiu	v0,v0,$04A4

nolinkAtt22
		
		andi	a3,a1,$01
		sll		a3,a3,$01
		andi	at,a1,$02
		sll		at,at,$0F+$03
		or		at,a3,at

		srl		a1,a1,$02

		li		gp,$FFF7FFFD
		
		lw		a0,$0050(v0)
		lw		a3,$0074(v0)
		and		a0,a0,gp
		and		a3,a3,gp
		or		a0,a0,at
		or		a3,a3,at
		sw		a0,$0050(v0)
		sw		a3,$0074(v0)

		lw		a0,$04D0(v0)
		lw		a3,$04F4(v0)
		and		a0,a0,gp
		and		a3,a3,gp
		or		a0,a0,at
		or		a3,a3,at
		sw		a0,$04D0(v0)
		sw		a3,$04F4(v0)

		lw		at,$0804(t9)	;load time for 2 tiles
		nop
		andi	a0,at,$FFFF
		beq		a0,s6,nolinkAtt13
		srl		at,at,$10

		addiu	v0,v0,$0048
		sh		s6,$0804(t9)
		lw		a0,$0000(t8)
		lui		a3,$FF00
		and		a0,a0,a3
		li		a3,$00FFFFFF
		and		a3,a3,v0
		or		a0,a0,a3
		sw		a0,$0000(t8)
		or		t8,v0,zero
		subiu	v0,v0,$0048

nolinkAtt13
		beq		at,s6,nolinkAtt14
		nop

		addiu	v0,v0,$006C
		sh		s6,$0806(t9)
		lw		a0,$0000(t8)
		lui		a3,$FF00
		and		a0,a0,a3
		li		a3,$00FFFFFF
		and		a3,a3,v0
		or		a0,a0,a3
		sw		a0,$0000(t8)
		or		t8,v0,zero
		subiu	v0,v0,$006C

nolinkAtt14
		lw		at,$0844(t9)	;load time for 2 tiles
		nop
		andi	a0,at,$FFFF
		beq		a0,s6,nolinkAtt23
		srl		at,at,$10

		addiu	v0,v0,$04C8
		sh		s6,$0844(t9)
		lw		a0,$0000(t8)
		lui		a3,$FF00
		and		a0,a0,a3
		li		a3,$00FFFFFF
		and		a3,a3,v0
		or		a0,a0,a3
		sw		a0,$0000(t8)
		or		t8,v0,zero
		subiu	v0,v0,$04C8

nolinkAtt23
		beq		at,s6,nolinkAtt24
		nop

		addiu	v0,v0,$04EC
		sh		s6,$0846(t9)
		lw		a0,$0000(t8)
		lui		a3,$FF00
		and		a0,a0,a3
		li		a3,$00FFFFFF
		and		a3,a3,v0
		or		a0,a0,a3
		sw		a0,$0000(t8)
		or		t8,v0,zero
		subiu	v0,v0,$04EC

nolinkAtt24

		srl		v1,v1,$03
		li		at,$07
		beq		at,v1,noBottom		;skip the second 2 rows if you're doing 28 and 29 (there are no 30 or 31)
		nop

		andi	a3,a1,$01
		sll		a3,a3,$01
		andi	at,a1,$02
		sll		at,at,$0F+$03
		or		at,a3,at

		srl		a1,a1,$02

		li		gp,$FFF7FFFD
		
		lw		a0,$0008+$900(v0)
		lw		a3,$002C+$900(v0)
		and		a0,a0,gp
		and		a3,a3,gp
		or		a0,a0,at
		or		a3,a3,at
		sw		a0,$0008+$900(v0)
		sw		a3,$002C+$900(v0)

		lw		a0,$0488+$900(v0)
		lw		a3,$04AC+$900(v0)
		and		a0,a0,gp
		and		a3,a3,gp
		or		a0,a0,at
		or		a3,a3,at
		sw		a0,$0488+$900(v0)
		sw		a3,$04AC+$900(v0)
		
		lw		at,$0880(t9)	;load time for 2 tiles
		nop
		andi	a0,at,$FFFF
		beq		a0,s6,nolinkAtt31
		srl		at,at,$10

		addiu	v0,v0,$0900
		sh		s6,$0880(t9)
		lw		a0,$0000(t8)
		lui		a3,$FF00
		and		a0,a0,a3
		li		a3,$00FFFFFF
		and		a3,a3,v0
		or		a0,a0,a3
		sw		a0,$0000(t8)
		or		t8,v0,zero
		subiu	v0,v0,$0900

nolinkAtt31
		beq		at,s6,nolinkAtt32
		nop

		addiu	v0,v0,$0924
		sh		s6,$0882(t9)
		lw		a0,$0000(t8)
		lui		a3,$FF00
		and		a0,a0,a3
		li		a3,$00FFFFFF
		and		a3,a3,v0
		or		a0,a0,a3
		sw		a0,$0000(t8)
		or		t8,v0,zero
		subiu	v0,v0,$0924

nolinkAtt32
		lw		at,$08C0(t9)	;load time for 2 tiles
		nop
		andi	a0,at,$FFFF
		beq		a0,s6,nolinkAtt41
		srl		at,at,$10

		addiu	v0,v0,$0D80
		sh		s6,$08C0(t9)
		lw		a0,$0000(t8)
		lui		a3,$FF00
		and		a0,a0,a3
		li		a3,$00FFFFFF
		and		a3,a3,v0
		or		a0,a0,a3
		sw		a0,$0000(t8)
		or		t8,v0,zero
		subiu	v0,v0,$0D80

nolinkAtt41
		beq		at,s6,nolinkAtt42
		nop

		addiu	v0,v0,$0DA4
		sh		s6,$08C2(t9)
		lw		a0,$0000(t8)
		lui		a3,$FF00
		and		a0,a0,a3
		li		a3,$00FFFFFF
		and		a3,a3,v0
		or		a0,a0,a3
		sw		a0,$0000(t8)
		or		t8,v0,zero
		subiu	v0,v0,$0DA4

nolinkAtt42

		andi	a3,a1,$01
		sll		a3,a3,$01
		andi	at,a1,$02
		sll		at,at,$0F+$03
		or		at,a3,at

		srl		a1,a1,$02

		li		gp,$FFF7FFFD
		
		lw		a0,$0050+$900(v0)
		lw		a3,$0074+$900(v0)
		and		a0,a0,gp
		and		a3,a3,gp
		or		a0,a0,at
		or		a3,a3,at
		sw		a0,$0050+$900(v0)
		sw		a3,$0074+$900(v0)

		lw		a0,$04D0+$900(v0)
		lw		a3,$04F4+$900(v0)
		and		a0,a0,gp
		and		a3,a3,gp
		or		a0,a0,at
		or		a3,a3,at
		sw		a0,$04D0+$900(v0)
		sw		a3,$04F4+$900(v0)

		lw		at,$0884(t9)	;load time for 2 tiles
		nop
		andi	a0,at,$FFFF
		beq		a0,s6,nolinkAtt33
		srl		at,at,$10

		addiu	v0,v0,$0948
		sh		s6,$0884(t9)
		lw		a0,$0000(t8)
		lui		a3,$FF00
		and		a0,a0,a3
		li		a3,$00FFFFFF
		and		a3,a3,v0
		or		a0,a0,a3
		sw		a0,$0000(t8)
		or		t8,v0,zero
		subiu	v0,v0,$0948

nolinkAtt33
		beq		at,s6,nolinkAtt34
		nop

		addiu	v0,v0,$096C
		sh		s6,$0886(t9)
		lw		a0,$0000(t8)
		lui		a3,$FF00
		and		a0,a0,a3
		li		a3,$00FFFFFF
		and		a3,a3,v0
		or		a0,a0,a3
		sw		a0,$0000(t8)
		or		t8,v0,zero
		subiu	v0,v0,$096C

nolinkAtt34
		lw		at,$08C4(t9)	;load time for 2 tiles
		nop
		andi	a0,at,$FFFF
		beq		a0,s6,nolinkAtt43
		srl		at,at,$10

		addiu	v0,v0,$0DC8
		sh		s6,$08C4(t9)
		lw		a0,$0000(t8)
		lui		a3,$FF00
		and		a0,a0,a3
		li		a3,$00FFFFFF
		and		a3,a3,v0
		or		a0,a0,a3
		sw		a0,$0000(t8)
		or		t8,v0,zero
		subiu	v0,v0,$0DC8

nolinkAtt43
		beq		at,s6,nolinkAtt44
		nop

		addiu	v0,v0,$0DEC
		sh		s6,$08C6(t9)
		lw		a0,$0000(t8)
		lui		a3,$FF00
		and		a0,a0,a3
		li		a3,$00FFFFFF
		and		a3,a3,v0
		or		a0,a0,a3
		sw		a0,$0000(t8)
		or		t8,v0,zero
		subiu	v0,v0,$0DEC

nolinkAtt44
noBottom
		sw		t8,lastChange

		jr		ra
		nop

namePart
;nameMirrorSelect
		
		sll		gp,at,$7

		li		v0,34560
		multu	at,v0
		mflo	v0
		la		v1,bg1DMAlist
		addu	v0,v0,v1
		andi	at,t8,$03FF
		li		v1,36
		multu	at,v1
		mflo	v1
		addu	v0,v0,v1			; v0 now has addr of the prim to modify

		lhu		v1,renderTimeStamp	;get current timestamp
		li		a3,$80022800
		andi	a2,t8,$03E0
		srl		a2,a2,$03
		addu	a3,a3,a2
		addu	a3,a3,gp
		lw		a3,$0000(a3)		;load the blocks for this tile row
		andi	a2,a1,$C0
		srl		a2,a2,$03
		srlv	a3,a3,a2
		andi	a3,a3,$FF			;get this specific block
		andi	a2,a3,$07
		lbu		at,blockMask
		sll		a2,a2,$16
		and		a3,a3,at
		sll		a3,a3,$03
		or		a2,a2,a3			;a2 has base YYYYXXXX

		andi	a3,a1,$1E
		sll		a3,a3,$01		;remember this is # of 16 bit pixels, not 4 bit
		addu	a2,a2,a3
		andi	a3,a1,$20
		sll		a3,a3,$10
		addu	a2,a2,a3			; a2 now has src Y_X for the prim
		andi	a3,a1,$01
		sll		a3,a3,$14
		addu	a2,a2,a3

		lw		a3,$0008(v0)
		li		gp,$00080002
		and		a3,a3,gp
		or		a2,a3,a2

		beq		s6,v1,dontLink		;don't link in if same timestamps
		sw		a2,$0008(v0)

		sh		v1,$0800(t9)		;save timestamp
		lw		v1,lastChange
		lui		a3,$FF00
		lw		a2,$0000(v1)
		li		a1,$00FFFFFF
		and		a2,a2,a3
		and		a3,v0,a1
		or		a3,a2,a3
		sw		a3,$0000(v1)		; link last to this one
		sw		v0,lastChange		; set the last changed to this one

		sb		s5,needToRender		;tell that you need to redraw
dontLink
		jr		ra
		nop

PPUWriteNameMap9

		lw		at,mirrorSel
		srl		v0,t8,$0A
		andi	v0,v0,$03
		srlv	at,at,v0
		andi	at,at,$01

		sll		v0,at,$0A
		lui		v1,$8002
		or		v1,v1,v0			;store the byte
		andi	v0,t8,$03FF
		addu	t9,v1,v0
		lbu		a0,$2000(t9)		;get the old value to compare
		andi	s6,t9,$07FF
		sb		a1,$2000(t9)
		sll		s6,s6,$01
		addu	t9,s6,s7
		lhu		s6,$0800(t9)		;get the old timestamp

		beq		a0,a1,PPUreturn		;quit if it hasn't changed
		subiu	v1,v0,$03C0
		bgez	v1,attrPart
		nop

;name part for mapper 9

		sll		gp,at,$0A		;calc addr in table that tells:
		lui		a3,$8002		; 0 = tile FD or FE, no update
		or		a3,a3,gp		; 1 = tile belongs to FD group for update
		andi	gp,t8,$03FF		; 2 = tile belongs to FE group for update
		or		a3,a3,gp

		addiu	v0,a1,$02
		andi	v0,v0,$FF
		beqz	v0,isSpecial
		addiu	v0,a1,$03
		andi	v0,v0,$FF
		bnez	v0,notSpecial
		nop

isSpecial
		addiu	gp,a1,$04
		andi	gp,gp,$FF
		j		doTileUpdate
		sb		zero,$0000(a3)

notSpecial

		ori		v0,a3,$2000			; make v0 point into actual tile data
		subiu	v0,v0,$01
specialSearchLoop
		lbu		v1,$0000(v0)
		nop
		addiu	a2,v1,$03
		andi	a2,a2,$FF
		beqz	a2,foundGroup
		addiu	a2,v1,$02
		andi	a2,a2,$FF
		beqz	a2,foundGroup
		andi	a2,v0,$3FF
		bnez	a2,specialSearchLoop
		subiu	v0,v0,$01

		li		v1,$FE

foundGroup
		addiu	gp,v1,$04
		sb		gp,$0000(a3)
		andi	gp,gp,$FF

doTileUpdate
		li		v0,34560
		multu	at,v0
		mflo	v0
		la		v1,bg1DMAlist
		addu	v0,v0,v1
		andi	at,t8,$03FF
		li		v1,36
		multu	at,v1
		mflo	v1
		addu	v0,v0,v1			; v0 now has addr of the prim to modify

		lhu		v1,renderTimeStamp	;get current timestamp
		la		a3,map9_fd_bg
		subiu	gp,gp,$01
		sll		gp,gp,$02
		addu	a3,a3,gp
		lw		a3,$0000(a3)		;load the blocks for this tile
		andi	a2,a1,$C0
		srl		a2,a2,$03
		srlv	a3,a3,a2
		andi	a3,a3,$FF			;get this specific block
		andi	a2,a3,$07
		lbu		at,blockMask
		sll		a2,a2,$16
		and		a3,a3,at
		sll		a3,a3,$03
		or		a2,a2,a3			;a2 has base YYYYXXXX

		andi	a3,a1,$1E
		sll		a3,a3,$01		;remember this is # of 16 bit pixels, not 4 bit
		addu	a2,a2,a3
		andi	a3,a1,$20
		sll		a3,a3,$10
		addu	a2,a2,a3			; a2 now has src Y_X for the prim
		andi	a3,a1,$01
		sll		a3,a3,$14
		addu	a2,a2,a3

		lw		a3,$0008(v0)
		li		gp,$00080002
		and		a3,a3,gp
		or		a2,a3,a2

		beq		s6,v1,dontLink9		;don't link in if same timestamps
		sw		a2,$0008(v0)

		sh		v1,$0800(t9)		;save timestamp
		lw		v1,lastChange
		lui		a3,$FF00
		lw		a2,$0000(v1)
		li		s6,$00FFFFFF
		and		a2,a2,a3
		and		a3,v0,s6
		or		a3,a2,a3
		sw		a3,$0000(v1)		; link last to this one
		sw		v0,lastChange		; set the last changed to this one

		sb		s5,needToRender		;tell that you need to redraw

dontLink9

		jr		ra
		nop

PPUWritePal
		subiu	at,t8,$3F00
		bltz	at,notPal		; if wrote to palette
		nop

		andi	t8,t8,$3F1F
		andi	a1,a1,$3F

		andi	t9,t8,$0003
		beqz	t9,wroteBackCol
		lui		a2,$8002
		or		a2,t8,a2
		lbu		v0,$0000(a2)	;get the old value
		andi	s6,a2,$1F
		sll		s6,s6,$01
		ori		s6,s6,$3F00
		lui		a3,$8002
		or		s6,s6,a3
		lhu		s6,$0020(s6)	;get the time stamp
		sb		a1,$0000(a2)	;store the byte

		beq		v0,a1,notPal		;compare old and new
		nop

		lhu		a3,renderTimeStamp	;get the current time stamp
		la		at,pal
		sll		a1,a1,$02
		addu	at,at,a1
		lw		a1,$0000(at)		;load the color

		andi	v0,t8,$10
		bnez	v0,isSprPal
		nop

		la		at,palDMAlist
		andi	v0,t8,$F
		sll		v1,v0,$03
		sll		v0,v0,$02
		addu	v0,v0,v1
		addu	at,at,v0		;at has addr of prim
		
		j		afterPalUpdate
		sw		a1,$0004(at)

isSprPal

		la		at,sprPalDMAlist
		andi	v0,t8,$F
		sll		v1,v0,$05
		sll		v0,v0,$02
		addu	v0,v0,v1
		addu	at,at,v0		;at has addr of prim

		sw		a1,$0004(at)
		sw		a1,$000C(at)
		sw		a1,$0014(at)
		sw		a1,$001C(at)

afterPalUpdate
		beq		s6,a3,notPal	;if on same timestamp, don't link into list
		nop		
		
		andi	v0,a2,$1F
		sll		v0,v0,$01
		ori		v0,v0,$3F00
		lui		v1,$8002
		or		v0,v0,v1
		sh		a3,$0020(v0)	;save the current time stamp
		or		v0,at,zero
		lw		v1,lastChange
		lui		a3,$FF00
		lw		a2,$0000(v1)
		li		a1,$00FFFFFF
		and		a2,a2,a3
		and		a3,v0,a1
		or		a3,a2,a3
		sw		a3,$0000(v1)		; link last to this one
		sw		v0,lastChange		; set the last changed to this one

		sb		s5,needToRender		;tell that you need to redraw

		j		notPal
		nop

wroteBackCol
		andi	t9,t8,$000F
		bnez	t9,notPal	;if wrote to index 0 of BG *OR* spr pal
		nop

		la		a0,pal
		sll		a1,a1,$02
		addu	a0,a0,a1
		lw		a0,$0000(a0)
		lui		at,$0800
		xor		a0,a0,at			;take out the 8 to make this command 60, rectangle
		sw		a0,bgRect+8

notPal
		jr		ra
		nop

write2006
		lbu		t9,wantLo2006
		nop
		bgtz	t9,wantLo
		nop

		andi	a1,a1,$3F
		sb		a1,$1803(s7)	;store to the high internal addr byte
		
		sb		s5,wantLo2006
		nop
		jr		ra
		nop
wantLo
		sb		a1,$1802(s7)	;store to the low addr byte
		nop

		lhu		t9,$1802(s7)
		nop
		sh		t9,$1800(s7)	;set the vram access address to this
		
		sb		zero,wantLo2006
		sb		s5,needToRender		;tell that you need to redraw

		jr		ra
		nop

write2005
		lbu		t9,wantLo2006
		nop
		bgtz	t9,wantLoscroll
		nop

		andi	t9,a1,$07
		sw		t9, fineX

		srl		a1,a1,$03
		lbu		t9,$1802(s7)
		nop
		andi	t9,t9,$E0			; set x tile scroll in internal
		or		t9,t9,a1			; VRAM address
		sb		t9,$1802(s7)

		sb		s5,wantLo2006
		sb		s5,needToRender		;tell that you need to redraw
		jr		ra
		nop

wantLoscroll	;verticle scroll
		sll		t8,a1,$04
		andi	t8,t8,$70
		srl		t9,a1,$06
		lbu		v0,$1803(s7)
		nop
		andi	v0,v0,$8C
		or		v0,v0,t8
		or		v0,v0,t9
		sb		v0,$1803(s7)

		sll		t8,a1,$02
		andi	t8,t8,$E0
		lbu		v0,$1802(s7)
		nop
		andi	v0,v0,$1F
		or		v0,v0,t8
		sb		v0,$1802(s7)

		sb		zero,wantLo2006
		sb		s5,needToRender		;tell that you need to redraw
		jr		ra
		nop

write2004	;sprRAM data reg
		lbu		t9,$2003(s7)
		la		t8,sprRAM
		addu	at,t8,t9
		sb		a1,$0000(at)
		addiu	at,t9,$01
		sb		at,$2003(s7)

		;andi	t9,t9,$FC
		;addu	t8,t8,t9
		;lw		at,$0000(t8)
		;la		a2, BSprim1
		;srl		a1,t9,$02
		;li		a0,$30
		;mult	a0,a1
		;mflo	a1
		;addu	a2,a2,a1

		;srl		v0,at,$18	;x coord
		;and		v1,at,$FF	;y coord
		;addiu	v1,v1,$01

		;subiu	gp,v1,$F0
		;srl		gp,gp,$1C	;limit Y pos to 240
		;ori		gp,gp,$F0
		;and		v1,v1,gp
			
		;sll		v1,v1,$10
		;or		v0,v0,v1
		;srl		v1,at,$15
		;andi	v1,v1,$01		;make it at +256 up and down if back sprite
		;sll		v1,v1,$18
		;or		v0,v0,v1
		;sw		v0,$0008(a2)	;set the new X,Y on screen for 8x8

		;srl		v1,at,$14		;v-flip the positions of the 2 tiles
		;andi	v1,v1,$08
		;sll		gp,v1,$10
		;addu	a0,v0,gp
		;sw		a0,$001C(a2)	;set the new X,Y on screen for 8x16 first half

		;xori	v1,v1,$08
		;sll		gp,v1,$10
		;addu	a0,v0,gp
		;sw		a0,$0028(a2)	;set the X,Y for the second half of 8x16

		;lui		gp,$0003
		;and		v1,at,gp		;color bits

		;andi	v0,at,$F800
		;or		v1,v1,v0		;y tex
		;srl		v0,at,$03
		;andi	v0,v0,$E0
		;or		v1,v1,v0		;x tex

		;srl		v0,at,$13
		;andi	v0,v0,$18
		;addu	v1,v1,v0		;flipping (+x tex)

		;sw		v1,$000C(a2)	;set the CLUT,y,x
		;li		v0,$FFFFFFDF
		;and		v1,v1,v0		;make x even
		;sw		v1,$0020(a2)	;set the CLUT,y,x for 8x16 first half
		;addu	v1,v1,$20
		;sw		v1,$002C(a2)	;set the CLUT,y,x for 8x16 second half

		;andi	v0,at,$0100
		;srl		v0,v0,$08		;which texture page for the 8x16 version
		;ori		v0,v0,$04
		;sb		v0,$0014(a2)

		jr		ra
		nop

write2000
		sb		a1,$2000(s7)

		li		v0,$01
		sll		at,a1,$1D
		sra		at,at,$04		;store VRAM addr inc amount
		srl		at,at,$1B
		addu	v0,v0,at
		sb		v0,$1804(s7)

		lbu		t9,$1803(s7)
		sll		a1,a1,$02
		andi	a1,a1,$0C
		andi	t9,t9,$F3		; update the internal VRAM addr
		or		t9,t9,a1
		sb		t9,$1803(s7)

		sb		s5,needToRender

		jr		ra
		nop

write2001
		sb		a1,$2001(s7)

		andi	v0,a1,$02
		xori	v0,v0,$02
		sll		v0,v0,$02
		sb		v0,NT2screen+4

		andi	v0,a1,$04
		xori	v0,v0,$04
		sll		v0,v0,$01
		sb		v0,spriteHead+8

		jr		ra
		nop

write2002
write2003
		or		at,t8,s7
		sb		a1,$2000(at)
		jr		ra
		nop

map0write
		jr		ra
		nop

include		mapper01.asm

map2write
		or		t8,ra,zero
		li		a0,$4
		jal		bankSwitch
		sll		a1,a1,$01
		j		bankSwitch
		or		ra,t8,zero

map3write
		lui		t8,mapReg0>>16
		lbu		t9,mapReg0(t8)
		sll		a0,a1,$03
		beq		t9,a1,map3skip
		nop
		
		sb		a1,mapReg0(t8)
		sw		ra,saveFP
		
		jal		bufLoadVROM
		li		a1,$00
		jal		bufLoadVROM		;pattern 0
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
		jal		bufLoadVROM
		nop

		lw		ra,saveFP
		nop
map3skip
		jr		ra
		nop

include mapper04.asm

include mapper05.asm

include mapper33.asm

map7write
		sll		v0,a1,$1B
		sra		v0,v0,$03
		srl		v0,v0,$1C
		sb		v0,mirrorSel
		sb		s5,needToRender

		or		t8,ra,zero

		andi	a1,a1,$0F
		li		a0,$4
		jal		bankSwitch
		sll		a1,a1,$02
		jal		bankSwitch
		nop
		jal		bankSwitch
		nop
		jal		bankSwitch
		nop

		jr		t8
		nop

map10writeA
		sw		ra,saveFP

		li		a0,$04
		jal		bankSwitch
		sll		a1,a1,1
		lw		ra,saveFP
		j		bankSwitch
		nop

map9writeA
		j		bankSwitch
		li		a0,$04
		
map9writeB
		sw		ra,saveFP

		lbu		t8,mapReg0
		nop
		beq		t8,a1,map9return
		nop

		sb		a1,mapReg0

		la		t8,map9_fd_sprites
		lbu		a2,$0000(t8)
		lbu		a3,$0004(t8)
		lbu		v0,$0008(t8)
		lbu		v1,$000C(t8)
		sll		a3,a3,$08
		or		a2,a2,a3
		sll		v0,v0,$10
		or		a2,a2,v0
		sll		v1,v1,$18
		or		a2,a2,v1
		sw		a2,BLOCKS(s7)
		
		sll		a0,a1,$02
		jal		bufLoadVROM
		li		a1,$0
		jal		bufLoadVROM
		nop
		jal		bufLoadVROM
		nop
		jal		bufLoadVROM
		nop

		li		a3,$03020100
		lw		ra,BLOCKS(s7)
		sw		a3,BLOCKS(s7)
		sw		ra,map9_fd_sprites

		lw		ra,saveFP
		nop
map9return
		jr		ra
		nop

map9writeC
		sw		ra,saveFP

		lbu		t8,mapReg1
		nop
		beq		t8,a1,map9return
		nop

		sb		a1,mapReg1

		la		t8,map9_fd_sprites
		lbu		a2,$0000(t8)
		lbu		a3,$0004(t8)
		lbu		v0,$0008(t8)
		lbu		v1,$000C(t8)
		sll		a3,a3,$08
		or		a2,a2,a3
		sll		v0,v0,$10
		or		a2,a2,v0
		sll		v1,v1,$18
		or		a2,a2,v1
		sw		a2,BLOCKS(s7)

		sll		a0,a1,$02
		jal		bufLoadVROM
		li		a1,$0
		jal		bufLoadVROM
		nop
		jal		bufLoadVROM
		nop
		jal		bufLoadVROM
		nop

		li		a3,$03020100
		lw		ra,BLOCKS(s7)
		sw		a3,BLOCKS(s7)
		sw		ra,map9_fe_sprites

		lw		ra,saveFP
		nop
		jr		ra
		nop

map9writeD
		sw		ra,saveFP

		lbu		t8,mapReg2
		nop
		beq		t8,a1,map9return
		nop

		sb		a1,mapReg2

		la		t8,map9_fd_sprites
		lbu		a2,$0000(t8)
		lbu		a3,$0004(t8)
		lbu		v0,$0008(t8)
		lbu		v1,$000C(t8)
		sll		a3,a3,$08
		or		a2,a2,a3
		sll		v0,v0,$10
		or		a2,a2,v0
		sll		v1,v1,$18
		or		a2,a2,v1
		sw		a2,BLOCKS+4(s7)

		sll		a0,a1,$02
		jal		bufLoadVROM
		li		a1,$4
		jal		bufLoadVROM
		nop
		jal		bufLoadVROM
		nop
		jal		bufLoadVROM
		nop

		li		a3,$07060504
		lw		ra,BLOCKS+4(s7)
		sw		a3,BLOCKS+4(s7)		;prevent fixrow from working
		sw		ra,map9_fd_bg

		or		a2,ra,zero		; get the blocks that should be used to draw $FD
		jal		map9fix
		li		a0,$01			; looking for FD (1)

		lw		ra,saveFP
		nop
		jr		ra
		nop

map9writeE
		sw		ra,saveFP

		lbu		t8,mapReg3
		nop
		beq		t8,a1,map9return
		nop

		sb		a1,mapReg3

		la		t8,map9_fd_sprites
		lbu		a2,$0000(t8)
		lbu		a3,$0004(t8)
		lbu		v0,$0008(t8)
		lbu		v1,$000C(t8)
		sll		a3,a3,$08
		or		a2,a2,a3
		sll		v0,v0,$10
		or		a2,a2,v0
		sll		v1,v1,$18
		or		a2,a2,v1
		sw		a2,BLOCKS+4(s7)

		sll		a0,a1,$02
		jal		bufLoadVROM
		li		a1,$4
		jal		bufLoadVROM
		nop
		jal		bufLoadVROM
		nop
		jal		bufLoadVROM
		nop

		li		a3,$07060504
		lw		ra,BLOCKS+4(s7)
		sw		a3,BLOCKS+4(s7)		;prevent fixrow from working
		sw		ra,map9_fe_bg

		or		a2,ra,zero		; get the blocks that should be used to draw $FE
		jal		map9fix
		li		a0,$02			; looking for FE (2)

		lw		ra,saveFP
		nop
		jr		ra
		nop

map9writeF
		la		at,map1mirrors+2
		andi	a1,a1,$01
		addu	at,at,a1
		lbu		t8,$0000(at)
		nop
		sb		t8,mirrorSel
		jr		ra
		nop

map34write
		or		t8,ra,zero

		li		a0,$4
		jal		bankSwitch
		sll		a1,a1,$02
		jal		bankSwitch
		nop
		jal		bankSwitch
		nop
		jal		bankSwitch
		nop

		jr		t8
		nop

map69write8
		andi	a1,a1,$F
		sb		a1,mapReg0		; store the command
		jr		ra
		nop

map69writeA
		lbu		a0,mapReg0		; get the command
		nop
		andi	at,a0,$F8
		bnez	at,map69not0_7
		nop

		sw		ra,saveFP

		or		at,a0,zero
		or		a0,a1,zero		;a0=which 1k page
		jal		bufLoadVROM
		or		a1,at,zero

		lw		ra,saveFP
		nop
map69return
		jr		ra
		nop

map69not0_7
		andi	at,a0,$4
		bnez	at,map69not8_B
		nop

subiu at,a0,$08
bnez at,nobrk69
nop

lbu	t8,mapReg1
nop
beq a1,t8,sameold69
nop
;break
sameold69
sb a1,mapReg1

andi at,a1,$40
bnez at,map69putInWram
nop
nobrk69
		andi	a0,a0,$F
		j		bankSwitch		;a1 already has bank #
		subiu	a0,a0,$05

map69putInWram
		andi	at,a1,$80
		beqz	at,map69return
		nop
		sw		s7,bankptrlo+$C
		jr		ra
		nop

map69not8_B
		li		at,$0C
		bne		at,a0,map69notMirror
		nop

		la		a0,map1mirrors+2
		andi	a1,a1,$03
		addu	a0,a0,a1
		lbu		a0,$0000(a0)
		li		a1,$01
		sb		a0,mirrorSel
		sb		a1,needToRender
		
		jr		ra
		nop

map69notMirror
		li		at,$0D
		bne		at,a0,not69IRQ
		nop
		
		li		t8,$0
		beqz	a1,nomap69irqon
		nop

		la		t8,map69hsync

nomap69irqon

		sw		t8,mapHsyncFunc

		jr		ra
		nop

not69IRQ
		li		at,$0E
		bne		at,a0,not69lo
		nop

		lhu		a0,map4irq
		nop
		andi	a0,a0,$FF00
		andi	a1,a1,$FF
		or		a0,a0,a1
		sh		a0,map4irq

		jr		ra
		nop

not69lo	;means this is 69hi

		lhu		a0,map4irq
		lw		t8,scanLine
		andi	a0,a0,$00FF
		andi	a1,a1,$FF
		sll		a1,a1,$08
		or		a0,a0,a1

		slti	at,t8,240
		bnez	at,notInV69
		nop

		li		at,262
		subu	t8,at,t8
		li		at,113
		multu	at,t8
		mflo	t8
		subu	a0,a0,t8

notInV69
		sh		a0,map4irq

		jr		ra
		nop

map71write9
		la		a0,map1mirrors
		andi	a1,a1,$10
		srl		a1,a1,$04
		addu	a0,a0,a1
		lbu		a1,$0000(a0)
		li		t8,$01
		sb		a1,mirrorSel
		sb		t8,needToRender

		jr		ra
		nop

map71writeC
		or		t8,ra,zero
		li		a0,$04
		jal		bankSwitch
		sll		a1,a1,$01
		j		bankSwitch
		or		ra,t8,zero
		
map11write
		sw		ra,saveFP
		or		t8,a1,zero

		andi	a1,a1,$F
		sll		a1,a1,$02
		jal		bankSwitch
		li		a0,$04
		jal		bankSwitch
		nop
		jal		bankSwitch
		nop
		jal		bankSwitch
		nop
		
		srl		a0,t8,$04
		li		a1,$00
		jal		bufLoadVROM
		sll		a0,a0,$03
		jal		bufLoadVROM		;pattern 0
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
		jal		bufLoadVROM
		nop

		lw		ra,saveFP
		nop
		jr		ra
		nop

map66write
		sw		ra,saveFP
		or		t8,a1,zero

		srl		a1,a1,$4
		sll		a1,a1,$02
		jal		bankSwitch
		li		a0,$04
		jal		bankSwitch
		nop
		jal		bankSwitch
		nop
		jal		bankSwitch
		nop
		
		andi	a0,t8,$F
		li		a1,$00
		jal		bufLoadVROM
		sll		a0,a0,$03
		jal		bufLoadVROM		;pattern 0
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
		jal		bufLoadVROM
		nop

		lw		ra,saveFP
		nop
		jr		ra
		nop
		
map38write
		sw		ra,saveFP

		li		a0,$04
		move	v1,a1
		andi		a1,v1,$3
		
		jal		bankSwitch
		sll		a1,a1,$02
		jal		bankSwitch
		nop
		jal		bankSwitch
		nop
		jal		bankSwitch
		nop
		
		li		a1,$00
		srl		a0,v1,$2
		andi		a0,$3
		jal		bufLoadVROM
		sll		a0,$3
		jal		bufLoadVROM		;pattern 0
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
		jal		bufLoadVROM
		nop

		lw		ra,saveFP
		nop
		jr		ra
		nop

map87write
		sw		ra,saveFP
	
		move	v1,a1
		andi		a1,1
		sll		a1,1
		srl		v1,1
		andi		v1,1
		or		a0,a1,v1

		li		a1,0
		jal		bufLoadVROM
		sll		a0,$3
		jal		bufLoadVROM		;pattern 0
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
		jal		bufLoadVROM
		nop

		lw		ra,saveFP
		nop
		jr		ra
		nop

map140write
		j		map66write
		nop

map180write
		or		t8,ra,zero
		li		a0,$6
		jal		bankSwitch
		sll		a1,a1,$01
		j		bankSwitch
		or		ra,t8,zero
		
map185write
		li		v1,chrDisabled

		li		a0,$13
		beq		a0,a1,map185disablechr
		nop
		andi		a1,$F
		beq		a1,zero,map185disablechr
		nop

; enable chr
		sb		zero,0(v1)

		jr		ra
		nop
		
map185disablechr
; disable chr
		li		a0,$1
		sb		a0,0(v1)
		
		jr		ra
		nop
		
map70write
		sw		ra,saveFP

		move	v1,a1

		li		$a0,4
		srl		a1,4
		jal		bankSwitch
		sll		a1,1
		jal		bankSwitch
		nop
		
		and		a0,v1,$F
		li		a1,0
		jal		bufLoadVROM
		sll		a0,$3
		jal		bufLoadVROM		;pattern 0
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
		jal		bufLoadVROM
		nop
		
		lw		ra,saveFP
		nop
		jr		ra
		nop
		
map79write
		sw		ra,saveFP

		andi		v1,a1,7
		srl		a1,3
		andi		a1,7
		
; a1 = prg reg, v1 = chr reg
		sw		v1,map79chr

		li		a0,$4
		jal		bankSwitch
		sll		a1,2
		jal		bankSwitch
		nop
		jal		bankSwitch
		nop
		jal		bankSwitch
		nop
		
		li		a1,$00
		lw		a0,map79chr
		nop
		jal		bufLoadVROM
		sll		a0,v1,3
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
		
map79chr		dw 0

justwrite50
		or		at,t8,s7
		or		at,at,a0
		jr		ra
		sb		a1,$6000(at)

read4015
		li		a0,$04
		li		a1,$0
		la		a2,sq1Timer
readTimersLoop
		lbu		at,$0000(a2)
		addiu	a2,a2,$04
		sltu	at,zero,at
		srl		a1,a1,$01
		sll		at,at,$03
		or		a1,a1,at
		subiu	a0,a0,$01
		bnez	a0,readTimersLoop
		nop

		lbu		at,$4015(s7)
		nop
		andi	at,at,$10
		or		a1,a1,at

		andi	a1,a1,$F			;tmp hack, need real DMC on/off detection

		jr		ra
		nop

read4016
		lw		v0,pad1_nes
		nop
		andi	a1,v0,$01
		srl		v0,v0,$01
		sw		v0,pad1_nes
		jr		ra
		ori		a1,a1,$40
		
read4017
		lw		v0,pad2_nes
		nop
		andi	a1,v0,$01
		srl		v0,v0,$01
		sw		v0,pad2_nes
		jr		ra
		ori		a1,a1,$40

write4000
write4001
write4002
write4003

		lw		a0,scanLine
		la		t9,soundRegs

		li		at,43
		slt		a2,at,a0

		li		at,108
		slt		at,at,a0
		addu	a2,a2,at

		li		at,173
		slt		at,at,a0
		addu	a2,a2,at

		sll		a2,a2,$05
		addu	t9,t9,a2
		andi	t8,t8,$03
		sll		at,t8,$01
		addu	t9,t9,at

		ori		a1,a1,$0100
		sh		a1,$0000(t9)

		li		at,$03
		beq		t8,at,sq1TimerWrite
		nop

		jr		ra
		nop

sq1TimerWrite

		srl		at,a1,$03
		andi	at,at,$1F
		la		t8,xlatTime
		addu	t8,t8,at
		lbu		t8,$0000(t8)
		nop
		sb		t8,sq1Timer
		jr		ra
		nop

write4004
write4005
write4006
write4007

		lw		a0,scanLine
		la		t9,soundRegs

		li		at,43
		slt		a2,at,a0

		li		at,108
		slt		at,at,a0
		addu	a2,a2,at

		li		at,173
		slt		at,at,a0
		addu	a2,a2,at

		sll		a2,a2,$05
		addu	t9,t9,a2
		andi	t8,t8,$07
		sll		at,t8,$01
		addu	t9,t9,at

		ori		a1,a1,$0100
		sh		a1,$0000(t9)

		li		at,$07
		beq		t8,at,sq2TimerWrite
		nop

		jr		ra
		nop

sq2TimerWrite

		srl		at,a1,$03
		andi	at,at,$1F
		la		t8,xlatTime
		addu	t8,t8,at
		lbu		t8,$0000(t8)
		nop
		sb		t8,sq2Timer
		jr		ra
		nop

write4008
write4009
write400A
write400B

		lw		a0,scanLine
		la		t9,soundRegs

		li		at,43
		slt		a2,at,a0

		li		at,108
		slt		at,at,a0
		addu	a2,a2,at

		li		at,173
		slt		at,at,a0
		addu	a2,a2,at

		sll		a2,a2,$05
		addu	t9,t9,a2
		andi	t8,t8,$0F		;bubble bobble writes to $408A for sound so this needs a mask
		sll		at,t8,$01
		addu	t9,t9,at

		ori		a1,a1,$0100
		sh		a1,$0000(t9)

		li		at,$0B
		beq		t8,at,triTimerWrite
		nop

		jr		ra
		nop

triTimerWrite

		srl		at,a1,$03
		andi	at,at,$1F
		la		t8,xlatTime
		addu	t8,t8,at
		lbu		t8,$0000(t8)
		nop
		sb		t8,triTimer
		jr		ra
		nop

write400C
write400D
write400E
write400F

		lw		a0,scanLine
		la		t9,soundRegs

		li		at,43
		slt		a2,at,a0

		li		at,108
		slt		at,at,a0
		addu	a2,a2,at

		li		at,173
		slt		at,at,a0
		addu	a2,a2,at

		sll		a2,a2,$05
		addu	t9,t9,a2
		andi	t8,t8,$0F			;mask the addr for games that want to be diffcult
		sll		at,t8,$01
		addu	t9,t9,at

		ori		a1,a1,$0100
		sh		a1,$0000(t9)

		li		at,$0F
		beq		t8,at,noiseTimerWrite
		nop

		jr		ra
		nop

noiseTimerWrite

		srl		at,a1,$03
		andi	at,at,$1F
		la		t8,xlatTime
		addu	t8,t8,at
		lbu		t8,$0000(t8)
		nop
		sb		t8,noiseTimer
		jr		ra
		nop
		
write4010
		jr		ra
		sb		a1,$4010(s7)

write4011
		jr		ra
		sb		a1,$4011(s7)

write4012
		jr		ra
		sb		a1,$4012(s7)

write4013
		jr		ra
		sb		a1,$4013(s7)

write4014	;SPR RAM DMA reg

		sll		a1,a1,$08
		or		gp,a1,s7
		la		t9,sprRAM				;start address
		addiu	t8,t9,$100				;dest addr
		
sprRAMCopyLoop
		lw		v0,$0000(gp)
		lw		v1,$0004(gp)
		lw		a0,$0008(gp)
		lw		a1,$000C(gp)
		lw		a2,$0010(gp)
		lw		a3,$0014(gp)
		lw		s5,$0018(gp)
		lw		s6,$001C(gp)
		sw		v0,$0000(t9)
		sw		v1,$0004(t9)
		sw		a0,$0008(t9)
		sw		a1,$000C(t9)
		sw		a2,$0010(t9)
		sw		a3,$0014(t9)
		sw		s5,$0018(t9)
		sw		s6,$001C(t9)
		addiu	t9,t9,$20
		bne		t8,t9,sprRAMCopyLoop
		addiu	gp,gp,$20

		li		s5,$01

		jr		ra
		subiu	t7,t7,$1800

realSpriteSetup
		mtlo	t0				;save t0 in lo reg
		lbu		t0,blockMask
		nop
		ori		t0,t0,$07

		lbu		t8,sprType
		nop
		bnez	t8,do8x16spr
		nop

		la		a2, spriteDMAlist+2772	;point to last sprite prim
		la		t8, sprRAM+$100			;dest addr
		la		t9, sprRAM				;start address for old
		la		a3, sprOnOffRecord

sprDMAloop8x8
		lw		at,$0000(t9)
		addiu	t9,t9,$04

		addiu	v1,at,$01
		andi	v1,v1,$FF
		srl		gp,v1,$03
		addu	gp,a3,gp			;get addr of byte with start of on/off info
		lwl		s6,$0003(gp)
		lwr		s6,$0000(gp)		;get on/off data

		srl		v0,at,$15
		andi	v0,v0,$01
		sllv	v0,s5,v0		;0=in front so set masks, 1=behind so respect masks
		sb		v0,$0004(a2)

		srl		v0,at,$18	;x coord

		andi	gp,v1,$07
		srlv	gp,s6,gp			;get to right starting bit
		andi	gp,gp,$FF
		la		a3,xlatSprInfo		;look up the byte for $HHHHYYYY (H=height, Y=additional Y coord)
		addu	a3,a3,gp
		lbu		a3,$0000(a3)		;load the byte
		nop
		andi	a0,a3,$F
		addu	v1,v1,a0			;add the Yadd to the Y coord
		srl		a3,a3,$04			;a3 is now the height of the 8x8 spr
		bnez	gp,skip8x8kill		;if the byte was 0, kill the H and W to make invisible
		nop
		or		a3,zero,zero
skip8x8kill

		;at this point, a3 has the height of the spr (width is always 8)

		sll		v1,v1,$10	;v1 has y coord
		or		v0,v0,v1	;v0 has x coord

		sw		v0,$000C(a2)
		addiu	gp,v0,$08
		sw		gp,$0014(a2)
		sll		a3,a3,$10
		addu	gp,v0,a3
		sw		gp,$001C(a2)
		addiu	gp,gp,$08
		sw		gp,$0024(a2)

		lbu		v0,sprAddr
		addiu	v1,at,$01
		andi	v1,v1,$FF
		sll		v1,v1,$03
		ori		v1,v1,$8000
		or		v1,v1,s7		;base addr for block lookup

		srl		v0,v0,$01
		addu	v1,v1,v0		;add 4 for second pat table

		lw		v1,$0000(v1)
		andi	v0,at,$C000
		srl		v0,v0,$0B
		srlv	v1,v1,v0
		and 	v1,v1,t0		;get the block #

		andi	v0,v1,$04
		sll		v0,v0,$02
		srl		gp,v1,$03
		or		v0,v0,gp
		ori		v0,v0,$0400
		sh		v0,$001A(a2)	;set tex page location

		srl		v0,at,$10		;color bits
		andi	v0,v0,$03
		addiu	v0,v0,$21
		sh		v0,$0012(a2)

		andi	v1,v1,$03
		sll		v1,v1,$0E

		andi	v0,at,$2000
		or		v1,v1,v0		;y tex
		srl		v1,v1,$08

		sltiu	gp,v1,$01
		sll		gp,gp,$03		;tex position Y is 0, move down to allow flipping
		addu	v1,v1,gp

		srl		v0,at,$05
		andi	v0,v0,$F0		;x tex

		sltiu	gp,v0,$01
		sll		gp,gp,$03		;tex position X is 0, move right to allow flipping
		addu	v0,v0,gp

		srl		s6,at,$04
		andi	s6,s6,$10
		addu	v1,v1,s6

		srl		s6,at,$16
		andi	s6,s6,$01
		beqz	s6,spr8noHFlip
		addiu	gp,v0,$08

		subiu	gp,v0,$01
		addiu	v0,v0,$07

spr8noHFlip

		sb		v0,$0010(a2)
		sb		gp,$0018(a2)
		sb		v0,$0020(a2)
		sb		gp,$0028(a2)

		srl		s6,at,$16
		srl		a3,a3,$10
		andi	s6,s6,$02
		beqz	s6,spr8noVFlip
		addu	gp,v1,a3

		subiu	gp,v1,$01
		addu	v1,v1,a3
		subiu	v1,v1,$01

spr8noVFlip

		sb		v1,$0011(a2)
		sb		v1,$0019(a2)
		sb		gp,$0021(a2)
		sb		gp,$0029(a2)

		la		a3,sprOnOffRecord	;load this back in

		bne		t8,t9,sprDMAloop8x8
		subiu	a2,a2,$2C

		mflo	t0

		jr		ra
		nop

do8x16spr

		la		a2, spriteDMAlist+2772	;point to last sprite prim
		la		t8, sprRAM+$100			;dest addr
		la		t9, sprRAM				;start address for old
		la		a3, sprOnOffRecord

sprDMAloop8x16
		lw		at,$0000(t9)
		addiu	t9,t9,$04

		andi	v1,at,$FF
		addiu	v1,v1,$01
		srl		gp,v1,$03
		addu	gp,a3,gp			;get addr of byte with start of on/off info
		lwl		s6,$0003(gp)
		lwr		s6,$0000(gp)		;get new on/off data

		srl		v0,at,$15
		andi	v0,v0,$01
		sllv	v0,s5,v0		;0=in front so set masks, 1=behind so respect masks
		sb		v0,$0004(a2)

		srl		v0,at,$18	;x coord

		andi	gp,v1,$07
		srlv	s6,s6,gp			;get to right starting bit
		andi	gp,s6,$FF
		srl		a1,s6,$08
		andi	a1,a1,$FF
		la		a3,xlatSprInfo		;look up the byte for $HHHHYYYY (H=height, Y=additional Y coord)
		addu	a1,a3,a1
		addu	a3,a3,gp
		lbu		a3,$0000(a3)		;load the byte
		lbu		a1,$0000(a1)
		andi	a0,a3,$F
		addu	v1,v1,a0			;add the Yadd to the Y coord
		srl		a3,a3,$04			;a3 is now the height of the 8x8 spr
		bnez	gp,skip8x16kill		;if the byte was 0, kill the H and W to make invisible
		nop
		j		dontAddHeight
		or		a3,zero,zero
skip8x16kill
		andi	gp,a1,$F
		bnez	gp,dontAddHeight	;don't add a0's height if there would be a gap in the sprite (just truncate it)
		nop
		srl		a1,a1,$04
		addu	a3,a3,a1
dontAddHeight

		sll		v1,v1,$10
		or		v0,v0,v1

		sw		v0,$000C(a2)
		addiu	gp,v0,$08
		sw		gp,$0014(a2)
		sll		a3,a3,$10
		addu	gp,v0,a3
		sw		gp,$001C(a2)
		addiu	gp,gp,$08
		sw		gp,$0024(a2)

		addiu	v1,at,$01
		andi	v1,v1,$FF
		sll		v1,v1,$03
		ori		v1,v1,$8000
		or		v1,v1,s7		;base addr for block lookup

		andi	v0,at,$0100
		xor		at,at,v0
		srl		v0,v0,$06
		addu	v1,v1,v0		;add 4 for second pat table

		lw		v1,$0000(v1)
		andi	v0,at,$C000
		srl		v0,v0,$0B
		srlv	v1,v1,v0
		and 	v1,v1,t0		;get the block #

		andi	v0,v1,$04
		sll		v0,v0,$02
		srl		gp,v1,$03
		or		v0,v0,gp
		ori		v0,v0,$0400
		sh		v0,$001A(a2)	;set tex page location

		srl		v0,at,$10		;color bits
		andi	v0,v0,$03
		addiu	v0,v0,$21
		sh		v0,$0012(a2)

		andi	v1,v1,$03
		sll		v1,v1,$0E

		andi	v0,at,$2000
		or		v1,v1,v0		;y tex
		srl		v1,v1,$08

		addiu	v1,v1,$08		;for 16 sprs, always go 8 down

		srl		v0,at,$05
		andi	v0,v0,$F0		;x tex

		sltiu	gp,v0,$01
		sll		gp,gp,$03		;tex position X is 0, move right to allow flipping
		addu	v0,v0,gp

		srl		s6,at,$16
		andi	s6,s6,$01
		beqz	s6,spr16noHFlip
		addiu	gp,v0,$08

		subiu	gp,v0,$01
		addiu	v0,v0,$07

spr16noHFlip

		sb		v0,$0010(a2)
		sb		gp,$0018(a2)
		sb		v0,$0020(a2)
		sb		gp,$0028(a2)

		srl		s6,at,$16
		srl		a3,a3,$10
		andi	s6,s6,$02
		beqz	s6,spr16noVFlip
		addu	gp,v1,a3

		subiu	gp,v1,$01
		addu	v1,v1,a3
		subiu	v1,v1,$01

spr16noVFlip

		sb		v1,$0011(a2)
		sb		v1,$0019(a2)
		sb		gp,$0021(a2)
		sb		gp,$0029(a2)

		la		a3,sprOnOffRecord	;load this back in

		bne		t8,t9,sprDMAloop8x16
		subiu	a2,a2,$2C

		mflo	t0

		jr		ra
		nop

map9SpriteSetup
		mtlo	t0				;save t0 in lo reg
		lbu		t0,blockMask
		nop
		ori		t0,t0,$07

		lbu		t8,sprType
		nop
		bnez	t8,do8x16spr_9
		nop

		la		a2, spriteDMAlist+2772	;point to last sprite prim
		la		t8, sprRAM+$100			;dest addr
		la		t9, sprRAM				;start address for old
		la		a3, sprOnOffRecord

		lw		at,$0000(t9)
		li		gp,$F8F8F8F8
		beq		at,gp,mtbeginning	;the 4 f8's mean this is the intro to
		li		at,$7E				;mtpu so change latch half way down
		lhu		at,$0004(t9)
		lbu		gp,$0009(t9)
		srl		v1,at,$08
		subiu	gp,gp,$FE			;if there's an FE there, then you're
		beqz	gp,notSplit			;in a fight and should not use latches
		li		s7,$0
		subiu	v1,v1,$FD			;then, if this is FD, use the Y coord (s7)
		bnez	v1,notSplit			;to determine which latch to use later
		li		s7,$0
mtbeginning
		andi	s7,at,$FF
		ori		s7,s7,$1000

notSplit

sprDMAloop8x8_9
		lw		at,$0000(t9)
		addiu	t9,t9,$04

		addiu	v1,at,$01
		andi	v1,v1,$FF
		srl		gp,v1,$03
		addu	gp,a3,gp			;get addr of byte with start of on/off info
		lwl		s6,$0003(gp)
		lwr		s6,$0000(gp)		;get on/off data

		srl		v0,at,$15
		andi	v0,v0,$01
		sllv	v0,s5,v0		;0=in front so set masks, 1=behind so respect masks
		sb		v0,$0004(a2)

		srl		v0,at,$18	;x coord

		andi	gp,v1,$07
		srlv	gp,s6,gp			;get to right starting bit
		andi	gp,gp,$FF
		la		a3,xlatSprInfo		;look up the byte for $HHHHYYYY (H=height, Y=additional Y coord)
		addu	a3,a3,gp
		lbu		a3,$0000(a3)		;load the byte
		nop
		andi	a0,a3,$F
		addu	v1,v1,a0			;add the Yadd to the Y coord
		srl		a3,a3,$04			;a3 is now the height of the 8x8 spr
		bnez	gp,skip8x8kill_9		;if the byte was 0, kill the H and W to make invisible
		nop
		or		a3,zero,zero
skip8x8kill_9

		;at this point, a3 has the height of the spr (width is always 8)

		sll		v1,v1,$10	;v1 has y coord
		or		v0,v0,v1	;v0 has x coord

		sw		v0,$000C(a2)
		addiu	gp,v0,$08
		sw		gp,$0014(a2)
		sll		a3,a3,$10
		addu	gp,v0,a3
		sw		gp,$001C(a2)
		addiu	gp,gp,$08
		sw		gp,$0024(a2)

		la		v1,map9_fe_sprites
		beqz	s7,notSplitCheck
		nop

		andi	v0,at,$FF
		andi	s7,s7,$FF
		subu	v0,v0,s7
		bltz	v0,notSplitCheck
		ori		s7,s7,$1000

		la		v1,map9_fd_sprites

notSplitCheck

		lw		v1,$0000(v1)
		andi	v0,at,$C000
		srl		v0,v0,$0B
		srlv	v1,v1,v0
		and 	v1,v1,t0		;get the block #

		andi	v0,v1,$04
		sll		v0,v0,$02
		srl		gp,v1,$03
		or		v0,v0,gp
		ori		v0,v0,$0400
		sh		v0,$001A(a2)	;set tex page location

		srl		v0,at,$10		;color bits
		andi	v0,v0,$03
		addiu	v0,v0,$21
		sh		v0,$0012(a2)

		andi	v1,v1,$03
		sll		v1,v1,$0E

		andi	v0,at,$2000
		or		v1,v1,v0		;y tex
		srl		v1,v1,$08

		sltiu	gp,v1,$01
		sll		gp,gp,$03		;tex position Y is 0, move down to allow flipping
		addu	v1,v1,gp

		srl		v0,at,$05
		andi	v0,v0,$F0		;x tex

		sltiu	gp,v0,$01
		sll		gp,gp,$03		;tex position X is 0, move right to allow flipping
		addu	v0,v0,gp

		srl		s6,at,$04
		andi	s6,s6,$10
		addu	v1,v1,s6

		srl		s6,at,$16
		andi	s6,s6,$01
		beqz	s6,spr8noHFlip_9
		addiu	gp,v0,$08

		subiu	gp,v0,$01
		addiu	v0,v0,$07

spr8noHFlip_9

		sb		v0,$0010(a2)
		sb		gp,$0018(a2)
		sb		v0,$0020(a2)
		sb		gp,$0028(a2)

		srl		s6,at,$16
		srl		a3,a3,$10
		andi	s6,s6,$02
		beqz	s6,spr8noVFlip_9
		addu	gp,v1,a3

		subiu	gp,v1,$01
		addu	v1,v1,a3
		subiu	v1,v1,$01

spr8noVFlip_9

		sb		v1,$0011(a2)
		sb		v1,$0019(a2)
		sb		gp,$0021(a2)
		sb		gp,$0029(a2)

		la		a3,sprOnOffRecord	;load this back in

		bne		t8,t9,sprDMAloop8x8_9
		subiu	a2,a2,$2C

		mflo	t0

		jr		ra
		lui		s7,$8001

do8x16spr_9

		la		a2, spriteDMAlist+2772	;point to last sprite prim
		la		t8, sprRAM+$100			;dest addr
		la		t9, sprRAM				;start address for old
		la		a3, sprOnOffRecord

		lhu		at,$0004(t9)
		lbu		gp,$0009(t9)
		srl		v1,at,$08
		subiu	gp,gp,$FE
		beqz	gp,notSplit16
		li		s7,$0
		subiu	v1,v1,$FD
		bnez	v1,notSplit16
		li		s7,$0

		andi	s7,at,$FF
		ori		s7,s7,$1000

notSplit16

sprDMAloop8x16_9
		lw		at,$0000(t9)
		addiu	t9,t9,$04

		andi	v1,at,$FF
		addiu	v1,v1,$01
		srl		gp,v1,$03
		addu	gp,a3,gp			;get addr of byte with start of on/off info
		lwl		s6,$0003(gp)
		lwr		s6,$0000(gp)		;get new on/off data

		srl		v0,at,$15
		andi	v0,v0,$01
		sllv	v0,s5,v0		;0=in front so set masks, 1=behind so respect masks
		sb		v0,$0004(a2)

		srl		v0,at,$18	;x coord

		andi	gp,v1,$07
		srlv	s6,s6,gp			;get to right starting bit
		andi	gp,s6,$FF
		srl		a1,s6,$08
		andi	a1,a1,$FF
		la		a3,xlatSprInfo		;look up the byte for $HHHHYYYY (H=height, Y=additional Y coord)
		addu	a1,a3,a1
		addu	a3,a3,gp
		lbu		a3,$0000(a3)		;load the byte
		lbu		a1,$0000(a1)
		andi	a0,a3,$F
		addu	v1,v1,a0			;add the Yadd to the Y coord
		srl		a3,a3,$04			;a3 is now the height of the 8x8 spr
		bnez	gp,skip8x16kill_9		;if the byte was 0, kill the H and W to make invisible
		nop
		j		dontAddHeight_9
		or		a3,zero,zero
skip8x16kill_9
		andi	gp,a1,$F
		bnez	gp,dontAddHeight_9	;don't add a0's height if there would be a gap in the sprite (just truncate it)
		nop
		srl		a1,a1,$04
		addu	a3,a3,a1
dontAddHeight_9

		sll		v1,v1,$10
		or		v0,v0,v1

		sw		v0,$000C(a2)
		addiu	gp,v0,$08
		sw		gp,$0014(a2)
		sll		a3,a3,$10
		addu	gp,v0,a3
		sw		gp,$001C(a2)
		addiu	gp,gp,$08
		sw		gp,$0024(a2)

		la		v1,map9_fe_sprites
		beqz	s7,notSplitCheck16
		nop

		andi	v0,at,$FF
		subiu	v0,v0,$7F
		bltz	v0,notSplitCheck16
		nop

		la		v1,map9_fd_sprites

notSplitCheck16

		lw		v1,$0000(v1)
		andi	v0,at,$C000
		srl		v0,v0,$0B
		srlv	v1,v1,v0
		and 	v1,v1,t0		;get the block #

		andi	v0,v1,$04
		sll		v0,v0,$02
		srl		gp,v1,$03
		or		v0,v0,gp
		ori		v0,v0,$0400
		sh		v0,$001A(a2)	;set tex page location

		srl		v0,at,$10		;color bits
		andi	v0,v0,$03
		addiu	v0,v0,$21
		sh		v0,$0012(a2)

		andi	v1,v1,$03
		sll		v1,v1,$0E

		andi	v0,at,$2000
		or		v1,v1,v0		;y tex
		srl		v1,v1,$08

		addiu	v1,v1,$08		;for 16 sprs, always go 8 down

		srl		v0,at,$05
		andi	v0,v0,$F0		;x tex

		sltiu	gp,v0,$01
		sll		gp,gp,$03		;tex position X is 0, move right to allow flipping
		addu	v0,v0,gp

		srl		s6,at,$16
		andi	s6,s6,$01
		beqz	s6,spr16noHFlip_9
		addiu	gp,v0,$08

		subiu	gp,v0,$01
		addiu	v0,v0,$07

spr16noHFlip_9

		sb		v0,$0010(a2)
		sb		gp,$0018(a2)
		sb		v0,$0020(a2)
		sb		gp,$0028(a2)

		srl		s6,at,$16
		srl		a3,a3,$10
		andi	s6,s6,$02
		beqz	s6,spr16noVFlip_9
		addu	gp,v1,a3

		subiu	gp,v1,$01
		addu	v1,v1,a3
		subiu	v1,v1,$01

spr16noVFlip_9

		sb		v1,$0011(a2)
		sb		v1,$0019(a2)
		sb		gp,$0021(a2)
		sb		gp,$0029(a2)

		la		a3,sprOnOffRecord	;load this back in

		bne		t8,t9,sprDMAloop8x16_9
		subiu	a2,a2,$2C

		mflo	t0

		jr		ra
		lui		s7,$8001

write4015
		sw		ra,saveRA
		sb		a1,$4015(s7)

		andi	at,a1,$10
		beqz	at,turnDMCoff
		lui		gp,$1f80

		lbu		at,$4012(s7)
		li		a0,bankptr+$8
		andi	v0,at,$80
		srl		v0,v0,$05
		addu	a0,a0,v0
		lw		a0,$0000(a0)
		sll		at,at,$06
		ori		at,at,$C000
		addu	a0,a0,at			;a0 has address of sample

		la		v0,DMCsampleAddrs
		li		v1,$0
DMCsearchLoop
		lw		at,$0000(v0)
		addiu	v0,v0,$04
		beq		at,a0,DMCfound
		addiu	v1,v1,$01
		beqz	at,DMCopening
		slti	at,v1,MAX_DMC_SAMPLES
		bnez	at,DMCsearchLoop
		nop

		j		afterDMC		;for now, just quit if no more room
		nop

DMCopening
		lbu		v0,$4013(s7)	;largets amount of space possible needed is $48E0 (seen up to $36E0 with punchout)
		lbu		t9,$4011(s7)		;not counting leading zeros and closing $0700....
		subiu	v1,v1,$01		;v1 = dmc sample index to use

		lw		a2,spuBuffAddr
		la		gp,DMCsampleAddrs
		sll		at,v1,$02
		addu	gp,gp,at
		sw		a0,$0000(gp)
		sw		a2,$0040(gp)
		;srl		a2,a2,$03
		;sh		a2,$1d36(gp)		;set sample start address

		lbu		a2,$4010(s7)
		lui		gp,$1f80
		la		a1,dmcFreqs
		andi	a2,a2,$F
		sll		a2,a2,$01			;lookup and set freq
		addu	a1,a1,a2
		lhu		a2,$0000(a1)
		nop
		sh		a2,$1d34(gp)

		sll		v0,v0,$04
		addiu	v0,v0,$01		;v0 = # of bytes to convert to ADPCM
		srl		t9,t9,$01
		andi	t9,t9,$3F		;t9 = delta counter
		sll		t9,t9,$1A
		sra		t9,t9,$1A

		la		gp,vromTmp
		andi	at,gp,$F
		slt		at,zero,at			;gp = 16 byte boundry in vromtmp
		srl		gp,gp,$04
		addu	gp,gp,at
		sll		gp,gp,$04

		sw		zero,$0000(gp)
		sw		zero,$0004(gp)		;first 16 bytes are 0
		sw		zero,$0008(gp)
		sw		zero,$000C(gp)
		addiu	gp,gp,$10

DMCconvertLoop
		andi	at,gp,$F
		bnez	at,noWriteHeader
		nop
		
		li		at,$0201		;or whatever the header should be
		sh		at,$0000(gp)
		addiu	gp,gp,$02

		la		at,vromTmp
		sub		at,gp,at
		subiu	at,at,$1F00
		bgtz	at,DMCconvertDone
		nop

noWriteHeader

		andi	at,t8,$F00
		bnez	at,noNewByte
		nop		

		lbu		t8,$0000(a0)		;get a byte
		addiu	a0,a0,$01
		subiu	v0,v0,$01
		addiu	at,v0,$01
		beqz	at,DMCconvertDone
		ori		t8,t8,$F000

noNewByte

		andi	at,t8,$01
		srl		t8,t8,$01
		sll		at,at,$01
		subiu	at,at,$01		; \
		addu	t9,t9,at

		subiu	at,t9,$20
		beqz	at,DMClimit1
		addiu	v1,zero,$FFFF
		addiu	at,t9,$21
		beqz	at,DMClimit1
		li		v1,1
		li		v1,0
DMClimit1
		addu	t9,t9,v1

		srl		a2,t9,$02
		andi	a2,a2,$F

		andi	at,t8,$01		;	process first 2 bits
		srl		t8,t8,$01
		sll		at,at,$01
		subiu	at,at,$01
		addu	t9,t9,at		; /

		subiu	at,t9,$20
		beqz	at,DMClimit2
		addiu	v1,zero,$FFFF
		addiu	at,t9,$21
		beqz	at,DMClimit2
		li		v1,1
		li		v1,0
DMClimit2
		addu	t9,t9,v1

		andi	at,t9,$3C
		sll		at,at,$02
		or		a2,a2,at


		andi	at,t8,$01
		srl		t8,t8,$01
		sll		at,at,$01
		subiu	at,at,$01		; \
		addu	t9,t9,at

		subiu	at,t9,$20
		beqz	at,DMClimit3
		addiu	v1,zero,$FFFF
		addiu	at,t9,$21
		beqz	at,DMClimit3
		li		v1,1
		li		v1,0
DMClimit3
		addu	t9,t9,v1

		andi	at,t9,$3C
		sll		at,at,$06
		or		a2,a2,at

		andi	at,t8,$01		;	process next 2 bits
		srl		t8,t8,$01
		sll		at,at,$01
		subiu	at,at,$01
		addu	t9,t9,at

		subiu	at,t9,$20
		beqz	at,DMClimit4
		addiu	v1,zero,$FFFF
		addiu	at,t9,$21
		beqz	at,DMClimit4
		li		v1,1
		li		v1,0
DMClimit4
		addu	t9,t9,v1

		andi	at,t9,$3C		; /
		sll		at,at,$0A
		or		a2,a2,at

		sh		a2,$0000(gp)	; store converted half
		addiu	gp,gp,$02

		j		DMCconvertLoop
		nop

DMCconvertDone
		andi	at,gp,$F
		beqz	at,DMCpadDone
		nop
		sh		zero,$0000(gp)
		j		DMCconvertDone
		addiu	gp,gp,$02
DMCpadDone

		lbu		v1,$4010(s7)
		li		at,$0700
		andi	v1,v1,$40			;v1 has repeat bit
		sll		v1,v1,$04
		xor		at,at,v1
		sw		at,$0000(gp)
		sw		zero,$0004(gp)
		sw		zero,$0008(gp)
		sw		zero,$000C(gp)
		addiu	gp,gp,$10

		lw		a2,spuBuffAddr

		la		a0,vromTmp
		andi	at,a0,$F
		slt		at,zero,at			;a0 = start address of sample
		srl		a0,a0,$04
		addu	a0,a0,at
		sll		a0,a0,$04

		li		at,$02
		srl		v1,v1,$08			;sets repeat addr if looping sample
		or		at,at,v1			;need this? couldn't just always set to 3?
		sb		at,$0011(a0)

		subu	a1,gp,a0
		andi	at,a1,$3F
		slt		at,zero,at			;a1 must be a mult of 64
		srl		a1,a1,$06
		addu	a1,a1,at
		sll		a1,a1,$06

		sw		a2,spuTargetAddr
		addu	v0,a2,a1
		sw		v0,spuBuffAddr

		la		v0,playDMC
		sw		v0,spuDMAcallback

		jal		libSpuWrite
		nop

dmcdmawait
		lw		at,spu_dma_active
		nop
		bnez	at,dmcdmawait
		nop

		j		afterDMC
		nop

DMCfound

		lui		gp,$1f80
		subiu	v1,v1,$01		;v1 = dmc sample index to use
		la		a0,DMCsndbufAddrs
		sll		v1,v1,$02
		addu	a0,a0,v1
		lw		a0,$0000(a0)
		nop
		srl		a0,a0,$03
		sh		a0,$1d36(gp)	;set sample start address

		lbu		a2,$4010(s7)
		nop
		la		a1,dmcFreqs
		andi	a2,a2,$F
		sll		a2,a2,$01			;lookup and set freq
		addu	a1,a1,a2
		lhu		a2,$0000(a1)
		nop
		sh		a2,$1d34(gp)

		li		at,$08			;do KEY ON for DMC voice
		sh		at,$1d8a(gp)

turnDMCoff
		li		at,$08			;do KEY OFF for DMC voice
		sh		at,$1d8e(gp)

afterDMC
		lbu		a1,$4015(s7)

		li		a0,$04
		la		a2,sq1Enabled
silenceLoop
		andi	at,a1,$01
		sb		at,$0000(a2)
		bnez	at,didntSilence
		nop
		sb		zero,$0001(a2)		;kills the timer too when write 0 here
didntSilence
		subiu	a0,a0,$01
		addiu	a2,a2,$04
		bnez	a0,silenceLoop
		srl		a1,a1,$01

		lw		ra,saveRA
		nop
		jr		ra
		nop

playDMC
		lw		a0,spuTargetAddr
		nop
		srl		a0,a0,$03
		sh		a0,$1d36(gp)			;set start addr

		li	at,$248 0
		sh	at,$1d30(gp)				;set volume
		sh	at,$1d32(gp)

		li		at,$08
		sh		at,$1d8A(gp)			;do KEY ON for that voice

		sw		zero,spuDMAcallback

		jr		ra
		nop

write4016
		lbu		t8,$4016(s7)
		andi	a1,a1,$01
		sll		t8,t8,$01			;keep track of bits written here
		or		t8,t8,a1
		sb		t8,$4016(s7)

		andi	at,t8,$3
		subiu	at,at,$02			;if last 2 bits in are 1 and 0
		bnez	at,noLatchPad4016
		nop

		lw		t8,pad1_data
		lw		t9,pad2_data
		sw		t8,pad1_nes
		sw		t9,pad2_nes

noLatchPad4016
		jr		ra
		nop

write4017
		sb		a1,$4017(s7)		;frame irq enable?
		jr		ra
		nop

read4000
read4001
read4002
read4003
read4004
read4005
read4006
read4007
read4008
read4009
read400A
read400B
read400C
read400D
read400E
read400F
read4010
read4011
read4012
read4013
read4014
		jr		ra
		nop

justread4k
	or		a1,t8,s7
	lbu		a1,$4000(a1)
	jr		ra
	nop

justwrite4k
	or		at,t8,s7
	jr		ra
	sb		a1,$4000(at)

;eof
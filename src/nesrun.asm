
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

;------------------------------------------------
; nesRun
;------------------------------------------------

nesRun
		addu	at,fp,s4

execLoop
		lbu		a1,$0000(at)
		lb		t9,$0001(at)
		srl		a2,s4,$0D
		bne		t3,a2,newBank
		ori		a1,a1,$0800
		sll		a1,a1,$07
		jr		a1
		andi	t8,t9,$FF

newBank
		sll		a1,a2,$02
		lui		t8,bankptrlo>>16
		or		t8,t8,a1
		lw		fp,bankptrlo(t8)
		or		t3,zero,a2
		addu	at,fp,s4
		lbu		a1,$0000(at)
		lb		t9,$0001(at)
		ori		a1,a1,$0800
		sll		a1,a1,$07
		jr		a1
		andi	t8,t9,$FF

postOp
		bgtz	t7,execLoop		; if h-blank time
		addu	at,fp,s4

postOp2
		addiu	t7,t7,$0553		;	reset cycle counter (+1363)

postOp3

		lui		gp,$1f80
		lw		at,nextScanJump(gp)
		lw		a0,scanLine(gp)			;scanline you're at the BEGINNING of
		jr		at
		nop

scan0_reset
;----------------------------------------------		

		lbu		t8,$2001(s7)
		sb		zero,$2002(s7)		;reset this
		andi	t8,t8,$18				; if new frame
		beq		t8,zero,noVRegUpdate	; AND the bg OR spr enabled...
		nop

		lhu		t8,$1802(s7)
		nop
		sh		t8,$1800(s7)		; vram reg = internal vram addr
noVRegUpdate

		lbu		a1,chrCount
		lw		a0,dirtyPat0
		bnez	a1,noVRAM
		nop
		beqz	a0,noDirtyPat0
		nop

		li		t8,$80022800		;pointer to info on which blocks were used to render BG for each row of tiles (will be 0,1,2,3 or 4,5,6,7)
		li		t9,$80022000		;pointer to tile numbers
		li		v0,30				;row counter
		la		a1,dirty0tile
		la		a3,bg1DMAlist		;pointer to prims
		lhu		at,renderTimeStamp
		lw		sp,lastChange		;get pointer to change list
		mtlo	at					;put current timestamp in LO reg

vramFixFirstLoop
		lw		at,$0000(t8)
		addiu	t8,t8,$04
		andi	at,at,$FF
		bnez	at,notFirstPatTable
		nop

		subiu	a3,a3,$24
		li		gp,$20
vramFixFirstInnderLoop
		beqz	gp,vramFixFirstRowDone
		addiu	a3,a3,$24
		lbu		v1,$0000(t9)
		addiu	t9,t9,$01
		subiu	gp,gp,$01
		srl		at,v1,$03
		srlv	at,a0,at
		andi	at,at,$01
		beqz	at,vramFixFirstInnderLoop
		nop

		srl		at,v1,$03
		addu	at,a1,at
		lbu		a2,$0000(at)
		andi	at,v1,$07
		srlv	at,a2,at
		andi	at,at,$01
		beqz	at,vramFixFirstInnderLoop
		nop

		subiu	at,t9,$01
		andi	at,at,$7FF
		sll		at,at,$01
		or		v1,at,s7
		addiu	v1,v1,$800
		lhu		at,$0000(v1)		; get current time stamp
		mflo	a2
		beq		at,a2,vramFixFirstInnderLoop
		nop
		sh		a3,$0000(sp)		; link last to this one
		srl		at,a3,$10
		sh		a2,$0000(v1)		; save new time stamp
		sb		at,$0002(sp)
		j		vramFixFirstInnderLoop
		or		sp,a3,zero			;set last change to current one

notFirstPatTable
		addiu	a3,a3,$480
		addiu	t9,t9,$20
vramFixFirstRowDone
		subiu	v0,v0,$01
		bnez	v0,vramFixFirstLoop
		nop

		li		t8,$80022880		;pointer to info on which blocks were used to render BG for each row of tiles (will be 0,1,2,3 or 4,5,6,7)
		li		t9,$80022400		;pointer to tile numbers
		li		v0,30				;row counter
		la		a1,dirty0tile
		la		a3,bg2DMAlist		;pointer to prims
		lhu		at,renderTimeStamp
		nop
		mtlo	at					;put current timestamp in LO reg

vramFixFirstLoop2
		lw		at,$0000(t8)
		addiu	t8,t8,$04
		andi	at,at,$FF
		bnez	at,notFirstPatTable2
		nop

		subiu	a3,a3,$24
		li		gp,$20
vramFixFirstInnderLoop2
		beqz	gp,vramFixFirstRowDone2
		addiu	a3,a3,$24
		lbu		v1,$0000(t9)
		addiu	t9,t9,$01
		subiu	gp,gp,$01
		srl		at,v1,$03
		srlv	at,a0,at
		andi	at,at,$01
		beqz	at,vramFixFirstInnderLoop2
		nop

		srl		at,v1,$03
		addu	at,a1,at
		lbu		a2,$0000(at)
		andi	at,v1,$07
		srlv	at,a2,at
		andi	at,at,$01
		beqz	at,vramFixFirstInnderLoop2
		nop

		subiu	at,t9,$01
		andi	at,at,$7FF
		sll		at,at,$01
		or		v1,at,s7
		addiu	v1,v1,$800
		lhu		at,$0000(v1)		; get current time stamp
		mflo	a2
		beq		at,a2,vramFixFirstInnderLoop2
		nop
		sh		a3,$0000(sp)		; link last to this one
		srl		at,a3,$10
		sh		a2,$0000(v1)		; save new time stamp
		sb		at,$0002(sp)
		j		vramFixFirstInnderLoop2
		or		sp,a3,zero			;set last change to current one

notFirstPatTable2
		addiu	a3,a3,$480
		addiu	t9,t9,$20
vramFixFirstRowDone2
		subiu	v0,v0,$01
		bnez	v0,vramFixFirstLoop2
		nop

		sw		sp,lastChange

		la		t8,dirty0tile
		sw		zero,$0000(t8)
		sw		zero,$0004(t8)
		sw		zero,$0008(t8)
		sw		zero,$000C(t8)
		sw		zero,$0010(t8)
		sw		zero,$0014(t8)
		sw		zero,$0018(t8)
		sw		zero,$001C(t8)

		sw		zero,dirtyPat0
		li		a3,$80020000-$80
p0update
		beqz	a0,noDirtyPat0
		andi	at,a0,$01
		srl		a0,a0,$01
		beqz	at,p0update
		addiu	a3,a3,$80

		jal		transPat
		or		at,a3,zero
		j		p0update
		nop

noDirtyPat0

		lw		a0,dirtyPat1
		nop
		beqz	a0,noDirtyPat1
		nop

		li		t8,$80022800		;pointer to info on which blocks were used to render BG for each row of tiles (will be 0,1,2,3 or 4,5,6,7)
		li		t9,$80022000		;pointer to tile numbers
		li		v0,30				;row counter
		la		a1,dirty1tile
		la		a3,bg1DMAlist		;pointer to prims
		lhu		at,renderTimeStamp
		lw		sp,lastChange		;get pointer to change list
		mtlo	at					;put current timestamp in LO reg

vramFixSecondLoop
		lw		at,$0000(t8)
		addiu	t8,t8,$04
		andi	at,at,$FF
		beqz	at,notSecondPatTable
		nop

		subiu	a3,a3,$24
		li		gp,$20
vramFixSecondInnderLoop
		beqz	gp,vramFixSecondRowDone
		addiu	a3,a3,$24
		lbu		v1,$0000(t9)
		addiu	t9,t9,$01
		subiu	gp,gp,$01
		srl		at,v1,$03
		srlv	at,a0,at
		andi	at,at,$01
		beqz	at,vramFixSecondInnderLoop
		nop

		srl		at,v1,$03
		addu	at,a1,at
		lbu		a2,$0000(at)
		andi	at,v1,$07
		srlv	at,a2,at
		andi	at,at,$01
		beqz	at,vramFixSecondInnderLoop
		nop

		subiu	at,t9,$01
		andi	at,at,$7FF
		sll		at,at,$01
		or		v1,at,s7
		addiu	v1,v1,$800
		lhu		at,$0000(v1)		; get current time stamp
		mflo	a2
		beq		at,a2,vramFixSecondInnderLoop
		nop
		sh		a3,$0000(sp)		; link last to this one
		srl		at,a3,$10
		sh		a2,$0000(v1)		; save new time stamp
		sb		at,$0002(sp)
		j		vramFixSecondInnderLoop
		or		sp,a3,zero			;set last change to current one

notSecondPatTable
		addiu	a3,a3,$480
		addiu	t9,t9,$20
vramFixSecondRowDone
		subiu	v0,v0,$01
		bnez	v0,vramFixSecondLoop
		nop

		li		t8,$80022880		;pointer to info on which blocks were used to render BG for each row of tiles (will be 0,1,2,3 or 4,5,6,7)
		li		t9,$80022400		;pointer to tile numbers
		li		v0,30				;row counter
		la		a1,dirty1tile
		la		a3,bg2DMAlist		;pointer to prims
		lhu		at,renderTimeStamp
		nop
		mtlo	at					;put current timestamp in LO reg

vramFixSecondLoop2
		lw		at,$0000(t8)
		addiu	t8,t8,$04
		andi	at,at,$FF
		beqz	at,notSecondPatTable2
		nop

		subiu	a3,a3,$24
		li		gp,$20
vramFixSecondInnderLoop2
		beqz	gp,vramFixSecondRowDone2
		addiu	a3,a3,$24
		lbu		v1,$0000(t9)
		addiu	t9,t9,$01
		subiu	gp,gp,$01
		srl		at,v1,$03
		srlv	at,a0,at
		andi	at,at,$01
		beqz	at,vramFixSecondInnderLoop2
		nop

		srl		at,v1,$03
		addu	at,a1,at
		lbu		a2,$0000(at)
		andi	at,v1,$07
		srlv	at,a2,at
		andi	at,at,$01
		beqz	at,vramFixSecondInnderLoop2
		nop

		subiu	at,t9,$01
		andi	at,at,$7FF
		sll		at,at,$01
		or		v1,at,s7
		addiu	v1,v1,$800
		lhu		at,$0000(v1)		; get current time stamp
		mflo	a2
		beq		at,a2,vramFixSecondInnderLoop2
		nop
		sh		a3,$0000(sp)		; link last to this one
		srl		at,a3,$10
		sh		a2,$0000(v1)		; save new time stamp
		sb		at,$0002(sp)
		j		vramFixSecondInnderLoop2
		or		sp,a3,zero			;set last change to current one

notSecondPatTable2
		addiu	a3,a3,$480
		addiu	t9,t9,$20
vramFixSecondRowDone2
		subiu	v0,v0,$01
		bnez	v0,vramFixSecondLoop2
		nop
		
		sw		sp,lastChange

		la		t8,dirty1tile
		sw		zero,$0000(t8)
		sw		zero,$0004(t8)
		sw		zero,$0008(t8)
		sw		zero,$000C(t8)
		sw		zero,$0010(t8)
		sw		zero,$0014(t8)
		sw		zero,$0018(t8)
		sw		zero,$001C(t8)

		sw		zero,dirtyPat1
		li		a3,$80021000-$80
p1update
		beqz	a0,noDirtyPat1
		andi	at,a0,$01
		srl		a0,a0,$01
		beqz	at,p1update
		addiu	a3,a3,$80

		jal		transPat
		or		at,a3,zero
		j		p1update
		nop

noDirtyPat1
noVRAM

		j		startFrame
		nop
afterStartFrame

		li		a0,$01
		sw		a0,scanLine				; next scanline will be 1
		la		a0,scan1_239_render
		sw		a0,nextScanJump			; next jump is to the renderer

		;li		t7,$0553	; eliminate jitter in games with precise timing

		j		execLoop		;	return since scanline is < 240
		addu	at,fp,s4

scan1_239_render
;-------------------------------------------------------
		addiu	t8,a0,$01		; inc the scan line
		sw		t8,scanLine
		subiu	t8,t8,$00F0
		beqz	t8,lastLine
		nop

		j		doLine		; draw this scan line
		nop

lastLine
		la		t8,scan240_vblankflag
		sw		t8,nextScanJump			; next jump is to the flag set line
		sb		s5,needToRender			; have to trigger render for last scanline
		j		doLine		; draw this scan line
		nop

afterDoLine
		j		execLoop
		addu	at,fp,s4

scan240_vblankflag
;--------------------------------------------------------
		lbu		t8,$2002(s7)	;	turn on the in v-blank bit if just finished 239
		li		a0,241
		ori		t8,t8,$80
		sb		t8,$2002(s7)
		sw		a0,scanLine
		la		a0,scan241_nmi
		sw		a0,nextScanJump			; next jump is to the nmi line
		
		jal		endFrame
		nop
afterEndFrame

		jal		readPads
		li		a0,$0

		jal		readPads
		li		a0,$1

		la		a0,saveT0
		sw		t0,$0000(a0)
		sw		t1,$0004(a0)
		sw		t2,$0008(a0)
		sw		t3,$000C(a0)
		sw		t4,$0010(a0)
		sw		t5,$0014(a0)
		sw		t6,$0018(a0)
		sw		t7,$001C(a0)

		li		sp,$801fff00
		jal		soundQuarterCallback
		nop

		la		a0,saveT0
		lw		t0,$0000(a0)
		lw		t1,$0004(a0)
		lw		t2,$0008(a0)
		lw		t3,$000C(a0)
		lw		t4,$0010(a0)
		lw		t5,$0014(a0)
		lw		t6,$0018(a0)
		lw		t7,$001C(a0)

		j		execLoop
		addu	at,fp,s4

scan241_nmi
;--------------------------------------------------------		
		lbu		t9,$2000(s7)
		nop
		srl		t9,t9,$07
		beq		t9,zero,noNMI	; if scanline = (right after) 240 AND NMI enable bit set		
		nop

		jal		doNMI			;	do the NMI
		nop
noNMI
	
		li		a0,242
		sw		a0,scanLine
		la		a0,scan242_261_vblank
		sw		a0,nextScanJump

		j		execLoop
		addu	at,fp,s4

scan242_261_vblank
;--------------------------------------------------------
		sw		zero,scanLine
		la		a0,scan0_reset
		sw		a0,nextScanJump
		addiu	t7,t7,$6529				;add cycles for lines 243-261
										;cycles for 242 were added at the top
		j		execLoop
		addu	at,fp,s4


printf
		mthi	at
		sw		sp,saveSP
		sw		t0,saveT0
		sw		t1,saveT1
		sw		t2,saveT2
		sw		t3,saveT3
		sw		t4,saveT4
		sw		t5,saveT5
		sw		t6,saveT6
		sw		t7,saveT7
		sw		t8,saveT8
		sw		t9,saveT9
		sw		a0,saveA0
		sw		a1,saveA1
		sw		a2,saveA2
		sw		a3,saveA3
		mfhi	t8
		sw		t8,saveAT
		sw		ra,saveRA

		li		sp,$801fff00

		la		a0,fname
		li		t0,$a0
		jalr	t0
		li		t1,$3f

		lw		sp,saveSP
		lw		t0,saveT0
		lw		t1,saveT1
		lw		t2,saveT2
		lw		t3,saveT3
		lw		t4,saveT4
		lw		t5,saveT5
		lw		t6,saveT6
		lw		t7,saveT7
		lw		t8,saveT8
		lw		t9,saveT9
		lw		a0,saveA0
		lw		a1,saveA1
		lw		a2,saveA2
		lw		a3,saveA3
		lw		ra,saveRA
		lw		at,saveAT

		jr		ra
		nop

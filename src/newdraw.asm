
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

;Things that are wrong with the current gfx engine:
;-Sprite priority (smb3, castlevania1)
;	this doesn't work exactly how i originally thought.  to really fix it, draw the
;	sprites 63->0 with a seperate $E6 mask setting bit packet for each one
;	but not mask respecting for any of them. then draw BG with mask respect.
;-No mid frame pal switching for BG or Sprites (wizwar1, startropics)
;-No switching of which pattern table mid frame for ?BG? or sprite (ice hocky)
;FIXED-No left 8 clip switching mid frame
;-Writing to pattern table is not fast enough (contra, ff2)
;-Issue in smb3 where status bar uses wrong banks in fortress (mmc3 irq prob?)
;FIXED-Issue in bubble bobble where title screen uses wrong bank

;------------------------------------------------------------------
;startFrame: sets up a new video frame
;------------------------------------------------------------------
startFrame
		la		v0,bgRect
		lbu		a1,13(v0)
		nop
		xori	a1,a1,$01				;switch the BG color rect's pos
		sb		a1,13(v0)
		sb		a1,spriteHead+5			;also set draw offset for sprites to draw


		sb		a1,NT2screen+5			;major part of BG clip

		sb		a1,spriteHead+9			;major part of sprite clip

		ori		a1,a1,$FC
		sb		a1,spriteHead+13		;major part of sprite clip right

		lhu		t8,bgRectTime
		lhu		t9,renderTimeStamp		;check time stamps
		nop
		beq		t8,t9,dontLinkBG
		nop

		sh		t9,bgRectTime
		lw		v1,lastChange
		lui		a3,$FF00
		lw		a2,$0000(v1)
		li		a1,$00FFFFFF
		and		a2,a2,a3
		and		a3,v0,a1
		or		a3,a2,a3
		sw		a3,$0000(v1)		; link last to this one
		sw		v0,lastChange		; set the last changed to this one
dontLinkBG

		sb		zero,lastBGstatus

		;li		sp,$801fff00
		;la		a0,fname
		;lw		a1,pad_buf+12
		;lw		a2,pad_buf+16
		;li		t0,$a0
		;jalr	t0
		;li		t1,$3f

		j		afterStartFrame
		nop

;--------------------------------------------------
;doLine: handles drawing the scanlines and spr0 hit
;--------------------------------------------------
doLine
		lbu		at,sprRAM		;get the Y coord-1 of spr0
		lui		a1,sprRAM>>16
		bne		at,a0,noScan
		ori		a1,a1,sprRAM&$FFFF

		jal		scanSpr0
		nop

noScan
		lbu		at,sprHitLine
		nop

		bne		at,a0,noSprHit
		li		at,$40
		sb		at,$2002(s7)
noSprHit

		lhu		ra,$2000(s7)
		li		at,120
		bne		at,a0,notMiddle
		andi	a1,ra,$20
		sb		a1,sprType
		andi	a1,ra,$08
		sb		a1,sprAddr
		;andi	a1,ra,$10
		;sb		a1,bgAddr
		srl		a1,ra,$08
		sb		a1,clips
		sb		s5,needToRender		; take some pressure off games that render everything on the last scanline
notMiddle

		srl		ra,ra,$08			;ra now has $2001
		la		a1,sprOnOffRecord
		srl		a2,a0,$03
		addu	a1,a1,a2
		lbu		a2,$0000(a1)
		srl		a3,ra,$04
		andi	a3,a3,$01
		andi	v0,a0,$07			;record whether sprites were on or off in table
		sllv	a3,a3,v0
		sllv	v1,s5,v0
		xori	v0,v1,$FF
		and		a2,a2,v0
		or		a2,a2,a3
		sb		a2,$0000(a1)

		or		v0,ra,zero
		lw		a1,mapHsyncFunc
		nop
		beqz	a1,noMapHsync
		nop
		jr		a1
		nop
noMapHsync
		or		ra,v0,zero

		andi	ra,ra,$18			; skip if BOTH are disabled
		beqz	ra,BGDis
		nop

		lhu		a1,$1802(s7)
		lhu		a2,$1800(s7)	; update the X pos + nametable from the tmp reg
		andi	a1,a1,$041F
		andi	a2,a2,$FBE0
		or		s6,a2,a1		; s6 = the vram address reg

		addiu	s6,s6,$1000
		andi	s6,s6,$7FFF		; inc the Y offset
		srl		at,s6,$0C
		bnez	at,noYwrap		; if it's 0, need to inc Y tile pos
		nop

		andi	a1,s6,$FC00
		addiu	s6,s6,$0020
		andi	s6,s6,$03FF
		or		s6,s6,a1
		andi	at,s6,$03C0		; inc Y tile pos
		li		a1,$03C0
		bne		at,a1,noYwrap	; if it's 30...
		nop

		andi	s6,s6,$FC1F		; make it zero and
		xori	s6,s6,$0800		; switch name tables

		sb		s5,needToRender		;need to draw now
noYwrap

		sh		s6,$1800(s7)

		lw		a1,BLOCKS(s7)
		lw		a2,BLOCKS+4(s7)
		sll		a3,a0,$03
		or		a3,a3,s7
		ori		a3,a3,$8000
		sw		a1,$0000(a3)
		sw		a2,$0004(a3)

		andi	ra,ra,$08
		beqz	ra,BGDis
		nop

lbu   a3,needToRender
nop
bnez  a3,forceCheck
srl   at,s6,$0C
beqz  at,forceCheck			;only check when on lines 0 or 7, seems to work pretty good
subiu at,at,$07
bnez  at,blocksGood
nop

forceCheck

		lbu		a3,mirrorSel
		srl		a1,s6,$05
		andi	a1,a1,$1F
		slti	at,a1,30
		beqz	at,blocksGood			;don't check a row > 30
		srl		a2,a3,$01
		xor		a2,a3,a2
		andi	a2,a2,$01
		bnez	a2,check2screen
		nop

		j		fixRowSingle
		nop

check2screen
		
		j		fixRowDouble
		nop

blocksGood

		lbu		a1,lastBGstatus
		nop
		bnez	a1,BGnotJustEnabled
		nop

		lbu		a2,fineX				;if just enabled, set the render marks
		lbu		a1,mirrorSel
		sh		s6,renderMarkAddr
		sb		a0,renderMarkLine
		sb		a2,renderMarkXoff
		sb		a1,renderMarkMirror

BGnotJustEnabled

		sb		s5,lastBGstatus
		j		goBG
		nop

BGDis
		lbu		a1,lastBGstatus
		sb		zero,lastBGstatus
		bnez	a1,forceRender			;force to render if just disabled
		nop
		li		a1,239
		beq		a1,a0,lastLineWithDisable
		nop
		j		noRender
		nop
lastLineWithDisable
		sb		a0,renderMarkLine
		j		forceRender
		nop
goBG

		lbu		a1,needToRender
		nop
		beqz	a1,noRender
		nop
forceRender
		lhu		a1,renderMarkAddr
		lbu		a2,renderMarkLine		;get the initial values
		lbu		a3,renderMarkXoff
		lbu		v0,renderMarkMirror
		la		ra,NT2screen

		srl		t8,a1,$0A
		andi	t8,t8,$03
		srlv	t9,v0,t8
		andi	t9,t9,$01
		ori		t9,t9,$0E
		sb		t9,$000C(ra)			;set first tex page
		xori	t8,t8,$01
		srlv	t9,v0,t8
		andi	t9,t9,$01
		ori		t9,t9,$0E
		sb		t9,$0020(ra)			;set second tex page

		lw		t8,visibleScreenPos
		sll		t9,a2,$10
		xori	t8,t8,$0100
		addu	t8,t8,t9
		 andi	t9,a3,$01
		 subu	t9,t8,t9
		sw		t9,$0014(ra)			;set the first screen Y_X dest
		andi	t9,a1,$1F
		li		at,$20
		subu	t9,at,t9
			sll		v0,t9,$03
			subu	v0,v0,a3		;get width of first sprite
			subu	v1,a0,a2
			sll		v1,v1,$10
			or		at,v0,v1
			 andi	gp,a3,$01
			 addu	at,at,gp
			sw		at,$001C(ra)	;set first H_W
			li		at,$0100
			subu	v0,at,v0
			or		at,v0,v1
			sw		at,$0030(ra)	;set second H_W
		sll		t9,t9,$03
		subu	t9,t9,a3
		addu	t8,t8,t9
		sw		t8,$0028(ra)			;set the second screen Y_X dest

		andi	t8,a1,$1F
		sll		t8,t8,$03
		or		t8,t8,a3
		 andi	t8,t8,$FFFE				;make sure it's even
		andi	t9,a1,$3E0
		sll		t9,t9,$06
		or		t8,t8,t9
		andi	t9,a1,$7000
		srl		t9,t9,$04
		or		t8,t8,t9
		sh		t8,$0018(ra)			;set first tex page y_x
		andi	t8,t8,$FF00
		sh		t8,$002C(ra)			;set second tex page y_x

		or		v0,ra,zero
		lw		v1,lastChange
		lui		a3,$FF00
		lw		a2,$0000(v1)
		li		ra,$00FFFFFF
		and		a2,a2,a3
		and		a3,v0,ra
		or		a3,a2,a3
		sw		a3,$0000(v1)		; link last to this one
		sw		v0,lastChange		; set the last changed to this one

		li		v0,$0CFFFFFF
		li		v1,239
		bne		v1,a0,notLastLine
		nop

		lw		at,sprFunc
		nop
		jalr	at
		nop
		
		li a0,239				;not really needed, but oh well
		li		ra,$00FFFFFF
		la		v0,spriteHead
		and		v0,v0,ra
		lui		ra,$0C00
		or		v0,v0,ra
notLastLine
		sw		v0,NT2screen		;set it to either terminate or link to sprites

		sb		a0,renderMarkLine		;reset the starting data

		la		a0,changeHead
		jal		gpuDMAlist
		nop							;send the DMA linked list
		jal		waitList
		nop

		lbu		t8,fineX
		lhu		t9,renderTimeStamp
		sb		t8,renderMarkXoff
		lbu		t8,mirrorSel
		la		a1,changeHead
		sh		s6,renderMarkAddr
		sb		t8,renderMarkMirror
		sb		zero,needToRender
		sw		a1,lastChange
		addiu	t9,t9,$01
		sh		t9,renderTimeStamp		;inc the time stamp

noRender

		j		afterDoLine
		nop

;----------------------------------
mmc3hsync
;----------------------------------

		andi	a1,ra,$18
		beqz	a1,noMapHsync
		nop

		lbu		a1,map4irq
		nop
		subiu	a1,a1,$01
		sb		a1,map4irq

		bnez	a1,noMapHsync		;if countdown is zero
		nop

		lbu		a1,map4latch
		nop
		sb		a1,map4irq		;copy latch to counter

		jal		doIRQ			;do the irq
		nop

		j		noMapHsync
		nop

;----------------------------------
mmc5hsync
;----------------------------------

		lbu		a1,mapReg0			; load target line
		nop
		bne		a1,a0,noMapHsync	; compare with current line
		nop

		jal		doIRQ
		nop

		j		noMapHsync
		nop

;----------------------------------
map69hsync
;----------------------------------

		lh		a1,map4irq
		nop

		slti	at,a1,114
		beqz	at,not69irq
		subiu	a1,a1,113

		jal		doIRQ			;do the irq
		nop
		j		notlastline69
		li		a1,$0

not69irq
		subiu	at,a0,239
		bnez	at,notlastline69
		nop
		
		subiu	a1,a1,$9B6			;because this is supposed to run through vblank

notlastline69
		sh		a1,map4irq

		j		noMapHsync
		nop

;------------------------------------------------------------------
;endFrame: finishes a frame with sprites and double buffers
;------------------------------------------------------------------
endFrame
		lui		gp,$1F80
		
eoFramevSync
		lw		t9,pad_buf
		nop
		andi	at,t9,$01
		bnez	at,eoFramevSync
		nop

		srl		v0,t9,$10
		andi	v0,v0,$0C09			;check for reset keysig
		bnez	v0,afterV
		nop

		j		resetStuff
		nop
		
afterV
		or		t9,t9,s5
		sb		t9,pad_buf

		lw		t9,visibleScreenPos
		nop
		xori	t9,t9,$0100
		sw		t9,visibleScreenPos

		andi	v0,t9,$3FF
		srl		v1,t9,$10
		sll		v1,v1,$0A
		or		v0,v0,v1
		lui		at,$0500
		or		v0,v0,at

		sw		v0,GP1(gp)			;reposition screen
		nop

		j		afterEndFrame
		nop


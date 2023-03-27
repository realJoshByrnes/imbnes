
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

;------------------------------------------
hereAfterException
;------------------------------------------

		;lw		v0,$0108(zero)
		;nop
		;lw		v0,$0000(v0)
		;nop
		;lw		sp,$007C(v0)		;set stack up to pick off where old one left off
		;nop
		;subiu	sp,sp,$10			;for good measure

		li		sp,vromTmp+$2700

		lui		gp,$1f80

		lhu		v0,$1070(gp)
		lhu		v1,$1074(gp)
		nop
		and		s0,v0,v1

		; this next line controls which ints this routine will ack.
		; $D means vBlank(1), CD(4) and DMA(8)

		andi	at,s0,$D
		beqz	at,doneIntProcessing
		nop

		;la a0,fname
		;or a1,s0,zero		; printf the interupt
		;li		t0,$a0
		;jalr	t0
		;li		t1,$3f

		;andi	at,s0,$70
		;beqz	at,noIntrRCnt
		;xori	at,at,$FFFF

		;sh		at,$1070(gp)			;clear this bit pending
		;andi	s0,s0,$FF8F				;take out of s0

		;la		a0,fname
		;lw		a1,vSyncCount
		;li		a2,$69
		;li		t2,$a0
        ;jalr	t2
        ;li		t1,$3f

;noIntrRCnt
		andi	at,s0,$01
		beqz	at,noIntrVSync
		xori	at,at,$FFFF

		sh		at,$1070(gp)			;clear this bit pending
		andi	s0,s0,$FFFE				;take out of s0

	; VSync interupt processing here

		lw		v0,vSyncCount
		nop
		addiu	v0,v0,$01
		sw		v0,vSyncCount

		;la		a0,fname		;
		;or		a1,v0,zero		;
		;li		t2,$00A0		; printf the vcount
		;jalr	t2				;
		;li		t1,$003F		;

noIntrVSync
		andi	at,s0,$04
		beqz	at,noIntrCD
		xori	at,at,$FFFF

		sh		at,$1070(gp)		;clear pending
		andi	s0,s0,$FFFB			;take out of s0

	; CD interupt processing here

		lui		v0,$1f80
		lbu		s1,$1800(v0)
		nop
		andi	s1,s1,$03

		li		at,$01
		sb		at,$1800(v0)
		
		lbu		a0,$1803(v0)
		nop
		andi	a0,a0,$07

		beqz	a0,cdNoIntr
		nop

		sb		a0,cd_stat_bytes

		;or		a1,a0,zero
		;la		a0,pfmsg
		;jal		printf
		;nop
		;nop
		;lui		v0,$1f80

cdNoIntr
		li		at,$01
		sb		at,$1800(v0)
		li		at,$07
		sb		at,$1803(v0)
		sb		at,$1802(v0)

		sb		s1,$1800(v0)

noIntrCD
		andi	at,s0,$08
		beqz	at,noIntrDMA
		xori	at,at,$FFFF

		sh		at,$1070(gp)		;clear pending
		andi	s0,s0,$FFF7			;take out of s0

DMAIntProcess

	; DMA interupt processing here

		lw		s1,$10f4(gp)
		nop

		srl		s1,s1,$18
		andi	s1,s1,$7F
		beqz	s1,noIntrDMA
		nop

;la a0,fname		;
;or a1,s1,zero		; printf the interupt
;li		t0,$a0
;jalr	t0
;li		t1,$3f			;

		andi	at,s1,$10
		beqz	at,noDMAIntrSPU
		nop

		xori	s1,s1,$10			;take out of s1
		lw		v0,$10f4(gp)
		li		at,$10FFFFFF
		and		v0,v0,at
		sw		v0,$10f4(gp)
	
	; SPU's DMA interupt
		
		jal		libSpuDelay
		nop

		lhu		v0,$1daa(gp)		;set spu dma mode to zero
		nop
		andi	v0,v0,$FFCF
		sh		v0,$1daa(gp)
	
		lw		v0,spuDMAcallback
		sw		zero,spu_dma_active		;if there is a callback
		beqz	v0,noDMAIntrSPU
		nop

		jalr	v0							;call it
		nop

noDMAIntrSPU

		li		t0,$01
dmaIntExtraKill
		and		at,s1,t0
		beqz	at,dmaIntExtraNotOn
		nop

		sll		at,t0,$08
		ori		at,at,$FF
		sll		at,at,$10
		ori		at,at,$FFFF
		lw		v0,$10f4(gp)
		nop
		and		v0,v0,at
		sw		v0,$10f4(gp)

dmaIntExtraNotOn
		sll		t0,t0,$01
		andi	at,t0,$7F
		bnez	at,dmaIntExtraKill
		nop

		j		DMAIntProcess
		nop

noIntrDMA

		j		hereAfterException
		nop

doneIntProcessing

		li		t2,$00B0
		jr		t2				;ReturnFromException
		li		t1,$0017

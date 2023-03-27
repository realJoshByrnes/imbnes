
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

; this is the main imbNES source file. it contains most of the
; emulator's code with only certain special purpose sections broken
; out into separate files.

COPYRIGHT_TIME	=	420			; 6 second splash screen = 420
INIT_GAME_NUM	=	$0000

GP0     equ $1810               ; some equ's for easy ref.
GP1     equ $1814

PAT1	equ $00000100
PAT2	equ $00000140

VROM_SLOTS equ 64

; CPU memory - full implementation

RAM1	equ		$0000
RAM2	equ		$0800		; mirror of RAM1
RAM3	equ		$1000		; mirror of RAM1
RAM4	equ		$1800		; mirror of RAM1
PREGS	equ		$2000
SREGS	equ		$4000
EXP		equ		$5000
SRAM	equ		$6000
PRGROM1	equ		$8000
PRGROM2	equ		$C000

; PPU memory

PPU		equ		$0000

org		$80024000

;--------------------
; program entry point
;--------------------
		li sp,$801fff00

;li a0,$80020004
;sw a0,$FFFC(a0)
;li a0,0
;la a1,soundon
;addiu   t2,zero,$00c0
;jalr      t2
;addiu   t1,zero,$0002

 ;to change the font color, change these RGB values
li	t0,$ff	;R
li	t1,$ff	;G
li	t2,$00	;B
 srl	t0,t0,$03
 srl	t1,t1,$03
 srl	t2,t2,$03
 sll	t1,t1,$05
 sll	t2,t2,$0A
 or	t0,t0,t1
 or	t0,t0,t2
 sh	t0,font+2


		jal		sysInit
		nop

		jal		libSpuInit
		nop

		jal		libGpuInit
		nop

		jal		InitPads
		nop

		jal		libCardInit
		nop

		jal		libCdInit
		nop

		jal		setupDisplay
		nop

		jal		imageVars
		nop

		jal		soundCounterEventInit
		nop

		jal		copyright
		nop
		
		jal		testCard
		nop

		jal		readFiles
		nop

imbNESreset

		jal		romMenu
		nop

		jal		setDisplayNES
		nop

		jal		buildLists
		nop

		j		loadROM
		nop
afterLoad

		jal		nesReset
		nop
afterReset

		jal		soundCounterInit
		nop

		jal		nesRun
		nop

soundon
	dw 0
	dw 0
	dw soundonroutine
	dw 0

soundonroutine
lui at,$8002
lw	v0,$0000(at)
lui v1,$1f80
lhu v1,$1070(v1)
nop
sh v1,$0000(v0)
addiu v0,v0,$02
sw v0,$0000(at)
jr		ra
nop

;-------------------------------------
testCard
;	attempts to verify the memory card
;-------------------------------------

		subiu	sp,sp,$14
		sw		ra,$0010(sp)

		li		a0,1			;enter critical
		syscall	$0

		li		a0,$F4000001		; a0 = SwCARD
		li		a1,$0004			; a1 = EvSpIOE
		li		a2,$2000			; a2 = EvMdNOINTR
		li		a3,$0
		li		t2,$b0
        jalr	t2						; open event
        li		t1,$08
		sw		v0,saveT0			; save result

		li		a0,$F4000001		; a0 = SwCARD
		li		a1,$8000			; a1 = EvSpERROR
		li		a2,$2000			; a2 = EvMdNOINTR
		li		a3,$0
		li		t2,$b0
        jalr	t2						; open event
        li		t1,$08
		sw		v0,saveT1			; save result

		li		a0,$F4000001		; a0 = SwCARD
		li		a1,$0100			; a1 = EvSpTIMOUT
		li		a2,$2000			; a2 = EvMdNOINTR
		li		a3,$0
		li		t2,$b0
        jalr	t2						; open event
        li		t1,$08
		sw		v0,saveT2			; save result

		li		a0,$F4000001		; a0 = SwCARD
		li		a1,$2000			; a1 = EvSpNEW
		li		a2,$2000			; a2 = EvMdNOINTR
		li		a3,$0
		li		t2,$b0
        jalr	t2						; open event
        li		t1,$08
		sw		v0,saveT3			; save result

		li		a0,$F0000011		; a0 = HwCARD
		li		a1,$0004			; a1 = EvSpIOE
		li		a2,$2000			; a2 = EvMdNOINTR
		li		a3,$0
		li		t2,$b0
        jalr	t2						; open event
        li		t1,$08
		sw		v0,saveT4			; save result

		li		a0,$F0000011		; a0 = HwCARD
		li		a1,$8000			; a1 = EvSpERROR
		li		a2,$2000			; a2 = EvMdNOINTR
		li		a3,$0
		li		t2,$b0
        jalr	t2						; open event
        li		t1,$08
		sw		v0,saveT5			; save result

		li		a0,$F0000011		; a0 = HwCARD
		li		a1,$0100			; a1 = EvSpTIMOUT
		li		a2,$2000			; a2 = EvMdNOINTR
		li		a3,$0
		li		t2,$b0
        jalr	t2						; open event
        li		t1,$08
		sw		v0,saveT6			; save result

		li		a0,$F0000011		; a0 = HwCARD
		li		a1,$2000			; a1 = EvSpNEW
		li		a2,$2000			; a2 = EvMdNOINTR
		li		a3,$0
		li		t2,$b0
        jalr	t2						; open event
        li		t1,$08
		sw		v0,saveT7			; save result

		lw		a0,saveT0
		li		t2,$b0
        jalr	t2						; enable event
        li		t1,$0c

		lw		a0,saveT1
		li		t2,$b0
        jalr	t2						; enable event
        li		t1,$0c

		lw		a0,saveT2
		li		t2,$b0
        jalr	t2						; enable event
        li		t1,$0c

		lw		a0,saveT3
		li		t2,$b0
        jalr	t2						; enable event
        li		t1,$0c

		lw		a0,saveT4
		li		t2,$b0
        jalr	t2						; enable event
        li		t1,$0c

		lw		a0,saveT5
		li		t2,$b0
        jalr	t2						; enable event
        li		t1,$0c

		lw		a0,saveT6
		li		t2,$b0
        jalr	t2						; enable event
        li		t1,$0c

		lw		a0,saveT7
		li		t2,$b0
        jalr	t2						; enable event
        li		t1,$0c

		li		a0,2			; exit critical
		syscall	$0

		li		a0,$0
		li		t2,$a0
        jalr	t2						; _card_info
        li		t1,$ab

;la a0,fname
;or a1,v0,zero
;li		t0,$a0
;jalr	t0
;li		t1,$3f

		jal		getCardResult
		nop

;la a0,fname
;or a1,v0,zero
;li		t0,$a0
;jalr	t0
;li		t1,$3f

		lw		ra,$0010(sp)
		nop
		jr		ra
		addiu	sp,sp,$14

;---------------------------------------
getCardResult
;	determines which card event occurred
;---------------------------------------
	
		sw		ra,saveRA

getCardResultLoop
		lw		a0,saveT0
		li		t2,$b0
        jalr	t2						; test event
        li		t1,$0b

		subiu	v0,v0,$01
		beqz	v0,gotCardEvent
		li		v0,$0

		lw		a0,saveT1
		li		t2,$b0
        jalr	t2						; test event
        li		t1,$0b

		subiu	v0,v0,$01
		beqz	v0,gotCardEvent
		li		v0,$1

		lw		a0,saveT2
		li		t2,$b0
        jalr	t2						; test event
        li		t1,$0b

		subiu	v0,v0,$01
		beqz	v0,gotCardEvent
		li		v0,$2

		lw		a0,saveT3
		li		t2,$b0
        jalr	t2						; test event
        li		t1,$0b

		subiu	v0,v0,$01
		beqz	v0,gotCardEvent
		li		v0,$3

		j		getCardResultLoop
		nop

gotCardEvent
		lw		ra,saveRA
		nop
		jr		ra
		nop

;--------------------------------------------------------------------------
imageVars
;	makes a copy of the volatile vars to they can be restored on soft reset
;--------------------------------------------------------------------------

		la		a0,volatile_vars_begin
		la		a1,volatile_vars_end
		la		v0,varCopySpace

imageVarsLoop
		lw		at,$0000(a0)
		addiu	a0,a0,$04
		sw		at,$0000(v0)
		bne		a0,a1,imageVarsLoop
		addiu	v0,v0,$04

		jr		ra
		nop

;--------------------------------------------------------------------------
restoreVars
;	copys image of vars back to original location
;--------------------------------------------------------------------------

		la		a0,volatile_vars_begin
		la		a1,volatile_vars_end
		la		v0,varCopySpace

restoreVarsLoop
		lw		at,$0000(v0)
		addiu	v0,v0,$04
		sw		at,$0000(a0)
		addiu	a0,a0,$04
		bne		a0,a1,restoreVarsLoop
		nop

		jr		ra
		nop

;--------------------
soundCounterEventInit
;--------------------

		sw		ra,saveRA

		li		a0,$01				;Enter Critical
        syscall $0

		li		a0,$f2000001		;RCntCNT1
		li		a1,$0002
		li		a2,$1000
		la		a3,soundQuarterCallback
		li		t2,$b0
        jalr	t2						;open the event
        li		t1,$08
		sw		v0,soundQuarterEventHandle
		or		s0,v0,zero
		
		li		a0,$02				;Exit Critical
        syscall $0

		or		a0,s0,zero
		li		t2,$b0
        jalr	t2						;enable the event
        li		t1,$0c

		lw		ra,saveRA
		nop
		jr		ra
		nop

;--------------------------------------------------
soundCounterInit
;	set up a root counter to go off every 1/4 frame
;--------------------------------------------------

		sw		ra,saveRA

		li		sp,$801fff00

	;this write to the RCnt hardware regs to set them up
		li		a0,$f2000001		;RCntCNT1
		li		a1,$9999			;high enough so it won't go off before vblank resets it on first frame
		li		a2,$1000			;RCntIntr
		li		t2,$b0
        jalr	t2
        li		t1,$02
		
	;this turns on bit 0x20 in $1f801074 to enable interupt processing
		li		a0,$f2000001		;RCntCNT1
		li		t2,$b0
        jalr	t2
        li		t1,$04

		lw		ra,saveRA
		nop
		jr		ra
		nop

;-----------------------------
soundQuarterCallback
;	called every quarter frame
;-----------------------------

		subiu	sp,sp,$1C
		sw		ra,$0010(sp)
		sw		s7,$0014(sp)
		sw		s0,$0018(sp)

		lui		s7,$8001

		lw		s0,quarterCount
		nop
		addiu	a1,s0,$01
		andi	a1,a1,$03
		sw		a1,quarterCount

		la		v0,soundRegs
		sll		at,s0,$05
		addu	v0,v0,at

		lw		v1,$0000(v0)
		sw		zero,$0000(v0)
		andi	at,v1,$FF00
		beqz	at,noUpd4000
		addiu	v0,v0,$04

		lbu		a0,sq1LastChan
		sb		v1,$4000(s7)
		srl		a1,a0,$01
		srl		t9,v1,$06
		andi	t9,t9,$03
		beq		a1,t9,noUpd4000			;if changing duty cycle
		nop

		lw		t8,sq1LastParams		;load last pitch + vol sent to SPU
		li		gp,$1f801c00

		sll		at,a0,$04
		or		at,at,gp
		sh		zero,$0000(at)			;turn off old channel
		sh		zero,$0002(at)

		sll		t9,t9,$01
		andi	a0,a0,$01
		or		t9,t9,a0
		sb		t9,sq1LastChan
		sll		at,t9,$04
		or		at,at,gp
		sh		t8,$0004(at)			;turn on new one w/ right pitch
		srl		t8,t8,$10
		sh		t8,$0000(at)
		sh		t8,$0002(at)

noUpd4000
		srl		v1,v1,$10
		andi	at,v1,$FF00
		beqz	at,noUpd4001
		nop

		sb		v1,$4001(s7)

noUpd4001
		lw		v1,$0000(v0)
		sw		zero,$0000(v0)
		andi	at,v1,$FF00
		beqz	at,noUpd4002
		addiu	v0,v0,$04

		lbu		a1,$4003(s7)
		sb		v1,$4002(s7)
		sll		a1,a1,$08
		andi	at,v1,$FF
		or		a1,a1,at
		andi	a1,a1,$7FF
		jal		newSquareFreq
		li		a0,$0

noUpd4002
		srl		v1,v1,$10
		andi	at,v1,$FF00
		beqz	at,noUpd4003
		nop

		sb		v1,$4003(s7)

		li		a0,$F
		sb		a0,sq1EnvLooper

		lbu		a1,$4002(s7)
		sll		at,v1,$08
		or		a1,a1,at
		andi	a1,a1,$7FF
		jal		newSquareFreq
		li		a0,$0	

noUpd4003
		lw		v1,$0000(v0)
		sw		zero,$0000(v0)
		andi	at,v1,$FF00
		beqz	at,noUpd4004
		addiu	v0,v0,$04

		lbu		a0,sq2LastChan
		sb		v1,$4004(s7)
		srl		a1,a0,$01
		srl		t9,v1,$06
		andi	t9,t9,$03
		beq		a1,t9,noUpd4004			;if changing duty cycle
		nop

		lw		t8,sq2LastParams		;load last pitch + vol sent to SPU
		li		gp,$1f801c80

		sll		at,a0,$04
		or		at,at,gp
		sh		zero,$0000(at)			;turn off old channel
		sh		zero,$0002(at)

		sll		t9,t9,$01
		andi	a0,a0,$01
		or		t9,t9,a0
		sb		t9,sq2LastChan
		sll		at,t9,$04
		or		at,at,gp
		sh		t8,$0004(at)			;turn on new one w/ right pitch
		srl		t8,t8,$10
		sh		t8,$0000(at)
		sh		t8,$0002(at)

noUpd4004
		srl		v1,v1,$10
		andi	at,v1,$FF00
		beqz	at,noUpd4005
		nop

		sb		v1,$4005(s7)

noUpd4005
		lw		v1,$0000(v0)
		sw		zero,$0000(v0)
		andi	at,v1,$FF00
		beqz	at,noUpd4006
		addiu	v0,v0,$04

		lbu		a1,$4007(s7)
		sb		v1,$4006(s7)
		sll		a1,a1,$08
		andi	at,v1,$FF
		or		a1,a1,at
		andi	a1,a1,$7FF
		jal		newSquareFreq
		li		a0,$1

noUpd4006
		srl		v1,v1,$10
		andi	at,v1,$FF00
		beqz	at,noUpd4007
		nop

		sb		v1,$4007(s7)

		li		a0,$F
		sb		a0,sq2EnvLooper

		lbu		a1,$4006(s7)
		sll		at,v1,$08
		or		a1,a1,at
		andi	a1,a1,$7FF
		jal		newSquareFreq
		li		a0,$1

noUpd4007
		lw		v1,$0000(v0)
		sw		zero,$0000(v0)
		andi	at,v1,$FF00
		beqz	at,noUpd4008
		addiu	v0,v0,$04

		lbu		a0,triLinMode
		sb		v1,$4008(s7)
		beqz	a0,noUpd4008		;if lin mode = 1
		nop

		andi	a0,v1,$7F
		sb		a0,triLinCtr			;lin counter = val

noUpd4008							;tri channel doesn't use 4009
noUpd4009
		lw		v1,$0000(v0)
		sw		zero,$0000(v0)
		andi	at,v1,$FF00
		beqz	at,noUpd400a
		addiu	v0,v0,$04

		lbu		a1,$400b(s7)
		sb		v1,$400a(s7)
		sll		a1,a1,$08
		andi	at,v1,$FF
		or		a1,a1,at
		jal		newTriFreq
		andi	a1,a1,$7FF

noUpd400a
		srl		v1,v1,$10
		andi	at,v1,$FF00
		beqz	at,noUpd400b
		nop

		lbu		a0,$4008(s7)
		li		a1,$01
		sb		a1,triLinMode
		andi	a0,a0,$7F
		sb		a0,triLinCtr

		lbu		a1,$400a(s7)
		sb		v1,$400b(s7)
		sll		at,v1,$08
		or		a1,a1,at
		jal		newTriFreq
		andi	a1,a1,$7FF

noUpd400b
		lw		v1,$0000(v0)
		sw		zero,$0000(v0)
		andi	at,v1,$FF00
		beqz	at,noUpd400c
		addiu	v0,v0,$04

		sb		v1,$400c(s7)

noUpd400c						;400d not used by noise chan
noUpd400d
		lw		v1,$0000(v0)
		sw		zero,$0000(v0)
		andi	at,v1,$FF00
		beqz	at,noUpd400e
		addiu	v0,v0,$04

		sb		v1,$400e(s7)
		andi	a0,v1,$80
		bnez	a0,noise93setPitch
		lui		gp,$1f80

		lhu		a0,$1daa(gp)
		andi	a1,v1,$0F
		la		a2,noiseFreqs
		addu	a2,a2,a1
		lbu		a1,$0000(a2)
		andi	a0,a0,$C0FF
		sll		a1,a1,$08
		or		a0,a0,a1
		sh		a0,$1daa(gp)
		j		noUpd400e
		nop

noise93setPitch

		la		a2,noise93offsets
		andi	a0,v1,$F
		sll		a0,a0,$02
		addu	a2,a2,a0
		lw		a2,$0000(a2)
		li		t8,NOISE93_BASE
		addu	a2,a2,t8
		srl		a2,a2,$03
		li		at,$4
		sh		at,$1d8e(gp)
		sh		a2,$1d26(gp)
		sh		at,$1d8a(gp)

noUpd400e
		srl		v1,v1,$10
		andi	at,v1,$FF00
		beqz	at,noUpd400f
		nop

		sb		v1,$400f(s7)
		li		a0,$F
		sb		a0,noiseEnvLooper

noUpd400f

		bnez	s0,soundQ1
		subiu	s0,s0,$01

;-------------
;First Quarter
;-------------

		jal		doSq1Quarter
		nop
		jal		doSq2Quarter
		nop
		jal		doTriQuarter
		nop
		jal		doNoiseQuarter
		nop

		j		endSoundInt
		nop

soundQ1
		bnez	s0,soundQ2
		subiu	s0,s0,$01

;-------------
;Second Quarter
;-------------

		jal		doSq1Quarter
		nop
		jal		doSq1Half
		nop
		jal		doSq2Quarter
		nop
		jal		doSq2Half
		nop
		jal		doTriQuarter
		nop
		jal		doNoiseQuarter
		nop

		j		endSoundInt
		nop

soundQ2
		bnez	s0,soundQ3
		subiu	s0,s0,$01

;-------------
;Third Quarter
;-------------

		jal		doSq1Quarter
		nop
		jal		doSq2Quarter
		nop
		jal		doTriQuarter
		nop
		jal		doNoiseQuarter
		nop

		li		a0,$f2000001
		li		a1,$9999		;disable the counter to wait for vblank
		li		a2,$1000		;when it will be reset
		li		t2,$b0
        jalr	t2
        li		t1,$02

		j		endSoundInt
		nop

soundQ3

;-------------
;Fourth Quarter
;-------------

		jal		doSq1Quarter
		nop
		jal		doSq1Half
		nop
		jal		doSq1Whole
		nop
		jal		doSq2Quarter
		nop
		jal		doSq2Half
		nop
		jal		doSq2Whole
		nop
		jal		doTriQuarter
		nop
		jal		doTriWhole
		nop
		jal		doNoiseQuarter
		nop
		jal		doNoiseWhole
		nop

		li		a0,$f2000001		;RCntCNT1
		li		a1,65			;65 scanlines per interupt
		li		a2,$1000			;RCntIntr
		li		at,$b0
        jalr	at
        li		t1,$02

endSoundInt
		jal		maybeKillSq1
		nop
		jal		maybeKillSq2
		nop
		jal		maybeKillTri
		nop
		jal		maybeKillNoise
		nop

		lw		ra,$0010(sp)
		lw		s7,$0014(sp)
		lw		s0,$0018(sp)
		jr		ra
		addiu	sp,sp,$1C

;----------------------------------------------------
maybeKillSq1
;	kills sq1 if one of the silence conditions is met
;----------------------------------------------------

		lhu		a0,sq1WantedVol
		lw		a1,sq1Enabled
		lbu		a2,sq1LastChan

		andi	at,a1,$FF
		beqz	at,killItSq1
		andi	at,a1,$FF00
		beqz	at,killItSq1
		srl		at,a1,$10
		andi	at,at,$FF
		beqz	at,killItSq1
		nop

		lui		gp,$1f80
		sll		a2,a2,$04
		or		gp,gp,a2
		sh		a0,$1c00(gp)
		sh		a0,$1c02(gp)
		sh		a0,sq1LastParams+2
		jr		ra
		nop

killItSq1
		lui		gp,$1f80
		sll		a2,a2,$04
		or		gp,gp,a2
		sh		zero,$1c00(gp)
		sh		zero,$1c02(gp)
		sh		zero,sq1LastParams+2
		jr		ra
		nop

;----------------------------------------------------
maybeKillSq2
;	kills sq2 if one of the silence conditions is met
;----------------------------------------------------

		lhu		a0,sq2WantedVol
		lw		a1,sq2Enabled
		lbu		a2,sq2LastChan

		andi	at,a1,$FF
		beqz	at,killItSq2
		andi	at,a1,$FF00
		beqz	at,killItSq2
		srl		at,a1,$10
		andi	at,at,$FF
		beqz	at,killItSq2
		nop

		lui		gp,$1f80
		sll		a2,a2,$04
		or		gp,gp,a2
		sh		a0,$1c80(gp)
		sh		a0,$1c82(gp)
		sh		a0,sq2LastParams+2
		jr		ra
		nop

killItSq2
		lui		gp,$1f80
		sll		a2,a2,$04
		or		gp,gp,a2
		sh		zero,$1c80(gp)
		sh		zero,$1c82(gp)
		sh		zero,sq2LastParams+2
		jr		ra
		nop

;----------------------------------------------------
maybeKillTri
;	kills tri if one of the silence conditions is met
;----------------------------------------------------

		lw		a1,triEnabled
		lbu		t9,triIsOn

		andi	at,a1,$FF
		beqz	at,killItTri
		andi	at,a1,$FF00
		beqz	at,killItTri
		srl		t8,a1,$10
		andi	at,t8,$FF
		beqz	at,killItTri
		andi	at,t8,$FF00
		beqz	at,killItTri
		nop

		li		t8,$1700			;value seems about right
		lui		gp,$1f80
		sh		t8,$1d00(gp)
		sh		t8,$1d02(gp)
		bnez	t9,triDone			;if channel was off...
		nop

		li		t8,$01						;do KEY ON
		sh		t8,$1d8A(gp)
		li		t8,$01
		sb		t8,triIsOn

triDone
		jr		ra
		nop

killItTri
		lui		gp,$1f80
		li		t8,$01						;do KEY OFF
		sh		t8,$1d8E(gp)
		sb		zero,triIsOn
		jr		ra
		nop

;----------------------------------------------------
maybeKillNoise
;	kills sq1 if one of the silence conditions is met
;----------------------------------------------------

		lw		a1,noiseEnabled
		lhu		a0,noiseWantedVol		;wanted vol for noise is the 4 bit NES volume, not SPU volume

		andi	at,a1,$FF
		beqz	at,killItNoise
		andi	at,a1,$FF00
		beqz	at,killItNoise
		nop

		lbu		a2,$400e(s7)
		beqz	a0,noMathNoise
		sll		t8,a0,$0C
		li		at,$600
		multu	t8,at
		mflo	t8
		li		at,$E000
		divu	t8,at
		mflo	t8
		addiu	t8,t8,$70
noMathNoise
		andi	a2,a2,$80
		bnez	a2,noise93
		lui		gp,$1f80

		sh		zero,$1d20(gp)
		sh		zero,$1d22(gp)
		sh		t8,$1d10(gp)	;set the vol for 32k
		sh		t8,$1d12(gp)

		jr		ra
		nop

noise93

		beqz	t8,noMathNoise93
		nop

		subiu	t9,t8,$70
		li		at,$3A0
		multu	t9,at
		mflo	t9
		li		at,$600
		divu	t9,at
		mflo	t9
		addiu	t9,t9,$50
		addu	t8,t8,t9
		
noMathNoise93

		sh		zero,$1d10(gp)
		sh		zero,$1d12(gp)
		sh		t8,$1d20(gp)	;set the vol for 93 bit
		sh		t8,$1d22(gp)

		jr		ra
		nop

killItNoise
		
		lui		gp,$1f80
		sh		zero,$1d20(gp)		;silence both noise channels
		sh		zero,$1d22(gp)
		sh		zero,$1d10(gp)
		sh		zero,$1d12(gp)

		jr		ra
		nop

;-------------------------------------------------
doSq1Quarter
;	does env processing 4 times per frame (240 hZ)
;-------------------------------------------------

		lbu		a0,$4000(s7)
		nop

		andi	at,a0,$10
		bnez	at,useLiteralVolSq1
		nop

		lbu		t8,sq1EnvCnt
		nop
		subiu	t8,t8,$01
		sb		t8,sq1EnvCnt
		bnez	t8,endDoSq1Quarter
		nop

		andi	t8,a0,$F
		addiu	t8,t8,$01
		sb		t8,sq1EnvCnt

		lbu		t8,sq1EnvLooper
		nop
		bnez	t8,sq1EnvLooperNoLoop
		subiu	t8,t8,$01
		andi	at,a0,$20
		sll		at,at,$1A
		sra		at,at,$03
		srl		t8,at,$1C
sq1EnvLooperNoLoop
		sb		t8,sq1EnvLooper

		j		setVolSq1
		nop

useLiteralVolSq1

		andi	t8,a0,$F

setVolSq1

		beqz	t8,justVolSq1
		sll		t8,t8,$C

		li		at,$DE
		multu	at,t8
		mflo	t8
		li		at,$108000
		addu	t8,t8,at
		srl		t8,t8,$0C

justVolSq1

		sh		t8,sq1WantedVol		;set the vol
	
endDoSq1Quarter

		jr		ra
		nop

;-------------------------------------------------
doSq2Quarter
;	does env processing 4 times per frame (240 hZ)
;-------------------------------------------------

		lbu		a0,$4004(s7)
		nop

		andi	at,a0,$10
		bnez	at,useLiteralVolSq2
		nop

		lbu		t8,sq2EnvCnt
		nop
		subiu	t8,t8,$01
		sb		t8,sq2EnvCnt
		bnez	t8,endDoSq2Quarter
		nop

		andi	t8,a0,$F
		addiu	t8,t8,$01
		sb		t8,sq2EnvCnt

		lbu		t8,sq2EnvLooper
		nop
		bnez	t8,sq2EnvLooperNoLoop
		subiu	t8,t8,$01
		andi	at,a0,$20
		sll		at,at,$1A
		sra		at,at,$03
		srl		t8,at,$1C
sq2EnvLooperNoLoop
		sb		t8,sq2EnvLooper

		j		setVolSq2
		nop

useLiteralVolSq2

		andi	t8,a0,$F

setVolSq2

		beqz	t8,justVolSq2
		sll		t8,t8,$C

		li		at,$DE
		multu	at,t8
		mflo	t8
		li		at,$108000
		addu	t8,t8,at
		srl		t8,t8,$0C

justVolSq2

		sh		t8,sq2WantedVol		;set the vol
	
endDoSq2Quarter

		jr		ra
		nop

;-------------------------------------------------
doTriQuarter
;	does lin cnt processing 4 times per frame (240 hZ)
;-------------------------------------------------

		lw		a0,triEnabled
		lbu		a1,triLinMode

		andi	at,a0,$FF
		beqz	at,endDoTriQuarter
		nop

		beqz	a1,skipLinSet
		nop

		lbu		t8,$4008(s7)
		nop
		srl		t8,t8,$07
		sb		t8,triLinMode

skipLinSet

		srl		a0,a0,$18
		beqz	a0,endDoTriQuarter
		nop
		bnez	a1,endDoTriQuarter
		nop

		subiu	a0,a0,$01
		sb		a0,triLinCtr

endDoTriQuarter

		jr		ra
		nop

;-------------------------------------------------
doNoiseQuarter
;	does env processing 4 times per frame (240 hZ)
;-------------------------------------------------

		lbu		a0,$400c(s7)
		nop

		andi	at,a0,$10
		bnez	at,useLiteralVolNoise
		nop

		lbu		t8,noiseEnvCnt
		nop
		subiu	t8,t8,$01
		sb		t8,noiseEnvCnt
		bnez	t8,endDoNoiseQuarter
		nop

		andi	t8,a0,$F
		addiu	t8,t8,$01
		sb		t8,noiseEnvCnt

		lbu		t8,noiseEnvLooper
		nop
		bnez	t8,noiseEnvLooperNoLoop
		subiu	t8,t8,$01
		andi	at,a0,$20
		sll		at,at,$1A
		sra		at,at,$03
		srl		t8,at,$1C
noiseEnvLooperNoLoop
		sb		t8,noiseEnvLooper

		j		setVolNoise
		nop

useLiteralVolNoise

		andi	t8,a0,$F

setVolNoise

		sh		t8,noiseWantedVol		;set the nes 4-bit vol
	
endDoNoiseQuarter

		jr		ra
		nop

;-------------------------------------------------
doSq1Half
;	does sweep processing 2 times per frame (120 hZ)
;-------------------------------------------------

		lw		a0,sq1Enabled
		nop
		andi	at,a0,$FF
		beqz	at,endDoSq1Half
		andi	at,a0,$FF00
		beqz	at,endDoSq1Half
		srl		at,a0,$10
		andi	at,at,$FF
		beqz	at,endDoSq1Half
		nop

		lbu		a0,$4001(s7)
		nop
		andi	at,a0,$80
		beqz	at,endDoSq1Half
		nop

		lbu		a1,sq1BendCtr
		nop
		subiu	a1,a1,$01
		sb		a1,sq1BendCtr
		bnez	a1,endDoSq1Half
		nop

		srl		a1,a0,$04
		andi	a1,a1,$07
		addiu	a1,a1,$01
		sb		a1,sq1BendCtr

		andi	at,a0,$07
		beqz	at,endDoSq1Half
		nop

		lhu		a3,$4002(s7)
		nop
		andi	t8,a3,$F800		;save top bits in t8
		andi	a3,a3,$7FF
		srlv	a2,a3,at
		
		sll		a0,a0,$1C
		sra		a0,a0,$1F
		xor		a2,a2,a0
		addu	a3,a3,a2

		andi	a2,a3,$7FF
		or		a2,a2,t8		;restore top bits
		sh		a2,$4002(s7)

		or		a1,a3,zero
		or		v0,ra,zero		;save return addr
		jal		newSquareFreq
		li		a0,$0
		or		ra,v0,zero		;restore after call

endDoSq1Half

		jr		ra
		nop

;-------------------------------------------------
doSq2Half
;	does sweep processing 2 times per frame (120 hZ)
;-------------------------------------------------

		lw		a0,sq2Enabled
		nop
		andi	at,a0,$FF
		beqz	at,endDoSq2Half
		andi	at,a0,$FF00
		beqz	at,endDoSq2Half
		srl		at,a0,$10
		andi	at,at,$FF
		beqz	at,endDoSq2Half
		nop

		lbu		a0,$4005(s7)
		nop
		andi	at,a0,$80
		beqz	at,endDoSq2Half
		nop

		lbu		a1,sq2BendCtr
		nop
		subiu	a1,a1,$01
		sb		a1,sq2BendCtr
		bnez	a1,endDoSq2Half
		nop

		srl		a1,a0,$04
		andi	a1,a1,$07
		addiu	a1,a1,$01
		sb		a1,sq2BendCtr

		andi	at,a0,$07
		beqz	at,endDoSq2Half
		nop

		lhu		a3,$4006(s7)
		nop
		andi	t8,a3,$F800		;save top bits in t8
		andi	a3,a3,$7FF
		srlv	a2,a3,at
		
		sll		a0,a0,$1C
		sra		a0,a0,$1F
		xor		a2,a2,a0
		andi	a0,a0,$01
		addu	a2,a2,a0
		addu	a3,a3,a2

		andi	a2,a3,$7FF
		or		a2,a2,t8		;restore top bits
		sh		a2,$4006(s7)

		or		a1,a3,zero
		or		v0,ra,zero		;save return addr
		jal		newSquareFreq
		li		a0,$1
		or		ra,v0,zero		;restore after call

endDoSq2Half

		jr		ra
		nop

;-------------------------------------------------
doSq1Whole
;	does timer processing 1 time per frame (60 hZ)
;-------------------------------------------------

		lw		a0,sq1Enabled
		lbu		a1,$4000(s7)
		andi	at,a0,$FF
		beqz	at,endDoSq1Whole
		andi	at,a0,$FF00
		beqz	at,endDoSq1Whole
		andi	at,a1,$20
		bnez	at,endDoSq1Whole
		srl		a0,a0,$08

		andi	a0,a0,$FF
		subiu	a0,a0,$01
		sb		a0,sq1Timer
		
endDoSq1Whole
		
		jr		ra
		nop

;-------------------------------------------------
doSq2Whole
;	does timer processing 1 time per frame (60 hZ)
;-------------------------------------------------

		lw		a0,sq2Enabled
		lbu		a1,$4004(s7)
		andi	at,a0,$FF
		beqz	at,endDoSq2Whole
		andi	at,a0,$FF00
		beqz	at,endDoSq2Whole
		andi	at,a1,$20
		bnez	at,endDoSq2Whole
		srl		a0,a0,$08

		andi	a0,a0,$FF
		subiu	a0,a0,$01
		sb		a0,sq2Timer
		
endDoSq2Whole
		
		jr		ra
		nop

;-------------------------------------------------
doTriWhole
;	does timer processing 1 time per frame (60 hZ)
;-------------------------------------------------

		lw		a0,triEnabled
		lbu		a1,$4008(s7)
		andi	at,a0,$FF
		beqz	at,endDoTriWhole
		andi	at,a0,$FF00
		beqz	at,endDoTriWhole
		andi	at,a1,$80
		bnez	at,endDoTriWhole
		nop

		srl		a0,a0,$08
		andi	a0,a0,$FF
		subiu	a0,a0,$01
		sb		a0,triTimer

endDoTriWhole

		jr		ra
		nop

;-------------------------------------------------
doNoiseWhole
;	does timer processing 1 time per frame (60 hZ)
;-------------------------------------------------

		lw		a0,noiseEnabled
		lbu		a1,$400c(s7)
		andi	at,a0,$FF
		beqz	at,endDoNoiseWhole
		andi	at,a0,$FF00
		beqz	at,endDoNoiseWhole
		andi	at,a1,$20
		bnez	at,endDoNoiseWhole
		srl		a0,a0,$08

		andi	a0,a0,$FF
		subiu	a0,a0,$01
		sb		a0,noiseTimer
		
endDoNoiseWhole
		
		jr		ra
		nop

;---------------------------------------
newSquareFreq
;	updates SPU when square freq changes
;	in: a0 = chan # (0 or 1)
;	in: a1 = 11 bit NES wavelength
;---------------------------------------

		la		a3,sq1LastChan
		addu	a3,a3,a0			;get the old channel
		lbu		t8,$0000(a3)
		andi	a1,a1,$FFFF

		li		at,$07
		sltu	a2,at,a1
		slti	gp,a1,$800
		and		a2,a2,gp
		la		gp,sq1ValidFreq
		sll		at,a0,$02
		addu	gp,gp,at
		sb		a2,$0000(gp)
		beqz	a2,noNewSquChan		;return if new pitch is not valid
		nop

		sll		a1,a1,$0A			;calc new pitch
		li		at,$51049240
		div		at,a1
		mflo	a1				;a1 now has pitch that should go to SPU

		srl		a2,a1,$0E
		sltu	a2,zero,a2
		sll		at,a2,$01		;reduce pitch if needed
		or		at,at,a2
		srlv	a1,a1,at
		
		andi	t9,t8,$FE
		or		t9,t9,a2

		li		gp,$1f801c00
		sll		at,a0,$07
		or		gp,gp,at
		sll		at,t9,$04
		or		at,at,gp				;set new pitch
		sh		a1,$0004(at)

		sb		t9,$0000(a3)			;store new channel

		la		a3,sq1LastParams
		sll		at,a0,$02
		addu	a3,a3,at
		sh		a1,$0000(a3)		;store this as last pitch

		beq		t8,t9,noNewSquChan
		nop

		lhu		a0,$0002(a3)
		sll		t8,t8,$04
		sll		t9,t9,$04
		or		at,gp,t8
		sh		zero,$0000(at)
		sh		zero,$0002(at)
		or		at,gp,t9
		sh		a0,$0000(at)
		sh		a0,$0002(at)

noNewSquChan

		jr		ra
		nop

;---------------------------------------
newTriFreq
;	updates SPU when tri freq changes
;	in: a1 = 11 bit NES wavelength
;---------------------------------------

		li		at,$07
		sltu	a2,at,a1
		slti	gp,a1,$800
		and		a2,a2,gp
		sb		a2,triValidFreq
		beqz	a2,noNewTriChan		;return if new pitch is not valid
		nop

		sll		a1,a1,$0A			;calc new pitch
		li		at,$51049240
		div		at,a1
		mflo	a1				;a1 now has pitch that should go to SPU

		srl		a2,a1,$0E
		bnez	a2,triuseHI
		nop

		lhu		t9,triIsOn			;load for is on and is lo
		lui		gp,$1f80
		srl		at,t9,$08
		xori	at,at,$01
		and		at,at,t9
		beqz	at,justPitchLO
		nop

		li		at,TRI_BASE+$10
		srl		at,at,$03			;set to LO sample
		sh		at,$1d06(gp)
		j		justPitchHI
		nop

justPitchLO
		sh		a1,$1d04(gp)		;set pitch
		li		at,TRI_BASE+$10
		srl		at,at,$03			;set to LO sample
		sh		at,$1d06(gp)
		li		t8,$01
		sb		t8,triIsLo
		j		noNewTriChan
		nop
	
triuseHI

		lhu		t9,triIsOn			;load for is on and is lo
		lui		gp,$1f80
		srl		at,t9,$08
		and		at,at,t9
		beqz	at,justPitchHI
		nop

		li		at,$01				;do KEY OFF
		sh		at,$1d8E(gp)
		li		at,TRI_BASE+TRI_HI_OFFSET
		srl		at,at,$03
		sh		at,$1d06(gp)
		srl		a1,a1,$03
		sh		a1,$1d04(gp)		;set pitch
		li		at,$01				;do KEY ON
		sh		at,$1d8A(gp)
		sb		zero,triIsLo
		j		noNewTriChan
		nop

justPitchHI
		srl		a1,a1,$03
		sh		a1,$1d04(gp)		;set pitch
		li		at,TRI_BASE+TRI_HI_OFFSET
		srl		at,at,$03
		sh		at,$1d06(gp)
		sb		zero,triIsLo

noNewTriChan

		jr		ra
		nop

;------------------------------------------------
setDisplayNES
;	positions and inits the display for emulation
;------------------------------------------------
		sw		ra,saveRA

		lui		v0,$1f80

		li		at,$04000000		;dma off
		sw		at,GP1(v0)
		
		li		at,$60000000		;black rect over NES screen
		sw		at,GP0(v0)
		li		at,$01000200
		sw		at,GP0(v0)
		li		at,$01000200
		sw		at,GP0(v0)

		jal		VSync				;wait for vsync to enable, maybe less flicker
		nop

		lui		v0,$1f80
		li		at,$05040200		;display area is 512,256
		sw		at,GP1(v0)

		lw		ra,saveRA
		nop
		jr		ra
		nop

;------------------------------------------------
readFiles
;	reads needed files from CD
;------------------------------------------------

		subiu	sp,sp,$14
		sw		ra,$0010(sp)

		li		a0,$10
		la		a1,rom_img
		li		a2,$01
		jal		cdReadSector			;get the volume descriptor
		nop

		lw		a0,rom_img+$8C			;sector # for path table
		la		a1,rom_img
		li		a2,$01
		jal		cdReadSector			;get the path table
		nop

		lhu		a0,rom_img+$2			;sector # for root dir entry table
		la		a1,rom_img
		li		a2,$01
		jal		cdReadSector			;get the dir entry table
		nop

		la		a0,cdfilename_nes
		la		a1,rom_img
		jal		searchFilePos			;find the NES.EXE file on the CD
		nop								;so it can be read in later to reset
		sw		v0,cdfilepos_nes		;all the vars

		la		a0,cdfilename_rombank
		la		a1,rom_img
		jal		searchFilePos
		nop
		sw		v0,cdfilepos_rombank

		la		a0,cdfilename_saveicon
		la		a1,rom_img
		jal		searchFilePos
		nop
		sw		v0,cdfilepos_saveicon

		or		a0,v0,zero
		la		a1,rom_img
		li		a2,$01
		jal		cdReadSector			;read the save icon file
		nop

		la		a0,icon
		la		a1,rom_img
		li		a2,246
		jal		copyMem
		nop

		lw		ra,$0010(sp)
		nop
		jr		ra
		addiu	sp,sp,$14

;----------------------------------------------
searchFilePos
;	searches 9660 directory info for a filename
;	and returns it's starting sector#
;	in: a0 = points to file name
;	in: a1 = points to dir info
;	out: v0 = sector #
;----------------------------------------------
		
		li		t0,$0
searchFilePosNameLoop
		addu	at,a0,t0
		lbu		v0,$0000(at)
		addu	at,a1,t0
		lbu		v1,$0021(at)
		beqz	v0,searchFilePosMatch		;match if you reach end of filename
		addiu	t0,t0,$01
		beq		v0,v1,searchFilePosNameLoop
		nop

		lbu		at,$0000(a1)
		nop
		addu	a1,a1,at
		j		searchFilePosNameLoop
		li		t0,$0
		
searchFilePosMatch
		
		lwl		v0,$0005(a1)
		lwr		v0,$0002(a1)
		jr		ra
		nop


;-------------------------------------------
setupDisplay
;	inits the display environment
;-------------------------------------------

		sw		ra,saveRA

		lui		v0,$1f80

		lhu		a0,$1074(v0)
		sh		zero,$1074(v0)		;turn off int processing

		li		at,$04000000		;dma off
		sw		at,GP1(v0)

		li		at,$E3000000		;clip top left
		sw		at,GP0(v0)
		li		at,$E4FFFFFF		;clip bottom right
		sw		at,GP0(v0)
		li		at,$E5000000		;draw offset within clip
		sw		at,GP0(v0)
		li		at,$E6000000		;mask settings
		sw		at,GP0(v0)
		li		at,$E1000400		;can draw on display area
		sw		at,GP0(v0)
		li		at,$E2000000		;texture window setting
		sw		at,GP0(v0)
		
		li		at,$60000000		;black rect over whole frame buffer
		sw		at,GP0(v0)
		li		at,$00000000
		sw		at,GP0(v0)
		li		at,$01ff03ff
		sw		at,GP0(v0)

		li		at,$40000000		;black line to get gap
		sw		at,GP0(v0)
		li		at,$01ff0000
		sw		at,GP0(v0)
		li		at,$01ff03ff
		sw		at,GP0(v0)

		li		at,$40000000		;black line to get gap
		sw		at,GP0(v0)
		li		at,$000003ff
		sw		at,GP0(v0)
		li		at,$01ff03ff
		sw		at,GP0(v0)

		li		at,$05000000		;display area is 0,0
		sw		at,GP1(v0)

		li		at,$bfc7ff52
		lbu		v1,$0000(at)
		lui		at,$0800
		subiu	v1,v1,69			;display settings (NTSC/PAL, width, height, 24bit etc)
		sltiu	v1,v1,$01
		sll		v1,v1,$03
		or		at,at,v1
		sw		at,GP1(v0)

		bnez	v1,setPALranges
		lui		at,$1f80

		li		v0,$06C4E24E		;horz screen range NTSC
		sw		v0,GP1(at)
		li		v1,$07040010		;vert screen range NTSC
		j		afterRanges
		sw		v1,GP1(at)

setPALranges

		li		v0,$06C62262		;horz screen range PAL
		sw		v0,GP1(at)
		li		v1,$0704B42D		;vert screen range PAL
		sw		v1,GP1(at)

afterRanges

		sw		v0,gpuHrange
		sw		v1,gpuVrange

		lui		v0,$1f80
		sh		a0,$1074(v0)		;re-enable ints

		jal		VSync				;wait for vsync to enable, maybe less flicker
		nop

		lui		v0,$1f80
		li		at,$03000000		;unmask display
		sw		at,GP1(v0)

		lw		ra,saveRA
		nop
		jr		ra
		nop

;------------------------------------------
cdReadSector
;	reads one sector from the CD
;	a0 = start sector #
;	a1 = dest in mem
;	a2 = how many sectors to read
;------------------------------------------

		subiu	sp,sp,$1C
		sw		ra,$0010(sp)
		sw		s0,$0014(sp)
		sw		s1,$0018(sp)

		or		s0,a1,zero
		or		s1,a2,zero

		la		a1,cd_loc
		jal		libCDIntToPos
		nop

seekRetry
		li		a0,$02
		la		a1,cd_loc
		li		a2,$00
		li		a3,$00
		jal		libCD_cw
		nop

modeSetRetry
		li		a0,$80
		sb		a0,cd_mode

		li		a0,$0E
		la		a1,cd_mode
		li		a2,$00
		li		a3,$00
		jal		libCD_cw
		nop

		li		a0,$06
		li		a1,$00
		li		a2,$00
		li		a3,$00
		jal		libCD_cw
		nop

cdReadWaitForData
		lbu		a0,cd_stat_bytes
		li		a1,$01
		bne		a0,a1,cdReadWaitForData
		nop
		sb		zero,cd_stat_bytes

		or		a0,s0,zero
		jal		libCdGetSector
		nop

		addiu	s0,s0,$800
		subiu	s1,s1,$01
		bnez	s1,cdReadWaitForData
		nop

		li		a0,$01
		sb		a0,cd_stat_bytes

		li		a0,$09
		li		a1,$00
		li		a2,$00
		li		a3,$00
		jal		libCD_cw
		nop

		lw		ra,$0010(sp)
		lw		s0,$0014(sp)
		lw		s1,$0018(sp)
		jr		ra
		addiu	sp,sp,$1C 

;------------------------------------------
libCdInit
;	cd init routine recreated from psyq libs
;------------------------------------------

		subiu	sp,sp,$18
		sw		ra,$0010(sp)
		sw		s0,$0014(sp)

		lui		s0,$1f80

		lhu		v0,$1074(s0)
		nop
		ori		v0,v0,$04
		sh		v0,$1074(s0)

		li		at,$01
		sb		at,$1800(s0)

CDintWaitLoop
		lbu		v0,$1803(s0)
		nop
		andi	v0,v0,$07
		beqz	v0,CDintsClear
		nop

		li		at,$01
		sb		at,$1800(s0)
		li		at,$07
		sb		at,$1803(s0)
		li		at,$07
		sb		at,$1802(s0)
		j		CDintWaitLoop
		nop

CDintsClear

		li		v0,$02
		sb		v0,cd_stat_bytes
		sb		zero,cd_stat_bytes+1
		sb		zero,cd_stat_bytes+2

		sb		zero,$1800(s0)
		sb		zero,$1803(s0)

		li		at,$1325
		sw		at,$1020(s0)

		li		a0,$01
		li		a1,$00
		li		a2,$00
		li		a3,$00
		jal		libCD_cw
		nop

		li		a0,$0A
		li		a1,$00
		li		a2,$00
		li		a3,$00
		jal		libCD_cw
		nop

		li		a0,$0C
		li		a1,$00
		li		a2,$00
		li		a3,$00
		jal		libCD_cw
		nop

		li		a0,$0
		li		a1,$0
		jal		libCD_sync
		nop

	;init volumes here, but don't need to

		lw		ra,$0010(sp)
		lw		s0,$0014(sp)
		jr		ra
		addiu	sp,sp,$18



;-------------------------------------------
libCD_cw	;	sends a low level cd command
;	in: a0 = the command
;	in: a1 = pointer to params
;	in: a2 = pointer to results buffer
;	in: a3 = 0 for blocking, else no block
;-------------------------------------------

		subiu	sp,sp,$28
		sw		ra,$0010(sp)
		sw		s0,$0014(sp)
		sw		s1,$0018(sp)
		sw		s2,$001C(sp)
		sw		s3,$0020(sp)
		sw		s4,$0024(sp)

		or		s0,a0,zero		;the command
		or		s1,a1,zero		;pointer params
		or		s2,a2,zero		;pointer to results buffer
		or		s3,a3,zero		;0 to block, otherwise non-blocking
		lui		s4,$1f80

		li		a0,$00
		li		a1,$00
		jal		libCD_sync
		nop

		sb		zero,cd_stat_bytes

	; here i'm not loading the "other" property of the command and zeroing
	; the ready level (cd_stat_bytes+1) if it's not zero

		sb		zero,$1800(s4)
		la		v0,cd_num_args
		addu	v0,v0,s0
		lbu		v0,$0000(v0)
		nop
cdcwPassArgsLoop
		beqz	v0,cdcwDoneArgs
		nop

		lbu		v1,$0000(s1)
		addiu	s1,s1,$01
		sb		v1,$1802(s4)
		j		cdcwPassArgsLoop
		subiu	v0,v0,$01
		
cdcwDoneArgs
		sb		s0,$1801(s4)		; issue the command

		bnez	s3,cdcwDone
		nop

cdcwWaitLoop

		;checkcallback

		;beqz	v0,cdcwNotInCallbackMode
		;nop

		;code for in callback mode here

;cdcwNotInCallbackMode

		lbu		v0,cd_stat_bytes
		nop
		bnez	v0,cdcwstatusComplete
		nop

		j		cdcwWaitLoop
		nop

cdcwstatusComplete

		beqz	s2,cdcwNoResults
		nop
		
		li		at,$08
		la		a0,cdResults
cdcwResultsLoop
		lbu		v0,$0000(a0)
		addiu	a0,a0,$01
		sb		v0,$0000(s2)
		subiu	at,at,$01
		bnez	at,cdcwResultsLoop
		addiu	s2,s2,$01

cdcwNoResults

		lbu		v0,cd_stat_bytes
		li		at,$05
		bne		v0,at,cdcwDone
		li		v0,$00

		li		v0,-1				;return -1 if error condition

cdcwDone
		lw		ra,$0010(sp)
		lw		s0,$0014(sp)
		lw		s1,$0018(sp)
		lw		s2,$001C(sp)
		lw		s3,$0020(sp)
		lw		s4,$0024(sp)
		jr		ra
		addiu	sp,sp,$28


;-----------------------------------------
libCD_sync	; waits for command to finish
;	in: a0 = 0 for blocking, else no block
;	in: a1 = pointer to results buffer
;-----------------------------------------

		subiu	sp,sp,$14
		sw		ra,$0010(sp)

cdsyncWaitLoop
		;checkcallback

		;beqz	v0,cdsyncNotInCallbackMode
		;nop

		;code for in callback mode here


cdsyncNotInCallbackMode
		lbu		v0,cd_stat_bytes
		;li		at,$02
		;beq		v0,at,cdstatusComplete
		;li		at,$05
		;beq		v0,at,cdstatusComplete
		;nop
		
		nop
		bnez	v0,cdstatusComplete
		nop

		beqz	a0,cdsyncWaitLoop
		nop

cdstatusComplete
		lw		ra,$0010(sp)
		nop
		jr		ra
		addiu	sp,sp,$14

;------------------------------------------
libCDIntToPos
;	directly from the libs
;	a0 = sector #
;	a1 = pointer to CdlLOC struct (4 bytes)
;------------------------------------------
		lui	v1,$1B4E
		ori	v1,v1,$81B5
		addiu	a0,a0,150
		mult	a0,v1
		move	v0,a1
		lui	a1,$8888
		ori	a1,a1,$8889
		mfhi	v1
		sra	a3,v1,3
		sra	v1,a0,31
		subu	a3,a3,v1
		mult	a3,a1
		lui	t1,$6666
		ori	t1,t1,$6667
		sll	a1,a3,2
		addu	a1,a1,a3
		sll	v1,a1,4
		mfhi	a2
		subu	v1,v1,a1
		subu	a0,a0,v1
		mult	a0,t1
		sra	v1,a3,31
		addu	t0,a2,a3
		sra	t0,t0,5
		subu	t0,t0,v1
		sll	v1,t0,4
		subu	v1,v1,t0
		mfhi	a1
		sll	v1,v1,2
		subu	a3,a3,v1
		mult	a3,t1
		sra	v1,a0,31
		sra	a1,a1,2
		subu	a1,a1,v1
		sll	a2,a1,4
		sll	v1,a1,2
		addu	v1,v1,a1
		sll	v1,v1,1
		subu	a0,a0,v1
		mfhi	t3
		addu	a2,a2,a0
		sra	v1,a3,31
		mult	t0,t1
		sb	a2,2(v0)
		sra	a0,t3,2
		subu	a0,a0,v1
		sll	a1,a0,4
		sll	v1,a0,2
		addu	v1,v1,a0
		sll	v1,v1,1
		subu	a3,a3,v1
		addu	a1,a1,a3
		sra	v1,t0,31
		sb	a1,1(v0)
		mfhi	t1
		sra	a0,t1,2
		subu	a0,a0,v1
		sll	a1,a0,4
		sll	v1,a0,2
		addu	v1,v1,a0
		sll	v1,v1,1
		subu	t0,t0,v1
		addu	a1,a1,t0
		jr	ra
		sb	a1,0(v0)

;------------------------------------------------
libCdGetSector
;	DMAs a sector from the cd hardware buf to mem
;	a0 = dest in mem for the data
;------------------------------------------------

		lui		t0,$1f80

		sb		zero,$1800(t0)
		li		at,$80
		sb		at,$1803(t0)
		li		at,$00020943
		sw		at,$1018(t0)
		li		at,$1323
		sw		at,$1020(t0)
		lw		v0,$10f0(t0)
		nop
		ori		v0,v0,$8000
		sw		v0,$10f0(t0)
		sw		a0,$10b0(t0)
		li		at,$00010200		;want to send 512 words = 2048 bytes
		sw		at,$10b4(t0)
cdGetSectorWaitReg0
		lbu		v0,$1800(t0)
		nop
		andi	v0,v0,$40
		beqz	v0,cdGetSectorWaitReg0
		nop
		li		at,$11000000
		sw		at,$10b8(t0)
cdGetSectorWaitDMABit
		lw		v0,$10b8(t0)
		lui		at,$0100
		and		v0,v0,at
		bnez	v0,cdGetSectorWaitDMABit
		nop
		li		at,$1325
		sw		at,$1020(t0)
		jr		ra
		nop

;--------------------------------------
libCardInit
;	recreation of psyq InitCARD() function
;--------------------------------------

		subiu	sp,sp,$14
		sw		ra,$0010(sp)

		li		a0,$00
		li		t2,$B0
		jalr	t2					;ChangeClearPAD(0)
		li		t1,$5B

		jal		VSync
		nop

		li		a0,$01
		syscall					;enterCriticalSection
		or		s0,v0,zero			;save return val

		li		a0,$01
		li		t2,$B0
		jalr	t2					;InitCard(1)
		li		t1,$4A

		li		v0,$DF80
		la		t0,card_patch_start
		la		t1,card_patch_end	; copy the mem card patch into the kernel
copy_patch
		lw		a0,$0000(t0)
		addiu	t0,t0,$04
		sw		a0,$0000(v0)
		bne		t0,t1,copy_patch
		addiu	v0,v0,$04

	; _patch_card

		li		t2,$B0
		jalr	t2					;get C0 table call
		li		t1,$56

		lw		v0,$0018(v0)				;load address of "ExceptionHandler" (0xC80, where it jumps on exceptions)
		nop
		lhu		a0,$0070(v0)
		lhu		a1,$0074(v0)
		sll		a0,a0,$10
		or		v0,a0,a1
		addiu	v0,v0,$0028				;v0 has address of code after check that int is on in 1070 but before 1074 check returns if 0

		la		a0,second_patch_start
		la		a1,second_patch_end
copy_second
		lw		t0,$0000(a0)
		addiu	a0,a0,$04
		sw		t0,$0000(v0)
		bne		a0,a1,copy_second
		addiu	v0,v0,$04

		lui		at,$0001
		sw		v0,$DFFC(at)		;store address to jump back to

	; _patch_card2

		li		t2,$B0
		jalr	t2					;get B0 table call
		li		t1,$57

		lw		v0,$016C(v0)		;get address of B0-5B call (changeclearpad)
		nop

		la		a0,third_patch_start
		la		a1,third_patch_end
copy_third
		lw		t0,$0000(a0)
		addiu	a0,a0,$04
		sw		t0,$09C8(v0)
		bne		a0,a1,copy_third
		addiu	v0,v0,$04

	; _patch_card_info

		li		t2,$B0
		jalr	t2					;get B0 table call
		li		t1,$57

		lw		v0,$016C(v0)		;get address of B0-5B call (changeclearpad)
		nop
		addiu	v0,v0,$1988
		sw		zero,$0000(v0)

		li		t2,$A0
		jalr	t2					; flush cache
		li		t1,$44

		li		at,$01
		bne		s0,at,libCardNoExit
		nop
		li		a0,$02
		syscall					;exitCriticalSection
libCardNoExit

	;lib's startcard stuff

		li		a0,$01
		syscall					;enterCriticalSection
		or		s0,v0,zero			;save return val

		li		a0,$00
		li		t2,$B0
		jalr	t2					;bios startCard()
		li		t1,$4B

		li		a0,$00
		li		t2,$B0
		jalr	t2					;ChangeClearPAD(0)
		li		t1,$5B

		li		at,$01
		bne		s0,at,libCardNoExit2
		nop
		li		a0,$02
		syscall					;exitCriticalSection
libCardNoExit2

	;lib's _bu_init stuff

		li		a0,$00			;(freezing here)
		li		t2,$A0
		jalr	t2					;bios _bu_init() call
		li		t1,$70

		lw		ra,$0010(sp)
		nop
		jr		ra
		addiu	sp,sp,$14

; this is the start of the memory card patch
card_patch_start
	lhu	t7,10(v1)
	lui	t0,$0000
	or	t8,t7,v0
	ori	t9,t8,$0012
	sh	t9,10(v1)
	li	t0,40
text_5C:
	addiu	t0,t0,-1
	bnez	t0,text_5C
	nop
	jr	ra
	nop

	lw	v0,$1074(v1)	// this line would be at $DFAC where the jump goes from the patch
	nop
	andi	v0,v0,$0080
	beqz	v0,text_AC
	nop
text_84:
	lw	v0,$1044(v1)
	nop
	andi	v0,v0,$0080
	bnez	v0,text_84
	nop
	lui	v0,$0001
	lw	v0,$DFFC(v0)	load the address to jump back to that was set in _patch_card
	nop
	jr	v0
	nop
text_AC:
	jr	ra
	nop
card_patch_end

second_patch_start
	lui		v0,$A001
	addiu	v0,v0,$DFAC
	jr		v0
	nop
	nop
second_patch_end

third_patch_start
	lui		t0,$A001
	addiu	t0,t0,$DF80
	jalr	ra,t0
	nop
	nop
third_patch_end

;--------------------------------------------
libPadInit
;	-do what libs do to init pads
;--------------------------------------------

	; padinitdirect stuff first but doesn't really do anything

	; padstartcom stuff

		li		a0,$01
		syscall					;enterCriticalSection

	;enqueue the int handler

		lui		gp,$1f80
		li		at,$FFFFFFFE	;force rcnt3 not pending
		sw		at,$1070(gp)

		lw		v0,$1074(gp)
		nop						;enable rcnt3 int processing
		ori		v0,v0,$01
		sw		v0,$1074(gp)

		li		a0,$03
		li		a1,$00
		li		t2,$C0
		jalr	t2					;ChangeClearRCnt(3,0) bios call
		li		t1,$0A

		li		a0,$02
		syscall					;exit critical



;------------------------------------------------------------------------
prepareMemcardData	;writes mem card file header and compresses sram data
; in:a0=where to put prepared data
;------------------------------------------------------------------------
		sw		s0,saveS0
		sw		ra,saveS1

		li		v0,$53			;'S'
		sb		v0,$0000(a0)
		li		v0,$43			;'C'
		sb		v0,$0001(a0)
		li		v0,$11			;0x11 for 1 icon, 0x12 for 2, 0x13 for 3
		sb		v0,$0002(a0)
		li		v0,$01			;1 block in size
		sb		v0,$0003(a0)

		li		v0,$6D82		;'N'
		sh		v0,$0004(a0)
		li		v0,$6482		;'E'
		sh		v0,$0006(a0)
		li		v0,$7282		;'S'
		sh		v0,$0008(a0)
		li		v0,$4681		;':'
		sh		v0,$000A(a0)
		addiu	a0,a0,$C

		;game title was copied to buname+5 on load

		la		v0,buname+5
		li		t8,$14
asciiConvLoop
		lbu		v1,$0000(v0)
		addiu	v0,v0,$01

		subiu	at,v1,$30
		bltz	at,asciiNotNum
		subiu	at,at,$09
		bgtz	at,asciiNotNum
		nop

		;convert ASCII number 0-9 to shift-jis
		addiu	v1,v1,$1F
		sll		v1,v1,$08
		ori		v1,v1,$82
		sh		v1,$0000(a0)
		addiu	a0,a0,$02
		j		asciiConvDone
		nop

asciiNotNum
		subiu	at,v1,$61
		bltz	at,asciiNotLowerCase
		nop
		subiu	v1,v1,$20	;convert to upper case
asciiNotLowerCase
		subiu	at,v1,$41
		bltz	at,asciiNotAlpha
		subiu	at,at,$19
		bgtz	at,asciiNotAlpha
		nop

		;convert upper case ASCII letter to shift-jis
		addiu	v1,v1,$1F
		sll		v1,v1,$08
		ori		v1,v1,$82
		sh		v1,$0000(a0)
		addiu	a0,a0,$02
		j		asciiConvDone
		nop

asciiNotAlpha

		;write space char if not alpha or num
		li		v1,$4081
		sh		v1,$0000(a0)
		addiu	a0,a0,$02

asciiConvDone
		subiu	t8,t8,$01
		bgtz	t8,asciiConvLoop
		nop

		sh		zero,$0000(a0)		;term game name
		sh		zero,$0002(a0)
		sh		zero,$0004(a0)
		sh		zero,$0006(a0)
		sh		zero,$0008(a0)
		sh		zero,$000A(a0)
		sh		zero,$000C(a0)
		sh		zero,$000E(a0)
		addiu	a0,a0,$10

		sw		zero,$0000(a0)		;28 bytes padding
		sw		zero,$0004(a0)
		sw		zero,$0008(a0)
		sw		zero,$000C(a0)
		sw		zero,$0010(a0)
		sw		zero,$0014(a0)
		sw		zero,$0018(a0)
		addiu	a0,a0,$1C

		la		v0,icon+$36		;palette offset in bmp
		li		t8,16			;16 colors
iconPalDecodeLoop
		lhu		v1,$0000(v0)
		lhu		t9,$0002(v0)
		addiu	v0,v0,$04
		
		andi	at,v1,$FF
		andi	v1,v1,$FF00
		andi	t9,t9,$FF
		or		v1,v1,t9
		or		t9,at,zero

		srl		gp,v1,$03
		andi	gp,gp,$1F
		andi	at,v1,$F800
		srl		at,at,$06
		or		gp,gp,at
		srl		at,t9,$03
		andi	at,at,$1F
		sll		at,at,$0A
		or		gp,gp,at

		sh		gp,$0000(a0)
		addiu	a0,a0,$02
		subiu	t8,t8,$01
		bgtz	t8,iconPalDecodeLoop
		nop

		la		v0,icon+$EE		;end of bitmap data in bmp - 8 (top row of pic)
		li		t8,$10			;16 rows in the picture
iconBitmapCopyLoop
		lwl		v1,$0003(v0)
		lwr		v1,$0000(v0)
		li		at,$F0F0F0F0
		and		t9,v1,at
		sll		v1,v1,$04
		and		v1,v1,at
		srl		t9,t9,$04
		or		v1,v1,t9
		swl		v1,$0003(a0)
		swr		v1,$0000(a0)
		lwl		v1,$0007(v0)
		lwr		v1,$0004(v0)
		li		at,$F0F0F0F0
		and		t9,v1,at
		sll		v1,v1,$04
		and		v1,v1,at
		srl		t9,t9,$04
		or		v1,v1,t9
		swl		v1,$0007(a0)
		swr		v1,$0004(a0)
		addiu	a0,a0,$08
		subiu	v0,v0,$08
		subiu	t8,t8,$01
		bgtz	t8,iconBitmapCopyLoop
		nop

		or		s0,a0,zero		;save a pointer to the freq table for later

		; a0 has dest for freq table
		li		a1,$80016000
		li		a2,$2000
		jal		buildFreqTable
		nop

		or		a1,s0,zero			;where the freq table is
		li		a2,rom_img			;where to build the tree
		jal		buildHuffmanTree
		nop

		; a0 has destination address for encoded data
		li		a1,rom_img			;where huff tree is
		li		a2,$80016000		;where data to encode is
		li		a3,$2000			;size of data to encode
		jal		huffmanEncode
		nop

		lw		ra,saveS1
		lw		s0,saveS0
		jr		ra
		nop
		
;------------------------
buildFreqTable
; in: a0 = destination
; in: a1 = source data
; in: a2 = size of data
;------------------------

		li		t8,$0			;counter
		li		t9,$0			;index
		or		v0,a1,zero
		addu	s2,a1,a2		;end of data
huffValLoop
		lbu		v1,$0000(v0)
		addiu	v0,v0,$01
		bne		v1,t9,huffNoMatch
		nop
		addiu	t8,t8,$01
huffNoMatch
		bne		s2,v0,huffValLoop
		nop
		sh		t8,$0000(a0)
		addiu	a0,a0,$02
		addiu	t9,t9,$01
		or		v0,a1,zero
		andi	at,t9,$FF
		bnez	at,huffValLoop
		li		t8,$0

		jr		ra
		nop

;--------------------------------------------
huffmanEncode
; in: a0 = destination for encoded data
; in: a1 = huffman tree address
; in: a2 = source data address
; in: a3 = source data size
;--------------------------------------------

		or		s0,ra,zero			;save return addr
		sb		zero,bitIOcounter	;init bit I/O function
		li		gp,$1f800000		;256 byte buffer to reverse data from

huffEncodeLoop

		lbu		t8,$0000(a2)
		addiu	a2,a2,$01
		subiu	a3,a3,$01
		
		or		v0,a1,zero
huffLeafSearch
		lw		at,$0010(v0)
		addiu	v0,v0,$14
		bne		at,t8,huffLeafSearch	
		nop
		subiu	v0,v0,$14				;v0 is pointer to start leaf

		li		t9,$0					;counter for reversing

		lw		v1,$0000(v0)
huffTraverseUp
		lw		t8,$000C(v0)			;load whether this is 0 node or 1 node
		addu	at,gp,t9
		sb		t8,$0000(at)
		addiu	t9,t9,$01
		or		v0,v1,zero
		lw		v1,$0000(v0)
		nop
		bnez	v1,huffTraverseUp
		nop

		subiu	t9,t9,$01
huffReverse
		addu	at,gp,t9
		lbu		t8,$0000(at)
		nop
		jal		bitWrite
		nop
		subiu	t9,t9,$01
		bgez	t9,huffReverse
		nop

		bnez	a3,huffEncodeLoop
		nop

		jal		bitWriteEnd
		nop

		or		ra,s0,zero
		jr		ra
		nop

;----------------------
bitWrite
; in: t8 = bit to write
; in: a0 = dest address
;----------------------
		lbu		t0,bitIOtmpVal
		lbu		t1,bitIOcounter
		srl		t0,t0,$01
		andi	t8,t8,$01
		sll		t8,t8,$07
		or		t0,t0,t8
		addiu	t1,t1,$01
		andi	t1,t1,$07
		sb		t1,bitIOcounter
		bnez	t1,bitWriteNoWrite
		nop
		sb		t0,$0000(a0)
		jr		ra
		addiu	a0,a0,$01
bitWriteNoWrite
		sb		t0,bitIOtmpVal
		jr		ra
		nop

;----------------------------
bitRead
; in: a0 = src address
; out: v0 = bit that was read
;----------------------------
		lbu		t0,$0000(a0)
		lbu		t1,bitIOcounter
		nop
		srlv	v0,t0,t1
		andi	v0,v0,$01
		addiu	t1,t1,$01
		andi	t1,t1,$07
		sb		t1,bitIOcounter
		sltiu	at,t1,$01
		jr		ra
		addu	a0,a0,at

;----------------------
bitWriteEnd
; in: a0 = dest address
;----------------------
		lbu		t1,bitIOcounter
		lbu		t0,bitIOtmpVal
		beqz	t1,bitWriteEndNoNeed
		nop
		li		at,$08
		subu	at,at,t1
		srlv	t0,t0,at
		sb		t0,$0000(a0)
		addiu	a0,a0,$01
bitWriteEndNoNeed
		jr		ra
		nop

;-----------------------------------------
buildHuffmanTree
; in: a1=addr of freq table
; in: a2=where to build tree
;-----------------------------------------

		or		s0,a2,zero		;save pointer to top of tree
		li		s1,$00			;remember number of nodes for searching

		li		v0,$0			;counter
huffLeafBuild
		lhu		t8,$0000(a1)
		addiu	a1,a1,$02
		beqz	t8,huffZeroFreq
		nop
		sw		zero,$0000(a2)		;parent
		sw		zero,$0004(a2)		;child1
		sw		zero,$0008(a2)		;child2
		sw		t8,$000C(a2)		;count
		sw		v0,$0010(a2)		;symbol
		addiu	a2,a2,$14
		addiu	s1,s1,$01			;one more node
huffZeroFreq
		addiu	v0,v0,$01
		andi	at,v0,$FF
		bnez	at,huffLeafBuild
		nop

		sll		s2,s1,$01
		subiu	s2,s2,$01			;# nodes you'll end up with at end

huffTreeBuild

		or		a1,s0,zero			;pointer to nodes
		li		a3,$FFFF			;min found so far
		li		v0,$0				;node counter

huffSearchSmall1
		lw		t8,$0000(a1)
		lw		t9,$000C(a1)
		bnez	t8,huffSearchSmall1noGood
		nop
		slt		at,t9,a3
		beqz	at,huffSearchSmall1noGood
		nop
		or		t0,a1,zero					;save pointer to min node
		or		a3,t9,zero					;save new min
huffSearchSmall1noGood
		addiu	v0,v0,$01
		bne		v0,s1,huffSearchSmall1
		addiu	a1,a1,$14

		sw		a1,$0000(t0)				;set what parent will be for the first min node

		or		a1,s0,zero			;pointer to nodes
		li		a3,$FFFF			;min found so far
		li		v0,$0				;node counter

huffSearchSmall2
		lw		t8,$0000(a1)
		lw		t9,$000C(a1)
		bnez	t8,huffSearchSmall2noGood
		nop
		slt		at,t9,a3
		beqz	at,huffSearchSmall2noGood
		nop
		or		t1,a1,zero					;save pointer to min node
		or		a3,t9,zero					;save new min
huffSearchSmall2noGood
		addiu	v0,v0,$01
		bne		v0,s1,huffSearchSmall2
		addiu	a1,a1,$14

		sw		a1,$0000(t1)				;set what parent will be for the second min node
		lw		t8,$000C(t0)
		lw		t9,$000C(t1)				;get old counts
		sw		zero,$0000(a1)				;\
		sw		t0,$0004(a1)
		sw		t1,$0008(a1)
		addu	t8,t8,t9					;	create new node
		sw		t8,$000C(a1)
		lui		at,$8000
		sw		at,$0010(a1)
		addiu	s1,s1,$01					;/
		sw		zero,$000C(t0)				;indicate t0 is the 0 node
		li		at,$01
		sw		at,$000C(t1)				;indicate t1 is the 1 node

		bne		s1,s2,huffTreeBuild			;loop until you have the right # of nodes
		nop

		jr		ra
		nop

;----------------------------------------------------
huffmanDecode
; in: a0=encoded data
; in: a1=dest for decoded data
; in: a2=size of decoded data
;----------------------------------------------------
		subiu	sp,sp,$28
		sw		ra,$0010(sp)
		sw		s0,$0014(sp)
		sw		s1,$0018(sp)
		sw		s2,$001C(sp)
		sw		s3,$0020(sp)
		sw		s4,$0024(sp)

		or		s3,a1,zero		;save these params, buildTree doesn't mess with a0
		or		s4,a2,zero

		or		a1,a0,zero
		li		a2,$80018000
		jal		buildHuffmanTree
		nop

		li		s0,$80018000
huffTreeTopSearch
		lw		at,$0000(s0)
		addiu	s0,s0,$14
		bnez	at,huffTreeTopSearch
		nop
		subiu	s0,s0,$14				;s0 points to top of tree

		sb		zero,bitIOcounter
		addiu	a0,a0,$200				;skip over freq table

huffDecodeLoop
		
		or		a1,s0,zero				;reset top of tree pointer
huffDecodeTraverse
		jal		bitRead
		nop
		addiu	a2,a1,$04
		sll		v0,v0,$02
		addu	a2,a2,v0
		lw		a1,$0000(a2)			;go down to the correct child
		nop
		lw		t8,$00010(a1)
		nop
		bltz	t8,huffDecodeTraverse	;negative symbol means keep going
		nop

		sb		t8,$0000(s3)
		addiu	s3,s3,$01
		subiu	s4,s4,$01
		bnez	s4,huffDecodeLoop
		nop

		lw		ra,$0010(sp)
		lw		s0,$0014(sp)
		lw		s1,$0018(sp)
		lw		s2,$001C(sp)
		lw		s3,$0020(sp)
		lw		s4,$0024(sp)
		jr		ra
		addiu	sp,sp,$28


PAL_SY_SX	equ $00010200			;the whole NES palette will be at 512, 1
PAL_DY_DX	equ $00000200			;the BG and Spr pals are right in a row at 512, 0
PAL_H_W		equ $00010001			;one dot per pal entry

BG1_Y_X		equ $00000380
BG2_Y_X		equ $000003C0

buildLists
		la		t0,palDMAlist		;start addr
		li		t1,16				;number of prims, 16 for BG pal
		li		t2,$08000000
		li		t3,PAL_SY_SX
		li		t4,PAL_DY_DX
		li		t5,PAL_H_W
palBGBuildLoop
		addiu	t6,t0,$0C
		li		t7,$00FFFFFF
		and		t6,t6,t7
		lui		t7,$0200
		or		t6,t6,t7
		sw		t6,$0000(t0)
		sw		zero,$0004(t0)
		sw		t4,$0008(t0)
		addiu	t4,t4,$01
		subiu	t1,t1,$01
		bnez	t1,palBGBuildLoop
		addiu	t0,t0,$0C

		la		t0,sprPalDMAlist	;start addr
		li		t1,16				;number of prims, 16 for sprite
		li		t2,$80000000
		li		t3,PAL_SY_SX
		li		t4,$0				; offset from PAL_DY_DX
		li		t5,PAL_H_W
palSprBuildLoop
		addiu	t6,t0,$24
		li		t7,$00FFFFFF
		and		t6,t6,t7
		lui		t7,$0800
		or		t6,t6,t7
		sw		t6,$0000(t0)
		sw		zero,$0004(t0)
		li		t6,PAL_DY_DX+16
		addu	t6,t6,t4
		sw		t6,$0008(t0)
		addiu	t6,t6,$04
		sw		t6,$0010(t0)
		addiu	t6,t6,$04
		sw		t6,$0018(t0)
		addiu	t6,t6,$04
		sw		t6,$0020(t0)
		addiu	t4,t4,$01
		andi	t6,t4,$04
		xor		t4,t4,t6
		sll		t6,t6,$02
		addu	t4,t4,t6
		subiu	t1,t1,$01
		bnez	t1,palSprBuildLoop
		addiu	t0,t0,$24

		la		t0,spriteDMAlist	;start addr
		li		t1,64				;number of prims to make
		li		t3,$E6000000
		li		t4,$2C808080
spriteBuildLoop
		addiu	t6,t0,$2C
		li		t7,$00FFFFFF
		and		t6,t6,t7
		lui		t7,$0A00			;9 words ($2C-textured 4 point poly)
		or		t6,t6,t7
		sw		t6,$0000(t0)
		sw		t3,$0004(t0)
		sw		t4,$0008(t0)
		sw		zero,$000C(t0)
		sw		zero,$0010(t0)
		sw		zero,$0014(t0)
		sw		zero,$0018(t0)
		sw		zero,$001C(t0)
		sw		zero,$0020(t0)
		sw		zero,$0024(t0)
		sw		zero,$0028(t0)
		subiu	t1,t1,$01
		bnez	t1,spriteBuildLoop
		addiu	t0,t0,$2C

		;subiu	t0,t0,$2C
		;li		t1,$06FFFFFF	;want it to point to next word after, not
		;sw		t1,$0000(t0)	;terminate

		la		t0,bg1DMAlist		;start addr
		li		t1,960				;number of prims to make
		li		t2,$80000000
		li		t3,$00000000		;destination Y_X
		li		t4,$00080002
		li		t5,$E6000000
		li		t8,$62000000
BG1BuildLoop
		addiu	t6,t0,$24
		li		t7,$00FFFFFF
		and		t6,t6,t7
		lui		t7,$0400
		or		t6,t6,t7
		sw		t6,$0000(t0)
		sw		t2,$0004(t0)
		sw		zero,$0008(t0)
		li		at,BG1_Y_X
		addu	at,at,t3
		sw		at,$000C(t0)
		sw		t4,$0010(t0)
		sw		t5,$0014(t0)
		sw		t8,$0018(t0)
		sw		at,$001C(t0)
		sw		t4,$0020(t0)
		addiu	t3,t3,$02
		andi	at,t3,$40
		li		t6,$FFFFFFBF
		and		t3,t3,t6
		sll		at,at,$0D
		addu	t3,t3,at
		subiu	t1,t1,$01
		bnez	t1,BG1BuildLoop
		addiu	t0,t0,$24

		la		t0,bg2DMAlist		;start addr
		li		t1,960				;number of prims to make
		li		t2,$80000000
		li		t3,$00000000		;destination Y_X
		li		t4,$00080002
		li		t5,$E6000000
		li		t8,$62000000
BG2BuildLoop
		addiu	t6,t0,$24
		li		t7,$00FFFFFF
		and		t6,t6,t7
		lui		t7,$0400
		or		t6,t6,t7
		sw		t6,$0000(t0)
		sw		t2,$0004(t0)
		sw		zero,$0008(t0)
		li		at,BG2_Y_X
		addu	at,at,t3
		sw		at,$000C(t0)
		sw		t4,$0010(t0)
		sw		t5,$0014(t0)
		sw		t8,$0018(t0)
		sw		at,$001C(t0)
		sw		t4,$0020(t0)
		addiu	t3,t3,$02
		andi	at,t3,$40
		li		t6,$FFFFFFBF
		and		t3,t3,t6
		sll		at,at,$0D
		addu	t3,t3,at
		subiu	t1,t1,$01
		bnez	t1,BG2BuildLoop
		addiu	t0,t0,$24

		li		t0,$00FFFFFF
		sw		t0,afterSprDMAlist
		li		t0,$E6000000
		sw		t0,afterSprDMAlist+4

		jr		ra
		nop

;------------------------------------------
sysInit
; ResetCallback recreation from the sony libs.
;------------------------------------------
		
		subiu	sp,sp,$14
		sw		ra,$0010(sp)

		lui		v0,$1f80
		sh		zero,$1074(v0)		;turn off all ints and clear pending ints?
		sh		zero,$1070(v0)

		li		t0,$33333333		;all DMA channels off
		sw		t0,$10f0(v0)

		la		a0,setjmpbuf
		li		t2,$A0
		jalr	t2					;setjmp
		li		t1,$13
		
		la		a0,setjmpbuf
		la		t0,hereAfterException		;set to jump to exception handler instead of this proc
		sw		t0,$0000(a0)

		la		a0,setjmpbuf
		li		t2,$B0
		jalr	t2					;HookEntryInt
		li		t1,$19

		lui		v0,$1f80

	;startIntrVSync					;init root count #1 + vsync handler dispatcher?

		li		t0,$0100
		sw		t0,$1114(v0)		;init root counter 1

		li		a0,$00
		li		t2,$B0
		jalr	t2					;ChangeClearPAD(0)
		li		t1,$5B

		li		a0,$03
		li		a1,$00
		li		t2,$C0
		jalr	t2					;ChangeClearRCnt(3, 0)
		li		t1,$0A

		lui		v0,$1f80

		li		t0,$0001
		sh		t0,$1074(v0)

	;startIntrDMA					;set up handler for DMA interupts

		sw		zero,$10f4(v0)
		
		li		t0,$0009
		sh		t0,$1074(v0)

		li		t2,$A0
		jalr	t2					;_96_remove
		li		t1,$72

		li		a0,$02				;exit critical section
		syscall

		lw		ra,$0010(sp)
		nop
		jr		ra
		addiu	sp,sp,$14

include except.asm

;------------------------------------------------------
askSave
;	asks the user if they want to save SRAM to mem card
;------------------------------------------------------

		subiu	sp,sp,$14
		sw		ra,$0010(sp)

		sb		zero,saveSelPos

		jal		textMode
		nop

		la		a0,saveMsg1
		li		a1,3
		jal		writeStrEnc
		nop

		la		a0,saveMsg2
		li		a1,8
		jal		writeStrEnc
		nop

		la		a0,saveMsg3
		li		a1,10
		jal		writeStrEnc
		nop

		lbu		t8,SRAMloaded
		nop
		beqz	t8,skipDelOption
		nop

		la		a0,saveMsg4
		li		a1,12
		jal		writeStrEnc
		nop

skipDelOption

		jal		updateSaveMenuDisplay
		nop

		la		a0,menu_Save
		jal		doMenu
		nop

		lw		ra,$0010(sp)
		nop
		jr		ra
		addiu	sp,sp,$14

save_start
		subiu	sp,sp,$14
		sw		ra,$0010(sp)

		lbu		t8,saveSelPos
		nop
		bnez	t8,notSaveIt
		subiu	t8,t8,$01

		la		a0,saveMsg6			;give saving message
		li		a1,17
		jal		writeStrEnc
		nop

		jal		updateSaveMenuDisplay
		nop

		lbu		a0,SRAMloaded
		nop
		bnez	a0,noCreateSave
		nop

		la		a0,buname
		li		a1,$00010200	;create - 1 blocks
		li		t0,$b0
		jalr	t0								; open
		li		t1,$32
		or		s0,v0,zero		;save handle in s0
	
		or		a0,s0,zero
		li		t0,$b0
		jalr	t0								; close
		li		t1,$36

noCreateSave
		la		a0,buname
		li		a1,$0002		;write access (don't use with create)
		li		t0,$b0
		jalr	t0								; open
		li		t1,$32
		or		s0,v0,zero		;save handle in s0

		li		a0,$80018000
		jal		prepareMemcardData
		nop

		or		a0,s0,zero
		li		a1,$80018000
		li		a2,$2000
		li		t0,$b0
		jalr	t0								; write
		li		t1,$35

		or		a0,s0,zero
		li		t0,$b0
		jalr	t0								; close
		li		t1,$36

		j		notEraseIt
		nop
	
notSaveIt
		beqz	t8,notEraseIt
		nop
		
		la		a0,saveMsg7
		li		a1,12
		jal		writeStrEnc
		nop

		jal		updateSaveMenuDisplay
		nop

		la		a0,buname
		li		t0,$b0
		jalr	t0								; delete
		li		t1,$45

notEraseIt

		lw		ra,$0010(sp)
		li		v0,$01				;want menu to return
		jr		ra
		addiu	sp,sp,$14

;------------------------------------------
writeHexChar
;	writes a number on the text buf in hex
;	in: a0 = number
;	in: a1 = row to write to
;	in; a2 = col to write to
;------------------------------------------

		la		t0,TEXT_PRIM_ADDR+TEXT_PRIM_CHARS_OFFSET
		li		at,$280
		multu	at,a1
		mflo	at
		addu	t0,t0,at
		li		at,$14
		multu	at,a2
		mflo	at
		addu	t0,t0,at

		andi	a0,a0,$F
		addiu	t2,a0,48
		slti	at,a0,$A
		xori	at,at,$01
		addu	t2,t2,at
		sll		at,at,$01
		addu	t2,t2,at
		sll		at,at,$01
		addu	t2,t2,at		;t2 now has ascii val to write

		andi	t1,t2,$1F
		sll		t1,t1,$03
		srl		t2,t2,$05
		sll		t2,t2,$0B
		or		t2,t2,t1
		sh		t2,$000C(t0)
		
		jr		ra
		nop

;------------------------------------------
writeChar
;	writes a char on the text buf
;	in: a0 = char
;	in: a1 = row to write to
;	in; a2 = col to write to
;------------------------------------------

		la		t0,TEXT_PRIM_ADDR+TEXT_PRIM_CHARS_OFFSET
		li		at,$280
		multu	at,a1
		mflo	at
		addu	t0,t0,at
		li		at,$14
		multu	at,a2
		mflo	at
		addu	t0,t0,at

		addu	t2,a0,zero		;t2 now has ascii val to write

		andi	t1,t2,$1F
		sll		t1,t1,$03
		srl		t2,t2,$05
		sll		t2,t2,$0B
		or		t2,t2,t1
		sh		t2,$000C(t0)
		
		jr		ra
		nop

;------------------------------------------
doMenu
;	processes keys and calls menu functions
;	in: a0 = pointer to menu def
;------------------------------------------

		subiu	sp,sp,$20
		sw		ra,$0010(sp)
		sw		s0,$0014(sp)
		sw		s1,$0018(sp)
		sw		s2,$001C(sp)

		or		s0,a0,zero		;s0 = pointer to menu definition

doMenuWaitClear
		lhu		t0,pad_buf+2
		nop
		xori	t0,t0,$FFFF
		bnez	t0,doMenuWaitClear
		nop

doMenuProcess
		jal		VSync
		nop

		lhu		t0,pad_buf+2
		li		s1,$01				;which button you're testing
		li		s2,$00				;offset in menu def struct
		lhu		t1,oldkeys
		sh		t0,oldkeys
		xori	t0,t0,$FFFF			;t0 has a 1 for each key that's DOWN
		and		t1,t1,t0			;t1 has a 1 for each key PRESSED
		xor		t0,t0,t1			;take PRESSED keys out of DOWN group

		la		v0,key_counters
		li		t2,$0				;counter
counterResetLoop
		srlv	at,t1,t2
		andi	at,at,$01
		beqz	at,keyNotPressed
		nop
		li		at,20
		sb		at,$0001(v0)
		j		afterKeyProcess
		sb		zero,$0000(v0)
keyNotPressed
		srlv	at,t0,t2
		andi	at,at,$01
		beqz	at,afterKeyProcess
		nop
		lbu		at,$0000(v0)
		lbu		v1,$0001(v0)
		addiu	at,at,$01
		sb		at,$0000(v0)
		bne		at,v1,afterKeyProcess
		nop
		li		at,$01
		sllv	at,at,t2
		xor		t0,t0,at
		or		t1,t1,at
		sb		zero,$0000(v0)
		li		at,2
		sb		at,$0001(v0)
afterKeyProcess
		addiu	t2,t2,$01
		andi	at,t2,$F
		bnez	at,counterResetLoop
		addiu	v0,v0,$01

doMenuKeyLoop
		addu	at,s0,s2
		lw		v0,$0000(at)
		nop
		beqz	v0,doMenuProcess
		and		at,v0,t1
		beqz	at,doMenuKeyLoop
		addiu	s2,s2,$08

		srl		v0,v0,$10
		bne		v0,t0,doMenuKeyLoop
		nop

		addu	v0,s0,s2
		lw		v0,$FFFC(v0)
		nop
		jalr	v0
		nop
		beqz	v0,doMenuProcess
		nop

		lw		ra,$0010(sp)
		lw		s0,$0014(sp)
		lw		s1,$0018(sp)
		lw		s2,$001C(sp)
		jr		ra
		addiu	sp,sp,$20

		
;------------------------------------------
romMenu
;	menu system for selecting game to play
;	game (+sram) is loaded when done
;------------------------------------------

		subiu	sp,sp,$14
		sw		ra,$0010(sp)

		jal		readGameList	;returns max page
		nop
		sh		v0,maxpage

		lhu		s1,gamenum
		li		at,19
		divu	s1,at
		mflo	s1				;s1 = current page index
		sh		s1,curpage

		lw		a0,copyrightStartTime
		nop
		beqz	a0,romMenuNoWait
		nop

		xori	a0,a0,$8000
romMenuCopyWait
		lw		at,vSyncCount
		addiu	v0,a0,COPYRIGHT_TIME
		slt		at,at,v0
		bnez	at,romMenuCopyWait
		nop
		sw		zero,copyrightStartTime

		lhu		a0,maxgamenum
		la		ra,endRomMenu
		beqz	a0,romSelect_start
		nop

romMenuNoWait

		jal		initRomScreen
		nop

		la		a0,menu_RomSelect
		jal		doMenu
		nop
		
endRomMenu
		lw		ra,$0010(sp)
		nop
		jr		ra
		addiu	sp,sp,$14

romSelect_tri
		subiu	sp,sp,$14
		sw		ra,$0010(sp)

		sb		zero,optionsSelPos

		jal		initOptionsScreen
		nop

		la		a0,menu_Options
		jal		doMenu
		nop

		jal		initRomScreen
		nop

		lw		ra,$0010(sp)
		li		v0,$0
		jr		ra
		addiu	sp,sp,$14

updateOptionsMenuDisplay
		subiu	sp,sp,$14
		sw		ra,$0010(sp)

		lbu		a2,optionsSelPos
		nop
		sll		at,a2,$02
		sll		a1,a2,$04
		addu	a1,a1,at
		li		at,TOTAL_NUM_OPTIONS
		subiu	at,at,$01
		sltu	at,a2,at
		bnez	at,optionsNotOnLast
		nop
		li		a1,160
optionsNotOnLast
		sll		a1,a1,$10
		li		a0,TEXT_PRIM_ADDR+$24
		li		at,$00140000
		addu	a1,a1,at
		sw		a1,$0004(a0)
		ori		a1,a1,$100
		sw		a1,$000C(a0)
		lui		at,$000A
		addu	a1,a1,at
		sw		a1,$001C(a0)
		xori	a1,a1,$100
		sw		a1,$0014(a0)
		jal		VSync
		nop
		li		a0,TEXT_PRIM_ADDR
		jal		gpuDMAlist
		nop
		jal		gpuSync
		nop
		lw		ra,$0010(sp)
		nop
		jr		ra
		addiu	sp,sp,$14

TOTAL_BASE_NUM_OPTIONS_SAVE = 2

updateSaveMenuDisplay
		subiu	sp,sp,$14
		sw		ra,$0010(sp)

		lbu		a2,saveSelPos
		nop
		sll		at,a2,$02
		sll		a1,a2,$04
		addu	a1,a1,at
		sll		a1,a1,$10
		li		a0,TEXT_PRIM_ADDR+$24
		li		at,$00500000
		addu	a1,a1,at
		sw		a1,$0004(a0)
		ori		a1,a1,$100
		sw		a1,$000C(a0)
		lui		at,$000A
		addu	a1,a1,at
		sw		a1,$001C(a0)
		xori	a1,a1,$100
		sw		a1,$0014(a0)
		jal		VSync
		nop
		li		a0,TEXT_PRIM_ADDR
		jal		gpuDMAlist
		nop
		jal		gpuSync
		nop
		lw		ra,$0010(sp)
		nop
		jr		ra
		addiu	sp,sp,$14

initOptionsScreen
		subiu	sp,sp,$14
		sw		ra,$0010(sp)

		jal		textMode
		nop

		la		a0,options1
		li		a1,2
		jal		writeStrEnc
		nop

		la		a0,options2
		li		a1,4
		jal		writeStrEnc
		nop

		la		a0,options3
		li		a1,6
		jal		writeStrEnc
		nop

		la		a0,optionsEnd
		li		a1,18
		jal		writeStrEnc
		nop
		
		jal		updateOptionsMenuDisplay
		nop

		lw		ra,$0010(sp)
		nop
		jr		ra
		addiu	sp,sp,$14

initRomScreen
		subiu	sp,sp,$14
		sw		ra,$0010(sp)

		jal		textMode
		nop

		la		a0,txtEnterCode
		li		a1,20
		jal		writeStrEnc
		nop

		jal		romMenuUpdPageSelNums
		nop

		lw		ra,$0010(sp)
		nop
		jr		ra
		addiu	sp,sp,$14

options_down
		sw		ra,saveRA
		lbu		a0,optionsSelPos
		li		a1,TOTAL_NUM_OPTIONS
		addiu	a0,a0,$01
		sltu	at,a0,a1
		bnez	at,noOptionsWrapUp
		nop
		li		a0,$0
noOptionsWrapUp
		sb		a0,optionsSelPos
		jal		updateOptionsMenuDisplay
		nop
		lw		ra,saveRA
		nop
		jr		ra
		li		v0,$0
		
options_up
		sw		ra,saveRA

		lbu		a0,optionsSelPos
		li		a1,TOTAL_NUM_OPTIONS
		subiu	a0,a0,$01
		bgez	a0,noOptionsWrapDown
		nop
		li		a0,TOTAL_NUM_OPTIONS-1
noOptionsWrapDown
		sb		a0,optionsSelPos
		jal		updateOptionsMenuDisplay
		nop
		lw		ra,saveRA
		nop
		jr		ra
		li		v0,$0

save_up
		sw		ra,saveRA

		lbu		a0,saveSelPos
		lbu		t8,SRAMloaded
		li		a1,TOTAL_BASE_NUM_OPTIONS_SAVE
		addu	a1,a1,t8
		subiu	a0,a0,$01
		bgez	a0,noSaveWrapDown
		nop
		subiu	a0,a1,$01
noSaveWrapDown
		sb		a0,saveSelPos
		jal		updateSaveMenuDisplay
		nop
		lw		ra,saveRA
		nop
		jr		ra
		li		v0,$0

save_down
		sw		ra,saveRA

		lbu		a0,saveSelPos
		lbu		t8,SRAMloaded
		li		a1,TOTAL_BASE_NUM_OPTIONS_SAVE
		addu	a1,a1,t8
		subiu	at,a1,$01
		bne		a0,at,noSaveWrapUp
		addiu	a0,a0,$01
		li		a0,$0
noSaveWrapUp
		sb		a0,saveSelPos
		jal		updateSaveMenuDisplay
		nop
		lw		ra,saveRA
		nop
		jr		ra
		li		v0,$0

options_start
		lbu		a1,optionsSelPos
		la		a0,optionsJumpTable
		sll		a1,a1,$02
		addu	a0,a0,a1
		lw		a0,$0000(a0)
		nop
		jr		a0
		nop

optionGameGenie
		subiu	sp,sp,$14
		sw		ra,$0010(sp)

		jal		textMode
		nop

		la		a0,GGline1
		li		a1,3
		jal		writeStrEnc
		nop

		la		a0,GGline2
		li		a1,6
		jal		writeStrEnc
		nop

		li		a3,0
ggShowExistingCodesLoop
		la		at,GGcode1
		addu	at,at,a3
		lb		t8,$0000(at)
		la		at,GGchars
		bltz	t8,ggShowBlank
		li		a0,95
		addu	a0,t8,at
		lbu		a0,$0000(a0)
ggShowBlank
		li		a1,13
		srl		at,a3,$03
		sll		at,at,$01
		addu	a1,a1,at
		andi	at,a3,$7
		sll		at,at,$01
		li		a2,8
		jal		writeChar
		addu	a2,a2,at

		addiu	a3,a3,$01
		subiu	at,a3,24
		bltz	at,ggShowExistingCodesLoop
		nop

doneShowingExisting

		sb		zero,GGselPos
		jal		updateGGscreen
		nop

		la		a0,menu_GameGenie
		jal		doMenu
		nop

		jal		initOptionsScreen
		nop

		lw		ra,$0010(sp)
		li		v0,$0
		jr		ra
		addiu	sp,sp,$14

gg_up
		subiu	sp,sp,$14
		sw		ra,$0010(sp)

		lbu		v0,GGselPos
		nop
		andi	v0,v0,$07
		sb		v0,GGselPos
		jal		updateGGscreen
		nop
		
		lw		ra,$0010(sp)
		li		v0,$0
		jr		ra
		addiu	sp,sp,$14

gg_down
		subiu	sp,sp,$14
		sw		ra,$0010(sp)

		lbu		v0,GGselPos
		nop
		ori		v0,v0,$10
		sb		v0,GGselPos
		jal		updateGGscreen
		nop
		
		lw		ra,$0010(sp)
		li		v0,$0
		jr		ra
		addiu	sp,sp,$14

gg_left
		subiu	sp,sp,$14
		sw		ra,$0010(sp)

		lbu		v0,GGselPos
		nop
		andi	v1,v0,$10
		subiu	v0,v0,$01
		andi	v0,v0,$07
		or		v0,v0,v1
		sb		v0,GGselPos
		jal		updateGGscreen
		nop
		
		lw		ra,$0010(sp)
		li		v0,$0
		jr		ra
		addiu	sp,sp,$14

gg_right
		subiu	sp,sp,$14
		sw		ra,$0010(sp)

		lbu		v0,GGselPos
		nop
		addiu	v0,v0,$01
		andi	v0,v0,$17
		sb		v0,GGselPos
		jal		updateGGscreen
		nop
		
		lw		ra,$0010(sp)
		li		v0,$0
		jr		ra
		addiu	sp,sp,$14

gg_start
		li		t8,$3			;code counter
		la		a0,GGcode1
		la		a3,GGdecoded

ggCodeDecodeLoop
		lbu		at,$0002(a0)
		nop
		andi	at,at,$8
		bnez	at,codeIs8
		nop
		
		lb		v0,$0000(a0)
		li		a1,$0				;will be addr
		bltz	v0,invalidGGcode
		andi	v1,v0,$7			;will be value
		andi	at,v0,$8
		sll		at,at,$04
		lb		v0,$0001(a0)
		or		v1,v1,at
		bltz	v0,invalidGGcode
		andi	at,v0,$7
		sll		at,at,$04
		or		v1,v1,at
		andi	at,v0,$8
		sll		at,at,$04
		lb		v0,$0002(a0)
		or		a1,a1,at
		bltz	v0,invalidGGcode
		andi	at,v0,$8
		sll		at,at,$0C
		or		a1,a1,at
		andi	at,v0,$7
		sll		at,at,$04
		lb		v0,$0003(a0)
		or		a1,a1,at
		bltz	v0,invalidGGcode
		andi	at,v0,$7
		sll		at,at,$C
		or		a1,a1,at
		andi	at,v0,$8
		lb		v0,$0004(a0)
		or		a1,a1,at
		bltz	v0,invalidGGcode
		andi	at,v0,$7
		or		a1,a1,at
		andi	at,v0,$8
		sll		at,at,$08
		lb		v0,$0005(a0)
		or		a1,a1,at
		bltz	v0,invalidGGcode
		andi	at,v0,$7
		sll		at,at,$08
		or		a1,a1,at
		andi	at,v0,$8
		j		ggCodeDecodeSuccess
		or		v1,v1,at

codeIs8

		lb		v0,$0000(a0)
		li		a1,$0				;will be addr
		bltz	v0,invalidGGcode
		andi	v1,v0,$7			;will be value
		andi	at,v0,$8
		sll		at,at,$04
		lb		v0,$0001(a0)
		or		v1,v1,at
		bltz	v0,invalidGGcode
		andi	at,v0,$7
		sll		at,at,$04
		or		v1,v1,at
		andi	at,v0,$8
		sll		at,at,$04
		lb		v0,$0002(a0)
		or		a1,a1,at
		bltz	v0,invalidGGcode
		andi	at,v0,$8
		sll		at,at,$0C
		or		a1,a1,at
		andi	at,v0,$7
		sll		at,at,$04
		lb		v0,$0003(a0)
		or		a1,a1,at
		bltz	v0,invalidGGcode
		andi	at,v0,$7
		sll		at,at,$C
		or		a1,a1,at
		andi	at,v0,$8
		lb		v0,$0004(a0)
		or		a1,a1,at
		bltz	v0,invalidGGcode
		andi	at,v0,$7
		or		a1,a1,at
		andi	at,v0,$8
		sll		at,at,$08
		lb		v0,$0005(a0)
		or		a1,a1,at
		bltz	v0,invalidGGcode
		andi	at,v0,$7
		sll		at,at,$08
		or		a1,a1,at
		andi	a2,v0,$8				;will be compare value
		lb		v0,$0006(a0)
		nop
		bltz	v0,invalidGGcode
		andi	at,v0,$7
		or		a2,a2,at
		andi	at,v0,$8
		sll		at,at,$04
		lb		v0,$0007(a0)
		or		a2,a2,at
		bltz	v0,invalidGGcode
		andi	at,v0,$7
		sll		at,at,$04
		or		a2,a2,at
		andi	at,v0,$8
		or		v1,v1,at

ggCodeDecodeSuccess
		sll		a2,a2,$08
		or		v1,v1,a2
		sh		a1,$0000(a3)
		sh		v1,$0006(a3)

		addiu	a0,a0,$08
		addiu	a3,a3,$02
		subiu	t8,t8,$01
		bnez	t8,ggCodeDecodeLoop
		nop

		jr		ra
		li		v0,$01

invalidGGcode
		li		v1,$FFFF
		sh		v1,$0000(a3)
		jr		ra
		li		v0,$01

gg_addLetter
		subiu	sp,sp,$14
		sw		ra,$0010(sp)

		lbu		v0,GGselPos
		lbu		v1,GGentryPos
		nop
		subiu	at,v1,24
		bgez	at,ggNoAdd
		nop
		andi	at,v0,$10
		srl		at,at,$01
		or		v0,v0,at
		andi	v0,v0,$F
		andi	at,v0,$01
		srl		v0,v0,$01
		sll		at,at,$03
		or		v0,v0,at
		la		a0,GGcode1
		addu	a0,a0,v1
		sb		v0,$0000(a0)

		addiu	a0,v1,$01
		sb		a0,GGentryPos

		andi	at,v1,$7
		subiu	at,at,$05
		bnez	at,notSmallLimitChar
		nop

		la		a0,GGcode1
		subiu	at,v1,$03
		addu	a0,a0,at
		lbu		a0,$0000(a0)
		nop
		andi	at,a0,$08
		xori	at,at,$08
		srl		at,at,$02
		addu	a0,v1,at
		addiu	a0,a0,$01
		sb		a0,GGentryPos

notSmallLimitChar
		la		a0,GGchars
		addu	a0,a0,v0
		lbu		a0,$0000(a0)
		li		a1,13
		srl		at,v1,$03
		sll		at,at,$01
		addu	a1,a1,at
		andi	at,v1,$7
		sll		at,at,$01
		li		a2,8
		jal		writeChar
		addu	a2,a2,at
		
		jal		updateGGscreen
		nop
ggNoAdd
		lw		ra,$0010(sp)
		li		v0,$0
		jr		ra
		addiu	sp,sp,$14

gg_delLetter
		subiu	sp,sp,$14
		sw		ra,$0010(sp)

		lbu		v1,GGentryPos
		nop
		beqz	v1,ggNoDel
		nop
		subiu	v1,v1,$01
		sb		v1,GGentryPos

		andi	at,v1,$7
		subiu	at,at,$07
		bnez	at,noBigLimitChar
		nop

		la		a0,GGcode1
		subiu	at,v1,$05
		addu	a0,a0,at
		lbu		a0,$0000(a0)
		nop
		andi	at,a0,$08
		xori	at,at,$08
		srl		at,at,$02
		subu	v1,v1,at
		sb		v1,GGentryPos

noBigLimitChar
		la		a0,GGcode1
		addu	a0,a0,v1
		li		v0,$FF
		sb		v0,$0000(a0)

		li		a0,95
		li		a1,13
		srl		at,v1,$03
		sll		at,at,$01
		addu	a1,a1,at
		andi	at,v1,$7
		sll		at,at,$01
		li		a2,8
		jal		writeChar
		addu	a2,a2,at
		
		jal		updateGGscreen
		nop
ggNoDel
		lw		ra,$0010(sp)
		li		v0,$0
		jr		ra
		addiu	sp,sp,$14

updateGGscreen
		subiu	sp,sp,$14
		sw		ra,$0010(sp)

		lbu		v0,GGselPos
		li		a0,TEXT_PRIM_ADDR+$24
		andi	at,v0,$07
		sll		at,at,$04
		srl		a1,at,$01
		addu	a1,a1,at
		addiu	a1,a1,$25
		andi	v0,v0,$10
		sll		at,v0,$01
		srl		v0,v0,$03
		subu	v0,at,v0
		addiu	v0,v0,$1B
		sll		v0,v0,$10
		or		a1,a1,v0
		sw		a1,$0004(a0)
		addiu	a1,a1,$0D
		sw		a1,$000C(a0)
		lui		at,$000F
		addu	a1,a1,at
		sw		a1,$001C(a0)
		subiu	a1,a1,$0D
		sw		a1,$0014(a0)

		jal		VSync
		nop
		li		a0,TEXT_PRIM_ADDR
		jal		gpuDMAlist
		nop
		jal		gpuSync
		nop

		lw		ra,$0010(sp)
		nop
		jr		ra
		addiu	sp,sp,$14

optionScreenAdjust
		subiu	sp,sp,$14
		sw		ra,$0010(sp)

		jal		textMode
		nop

		la		a0,screenPosMsg1
		li		a1,6
		jal		writeStrEnc
		nop

		la		a0,screenPosMsg2
		li		a1,18
		jal		writeStrEnc
		nop

		jal		VSync
		nop
		li		a0,TEXT_PRIM_ADDR
		jal		gpuDMAlist
		nop
		jal		gpuSync
		nop

		la		a0,menu_ScreenPos
		jal		doMenu
		nop

		jal		initOptionsScreen
		nop

		lw		ra,$0010(sp)
		li		v0,$0
		jr		ra
		addiu	sp,sp,$14

optionButtonConfig
		subiu	sp,sp,$18
		sw		ra,$0010(sp)
		sw		s0,$0014(sp)

		jal		textMode
		nop

		li		s0,$0			;counter

btnCfgLoop
		la		a0,btnCfgA
		sll		at,s0,$5
		addu	a0,a0,at
		addu	a0,a0,s0
		li		a1,5
		addu	a1,a1,s0
		jal		writeStrEnc
		nop
		jal		VSync
		nop
		li		a0,TEXT_PRIM_ADDR
		jal		gpuDMAlist
		nop
		jal		gpuSync
		nop

btnCfgWaitNoButsDown
		lhu		a0,pad_buf+2
		nop
		xori	a0,a0,$FFFF
		bnez	a0,btnCfgWaitNoButsDown
		nop

btnCfgWaitForPress
		lhu		a0,pad_buf+2
		nop
		xori	a0,a0,$FFFF
		beqz	a0,btnCfgWaitForPress
		nop

		la		a1,padMasks
		sll		at,s0,$01
		addu	a1,a1,at
		sh		a0,$0000(a1)

		addiu	s0,s0,$01
		slti	at,s0,$0A
		bnez	at,btnCfgLoop
		nop

		jal		initOptionsScreen
		nop

		li		v0,$0
		lw		ra,$0010(sp)
		lw		s0,$0014(sp)
		jr		ra
		addiu	sp,sp,$18

optionReturn
		jr		ra
		li		v0,$1

romMenuUpdPageSelNums
		sw		ra,saveRA

		lh		t8,gamenum
		lhu		t9,maxgamenum
		nop
		subu	v0,t9,t8
		bgez	v0,gameNumNotTooBig
		nop
		li		t8,$0
gameNumNotTooBig
		bgez	t8,gameNumNotTooSmall
		nop
		or		t8,t9,zero
gameNumNotTooSmall
		sh		t8,gamenum
		
		srl		a0,t8,$08
		li		a1,20
		jal		writeHexChar
		li		a2,5

		srl		a0,t8,$04
		li		a1,20
		jal		writeHexChar
		li		a2,6

		srl		a0,t8,$00
		li		a1,20
		jal		writeHexChar
		li		a2,7

		li		at,19
		divu	t8,at
		mfhi	v0

		sll		v0,v0,$01
		sll		at,v0,$02
		addu	v0,v0,at		;v0*=10
		sll		v0,v0,$10
		li		a0,TEXT_PRIM_ADDR+$24
		sw		v0,$0004(a0)
		ori		v0,v0,$100
		sw		v0,$000C(a0)
		lui		at,$000A
		addu	v0,v0,at
		sw		v0,$001C(a0)
		xori	v0,v0,$100
		sw		v0,$0014(a0)

		mflo	a0
		jal		showpage
		nop

		lw		ra,saveRA
		nop
		jr		ra
		li		v0,$0

screen_up
		lw		v0,gpuVrange
		li		at,$0401
		addu	v0,v0,at
		lui		at,$1f80
		sw		v0,GP1(at)
		sw		v0,gpuVrange
		jr		ra
		li		v0,$0

romSelect_up
		lhu		t8,gamenum
		nop
		subiu	t8,t8,$01
		sh		t8,gamenum
		j		romMenuUpdPageSelNums
		nop

screen_down
		lw		v0,gpuVrange
		li		at,$0401
		subu	v0,v0,at
		lui		at,$1f80
		sw		v0,GP1(at)
		sw		v0,gpuVrange
		jr		ra
		li		v0,$0

romSelect_down
		lhu		t8,gamenum
		nop
		addiu	t8,t8,$01
		sh		t8,gamenum
		j		romMenuUpdPageSelNums
		nop

screen_left
		lw		v0,gpuHrange
		li		at,$A00A
		addu	v0,v0,at
		andi	at,v0,$FFF
		subiu	at,at,$316
		beqz	at,upperLimitH
		lui		at,$1f80
		sw		v0,GP1(at)
		sw		v0,gpuHrange
upperLimitH
		jr		ra
		li		v0,$0

screen_right
		lw		v0,gpuHrange
		nop
		andi	at,v0,$FFF
		subiu	at,at,$190
		beqz	at,lowerLimitH
		nop
		li		at,$A00A
		subu	v0,v0,at
		lui		at,$1f80
		sw		v0,GP1(at)
		sw		v0,gpuHrange
lowerLimitH
		jr		ra
		li		v0,$0

screen_start
		jr		ra
		li		v0,$01

romSelect_r2
		lui		t8,$1f80
		li		v0,$08000000
        sw		v0,GP1(t8)              ; set display mode (NTSC)
		li		v0,$06C4E24E			; horz screen range NTSC
		sw		v0,GP1(t8)
		sw		v0,gpuHrange
		li		v0,$07040010			; vert screen range NTSC
		sw		v0,GP1(t8)
		sw		v0,gpuVrange
		jr		ra
		li		v0,$0

romSelect_l2
		lui		t8,$1f80
		li		v0,$08000008
        sw		v0,GP1(t8)              ; set display mode (PAL)
		li		v0,$06C62262			; horz screen range PAL
		sw		v0,GP1(t8)
		sw		v0,gpuHrange
		li		v0,$0704B42D			; vert screen range PAL
		sw		v0,GP1(t8)
		sw		v0,gpuVrange
		jr		ra
		li		v0,$0

romSelect_right
		lhu		t8,gamenum
		lhu		t9,maxgamenum
		addiu	t8,t8,19

		subu	at,t8,t9
		blez	at,noProbPageRight
		nop

		li		at,19
		addiu	a0,t9,$01
		divu	a0,at
		mfhi	at
		li		a0,19
		subu	a0,a0,at
		li		at,19
		divu	a0,at
		mfhi	a0

		subu	at,t8,t9
		subu	at,at,a0
		bgtz	at,noProbPageRight
		nop

		or		t8,t9,zero

noProbPageRight
		sh		t8,gamenum
		j		romMenuUpdPageSelNums
		nop

romSelect_left
		lhu		t8,gamenum
		nop
		subiu	t8,t8,19
		sh		t8,gamenum
		j		romMenuUpdPageSelNums
		nop

romSelect_r1
		lhu		t8,gamenum
		nop
		addiu	t8,t8,76
		sh		t8,gamenum
		j		romMenuUpdPageSelNums
		nop

romSelect_l1
		lhu		t8,gamenum
		nop
		subiu	t8,t8,76
		sh		t8,gamenum
		j		romMenuUpdPageSelNums
		nop

romSelect_midPage
		lhu		t8,maxgamenum
		nop
		srl		t8,t8,$01
		sh		t8,gamenum
		j		romMenuUpdPageSelNums
		nop

romSelect_sq
		sw		ra,saveRA

		lhu		t8,gamenum
		nop
		addiu	t8,t8,$0100
		andi	t8,t8,$0FFF
		sh		t8,gamenum
		j		romMenuUpdPageSelNums
		nop

romSelect_x
		sw		ra,saveRA

		lhu		t8,gamenum
		nop
		addiu	at,t8,$0010
		andi	at,at,$FF
		andi	t8,t8,$0F00
		or		t8,t8,at
		sh		t8,gamenum
		j		romMenuUpdPageSelNums
		nop

romSelect_o
		sw		ra,saveRA

		lhu		t8,gamenum
		nop
		addiu	at,t8,$0001
		andi	at,at,$F
		andi	t8,t8,$0FF0
		or		t8,t8,at
		sh		t8,gamenum
		j		romMenuUpdPageSelNums
		nop

romSelect_start
		subiu	sp,sp,$18
		sw		ra,$0010(sp)
		sw		s0,$0014(sp)

		lhu		a0,gamenum
		lhu		a1,maxgamenum
		nop
		addiu	a1,a1,$01
		slt		at,a0,a1
		beqz	at,badGameNum
		sll		a0,a0,$05
		la		a1,rom_img
		addu	s0,a0,a1		;s0 points to game name+info

		li		a0,buname+5
		or		a1,s0,zero
		jal		copyMem				;copy game name to memcard file name
		li		a2,20

		lw		a0,28(s0)		;get game's offset + size
		nop
		srl		a2,a0,$14
		sll		s3,s3,$0B
		sll		a0,a0,$0C
		srl		a0,a0,$0C
		lw		a1,cdfilepos_rombank
		nop
		addu	a0,a0,a1
		la		a1,rom_img
		jal		cdReadSector
		nop
			
		la		a0,buname
		li		a1,$0001		;read access
		li		t0,$b0
		jalr	t0								; open
		li		t1,$32
		or		s0,v0,zero		;save handle in s0

		sb		zero,SRAMloaded
		li		at,$FFFFFFFF
		beq		s0,at,noSRAMexist
		nop

		la		a0,saveMsg5
		li		a1,20
		jal		writeStrEnc
		nop
		jal		VSync
		nop
		li		a0,TEXT_PRIM_ADDR
		jal		gpuDMAlist
		nop
		jal		gpuSync
		nop

badRead

		or		a0,s0,zero
		li		a1,$80014000
		li		a2,$2000
		li		t0,$b0
		jalr	t0								; read
		li		t1,$34

;read returning fffffffe on bad loads	

		;or		a1,v0,zero
		;la		a0,fname
		;li		t0,$a0
		;jalr	t0
		;li		t1,$3f

		or		a0,s0,zero
		li		t0,$b0
		jalr	t0								; close
		li		t1,$36

		lw		a0,$80014000
		li		a1,$01114353
		beq		a0,a1,doHuff
		nop

		li		a0,$80016000
		li		a1,$80014000
		jal		copyMem
		li		a2,$2000

		j		skipHuff
		nop

doHuff
		li		a0,$80014100
		li		a1,$80016000
		li		a2,$2000
		jal		huffmanDecode
		nop

skipHuff
		li		t0,$01				;make sure this stays a 1
		sb		t0,SRAMloaded

noSRAMexist

		lw		ra,$0010(sp)
		lw		s0,$0014(sp)
		li		v0,$01			;v0 = 1 means menu will return
		jr		ra
		addiu	sp,sp,$18

badGameNum

		lw		ra,$0010(sp)
		lw		s0,$0014(sp)
		li		v0,$00			;v0 = 0 means menu will continue
		jr		ra
		addiu	sp,sp,$18

;------------------------
readGameList
;------------------------

		sw		ra,saveRA

		lw		a0,cdfilepos_rombank
		la		a1,rom_img
		li		a2,$40
		jal		cdReadSector			;read the header up to it's max size
		nop

		la		a0,rom_img
		li		v0,$0			;game counter
findLastGameLoop
		lbu		at,$0000(a0)
		addiu	v0,v0,$01
		addiu	at,at,$01
		andi	at,at,$FF
		bnez	at,findLastGameLoop		;loop until find terminating $FF
		addiu	a0,a0,$20

		subiu	v0,v0,$02
		sh		v0,maxgamenum
		li		at,19
		divu	v0,at
		mflo	v0						;now v0 has the largest valid page index (zero based)
		
		lw		ra,saveRA
		nop
		jr		ra
		nop

;---------------------------
showpage
;	displays a page of games
;	in: a0 has page #
;---------------------------

		subiu	sp,sp,$20
		sw		ra,$0010(sp)
		sw		s0,$0014(sp)
		sw		s1,$0018(sp)
		sw		s2,$001C(sp)

		li		at,19
		multu	at,a0
		mflo	s0				;s0 = game # you're on
		li		s1,$0			;s1 = what line you're on

showpageLoop
		srl		a0,s0,$08
		or		a1,s1,zero
		jal		writeHexChar
		li		a2,$0

		srl		a0,s0,$04
		or		a1,s1,zero
		jal		writeHexChar
		li		a2,$1

		or		a0,s0,zero
		or		a1,s1,zero
		jal		writeHexChar
		li		a2,$2

		li		s2,$0
showpageNameLoop
		sll		at,s0,$05
		addu	at,at,s2
		la		a0,rom_img
		addu	a0,a0,at
		lbu		a0,$0000(a0)
		or		a1,s1,zero
		li		at,$FF
		beq		at,a0,showpageAfterNames
		nop
		jal		writeChar
		addiu	a2,s2,$04
		addiu	s2,s2,$01
		li		at,28
		bne		at,s2,showpageNameLoop
		nop

		addiu	s1,s1,$01
		li		at,19
		bne		at,s1,showpageLoop
		addiu	s0,s0,$01

showpageAfterNames
		li		at,19
		beq		at,s1,showpageAfterBlank
		nop
		li		s2,$0
showpageBlankLoop
		li		a0,$20
		or		a1,s1,zero
		jal		writeChar
		or		a2,s2,zero
		addiu	s2,s2,$01
		li		at,32
		bne		at,s2,showpageBlankLoop
		nop
		j		showpageAfterNames
		addiu	s1,s1,$01

showpageAfterBlank	
		jal		VSync
		nop
		li		a0,TEXT_PRIM_ADDR
		jal		gpuDMAlist
		nop
		jal		gpuSync
		nop

		lw		ra,$0010(sp)
		lw		s0,$0014(sp)
		lw		s1,$0018(sp)
		lw		s2,$001C(sp)
		jr		ra
		addiu	sp,sp,$20
		
;-----------------------
getKeys	 ;returns pad info in v0
;-----------------------
		sw		ra,saveFP

		sh		zero,pad_buf+2
		nop

		li		at,$B0
		;jalr	at			;start the pad
		li		t1,$13

waitforpad
		lhu		v0,pad_buf+2
		nop
		beqz	v0,waitforpad	;wait for a reading
		nop

		sw		v0,saveA0

		li		at,$B0
		;jalr	at			;stop the pad
		li		t1,$14

		lw		v0,saveA0
		lw		ra,saveFP
		nop
		jr		ra
		nop

;-----------------------------------------
copyright
;	shows copyright notice on program boot
;-----------------------------------------

		subiu	sp,sp,$14
		sw		ra,$0010(sp)

		jal		textMode
		nop

		la		a0,copy1
		li		a1,1
		jal		writeStrEnc
		nop

		la		a0,copy2
		li		a1,2
		jal		writeStrEnc
		nop

		la		a0,copy3
		li		a1,8
		jal		writeStrEnc
		nop

		la		a0,copy4
		li		a1,15
		jal		writeStrEnc
		nop

		la		a0,copy5
		li		a1,16
		jal		writeStrEnc
		nop

		la		a0,copy6
		li		a1,18
		jal		writeStrEnc
		nop

		la		a0,copy7
		li		a1,19
		jal		writeStrEnc
		nop

		jal		VSync
		nop

		jal		gpuSync
		nop

		li		a0,TEXT_PRIM_ADDR			;put up the splash screen
		jal		gpuDMAlist
		nop

		lw		a0,vSyncCount
		nop
		ori		a0,a0,$8000
		sw		a0,copyrightStartTime		;mark when it started

		lw		ra,$0010(sp)
		nop
		jr		ra
		addiu	sp,sp,$14

;------------------------------------------------
textMode
;	sets up the GPU for text mode screens
;------------------------------------------------

	; palette for font is the first few pix of the font itself

	FONT_Y_X = $01000100

		sw		ra,saveRA

		lui		v0,$1f80

		li		at,$04000000		;set DMA off
		sw		at,GP1(v0)

		li		at,$01000000		;reset command buffer
		sw		at,GP0(v0)

		li		at,$E6000000		;send image IS sensitive to mask bits!
		sw		at,GP0(v0)

		li		at,$A0000000		;send image data command
		sw		at,GP0(v0)

		li		at,FONT_Y_X			;x,y pos of where to put font
		sw		at,GP0(v0)

		li		at,$00400040		;width and height
		sw		at,GP0(v0)

		la		a0,font
		li		a1,8192				;send font to frame buffer
		jal		gpuDMA
		nop

		jal		gpuSync
		nop

		li		at,FONT_Y_X>>6
		andi	at,at,$F
		li		a0,FONT_Y_X>>20
		andi	a0,a0,$10
		or		a0,a0,at
		lui		at,$E100
		or		a0,a0,at
		sw		a0,GP0(v0)			;set tex page

		jal		makeTextprims		;create the primitives to draw the chars on screen
		nop

		li		a0,TEXT_PRIM_ADDR		;draw the text screen once
		jal		gpuDMAlist
		nop

		jal		gpuSync
		nop

		lui		v0,$1f80
		li		at,$05000000		;display area is 0,0
		sw		at,GP1(v0)

		lw		ra,saveRA
		nop
		jr		ra
		nop

;------------------------------------------------
gpuDMA
;	uses DMA to send data to the GPU
;	in: a0 = address of data
;	in; a1 = size of data in bytes
;------------------------------------------------

		li		v0,$03			;address starts out at least divisible by 4
gpuDMAfigureSize
		srlv	at,a1,v0
		sllv	at,at,v0
		beq		at,a1,gpuDMAfigureSize
		addiu	v0,v0,$01

		subiu	v0,v0,$04
		slti	at,v0,$05
		bnez	at,gpuDMAnotTooBig
		nop
		li		v0,$04
gpuDMAnotTooBig
		li		at,$01
		sllv	at,at,v0		;at is block size to transfer
		srl		a1,a1,$02
		srlv	a1,a1,v0
		sll		a1,a1,$10
		or		a1,a1,at		;a1 has block info for DMA

		lui		v0,$1f80

		li		at,$04000002		;set DMA CPU->GPU
		sw		at,GP1(v0)

		sw		a0,$10A0(v0)		;start address of transfer

		sw		a1,$10A4(v0)		;block info

		li		at,$01000201		;start transfer
		sw		at,$10A8(v0)

		jr		ra
		nop


;------------------------------------------------
gpuDMAlist
;	starts a linked list transfer to GPU
;	in: a0 = address of list head
;------------------------------------------------

		lui		v0,$1f80

		li		at,$04000002		;set DMA CPU->GPU
		sw		at,GP1(v0)

		sw		a0,$10A0(v0)		;start address of transfer

		sw		zero,$10A4(v0)		;block info

		li		at,$01000401		;start transfer
		sw		at,$10A8(v0)

		jr		ra
		nop

;------------------------------------------------
gpuSync
;	waits for the gpu to finish dma + drawing
;------------------------------------------------

		lui		at,$1f80
		lw		at,$10a8(at)
		nop
		srl		at,at,$18			; first wait for dma to finish
		andi	at,$01
		bnez	at,gpuSync
		nop

		lui		at,$1f80
		lw		at,GP1(at)
		nop
		srl		at,at,$18			; then wait for drawing to stop
		andi	at,$04
		beqz	at,gpuSync
		nop

		jr		ra
		nop

include newdraw.asm

;------------------------------------------------
; doNMI  -  the NES's FFFA vector
;------------------------------------------------

doNMI
		or		t9,ra,zero

		subiu	t7,t7,$54		; 7 clock cycles for interupt
		
		or		at,s3,s7
		srl		t8,s4,$08
		sb		t8,$0100(at)
		subiu	s3,s3,$01
		andi	s3,s3,$FF
		or		at,s3,s7
		sb		s4,$0100(at)
		nop

		jal		makeP		;puts P into a1
		nop

		subiu	s3,s3,$01
		andi	s3,s3,$FF
		or		t8,s3,s7
		sb		a1,$0100(t8)

		lw		s4,bankptr+12
		li		t8,$FFFA
		addu	s4,s4,t8
		lhu		s4,$0000(s4)	;PC=NMI vector
		subiu	s3,s3,$01		;set S to where it should be

		jr		t9
		andi	s3,s3,$FF

;------------------------------------------------
; doIRQ  -  the NES's FFFE vector
;------------------------------------------------

doIRQ
		;bnez	t2,intsDisabled
		or		t9,ra,zero

		subiu	t7,t7,$54		; 7 clock cycles for interupt

		or		at,s3,s7
		srl		t8,s4,$08
		sb		t8,$0100(at)
		subiu	s3,s3,$01
		andi	s3,s3,$FF
		or		at,s3,s7
		sb		s4,$0100(at)
		nop

		jal		makeP		;puts P into a1
		nop

		subiu	s3,s3,$01
		andi	s3,s3,$FF
		or		t8,s3,s7
		sb		a1,$0100(t8)
		
		lw		s4,bankptr+12
		li		t8,$FFFE
		addu	s4,s4,t8
		lhu		s4,$0000(s4)	;PC=IRQ vector
		subiu	s3,s3,$01		;set S to where it should be

;intsDisabled
		jr		t9
		andi	s3,s3,$FF

;------------------------------------------------
; nesReset
;------------------------------------------------

nesReset
		li		a0,$80010000		;zero nes ram up to SRAM
		li		a1,$6000
		jal		fillMem
		li		a2,$00

		li		a0,$80018000		;zero PRG ROM space
		li		a1,$8000
		jal		fillMem
		li		a2,$00

		li		a0,$80020000		;zero PPU pat + name + att space
		li		a1,$2800
		li		a2,$D9D9D9D9
		jal		fillMem
		nop

		li		a0,$80022800		;set up something about blocks space
		li		a1,$1800
		li		a2,$07060504
		jal		fillMem
		nop

		li		a0,$80023F00		;make old palette vals invalide to force update
		li		a1,$20
		li		a2,$23232323
		jal		fillMem
		nop

		li		a0,sprRAM			;init sprite ram
		li		a1,$100
		li		a2,$F4
		jal		fillMem
		nop

		li		s0,0	;A=0
		li		s1,0	;X=0
		li		s2,0	;Y=0
		li		s3,$FF	;S=0x0FF

		ori		t0,zero,$00		;Carry
		ori		t1,zero,$01		;Zero
		ori		t2,zero,$00		;Interupt disable
		ori		t3,zero,$00		;Decimal
		ori		t4,zero,$00		;Break
		ori		t5,zero,$00		;oVerflow
		ori		t6,zero,$00		;Negetive

		lui		s7,$8001
		lw		s4,bankptr+12
		nop
		li		t9,$FFFC
		addu	s4,s4,t9
		lhu		s4,$0000(s4)	;PC=reset vector
		nop

		srl		t9,s4,$0D
		or		t3,t9,zero
		andi	t9,t9,$03
		sll		t9,t9,$02
		la		fp,bankptr
		addu	fp,fp,t9
		lw		fp,$0000(fp)

		addiu	s5,zero,$01
		addiu	s6,zero,$02

		sb		s5,$1804(s7)	;set up vram addr inc amount

		li		a3,$03020100
		sw		a3,BLOCKS(s7)
		li		a3,$07060504
		sw		a3,BLOCKS+4(s7)
		
		addiu	sp,zero,$0008

		li		t7,$0553			;cause the first scanline to be triggered immediatly
		li		t8,0
		sw		t8,scanLine		;start on line 0
		nop

		sw		zero,$2000(s7)	;reset some RAM
		nop
		sw		zero,$2004(s7)
		nop

		li		t8,$FF
		sb		t8,$4017(s7)		;disable frame IRQs

		li		t8,$80010000
		li		t9,bankptrlo
		sw		t8,$00(t9)
		sw		t8,$04(t9)
		sw		t8,$08(t9)
		sw		t8,$0C(t9)

		la		t8,scan0_reset
		sw		t8,nextScanJump

		sb		zero,SRAMchanged(s7)		;SRAM hasn't changed

		sw		zero,scanLine
		la		t8,scan0_reset
		sw		t8,nextScanJump

		sb		zero,buffNext_incAmt

		j		afterReset
		nop

;------------------------------------------------
; loadROM
;------------------------------------------------

loadROM
		la		fp, rom_img

		la		t8,realSpriteSetup	; make this the default sprite handler
		sw		t8,sprFunc

		li		t8,$01
		sb		t8,buffNext_incAmt+1	; make 1 the default inc amount

		sw		zero,mapHsyncFunc		; make no default hsync call
		
		lbu		t8, $0004(fp)		; read in number of 16k ($4000) PRG-ROM banks
		nop
		sb		t8, prgCount
		sll		t9,t8,$01
		subiu	t9,t9,$01
		sb		t9,prgMask			; set program mask for 8k banks

		la		at,rom_img+16
		sll		t8,t8,$0E			; set vrom start address
		addu	t9,at,t8
		sw		t9,vromaddr

		lbu		t8, $0005(fp)		; number of 8k ($2000) CHR-ROM banks
		nop
		sb		t8, chrCount

		sll		t9,t8,$03
		subiu	t9,t9,$01
		sb		t9,chrMask			;set chr bank mask

		sltiu	t9,t8,$01
		xori	t9,t9,$01
		sll		t9,t9,$1F
		sra		t9,t9,$02
		srl		t9,t9,$1A
		sb		t9,blockMask

		lhu		t8,$0006(fp)		; flags and mapper# word
		nop
		andi	at,t8,$0001			; mirroring bit
		li		t9,$04
		srlv	t9,t9,at
		ori		t9,t9,$08
		sb		t9,mirrorSel
	
		andi	t9,t8,$00F0
		srl		t9,t9,$04
		andi	at,t8,$0F00
		bne		at,zero,badUpper
		nop
		andi	at,t8,$F000
		srl		at,at,$08
		or		t9,t9,at		; get mapper #
badUpper
		bne		t9,zero,notMap00
		nop

;-------------
;MAPPER 0 init
;-------------

		li		a0,$4
		jal		bankSwitch
		li		a1,$0
		jal		bankSwitch
		nop
		li		a0,$6
		jal		bankSwitch
		li		a1,$FE
		jal		bankSwitch
		nop

		li		a0,$00
		li		a1,$00
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
		
		la		a0,map0write
		sw		a0,write80map
		sw		a0,write90map
		sw		a0,writeA0map
		sw		a0,writeB0map
		sw		a0,writeC0map
		sw		a0,writeD0map
		sw		a0,writeE0map
		sw		a0,writeF0map

		j		mapperDone
		nop

notMap00
		li		at,$01
		bne		t9,at,notMap01
		nop

;-------------
;MAPPER 1 init
;-------------

		li		a0,$4
		jal		bankSwitch
		li		a1,$0
		jal		bankSwitch
		nop
		li		a0,$6
		jal		bankSwitch
		li		a1,$FE
		jal		bankSwitch
		nop

		lbu		a0,chrCount
		nop
		beqz	a0,noChrMap1
		nop

		li		a0,$00
		li		a1,$00
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

		li		a0,$01
		sb		a0,mapReg2

noChrMap1

		li		a0,$0C
		sb		a0,mapReg0

		la		a0,map1write
		sw		a0,write80map
		sw		a0,write90map
		sw		a0,writeA0map
		sw		a0,writeB0map
		sw		a0,writeC0map
		sw		a0,writeD0map
		sw		a0,writeE0map
		sw		a0,writeF0map

		j		mapperDone
		nop

notMap01
		li		at,$02
		bne		t9,at,notMap02
		nop

;-------------
;MAPPER 2 init
;-------------

		li		a0,$4
		jal		bankSwitch
		li		a1,$0
		jal		bankSwitch
		nop
		li		a0,$6
		jal		bankSwitch
		li		a1,$FE
		jal		bankSwitch
		nop

		la		a0,map2write
		sw		a0,write80map
		sw		a0,writeA0map
		sw		a0,writeC0map
		sw		a0,writeE0map
		sw		a0,write90map
		sw		a0,writeB0map
		sw		a0,writeD0map
		sw		a0,writeF0map

		j		mapperDone
		nop

notMap02
		li		at,$03
		bne		t9,at,notMap03
		nop

;-------------
;MAPPER 3 init
;-------------

		li		a0,$4
		jal		bankSwitch
		li		a1,$0
		jal		bankSwitch
		nop
		li		a0,$6
		jal		bankSwitch
		li		a1,$FE
		jal		bankSwitch
		nop

		li		a0,$00
		li		a1,$00
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

		la		a0,map3write
		sw		a0,write80map
		sw		a0,writeA0map
		sw		a0,writeC0map
		sw		a0,writeE0map
		sw		a0,write90map
		sw		a0,writeB0map
		sw		a0,writeD0map
		sw		a0,writeF0map

		j		mapperDone
		nop

notMap03
		li		at,$04
		bne		t9,at,notMap04
		nop

;-------------
;MAPPER 4 init
;-------------

		li		a0,$4
		jal		bankSwitch			;first 16k
		li		a1,$0
		jal		bankSwitch
		nop
		li		a0,$6
		jal		bankSwitch			;last 16k
		li		a1,$FE
		jal		bankSwitch
		nop

		lbu		t8,chrCount
		nop
		beqz	t8,noVROMmap4
		nop

		li		a0,$00
		li		a1,$00
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

noVROMmap4

		la		a0,map4write8
		sw		a0,write80map
		sw		a0,write90map
		la		a0,map4writeA
		sw		a0,writeA0map
		sw		a0,writeB0map
		la		a0,map4writeC
		sw		a0,writeC0map
		sw		a0,writeD0map
		la		a0,map4writeE
		sw		a0,writeE0map
		sw		a0,writeF0map

		sb		zero,mapReg0		;needs to be set up this way, not $0C

		j		mapperDone
		nop

notMap04
		li		at,$05
		bne		t9,at,notMap05
		nop

;-------------
;MAPPER 5 init
;-------------

		;li		a0,$4
		;jal		bankSwitch			; all banks start on last 8k
		;li		a1,$FF
		;jal		bankSwitch
		;li		a1,$FF
		;jal		bankSwitch
		;li		a1,$FF
		;jal		bankSwitch
		;li		a1,$FF
		
		;li		a0,$00
		;li		a1,$00
		;jal		bufLoadVROM
		;nop
		;jal		bufLoadVROM		;pattern 0
		;nop
		;jal		bufLoadVROM
		;nop
		;jal		bufLoadVROM
		;nop

		;jal		bufLoadVROM
		;nop
		;jal		bufLoadVROM		;pattern 1
		;nop
		;jal		bufLoadVROM
		;nop
		;jal		bufLoadVROM
		;nop

		;la		a0,map5write50
		;sw		a0,write50map
		;la		a0,map5write51
		;sw		a0,write51map
		;la		a0,map5write52
		;sw		a0,write52map

		j		mapperDone
		nop

notMap05
		li		at,$07
		bne		t9,at,notMap07
		nop

;-------------
;MAPPER 7 init
;-------------

		li		a0,$4
		jal		bankSwitch
		li		a1,$0
		jal		bankSwitch
		nop
		jal		bankSwitch
		nop
		jal		bankSwitch
		nop

		la		a0,map7write
		sw		a0,write80map
		sw		a0,writeA0map
		sw		a0,writeC0map
		sw		a0,writeE0map
		sw		a0,write90map
		sw		a0,writeB0map
		sw		a0,writeD0map
		sw		a0,writeF0map

		j		mapperDone
		nop

notMap07
		li		at,9
		bne		t9,at,notMap9
		nop

;-------------
;MAPPER 9 init
;-------------

		li		a0,$4
		jal		bankSwitch			;first 8k
		li		a1,$0

		li		a0,$5
		jal		bankSwitch
		li		a1,$FD
		jal		bankSwitch			;last 24k
		nop
		jal		bankSwitch
		nop

		la		a0,map0write
		sw		a0,write80map
		sw		a0,write90map
		la		a0,map9writeA
		sw		a0,writeA0map
		la		a0,map9writeB
		sw		a0,writeB0map
		la		a0,map9writeC
		sw		a0,writeC0map
		la		a0,map9writeD
		sw		a0,writeD0map
		la		a0,map9writeE
		sw		a0,writeE0map
		la		a0,map9writeF
		sw		a0,writeF0map

		la		t8,map9SpriteSetup		; use custom sprite handler
		sw		t8,sprFunc

		la		t8,PPUWriteNameMap9
		sw		t8,PPUWrite+8

		li		t8,$04
		sb		t8,buffNext_incAmt+1	; make 4 the inc amount when searching for a VROM slot

		li		t8,$AB
		sb		t8,mapReg0
		sb		t8,mapReg1
		sb		t8,mapReg2
		sb		t8,mapReg3

		
		lbu		t8,rom_img+$1A9B0
		nop
		subiu	t8,t8,$A5
		beqz	t8,mtversion
		nop

;regular punchout
		li		t8,$0C
		li		t9,rom_img+$1A97F
		sb		t8,$0000(t9)
		j		afterTotalHack
		nop

mtversion
		li		t8,$0C
		li		t9,rom_img+$1A9B0
		sb		t8,$0000(t9)

		li		t8,$FD
		li		t9,rom_img+$12204
		sb		t8,$0000(t9)

afterTotalHack

		li		t8,$FEFEFEFE	; set this up so it will
		li		a0,$80022000	; draw the screen right
		li		a1,$3C0
punchoutLoopbegin
		sw		t8,$0000(a0)
		sw		t8,$0400(a0)
		subiu	a1,a1,$04
		bnez	a1,punchoutLoopbegin
		addiu	a0,a0,$04

		j		mapperDone
		nop

notMap9
		li		at,11
		bne		t9,at,notMap11
		nop

;--------------
;MAPPER 11 init
;--------------

		li		a0,$4
		jal		bankSwitch			;first 32k
		li		a1,$0
		jal		bankSwitch
		nop
		jal		bankSwitch
		nop
		jal		bankSwitch
		nop
		
		li		a0,$00
		li		a1,$00
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

		la		a0,map11write
		sw		a0,write80map
		sw		a0,writeA0map
		sw		a0,writeC0map
		sw		a0,writeE0map
		sw		a0,write90map
		sw		a0,writeB0map
		sw		a0,writeD0map
		sw		a0,writeF0map
		
		j		mapperDone
		nop

notMap11
		li		at,34
		bne		t9,at,notMap34
		nop

;--------------
;MAPPER 34 init (Deadly Towers)
;--------------

		li		a0,$4
		jal		bankSwitch
		li		a1,$0
		jal		bankSwitch
		nop
		li		a0,$6
		jal		bankSwitch
		li		a1,$FE
		jal		bankSwitch
		nop

		lbu		t8,chrCount
		nop
		beqz	t8,noVROMmap34
		nop

		li		a0,$00
		li		a1,$00
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

noVROMmap34

		la		a0,map34write
		sw		a0,write80map
		sw		a0,write90map
		sw		a0,writeA0map
		sw		a0,writeB0map
		sw		a0,writeC0map
		sw		a0,writeD0map
		sw		a0,writeE0map
		sw		a0,writeF0map

		j		mapperDone
		nop

notMap34
		li		at,66
		bne		t9,at,notMap66
		nop

;--------------
;MAPPER 66 init (SMB+duckhunt)
;--------------

		li		a0,$4
		jal		bankSwitch			;first 32k
		li		a1,$0
		jal		bankSwitch
		nop
		jal		bankSwitch
		nop
		jal		bankSwitch
		nop
		
		li		a0,$00
		li		a1,$00
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

		la		a0,map66write
		sw		a0,write80map
		sw		a0,writeA0map
		sw		a0,writeC0map
		sw		a0,writeE0map
		sw		a0,write90map
		sw		a0,writeB0map
		sw		a0,writeD0map
		sw		a0,writeF0map

		j		mapperDone
		nop

notMap66
		li		at,69
		bne		t9,at,notMap69
		nop

;--------------
;MAPPER 69 init
;--------------

		;li		a0,$4
		;jal		bankSwitch
		;li		a1,$0
		;jal		bankSwitch
		;nop
		;li		a0,$6
		;jal		bankSwitch
		;li		a1,$FE
		;jal		bankSwitch
		;nop

		;lbu		t8,chrCount
		;nop
		;beqz	t8,noVROMmap69
		;nop

		;li		a0,$00
		;li		a1,$00
		;jal		bufLoadVROM
		;nop
		;jal		bufLoadVROM		;pattern 0
		;nop
		;jal		bufLoadVROM
		;nop
		;jal		bufLoadVROM
		;nop

		;jal		bufLoadVROM
		;nop
		;jal		bufLoadVROM		;pattern 1
		;nop
		;jal		bufLoadVROM
		;nop
		;jal		bufLoadVROM
		;nop

noVROMmap69

		;la		a0,map69write8
		;sw		a0,write80map
		;la		a0,map69writeA
		;sw		a0,writeA0map

		j		mapperDone
		nop

notMap69
		li		at,71
		bne		t9,at,notMap71
		nop

;--------------
;MAPPER 71 init (Dizzy)
;--------------

		li		a0,$4
		jal		bankSwitch
		li		a1,$0
		jal		bankSwitch
		nop
		li		a0,$6
		jal		bankSwitch
		li		a1,$FE
		jal		bankSwitch
		nop

		la		a0,map71write9
		sw		a0,write90map
		la		a0,map71writeC
		sw		a0,writeC0map
		sw		a0,writeD0map
		sw		a0,writeE0map
		sw		a0,writeF0map

		j		mapperDone
		nop

notMap71
mapperDone

		j		afterLoad
		nop


;----------------------------------------------------
; transPat
; in: at=addr in VRAM to take from (multiple of $80)
;----------------------------------------------------
transPat
		la		sp,patTmp		; fp = dest of decoded data

		li		a2,$44444444	; att data to OR in

		li		s5,$0		;tile counter
		li		v1,$0		;the converted word

loadBytes
		lbu		t8,$0000(at)
		lbu		t9,$0008(at)	;load 2 bytes for one row
		li		a1,$08			;count 8 shifts

decode
		sll		v1,v1,$03	; two padding zeros to get 4 bits

		andi	v0,t9,$01		
		or		v1,v1,v0

		sll		v1,v1,$01
		andi	v0,t8,$01		
		or		v1,v1,v0

		srl		t8,t8,$01
		srl		t9,t9,$01	; shift the sources down
		subiu	a1,a1,$01	; dec the shift counter

		bgtz	a1,decode	; loop for the full 32 bits
		nop

		sw		v1,$0000(sp)	; store the decoded word (att #0)
		or		gp,v1,a2
		sw		gp,$0004(sp)	; store word for att #1
		sll		gp,a2,$01
		or		gp,v1,gp
		sw		gp,$0100(sp)	; store word for att #2
		or		gp,gp,a2
		sw		gp,$0104(sp)	; store word for att #3
		
		andi	v0,s5,$01
		beqz	v0,patEvenTile
		li		v0,512
		li		v0,-504
patEvenTile

		addu	sp,sp,v0		; inc dest addr
		addiu	at,at,$10		; inc source addr
		addiu	s5,s5,$1		; inc the counter
		
		andi	v0,s5,$7
		bnez	v0,loadBytes		; if on the end of a row of pix
		nop

		subiu	at,at,$007F			;	addr -= 128

		andi	v0,s5,$003F
		bne		v0,zero,loadBytes	; if on the end of a row of
		nop							; whole tiles (8 pix rows)
	
	;--- done decoding, now transfer---
		subiu	t8,at,$0008		; bring src addr back to where it started

		lui		gp,$1f80		; hardware base

		li		at,$04000000
		sw		at,GP1(gp)		;set DMA to CPU->GPU
		nop
		lui		at,$0100
		sw		at,GP0(gp)		;reset command buffer
		nop

		li		sp,$e6000000
		sw		sp,GP0(gp)
		nop

		lui		at,$A000
		sw		at,GP0(gp)		;send image data primitive
		nop

		andi	t8,t8,$1FFF

		srl		t9,t8,$09
		sll		t9,t9,$15

		andi	at,t8,$180
		srl		at,at,$03
		or		t9,t9,at

		sw		t9,GP0(gp)		;YYYYXXXX
		nop

		li		at,$00200010
		sw		at,GP0(gp)		;HHHHWWWW = 8 x 64 (each frame buffer pixel is 16 bits, so you get 4, 4bpp tex pixs per frame pix)
		nop

		li		at,$04000002		;set DMA CPU->GPU
		sw		at,GP1(gp)

		la		at,patTmp
		sw		at,$10a0(gp)	;set D2_MADR with the start address
		nop
		li		at,$00100010
		sw		at,$10a4(gp)	;set D2_BCR with #blocks,block size (words)
		nop
		li		at,$01000201
		sw		at,$10a8(gp)	;set D2_CHCR with the trigger stuff
		nop

dmaWait
		lw		at,$10a8(gp)
		nop
		srl		at,at,$18
		andi	at,$01
		bnez	at,dmaWait
		nop

		li		s5,$01		;restore s5
		li		gp,$00
		li		sp,$08

		jr		ra
		nop

;----------------------------------------------------
; transVROM
; in: at=src address of VROM block to transfer
; in: a0=block # to transfer to (0 -> VROM_SLOTS)
;----------------------------------------------------
transVROM
		la		sp,vromTmp		; fp = dest of decoded data

		li		a2,$44444444	; att data to OR in

		li		s5,$0		;tile counter
		li		v1,$0		;the converted word
		
loadBytesVROM
		lbu		t8,$0000(at)
		lbu		t9,$0008(at)	;load 2 bytes for one row
		li		a1,$08			;count 8 shifts

decodeVROM
		sll		v1,v1,$03	; two padding zeros to get 4 bits

		andi	v0,t9,$01		
		or		v1,v1,v0

		sll		v1,v1,$01
		andi	v0,t8,$01		
		or		v1,v1,v0

		srl		t8,t8,$01
		srl		t9,t9,$01	; shift the sources down
		subiu	a1,a1,$01	; dec the shift counter

		bgtz	a1,decodeVROM	; loop for the full 32 bits
		nop

		sw		v1,$0000(sp)	; store the decoded word (att #0)
		or		gp,v1,a2
		sw		gp,$0004(sp)	; store word for att #1
		sll		gp,a2,$01
		or		gp,v1,gp
		sw		gp,$0400(sp)	; store word for att #2
		or		gp,gp,a2
		sw		gp,$0404(sp)	; store word for att #3
		
		andi	v0,s5,$01
		beqz	v0,vromEvenTile
		li		v0,2048
		li		v0,-2040
vromEvenTile
		
		addu	sp,sp,v0		; inc dest addr
		addiu	at,at,$10		; inc source addr
		addiu	s5,s5,$01		; inc the counter
		
		andi	v0,s5,$1F
		bnez	v0,loadBytesVROM		; if on the end of a row of pix
		nop

		subiu	at,at,$01FF			;	addr -= 128

		andi	v0,s5,$FF
		bnez	v0,loadBytesVROM	; if on the end of a row of
		nop							; whole tiles (8 pix rows)

		addiu	at,at,$1F8 
		addiu	sp,sp,$C00
	
		and		v0,s5,$01FF
		bnez	v0,loadBytesVROM	; if at the end
		nop

		;--- done decoding, now transfer---

		lui		gp,$1f80		; hardware base

		li		sp,$e6000000
		sw		sp,GP0(gp)
		nop

		li		sp,$04000002
		sw		sp,GP1(gp)		;set DMA to CPU->GPU
		nop
		lui		sp,$0100
		sw		sp,GP0(gp)		;reset command buffer
		nop
		lui		sp,$A000
		sw		sp,GP0(gp)		;send image data primitive
		nop
	
		srl		sp,a0,$03		;every 8 blocks is worth 64 pix for X pos
		sll		sp,sp,$06
		
		andi	at,a0,$07		;every MOD7 blocks is worth 64 pix for Y pos
		sll		at,at,$16
		or		sp,sp,at

		sw		sp,GP0(gp)		;YYYYXXXX
		nop

		li		sp,$00400040
		sw		sp,GP0(gp)		;HHHHWWWW = 64 x 64 (each frame buffer pixel is 16 bits, so you get 4, 4bpp tex pixs per frame pix)
		nop

		la		sp,vromTmp
		sw		sp,$10a0(gp)	;set D2_MADR with the start address
		nop
		li		sp,$00800010
		sw		sp,$10a4(gp)	;set D2_BCR with #blocks,block size (words)
		nop
		li		sp,$01000201
		sw		sp,$10a8(gp)	;set D2_CHCR with the trigger stuff
		nop

dmaWaitblock
		lw		sp,$10a8(gp)
		nop
		srl		sp,sp,$18
		bnez	sp,dmaWaitblock
		nop

gpuWaitblock2k
		lw		sp,GP1(gp)
		nop
		srl		sp,sp,$10
		andi	sp,sp,$1400
		xori	sp,sp,$1400
		bnez	sp,gpuWaitblock2k
		nop

		li		s5,$01		;restore s5
		li		gp,$00
		li		sp,$08

		jr		ra
		nop

;--------------------------------------------------------------
; bufLoadVROM
; in: a0=block # you want loaded (each block = $400 bytes)
; in: a1=which slot in pattern table does this block represent
;--------------------------------------------------------------
bufLoadVROM
		sw		ra,saveRA
		sw		a0,saveA0		;save some stuff
		sw		a1,saveA1

		lbu		at,chrMask
		lui		s7,$8001
		and		a0,a0,at

		la		at,buffs
		addiu	gp,at,128
		li		t8,$0
		addiu	a0,a0,$01		;make it one more sice 0=no block present
checkLoop
		lhu		t9,$0000(at)
		addiu	at,at,$02
		beq		t9,a0,checkDone		;if found...
		nop
		beqz	t9,notFoundSpace	;if reach end of loaded spaces
		nop
		bne		at,gp,checkLoop		;if reach end of list, all full
		addiu	t8,t8,$01

notFoundNoSpace
		lui		gp,$1f80
		lbu		t8,buffNext_incAmt(gp)		; load the next slot to try
		lbu		t9,buffNext_incAmt+1(gp)	; load the inc amount
		nop

		subu	t8,t8,t9				; offset for the following loop
findOKspace
		lw		ra,BLOCKS(s7)			;need to make this NOT overwrite something
		addu	t8,t8,t9				;already in 'blocks'
		andi	t8,t8,$3F
		andi	at,ra,$FF
		beq		at,t8,findOKspace
		srl		ra,ra,$08
		andi	at,ra,$FF
		beq		at,t8,findOKspace
		srl		ra,ra,$08
		andi	at,ra,$FF
		beq		at,t8,findOKspace
		srl		ra,ra,$08
		andi	at,ra,$FF
		beq		at,t8,findOKspace
		nop

		lw		ra,BLOCKS+4(s7)
		nop
		andi	at,ra,$FF
		beq		at,t8,findOKspace
		srl		ra,ra,$08
		andi	at,ra,$FF
		beq		at,t8,findOKspace
		srl		ra,ra,$08
		andi	at,ra,$FF
		beq		at,t8,findOKspace
		srl		ra,ra,$08
		andi	at,ra,$FF
		beq		at,t8,findOKspace
		nop

		addu	t9,t8,t9
		sb		t9,buffNext_incAmt(gp)		;store the next slot to try

		ori		ra,s7,BLOCKS
		addu	ra,ra,a1
		sb		t8,$0000(ra)

		la		t9,buffs
		sll		at,t8,$01			;save the new block #
		addu	t9,t9,at
		sh		a0,$0000(t9)

		lw		at,vromaddr
		subiu	a0,a0,$01
		sll		t9,a0,$0A
		addu	t9,at,t9
		la		at,patBlocks
		sll		s6,a1,$02			;save the block #
		addu	at,at,s6
		sw		t9,$0000(at)

		lbu		at,prgCount
		la		t9,rom_img+16
		sll		at,at,$0E			;start addr of VROM data
		addu	t9,t9,at

		sll		a0,a0,$0A
		addu	at,a0,t9			;at=start addr of block to load
		or		a0,t8,zero			;a0=slot to load to
		or		s6,a1,zero			;need to save this so it's not killed
		jal		transVROM
		nop

		or		a1,s6,zero			;a1=dest slot in pattern table

		j		foundDone
		nop

checkDone      ;found the block already in the buffer
		ori		ra,s7,BLOCKS
		addu	ra,ra,a1
		sb		t8,$0000(ra)

		lw		at,vromaddr
		subiu	a0,a0,$01
		sll		t9,a0,$0A
		addu	t9,at,t9
		la		at,patBlocks
		sll		s6,a1,$02			;set the pattern data pointer
		addu	at,at,s6
		sw		t9,$0000(at)

		j		foundDone
		nop

notFoundSpace
		la		t9,buffs
		sll		at,t8,$01			;save the new block #
		addu	t9,t9,at
		sh		a0,$0000(t9)

		lw		at,vromaddr
		subiu	a0,a0,$01
		sll		a0,a0,$0A
		addu	at,at,a0
		la		t9,patBlocks
		sll		s6,a1,$02			;set the pattern data pointer
		addu	t9,t9,s6
		sw		at,$0000(t9)

		ori		ra,s7,BLOCKS
		addu	ra,ra,a1
		sb		t8,$0000(ra)

		;at=start addr of block to load
		or		a0,t8,zero			;a0=slot to load to
		jal		transVROM
		nop

foundDone
		lw		ra,saveRA
		lw		a0,saveA0
		lw		a1,saveA1
		addiu	a0,a0,$01		;set it so another call will do next block
		jr		ra
		addiu	a1,a1,$01

;------------------------------------------------
; makeP
; makes a byte for P, the flags reg into a1
;------------------------------------------------

makeP
		lbu		t8,$1805(s7)		;get D flag
		or		a1,zero,t6
		sllv	a1,a1,s5
		or		a1,a1,t5
		sllv	a1,a1,s5
		ori		a1,a1,$01
		sllv	a1,a1,s5
		or		a1,a1,t4
		sllv	a1,a1,s5
		;or		a1,a1,t3
		sllv	a1,a1,s5
		or		a1,a1,t2
		sllv	a1,a1,s5
		or		a1,a1,t1
		sllv	a1,a1,s5
		or		a1,a1,t8
		jr		ra
		or		a1,a1,t0

;--------------------------------------------------------------------
libGpuInit
;	gpu init recreated from sony libs
;--------------------------------------------------------------------

		subiu	sp,sp,$14
		sw		ra,$0010(sp)

		lui		v0,$1f80

		;li		a0,$0				;passes address of lib's jump table & $00FFFFFF
		;li		t2,$A0
		;jalr	t2					;gpu_cw - don't understand what this does yet
		;li		t1,$49

		lhu		a0,$1074(v0)
		sh		zero,$1074(v0)		;zero int mask reg

		li		at,$0401
		sw		at,$10A8(v0)		;dma control reg, linked list mode, to GPU

		lw		at,$10F0(v0)            
		nop
		ori		at,at,$0800			;turn on the GPU's DMA channel in DPCR
		sw		at,$10F0(v0)

		sw		zero,$1814(v0)		;reset control command

		sh		a0,$1074(v0)		;restore the int mask

		jal		VSync
		nop

	;setDispMask(0) part

		lui		v0,$1f80
		li		at,$03000001
		sw		at,$1814(v0)		;mask display

		lw		ra,$0010(sp)
		nop
		jr		ra
		addiu	sp,sp,$14

;-------------------------------------------------------------
; WaitGPU - waits until GPU ready to recieve commands
;-------------------------------------------------------------

WaitGPU
        lui		at,$1f80
        lw		at, GP1(at)		; load status word from GPU
		nop
		sll		at,at,$03
		srl		at,at,$1F
        beqz	at, WaitGPU		; bit $1c = 0 -> GPU is busy
        nop
        jr ra
        nop

WaitGPUIdle
			lui at,$1f80        
            lw at, GP1(at)                
            nop
			srl at,at,$1A
            andi at,at,$01
            beqz at, WaitGPUIdle
            nop
            jr ra
            nop

InitPads
		sw		ra,saveRA

        la		a0, pad_buf
		li		a1, 32
        la		a2, pad_buf2
		li		a3, 32
		li		t2,$B0
		jalr	t2					;initpad bios call
		li		t1,$12

		li		t2,$B0
		jalr	t2					;startpad bios call
		li		t1,$13

		li		a0,$00
		li		t2,$B0
		jalr	t2					;ChangeClearPAD(0)
		li		t1,$5B

		li		t0,$FFFF
		sh		t0,pad_buf+2		;init the data readouts
		sh		t0,pad_buf2+2

		lw		ra,saveRA
		nop
		jr		ra
		nop

VSync
		lw		v0,vSyncCount
vsync_wait_loop
		lw		at,vSyncCount
		nop
		beq		at,v0,vsync_wait_loop
		nop
        jr ra
        nop
		
IREG equ $1070
IMASK equ $1074
DPCR equ $10f0
DICR equ $10f4
D2_MADR equ $10a0
D2_BCR equ $10a4
D2_CHCR equ $10a8

;--------------------------------
; copyMem
; in:a0 = dest address
; in:a1 = src address
; in:a2 = # of bytes
;--------------------------------
copyMem
	andi	at,a0,$3
	bnez	at,copyMemBytes
	andi	at,a1,$3
	bnez	at,copyMemBytes
	andi	at,a2,$3
	bnez	at,copyMemBytes
	nop

copyMemWords
	lw	 at,$0000(a1)
	addiu a1,a1,4
	sw	 at,$0000(a0)
	subiu a2,a2,4
	bgtz a2,copyMemWords
	addiu a0,a0,4
	jr	 ra
	nop

copyMemBytes
	lbu	 at,$0000(a1)
	addiu a1,a1,1
	sb	 at,$0000(a0)
	subiu a2,a2,1
	bgtz a2,copyMemBytes
	addiu a0,a0,1
	jr	 ra
	nop

;--------------------------------
; fillMem
; in:a0 = start address
; in:a1 = length of fill in bytes
; in:a2 = word value to fill with
;--------------------------------
fillMem
	sw	 a2,$0000(a0)
	subiu a1,a1,$04
	addiu a0,a0,$04
	bgtz a1,fillMem
	nop
	jr   ra
	nop

;--------------------------------------------------------------------
; scan sprite 0
; in: a1 has the addr of sprite 0's attribute bytes (Y,index,flags,X)
;--------------------------------------------------------------------
scanSpr0
		lbu		at,sprType
		nop
		andi	gp,at,$20
		bne		gp,zero,scan16
		nop

		lbu		gp,$0001(a1)	; get the tile # for sprite 0
		lbu		at,$2000(s7)
		la		t8,patBlocks
		srl		a2,gp,$06
		sll		a2,a2,$02
		addu	t8,t8,a2
		andi	at,at,$08	 ; adjust for which
		sll		at,at,$01
		addu	t8,t8,at
		lw		a2,$0000(t8)
		andi	at,gp,$3F
		lbu		t8,$0000(a1)	; load the Y coord
		sll		at,at,$04
		addu	a2,a2,at	; add $10 for each tile

		addiu	gp,a2,$0008		;end address
countLoop
		lbu		at,$0000(a2)
		lbu		t9,$0008(a2)
		addiu	t8,t8,$01
		or		at,at,t9
		bnez	at,countDone
		addiu	a2,a2,$0001
		bne		a2,gp,countLoop
		nop
		li		t8,$0100		;no hit if there's no non trans pix
countDone
		;addiu	t8,t8,$01		; this is to make it occur on the right line
		sb		t8,sprHitLine		

		jr		ra
		nop

scan16

		lbu		gp,$0001(a1)	; get the tile # for sprite 0
		la		t8,patBlocks
		andi	at,gp,$01	 ; adjust for which
		sll		at,at,$04	 ; pattern table
		addu	t8,t8,at
		andi	gp,gp,$FE	 ; make the tile# even
		srl		a2,gp,$06
		sll		a2,a2,$02
		addu	t8,t8,a2
		lw		a2,$0000(t8)
		andi	at,gp,$3F
		lbu		t8,$0000(a1)	; load the Y coord
		sll		at,at,$04
		addu	a2,a2,at	; add $10 for each tile

		addiu	gp,a2,$08		;end address

countLoop16p1
		lbu		at,$0000(a2)
		lbu		t9,$0008(a2)
		addiu	t8,t8,$01
		or		at,at,t9
		bnez	at,countDone16
		addiu	a2,a2,$01
		bne		a2,gp,countLoop16p1
		nop

		addiu	a2,a2,$08
		addiu	gp,a2,$08	; new finish addr

countLoop16p2
		lbu		at,$0000(a2)
		lbu		t9,$0008(a2)
		addiu	t8,t8,$01
		or		at,at,t9
		bnez	at,countDone16
		addiu	a2,a2,$01
		bne		a2,gp,countLoop16p2
		nop
		li		t8,$0100		;no hit if there's no non trans pix
countDone16
		;addiu	t8,t8,$01		;needs a little adjustment
		sb		t8,sprHitLine		

		jr		ra
		nop

;-------------------------------------------------
libSpuInit
; version of SpuInit recreated from the psyq libs
;-------------------------------------------------
		
		subiu	sp,sp,$30
		sw		ra,$0018(sp)

		; ResetCallback called here, i called it earlier

	;_spu_init part

		lui		gp,$1F80			;hardware base

		lw		t0,$10F0(gp)            
		lui		at,$000B			;turn on the SPU's DMA channel in DPCR
		or		t0,t0,at
		sw		t0,$10F0(gp)

		li		t0,$1F801C00
		sh		zero,$0180(t0)		;main vol left and right = 0
		sh		zero,$0182(t0)

		sh		zero,$01AA(t0)		;spu control reg = 0

		jal		libSpuDelay
		nop

		li		t0,$1F801C00
		sh		zero,$0180(t0)		;main vol left and right = 0 again
		sh		zero,$0182(t0)

libInitSpuWaitIdle
		lhu		at,$01AE(t0)		;get spu status - check is done here 
		nop							;to wait for spu to become idle
		andi	at,at,$07FF
		bnez	at,libInitSpuWaitIdle	;wait for idle, no timeout check
		nop

		li		at,$04
		sh		at,$01AC(t0)		;load the unknown reg with 4

		sh		zero,$0184(t0)		;reverb depth left,right = 0
		sh		zero,$0186(t0)

		li		at,$FFFF
		sh		at,$018C(t0)		;turn all voices off
		sh		at,$018E(t0)

		sh		zero,$0198(t0)		;reverb mode = 0 for all channels
		sh		zero,$019A(t0)

		sh		zero,$0190(t0)		;freq modulation off
		sh		zero,$0192(t0)
		sh		zero,$0194(t0)		;noise mode off
		sh		zero,$0196(t0)
		sh		zero,$01B0(t0)		;cd vol = 0
		sh		zero,$01B2(t0)
		sh		zero,$01B4(t0)		;ext vol = 0
		sh		zero,$01B6(t0)

		la		a0,initSPUSystemData
		li		a1,$0010
		li		a2,$1000
		jal		libSpuCPUSPUtrans
		nop

		li		v0,$3FFF		;default pitch
		li		v1,$0200		;default wave data pointer
		li		at,$18			;# of voices to init
		li		t0,$1F801C00
libVoiceInitLoop
		sh		zero,$0000(t0)
		sh		zero,$0002(t0)
		sh		v0,$0004(t0)
		sh		v1,$0006(t0)
		sh		zero,$0008(t0)
		sh		zero,$000A(t0)
		subiu	at,at,$01
		bnez	at,libVoiceInitLoop
		addiu	t0,t0,$10

		li		v0,$1F801C00
		li		t0,$FFFF
		li		t1,$00FF
		sh		t0,$0188(v0)			turn all voices on
		sh		t1,$018A(v0)
		jal		libSpuDelay
		nop
		jal		libSpuDelay
		nop
		jal		libSpuDelay
		nop
		jal		libSpuDelay
		nop

		li		v0,$1F801C00
		sh		t0,$018C(v0)			all voices off
		sh		t1,$018E(v0)
		jal		libSpuDelay
		nop
		jal		libSpuDelay
		nop
		jal		libSpuDelay
		nop
		jal		libSpuDelay
		nop

		li		a0,$1F801C00
		li		at,$C000
		sh		at,$01AA(a0)		;enable and unmute spu

	;SpuStart part

HwSPU		equ	$F0000009
EvSpCOMP	equ	$0020
EvMdNOINTR	equ	$2000

		li		a0,$01
		syscall					;enterCriticalSection

		lw		a0,$10f4(gp)
		lui		at,$00FF
		ori		at,at,$FFFF
		and		a0,a0,at
		lui		at,$0090
		or		a0,a0,at
		sw		a0,$10f4(gp)	;allow spu dma complete to generate interupts

		;li		a0,HwSPU
		;li		a1,EvSpCOMP
		;li		a2,EvMdNOINTR
		;li		a3,$0
		;li		t2,$00B0		;open event for spu command complete
		;jalr	t2
		;li		t1,$0008		

		;sw		v0,spu_dma_event_desc
		;or		a0,v0,zero
		;li		t2,$00B0		;enable event
		;jalr	t2
		;li		t1,$000C

		li		a0,$02			;exit critical section
		syscall

	;end spustart part

		li		at,$FFFE
		sh		at,$1DA2(gp)		;set reverb start area

	;---------------------------------
	; now set up the voices for imbNES
	;---------------------------------

		sw		zero,spuDMAcallback

		la		a0,wav_tri
		li		a1,$4C0
		li		a2,TRI_BASE
		jal		libSpuWrite
		nop

		jal		libSpuIsTransferComplete
		nop

		la		a0,wav_noise93
		li		a1,$19AC0
		li		a2,NOISE93_BASE
		jal		libSpuWrite
		nop

		jal		libSpuIsTransferComplete
		nop

		la		a0,wav_squ
		li		a1,$980
		li		a2,SQU_BASE
		jal		libSpuWrite
		nop

		jal		libSpuIsTransferComplete
		nop

	; set start addresses...
	; channels 0-15 are for sq waves 1 and 2

		lui		gp,$1f80

		li		t0,SQU_BASE>>3

		sh		t0,$1c06(gp)		; \
		addiu	t0,t0,$42
		sh		t0,$1c16(gp)
		addiu	t0,t0,$0A
		sh		t0,$1c26(gp)
		addiu	t0,t0,$42
		sh		t0,$1c36(gp)
		addiu	t0,t0,$0A			;	SQ1 channels
		sh		t0,$1c46(gp)
		addiu	t0,t0,$42
		sh		t0,$1c56(gp)
		addiu	t0,t0,$0A
		sh		t0,$1c66(gp)
		addiu	t0,t0,$42
		sh		t0,$1c76(gp)
		addiu	t0,t0,$0A			; /

		li		t0,SQU_BASE>>3

		sh		t0,$1c86(gp)		; \
		addiu	t0,t0,$42
		sh		t0,$1c96(gp)
		addiu	t0,t0,$0A
		sh		t0,$1cA6(gp)
		addiu	t0,t0,$42
		sh		t0,$1cB6(gp)
		addiu	t0,t0,$0A			;	SQ2 channels
		sh		t0,$1cC6(gp)
		addiu	t0,t0,$42
		sh		t0,$1cD6(gp)
		addiu	t0,t0,$0A
		sh		t0,$1cE6(gp)
		addiu	t0,t0,$42
		sh		t0,$1cF6(gp)
		addiu	t0,t0,$0A			; /

		li		t0,TRI_BASE>>3
		sh		t0,$1d06(gp)		;tri start addr

		li		t0,$0004			;give tri a release rate to avoid pops
		sh		t0,$1d0a(gp)		;using key on/off

		li		t0,NOISE93_BASE>>3
		sh		t0,$1d26(gp)		;tmp start addr
		li		t0,$1000
		sh		t0,$1d24(gp)

		li		t0,$0002
		sh		t0,$1d96(gp)		;make channel 17 noise

		li		t0,$FFFF
		sh		t0,$1d88(gp)		;turn on channels
		li		t0,$0007
		sh		t0,$1d8a(gp)

		li t1, $3000
        sh t1, $1d80(gp)		;main vol L and R
        sh t1, $1d82(gp)
;li t0,$1000
;sh t0,$1d04(gp)
;li t0,$2000
;sh t0,$1d00(gp)
;sh t0,$1d02(gp)
;li at,$01
;sh at,$1d8e(gp)
;sh at,$1d8a(gp)
		lw		ra,$0018(sp)
		nop
		jr		ra
		addiu	sp,sp,$30

initSPUSystemData	dw $07070707,$07070707,$07070707,$07070707
spu_dma_active		dw $0

;-----------------------------------------------
libSpuDelay
; a delay function recreated from the psqy libs
;-----------------------------------------------
		la		at,vromTmp
		li		v0,13
		sw		v0,4(at)
		j		text_B18
		sw		zero,0(at)
text_AEC
		lw		v1,4(at)
		nop
		sll		v0,v1,1
		addu	v0,v0,v1
		sll		v0,v0,2
		addu	v0,v0,v1
		sw		v0,4(at)
		lw		v0,0(at)
		nop
		addiu	v0,v0,1
		sw		v0,0(at)
text_B18
		lw		v0,0(at)
		nop
		slti	v0,v0,60
		bnez	v0,text_AEC
		nop
		jr		ra
		nop
	
;--------------------------------------------------------------------
libSpuCPUSPUtrans
; a function to use the data reg to transfer info to the sound buffer
; in: a0 = source address
; in: a1 = size of data
; in: a2 = dest in sound buffer
;--------------------------------------------------------------------

		subiu	sp,sp,$30
		sw		ra,$0018(sp)

		li		v0,$1F801C00
		or		s1,a1,zero
		or		s2,a0,zero

		lhu		a1,$01AE(v0)		;load status
		srl		a2,a2,$03
		sh		a2,$01A6(v0)		;set sound buffer address
		andi	s3,a1,$07FF

		jal		libSpuDelay
		nop

		beqz	s1,libSpuCPUSPUafterTransfer	;jump to end if size is 0
		sltiu	v0,s1,65

libSpuCPUSPUtransferTop
		beqz	v0,libSpuCPUSPUbigSize
		li		s0,64
		or		s0,s1,zero				;makes 64 the max value in s0

libSpuCPUSPUbigSize
		blez	s0,libSpuCPUSPUskipWrite		;skip writing if size <= 0
		li		v1,$0

		li		a0,$1F801C00

libSpuCPUSPUtransferLoop
		lhu		v0,$0000(s2)				;load data
		addiu	s2,s2,$02
		addiu	v1,v1,$02
		sh		v0,$01A8(a0)				;write to data reg
		slt		v0,v1,s0
		bnez	v0,libSpuCPUSPUtransferLoop		;loop to transfer s0 bytes
		nop

libSpuCPUSPUskipWrite
		li		v1,$1F801C00
		lhu		a0,$01AA(v1)
		nop
		andi	v0,a0,$FFCF			;change DMA to 01 in control reg
		ori		v0,v0,$0010
		sh		v0,$01AA(v1)

		jal		libSpuDelay
		nop

libSpuCPUSPUwaitNotBusy
		li		v0,$1F801C00
		lhu		v0,$01AE(v0)				;get status
		nop
		andi	v0,v0,$0400
		bnez	v0,libSpuCPUSPUwaitNotBusy
		nop

		jal		libSpuDelay
		nop
		jal		libSpuDelay
		nop

		subu	s1,s1,s0
		bnez	s1,libSpuCPUSPUtransferTop			; loop to transfer all data
		sltiu	v0,s1,65

libSpuCPUSPUafterTransfer
		li		v0,$1F801C00
		lhu		a0,$01AA(v0)
		andi	a1,s3,$FFFF
		andi	v1,a0,$FFCF
		sh		v1,$01AA(v0)				;set DMA in control to 00

libSpuCPUSPUwaitDMAFclear
		li		v0,$1F801C00
		lhu		v0,$01AE(v0)				;load status
		nop
		andi	v0,v0,$07FF
		bne		v0,a1,libSpuCPUSPUwaitDMAFclear		;return if status reg is the same as before the transfer
		nop

		lw		ra,$0018(sp)
		nop
		jr		ra
		addiu	sp,sp,$30


;------------------------------------------
libSpuWrite
;  recreation of SpuWrite from psyq libs
; in:a0 = start addr of data
; in:a1 = size of data (must be mult of 64)
; in:a2 = full target addr in sound buffer
;------------------------------------------

		lui		gp,$1f80

		srl		a2,a2,$03
		sh		a2,$1DA6(gp)		;set sound buffer address

libSpuWriteAddrLoop	
		lhu		at,$1DA6(gp)				;wait for address to register change
		nop
		bne		at,a2,libSpuWriteAddrLoop
		nop

		lhu		at,$1DAA(gp)
		nop
		andi	at,at,$FFCF					;set to DMA mode write
		ori		at,at,$0020
		sh		at,$1DAA(gp)

libSpuWriteModeLoop	
		lhu		at,$1DAA(gp)				;wait for dma mode change to change
		li		v0,$0020
		andi	at,at,$0030
		bne		at,v0,libSpuWriteModeLoop
		nop

		lw		at,$1014(gp)			;no idea what this is doing...
		nop
		li		v0,$F0FFFFFF
		and		at,at,v0
		lui		v0,$2000				;this would be $2200 for dma reads
		or		at,at,v0
		sw		at,$1014(gp)

		srl		v0,a1,$06				;v0 = # of 64 byte blocks needed
		sw		a0,$10C0(gp)			;set dest addr

		sll		v0,v0,$10
		ori		v0,v0,$0010
		sw		v0,$10C4(gp)			;set block data

		li		v0,$01
		sw		v0,spu_dma_active

		li		v0,$01000201
		sw		v0,$10C8(gp)			;set write trigger

		jr		ra
		nop

;-----------------------------------
libSpuIsTransferComplete
;  waits for dma transfer to be done
;-----------------------------------
		lw		at,spu_dma_active
		nop
		bnez	at,libSpuIsTransferComplete
		nop
		jr		ra
		nop


;---------------------------------------------------------------
resetStuff
;	resets various memory things so that a new game can start up
;---------------------------------------------------------------

		li		sp,$801FFF00		;set up stack

		lui		gp,$1f80
		li		a0,$170
soundSilenceLoop
		or		a1,a0,gp
		sh		zero,$1c00(a1)
		sh		zero,$1c02(a1)
		subiu	a0,a0,$10
		bgez	a0,soundSilenceLoop
		nop

		lhu		a0,$1074(gp)		;disable rcnt1 int handling
		nop
		andi	a0,a0,$FFDF
		sh		a0,$1074(gp)

		jal		restoreVars			;restore emulation variables to orig vals
		nop

		lbu		t0,SRAMchanged(s7)
		nop
		beqz	t0,noSaveQuery
		nop

		jal		askSave
		nop

noSaveQuery
		j		imbNESreset
		nop

;----------------------------------------------------------------------
makeTextprims	; sets up a block of prims to DMA to draw a text screen
;	out: v0 = size of data created
;----------------------------------------------------------------------

	TEXT_PRIM_ADDR = $80010000
	TEXT_PRIM_CHARS_OFFSET = $44
	TEXT_ROWS = 21
	TEXT_COLS = 32

		li		a0,TEXT_PRIM_ADDR

		addiu	at,a0,TEXT_PRIM_CHARS_OFFSET	; link
		sll		at,at,$08
		srl		at,at,$08
		lui		t0,$1000
		or		at,at,t0
		sw		at,$0000(a0)
		addiu	a0,a0,$04
		li		at,$E3000000		; clip top
		sw		at,$0000(a0)
		addiu	a0,a0,$04
		li		at,$E4FFFFFF		; clip bottom
		sw		at,$0000(a0)
		addiu	a0,a0,$04
		li		at,$E5000000		; draw offset (0)
		sw		at,$0000(a0)
		addiu	a0,a0,$04
		li		at,$E6000000		; mask bits
		sw		at,$0000(a0)
		addiu	a0,a0,$04
		li		at,$60400000		; black rect
		sw		at,$0000(a0)
		addiu	a0,a0,$04
		li		at,$00000000
		sw		at,$0000(a0)
		addiu	a0,a0,$04
		li		at,$01000100
		sw		at,$0000(a0)
		addiu	a0,a0,$04
		li		at,$E500A000		; draw offset (+20 Y)
		sw		at,$0000(a0)
		addiu	a0,a0,$04

		li		at,$388a442a		; selection poly
		sw		at,$0000(a0)
		addiu	a0,a0,$04
		li		at,$00000000
		sw		at,$0000(a0)
		addiu	a0,a0,$04
		li		at,$00F0caa6
		sw		at,$0000(a0)
		addiu	a0,a0,$04
		li		at,$00000000
		sw		at,$0000(a0)
		addiu	a0,a0,$04
		li		at,$008a442a
		sw		at,$0000(a0)
		addiu	a0,a0,$04
		li		at,$00000000
		sw		at,$0000(a0)
		addiu	a0,a0,$04
		li		at,$00F0caa6
		sw		at,$0000(a0)
		addiu	a0,a0,$04
		li		at,$00000000
		sw		at,$0000(a0)
		addiu	a0,a0,$04

		li		v0,$0						;counter
		li		t0,TEXT_ROWS
		li		t1,TEXT_COLS
		multu	t0,t1
		mflo	v1							;how many prims to make
		li		a2,$0800					;initial YYXX on tex page
textMakeLoop
		addiu	at,a0,$14
		sll		at,at,$08
		srl		at,at,$08
		lui		t0,$0400
		or		at,at,t0
		sw		at,$0000(a0)		; link
		addiu	a0,a0,$04

		li		at,$64808080
		sw		at,$0000(a0)		;4 point textured poly prim
		addiu	a0,a0,$04

		srl		at,v0,$05
		sll		at,at,$13
		srl		t0,at,$02
		addu	at,at,t0		;y coord (10 pix per line)
		lui		t0,$01
		addu	at,at,t0

		andi	t0,v0,$1F
		sll		t0,t0,$03		;x coord (8 pix per char)
		or		a1,at,t0
		sw		a1,$0000(a0)		;yyyyxxxx of upper left point
		addiu	a0,a0,$04

		li		at,FONT_Y_X
		srl		t0,at,$10
		srl		at,at,$04
		andi	at,at,$3F		;x coord / 16 of clut
		sll		t0,t0,$06
		or		at,at,t0
		sll		at,at,$10
		or		at,at,a2
		sw		at,$0000(a0)		;clut_uuvv (uuvv is set as write to screen)
		addiu	a0,a0,$04

		li		at,$00080008
		sw		at,$0000(a0)		;hhhhwwww
		addiu	a0,a0,$04

		addiu	v0,v0,1
		bne		v0,v1,textMakeLoop
		nop

		subiu	at,a0,$14
		li		t0,$04FFFFFF
		sw		t0,$0000(at)

		li		at,TEXT_PRIM_ADDR
		jr		ra
		subu	v0,a0,at

;---------------------------------------------------------------------
writeStrEnc ; a0=addr of 32 byte encoded string  a1=line# to write to
;---------------------------------------------------------------------

		sw		t1,saveT1
		sw		t2,saveT2
		sw		t4,saveT4

		la		t0,TEXT_PRIM_ADDR+TEXT_PRIM_CHARS_OFFSET
		li		at,$280
		multu	at,a1
		mflo	a1
		addu	t0,t0,a1
		li		t1,32

		lbu		t4,32(a0)
		nop
		
writeStrEncLoop
		lbu		t2,$0000(a0)
		addiu	a0,a0,1
		srl		at,t4,$07
		sll		t4,t4,$01
		or		t4,t4,at
		xori	t4,t4,$A6
		andi	t4,t4,$FF
		addu	t2,t2,t4
		andi	t2,t2,$FF		; t2 now has decoded letter
		
		andi	t3,t2,$1F
		sll		t3,t3,$03
		srl		t2,t2,$05
		sll		t2,t2,$0B
		or		t2,t2,t3
		sh		t2,$000C(t0)
		addiu	t0,t0,$14
		subiu	t1,t1,1
		bnez	t1,writeStrEncLoop
		nop

		lw		t1,saveT1
		lw		t2,saveT2
		lw		t4,saveT4

		jr		ra
		nop

;--------------------------------------------
sendList
; in: v0=addr of start of list
;--------------------------------------------
		lui		gp,$1f80

		li		at,$04000002
		sw		at,GP1(gp)
		sw		v0,D2_MADR(gp)
		sw		zero,D2_BCR(gp)
		li		at,$01000401
		sw		at,D2_CHCR(gp)
		
		jr		ra
		nop

;--------------------------------------------
waitList
;--------------------------------------------
		lui		gp,$1f80
		lw		at,D2_CHCR(gp)
		nop
		srl		at,at,$18
		andi	at,at,$01
		bnez	at,waitList
		nop

		jr		ra
		nop

;------------------------------------------------------------------------
fixRowSingle	;fixes and links a row of BG tiles to use a new pat block
;------------------------------------------------------------------------

		;a1=row#
		;a3=mirrorSel

		srl		gp,s6,$0A
		andi	gp,gp,$03
		srlv	gp,a3,gp
		andi	gp,gp,$01		;gp has which name table

		lbu		a3,$2000(s7)
		ori		a2,s7,BLOCKS
		andi	a3,a3,$10
		srl		a3,a3,$02
		addu	a2,a2,a3
		lw		a2,$0000(a2)	;get the blocks that should be used to draw it

		lui		at,$8002
		sll		a1,a1,$02
		or		at,at,a1
		sll		s7,gp,$07
		or		at,at,s7
		lw		s7,$2800(at)	;get the blocks it was using
		sw		a2,$2800(at)	;set which blocks it should be using
		beq		s7,a2,endCheckSingle
		nop							;exit if the blocks are the same

		li		a3,$80022000
		sll		at,gp,$A
		or		a3,a3,at
		sll		a1,a1,$03
		addu	a3,a3,a1		;a3 has addr for tiles for this row

		li		v0,$80010800
		sll		at,gp,$B
		addu	v0,v0,at
		sll		at,a1,$01
		addu	v0,v0,at		;v0 has addr for time stamps

		li		at,36
		mult	at,a1
		la		a1,bg1DMAlist
		mflo	at
		addu	a1,a1,at		
		li		at,34560
		sll		gp,gp,$1F
		sra		gp,gp,$1F
		and		at,at,gp
		addu	a1,a1,at		;a1 has addr of prims for start of row

		lw		t8,$0000(a3)	;get tile #s
		lhu		gp,renderTimeStamp		;get current time stamp
		lw		sp,lastChange			;get pointer to change list
		lbu		ra,blockMask

		mthi	a0			;need to save a0

fixLoop	
		andi	at,t8,$C0
		srl		t9,at,$03
		srlv	at,a2,t9
		andi	at,at,$FF		;at has block# to use for this tile

		srlv	t9,s7,t9
		andi	t9,t9,$FF		;t9 has old block#

		beq		at,t9,noLinkFix
		andi	at,at,$3F			;64 is the limit

		andi	t9,at,$07
		sll		t9,t9,$16
		and		at,at,ra
		sll		at,at,$03
		or		t9,t9,at		;t9 has base YYYYXXXX

		andi	at,t8,$1E
		sll		at,at,$01
		addu	t9,t9,at
		andi	at,t8,$20
		sll		at,at,$10
		addu	t9,t9,at
		andi	at,t8,$01
		sll		at,at,$14
		addu	t9,t9,at		; t9 now has src Y_X for the prim

		lw		a0,$0008(a1)
		li		at,$00080002
		and		a0,a0,at
		lhu		at,$0000(v0)	;get time stamp
		or		t9,a0,t9

		beq		gp,at,noLinkFix
		sw		t9,$0008(a1)	;write new YYYYXXXX

		sh		gp,$0000(v0)		;save timestamp
		
		lw		v1,$0000(sp)
		lui		at,$FF00
		li		t9,$00FFFFFF
		and		v1,v1,at
		and		at,a1,t9
		or		at,v1,at
		sw		at,$0000(sp)		; link last to this one

		or		sp,a1,zero			;set last change to current one

noLinkFix

		addiu	a1,a1,$24
		addiu	v0,v0,$02
		srl		t8,t8,$08

		andi	at,t8,$C0
		srl		t9,at,$03
		srlv	at,a2,t9
		andi	at,at,$FF		;at has block# to use for this tile

		srlv	t9,s7,t9
		andi	t9,t9,$FF		;t9 has old block#

		beq		at,t9,noLinkFix2
		andi	at,at,$3F			;64 is the limit

		andi	t9,at,$07
		sll		t9,t9,$16
		and 	at,at,ra
		sll		at,at,$03
		or		t9,t9,at		;t9 has base YYYYXXXX

		andi	at,t8,$1E
		sll		at,at,$01
		addu	t9,t9,at
		andi	at,t8,$20
		sll		at,at,$10
		addu	t9,t9,at
		andi	at,t8,$01
		sll		at,at,$14
		addu	t9,t9,at		; t9 now has src Y_X for the prim

		lw		a0,$0008(a1)
		li		at,$00080002
		and		a0,a0,at
		lhu		at,$0000(v0)	;get time stamp
		or		t9,a0,t9

		beq		gp,at,noLinkFix2
		sw		t9,$0008(a1)	;write new YYYYXXXX

		sh		gp,$0000(v0)		;save timestamp
		
		lw		v1,$0000(sp)
		lui		at,$FF00
		li		t9,$00FFFFFF
		and		v1,v1,at
		and		at,a1,t9
		or		at,v1,at
		sw		at,$0000(sp)		; link last to this one

		or		sp,a1,zero			;set last change to current one

noLinkFix2

		addiu	a1,a1,$24
		addiu	v0,v0,$02
		srl		t8,t8,$08

		andi	at,t8,$C0
		srl		t9,at,$03
		srlv	at,a2,t9
		andi	at,at,$FF		;at has block# to use for this tile

		srlv	t9,s7,t9
		andi	t9,t9,$FF		;t9 has old block#

		beq		at,t9,noLinkFix3
		andi	at,at,$3F			;64 is the limit

		andi	t9,at,$07
		sll		t9,t9,$16
		and 	at,at,ra
		sll		at,at,$03
		or		t9,t9,at		;t9 has base YYYYXXXX

		andi	at,t8,$1E
		sll		at,at,$01
		addu	t9,t9,at
		andi	at,t8,$20
		sll		at,at,$10
		addu	t9,t9,at
		andi	at,t8,$01
		sll		at,at,$14
		addu	t9,t9,at		; t9 now has src Y_X for the prim

		lw		a0,$0008(a1)
		li		at,$00080002
		and		a0,a0,at
		lhu		at,$0000(v0)	;get time stamp
		or		t9,a0,t9

		beq		gp,at,noLinkFix3
		sw		t9,$0008(a1)	;write new YYYYXXXX

		sh		gp,$0000(v0)		;save timestamp
		
		lw		v1,$0000(sp)
		lui		at,$FF00
		li		t9,$00FFFFFF
		and		v1,v1,at
		and		at,a1,t9
		or		at,v1,at
		sw		at,$0000(sp)		; link last to this one

		or		sp,a1,zero			;set last change to current one

noLinkFix3

		addiu	a1,a1,$24
		addiu	v0,v0,$02
		srl		t8,t8,$08

		andi	at,t8,$C0
		srl		t9,at,$03
		srlv	at,a2,t9
		andi	at,at,$FF		;at has block# to use for this tile

		srlv	t9,s7,t9
		andi	t9,t9,$FF		;t9 has old block#

		beq		at,t9,noLinkFix4
		andi	at,at,$3F			;64 is the limit

		andi	t9,at,$07
		sll		t9,t9,$16
		and 	at,at,ra
		sll		at,at,$03
		or		t9,t9,at		;t9 has base YYYYXXXX

		andi	at,t8,$1E
		sll		at,at,$01
		addu	t9,t9,at
		andi	at,t8,$20
		sll		at,at,$10
		addu	t9,t9,at
		andi	at,t8,$01
		sll		at,at,$14
		addu	t9,t9,at		; t9 now has src Y_X for the prim

		lw		a0,$0008(a1)
		li		at,$00080002
		and		a0,a0,at
		lhu		at,$0000(v0)	;get time stamp
		or		t9,a0,t9

		beq		gp,at,noLinkFix4
		sw		t9,$0008(a1)	;write new YYYYXXXX

		sh		gp,$0000(v0)		;save timestamp
		
		lw		v1,$0000(sp)
		lui		at,$FF00
		li		t9,$00FFFFFF
		and		v1,v1,at
		and		at,a1,t9
		or		at,v1,at
		sw		at,$0000(sp)		; link last to this one

		or		sp,a1,zero			;set last change to current one

noLinkFix4

		addiu	a3,a3,$04
		lw		t8,$0000(a3)
		addiu	a1,a1,$24
		andi	at,a3,$1F
		bnez	at,fixLoop
		addiu	v0,v0,$02


		sw		sp,lastChange		; set the last changed to this one

		mfhi	a0

endCheckSingle
		li		s5,$01				; restore this
		j		blocksGood
		lui		s7,$8001


;------------------------------------------------------------------------
fixRowDouble	;fixes and links a row of BG tiles to use a new pat block
;------------------------------------------------------------------------

		;a1=row#
		;a3=mirrorSel

		lbu		gp,fineX
		andi	at,s6,$1F
		or		gp,gp,at
		beqz	gp,fixRowSingle		;only do a single row if you are not scrolled at all
		nop

		lbu		a3,$2000(s7)
		ori		a2,s7,BLOCKS
		andi	a3,a3,$10
		srl		a3,a3,$02
		addu	a2,a2,a3
		lw		a2,$0000(a2)	;get the blocks that should be used to draw it

		lui		at,$8002
		sll		a1,a1,$02
		or		at,at,a1
		lw		s7,$2800(at)	;get the blocks it was using
		lw		ra,$2880(at)	;get blocks second was using
		bne		s7,a2,dubDif
		nop
		beq		ra,a2,endCheckDouble
		nop
dubDif
		sw		a2,$2800(at)	;set which blocks it should be using
		sw		a2,$2880(at)	;set which blocks it should be using
		
		li		a3,$80022000
		sll		a1,a1,$03
		addu	a3,a3,a1		;a3 has addr for tiles for this row

		li		v0,$80010800
		sll		at,a1,$01
		addu	v0,v0,at		;v0 has addr for time stamps

		li		at,36
		mult	at,a1
		la		a1,bg1DMAlist
		mflo	at
		addu	a1,a1,at		;a1 has addr of prims for start of row

		mtlo	t0				;save t0
		mthi	a0			;need to save a0

		lw		t8,$0000(a3)	;get tile #s
		lhu		gp,renderTimeStamp		;get current time stamp
		lw		sp,lastChange			;get pointer to change list
		li		s5,0					;init marker
		lbu		t0,blockMask

fixLoopDub
		andi	at,t8,$C0
		srl		t9,at,$03
		srlv	at,a2,t9
		andi	at,at,$FF		;at has block# to use for this tile

		srlv	t9,s7,t9
		andi	t9,t9,$FF		;t9 has old block#

		beq		at,t9,noLinkFixDub
		andi	at,at,$3F			;64 is the limit

		andi	t9,at,$07
		sll		t9,t9,$16
		and 	at,at,t0
		sll		at,at,$03
		or		t9,t9,at		;t9 has base YYYYXXXX

		lw		a0,$0008(a1)	
		lhu		v1,$0000(v0)	;get time stamp

		andi	at,t8,$1E
		sll		at,at,$01
		addu	t9,t9,at
		andi	at,t8,$20
		sll		at,at,$10
		addu	t9,t9,at
		andi	at,t8,$01
		sll		at,at,$14
		addu	t9,t9,at		; t9 now has src Y_X for the prim

		li		at,$00080002
		and		a0,a0,at
		or		t9,a0,t9

		beq		gp,v1,noLinkFixDub
		sw		t9,$0008(a1)	;write new YYYYXXXX

		sh		gp,$0000(v0)		;save timestamp
		
		sh		a1,$0000(sp)
		srl		at,a1,$10
		sb		at,$0002(sp)

		or		sp,a1,zero			;set last change to current one

noLinkFixDub

		addiu	a1,a1,$24
		addiu	v0,v0,$02
		srl		t8,t8,$08

		andi	at,t8,$C0
		srl		t9,at,$03
		srlv	at,a2,t9
		andi	at,at,$FF		;at has block# to use for this tile

		srlv	t9,s7,t9
		andi	t9,t9,$FF		;t9 has old block#

		beq		at,t9,noLinkFix2Dub
		andi	at,at,$3F			;64 is the limit

		andi	t9,at,$07
		sll		t9,t9,$16
		and  	at,at,t0
		sll		at,at,$03
		or		t9,t9,at		;t9 has base YYYYXXXX

		lw		a0,$0008(a1)	
		lhu		v1,$0000(v0)	;get time stamp

		andi	at,t8,$1E
		sll		at,at,$01
		addu	t9,t9,at
		andi	at,t8,$20
		sll		at,at,$10
		addu	t9,t9,at
		andi	at,t8,$01
		sll		at,at,$14
		addu	t9,t9,at		; t9 now has src Y_X for the prim

		li		at,$00080002
		and		a0,a0,at
		or		t9,a0,t9

		beq		gp,v1,noLinkFix2Dub
		sw		t9,$0008(a1)	;write new YYYYXXXX

		sh		gp,$0000(v0)		;save timestamp
		
		sh		a1,$0000(sp)
		srl		at,a1,$10
		sb		at,$0002(sp)

		or		sp,a1,zero			;set last change to current one

noLinkFix2Dub

		addiu	a1,a1,$24
		addiu	v0,v0,$02
		srl		t8,t8,$08

		andi	at,t8,$C0
		srl		t9,at,$03
		srlv	at,a2,t9
		andi	at,at,$FF		;at has block# to use for this tile

		srlv	t9,s7,t9
		andi	t9,t9,$FF		;t9 has old block#

		beq		at,t9,noLinkFix3Dub
		andi	at,at,$3F			;64 is the limit

		andi	t9,at,$07
		sll		t9,t9,$16
		and 	at,at,t0
		sll		at,at,$03
		or		t9,t9,at		;t9 has base YYYYXXXX

		lw		a0,$0008(a1)	
		lhu		v1,$0000(v0)	;get time stamp

		andi	at,t8,$1E
		sll		at,at,$01
		addu	t9,t9,at
		andi	at,t8,$20
		sll		at,at,$10
		addu	t9,t9,at
		andi	at,t8,$01
		sll		at,at,$14
		addu	t9,t9,at		; t9 now has src Y_X for the prim

		li		at,$00080002
		and		a0,a0,at
		or		t9,a0,t9

		beq		gp,v1,noLinkFix3Dub
		sw		t9,$0008(a1)	;write new YYYYXXXX

		sh		gp,$0000(v0)		;save timestamp
		
		sh		a1,$0000(sp)
		srl		at,a1,$10
		sb		at,$0002(sp)

		or		sp,a1,zero			;set last change to current one

noLinkFix3Dub

		addiu	a1,a1,$24
		addiu	v0,v0,$02
		srl		t8,t8,$08

		andi	at,t8,$C0
		srl		t9,at,$03
		srlv	at,a2,t9
		andi	at,at,$FF		;at has block# to use for this tile

		srlv	t9,s7,t9
		andi	t9,t9,$FF		;t9 has old block#

		beq		at,t9,noLinkFix4Dub
		andi	at,at,$3F			;64 is the limit

		andi	t9,at,$07
		sll		t9,t9,$16
		and 	at,at,t0
		sll		at,at,$03
		or		t9,t9,at		;t9 has base YYYYXXXX

		lw		a0,$0008(a1)	
		lhu		v1,$0000(v0)	;get time stamp

		andi	at,t8,$1E
		sll		at,at,$01
		addu	t9,t9,at
		andi	at,t8,$20
		sll		at,at,$10
		addu	t9,t9,at
		andi	at,t8,$01
		sll		at,at,$14
		addu	t9,t9,at		; t9 now has src Y_X for the prim

		li		at,$00080002
		and		a0,a0,at
		or		t9,a0,t9

		beq		gp,v1,noLinkFix4Dub
		sw		t9,$0008(a1)	;write new YYYYXXXX

		sh		gp,$0000(v0)		;save timestamp
		
		sh		a1,$0000(sp)
		srl		at,a1,$10
		sb		at,$0002(sp)

		or		sp,a1,zero			;set last change to current one

noLinkFix4Dub

		addiu	a3,a3,$04
		lw		t8,$0000(a3)
		addiu	a1,a1,$24
		andi	at,a3,$1F
		bnez	at,fixLoopDub
		addiu	v0,v0,$02

		or		s7,ra,zero
		li		at,33408
		addu	a1,a1,at
		addiu	a3,a3,$3E0
		lw		t8,$0000(a3)
		addiu	v0,v0,$7C0
		beqz	s5,fixLoopDub
		addiu	s5,s5,$01

		sw		sp,lastChange		; set the last changed to this one
		mflo	t0					; restore t0 from lo reg
		mfhi	a0
endCheckDouble
		li		s5,$01				; restore this
		j		blocksGood
		lui		s7,$8001

;------------------------------------------------------------------------
map9fix		;fixes and links BG tiles for mapper 9
; in: a0 = $01 for latch $FD, $02 for $FE
; in: a2 = blocks to use for that latch
;------------------------------------------------------------------------

		li		a3,$80020000	; a3 has address of latch select and (+$2000) tiles
		li		v0,$80010800	; v0 has addr for time stamps
		la		a1,bg1DMAlist	; a1 has addr of prims
		lbu		t8,$0000(a3)			; get latch infoz
		lhu		gp,renderTimeStamp		; get current time stamp
		lw		sp,lastChange			; get pointer to change list

fixLoop9
		bne		t8,a0,noFix9		; if this tile uses the latch in question
		nop

		lbu		t8,$2000(a3)			; load the tile #
		nop

		andi	at,t8,$C0
		srl		t9,at,$03
		srlv	at,a2,t9
		andi	at,at,$FF		;at has block# to use for this tile

		andi	t9,at,$07
		sll		t9,t9,$16
		andi	at,at,$38		; this would be what the block mask does
		sll		at,at,$03
		or		t9,t9,at		;t9 has base YYYYXXXX

		andi	at,t8,$1E
		sll		at,at,$01
		addu	t9,t9,at
		andi	at,t8,$20
		sll		at,at,$10
		addu	t9,t9,at
		andi	at,t8,$01
		sll		at,at,$14
		addu	t9,t9,at		; t9 now has src Y_X for the prim

		lw		t8,$0008(a1)
		li		at,$00080002
		and		t8,t8,at
		lhu		at,$0000(v0)	;get time stamp
		or		t9,t8,t9

		beq		gp,at,noFix9
		sw		t9,$0008(a1)	;write new YYYYXXXX

		sh		gp,$0000(v0)		;save timestamp
		
		sh		a1,$0000(sp)
		srl		at,a1,$10
		sb		at,$0002(sp)

		or		sp,a1,zero			;set last change to current one

noFix9

		addiu	a3,a3,$01
		lbu		t8,$0000(a3)
		addiu	a1,a1,$24
		addiu	v0,v0,$02
		
		andi	at,a3,$FFF
		subiu	at,at,$3C0
		bnez	at,fixLoop9
		nop

		sw		sp,lastChange		; set the last changed to this one

		jr		ra
		nop

;--------------------------------------------------
readPads
;	a0:which pad to read (0 for first, 1 to second)
;--------------------------------------------------

		li		t9,$0			;will contain btn status for NES to read

		sll		a0,a0,$1

		la		t8,pad_buf
		sll		at,a0,$4
		addu	t8,t8,at
		lw		a1,$0000(t8)
		lw		v0,padMasks

		andi	at,a1,$FF00			;if you have a dual shock controller...
		subiu	at,at,$7300
		bnez	at,notDualShock
		srl		a1,a1,$10

		lhu		t8,$0006(t8)			;read dirs from left analog
		nop

		andi	at,t8,$FF
		subiu	at,at,$40
		bgez	at,noDualShockLeft
		nop
		ori		t9,t9,$40
noDualShockLeft
		andi	at,t8,$FF
		subiu	at,at,$C0
		bltz	at,noDualShockRight
		nop
		ori		t9,t9,$80
noDualShockRight
		srl		at,t8,$08
		subiu	at,at,$40
		bgez	at,noDualShockUp
		nop
		ori		t9,t9,$10
noDualShockUp
		srl		at,t8,$08
		subiu	at,at,$C0
		bltz	at,notDualShock
		nop
		ori		t9,t9,$20

notDualShock

		xori	a1,a1,$FFFF
		andi	at,v0,$FFFF
		and		at,at,a1
		beqz	at,Aup
		nop

		la		t8,turboCounter
		addu	t8,t8,a0
		lbu		t8,$0000(t8)
		nop
		bnez	t8,AnoTrig
		nop

		la		t8,turboMax
		addu	t8,t8,a0
		lbu		t8,$0000(t8)
		ori		t9,t9,$01
		la		at,turboCounter
		addu	at,at,a0
		sb		t8,$0000(at)
		j		turboAfterA
		nop


AnoTrig
		subiu	t8,t8,$01
		la		at,turboCounter
		addu	at,at,a0
		sb		t8,$0000(at)
		j		turboAfterA
		nop

Aup
		la		at,turboCounter
		addu	at,at,a0
		sb		zero,$0000(at)

turboAfterA

		srl		at,v0,$10
		and		at,at,a1
		beqz	at,Bup
		nop

		la		t8,turboCounter
		addu	t8,t8,a0
		lbu		t8,$0001(t8)
		nop
		bnez	t8,BnoTrig
		nop

		la		t8,turboMax
		addu	t8,t8,a0
		lbu		t8,$0001(t8)
		ori		t9,t9,$02
		la		at,turboCounter
		addu	at,at,a0
		sb		t8,$0001(at)
		j		turboAfterB
		nop


BnoTrig
		subiu	t8,t8,$01
		la		at,turboCounter
		addu	at,at,a0
		sb		t8,$0001(at)
		j		turboAfterB
		nop

Bup
		la		at,turboCounter
		addu	at,at,a0
		sb		zero,$0001(at)

turboAfterB

		lw		v1,padMasks+16		;load the masks for the turbo toggle buttons
		nop
		srl		at,v1,$10
		and		at,a1,at
		beqz	at,noIncB
		li		v0,$00

		la		at,turboIncDown
		addu	at,at,a0
		lbu		at,$0001(at)
		nop
		bnez	at,noIncB
		li		v0,$01

		la		at,turboMax
		addu	at,at,a0
		lbu		t8,$0001(at)
		nop
		addiu	t8,t8,$02
		andi	t8,t8,$07
		sb		t8,$0001(at)

noIncB

		la		at,turboIncDown
		addu	at,at,a0
		sb		v0,$0001(at)

		andi	at,v1,$FFFF
		and		at,a1,at
		beqz	at,noIncA
		li		v0,$00

		la		at,turboIncDown
		addu	at,at,a0
		lbu		at,$0000(at)
		nop
		bnez	at,noIncA
		li		v0,$01

		la		at,turboMax
		addu	at,at,a0
		lbu		t8,$0000(at)
		nop
		addiu	t8,t8,$02
		andi	t8,t8,$07
		sb		t8,$0000(at)

noIncA

		la		at,turboIncDown
		addu	at,at,a0
		sb		v0,$0000(at)

		lw		v0,padMasks+4
		lw		v1,padMasks+8
		lw		t8,padMasks+12

		andi	at,v0,$FFFF
		and		at,at,a1
		sltu	at,zero,at
		sll		at,at,$02
		or		t9,t9,at

		srl		at,v0,$10
		and		at,at,a1
		sltu	at,zero,at
		sll		at,at,$03
		or		t9,t9,at

		andi	at,v1,$FFFF
		and		at,at,a1
		sltu	at,zero,at
		sll		at,at,$04
		or		t9,t9,at

		srl		at,v1,$10
		and		at,at,a1
		sltu	at,zero,at
		sll		at,at,$05
		or		t9,t9,at

		andi	at,t8,$FFFF
		and		at,at,a1
		sltu	at,zero,at
		sll		at,at,$06
		or		t9,t9,at

		srl		at,t8,$10
		and		at,at,a1
		sltu	at,zero,at
		sll		at,at,$07
		or		t9,t9,at

		lui		at,$01
		srl		a0,a0,$01
		sllv	at,at,a0
		or		t9,t9,at

		la		at,pad1_data
		sll		a0,a0,$02
		addu	at,at,a0
		sw		t9,$0000(at)
		jr		ra 
		nop

;----------------------------------------------
bankSwitch
;	swaps 8k banks and does game genie
;	a0 = target addr space (4=8000, 5=A000 ...)
;	a1 = 8k bank # in ROM
;----------------------------------------------

		lw		a3,prgMask		;load mask
		nop
		and		a1,a1,a3		;mask value

		la		a2,rom_img+16
		sll		at,a1,$0D
		addu	a2,a2,at

		sra		a3,a3,$10
		addiu	at,a3,$01
		bnez	at,doGG
		nop

afterGG
		la		a3,bankptrlo
		sll		at,a0,$02
		addu	a3,a3,at

		sll		at,a0,$0D
		subu	at,a2,at
		sw		at,$0000(a3)

		srl		a2,s4,$0D
		subu	a2,a2,a0
		bnez	a2,isNotCurrent		;if swaping bank you're on...
		addiu	a0,a0,$01

		or		fp,at,zero		;correct pointer

isNotCurrent
		jr		ra 
		addiu	a1,a1,$01

;---
doGG	;jumps here to do game genie changes, a2 has base addr of bank
;---
	
		mthi	ra
		andi	at,a0,$03
		srl		ra,a3,$0D
		andi	ra,ra,$03
		bne		at,ra,doGGcode2
		nop

		andi	at,a3,$8000
		bnez	at,ggfirst8
		andi	a3,a3,$1FFF

		lbu		at,GGdecoded+6
		addu	a3,a3,a2
		j		doGGcode2
		sb		at,$0000(a3)

ggfirst8

		lhu		at,GGdecoded+6
		addu	a3,a3,a2
		lbu		ra,$0000(a3)
		srl		s5,at,$08
		bne		s5,ra,doGGcode2
		nop

		sb		at,$0000(a3)

doGGcode2

		lw		a3,GGdecoded+2
		andi	at,a0,$03
		addiu	ra,a3,$01
		andi	ra,ra,$FFFF
		beqz	ra,doGGcode4
		srl		ra,a3,$0D
		andi	ra,ra,$03
		bne		at,ra,doGGcode3
		nop

		andi	at,a3,$8000
		bnez	at,ggsecond8
		nop

		lbu		at,GGdecoded+8
		andi	s5,a3,$1FFF
		addu	s5,s5,a2
		j		doGGcode3
		sb		at,$0000(s5)

ggsecond8
		
		lhu		at,GGdecoded+8
		andi	s5,a3,$1FFF
		addu	s5,s5,a2
		lbu		ra,$0000(s5)
		srl		k0,at,$08
		bne		k0,ra,doGGcode3
		nop

		sb		at,$0000(s5)

doGGcode3
		
		srl		a3,a3,$10
		andi	at,a0,$03
		addiu	ra,a3,$01
		andi	ra,ra,$FFFF
		beqz	ra,doGGcode4
		srl		ra,a3,$0D
		andi	ra,ra,$03
		bne		at,ra,doGGcode4
		nop

		andi	at,a3,$8000
		bnez	at,ggthird8
		andi	a3,a3,$1FFF

		lbu		at,GGdecoded+10
		addu	a3,a3,a2
		j		doGGcode4
		sb		at,$0000(a3)

ggthird8
		
		lhu		at,GGdecoded+10
		addu	a3,a3,a2
		lbu		ra,$0000(a3)
		srl		s5,at,$08
		bne		s5,ra,doGGcode4
		nop

		sb		at,$0000(a3)

doGGcode4
		mfhi	ra
		j		afterGG
		li		s5,$01

;
; not sure what this was for
; looks like it might have been the beginnings of the event based rendering system
; i started adding after v1.3.2 but never was able to finish. i'm putting this back into
; the source code before i release it because i'm trying to get it to compile into a
; byte for byte copy of the 1.3.2 binary that i released.
;
		li		v0,_unk01
		li		v1,$08
unkLoop01
		lw		a2,$0000(v0)
		addiu	v0,v0,$08
		slt		at,a2,a0
		bnez	at,unkLoop01
		subiu	v1,v1,$01
		
		subiu	a3,v1,$01

align 4
;--------------------
volatile_vars_begin
;--------------------

GGselPos			db	0
GGentryPos			db	0

align 4
GGcode1				dcb 8,$FF
GGcode2				dcb 8,$FF
GGcode3				dcb 8,$FF

align 4
prgMask				db	$00, $00	;\ must stay together
GGdecoded			dcb	12,$FF		;/

MAX_DMC_SAMPLES = 16
DMC_START_VOICE = 8

align 4
DMCsampleAddrs	dw	$0,$0,$0,$0, $0,$0,$0,$0, $0,$0,$0,$0, $0,$0,$0,$0
DMCsndbufAddrs	dw	$0,$0,$0,$0, $0,$0,$0,$0, $0,$0,$0,$0, $0,$0,$0,$0
spuBuffAddr		dw	$20000

align 4
sq1LastParams	dw	$0
sq2LastParams	dw	$0

sq1Enabled		db 0
sq1Timer		db 0
sq1ValidFreq	db 0
sq1EnvLooper	db 0

sq2Enabled		db 0
sq2Timer		db 0
sq2ValidFreq	db 0
sq2EnvLooper	db 0

triEnabled		db 0
triTimer		db 0
triValidFreq	db 0
triLinCtr		db 0

noiseEnabled	db 0
noiseTimer		db 0
noiseValidFreq	db 0
noiseEnvLooper	db 0

sq1LastChan		db	$0
sq2LastChan		db	$0
sq1EnvCnt		db	$1
sq2EnvCnt		db	$1
noiseEnvCnt		db	$1
sq1BendCtr		db	$1
sq2BendCtr		db	$1

align 2
sq1WantedVol	dh	0
sq2WantedVol	dh	0
noiseWantedVol	dh	0

triLinMode		db	0

align 4
blockYX			dw	$00000000, $00400000, $00800000, $00C00000, $01000000, $01400000, $01800000, $01C00000
lastChange		dw	changeHead

align 4
mapReg0		db	$C
mapReg1		db	$0
mapReg2		db	$0
mapReg3		db	$0
map1tmp		db	$0
map1pos		db	$0			   ; v---v--> two extra for mapper 69
map1mirrors	db	$0, $F, $A, $C, $0, $F
map1lastaddr db $0
map5chrMode	db	$0
map5chrSingleVals	db	0,1,2,3,4,5,6,7
map5chrDoubleVals	db	0,1,2,3

align 2
map4prevs	dh	$FF00, $FF00, $FF00, $FF00, $FF00, $FF00, $0600, $0701
renderMarkAddr	dh $0000
sprHitLine	db	$FF
sprType		db	$0
sprAddr		db	$0
clips		db	$0

align 2
map4irq		dh	$0
map4latch	db	$0
map4irqOn	db	$0

sprOn				db	$00
lastBGstatus		db	$00
needToRender		db $0
renderMarkLine		db	$0
renderMarkXoff		db	$0
renderMarkMirror	db $A

align 2
renderTimeStamp		dh	$8000
bgRectTime			dh	$0

align 4
dirtyPat0			dw	$0
dirtyPat1			dw	$0
visibleScreenPos	dw	$01000200
mirrorSel			dw	$0
fineX				dw	$0

align 4
dirty0tile			dcb 32,0			;per tile dirty bits
dirty1tile			dcb	32,0

wantLo2006			db	0,0,0,0			;0 for align
backColor			dw	$60000800
pad_buf				dcb 32,0    ; pad info for player 1
pad_buf2			dcb 32,0   ; pad info for player 2
pad1_data			dw	0
pad2_data			dw	0
pad1_nes			dw	0
pad2_nes			dw	0

turboCounter		db	0,0,0,0
turboMax			db	0,0,0,0
turboIncDown		db	0,0,0,0

sprOnOffRecord dcb 33, 0

align 4
soundRegs	dcb	$80,0

align 2
oldkeys	dh $FFFF

align 4
write50map	dw justwrite50
write51map	dw justwrite50
write52map	dw justwrite50
write80map	dw map0write
writeA0map	dw map0write
writeC0map	dw map0write
writeE0map	dw map0write
write90map	dw map0write
writeB0map	dw map0write
writeD0map	dw map0write
writeF0map	dw map0write

buffs	  dcb	128,$0		;half words for the block # in each slot
; 8 pointers to where the pattern table info is coming from:
patBlocks dw	$80020000,$80020400,$80020800,$80020C00,$80021000,$80021400,$80021800,$80021C00

PPUWrite	dw	PPUWritePat,PPUWritePat,PPUWriteName,PPUWritePal

bgRect			dw	$04FFFFFF
				dw	$E6000000
				dw	$60000800
				dw	$01000200
				dw	$00F00100

spriteHead		db spriteDMAlist, spriteDMAlist>>8, spriteDMAlist>>16, $03
				dw	$E5080200
				dw	$E3040200		;clipping for left 8 and so no overflow on right
				dw	$E407FFFF


changeHead		dw	$05FFFFFF
				dw	$E1000420		;set to the right semi trans mode
				dw	$E3000000		;no clipping so that trans rects can be drawn
				dw	$E407FFFF
				dw	$E5000000
				dw	$E6000000
			
NT2screen		dw	$0CFFFFFF
				dw	$E3000000		;set clipping for don't show BG in left 8 pixels
				dw	$E6000001		;set the masks as you draw
				dw	$E1000400		;tex page for first NT
				dw	$64808080			;sprite
				dw	$00000000			;Y_X
				dw	$00200000			;clut:u_v
				dw	$00000000			;H_W
				dw	$E1000400		;tex page for second NT
				dw	$64808080			;sprite
				dw	$00000000			;Y_X
				dw	$00200000			;clut:u_v
				dw	$00000000			;H_W

				;dw	$74808080
				;dw	$00800080		; do something like this to make
				;dw	$00210000		; mid frame palette updates work?

align 4
;--------------------
volatile_vars_end
;--------------------

key_counters	dcb	$20,0

cd_num_args
	db	$00,$00,$03,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00
	db	$00,$02,$01,$00,$00,$00
	db	$01,$00,$01,$00,$00,$00
	db	$00

cd_stat_bytes	db	2,0,0
cd_mode			db	0
cd_pos			db	0,0,0,0
cd_loc			db	0,0,0,0
cdResults		db	0,0,0,0,0,0,0,0

align 4
menu_RomSelect
dw	$00000010,	romSelect_up
dw	$00000040,	romSelect_down
dw	$00000080,	romSelect_left
dw	$00000020,	romSelect_right
dw	$00000200,	romSelect_r2
dw	$00000100,	romSelect_l2
dw	$00000800,	romSelect_r1
dw	$00000400,	romSelect_l1
dw	$04000800,	romSelect_midPage
dw	$08000400,	romSelect_midPage
dw	$00008000,	romSelect_sq
dw	$00004000,	romSelect_x
dw	$00002000,	romSelect_o
dw	$00001000,	romSelect_tri
dw	$00000008,	romSelect_start
;dw	$00000001,	romSelect_colors
dw	$00000000

TOTAL_NUM_OPTIONS = 4

align 4
menu_Options
dw	$00000010,	options_up
dw	$00000040,	options_down
dw	$00000008,	options_start
dw	$00000000

align 4
menu_Save
dw	$00000010,	save_up
dw	$00000040,	save_down
dw	$00000008,	save_start
dw	$00000000

align 4
menu_ScreenPos
dw	$00000010,	screen_up
dw	$00000040,	screen_down
dw	$00000080,	screen_left
dw	$00000020,	screen_right
dw	$00000008,	screen_start
dw	$00000000

align 4
menu_GameGenie
dw	$00000010,	gg_up
dw	$00000040,	gg_down
dw	$00000080,	gg_left
dw	$00000020,	gg_right
dw	$00000008,	gg_start
dw	$00004000,	gg_addLetter
dw	$00008000,	gg_delLetter
dw	$00000000

optionsJumpTable
dw	optionGameGenie, optionButtonConfig, optionScreenAdjust, optionReturn

romMenuSelIndex		db	0
optionsSelPos		db	0
saveSelPos			db	0

GGchars				db	"APZLGITYEOXUKSVN"

bitIOtmpVal			db	0
bitIOcounter		db	0

align 4
spuTargetAddr	dw	$0
spuDMAcallback	dw	$0

align 4

gpuVrange	dw	$07040010
gpuHrange	dw	$06C4E24E

BLOCKS			equ $1808
SRAMchanged		equ $1806
PPULatch		equ	$1807

sprRAM			equ $1f800000
sprOnOffData	equ	$1f800100
bankptrlo		equ $1f800200
bankptr			equ $1f800210			;4 pointers to 8000 A000 C000 and E000
scanLine		equ	$1f800220
nextScanJump	equ	$1f800224
sprFunc			equ	$1f800228
buffNext_incAmt	equ	$1f80022C
mapHsyncFunc	equ	$1f800230
_unk01			equ	$1f800234

vSyncCount		dw	$0
vromaddr		dw	$0

SRAMloaded	db 0
blockMask	db 0

chrMask		db	$00

align 2
; NES button	 A	   B	 SEL   START UP    DOWN  LEFT  RIGHT
padMasks	dh	$4000,$8000,$0001,$0008,$0010,$0040,$0080,$0020,$0000,$0000 ;$2000,$1000
; PSX button     X     Sqr   SEL   START UP    DOWN  LEFT  RIGHT TB_A  TB_B

align 2
triIsOn		db	1
triIsLo		db	1

align 4
soundQuarterEventHandle	dw	$0
quarterCount dw 0

align 4
map9_fd_sprites		dw	0
map9_fe_sprites		dw	0
map9_fd_bg			dw	$03020100
map9_fe_bg			dw	$03020100

xlatTime	db	$05,$7F,$0A,$01,$14,$02,$28,$03
			db	$50,$04,$1E,$05,$07,$06,$0E,$07
			db	$06,$08,$0C,$09,$18,$0A,$30,$0B
			db	$60,$0C,$24,$0D,$08,$0E,$10,$0F

align 2
dmcFreqs	dh	$0184, $01B5, $01E8, $0207, $0244, $028D, $02DE, $0308
			dh	$0369, $040D, $0491, $0511, $061E, $07A0, $0901, $0C01

noiseFreqs	db	63,62,61,60,57,55,53,52,50,49,46,45,42,41,37,36

NOISE93_BASE	=	$14D0
noise93offsets	dw	$0010, $0390, $0710, $0A90, $0E10, $0F70, $12F0, $2550
				dw	$3C50, $5950, $6B90, $A210, $B450, $CFB0, $F410, $108F0

; used to translate 1 bit sprite on/off info into a vertical offset (low nib) and height (high nib) for sprite prims
xlatSprInfo
db $00, $10, $11, $20, $12, $30, $21, $30, $13, $40, $31, $40, $22, $40, $31, $40
db $14, $50, $41, $50, $32, $50, $41, $50, $23, $50, $41, $50, $32, $50, $41, $50
db $15, $60, $51, $60, $42, $60, $51, $60, $33, $60, $51, $60, $42, $60, $51, $60
db $24, $60, $51, $60, $42, $60, $51, $60, $33, $60, $51, $60, $42, $60, $51, $60
db $16, $70, $61, $70, $52, $70, $61, $70, $43, $70, $61, $70, $52, $70, $61, $70
db $34, $70, $61, $70, $52, $70, $61, $70, $43, $70, $61, $70, $52, $70, $61, $70
db $25, $70, $61, $70, $52, $70, $61, $70, $43, $70, $61, $70, $52, $70, $61, $70
db $34, $70, $61, $70, $52, $70, $61, $70, $43, $70, $61, $70, $52, $70, $61, $70
db $17, $80, $71, $80, $62, $80, $71, $80, $53, $80, $71, $80, $62, $80, $71, $80
db $44, $80, $71, $80, $62, $80, $71, $80, $53, $80, $71, $80, $62, $80, $71, $80
db $35, $80, $71, $80, $62, $80, $71, $80, $53, $80, $71, $80, $62, $80, $71, $80
db $44, $80, $71, $80, $62, $80, $71, $80, $53, $80, $71, $80, $62, $80, $71, $80
db $26, $80, $71, $80, $62, $80, $71, $80, $53, $80, $71, $80, $62, $80, $71, $80
db $44, $80, $71, $80, $62, $80, $71, $80, $53, $80, $71, $80, $62, $80, $71, $80
db $35, $80, $71, $80, $62, $80, $71, $80, $53, $80, $71, $80, $62, $80, $71, $80
db $44, $80, $71, $80, $62, $80, $71, $80, $53, $80, $71, $80, $62, $80, $71, $80

copy1		db $03,$54,$8E,$CB,$A4,$6E,$B3,$E9,$0F,$5B,$DA,$DE,$D3,$8A,$05,$A4,$08,$55,$E0,$9D,$AF,$6E,$EB,$A4,$CA,$49,$97,$9D,$91,$4B,$C3,$B7,$7C ;"an NES emulator for PSX (c) 2003"
copy2		db $06,$8E,$9D,$7F,$3B,$B3,$A4,$04,$5F,$8E,$BE,$CB,$87,$F4,$F2,$C2,$28,$DA,$EC,$CC,$8C,$08,$ED,$15,$5A,$8E,$9D,$7F,$3B,$B3,$A4,$C2,$5E ;"       by Allan Blomquist       "
copy3		db $4A,$15,$70,$59,$F7,$55,$25,$E8,$77,$5E,$B7,$A1,$4B,$2C,$F3,$2D,$4A,$43,$95,$8C,$F7,$82,$E2,$F6,$5D,$23,$82,$59,$F7,$2C,$D1,$E8,$38 ;"     It Might Be NES v1.3.2     "
copy4		db $18,$9E,$9D,$38,$AF,$F1,$7B,$18,$5E,$BE,$AC,$30,$AE,$36,$28,$12,$6B,$6A,$7B,$21,$81,$16,$7F,$0A,$6A,$AF,$55,$30,$AA,$35,$28,$C9,$57 ;" This software is FREEware and  "
copy5		db $29,$D7,$0F,$73,$13,$50,$47,$A7,$5D,$D7,$2E,$97,$E5,$A3,$68,$C4,$6D,$D7,$35,$A0,$E5,$91,$67,$D1,$29,$1D,$3B,$A4,$32,$50,$19,$78,$A8 ;"  CAN NOT be sold in any form   "
copy6		db $EC,$52,$E5,$50,$5E,$C5,$6A,$20,$38,$6C,$E5,$A0,$5E,$C6,$6C,$18,$3C,$72,$2E,$9E,$5A,$C5,$6E,$E5,$2F,$A1,$32,$50,$19,$78,$29,$D7,$49 ;"    email: pencap@iname.com     "
copy7		db $52,$7B,$F8,$19,$6E,$76,$75,$33,$50,$82,$BF,$DF,$29,$BF,$7A,$21,$4A,$77,$F8,$DE,$61,$B7,$7A,$24,$3E,$73,$F8,$15,$28,$B9,$6E,$EE,$41 ;"visit http://imbnes.gamebase.ca/"

saveMsg1	db $07,$C0,$D9,$AC,$4B,$63,$B6,$86,$5D,$D5,$E0,$BC,$9E,$13,$AB,$82,$54,$D1,$91,$BC,$9E,$58,$A8,$41,$3A,$BE,$B2,$94,$59,$21,$72,$41,$DF ;" The previous game used SRAM... "
saveMsg2	db $B4,$A2,$C6,$0E,$D1,$BE,$95,$00,$B4,$D5,$F8,$2F,$CB,$7D,$93,$0A,$B4,$EF,$0B,$5B,$ED,$CF,$98,$BB,$F7,$E3,$18,$52,$9E,$7D,$3F,$BB,$65 ;"    Save SRAM to memory card    "
saveMsg3	db $3A,$B5,$B0,$DA,$F6,$2E,$DD,$00,$5E,$04,$B0,$28,$45,$82,$DD,$53,$7B,$0B,$F5,$DA,$29,$60,$FE,$2D,$3A,$B5,$B0,$DA,$F6,$2E,$DD,$00,$20 ;"        Do not save SRAM        "
saveMsg4	db $47,$0B,$B8,$A6,$93,$50,$E8,$A6,$47,$3E,$C6,$82,$74,$0B,$DA,$B3,$96,$58,$94,$AE,$8C,$58,$E3,$B3,$A0,$0B,$D7,$A2,$99,$4F,$94,$61,$BF ;"  Delete SRAM from memory card  "
saveMsg5	db $3A,$B5,$B0,$DA,$F6,$2E,$DD,$00,$3A,$E1,$FF,$1B,$3A,$77,$2B,$47,$3A,$E8,$E2,$FB,$23,$3C,$EB,$0E,$3A,$B5,$B0,$DA,$F6,$2E,$DD,$00,$20 ;"         Loading SRAM...        "
saveMsg6	db $A6,$CE,$1E,$7E,$3D,$BF,$BC,$B2,$A6,$CE,$1E,$B1,$7E,$15,$05,$00,$ED,$DC,$2C,$8C,$3D,$BF,$BC,$B2,$A6,$CE,$1E,$7E,$3D,$BF,$BC,$B2,$6E ;"           Saving...            "
saveMsg7	db $54,$E1,$48,$09,$98,$69,$57,$EB,$54,$E1,$6C,$4E,$E4,$AE,$AB,$34,$A2,$28,$56,$17,$A6,$69,$57,$EB,$54,$E1,$48,$09,$98,$69,$57,$EB,$35 ;"          Deleting...           "

options1	db $8F,$9B,$73,$23,$C3,$04,$82,$85,$8F,$9B,$73,$4A,$04,$51,$C7,$85,$B6,$E0,$C1,$6C,$08,$04,$82,$85,$8F,$9B,$73,$23,$C3,$04,$82,$85,$9B ;"           Game Genie           "
options2	db $58,$E9,$58,$E9,$58,$E9,$58,$E9,$58,$0B,$AD,$3D,$AC,$38,$A6,$E9,$7B,$38,$A6,$2F,$A1,$30,$58,$E9,$58,$E9,$58,$E9,$58,$E9,$58,$E9,$37 ;"         Button Config          "
options3	db $2D,$DF,$FC,$32,$A5,$D0,$1A,$76,$2D,$12,$3F,$84,$EA,$15,$68,$76,$4E,$23,$46,$87,$F8,$24,$1A,$76,$2D,$DF,$FC,$32,$A5,$D0,$1A,$76,$AA ;"         Screen Adjust          "
optionsEnd	db $4E,$1D,$80,$39,$B7,$AC,$D2,$08,$8F,$60,$CB,$39,$0B,$FB,$D2,$0D,$8F,$6A,$C5,$39,$E4,$F1,$20,$3B,$4E,$1D,$80,$39,$B7,$AC,$D2,$E6,$3A ;"       Back to Game Menu        "

screenPosMsg1	db $59,$F7,$2C,$01,$37,$9D,$5E,$C4,$A2,$46,$7A,$D1,$3B,$8D,$67,$B5,$9E,$45,$2C,$28,$31,$9E,$5D,$70,$7D,$04,$7C,$12,$2C,$4A,$15,$70,$B0 ;"   Position screen with D-pad   "
screenPosMsg2	db $1E,$7E,$3D,$EF,$0E,$F7,$F9,$21,$1E,$B1,$71,$E0,$EE,$E6,$A6,$25,$66,$C3,$8B,$BF,$02,$FB,$F4,$17,$71,$C6,$82,$03,$BC,$B2,$A6,$CE,$52 ;"   Press START when finished    "

btnCfgA			db $CF,$1C,$A2,$77,$14,$6F,$C5,$25,$FD,$41,$A5,$25,$F0,$2A,$80,$33,$CF,$1C,$72,$25,$CF,$1C,$72,$25,$CF,$1C,$72,$25,$CF,$1C,$72,$25,$FB ;"  Press NES A...                "
btnCfgB			db $7B,$33,$D3,$16,$47,$D9,$E0,$9F,$A9,$58,$D6,$C4,$24,$94,$9B,$AD,$7B,$33,$A3,$C4,$02,$86,$8D,$9F,$7B,$33,$A3,$C4,$02,$86,$8D,$9F,$81 ;"  Press NES B...                "
btnCfgSELECT	db $D0,$1A,$A6,$7F,$24,$4F,$85,$A5,$FE,$3F,$A9,$2D,$12,$21,$5E,$CA,$F3,$4E,$84,$3B,$ED,$FC,$32,$A5,$D0,$1A,$76,$2D,$DF,$FC,$32,$A5,$7B ;"  Press NES SELECT...           "
btnCfgSTART		db $7B,$33,$D3,$16,$47,$D9,$E0,$9F,$A9,$58,$D6,$C4,$35,$BA,$AE,$D1,$AF,$41,$B1,$D2,$02,$86,$8D,$9F,$7B,$33,$A3,$C4,$02,$86,$8D,$9F,$81 ;"  Press NES START...            "
btnCfgUP		db $45,$0F,$CC,$C3,$6C,$1E,$67,$62,$73,$34,$CF,$71,$5C,$FB,$22,$70,$53,$0F,$9C,$71,$27,$CB,$14,$62,$45,$0F,$9C,$71,$27,$CB,$14,$62,$BE ;"  Press NES UP...               "
btnCfgDOWN		db $35,$AF,$0C,$44,$6B,$20,$73,$7A,$63,$D4,$0F,$F2,$4A,$FC,$57,$A8,$43,$BD,$EA,$F2,$26,$CD,$20,$7A,$35,$AF,$DC,$F2,$26,$CD,$20,$7A,$A6 ;"  Press NES DOWN...             "
btnCfgLEFT		db $39,$B7,$DC,$24,$2B,$A1,$70,$80,$67,$DC,$DF,$D2,$12,$73,$43,$B4,$47,$C5,$BA,$D2,$E6,$4E,$1D,$80,$39,$B7,$AC,$D2,$E6,$4E,$1D,$80,$A0 ;"  Press NES LEFT...             "
btnCfgRIGHT		db $93,$63,$73,$55,$C9,$D4,$DA,$8B,$C1,$88,$76,$03,$B6,$AA,$AE,$B3,$C7,$71,$51,$11,$84,$81,$87,$8B,$93,$63,$43,$03,$84,$81,$87,$8B,$95 ;"  Press NES RIGHT...            "
btnCfgTurboA	db $86,$8D,$CF,$CD,$78,$F6,$17,$02,$BA,$E2,$F1,$BD,$82,$A3,$F8,$51,$CD,$D4,$EB,$C0,$33,$C4,$D2,$10,$94,$8D,$9F,$7B,$33,$A3,$C4,$02,$1E ;"  Press Turbo Toggle A...       "
btnCfgTurboB	db $C4,$02,$B6,$DF,$E4,$CE,$86,$A3,$F8,$57,$D8,$CF,$EE,$7B,$67,$F2,$0B,$49,$D2,$D2,$9F,$9D,$41,$B1,$D2,$02,$86,$8D,$9F,$7B,$33,$A3,$7D ;"  Press Turbo Toggle B...       "

GGline1			db $78,$29,$D7,$EC,$52,$06,$50,$19,$9D,$29,$D7,$1C,$52,$E5,$7F,$19,$78,$63,$D7,$EC,$8A,$E5,$50,$45,$78,$29,$0C,$EC,$52,$E5,$50,$19,$07 ;"     A  E  P  O  Z  X  L  U     "
GGline2			db $6A,$55,$EF,$5C,$F1,$4F,$C9,$18,$95,$55,$EF,$85,$F1,$28,$FC,$18,$6A,$89,$EF,$5C,$27,$28,$C9,$51,$6A,$55,$1D,$5C,$F1,$28,$C9,$18,$08 ;"     G  K  I  S  T  V  Y  N     "
GGcode			db $BD,$C0,$BA,$B6,$AE,$DE,$FE,$3E,$FC,$C0,$F9,$B6,$ED,$DE,$3D,$3E,$FC,$C0,$F9,$B6,$ED,$DE,$3D,$3E,$BD,$C0,$BA,$B6,$AE,$DE,$FE,$3E,$E2 ;"        _ _ _ _ _ _ _ _         "


; from the .NES header...
prgCount	db	0
chrCount	db	0

align 4
pal		incbin	enginet.pal
; GG codes for SMB coins->BG color are:
;	AEGEXP
;	ZIAEOX
;	YAAEXZ

align 4
font	incbin	font2.bin

cdfilename_rombank	db	"ROMBANK.BIN",59,"1",0
cdfilename_saveicon	db	"SAVEICON.BMP",59,"1",0
cdfilename_nes		db	"NES.EXE",59,"1",0

align 4
cdfilepos_rombank	dw	$0
cdfilepos_saveicon	dw	$0
cdfilepos_nes		dw	$0

txtEnterCode	db	$23,$89,$F9,$F5,$F4,$06,$3E,$ED,$00,$3A,$B5,$B0,$DA,$26,$80,$22,$53,$8D,$B5,$0F,$DA,$3C,$7D,$2F,$00,$89,$05,$04,$23,$45,$7C,$30,$43 ;"Code:000     Press  for options"

fname	db	"%08x",13,10,0
pfmsg	db	"Got CD Interupt %2x",13,10,0

align 4
		db  0,0,0
buname	db	"bu00:12345678901234567890",0

textTmp			db "                                ",0   ;will need to NULL term this

align 4
setjmpbuf	dcb	$30,0
gamenum	dh	INIT_GAME_NUM
maxgamenum	dh	$0000
curpage	dh	$0000
maxpage	dh	$0000

align 4
icon incbin saveicon.bmp

endofprog

blank	dcb	$80040000-endofprog, 0

include addr_op_out.asm
include nesrun.asm
include writes.asm

varCopySpace dcb volatile_vars_end-volatile_vars_begin, 0

endofrun

blank2	dcb	$80050000-endofrun, 0

include newwrites.asm

read2kjump	dw	read2000,read2001,read2002,read2003,read2004,read2005,read2006,read2007
write2kjump	dw	write2000,write2001,write2002,write2003,write2004,write2005,write2006,write2007

read4kjump	dw	read4000,read4001,read4002,read4003,read4004,read4005,read4006,read4007
			dw	read4008,read4009,read400A,read400B,read400C,read400D,read400E,read400F
			dw	read4010,read4011,read4012,read4013,read4014,read4015,read4016,read4017
			dw	justread4k,justread4k,justread4k,justread4k,justread4k,justread4k,justread4k,justread4k

write4kjump	dw	write4000,write4001,write4002,write4003,write4004,write4005,write4006,write4007
			dw	write4008,write4009,write400A,write400B,write400C,write400D,write400E,write400F
			dw	write4010,write4011,write4012,write4013,write4014,write4015,write4016,write4017
			dw	justwrite4k,justwrite4k,justwrite4k,justwrite4k,justwrite4k,justwrite4k,justwrite4k,justwrite4k

align 4
include dma_list.asm

align 4
saveRA dw 0
saveA0 dw 0
saveA1 dw 0
saveA2 dw 0
saveA3 dw 0
saveT0 dw 0
saveT1 dw 0
saveT2 dw 0
saveT3 dw 0
saveT4 dw 0
saveT5 dw 0
saveT6 dw 0
saveT7 dw 0
saveT8 dw 0
saveT9 dw 0
saveAT dw 0
saveSP dw 0
saveS0 dw 0
saveS1 dw 0
saveFP dw 0

copyrightStartTime	dw	$0

vromTmp	  dcb	$2800,0

align 4
rom_img

align 4
wav_noise93	incbin	noise93.vag

SQU_BASE	=	$1AF90

align 4
wav_squ		incbin	squ00LO.vag		; \
			incbin	squ00HI.vag
			incbin	squ01LO.vag
			incbin	squ01HI.vag		;  size is $980 alltogether
			incbin	squ10LO.vag
			incbin	squ10HI.vag
			incbin	squ11LO.vag
			incbin	squ11HI.vag		; /
				
TRI_BASE	=	$1010
TRI_HI_OFFSET =	$420

align 4
wav_tri		incbin	triLO.vag
			incbin	triHI.vag

end_of_file

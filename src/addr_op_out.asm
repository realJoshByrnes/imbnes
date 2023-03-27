
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

; There are 154 valid opcodes (out of 256 total) on the NES.

ADDR_OR_READ	= $0A00
ADDR_OR_WRITE	= $0B00

;---------------------------------------------
; opcode=$00  ins=BRK  addr=implied
;---------------------------------------------
opcode00

		addiu	s4,s4,$02

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

		j		postOp
		andi	s3,s3,$FF

;---------------------------------------------
; opcode=$01  ins=ORA  addr=indirect X
;---------------------------------------------
endop00
dcb $80040080-endop00,0
opcode01

		addu	t8,t8,s1
		andi	t8,t8,$FF
		or		t8,t8,s7
		lbu		t9,$0001(t8)
		lbu		t8,$0000(t8)
		addu	s4,s4,$02
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$48

		or		s0,s0,a1
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$02  -my own fake "LDA $2002" opcode
;---------------------------------------------
endop01
dcb $80040100-endop01,0
opcode02
		addiu	s4,s4,$03
		lbu		s0,$2002(s7)
		subiu	t7,t7,$30
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;sign
		andi	t9,s0,$3F		;reset the vblank and sprite hit flags
		sb		zero,wantLo2006 ;reset the 2005/2006 toggle
		j		postOp
		sb		t9,$2002(s7)

;---------------------------------------------
; opcode=$03  -my own fake "LDX $2002" opcode
;---------------------------------------------
endop02
dcb $80040180-endop02,0
opcode03
		addiu	s4,s4,$03
		lbu		s1,$2002(s7)
		subiu	t7,t7,$30
		sltu	t1,s1,s5		;zero
		srl		t6,s1,$07		;sign
		andi	t9,s1,$3F		;reset the vblank and sprite hit flags
		sb		zero,wantLo2006 ;reset the 2005/2006 toggle
		j		postOp
		sb		t9,$2002(s7)

;---------------------------------------------
; opcode=$04  -my own fake "LDY $2002" opcode
;---------------------------------------------
endop03
dcb $80040200-endop03,0
opcode04
		addiu	s4,s4,$03
		lbu		s2,$2002(s7)
		subiu	t7,t7,$30
		sltu	t1,s2,s5		;zero
		srl		t6,s2,$07		;sign
		andi	t9,s2,$3F		;reset the vblank and sprite hit flags
		sb		zero,wantLo2006 ;reset the 2005/2006 toggle
		j		postOp
		sb		t9,$2002(s7)

;---------------------------------------------
; opcode=$05  ins=ORA  addr=zero page
;---------------------------------------------
endop04
dcb $80040280-endop04,0
opcode05
		
		or		t9,t8,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$24
	
		or		s0,s0,t8
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$06  ins=ASL  addr=zero page
;---------------------------------------------
endop05
dcb $80040300-endop05,0
opcode06
		
		or		t9,t8,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02
		
		subiu	t7,t7,$3C
		
		sll		t8,t8,$01
		srl		t0,t8,$08		;carry
		andi	t8,t8,$FF
		sltu	t1,t8,s5		;zero
		srl		t6,t8,$07		;negetive

		sb		t8,$0000(t9)

		
		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$07 fake BIT $2002
;---------------------------------------------
endop06
dcb $80040380-endop06,0
opcode07
		addiu	s4,s4,$03
		lbu		t8,$2002(s7)
		subiu	t7,t7,$30
		sb		zero,wantLo2006 ;reset the 2005/2006 toggle
		srl		t6,t8,$07		;negative
		srl		t5,t8,$06
		andi	t5,t5,$01		;overflow
		and		t9,t8,s0
		sltu	t1,t9,s5		;zero
		andi	t9,t8,$3F		;reset the vblank and sprite hit flags
		j		postOp
		sb		t9,$2002(s7)
		
;---------------------------------------------
; opcode=$08  ins=PHP  addr=implied
;---------------------------------------------
endop07
dcb $80040400-endop07,0
opcode08

		addiu	s4,s4,$01

		subiu	t7,t7,$24

		jal		makeP		;makes P byte in a1
		or		at,s3,s7
		sb		a1,$0100(at)
		subiu	s3,s3,$01
		andi	s3,s3,$FF

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$09  ins=ORA  addr=immediate
;---------------------------------------------
endop08
dcb $80040480-endop08,0
opcode09

		addiu	s4,s4,$02
	
		subiu	t7,t7,$18

		or		s0,s0,t8
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$0A  ins=ASLA  addr=implied
;---------------------------------------------
endop09
dcb $80040500-endop09,0
opcode0A

		addiu	s4,s4,$01

		subiu	t7,t7,$18

		sll		s0,s0,$01
		srl		t0,s0,$08		;carry
		andi	s0,s0,$FF
		sltu	t1,s0,s5		;zero
		sra		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$0B
;---------------------------------------------
endop0A
dcb $80040580-endop0A,0
opcode0B

	; this is not a break because in the simpsons, bart vs world,
	; there is the opcode $0B when you throw a ball in my ROM.
	; may be an error in the dump but i'll let it go for now.

		addiu	s4,s4,$02		;immediate address mode i think
		j		postOp
		nop

;---------------------------------------------
; opcode=$0C
; hack hack hack - a fake opcode for punchout to get
; the jogging scenes to render correctly (replaces an LDA)
;---------------------------------------------
endop0B
dcb $80040600-endop0B,0
opcode0C

		or		t9,t8,s7
		lbu		s0,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$24
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;sign

		li		t8,$FEFEFEFE	; set this up so it will
		li		a0,$80022000	; draw the screen right
		li		a1,$3C0
punchoutLoop
		sw		t8,$0000(a0)
		subiu	a1,a1,$04
		bnez	a1,punchoutLoop
		addiu	a0,a0,$04

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$0D  ins=ORA  addr=absolute
;---------------------------------------------
endop0C
dcb $80040680-endop0C,0
opcode0D

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9
		subiu	t7,t7,$30

		or		s0,s0,a1
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$0E  ins=ASL  addr=absolute
;---------------------------------------------
endop0D
dcb $80040700-endop0D,0
opcode0E

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9
		subiu	t7,t7,$48

		sll		a1,a1,$01
		srl		t0,a1,$08		;carry
		andi	a1,a1,$FF
		sltu	t1,a1,s5		;zero
		srl		t6,a1,$07		;negetive

		ori		t9,t9,$8000
		jalr	t9
		nop

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$0F
;---------------------------------------------
endop0E
dcb $80040780-endop0E,0
opcode0F
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$10  ins=BPL  addr=relative
;---------------------------------------------
endop0F
dcb $80040800-endop0F,0
opcode10

		addiu	s4,s4,$02

		addu	s4,s4,t9
		beqz	t6,postOp
		subiu	t7,t7,$24

		addiu	t7,t7,$0C
		subu	s4,s4,t9
		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$11  ins=ORA  addr=indirect Y
;---------------------------------------------
endop10
dcb $80040880-endop10,0
opcode11

		or		t9,t8,s7
		lbu		t8,$0000(t9)
		lbu		t9,$0001(t9)
		addiu	s4,s4,$02
		addu	t8,t8,s2
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$3C

		or		s0,s0,a1
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$12
;---------------------------------------------
endop11
dcb $80040900-endop11,0
opcode12
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$13
;---------------------------------------------
endop12
dcb $80040980-endop12,0
opcode13
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$14
;---------------------------------------------
endop13
dcb $80040A00-endop13,0
opcode14
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$15  ins=ORA  addr=zero page X
;---------------------------------------------
endop14
dcb $80040A80-endop14,0
opcode15

		addu	t9,t8,s1
		andi	t9,t9,$FF
		or		t9,t9,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$24

		or		s0,s0,t8
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$16  ins=ASL  addr=zero page X
;---------------------------------------------
endop15
dcb $80040B00-endop15,0
opcode16

		addu	t9,t8,s1
		andi	t9,t9,$FF
		or		t9,t9,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02
		
		subiu	t7,t7,$48

		sll		t8,t8,$01
		srl		t0,t8,$08		;carry
		andi	t8,t8,$FF
		sltu	t1,t8,s5		;zero
		srl		t6,t8,$07		;negetive

		sb		t8,$0000(t9)

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$17
;---------------------------------------------
endop16
dcb $80040B80-endop16,0
opcode17
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$18  ins=CLC  addr=implied
;---------------------------------------------
endop17
dcb $80040C00-endop17,0
opcode18

		addiu	s4,s4,$01
		subiu	t7,t7,$18

		or		t0,zero,zero
		
		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$19  ins=ORA  addr=absolute indexed Y
;---------------------------------------------
endop18
dcb $80040C80-endop18,0
opcode19

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		addu	t8,t8,s2
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$30

		or		s0,s0,a1
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553
		
;---------------------------------------------
; opcode=$1A
;---------------------------------------------
endop19
dcb $80040D00-endop19,0
opcode1A
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$1B
;---------------------------------------------
endop1A
dcb $80040D80-endop1A,0
opcode1B
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$1C
;---------------------------------------------
endop1B
dcb $80040E00-endop1B,0
opcode1C
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$1D  ins=ORA  addr=absolute indexed X
;---------------------------------------------
endop1C
dcb $80040E80-endop1C,0
opcode1D

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		addu	t8,t8,s1
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$30

		or		s0,s0,a1
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553
		
;---------------------------------------------
; opcode=$1E  ins=ASL  addr=absolute indexed X
;---------------------------------------------
endop1D
dcb $80040F00-endop1D,0
opcode1E

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		addu	t8,t8,s1
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$54

		sll		a1,a1,$01
		srl		t0,a1,$08		;carry
		andi	a1,a1,$FF
		sltu	t1,a1,s5		;zero
		srl		t6,a1,$07		;negetive

		ori		t9,t9,$8000
		jalr	t9
		nop

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$1F
;---------------------------------------------
endop1E
dcb $80040F80-endop1E,0
opcode1F
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$20  ins=JSR  addr=absolute
;---------------------------------------------
endop1F
dcb $80041000-endop1F,0
opcode20

		addiu	s4,s4,$02		; one less than it should be
		or		t9,s3,s7
		beqz	s3,hardwayJSR
		srl		v0,s4,$08
		sb		v0,$0100(t9)
		sb		s4,$00FF(t9)
		subiu	s3,s3,$02
		andi	s3,s3,$FF

		lbu		t9,$0002(at)
		subiu	t7,t7,$48
		sll		t9,t9,$08
		or		s4,t8,t9		; set new PC

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553
		
hardwayJSR
		sb		v0,$0100(t9)
		sb		s4,$01FF(t9)
		li		s3,$FE

		lbu		t9,$0002(at)
		subiu	t7,t7,$48
		sll		t9,t9,$08
		or		s4,t8,t9		; set new PC

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$21  ins=AND  addr=indirect X
;---------------------------------------------
endop20
dcb $80041080-endop20,0
opcode21

		addu	t8,t8,s1
		andi	t8,t8,$FF
		or		t8,t8,s7
		lbu		t9,$0001(t8)
		lbu		t8,$0000(t8)
		addu	s4,s4,$02
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$48
		and		s0,s0,a1
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$22
;---------------------------------------------
endop21
dcb $80041100-endop21,0
opcode22
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$23
;---------------------------------------------
endop22
dcb $80041180-endop22,0
opcode23
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$24  ins=BIT  addr=zero page
;---------------------------------------------
endop23
dcb $80041200-endop23,0
opcode24

		or		t9,t8,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$24

		srl		t6,t8,$07		;negative
		srl		t5,t8,$06
		andi	t5,t5,$01		;overflow
		and		t9,t8,s0
		sltu	t1,t9,s5		;zero
		

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$25  ins=AND  addr=zero page
;---------------------------------------------
endop24
dcb $80041280-endop24,0
opcode25

		or		t9,t8,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$18

		and		s0,s0,t8
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		
		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$26  ins=ROL  addr=zero page
;---------------------------------------------
endop25
dcb $80041300-endop25,0
opcode26
		
		or		t9,t8,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$3C

		sll		t8,t8,$01
		or		t8,t8,t0
		srl		t0,t8,$08		;carry
		andi	t8,t8,$FF
		sltu	t1,t8,s5		;zero
		srl		t6,t8,$07		;negetive
		
		sb		t8,$0000(t9)

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553
		
;---------------------------------------------
; opcode=$27
;---------------------------------------------
endop26
dcb $80041380-endop26,0
opcode27
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$28  ins=PLP  addr=implied
;---------------------------------------------
endop27
dcb $80041400-endop27,0
opcode28

		addiu	s4,s4,$01

		addiu	s3,s3,$01
		andi	s3,s3,$FF		;just to be safe
		or		t8,s3,s7
		lbu		t8,$0100(t8)
		subiu	t7,t7,$30
		srl		t6,t8,$07
		srl		t5,t8,$06
		andi	t5,t5,$01
		srl		t4,t8,$04
		andi	t4,t4,$01
		;srl	t3,t8,$03
		;andi	t3,t3,$01
		srl		t2,t8,$02
		andi	t2,t2,$01
		srl		t1,t8,$01
		andi	t1,t1,$01
		and		t0,t8,$01
		
		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$29  ins=AND  addr=immediate
;---------------------------------------------
endop28
dcb $80041480-endop28,0
opcode29
		
		addiu	s4,s4,$02

		subiu	t7,t7,$18

		and		s0,s0,t8
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$2A  ins=ROLA  addr=implied
;---------------------------------------------
endop29
dcb $80041500-endop29,0
opcode2A

		addiu	s4,s4,$01

		subiu	t7,t7,$18

		sll 	s0,s0,$01
		or		s0,s0,t0
		srl		t0,s0,$08		;carry
		andi	s0,s0,$FF
		sltu	t1,s0,s5		;zero
		sra		t6,s0,$07		;negetive

		
		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$2B
;---------------------------------------------
endop2A
dcb $80041580-endop2A,0
opcode2B
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$2C  ins=BIT  addr=absolute
;---------------------------------------------
endop2B
dcb $80041600-endop2B,0
opcode2C

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9
		subiu	t7,t7,$30

		srl		t6,a1,$07		;negative
		srl		t5,a1,$06
		andi	t5,t5,$01		;overflow
		and		t9,a1,s0
		sltu	t1,t9,s5		;zero

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$2D  ins=AND  addr=absolute
;---------------------------------------------
endop2C
dcb $80041680-endop2C,0
opcode2D

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9
		subiu	t7,t7,$30

		and		s0,s0,a1
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$2E  ins=ROL  addr=absolute
;---------------------------------------------
endop2D
dcb $80041700-endop2D,0
opcode2E

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9
		subiu	t7,t7,$48

		sll		a1,a1,$01
		or		a1,a1,t0
		srl		t0,a1,$08		;carry
		andi	a1,a1,$FF
		sltu	t1,a1,s5		;zero
		srl		t6,a1,$07		;negetive

		ori		t9,t9,$8000
		jalr	t9
		nop

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$2F
;---------------------------------------------
endop2E
dcb $80041780-endop2E,0
opcode2F
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$30  ins=BMI  addr=relative
;---------------------------------------------
endop2F
dcb $80041800-endop2F,0
opcode30

		addiu	s4,s4,$02

		addu	s4,s4,t9
		bnez	t6,postOp
		subiu	t7,t7,$24

		addiu	t7,t7,$0C
		subu	s4,s4,t9
		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$31  ins=AND  addr=indirect Y
;---------------------------------------------
endop30
dcb $80041880-endop30,0
opcode31

		or		t9,t8,s7
		lbu		t8,$0000(t9)
		lbu		t9,$0001(t9)
		addiu	s4,s4,$02
		addu	t8,t8,s2
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$3C

		and		s0,s0,a1
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$32
;---------------------------------------------
endop31
dcb $80041900-endop31,0
opcode32
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$33
;---------------------------------------------
endop32
dcb $80041980-endop32,0
opcode33
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$34
;---------------------------------------------
endop33
dcb $80041A00-endop33,0
opcode34
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$35  ins=AND  addr=zero page X
;---------------------------------------------
endop34
dcb $80041A80-endop34,0
opcode35

		addu	t9,t8,s1
		andi	t9,t9,$FF
		or		t9,t9,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$24

		and		s0,s0,t8
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$36  ins=ROL  addr=zero page X
;---------------------------------------------
endop35
dcb $80041B00-endop35,0
opcode36

		addu	t9,t8,s1
		andi	t9,t9,$FF
		or		t9,t9,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$48

		sll		t8,t8,$01
		or		t8,t8,t0
		srl 	t0,t8,$08		;carry
		andi	t8,t8,$FF
		sltu	t1,t8,s5		;zero
		srl		t6,t8,$07		;negetive

		sb		t8,$0000(t9)
		
		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$37
;---------------------------------------------
endop36
dcb $80041B80-endop36,0
opcode37
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$38  ins=SEC  addr=implied
;---------------------------------------------
endop37
dcb $80041C00-endop37,0
opcode38	

		addiu	s4,s4,$01

		subiu	t7,t7,$18
		ori		t0,zero,$01
		
		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$39  ins=AND  addr=absolute indexed Y
;---------------------------------------------
endop38
dcb $80041C80-endop38,0
opcode39

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		addu	t8,t8,s2
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9
		
		subiu	t7,t7,$30

		and		s0,s0,a1
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$3A
;---------------------------------------------
endop39
dcb $80041D00-endop39,0
opcode3A
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$3B
;---------------------------------------------
endop3A
dcb $80041D80-endop3A,0
opcode3B
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$3C
;---------------------------------------------
endop3B
dcb $80041E00-endop3B,0
opcode3C
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$3D  ins=AND  addr=absolute indexed X
;---------------------------------------------
endop3C
dcb $80041E80-endop3C,0
opcode3D

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		addu	t8,t8,s1
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$30

		and		s0,s0,a1
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$3E  ins=ROL  addr=absolute indexed X
;---------------------------------------------
endop3D
dcb $80041F00-endop3D,0
opcode3E

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		addu	t8,t8,s1
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$54

		sll		a1,a1,$01
		or		a1,a1,t0
		srl		t0,a1,$08		;carry
		andi	a1,a1,$FF
		sltu	t1,a1,s5		;zero
		srl		t6,a1,$07		;negetive

		ori		t9,t9,$8000
		jalr	t9
		nop

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$3F
;---------------------------------------------
endop3E
dcb $80041F80-endop3E,0
opcode3F
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$40  ins=RTI  addr=implied
;---------------------------------------------
endop3F
dcb $80042000-endop3F,0
opcode40

		addiu	s3,s3,$01
		andi	s3,s3,$FF
		or		v0,s3,s7
		lbu		t8,$0100(v0)
		subiu	t7,t7,$48

		srl		t6,t8,$07
		srl		t5,t8,$06
		andi	t5,t5,$01
		srl		t4,t8,$04
		andi	t4,t4,$01
		;srl	t3,t8,$03
		;andi	t3,t3,$01
		srl		t2,t8,$02
		andi	t2,t2,$01
		srl		t1,t8,$01
		andi	t1,t1,$01

		addiu	s3,s3,$02
		andi	s3,s3,$FF
		beqz	s3,hardwayRTI
		or		v0,s3,s7
		lbu		s4,$0100(v0)
		lbu		t9,$00FF(v0)
		sll		s4,s4,$08
		or		s4,s4,t9

		j		postOp
		andi	t0,t8,$01
hardwayRTI
		lbu		s4,$0100(v0)
		lbu		t9,$01FF(v0)
		sll		s4,s4,$08
		or		s4,s4,t9

		j		postOp
		andi	t0,t8,$01

;---------------------------------------------
; opcode=$41  ins=EOR  addr=indirect X
;---------------------------------------------
endop40
dcb $80042080-endop40,0
opcode41

		addu	t8,t8,s1
		andi	t8,t8,$FF
		or		t8,t8,s7
		lbu		t9,$0001(t8)
		lbu		t8,$0000(t8)
		addu	s4,s4,$02
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$48
		xor		s0,s0,a1
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$42
;---------------------------------------------
endop41
dcb $80042100-endop41,0
opcode42
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$43
;---------------------------------------------
endop42
dcb $80042180-endop42,0
opcode43
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$44
;---------------------------------------------
endop43
dcb $80042200-endop43,0
opcode44
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$45  ins=EOR  addr=zero page
;---------------------------------------------
endop44
dcb $80042280-endop44,0
opcode45

		or		t9,t8,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$24

		xor		s0,s0,t8
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$46  ins=LSR  addr=zero page
;---------------------------------------------
endop45
dcb $80042300-endop45,0
opcode46

		or		t9,t8,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$3C

		andi	t0,t8,$01		;carry
		srl 	t8,t8,$01
		sltu	t1,t8,s5		;zero
		srl		t6,t8,$07		;negetive

		sb		t8,$0000(t9)

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$47
;---------------------------------------------
endop46
dcb $80042380-endop46,0
opcode47
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$48  ins=PHA  addr=implied
;---------------------------------------------
endop47
dcb $80042400-endop47,0
opcode48

		addiu	s4,s4,$01

		subiu	t7,t7,$24

		or		at,s3,s7
		sb		s0,$0100(at)
		subiu	s3,s3,$01
		andi	s3,s3,$FF

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$49  ins=EOR  addr=immediate
;---------------------------------------------
endop48
dcb $80042480-endop48,0
opcode49

		addiu	s4,s4,$02

		subiu	t7,t7,$18

		xor		s0,s0,t8
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$4A  ins=LSRA  addr=implied
;---------------------------------------------
endop49
dcb $80042500-endop49,0
opcode4A

		addiu	s4,s4,$01

		subiu	t7,t7,$18

		andi	t0,s0,$01		;carry
		srl 	s0,s0,$01
		sltu	t1,s0,s5		;zero
		sra		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$4B
;---------------------------------------------
endop4A
dcb $80042580-endop4A,0
opcode4B
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$4C  ins=JMP  addr=absolute
;---------------------------------------------
endop4B
dcb $80042600-endop4B,0
opcode4C

		lbu		t9,$0002(at)
		subiu	t7,t7,$24
		sll		t9,t9,$08
		or		s4,t8,t9

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$4D  ins=EOR  addr=absolute
;---------------------------------------------
endop4C
dcb $80042680-endop4C,0
opcode4D

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9
		subiu	t7,t7,$30

		xor		s0,s0,a1
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$4E  ins=LSR  addr=absolute
;---------------------------------------------
endop4D
dcb $80042700-endop4D,0
opcode4E

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9
		subiu	t7,t7,$48
		
		and		t0,a1,$01		;carry
		srl 	a1,a1,$01
		sltu	t1,a1,s5		;zero
		srl		t6,a1,$07		;negetive

		ori		t9,t9,$8000
		jalr	t9
		nop

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$4F
;---------------------------------------------
endop4E
dcb $80042780-endop4E,0
opcode4F
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$50  ins=BVC  addr=relative
;---------------------------------------------
endop4F
dcb $80042800-endop4F,0
opcode50

		addiu	s4,s4,$02

		addu	s4,s4,t9
		beqz	t5,postOp
		subiu	t7,t7,$24

		addiu	t7,t7,$0C
		subu	s4,s4,t9
		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$51  ins=EOR  addr=indirect Y
;---------------------------------------------
endop50
dcb $80042880-endop50,0
opcode51

		or		t9,t8,s7
		lbu		t8,$0000(t9)
		lbu		t9,$0001(t9)
		addiu	s4,s4,$02
		addu	t8,t8,s2
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$3C

		xor		s0,s0,a1
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$52
;---------------------------------------------
endop51
dcb $80042900-endop51,0
opcode52
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$53
;---------------------------------------------
endop52
dcb $80042980-endop52,0
opcode53
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$54
;---------------------------------------------
endop53
dcb $80042A00-endop53,0
opcode54
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$55  ins=EOR  addr=zero page X
;---------------------------------------------
endop54
dcb $80042A80-endop54,0
opcode55

		addu	t9,t8,s1
		andi	t9,t9,$FF
		or		t9,t9,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$30

		xor		s0,s0,t8
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$56  ins=LSR  addr=zero page X
;---------------------------------------------
endop55
dcb $80042B00-endop55,0
opcode56

		addu	t9,t8,s1
		andi	t9,t9,$FF
		or		t9,t9,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$48

		and		t0,t8,$01		;carry
		srl 	t8,t8,$01
		sltu	t1,t8,s5		;zero
		srl		t6,t8,$07		;negetive

		sb		t8,$0000(t9)

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$57
;---------------------------------------------
endop56
dcb $80042B80-endop56,0
opcode57
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$58  ins=CLI  addr=implied
;---------------------------------------------
endop57
dcb $80042C00-endop57,0
opcode58

		addiu	s4,s4,$01

		subiu	t7,t7,$18
		or		t2,zero,zero

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$59  ins=EOR  addr=absolute indexed Y
;---------------------------------------------
endop58
dcb $80042C80-endop58,0
opcode59

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		addu	t8,t8,s2
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$30

		xor		s0,s0,a1
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$5A
;---------------------------------------------
endop59
dcb $80042D00-endop59,0
opcode5A
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$5B
;---------------------------------------------
endop5A
dcb $80042D80-endop5A,0
opcode5B
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$5C
;---------------------------------------------
endop5B
dcb $80042E00-endop5B,0
opcode5C
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$5D  ins=EOR  addr=absolute indexed X
;---------------------------------------------
endop5C
dcb $80042E80-endop5C,0
opcode5D

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		addu	t8,t8,s1
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$30

		xor		s0,s0,a1
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$5E  ins=LSR  addr=absolute indexed X
;---------------------------------------------
endop5D
dcb $80042F00-endop5D,0
opcode5E

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		addu	t8,t8,s1
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$54

		and		t0,a1,$01		;carry
		srl 	a1,a1,$01
		sltu	t1,a1,s5		;zero
		srl		t6,a1,$07		;negetive

		ori		t9,t9,$8000
		jalr	t9
		nop

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$5F
;---------------------------------------------
endop5E
dcb $80042F80-endop5E,0
opcode5F
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$60  ins=RTS  addr=implied
;---------------------------------------------
endop5F
dcb $80043000-endop5F,0
opcode60

		addiu	s3,s3,$02
		andi	s3,s3,$FF
		beqz	s3,hardwayRTS
		or		t8,s3,s7
		lwl		s4,$0102(t8)		; want to pull from stack - 1
		lwr		s4,$00FF(t8)
		subiu	t7,t7,$48
		andi	s4,s4,$FFFF
		addiu	s4,s4,$01

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

hardwayRTS
		lbu		s4,$0100(t8)
		lbu		t8,$01FF(t8)
		subiu	t7,t7,$48
		sll		s4,s4,$08
		or		s4,s4,t8
		addiu	s4,s4,$01

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$61  ins=ADC  addr=indirect X
;---------------------------------------------
endop60
dcb $80043080-endop60,0
opcode61

		addu	t8,t8,s1
		andi	t8,t8,$FF
		or		t8,t8,s7
		lbu		t9,$0001(t8)
		lbu		t8,$0000(t8)
		addu	s4,s4,$02
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$48

		addu	a1,a1,t0
		addu	s0,s0,a1
		srl		t0,s0,$08		;carry
		andi	s0,s0,$FF
		srl		t6,s0,$07		;negetive
		sltu	t1,s0,s5		;zero

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$62
;---------------------------------------------
endop61
dcb $80043100-endop61,0
opcode62
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$63
;---------------------------------------------
endop62
dcb $80043180-endop62,0
opcode63
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$64
;---------------------------------------------
endop63
dcb $80043200-endop63,0
opcode64
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$65  ins=ADC  addr=zero page
;---------------------------------------------
endop64
dcb $80043280-endop64,0
opcode65

		or		t9,t8,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$24

		addu	t8,t8,t0
		addu	s0,s0,t8
		srl		t0,s0,$08		;carry
		andi	s0,s0,$FF
		srl		t6,s0,$07		;negetive
		sltu	t1,s0,s5		;zero

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$66  ins=ROR  addr=zero page
;---------------------------------------------
endop65
dcb $80043300-endop65,0
opcode66

		or		t9,t8,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$3C

		sll		v0,t0,$08
		or		t8,t8,v0
		and		t0,t8,$01		;carry
		srl 	t8,t8,$01
		sltu	t1,t8,s5		;zero
		srl		t6,t8,$07		;negetive

		sb		t8,$0000(t9)

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$67
;---------------------------------------------
endop66
dcb $80043380-endop66,0
opcode67
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$68  ins=PLA  addr=implied
;---------------------------------------------
endop67
dcb $80043400-endop67,0
opcode68

		addiu	s4,s4,$01

		addiu	s3,s3,$01
		andi	s3,s3,$FF		;needed by "720 degrees"
		or		t8,s3,s7
		lbu		s0,$0100(t8)
		subiu	t7,t7,$30
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$69  ins=ADC  addr=immediate
;---------------------------------------------
endop68
dcb $80043480-endop68,0
opcode69

		addiu	s4,s4,$02
		
		subiu	t7,t7,$18

		addu	t8,t8,t0
		addu	s0,s0,t8
		srl		t0,s0,$08		;carry
		andi	s0,s0,$FF
		srl		t6,s0,$07		;negetive
		sltu	t1,s0,s5		;zero

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$6A  ins=RORA  addr=implied
;---------------------------------------------
endop69
dcb $80043500-endop69,0
opcode6A

		addiu	s4,s4,$01

		subiu	t7,t7,$18

		sll 	v0,t0,$08
		or		s0,s0,v0
		andi	t0,s0,$01		;carry
		srl 	s0,s0,$01
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;negetive

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$6B
;---------------------------------------------
endop6A
dcb $80043580-endop6A,0
opcode6B
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$6C  ins=JMP  addr=indirect
;---------------------------------------------
endop6B
dcb $80043600-endop6B,0
opcode6C
		lbu		t9,$0002(at)
		subiu	t7,t7,$3C
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9
		nop

		or		s4,zero,a1

		jalr	t9
		addiu	t8,t8,$01

		sll		a1,a1,$08
		or		s4,s4,a1

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$6D  ins=ADC  addr=absolute
;---------------------------------------------
endop6C
dcb $80043680-endop6C,0
opcode6D

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9
		subiu	t7,t7,$30

		addu	a1,a1,t0
		addu	s0,s0,a1
		srl 	t0,s0,$08		;carry
		andi	s0,s0,$FF
		srl		t6,s0,$07		;negetive
		sltu	t1,s0,s5		;zero

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$6E  ins=ROR  addr=absolute
;---------------------------------------------
endop6D
dcb $80043700-endop6D,0
opcode6E

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9
		subiu	t7,t7,$48

		sll 	v0,t0,$08
		or		a1,a1,v0
		and		t0,a1,$01		;carry
		srl 	a1,a1,$01
		sltu	t1,a1,s5		;zero
		srl		t6,a1,$07		;negetive

		ori		t9,t9,$8000
		jalr	t9
		nop

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$6F
;---------------------------------------------
endop6E
dcb $80043780-endop6E,0
opcode6F
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$70  ins=BVS  addr=relative
;---------------------------------------------
endop6F
dcb $80043800-endop6F,0
opcode70

		addiu	s4,s4,$02

		addu	s4,s4,t9
		bnez	t5,postOp
		subiu	t7,t7,$24

		addiu	t7,t7,$0C
		subu	s4,s4,t9
		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$71  ins=ADC  addr=indirect Y
;---------------------------------------------
endop70
dcb $80043880-endop70,0
opcode71

		or		t9,t8,s7
		lbu		t8,$0000(t9)
		lbu		t9,$0001(t9)
		addiu	s4,s4,$02
		addu	t8,t8,s2
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9
		
		subiu	t7,t7,$3C

		addu	a1,a1,t0
		addu	s0,s0,a1
		srl 	t0,s0,$08		;carry
		andi	s0,s0,$FF
		srl		t6,s0,$07		;negetive
		sltu	t1,s0,s5		;zero

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$72
;---------------------------------------------
endop71
dcb $80043900-endop71,0
opcode72
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$73
;---------------------------------------------
endop72
dcb $80043980-endop72,0
opcode73
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$74
;---------------------------------------------
endop73
dcb $80043A00-endop73,0
opcode74
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$75  ins=ADC  addr=zero page X
;---------------------------------------------
endop74
dcb $80043A80-endop74,0
opcode75

		addu	t9,t8,s1
		andi	t9,t9,$FF
		or		t9,t9,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02
		
		subiu	t7,t7,$30
		
		addu	t8,t8,t0
		addu	s0,s0,t8
		srl 	t0,s0,$08		;carry
		andi	s0,s0,$FF
		srl		t6,s0,$07		;negetive
		sltu	t1,s0,s5		;zero

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$76  ins=ROR  addr=zero page X
;---------------------------------------------
endop75
dcb $80043B00-endop75,0
opcode76

		addu	t9,t8,s1
		andi	t9,t9,$FF
		or		t9,t9,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$48

		sll 	v0,t0,$08
		or		t8,t8,v0
		and		t0,t8,$01		;carry
		srl 	t8,t8,$01
		sltu	t1,t8,s5		;zero
		srl		t6,t8,$07		;negetive

		sb		t8,$0000(t9)

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$77
;---------------------------------------------
endop76
dcb $80043B80-endop76,0
opcode77
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$78  ins=SEI  addr=implied
;---------------------------------------------
endop77
dcb $80043C00-endop77,0
opcode78

		addiu	s4,s4,$01

		subiu	t7,t7,$18
		ori		t2,zero,$01

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$79  ins=ADC  addr=absolute indexed Y
;---------------------------------------------
endop78
dcb $80043C80-endop78,0
opcode79

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		addu	t8,t8,s2
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$30

		addu	a1,a1,t0
		addu	s0,s0,a1
		srl 	t0,s0,$08		;carry
		andi	s0,s0,$FF
		srl		t6,s0,$07		;negetive
		sltu	t1,s0,s5		;zero

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$7A
;---------------------------------------------
endop79
dcb $80043D00-endop79,0
opcode7A
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$7B
;---------------------------------------------
endop7A
dcb $80043D80-endop7A,0
opcode7B
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$7C
;---------------------------------------------
endop7B
dcb $80043E00-endop7B,0
opcode7C
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$7D  ins=ADC  addr=absolute indexed X
;---------------------------------------------
endop7C
dcb $80043E80-endop7C,0
opcode7D

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		addu	t8,t8,s1
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$30

		addu	a1,a1,t0
		addu	s0,s0,a1
		srl 	t0,s0,$08		;carry
		andi	s0,s0,$FF
		srl		t6,s0,$07		;negetive
		sltu	t1,s0,s5		;zero

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$7E  ins=ROR  addr=absolute indexed X
;---------------------------------------------
endop7D
dcb $80043F00-endop7D,0
opcode7E

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		addu	t8,t8,s1
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$54

		sll 	v0,t0,$08
		or		a1,a1,v0
		and		t0,a1,$01		;carry
		srl 	a1,a1,$01
		sltu	t1,a1,s5		;zero
		srl		t6,a1,$07		;negetive

		ori		t9,t9,$8000
		jalr	t9
		nop

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$7F
;---------------------------------------------
endop7E
dcb $80043F80-endop7E,0
opcode7F
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$80
;---------------------------------------------
endop7F
dcb $80044000-endop7F,0
opcode80
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$81  ins=STA  addr=indirect X
;---------------------------------------------
endop80
dcb $80044080-endop80,0
opcode81
		
		addu	t8,t8,s1
		andi	t8,t8,$FF
		or		t8,t8,s7
		lbu		t9,$0001(t8)
		lbu		t8,$0000(t8)
		or		a1,zero,s0
		addu	s4,s4,$02
		ori		t9,t9,ADDR_OR_WRITE
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$48
		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$82
;---------------------------------------------
endop81
dcb $80044100-endop81,0
opcode82
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$83
;---------------------------------------------
endop82
dcb $80044180-endop82,0
opcode83
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$84  ins=STY  addr=zero page
;---------------------------------------------
endop83
dcb $80044200-endop83,0
opcode84

		or		t9,t8,s7
		sb		s2,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$24
		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$85  ins=STA  addr=zero page
;---------------------------------------------
endop84
dcb $80044280-endop84,0
opcode85

		or		t9,t8,s7
		sb		s0,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$24
		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$86  ins=STX  addr=zero page
;---------------------------------------------
endop85
dcb $80044300-endop85,0
opcode86

		or		t9,t8,s7
		sb		s1,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$24
		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$87
;---------------------------------------------
endop86
dcb $80044380-endop86,0
opcode87
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$88  ins=DEY  addr=implied
;---------------------------------------------
endop87
dcb $80044400-endop87,0
opcode88

		addiu	s4,s4,$01

		subiu	t7,t7,$18

		subiu	s2,s2,$01
		andi	s2,s2,$FF
		sltu	t1,s2,s5		;zero
		srl		t6,s2,$07		;sign

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$89
;---------------------------------------------
endop88
dcb $80044480-endop88,0
opcode89
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$8A  ins=TXA  addr=implied
;---------------------------------------------
endop89
dcb $80044500-endop89,0
opcode8A

		addiu	s4,s4,$01

		subiu	t7,t7,$18

		or		s0,zero,s1
		srl		t6,s0,$07		;negetive
		sltu	t1,s0,s5		;zero

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$8B
;---------------------------------------------
endop8A
dcb $80044580-endop8A,0
opcode8B
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$8C  ins=STY  addr=absolute
;---------------------------------------------
endop8B
dcb $80044600-endop8B,0
opcode8C

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		or		a1,zero,s2
		ori		t9,t9,ADDR_OR_WRITE
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$30

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$8D  ins=STA  addr=absolute
;---------------------------------------------
endop8C
dcb $80044680-endop8C,0
opcode8D

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		or		a1,zero,s0
		ori		t9,t9,ADDR_OR_WRITE
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$30

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$8E  ins=STX  addr=absolute
;---------------------------------------------
endop8D
dcb $80044700-endop8D,0
opcode8E

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		or		a1,zero,s1
		ori		t9,t9,ADDR_OR_WRITE
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$30

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$8F
;---------------------------------------------
endop8E
dcb $80044780-endop8E,0
opcode8F
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$90  ins=BCC  addr=relative
;---------------------------------------------
endop8F
dcb $80044800-endop8F,0
opcode90

		addiu	s4,s4,$02

		addu	s4,s4,t9
		beqz	t0,postOp
		subiu	t7,t7,$24

		addiu	t7,t7,$0C
		subu	s4,s4,t9
		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$91  ins=STA  addr=indirect Y
;---------------------------------------------
endop90
dcb $80044880-endop90,0
opcode91
		
		or		t9,t8,s7
		lbu		t8,$0000(t9)
		lbu		t9,$0001(t9)
		addiu	s4,s4,$02
		or		a1,zero,s0
		addu	t8,t8,s2
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_WRITE
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$48

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$92
;---------------------------------------------
endop91
dcb $80044900-endop91,0
opcode92
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$93
;---------------------------------------------
endop92
dcb $80044980-endop92,0
opcode93
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$94  ins=STY  addr=zero page X
;---------------------------------------------
endop93
dcb $80044A00-endop93,0
opcode94

		addu	t9,t8,s1
		andi	t9,t9,$FF
		or		t9,t9,s7
		sb		s2,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$30

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$95  ins=STA  addr=zero page X
;---------------------------------------------
endop94
dcb $80044A80-endop94,0
opcode95

		addu	t9,t8,s1
		andi	t9,t9,$FF
		or		t9,t9,s7
		sb		s0,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$30

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$96  ins=STX  addr=zero page Y
;---------------------------------------------
endop95
dcb $80044B00-endop95,0
opcode96
		
		addu	t9,t8,s2
		andi	t9,t9,$FF
		or		t9,t9,s7
		sb		s1,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$30

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$97
;---------------------------------------------
endop96
dcb $80044B80-endop96,0
opcode97
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$98  ins=TYA  addr=implied
;---------------------------------------------
endop97
dcb $80044C00-endop97,0
opcode98

		addiu	s4,s4,$01

		subiu	t7,t7,$18

		or		s0,zero,s2
		srl		t6,s0,$07		;negetive
		sltu	t1,s0,s5		;zero

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$99  ins=STA  addr=absolute indexed Y
;---------------------------------------------
endop98
dcb $80044C80-endop98,0
opcode99

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		or		a1,zero,s0
		addu	t8,t8,s2
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_WRITE
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$3C

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$9A  ins=TXS  addr=implied
;---------------------------------------------
endop99
dcb $80044D00-endop99,0
opcode9A

		addiu	s4,s4,$01

		subiu	t7,t7,$18
		andi	s3,s1,$FF

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$9B
;---------------------------------------------
endop9A
dcb $80044D80-endop9A,0
opcode9B
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$9C
;---------------------------------------------
endop9B
dcb $80044E00-endop9B,0
opcode9C
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$9D  ins=STA  addr=absolute indexed X
;---------------------------------------------
endop9C
dcb $80044E80-endop9C,0
opcode9D

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		or		a1,zero,s0
		addu	t8,t8,s1
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_WRITE
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$3C

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$9E
;---------------------------------------------
endop9D
dcb $80044F00-endop9D,0
opcode9E
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$9F
;---------------------------------------------
endop9E
dcb $80044F80-endop9E,0
opcode9F
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$A0  ins=LDY  addr=immediate
;---------------------------------------------
endop9F
dcb $80045000-endop9F,0
opcodeA0

		addiu	s4,s4,$02

		subiu	t7,t7,$18

		andi	s2,t8,$FF
		sltu	t1,s2,s5		;zero
		srl		t6,s2,$07		;sign

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$A1  ins=LDA  addr=indirect X
;---------------------------------------------
endopA0
dcb $80045080-endopA0,0
opcodeA1

		addu	t8,t8,s1
		andi	t8,t8,$FF
		or		t8,t8,s7
		lbu		t9,$0001(t8)
		lbu		t8,$0000(t8)
		addu	s4,s4,$02
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$48
		or		s0,zero,a1
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;sign

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$A2  ins=LDX  addr=immediate
;---------------------------------------------
endopA1
dcb $80045100-endopA1,0
opcodeA2

		addiu	s4,s4,$02

		subiu	t7,t7,$18

		andi	s1,t8,$FF
		sltu	t1,s1,s5		;zero
		srl		t6,s1,$07		;sign

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$A3
;---------------------------------------------
endopA2
dcb $80045180-endopA2,0
opcodeA3
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$A4  ins=LDY  addr=zero page
;---------------------------------------------
endopA3
dcb $80045200-endopA3,0
opcodeA4

		or		t9,t8,s7
		lbu		s2,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$24
		sltu	t1,s2,s5		;zero
		srl		t6,s2,$07		;sign

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$A5  ins=LDA  addr=zero page
;---------------------------------------------
endopA4
dcb $80045280-endopA4,0
opcodeA5

		or		t9,t8,s7
		lbu		s0,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$24

		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;sign

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$A6  ins=LDX  addr=zero page
;---------------------------------------------
endopA5
dcb $80045300-endopA5,0
opcodeA6
		
		or		t9,t8,s7
		lbu		s1,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$24
		sltu	t1,s1,s5		;zero
		srl		t6,s1,$07		;sign

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$A7
;---------------------------------------------
endopA6
dcb $80045380-endopA6,0
opcodeA7
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$A8  ins=TAY  addr=implied
;---------------------------------------------
endopA7
dcb $80045400-endopA7,0
opcodeA8

		addiu	s4,s4,$01

		subiu	t7,t7,$18
		or		s2,zero,s0
		srl		t6,s2,$07		;negetive
		sltu	t1,s2,s5		;zero

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$A9  ins=LDA  addr=immediate
;---------------------------------------------
endopA8
dcb $80045480-endopA8,0
opcodeA9

		addiu	s4,s4,$02

		subiu	t7,t7,$18
		andi	s0,t8,$FF
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;sign

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$AA  ins=TAX  addr=implied
;---------------------------------------------
endopA9
dcb $80045500-endopA9,0
opcodeAA

		addiu	s4,s4,$01

		subiu	t7,t7,$18
		or		s1,zero,s0
		srl		t6,s1,$07		;negetive
		sltu	t1,s1,s5		;zero

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$AB
;---------------------------------------------
endopAA
dcb $80045580-endopAA,0
opcodeAB
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$AC  ins=LDY  addr=absolute
;---------------------------------------------
endopAB
dcb $80045600-endopAB,0
opcodeAC

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9
		subiu	t7,t7,$30

		or		s2,zero,a1
		sltu	t1,s2,s5		;zero
		srl		t6,s2,$07		;sign

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$AD  ins=LDA  addr=absolute
;---------------------------------------------
endopAC
dcb $80045680-endopAC,0
opcodeAD

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9
		subiu	t7,t7,$30

		or		s0,zero,a1
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;sign

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$AE  ins=LDX  addr=absolute
;---------------------------------------------
endopAD
dcb $80045700-endopAD,0
opcodeAE

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9
		subiu	t7,t7,$30
		
		or		s1,zero,a1
		sltu	t1,s1,s5		;zero
		srl		t6,s1,$07		;sign

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$AF  ins=NOP  addr=implied
;---------------------------------------------
endopAE
dcb $80045780-endopAE,0
opcodeAF
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$B0  ins=BCS  addr=relative
;---------------------------------------------
endopAF
dcb $80045800-endopAF,0
opcodeB0

		addiu	s4,s4,$02

		addu	s4,s4,t9
		bnez	t0,postOp
		subiu	t7,t7,$24

		addiu	t7,t7,$0C
		subu	s4,s4,t9
		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$B1  ins=LDA  addr=indirect Y
;---------------------------------------------
endopB0
dcb $80045880-endopB0,0
opcodeB1

		or		t9,t8,s7
		lbu		t8,$0000(t9)
		lbu		t9,$0001(t9)
		addiu	s4,s4,$02
		addu	t8,t8,s2
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$3C
		or		s0,zero,a1
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;sign

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$B2
;---------------------------------------------
endopB1
dcb $80045900-endopB1,0
opcodeB2
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$B3
;---------------------------------------------
endopB2
dcb $80045980-endopB2,0
opcodeB3
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$B4  ins=LDY  addr=zero page X
;---------------------------------------------
endopB3
dcb $80045A00-endopB3,0
opcodeB4

		addu	t9,t8,s1
		andi	t9,t9,$FF
		or		t9,t9,s7
		lbu		s2,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$30
		sltu	t1,s2,s5		;zero
		srl		t6,s2,$07		;sign

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$B5  ins=LDA  addr=zero page X
;---------------------------------------------
endopB4
dcb $80045A80-endopB4,0
opcodeB5

		addu	t9,t8,s1
		andi	t9,t9,$FF
		or		t9,t9,s7
		lbu		s0,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$30
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;sign

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$B6  ins=LDX  addr=zero page Y
;---------------------------------------------
endopB5
dcb $80045B00-endopB5,0
opcodeB6

		addu	t9,t8,s2
		andi	t9,t9,$FF
		or		t9,t9,s7
		lbu		s1,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$30
		sltu	t1,s1,s5		;zero
		srl		t6,s1,$07		;sign

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$B7  ins=NOP  addr=implied
;---------------------------------------------
endopB6
dcb $80045B80-endopB6,0
opcodeB7
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$B8  ins=CLV  addr=implied
;---------------------------------------------
endopB7
dcb $80045C00-endopB7,0
opcodeB8

		addiu	s4,s4,$01

		subiu	t7,t7,$18
		or		t5,zero,zero

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$B9  ins=LDA  addr=absolute indexed Y
;---------------------------------------------
endopB8
dcb $80045C80-endopB8,0
opcodeB9

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		addu	t8,t8,s2
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$30

		or		s0,zero,a1
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;sign

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$BA  ins=TSX  addr=implied
;---------------------------------------------
endopB9
dcb $80045D00-endopB9,0
opcodeBA

		addiu	s4,s4,$01

		subiu	t7,t7,$18
		andi	s1,s3,$FF
		srl		t6,s1,$07		;negetive
		sltu	t1,s1,s5		;zero

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$BB
;---------------------------------------------
endopBA
dcb $80045D80-endopBA,0
opcodeBB
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$BC  ins=LDY  addr=absolute indexed X
;---------------------------------------------
endopBB
dcb $80045E00-endopBB,0
opcodeBC

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		addu	t8,t8,s1
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$30

		or		s2,zero,a1
		sltu	t1,s2,s5		;zero
		srl		t6,s2,$07		;sign

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$BD  ins=LDA  addr=absolute indexed X
;---------------------------------------------
endopBC
dcb $80045E80-endopBC,0
opcodeBD

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		addu	t8,t8,s1
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$30

		or		s0,zero,a1
		sltu	t1,s0,s5		;zero
		srl		t6,s0,$07		;sign

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$BE  ins=LDX  addr=absolute indexed Y
;---------------------------------------------
endopBD
dcb $80045F00-endopBD,0
opcodeBE

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		addu	t8,t8,s2
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$30

		or		s1,zero,a1
		sltu	t1,s1,s5		;zero
		srl		t6,s1,$07		;sign

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$BF
;---------------------------------------------
endopBE
dcb $80045F80-endopBE,0
opcodeBF
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$C0  ins=CPY  addr=immediate
;---------------------------------------------
endopBF
dcb $80046000-endopBF,0
opcodeC0

		addiu	s4,s4,$02

		subiu	t7,t7,$18
		sltu	t0,s2,t8		;Carry
		xor		t0,t0,s5
		subu	t6,s2,t8
		andi	t6,t6,$00FF
		sltu	t1,t6,s5		;Zero
		srl		t6,t6,$07		;sigN

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$C1  ins=CMP  addr=indirect X
;---------------------------------------------
endopC0
dcb $80046080-endopC0,0
opcodeC1

		addu	t8,t8,s1
		andi	t8,t8,$FF
		or		t8,t8,s7
		lbu		t9,$0001(t8)
		lbu		t8,$0000(t8)
		addu	s4,s4,$02
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$48
		sltu	t0,s0,a1		;Carry
		xor		t0,t0,s5
		subu	t6,s0,a1
		andi	t6,t6,$FF
		sltu	t1,t6,s5		;Zero
		srl		t6,t6,$07		;sigN

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$C2
;---------------------------------------------
endopC1
dcb $80046100-endopC1,0
opcodeC2
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$C3
;---------------------------------------------
endopC2
dcb $80046180-endopC2,0
opcodeC3
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$C4  ins=CPY  addr=zero page
;---------------------------------------------
endopC3
dcb $80046200-endopC3,0
opcodeC4
		
		or		t9,t8,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$24

		sltu	t0,s2,t8		;Carry
		xor		t0,t0,s5
		subu	t6,s2,t8
		andi	t6,t6,$FF
		sltu	t1,t6,s5		;Zero
		srl		t6,t6,$07		;sigN

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$C5  ins=CMP  addr=zero page
;---------------------------------------------
endopC4
dcb $80046280-endopC4,0
opcodeC5
		
		or		t9,t8,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$24

		sltu	t0,s0,t8		;Carry
		xor		t0,t0,s5
		subu	t6,s0,t8
		andi	t6,t6,$FF
		sltu	t1,t6,s5		;Zero
		srl		t6,t6,$07		;sigN

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$C6  ins=DEC  addr=zero page
;---------------------------------------------
endopC5
dcb $80046300-endopC5,0
opcodeC6
		
		or		t9,t8,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$3C
		subiu	t8,t8,$01
		andi	t8,t8,$FF
		sltu	t1,t8,s5		;zero
		srl		t6,t8,$07		;sign

		sb		t8,$0000(t9)

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$C7
;---------------------------------------------
endopC6
dcb $80046380-endopC6,0
opcodeC7
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$C8  ins=INY  addr=implied
;---------------------------------------------
endopC7
dcb $80046400-endopC7,0
opcodeC8

		addiu	s4,s4,$01

		subiu	t7,t7,$18

		addiu	s2,s2,$01
		andi	s2,s2,$FF
		sltu	t1,s2,s5		;zero
		srl		t6,s2,$07		;sign

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$C9  ins=CMP  addr=immediate
;---------------------------------------------
endopC8
dcb $80046480-endopC8,0
opcodeC9

		addiu	s4,s4,$02

		subiu	t7,t7,$18

		sltu	t0,s0,t8		;Carry
		xor		t0,t0,s5
		subu	t6,s0,t8
		andi	t6,t6,$00FF
		sltu	t1,t6,s5		;Zero
		srl		t6,t6,$07		;sigN

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$CA  ins=DEX  addr=implied
;---------------------------------------------
endopC9
dcb $80046500-endopC9,0
opcodeCA

		addiu	s4,s4,$01

		subiu	t7,t7,$18

		subiu	s1,s1,$01
		andi	s1,s1,$FF
		sltu	t1,s1,s5		;zero
		srl		t6,s1,$07		;sign

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$CB
;---------------------------------------------
endopCA
dcb $80046580-endopCA,0
opcodeCB
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$CC  ins=CPY  addr=absolute
;---------------------------------------------
endopCB
dcb $80046600-endopCB,0
opcodeCC

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9
		subiu	t7,t7,$30

		sltu	t0,s2,a1		;Carry
		xor		t0,t0,s5
		subu	t6,s2,a1
		andi	t6,t6,$FF
		sltu	t1,t6,s5		;Zero
		srl		t6,t6,$07		;sigN

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$CD  ins=CMP  addr=absolute
;---------------------------------------------
endopCC
dcb $80046680-endopCC,0
opcodeCD

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9
		subiu	t7,t7,$30

		sltu	t0,s0,a1		;Carry
		xor		t0,t0,s5
		subu	t6,s0,a1
		andi	t6,t6,$FF
		sltu	t1,t6,s5		;Zero
		srl		t6,t6,$07		;sigN

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$CE  ins=DEC  addr=absolute
;---------------------------------------------
endopCD
dcb $80046700-endopCD,0
opcodeCE

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9
		subiu	t7,t7,$48

		subiu	a1,a1,$01
		andi	a1,a1,$FF
		sltu	t1,a1,s5		;zero
		srl		t6,a1,$07		;sign

		ori		t9,t9,$8000
		jalr	t9
		nop

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$CF
;---------------------------------------------
endopCE
dcb $80046780-endopCE,0
opcodeCF
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$D0  ins=BNE  addr=relative
;---------------------------------------------
endopCF
dcb $80046800-endopCF,0
opcodeD0

		addiu	s4,s4,$02

		addu	s4,s4,t9
		beqz	t1,postOp
		subiu	t7,t7,$24

		addiu	t7,t7,$0C
		subu	s4,s4,t9
		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$D1  ins=CMP  addr=indirect Y
;---------------------------------------------
endopD0
dcb $80046880-endopD0,0
opcodeD1

		or		t9,t8,s7
		lbu		t8,$0000(t9)
		lbu		t9,$0001(t9)
		addiu	s4,s4,$02
		addu	t8,t8,s2
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$3C

		sltu	t0,s0,a1		; Carry
		xor		t0,t0,s5
		subu	t6,s0,a1
		andi	t6,t6,$00FF
		sltu	t1,t6,s5		; Zero
		srl		t6,t6,$07		; sigN

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$D2
;---------------------------------------------
endopD1
dcb $80046900-endopD1,0
opcodeD2
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$D3
;---------------------------------------------
endopD2
dcb $80046980-endopD2,0
opcodeD3
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$D4
;---------------------------------------------
endopD3
dcb $80046A00-endopD3,0
opcodeD4
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$D5  ins=CMP  addr=zero page X
;---------------------------------------------
endopD4
dcb $80046A80-endopD4,0
opcodeD5

		addu	t9,t8,s1
		andi	t9,t9,$FF
		or		t9,t9,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$30

		sltu	t0,s0,t8		;Carry
		xor		t0,t0,s5
		subu	t6,s0,t8
		andi	t6,t6,$FF
		sltu	t1,t6,s5		;Zero
		srl		t6,t6,$07		;sigN

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$D6  ins=DEC  addr=zero page X
;---------------------------------------------
endopD5
dcb $80046B00-endopD5,0
opcodeD6

		addu	t9,t8,s1
		andi	t9,t9,$FF
		or		t9,t9,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$48

		subu	t8,t8,s5
		andi	t8,t8,$FF
		sltu	t1,t8,s5		;zero
		srl		t6,t8,$07		;sign

		sb		t8,$0000(t9)

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$D7
;---------------------------------------------
endopD6
dcb $80046B80-endopD6,0
opcodeD7
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$D8  ins=CLD  addr=implied
;---------------------------------------------
endopD7
dcb $80046C00-endopD7,0
opcodeD8

		addiu	s4,s4,$01

		subiu	t7,t7,$18
		sb		zero,$1805(s7)	;store decimal flag off

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$D9  ins=CMP  addr=absolute indexed Y
;---------------------------------------------
endopD8
dcb $80046C80-endopD8,0
opcodeD9

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		addu	t8,t8,s2
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$30

		sltu	t0,s0,a1		;Carry
		xor		t0,t0,s5
		subu	t6,s0,a1
		andi	t6,t6,$FF
		sltu	t1,t6,s5		;Zero
		srl		t6,t6,$07		;sigN

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$DA
;---------------------------------------------
endopD9
dcb $80046D00-endopD9,0
opcodeDA
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$DB
;---------------------------------------------
endopDA
dcb $80046D80-endopDA,0
opcodeDB
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$DC
;---------------------------------------------
endopDB
dcb $80046E00-endopDB,0
opcodeDC
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$DD  ins=CMP  addr=absolute indexed X
;---------------------------------------------
endopDC
dcb $80046E80-endopDC,0
opcodeDD

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		addu	t8,t8,s1
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$30

		sltu	t0,s0,a1		;Carry
		xor		t0,t0,s5
		subu	t6,s0,a1
		andi	t6,t6,$FF
		sltu	t1,t6,s5		;Zero
		srl		t6,t6,$07		;sigN

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$DE  ins=DEC  addr=absolute indexed X
;---------------------------------------------
endopDD
dcb $80046F00-endopDD,0
opcodeDE

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		addu	t8,t8,s1
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$54

		subu	a1,a1,s5
		andi	a1,a1,$FF
		sltu	t1,a1,s5		;zero
		srl		t6,a1,$07		;sign

		ori		t9,t9,$8000
		jalr	t9
		nop

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$DF
;---------------------------------------------
endopDE
dcb $80046F80-endopDE,0
opcodeDF
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$E0  ins=CPX  addr=immediate
;---------------------------------------------
endopDF
dcb $80047000-endopDF,0
opcodeE0

		addiu	s4,s4,$02

		subiu	t7,t7,$18

		sltu	t0,s1,t8		;Carry
		xor		t0,t0,s5
		subu	t6,s1,t8
		andi	t6,t6,$00FF
		sltu	t1,t6,s5		;Zero
		srl		t6,t6,$07		;sigN

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$E1  ins=SBC  addr=indirect X
;---------------------------------------------
endopE0
dcb $80047080-endopE0,0
opcodeE1

		addu	t8,t8,s1
		andi	t8,t8,$FF
		or		t8,t8,s7
		lbu		t9,$0001(t8)
		lbu		t8,$0000(t8)
		addu	s4,s4,$02
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$48

		xori	a1,a1,$FF
		addu	s0,s0,a1
		addu	s0,s0,t0
		srl		t0,s0,$08		;Carry
		andi	s0,s0,$FF
		srl		t6,s0,$07		;negetive
		sltu	t1,s0,s5		;zero

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$E2
;---------------------------------------------
endopE1
dcb $80047100-endopE1,0
opcodeE2
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$E3
;---------------------------------------------
endopE2
dcb $80047180-endopE2,0
opcodeE3
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$E4  ins=CPX  addr=zero page
;---------------------------------------------
endopE3
dcb $80047200-endopE3,0
opcodeE4
		
		or		t9,t8,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$24

		sltu	t0,s1,t8		;Carry
		xor		t0,t0,s5
		subu	t6,s1,t8
		andi	t6,t6,$FF
		sltu	t1,t6,s5		;Zero
		srl		t6,t6,$07		;sigN

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$E5  ins=SBC  addr=zero page
;---------------------------------------------
endopE4
dcb $80047280-endopE4,0
opcodeE5
		
		or		t9,t8,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02
		
		subiu	t7,t7,$24
		
		xori	t8,t8,$FF
		addu	s0,s0,t8
		addu	s0,s0,t0
		srl		t0,s0,$08		;Carry
		andi	s0,s0,$FF
		srl		t6,s0,$07		;negetive
		sltu	t1,s0,s5		;zero

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$E6  ins=INC  addr=zero page
;---------------------------------------------
endopE5
dcb $80047300-endopE5,0
opcodeE6
		
		or		t9,t8,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$3C

		addu	t8,t8,s5
		andi	t8,t8,$FF
		sltu	t1,t8,s5		;zero
		srl		t6,t8,$07		;sign

		sb		t8,$0000(t9)
		
		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$E7
;---------------------------------------------
endopE6
dcb $80047380-endopE6,0
opcodeE7
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$E8  ins=INX  addr=implied
;---------------------------------------------
endopE7
dcb $80047400-endopE7,0
opcodeE8

		addiu	s4,s4,$01

		subiu	t7,t7,$18

		addiu	s1,s1,$01
		andi	s1,s1,$FF
		sltu	t1,s1,s5		;zero
		srl		t6,s1,$07		;sign

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$E9  ins=SBC  addr=immediate
;---------------------------------------------
endopE8
dcb $80047480-endopE8,0
opcodeE9

		addiu	s4,s4,$02
		
		subiu	t7,t7,$18
		
		xori	t8,t8,$FF
		addu	s0,s0,t8
		addu	s0,s0,t0
		srl		t0,s0,$08		;Carry
		andi	s0,s0,$FF
		srl		t6,s0,$07		;negetive
		sltu	t1,s0,s5		;zero

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$EA  ins=NOP  addr=implied
;---------------------------------------------
endopE9
dcb $80047500-endopE9,0
opcodeEA

		addiu	s4,s4,$01

		subiu	t7,t7,$18
		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$EB
;---------------------------------------------
endopEA
dcb $80047580-endopEA,0
opcodeEB
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$EC  ins=CPX  addr=absolute
;---------------------------------------------
endopEB
dcb $80047600-endopEB,0
opcodeEC

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9
		subiu	t7,t7,$30

		sltu	t0,s1,a1		;Carry
		xor		t0,t0,s5
		subu	t6,s1,a1
		andi	t6,t6,$FF
		sltu	t1,t6,s5		;Zero
		srl		t6,t6,$07		;sigN

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$ED  ins=SBC  addr=absolute
;---------------------------------------------
endopEC
dcb $80047680-endopEC,0
opcodeED

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9
		subiu	t7,t7,$30

		xori	a1,a1,$FF
		addu	s0,s0,a1
		addu	s0,s0,t0
		srl		t0,s0,$08		;Carry
		andi	s0,s0,$FF
		srl		t6,s0,$07		;negetive
		sltu	t1,s0,s5		;zero

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$EE  ins=INC  addr=absolute
;---------------------------------------------
endopED
dcb $80047700-endopED,0
opcodeEE

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9
		subiu	t7,t7,$48

		addu	a1,a1,s5
		andi	a1,a1,$FF
		sltu	t1,a1,s5		;zero
		srl		t6,a1,$07		;sign

		ori		t9,t9,$8000
		jalr	t9
		nop

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$EF
;---------------------------------------------
endopEE
dcb $80047780-endopEE,0
opcodeEF
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$F0  ins=BEQ  addr=relative
;---------------------------------------------
endopEF
dcb $80047800-endopEF,0
opcodeF0

		addiu	s4,s4,$02

		addu	s4,s4,t9
		bnez	t1,postOp
		subiu	t7,t7,$24

		addiu	t7,t7,$0C
		subu	s4,s4,t9
		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$F1  ins=SBC  addr=indirect Y
;---------------------------------------------
endopF0
dcb $80047880-endopF0,0
opcodeF1

		or		t9,t8,s7
		lbu		t8,$0000(t9)
		lbu		t9,$0001(t9)
		addiu	s4,s4,$02
		addu	t8,t8,s2
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9
		
		subiu	t7,t7,$3C
		
		xori	a1,a1,$FF
		addu	s0,s0,a1
		addu	s0,s0,t0
		srl		t0,s0,$08		;Carry
		andi	s0,s0,$FF
		srl		t6,s0,$07		;negetive
		sltu	t1,s0,s5		;zero

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$F2
;---------------------------------------------
endopF1
dcb $80047900-endopF1,0
opcodeF2
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$F3
;---------------------------------------------
endopF2
dcb $80047980-endopF2,0
opcodeF3
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$F4
;---------------------------------------------
endopF3
dcb $80047A00-endopF3,0
opcodeF4
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$F5  ins=SBC  addr=zero page X
;---------------------------------------------
endopF4
dcb $80047A80-endopF4,0
opcodeF5

		addu	t9,t8,s1
		andi	t9,t9,$FF
		or		t9,t9,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02
		
		subiu	t7,t7,$30
		
		xori	t8,t8,$FF
		addu	s0,s0,t8
		addu	s0,s0,t0
		srl		t0,s0,$08		;Carry
		andi	s0,s0,$FF
		srl		t6,s0,$07		;negetive
		sltu	t1,s0,s5		;zero

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$F6  ins=INC  addr=zero page X
;---------------------------------------------
endopF5
dcb $80047B00-endopF5,0
opcodeF6

		addu	t9,t8,s1
		andi	t9,t9,$FF
		or		t9,t9,s7
		lbu		t8,$0000(t9)
		addiu	s4,s4,$02

		subiu	t7,t7,$48

		addiu	t8,t8,$01
		andi	t8,t8,$FF
		sltu	t1,t8,s5		;zero
		srl		t6,t8,$07		;sign

		sb		t8,$0000(t9)

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$F7
;---------------------------------------------
endopF6
dcb $80047B80-endopF6,0
opcodeF7
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$F8  ins=SED  addr=implied
;---------------------------------------------
endopF7
dcb $80047C00-endopF7,0
opcodeF8

		addiu	s4,s4,$01

		subiu	t7,t7,$18

		li		t8,$08
		sb		t8,$1805(s7)	;store decimal flag on

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$F9  ins=SBC  addr=absolute indexed Y
;---------------------------------------------
endopF8
dcb $80047C80-endopF8,0
opcodeF9

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		addu	t8,t8,s2
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$30

		xori	a1,a1,$FF
		addu	s0,s0,a1
		addu	s0,s0,t0
		srl		t0,s0,$08		;Carry
		andi	s0,s0,$FF
		srl		t6,s0,$07		;negetive
		sltu	t1,s0,s5		;zero

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$FA
;---------------------------------------------
endopF9
dcb $80047D00-endopF9,0
opcodeFA
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$FB
;---------------------------------------------
endopFA
dcb $80047D80-endopFA,0
opcodeFB
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$FC
;---------------------------------------------
endopFB
dcb $80047E00-endopFB,0
opcodeFC
		break
		j		postOp
		nop

;---------------------------------------------
; opcode=$FD  ins=SBC  addr=absolute indexed X
;---------------------------------------------
endopFC
dcb $80047E80-endopFC,0
opcodeFD

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		addu	t8,t8,s1
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$30

		xori	a1,a1,$FF
		addu	s0,s0,a1
		addu	s0,s0,t0
		srl		t0,s0,$08		;Carry
		andi	s0,s0,$FF
		srl		t6,s0,$07		;negetive
		sltu	t1,s0,s5		;zero

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$FE  ins=INC  addr=absolute indexed X
;---------------------------------------------
endopFD
dcb $80047F00-endopFD,0
opcodeFE

		lbu		t9,$0002(at)
		addiu	s4,s4,$03
		addu	t8,t8,s1
		srl		at,t8,$08
		andi	t8,t8,$FF
		addu	t9,t9,at
		andi	t9,t9,$FF
		ori		t9,t9,ADDR_OR_READ
		sll		t9,t9,$07
		jalr	t9

		subiu	t7,t7,$54

		addiu	a1,a1,$01
		andi	a1,a1,$FF
		sltu	t1,a1,s5		;zero
		srl		t6,a1,$07		;sign

		ori		t9,t9,$8000
		jalr	t9
		nop

		bgtz	t7,execLoop
		addu	at,fp,s4
		j		postOp3
		addiu	t7,t7,$0553

;---------------------------------------------
; opcode=$FF
;---------------------------------------------
endopFE
dcb $80047F80-endopFE,0
opcodeFF
		break
		j		postOp
		nop

endopFF
dcb $80047FFC-endopFF,0

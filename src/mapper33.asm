map33write8 ; t8 = address, $a1 = data
	sw		ra,saveFP

	andi		at,t8,$F
	li		v1,$1
	beq		at,v1,map33_8001
	nop
	
	li		v1,$2
	beq		at,v1,map33_8002
	nop
	
	li		v1,$3
	beq		at,v1,map33_8003
	nop

map33_8000
	andi		v1,a1,$40
	srl		v1, 6
	la		a0,map1mirrors+2
	addu	a0,a0,v1
	lbu		a0,$0000(a0)
	sb		s5,needToRender
	sb		a0,mirrorSel

	andi		a1, $3F
	jal		bankSwitch
	li		a0,4

	j		map33return
	nop
	
map33_8001
	andi		a1, $3F
	jal		bankSwitch
	li		a0,5

	j		map33return
	nop
	
map33_8002
	sll		a0,a1,$01
	
	jal		bufLoadVROM
	li		a1,$00
	jal		bufLoadVROM
	nop

	j		map33return
	nop
	
map33_8003
	sll		a0,a1,$01
	
	jal		bufLoadVROM
	li		a1,$02
	jal		bufLoadVROM
	nop

	j		map33return
	nop
	
map33writeA
	sw		ra,saveFP

	andi		at,t8,$F
	li		v1,$1
	beq		at,v1,map33_A001
	nop
	
	li		v1,$2
	beq		at,v1,map33_A002
	nop
	
	li		v1,$3
	beq		at,v1,map33_A003
	nop

map33_A000
	move	a0,a1
	jal		bufLoadVROM
	li		a1,$04

	j		map33return
	nop
	
map33_A001
	move	a0,a1
	jal		bufLoadVROM
	li		a1,$05

	j		map33return
	nop
	
map33_A002
	move	a0,a1
	jal		bufLoadVROM
	li		a1,$06
	
	j		map33return
	nop
	
map33_A003
	move	a0,a1
	jal		bufLoadVROM
	li		a1,$07

map33return
	lw ra,saveFP
	nop
	jr ra
	nop

map33writeC
	jr ra
	nop
	
map33writeE
	jr ra
	nop

	
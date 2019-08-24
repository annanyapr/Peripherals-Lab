cpu "8085.tbl"
hof "int8"

GTHEX: EQU 030EH
OUTPUT: EQU 0389H
HXDSP: EQU 034FH
RDKBD: EQU 03BAH
CLEAR: EQU 02BEH

org 9000h

LDA 8200h
MOV H,A
MVI A,8BH
OUT 03H

FLOOR0:
	MVI B,01H
	MVI A,00H 
	STA 8202H
	OUT 00H
	CALL DELAY 
	IN 01H
	ANA H
	CMP H 
	JZ BOSS
	IN 01H
	CPI 00H 
	JZ FLOOR0
	JZ FLOOR1

FLOOR1:
	MVI A,01H 
	STA 8202H
	OUT 00H
	CALL DELAY 
	IN 01H
	ANI 01H
	CPI 01H
	JZ FLOOR1
	IN 01H
	ANA H
	CMP H 
	JZ BOSS
	MOV A,B
	CPI 00H 
	JZ FLOOR0
	IN 01H
	CPI 01H
	MVI B,00H
	JC FLOOR0
	JZ FLOOR1
	MVI B,01H
	JMP FLOOR2

FLOOR2:
	MVI A,02H 
	STA 8202H
	OUT 00H
	CALL DELAY 
	IN 01H
	ANI 02H
	CPI 02H
	JZ FLOOR2
	IN 01H
	ANA H
	CMP H 
	JZ BOSS
	MOV A,B
	CPI 00H 
	JZ FLOOR1
	IN 01H
	CPI 02H
	MVI B,00H
	JC FLOOR1
	JZ FLOOR2
	MVI B,01H
	JMP FLOOR3

FLOOR3:
	MVI A,04H 
	STA 8202H
	OUT 00H
	CALL DELAY 
	IN 01H
	ANI 04H
	CPI 04H
	JZ FLOOR3
	IN 01H
	ANA H
	CMP H 
	JZ BOSS
	MOV A,B
	CPI 00H 
	JZ FLOOR2
	IN 01H
	CPI 04H
	MVI B,00H
	JC FLOOR2
	JZ FLOOR3
	MVI B,01H
	JMP FLOOR4

FLOOR4:
	MVI A,08H 
	STA 8202H
	OUT 00H
	CALL DELAY 
	IN 01H
	ANI 08H
	CPI 08H
	JZ FLOOR4
	IN 01H
	ANA H
	CMP H 
	JZ BOSS
	MOV A,B
	CPI 00H 
	JZ FLOOR3
	IN 01H
	CPI 08H
	MVI B,00H
	JC FLOOR3
	JZ FLOOR4
	MVI B,01H
	JMP FLOOR5

FLOOR5:
	MVI A,10H 
	STA 8202H
	OUT 00H
	CALL DELAY 
	IN 01H
	ANI 10H
	CPI 10H
	JZ FLOOR5
	IN 01H
	ANA H
	CMP H 
	JZ BOSS
	MOV A,B
	CPI 00H 
	JZ FLOOR4
	IN 01H
	CPI 10H
	MVI B,00H
	JC FLOOR4
	JZ FLOOR5
	MVI B,01H
	JMP FLOOR6

FLOOR6:
	MVI A,20H 
	STA 8202H
	OUT 00H
	CALL DELAY 
	IN 01H
	ANI 20H
	CPI 20H
	JZ FLOOR6
	IN 01H
	ANA H
	CMP H 
	JZ BOSS
	MOV A,B
	CPI 00H 
	JZ FLOOR5
	IN 01H
	CPI 20H
	MVI B,00H
	JC FLOOR5
	JZ FLOOR6
	MVI B,01H
	JMP FLOOR7

FLOOR7:
	MVI A,40H 
	STA 8202H
	OUT 00H
	CALL DELAY 
	IN 01H
	ANI 40H
	CPI 40H
	JZ FLOOR7
	IN 01H
	ANA H
	CMP H 
	JZ BOSS
	MOV A,B
	CPI 00H 
	JZ FLOOR6
	IN 01H
	ANI 0C0H
	CPI 40H
	MVI B,00H
	JC FLOOR6
	JZ FLOOR7
	MVI B,01H
	JMP FLOOR8

FLOOR8:
	MVI B, 00H
	MVI A,80H 
	STA 8202H
	OUT 00H
	CALL DELAY 
	IN 01H
	ANI 80H
	CPI 80H
	JZ FLOOR8
	IN 01H
	ANA H
	CMP H 
	JZ BOSS
	IN 01H
	ANI 080H
	CPI 80H	
	JC FLOOR7
	JZ FLOOR8

DELAY:
	MVI C,03H
OUTLOOP:
	LXI D,0AF00H
INLOOP:
	DCX D		; decrease the D-E pair by one
	MOV A,D
	ORA E		; logical or with content of A
	JNZ INLOOP
	DCR C
	JNZ OUTLOOP
	RET

BOSS:				;BOSS subroutine
	LDA 8202H
	CMP H			;Compares BOSS floor with current floor(8202H memory location)
	JC HIGHBOSS		;If boss floor is higher than present location, goes to HIGHBOSS subroutine
	JZ Wait1			;If boss is at same floor jumps to Wait1 subroutine
	JMP LOWBOSS		;If boss floor is lower than present floror, jumps to LOWBOSS subroutine
HIGHBOSS:
	LDA 8202H		;changes elevator position to boss position(incrementing) A, then jumps to Wait1
	CPI 00H
	JZ INCREMENT		;ensures A has a 1 bit somewhere in its 8 bits (highboss can be called from floor0 as well)
	RLC			;logical left circular shift of accumulator(A)
	STA 8202H
RETURN:	OUT 00H
	CALL DELAY
	LDA 8202H
	CMP H
	JC HIGHBOSS
	JZ Wait1
LOWBOSS:			;changes elevator position to boss position(decrementing) A, then jumps to Wait1
	LDA 8202H
	RRC
	STA 8202H
	OUT 00H
	CALL DELAY
	LDA 8202H
	CMP H
	JZ Wait1
	JMP LOWBOSS 	
Wait1:				;Wait1s for boss floor request to go low, then goes to TOZERO subroutine
	IN 01H
	ANA H
	CMP H	
	JZ Wait1
	CALL DELAY
TOZERO:				;Takes elevator with boss in it to ground floor (floor0)
	LDA 8202H
	RRC			;logical right shift of A (circular)
	STA 8202H
	OUT 00H
	CALL DELAY
	LDA 8202H
	CPI 01H
	JZ FLOOR0		;Jumps to floor0 subroutine after boss reaches floor0
	JMP TOZERO
INCREMENT:			;INCREMENTS location 8202H (for HIGHBOSS call from floor0)
	ADI 01H
	STA 8202H
	JMP RETURN

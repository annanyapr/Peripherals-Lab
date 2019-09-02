cpu "8085.tbl"
hof "int8"

GTHEX: EQU 030EH          ;      This routinue collects the hex digits entered from keyboard
OUTPUT: EQU 0389H         ;      Outputs characters to display
CLEAR: EQU 02BEH          ;      Clears the display 
UPDDT: EQU 044CH          ;      Update data field display   
UPDAD: EQU 0440H          ;      Update the address field display 
CURAD: EQU 8FEFH          ;      Displays the number stored in the address field of UPDAD
CURDT: EQU 8FF1H          ;      Stores 8bit data and shows in the Data display.

org 9000h 



CALL CLEAR
MVI A,00H
MVI B,00H
Call GTHEX   ; Take input for current time
MOV H,D
MOV L,E
SHLD 8200H
CALL CLEAR

; DIVIDEND FOR SQUARE WAVE
LXI H,07D00H
SHLD 8300H
CALL DIVISION
LHLD 8400H
SHLD 8202H

; DIVIDEND FOR STEP WAVE
LXI H,02400H
SHLD 8300H
CALL DIVISION
LHLD 8400H
SHLD 8204H

; DIVIDEND FOR SYMMETRIC STEP WAVE
LXI H,01200H
SHLD 8300H
CALL DIVISION
LHLD 8400H
SHLD 8206H

; DIVIDEND FOR SAWTOOTH WAVE
LXI H,03A8H
SHLD 8300H
CALL DIVISION
LHLD 8400H
SHLD 8208H

; DIVIDEND FOR TRIANGLE WAVE
LXI H,02A4H
SHLD 8300H
CALL DIVISION
LHLD 8400H
SHLD 820AH


MVI A,8BH		;setting 8255 to mode0 and port A o/p and port B,C i/p
MVI B,00H
OUT 03H

; FUNCTION TO CHOOOSE THE WAVEFORM BASED ON INPUTY FROM LCI
; DIP SWITCHES ARE IN ORDER
; 1ST--> SQUARE
; 2ND--> TRIANGULAR
; 3RD--> SWATOOTH
; 4TH--> STAIRCASE
; 5TH--> SYMSTAIRCASE
CHOOSEWAVE:
	IN 01H

	CPI 80H		 
	JZ SQUARE

	CPI 40H		 
	JZ TRIANGULAR


	CPI 20H		 
	JZ SAWTOOTH

	CPI 10H		 
	JZ STAIRCASE

	CPI 08H		 
	JZ SYMSTAIRCASE


MVI A,80H
OUT 43H


SQUARE:
	MVI A,00H
	STA 9500H
	LHLD 8202H
	MOV B,H 
	MOV C,L

	LOOP1:
		LDA 9500H
		OUT 40H
		DCX B
		MOV A,B                   
		ORA C
		JNZ LOOP1

	MVI A,0FFH
	STA 9500H
	LHLD 8202H
	MOV B,H 
	MOV C,L

	LOOP2:
	LDA 9500H
	OUT 40H
	DCX B
	MOV A,B                   
	ORA C
	JNZ LOOP2
JMP CHOOSEWAVE


TRIANGULAR:
MVI A,00H
STA 9500H
	TRAINGULARTEMP:
		LDA 9500H
		ADI 06H
		OUT 40H
		STA 9500H
		LHLD 820AH
		MOV B,H 
		MOV C,L
		TRIDELAY:
			LDA 9500H
			OUT 40H
			DCX B
			MOV A,B                   
			ORA C
		JNZ TRIDELAY
	LDA 9500H
	CPI 0FCH
	JNZ TRAINGULARTEMP

	TLOOP2:
		LDA 9500H
		SBI 06H
		OUT 40H
		STA 9500H
		LHLD 820AH
		MOV B,H 
		MOV C,L
		TRIDELAY2:
			LDA 9500H
			OUT 40H
			DCX B
			MOV A,B                   
			ORA C
		JNZ TRIDELAY2
		LDA 9500H
		CPI 00H
		JNZ TLOOP2

JMP CHOOSEWAVE


SAWTOOTH:
	MVI A,00H
	STA 9500H
	SAWTEMP:
		LDA 9500H
		ADI 04H
		OUT 40H
		STA 9500H
		LHLD 8208H
		MOV B,H 
		MOV C,L
		SAWDELAY:
			LDA 9500H
			OUT 40H
			DCX B
			MOV A,B                   
			ORA C
		JNZ SAWDELAY
	LDA 9500H
	CPI 0FCH
	JNZ SAWTEMP
JMP CHOOSEWAVE



STAIRCASE:
	MVI A,00H
	STA 9500H
	STAIRTEMP:
		LHLD 8204H
		MOV B,H 
		MOV C,L
		STAIRDELAY:
			LDA 9500H
			OUT 40H
			DCX B
			MOV A,B                   
			ORA C
		JNZ STAIRDELAY
		LDA 9500H
		ADI 20H
		CPI 0E0H
		STA 9500H
	JNZ STAIRTEMP

	MOV A,00H
	STA 9500H
	OUT 40H

JMP CHOOSEWAVE



SYMSTAIRCASE:
MVI A,00H
STA 9500H
SYMSTAIRTEMP:
	LHLD 8206H
	MOV B,H 
	MOV C,L
	SYMSTAIRDELAY:
		LDA 9500H
		OUT 40H
		DCX B
		MOV A,B                   
		ORA C
	JNZ SYMSTAIRDELAY

		LDA 9500H
		ADI 20H
		CPI 0E0H
		STA 9500H
	JNZ SYMSTAIRTEMP

SYMSTAIRTEMP2:
	LHLD 8206H
	MOV B,H 
	MOV C,L
	SYMSTAIRDELAY2:
		LDA 9500H
		OUT 40H
		DCX B
		MOV A,B                   
		ORA C
		JNZ SYMSTAIRDELAY2
	LDA 9500H
	SBI 20H
	STA 9500H
	JNZ SYMSTAIRTEMP2

JMP CHOOSEWAVE



DIVISION:

mvi b,00h ; BC will have quotient
mvi c,00h

LHLD 8200H
MOV D,H 
MOV E,L 


LHLD 8300H
label2:  ; repeated subtraction 
mov a,l
sub e
mov l,a
mov a,h
sbb d
mov h,a
jc label1 ; when remainder becomes negative stop incrmenting quotient 
inx b
jmp label2

label1: 
dad d    ; add to HL pair , DE pair



MOV A,B
STA 8401H
MOV A,C
STA 8400H

RET  

RST 5
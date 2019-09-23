cpu "8085.tbl"
hof "int8"
org 9000h
RDKBD: EQU 03BAH
OUTPUT: EQU 0389H         ;      Outputs characters to display
CLEAR: EQU 02BEH          ;      Clears the display 
UPDDT: EQU 044CH          ;      Update data field display   
UPDAD: EQU 0440H          ;      Update the address field display 
CURAD: EQU 8FEFH          ;      Displays the number stored in the address field of UPDAD
CURDT: EQU 8FF1H          ;      Stores 8bit data and shows in the Data display.

MVI A,8BH                ; ports initialization for both peripherals.
OUT 43H

MVI A,80H
OUT 03H

MVI A,00H
STA 8600H

MVI A,00H
STA 8601H

START:

MVI D,00H 				 ; channel initialization
MVI E,00H
CALL CONVERT 			 ; converting analog to digital
LDA 8501H
CALL DELAY

LDA 8501H

CALL DISPLAY			 ; displaying the converted value on data position.


LDA 8501H   			 ; stroring the number at two locations, one for clockwise movement and other for anti-clockwise(return to 0)
STA 8600H
LDA 8501H
STA 8601H

MVI A,88H				 ; stepper motor initialization 

LOOP:
PUSH PSW    			 ; saving the state
OUT 00H
LDA 8600H     			 ; rotating it for no. of times stored in 8600.
CPI 00H 				 ; if no. of rotations left=0, call stop
JZ STOP
LDA 8600H
DCR A
JZ STOP
DCR A  					 ; else decrease the no. of rotations left
STA 8600H
LDA 8600H   
JZ STOP
CALL DELAY
POP PSW 				
RRC						 ; rotating it in clockwise manner.
JMP LOOP

STOP: 					; waits for a keyboard input.
CALL RDKBD

MVI A,88H 			 	; port initialization
LOOP2:
PUSH PSW 				; saving the state
OUT 00H
LDA 8601H 				; rotating the same number of times just in anti clockwise manner.
CPI 00H
JZ START
LDA 8601H
DCR A
JZ START
DCR A 
STA 8601H
LDA 8601H
JZ START
CALL DELAY
POP PSW
RLC						; doing in order to avoid drift
JMP LOOP2
JMP START


DELAY:    				; wasting time by looping in inloop and outloop
	MVI C,03H
OUTLOOP:
	LXI D,00FFH
INLOOP:  				; operated for 00ffh times.
	DCX D
	MOV A,D
	ORA E
	JNZ INLOOP
	DCR C
	JNZ OUTLOOP
	RET



CONVERT:                
	MVI A,00H 			; intilaize channel
	OUT 40H

	; START SIGNAL
	MVI A,20H			; assert for start signal
	OUT 40H
	
	NOP
	NOP
	
	; START PULSE OVER
	MVI A,00H      		; start pulse over
	OUT 40H


WAIT1:	
	IN 42H				; check EOC
	ANI 01H
	JNZ WAIT1 			; check until EOC goes down
WAIT2:
	IN 42H				; check EOC
	ANI 01H
	JZ WAIT2			; wait until EOC goes up

; READ SIGNAL
	MVI A,40H
	OUT 40H
	NOP

	IN 41H				; GET THE CONVERTED DATA FROM PORT B

	STA 8501H
	MVI A,00H 			; DEASSERT READ SIGNAL 
	ORA D
	OUT 40H
RET

DISPLAY:
		LXI H, 0000H 		; channel number i sstored in LS byte of ad. field
		Shld CURAD
		LDA 8501H			; digital value is stored in data field
		STA CURDT
		MVI B,00H
		CALL UPDAD 		; display without dot the ad. field
		MVI B,00H
		CALL UPDDT 		; get back reg D and E.
		RET

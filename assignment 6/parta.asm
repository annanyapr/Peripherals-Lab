
cpu "8085.tbl"
hof "int8"
org 9000h

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


MVI A,88H
LOOP:
PUSH PSW                 ; saving the state
OUT 00H
CALL CONVERT             ; converting analog to digital
LDA 8501H
MOV B,A 			
MVI A,0FFH				 ; subtracting the value from FF and running the delay loop for the new number of times.
SUB b
MOV C,A
STA 8500H				 ; for a larger value, delay has to be small and vice-versa.
CALL DELAY
CALL DISPLAY             ; displaying the converted value on data position.
POP PSW
RRC						 ; rotating clockwise
JMP LOOP


DELAY:                   ; delaying the whole process by square of value of number stored at 8500.
	LOOP1a: LDA 8500H  
	MOV E, A
	LOOP2a:  DCR E
	    JNZ LOOP2a
	    DCR C
	    JNZ LOOP1a
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
	STA 8501H			; SAVE A SO THAT WE CAN DEASSERT THE SIGNAL
	MVI A,00H 			; DEASSERT READ SIGNAL 
	OUT 40H
RET


DISPLAY:
		LXI H, 0000H 		; channel number i sstored in LS byte of ad. field
		Shld CURAD
		LDA 8501H
		STA CURDT
		MVI B,00H
		CALL UPDAD 		; display without dot the ad. field
		MVI B,00
		CALL UPDDT 		; get back reg D and E.
		RET

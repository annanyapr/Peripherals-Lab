cpu "8085.tbl"            ;      CPU Table monitor command
hof "int8"                ;      HEX Format

org 9000h                 ;      Puts location pointer at prompt at 9000

;Pneumonics
GTHEX: EQU 030EH          ;      This routinue collects the hex digits entered from keyboard
OUTPUT: EQU 0389H         ;      Outputs characters to display
CLEAR: EQU 02BEH          ;      Clears the display 
UPDDT: EQU 044CH          ;      Update data field display   
UPDAD: EQU 0440H          ;      Update the address field display 
CURAD: EQU 8FEFH          ;      Displays the number stored in the address field of UPDAD
CURDT: EQU 8FF1H          ;      Stores 8bit data and shows in the Data display.
RDKBD: EQU 03BAH
  
CALL CLEAR

; Take input for  timer (hour minute)
MVI A,00H
MVI B,00H
Call GTHEX   				
MOV H,D
MOV L,E
SHLD 9100H
Call CLEAR

; Take input for  timer (second)
MVI A,00H
MVI B,00H
Call GTHEX
MOV A, E
LHLD 9100H

; to wait for the keybord input to start the timer
STA CURDT 
SHLD CURAD 

CALL UPDAD                
CALL UPDDT  

CALL RDKBD 
	
LHLD CURAD
LDA CURDT

JMP SEC


MIN:                         
SHLD CURAD  			  ;     Store data in HL at address of CURAD 
MVI A,59H                

SEC:
                        
STA CURDT                 ;      Store content of Accumulator in CURDT
CALL UPDAD                ;      Update Address field display 

CALL UPDDT                ;      Show the data display
CALL DELAY                ;      Call function DELAY

;		check after each second if any interrupt is made
MVI A,0BH  				 
SIM						 ; Unmask the iterrupts 
EI						 ; enable the interrupt


LDA CURDT                  
MVI B,99H
ADD B                 	  ;      Increment the value of data display by 1
DAA                       
CPI 99H                   ;      Compare the value in accumulator with 99H
JNZ SEC                   ;      If the value in accumulator is not 99 then jump to SEC function 

;If the value of seconds hand is 00 it must be put to 59 and update Minutes hand.

LHLD CURAD

MOV A,L                   
MVI B,99H
ADD B                 
DAA                     
MOV L,A                  

CPI 99H                   ;      Compare the value in accumulator to 99H
JNZ MIN                   ;      If the value in accumulator is not 99H them jump to MIN function

;If the value of minutes hand is 00 it must be put to 59 and update Hours hand.

MVI L,59H                 
MOV A,H                   
MVI B,99H
ADD B                   
DAA                      
MOV H,A                   

CPI 99H                  
JNZ MIN                  
JMP END                 ;      Unconditional jump to END function 


DELAY:                    ;      Delay function
MVI C,03H                 

OUTLOOP:                  ;      OUTLOOP function
LXI D,0A700H               ;      Loads the value 9FFFH into DE register

INLOOP:                   ;      INLOOP function
DCX D                    
MOV A,D                   
ORA E                    
JNZ INLOOP                
DCR C                     
JNZ OUTLOOP               ;      As long as the memory of C is not 00H jump to OUTLOOP
RET                       ;      Return 

INTR:  						
	PUSH PSW			; Push the program status in stack
	CALL RDKBD 			; wait for the keyboard input
	POP PSW				; pop the program status from stack
	EI					; Enable the interrupt again 
	RET  				; rerturn to the called function


END:
RST 5
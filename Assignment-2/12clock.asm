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

  
CALL CLEAR

MVI A,00H
MVI B,00H
Call GTHEX   ; Take input for current time
MOV H,D
MOV L,E
JMP MIN

BEGIN: LXI H,0000H    ;      Begin funtion : loads 0000H into HL register

MIN:                      
SHLD CURAD                ;      Store data in HL at address of CURAD 
MVI A,00H                

SEC:                      
STA CURDT                 ;      Store content of Accumulator in CURDT
CALL UPDAD                ;      Update Address field display 

CALL UPDDT                ;      Show the data display
CALL DELAY                ;      Call function DELAY

LDA CURDT                  
ADI 01H                   ;      Increment the value of data display by 1
DAA                       
CPI 60H                   ;      Compare the value in accumulator with 60H
JNZ SEC                   ;      If the value in accumulator is not 60 then jump to SEC function 

;If the value of seconds hand is 60 it must be put to 0 and update Minutes hand.

LHLD CURAD                

MOV A,L                   
ADI 01H                  
DAA                     
MOV L,A                  

CPI 60H                   ;      Compare the value in accumulator to 60H
JNZ MIN                   ;      If the value in accumulator is not 60 them jump to MIN function

;If the value of minutes hand is 60 it must be put to 0 and update Hours hand.

MVI L,00H                 
MOV A,H                   
ADI 01H                   
DAA                      
MOV H,A                   

CPI 12H                   ;      Compare the value in accumulator to 12 ( max hour hand is 12 )
JNZ MIN                   ;      If the value in accumulator is not 12 jump to MIN function
JMP BEGIN                 ;      Unconditional jump to BEGIN function 

; If hours hand exceeds 11 we need to change it to 0

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
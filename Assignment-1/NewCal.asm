cpu "8085.tbl"
hof "int8"

org 9100h

mvi a,00h ; move immediate 
sta 9054h ; store A	
sta 9055h
sta 9056h
sta 9057h

; 01 - Add
; 02 - Sub
; 03 - Div
; 04 - Mul

lda 904fh	; Load A
mvi b,01h
cmp b       ; compare b with a 
jz add		

mvi b,02h
cmp b
jz sub

mvi b,03h
cmp b
jz div

mvi b,04h
cmp b
jz mul

add:

lda 9051h	
mov b,a
lda 9053h
add b
sta 9057h
lda 9050h
mov b,a
lda 9052h
adc b       ; add with carry bit
sta 9056h
mvi a, 00h  
adc a
sta 9055h
jmp bottom

sub:

lhld 9052h  ; load HL pair (9052-L , 9053- H)
xchg  ; exchange the values of DE and HL
lhld 9050h
mvi c,00h
mov a,h
sub d
sta 9057h
mov a,l
sbb e  ; subtract with borrow flag
sta 9056h
jmp bottom

div:

mvi b,00h ; BC will have quotient
mvi c,00h
lda 9052h
mov D, A
lda 9053h
mov E, A

lda 9050h
mov H, A
lda 9051h
mov L, A
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

mov A, H
sta 9056h
mov A, L
sta 9057h
mov A, b
sta 9054h
mov A, c
sta 9055h

jmp bottom


mul:

lda 9050h
mov H, A
lda 9051h
mov L, A
sphl  ; store hl in stack 
lda 9052h
mov D, A
lda 9053h
mov E, A
lxi H, 0000h  ; load pair immediate
lxi B, 0000h
label: dad SP  ; add the values stored in stack to HL
jnc lbl
inx B ; increment BC pair
lbl: dcx D  ; decrement DE pair
mov A,E
ora D  ; or the values of d with A
jnz label
mov A, L
mov L, H
mov H, A
shld 9056h ; store hl into memory (h-9057 l-9056)
mov L,B
mov H,C
shld 9054h


bottom:

RST 5

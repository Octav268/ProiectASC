assume cs:code, ds:data

data segment
    msg1         db 10, 'Introduceti date HEX (8-16 octeti): $'
    msg2         db 13, 10, 'Cuvantul C (BIN): $'
    msg3         db 13, 10, 'Sortat descrescator: $'
    msg4         db 13, 10, 'Octetul cu cei mai multi de 1: $'      ;mesaje pentru utilizator
    msg5         db 13, 10, 'Pozitia in sir: $'                     
    msg6         db 13, 10, 'Dupa rotiri (BIN): $'  
    msg7         db 13, 10, 'Dupa rotiri (HEX): $'
    msg8         db 13, 10, 'Eroare: Caractere invalide! $'
    msg9         db 13, 10, 'Eroare: Minim 8 octeti! $'
    cmd_exit     db 'exit', 0Dh                                     ;oprire fortata
    
    input_buffer db 50, 0, 50 dup(0)    ; buffer pentru citire cu 0Ah 
    valori       db 32 dup(0)           ; sirul de octeti dupa validare/conversie  
    C_rez        dw 0                   ; cuvantul C
    valori_shift db 32 dup(0)           ; sirul rezultat din sortare/rotire
    nr_octeti    db 0               
    max_bits     db 0               
    val_max_bits db 0                   ; variabile folosite pentru calculul aparitiilor lui 1       
    pos_max_bits db 0  
 
data ends

code segment
start:
    mov ax, data
    mov ds, ax

citire:
    call CURATA_BUFFER      ; pentru citiri repetate
    
    mov dx, offset msg1
    mov ah, 09h             ; mesaj de inceput
    int 21h 

    mov dx, offset input_buffer
    mov ah, 0Ah
    int 21h

    call VALIDARE_SI_EXIT   
    jc citire               
    
prelucrare:
    ; conversie din ASCII HEX in BIN
    lea si, input_buffer + 2
    lea di, valori
    mov cl, nr_octeti
    xor ch, ch           
    cld

conversie_loop:
    lodsb        
    call ascii_to_val
    shl al, 4          
    mov bl, al      ; salvare byte superior
    lodsb        
    call ascii_to_val
    or al, bl           
    stosb
    loop conversie_loop

    ;   cuvantul C: bitii 0-3: XOR, 4-7: OR, 8-15: suma modulo 256 
    lea si, valori
    mov cl, nr_octeti
    call CALCUL_C
    mov C_rez, ax    

    ;   sortare descrescatoare folosind BUBBLE SORT
    mov cl, nr_octeti
    dec cl              ; pentru n elemente facem n-1 comparatii

sort_i:
    push cx             ; salvam  primul contor pentru a nu l distruge in urmatorul loop
    lea si, valori
    mov cl, nr_octeti
    dec cl

sort_j:
    mov al, [si]
    mov bl, [si+1]      ; luam octeti consecutivi
    cmp al, bl
    jae no_swap       ; pentru egalitate nu trebuie modificat
    
    mov [si], bl    
    mov [si+1], al  


	;afisare cuvantul C
    mov dx, offset msg2
    mov ah, 09h
    int 21h
    mov ax, C_rez
    call print_bin16

    ; afisare sir sortat
    mov dx, offset msg3
    mov ah, 09h
    int 21h 
    lea si, valori
    mov cl, nr_octeti
    xor ch, ch
	afis_sort: 
    lodsb 
    call print_bin8 
    loop afis_sort


exit:
     mov ax, 4C00h
     int 21h

;----------------------------------------------

CALCUL_C PROC
    push bx
    push cx
    push dx
    push si
    
    xor dx, dx          ; DH = Suma, DL = OR
    mov bl, cl          ; Salvam nr_octeti original in BL
    xor ch, ch          ; Ne asiguram ca CH e zero pentru loop
    
calc_l:
    lodsb
    add dh, al
    mov ah, al
    and ah, 3Ch
    or dl, ah
    loop calc_l
    
    shr dl, 2
    shl dl, 4
    
    ; Resetam SI la inceputul sirului 'valori'
    sub si, bx          
    
    mov al, [si]        ; Primul element
    and al, 0Fh
    
    xor bh, bh
    add si, bx
    dec si              ; SI la ultimul element
    
    mov ah, [si]
    shr ah, 4
    
    xor al, ah
    and al, 0Fh
    or al, dl           ; Rezultat AL final
    
    mov ah, dh          ; Suma in AH
    
    pop si
    pop dx
    pop cx
    pop bx
    ret
CALCUL_C ENDP

VALIDARE_SI_EXIT proc
    mov al, input_buffer[1]
    cmp al, 4
    jne v_chars
    
    lea si, input_buffer[2]
    lea di, cmd_exit
    mov cx, 4
    cld
    repe cmpsb
    je e_p              ; Iesire daca e 'exit'

v_chars:
    lea si, input_buffer[2]
    mov cl, input_buffer[1]
    xor ch, ch
    jcxz e_l            ; Buffer gol
    xor bx, bx          ; BL numara caracterele hex valide
    
v_l:
    lodsb
    cmp al, ' '
    je v_n
    cmp al, '0'
    jb v_m
    cmp al, '9'
    jbe v_k
v_m:
    and al, 0DFh        ; Case insensitive
    cmp al, 'A'
    jb v_e
    cmp al, 'F'
    ja v_e
v_k:
    inc bl
v_n:
    loop v_l
    
    cmp bl, 16
    jb e_l              ; Eroare daca sunt < 8 octeti
    
    shr bl, 1
    mov nr_octeti, bl
    clc
    ret

v_e:
    mov dx, offset msg8
    jmp v_p
e_l:
    mov dx, offset msg9
v_p:
    mov ah, 09h
    int 21h
    stc
    ret
e_p:
    mov ax, 4C00h
    int 21h
VALIDARE_SI_EXIT endp

    ; Memoria buffer-ului este resetata la 0, input_buffer[0] setat la 50.
CURATA_BUFFER proc
    push ax
    push cx
    push di

    lea di, input_buffer
    mov cx, 52
    mov al, 0
    cld
    rep stosb
    mov input_buffer, 50

    pop di
    pop cxs
    pop ax
    ret
CURATA_BUFFER endp

ascii_to_val proc
    cmp al, '9'
    jbe d1
    and al, 0DFh
    sub al, 7
d1: 
    sub al, '0'
    ret
ascii_to_val endp
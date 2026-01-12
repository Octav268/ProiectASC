data segment
    buffer db 20          ; dimensiunea maxima a sirului
           db ?           ; numarul de caractere citite
           db 20 dup(?)   ; spatiu pentru caractere

    msg db 0Dh,0Ah,'Sirul introdus este: $'
data ends

code segment
start:
    ; Initializare segment date
    mov ax, data
    mov ds, ax

  
    mov ah, 09h
    lea dx, msg
    int 21h

    ; Citire sir de caractere
    mov ah, 0Ah
    lea dx, buffer
    int 21h

    ; Afisare sirul citit
    mov cl, [buffer+1]      ; CL = numarul de caractere citite
    mov si, offset buffer+2  ; SI = adresa primului caracter citit

print_loop:
    cmp cl, 0
    je done
    mov al, [si]
    mov ah, 0Eh              
    int 10h
    inc si
    dec cl
    jmp print_loop

done:
    ; Terminare program
    mov ah, 4Ch
    int 21h

code ends
end start

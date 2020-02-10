extern puts
extern printf
extern strlen

%define BAD_ARG_EXIT_CODE -1

section .data
filename: db "./input0.dat", 0
inputlen: dd 2263

fmtstr:            db "Key: %d",0xa, 0
usage:             db "Usage: %s <task-no> (task-no can be 1,2,3,4,5,6)", 10, 0
error_no_file:     db "Error: No input file %s", 10, 0
error_cannot_read: db "Error: Cannot read input file %s", 10, 0

section .text
global main

xor_strings:
        ; TODO TASK 1
        push ebp
        mov ebp, esp
        
        mov esi, [ebp + 8] ;folosesc esi pentru mesaj   
        mov edi, [ebp + 12] ;folosesc edi pentru cheie
          
xor_byte_by_byte:                
        mov al, byte [esi] ;iau un byte din esi si il pun in al
        cmp al, 0x00 ;verific daca am ajuns la sfarsit       
        je end_xor_strings ;daca da, ies din functie
        mov bl, byte [edi] ;iau un byte din edi si il pun in bl
        cmp bl, 0x00 ;verific daca am ajuns la sfarsit
        je end_xor_strings ;daca da, ies din functie
        xor al, bl ;fac xor byte cu byte intre mesaj si cheie         
        mov byte[esi], al ;suprascriu
        inc esi ;avansez in mesaj
        inc edi ;avansez in cheie
        jmp xor_byte_by_byte ;repet procesul

end_xor_strings:              
        leave
        ret
;===============================================================; 
rolling_xor:
	; TODO TASK 2
        push ebp
        mov ebp, esp
        
        mov esi, [ebp + 8] ;folosesc esi pentru mesaj
        mov ah, byte [esi] ;salvez in ah primul octet din mesaj, adica m1
    
rolling_xor_byte_by_byte:
        inc esi ;avansez in mesaj, ma mut pe octetul m2
        cmp byte[esi], 0x00 ;verific daca am ajuns la sfarsitul sirului
        je end_rolling_xor ;daca da, ies din functie
        mov bh, byte[esi] ;salvez pe c1 pentru urmatorul pas
        xor byte[esi], ah ;fac xor intre octetul curent si cel anterior
        mov ah, bh ;actualizez rezultatul 
        jmp rolling_xor_byte_by_byte ;repet procesul
    
end_rolling_xor:        
        leave 
        ret
;===============================================================;         
convert:
        push ebp 
        mov ebp, esp
        
        mov esi, [ebp + 8] ;folosesc esi pentru mesaj
        xor edx, edx ;contor pentru parcurgere din 2 in 2
        xor edi, edi ;contor pentru parcurgere din 1 in 1
              
move: 
        mov al, byte [esi + edx] ;folosesc al pentru cate doi octeti
        cmp al, 0x00 ;verific daca am ajuns la finalul sirului
        je end_xor_hex_strings ;daca da, am terminat
        mov ah, byte [esi + edx + 1] ;folosesc ah pentru un octet
        cmp al, '9' ;pentru a verifica daca e cifra
        jle digit ;daca da,sar la label-ul digit
        jg letter ;daca nu,inseamna ca e litera
        
cmp_for_ah:
        cmp ah, '9' ;pentru a verifica daca e cifra
        jle digit2 ;daca da,sar la label-ul digit2
        jge letter2 ;daca nu,inseamna ca e litera
        
repeat_process:     
        shl al, 4 ;inmultesc al cu 16 pentru urmatorii doi octeti
        add al, ah ;imi trebuie urmatorul mesaj
        mov byte [esi + edi], al ;suprascriu
        inc edi ;cresc edi
        add edx, 2 ;cresc edx (merge din 2 in 2)
        jmp move
        
digit: 
        sub al, '0' ;converteste din caracter in cifra
        jmp cmp_for_ah
      
letter:
        sub al, 'a'
        add al, 10
        jmp cmp_for_ah
    
digit2: 
        sub ah, '0' ;converteste din caracter in cifra
        jmp repeat_process
     
letter2:
        sub ah, 'a'
        add ah, 10
        jmp repeat_process

xor_hex_strings:
	; TODO TASK 3
        push ebp
        mov ebp, esp
        
        mov esi, [ebp + 8] ;folosesc esi pentru mesaj   
        mov edi, [ebp + 12] ;folosesc edi pentru cheie
         
xor_hex_byte_by_byte:                
        mov al, byte [esi] ;iau un byte din esi si il pun in al
        cmp al, 0x00 ;verific daca am ajuns la sfarsit       
        je end_xor_hex_strings ;daca da, ies din functie
        mov bl, byte [edi] ;iau un byte din edi si il pun in bl
        cmp bl, 0x00 ;verific daca am ajuns la final
        je end_xor_hex_strings ;daca da, ies din functie
        xor al, bl ;fac xor byte cu byte intre mesaj si cheie         
        mov byte[esi], al ;suprascriu
        inc esi ;avansez in mesaj
        inc edi ;avansez in cheie
        jmp xor_hex_byte_by_byte ;repeta procesul
            
end_xor_hex_strings:
        leave 
        ret
;===============================================================;

base32_to_value: ; daca e litera scade din aceasta valoarea ascii a lui 'A'
        push ebp ; daca e numar, scade '2' si aduna 26
        mov ebp, esp
        mov eax, [ebp + 8]
        sub eax, '='
        jz base32_to_value_exit ; daca este '=' se pune 0 in eax
        mov eax, [ebp + 8]
        cmp eax, 'A'
        jl base32_to_value_number
        sub eax, 'A'
        jmp base32_to_value_exit
base32_to_value_number:
        sub eax, '2'
        add eax, 26
base32_to_value_exit: ; rezultatul este pus in eax
        pop ebp
        ret
 
base32decode:
	; TODO TASK 4
	push ebp
        mov ebp, esp
        mov edi, [ebp + 8] ; parcurge stringul codat
        mov esi, [ebp + 8] ; scrie stringul decodat cate un caracter
        
base32decode_iteration:
        xor edx, edx
        xor eax, eax
        mov al, byte [edi] ; se ia primul caracter si se decodifica
        push eax
        call base32_to_value
        add esp, 4
        
        mov dl, al ; in dl se construieste primul byte din numar
        shl dl, 3  ; mai raman 3 biti de "umplut"
        mov al, byte [edi + 1]
        push eax
        call base32_to_value
        add esp, 4
        
        mov ah, al
        shr al, 2     ; se pun doar 3/5 biti in dl pentru completare
        or dl, al     ; acum primul byte este in dl
        mov [esi], dl ; se scrie in esi pentru a se putea refolosi dl
        inc esi
        xor edx, edx
        shl ah, 3 ; se sterg bitii care au fost folositi anterior
        shr ah, 3
        mov dl, ah  ; se pun cei 2 ramasi in dl urmand sa se construiasca
        shl edx, 30 ; in edx restul de 4 bytes, adica 6 caractere din sir
        xor eax, eax
        mov al, byte [edi + 2]
        push eax
        call base32_to_value
        add esp, 4
        shl eax, 25 ; se shifteaza eax cu 30-5 biti
        or edx, eax ; si se pune rezultatul in edx
        
        xor eax, eax
        mov al, byte [edi + 3]
        push eax
        call base32_to_value
        add esp, 4
        shl eax, 20 ; se shifteaza eax cu 25-5 biti
        or edx, eax
        
        xor eax, eax
        mov al, byte [edi + 4]
        push eax
        call base32_to_value
        add esp, 4
        shl eax, 15 ; se shifteaza eax cu 20-5 biti
        or edx, eax
        
        xor eax, eax
        mov al, byte [edi + 5]
        push eax
        call base32_to_value
        add esp, 4
        shl eax, 10 ; se shifteaza eax cu 15-5 biti
        or edx, eax
        
        xor eax, eax
        mov al, byte [edi + 6]
        push eax
        call base32_to_value
        add esp, 4
        shl eax, 5 ; se shifteaza eax cu 10-5 biti
        or edx, eax
        
        xor eax, eax
        mov al, byte [edi + 7]
        push eax
        call base32_to_value
        add esp, 4
        or edx, eax ; nu mai este nevoie de shiftare
        
        mov byte [esi + 3], dl ; se scriu in sir caracterele in ordine inversa
        mov byte [esi + 2], dh
        shr edx, 16
        mov byte [esi + 1], dl
        mov byte [esi], dh
        
        add esi, 4 ; fiecare 8 caractere codificate reprezinta 5 bytes
        add edi, 8 ; unul din ei fiind scris mai sus
        cmp byte [edi], 0
        jne base32decode_iteration
                
        mov byte [esi], 0
        pop ebp
	ret
;===============================================================;
bruteforce_singlebyte_xor:
	; TODO TASK 5
        push ebp 
        mov ebp, esp
        
        mov esi, ecx ;pun sirul in esi
        
        xor edx, edx ;verific sa am registrele goale
        xor edi, edi 
        xor eax, eax
        xor ebx, ebx
        
case_f:
        mov bh, byte [esi] ;iau un byte din mesaj
        xor bh, al ;construiesc cheia
        cmp bh, 'f' ;daca am gasit 'f'
        je case_o ;vreau sa vad daca am 'o'
        jmp fail ;nu am gasit 'f'
       
case_o:
        mov bh, byte [esi + 1] ;iau urmatorul byte
        xor bh, al ;construiesc cheia
        cmp bh, 'o';daca am gasit 'o'
        je case_r ;vreau sa vad daca am 'r'
        jmp fail ;nu am gasit 'o'
       
case_r:
        mov bh, byte [esi + 2] ;iau urmatorul byte
        xor bh, al ;construiesc cheia
        cmp bh, 'r' ;daca am gasit 'r'
        je case_c ;vreau sa vad daca am 'c'
        jmp fail ;nu am gasit 'r'
       
case_c:
        mov bh, byte [esi + 3] ;iau urmatorul byte
        xor bh, al ;construiesc cheia
        cmp bh, 'c' ;daca am gasit 'c'
        je case_e ;vreau sa vad daca am 'e'
        jmp fail ;nu am gasit 'c'
       
case_e:
        mov bh, byte[esi + 4] ;iau urmatorul byte
        xor bh, al ;construiesc cheia
        cmp bh, 'e' ;daca am gasit 'e'
        je end_try ;reiau procesul
        jmp fail ;nu am gasit 'e'
       
fail:
        inc eax ;creste cheia
        cmp eax, 255 ;daca am ajuns la final
        jne case_f ;daca nu, verifica din nou
        xor eax, eax ;refa eax
        inc esi ;avanseaza in sir
        jmp case_f ;sare la inceput
   
end_try:
        mov esi, ecx
        
continue:
        cmp byte [esi], 0x00 ;daca am ajuns la finalul sirului
        je end_bruteforce ;iesi din functie
        xor byte [esi], al ;fac xor intre un byte din mesaj si cheie
        inc esi ;avanseaza in sir
        jmp continue ;reia procesul
        
end_bruteforce:
        leave 
        ret
;===============================================================;
decode_vigenere:
	; TODO TASK 6
        push ebp
        mov ebp, esp
        
        mov esi, [ebp + 8] ;retin in esi mesajul 
        mov edi, [ebp + 12] ;retin in edi cheia
        
check_byte:
        mov bh, byte [edi] ;iau un byte din esi si il pun in bh
        mov bl, byte [esi] ;iau un byte din edi si il pun in bl
        cmp bl, 0x00 ;verific daca am ajuns la final
        je end_decode ;daca da, ies din functie
        cmp bl, 'a' 
        jb next_step
        cmp bl, 'z'
        ja next_step
        sub bh, 'a' ;aflu offset pentru cheie
        sub bl, 'a' ;aflu offset pentru mesaj
        cmp bl, bh ;compar cele doua offset-uri
        jge ok ;daca bl>=bh, sar la label-ul ok 
        jl not_ok ;daca bl<bh, sar la labe-ul not_ok

not_ok:
        sub bl, bh ;scad din bl ce am in bh
        add bl, '{' ;adaug urmatorul caracter dupa z
        jmp ok2 
        
ok:
        sub bl, bh
        add bl, 'a' ;pot sa adaug 'a'
        jmp ok2
        
ok2:
        mov byte [esi], bl ;reiau verificarea de la ok
        inc edi ;avansez in cheie
        cmp byte [edi], 0x00 ;verific daca am ajuns la final
        je reset ;daca da, resetez cheia
        jmp next_step ;avansez in mesaj
        
reset:
        mov edi, [ebp + 12]
        jmp next_step
        
next_step:
        inc esi
        jmp check_byte
                 
end_decode:
        leave
	ret
;===============================================================;
main:
	push ebp
	mov ebp, esp
	sub esp, 2300

	; test argc
	mov eax, [ebp + 8]
	cmp eax, 2
	jne exit_bad_arg

	; get task no
	mov ebx, [ebp + 12]
	mov eax, [ebx + 4]
	xor ebx, ebx
	mov bl, [eax]
	sub ebx, '0'
	push ebx

	; verify if task no is in range
	cmp ebx, 1
	jb exit_bad_arg
	cmp ebx, 6
	ja exit_bad_arg

	; create the filename
	lea ecx, [filename + 7]
	add bl, '0'
	mov byte [ecx], bl

	; fd = open("./input{i}.dat", O_RDONLY):
	mov eax, 5
	mov ebx, filename
	xor ecx, ecx
	xor edx, edx
	int 0x80
	cmp eax, 0
	jl exit_no_input

	; read(fd, ebp - 2300, inputlen):
	mov ebx, eax
	mov eax, 3
	lea ecx, [ebp-2300]
	mov edx, [inputlen]
	int 0x80
	cmp eax, 0
	jl exit_cannot_read

	; close(fd):
	mov eax, 6
	int 0x80

	; all input{i}.dat contents are now in ecx (address on stack)
	pop eax
	cmp eax, 1
	je task1
	cmp eax, 2
	je task2
	cmp eax, 3
	je task3
	cmp eax, 4
	je task4
	cmp eax, 5
	je task5
	cmp eax, 6
	je task6
	jmp task_done

task1:
	; TASK 1: Simple XOR between two byte streams

	; TODO TASK 1: find the address for the string and the key
	; TODO TASK 1: call the xor_strings function
         
        push ecx ;salvez ecx pe stiva deoarece este alterat de strlen
        
        push ecx
        call strlen
        add esp, 4
        
        pop ecx ;dupa apelul strlen nu uit sa scot ecx pe stiva
                
        mov ebx, ecx ;salvez ecx pentru apelul puts   
        inc eax          
        add ecx, eax ;actualizez ecx pentru fiecare pas
        
        push ebx ;salvez de fapt ecx pe stiva
        
        push ecx ;pun parametrii in ordine inversa pe stiva       
        push ebx
        call xor_strings
        add esp, 8
        
        call puts
        add esp, 4
        
        jmp task_done
        
task2:
	; TASK 2: Rolling XOR

	; TODO TASK 2: call the rolling_xor function
         
        push ecx ;pune sirul pe stiva
        call rolling_xor ;aplica functia
        add esp, 4
         
        push ecx ;pune sirul de afisat in ecx
        call puts
        add esp, 4
          
        jmp task_done
        
task3:
	; TASK 3: XORing strings represented as hex strings

	; TODO TASK 1: find the addresses of both strings
	; TODO TASK 1: call the xor_hex_strings function
        
        push ecx ;ecx poate fi alterat de strlen deci il salvez
        
        push ecx
        call strlen
        add esp, 4
       
        pop ecx ;nu uit sa il scot de pe stiva
          
        mov ebx, ecx ;salvez ecx curent in ebx
        inc eax 
        add ebx, eax ;actualizez ecx pentru fiecare pas
        
        push ecx ;convertesc mesajul
        call convert
        add esp, 4
        
        push ebx ;convertesc cheia
        call convert
        add esp, 4 
        
        push ebx ;pun parametrii in ordine inversa pe stiva
        push ecx
        call xor_hex_strings
        add esp,8
        
        push ecx ;rezultatul o sa fie pus in ecx
        call puts
        add esp, 4
        
        jmp task_done

task4:
	; TASK 4: decoding a base32-encoded string

	; TODO TASK 4: call the base32decode function
	
	push ecx
        call base32decode ; se apeleaza functia de decodificare
        add esp, 4
        
	push ecx
	call puts ; se afiseaza sirul decodificat
	pop ecx
	
	jmp task_done

task5:
	; TASK 5: Find the single-byte key used in a XOR encoding

	; TODO TASK 5: call the bruteforce_singlebyte_xor function
      
        call bruteforce_singlebyte_xor
     
        push eax ;salveaza eax din cauza puts
        
        push ecx                    
        call puts
        pop ecx
        
        pop eax ;nu uit sa il scot de pe stiva
        
        push eax                    ;eax = key value
        push fmtstr
        call printf                 ;print key value
        add esp, 8

        jmp task_done

task6:
	; TASK 6: decode Vignere cipher

	; TODO TASK 6: find the addresses for the input string and key
	; TODO TASK 6: call the decode_vigenere function
        
        push ecx ;pune ecx pe stiva din cauza strlen 

        push ecx
        call strlen
        add esp, 4

        pop ecx ;nu uit sa il scot de pe stiva
        
        add eax, ecx
        inc eax

        push eax ;pune parametrii in ordine inversa pe stiva
        push ecx                    
        call decode_vigenere
        add esp, 8

        push ecx ;afiseaza mesajul decriptat
        call puts
        add esp, 4

        jmp task_done

task_done:
	xor eax, eax
	jmp exit

exit_bad_arg:
	mov ebx, [ebp + 12]
	mov ecx , [ebx]
	push ecx
	push usage
	call printf
	add esp, 8
	jmp exit

exit_no_input:
	push filename
	push error_no_file
	call printf
	add esp, 8
	jmp exit

exit_cannot_read:
	push filename
	push error_cannot_read
	call printf
	add esp, 8
	jmp exit

exit:
	mov esp, ebp
	pop ebp
	ret

;---------------------------------------------------------------------------------
;TB: LM
;ALUNAS: ELLEN C B MARQUES E EDUARDA ELGER
;OBJETIVO: CONSTRUIR UM CODIGO INTERATIVO QUE CALCULE O N-ESSIMO NUMERO FIBONACCI 
;nasm -f elf64 tb1.asm ; ld tb1.o -o tb1.x && ./tb1.x
;----------------------------------------------------------------------------------
%define maxChars 3
%define openrw  102o ; flag open()
%define userWR 644o  ; Read+Write+Execute
%define append 2101o ; flag open() criar/escrever no final

section .data
    strOla : db "Insira o Fibonacci que deseja (até XX)", 10, 0 ;SOLICITACAO DE ENTRADA DO N-ESSIMO NUMERO
    strOlaL: equ $ - strOla   

    strBye : db "Voce digitou: ", 0
    strByeL: equ $ - strBye 

    strLF  : db 10 ; quebra de linha ASCII!
    strLFL : db 1

	strErro : db "Erro!Numero invalido", 10, 0 ;MESAGEM DE ERRO 
    strErroL: equ $ - strErro

    strFilename : db "fib(" , 10, 0   ;PRIMEIRA PARTE DO NOME DO ARQUIVO 
    strFilenameL: equ $ - strFilename

    strFilenamefim: db ").bin", 10, 0 ;SEGUNDA PARTE DO NOME DO ARQUIVO 
    strFilenamefimL: equ $ -strFilenamefim

    pfe:  db "%d fora do intervalo aceito.", 10, 0
    pfeL: equ $ - pfe
    pfv:  db "fib =", 10, 0
    pfvL: equ $ - pfv
section .bss
    ;VARIAVEIS 
    strLida  : resb maxChars 
    strLidaL : resd 1
	buffer : resb 1
    fileHandle: resd 1
    filename: resb 12
    num: resq 1  
    res : resq 1 ;resposta do fib
section .text
 	global _start

_start:
    mov rax, 1
    mov rdi, 1
    lea rsi, [strOla]
    mov rdx, strOlaL
    syscall  

leitura:
    mov dword [strLidaL], maxChars
    mov rax, 0  ; READ
    mov rdi, 1
    lea rsi, [strLida]
    mov rdx, [strLidaL]
    syscall

    mov [strLidaL], eax

    cmp byte [strLida + 1], 10
    je umdigito

verificacaoDeEntrada: 
    cmp byte [strLida + eax-1], 10 ;AQUI INICIAMOS O TESTE DA ENTRADA CASO SEJAM 3 NUMEROS ELA PULA PRA FUNCAO LIMPA BUFFER E FINZALIZA
    jne limpaBuffer
       
convert:

    mov r8b, byte[strLida]     
    sub r8b, 48        
    mov al,10
    imul r8, rax
    jmp doisgitos                     
    
    umdigito:
    mov r8b, byte[strLida]
    sub r8b, 48             
    mov [num], r8 ;rax 
    jmp fib

    doisgitos:
    mov r9b, byte[strLida+1]
    sub r9b, 48             
    add r8, r9
    mov [num] ,r8
    jmp fib
    
fib:
    mov r10, [num]
    cmp r10, 93   ; O objetido dessa parte do codigo é fazer a limitaçao dos fibs possiveis, pq testando nós observamos que ao executar um fib maior que 93 ocorre o estouro do registrador portanto o nosso fib limitante sera 93 
    ja erro ;caso o numero exceda ele nos da uma mensagem de erro e nao cria o arquivo
	xor r11, r11 ;zera o reg
	mov r12 , 1  ; guarda o valor de 1 no reg 12
	mov r14, 1 ;r14 sera o reg utilizado para o inc

	soma_fib:
	mov r13 , r12 ;resultado do fib sera alocado em r12
	add r12 , r11 
	mov r11, r13  
	inc r14
	

	cmp r14, [num] 
	; je escreve_resposta
	jl soma_fib
    mov [res], r12 ;aqui movendo o resultado alocado em r12 para a [res]

resposta:
    ;alteracao no nome do arquivo
    mov r8d, [strFilename] ;AQUI INICIAMOS A CONCATENACAO DAS STRINGS PARA O NOME DO ARQUIVO SEMPRE MUDAR COFORME A ENTRADA DO USUARIO
    mov r9d, [strLidaL]
    mov [filename], r8d

    mov r8d, [strLida]
    mov [filename + 4], r8d
   
    lea r10, [filename]
    add r10, 3
    add r10, r9

    mov [r10], byte ")"
    inc r10
    mov [r10], byte "."
    inc r10
    mov [r10], byte "b"
    inc r10
    mov [r10], byte "i"
    inc r10
    mov [r10], byte "n"
    inc r10
    mov [r10], byte 0
    
    mov rax, 2         ; open file
    lea rdi, [filename]; *pathname
    mov esi, openrw     ; flags
    mov edx, userWR     ; mode
    mov ecx, append
    syscall

    mov [fileHandle], eax

    escreve_resposta:
    mov rax, 1 ;
    mov rdi, [fileHandle] ; fd
    lea rsi, [res]      ; *buf
    mov rdx, 8          ; count
    syscall

    fecha:
    mov rax, 3  ; fechar arquivo
    mov edi, [fileHandle]
    syscall

	jmp fim

limpaBuffer: 
	mov rax, 0
	mov rdi, 1
	mov rsi, buffer
	mov edx, 1
	syscall
	cmp byte [buffer], 0xa
	jnz limpaBuffer

    erro: ;mesnagem de erro 
	mov rax, 1
    mov rdi, 1
    lea rsi, [strErro]
    mov edx, strErroL
    syscall

fim:
    mov rax, 60
    mov rdi, 0
    syscall

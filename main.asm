.model small
.stack 5h
.data
    
    MSG1 DB 10,' ======= CALCULADORA EM ASSEMBLY ======= ',10,'$'
    MSG2 DB 10,'Iniciar uma Soma         (+) (1)',10,'$'
    MSG3 DB 10,'Iniciar uma Subtracao    (-) (2)',10,'$'
    MSG4 DB 10,'Iniciar uma multiplicacao(*) (3)',10,'$'
    MSG5 DB 10,'Iniciar uma divisao      (/) (4)',10,'$'

    calc DB 10,'=== Coloque os numeros Para a Operacao ===',10,'$'
    Selectop DB 10,'Selecione a Operacao desejada (1-4)','$'
    Resultado DB 10,'Resultado da Operação foi = ',10,'$'
    error DB 10,'Operando NAO INDENTIFICADO Tente Novamente',10,'$'

    num1 DB 10,'Inserir o Primeiro numero: ',10,'$'
    num2 DB 10,'Inserir o Segundo numero: ',10,'$'
    Res DB 10,'=== Resultado da Operacao ===',10,'$'

    confirmacao DB 10,' Quer continuar? (S/N)',10,'$'

.code
    
    Imprime_msg macro var1;macro para codigo de impressão 
    MOV AH, 09h
    LEA DX,var1
    INT 21h
    ENDM

    MAIN PROC
        MOV AX,@DATA     ;Inicialização da data base 
        MOV DS,AX        ;
    
    start:
        Imprime_msg MSG1
        
    ;=============== CRIANDO A INTERFACE DA CALCULADORA ===============
        ; Colocando as opções da calculadora p/ o usuario
        Imprime_msg MSG2
        Imprime_msg MSG3
        Imprime_msg MSG4
        Imprime_msg MSG5

        ;Mensagem de Seleção da operação 
        Imprime_msg Selectop
        mov ah,07h
        int 21h
    
    ;=============== Indentificação do Operando ===============
    ;Nessa passagem vamos indentificar se o valor q o usuario colocou é valido para operação

            mov ch,al ; o CH é o verificador de operação no codigo inteiro

            cmp ch,"1"
            jz NUM
            cmp ch,"2"
            jz NUM
            cmp ch,"3"
            jz NUM
            cmp ch,"4"
            jz NUM

            erro:
            
            ;printaa a frase avisando o erro 

            Imprime_msg error
            jmp start   
    ;=============== Inicialização das msg para receber os Numeros ===============
    ;Nessa etapa vc vai colocar os numeros que seram usados para a operação
    ;Usuario pode escolher digitar numeros de 2 casas, negativos e hexadecimais
    ;O primeiro e o segundo digito é lido
    ;O primeiro digito da operação é printado
        NUM:
            ;Clear screen
            XOR CL,Cl        ;Zerendo Cl, pos será utilizado para verificadores de negativo
            mov ax, 3
            int 10h
            MOV AH,09H       ;Processo de enviar a mensagem para receber o primeiro numero 
            LEA DX,calc      ;Mensagem para receber os numero
            INT 21H          ;
            LEA DX,num1
            INT 21H

            mov AH,01        ; recebe o caracter
            INT 21h
            cmp AL,'-'
            JNE NAONEGATIVO   ;Se o primeiro numero for negativo CL = 1
            int 21h
            MOV CL,1
        NAONEGATIVO:

            MOV BH,AL        ;E ARMARZENA-LO EM BH "Primeiro numero esta armazenado em BH"

            MOV AH,09H       ;Processo de enviar a mensagem para receber o Segundo numero
            LEA DX,num2
            INT 21H
        
            mov AH,01        ; recebe o outro numero "caracter"
            INT 21h

            XOR DX,DX
            cmp AL,'-'
            JNE NAONEGATIVO2     ;Se o segundo número for negativo DH = 1
            int 21h
            MOV DH,1
        NAONEGATIVO2:
            MOV DL,CL           ;Mover CL para Dl
            PUSH DX            ;Mover DX na pilha (agora a pilha contém os verificadores de negativo)
                               ;Se XL = 1 primeiro numero negativo" Se XH = 1 segundo numero negativo

            MOV BL,AL          ;ARMAZENAR PRIMEIRO DIGITO EM BL "segundo numero armazenado em BL"

            mov ax, 3        ;clear screen
            int 10h

            MOV AH,09H       ;Processo de enviar a mensagem De Resultado
            LEA DX,Res       
            INT 21H

            MOV AH,02
            CMP CL,1             ;Printar "-" se CL = 1 (primeiro número negativo)
            JNE PRINTNEGATIVO
            MOV DL,'-'
            int 21h
        PRINTNEGATIVO:
            MOV DL,BH
            int 21h

            
            cmp CH,"1"
            jz SOMA
            cmp CH,"2"
            jz SUBT
            cmp CH,"3"
            jz MULTI
            cmp CH,"4"
            jz SOMA

    ;==== Depois dessa estapa ====
    ;Na pilha está localizado os verificadores de negativo
    ;CH tem o número da operação
    ;BH tem o primeiro digito lido
    ;Bl tem o segundo digito lido


    ;=============== Inicio Do Código Da Operação De Adição ===============
    SOMA:



        MOV DL,2BH       ;Imprimir o character +
        INT 21h          ;
        
        POP CX           ;CX contém os verificadores de negativo
        CMP CH,1
        JNE PRINTNEGATIVO2   ;Se o segundo número é negativo printar "-"
        MOV DL,'-'
        int 21h
        PRINTNEGATIVO2:
        MOV DL,BL            ;printar segundo numero
        int 21h

        sub BH,30h       ;Transforma o Primeiro numero "caracter" de BH em numeral
        sub BL,30h       ;Transforma o Segundo numero "caracter" de BL em numeral

        CMP CL,1
        JNE NEGATIVBH        ;Se o primeiro numero for negativo (transformar em negativo numeral)
        NEG BH
    NEGATIVBH:               

        CMP CH,1
        JNE NEGATIVBL        ;Se o segundo numero for negativo (transformálo em negativo numeral)
        NEG BL 
    NEGATIVBL:

        ADD BL,BH        ; soma dos dois valores



        
        MOV Dl,3DH       ; imprimir o caracter =
        MOV AH,02
        INT 21h

        CMP BL,0
        JNL MENORZERO    ;Se o resultado for negativo printar "-" e transformar o resultado de volta para positivo
        NEG BL           ;(não é possível printar negativo diretamente)
        MOV DL,'-'
        int 21h
    MENORZERO:

    ;===Print do resultado (dois dígitos)===

        XOR AX,AX           ;Zerar AX
        MOV CL,10
        MOV AL,BL
        DIV CL             ;Dividir o resultado por 10 para printar 2 digitos
        MOV BH,AH          ;BH = Resto AL = Quociente
        MOV AH,02
        CMP AL,0
        JE NOQUOCSOMA         ;Pular se Quociente = 0

        MOV  DL,AL
        ADD  DL,30h       ; soma 30 para conseguir ler o numero pois esta em formato caracter explo 2+3=5+35 35-30=5)
        int 21h           ;Imprimir Quociente (primeiro dígito)

       NOQUOCSOMA:
        MOV DL,BH
        ADD DL,30h
        int 21h           ;Imprimir Resto (segundo digito) 
    
        JMP FIM





    SUBT:
        MOV DL,2DH       ;Imprimir o character -
        MOV AH,02        ;
        int 21h          ;

        POP CX           ;Colocando os verificadores de negativo em CX 
                         ;(CH = 1 primeiro digito negativo, Cl = 1 segundo digito negativo)
            
        CMP CH,1       
        JNE PRINTNEGATIVO2SUB        ;se o segundo numero for negativo printar "-"
        MOV DL,'-'
        int 21h
        PRINTNEGATIVO2SUB:
        MOV DL,BL
        int 21h


        MOV AL,BL                    ;BL e BH estavam sendo estragados quando chamavam a função
        MOV DL,BH                    ;Por isso mover para Al,DL (no começo da função SUB eles voltam para BH,BL)
        CALL PROCSUB
        JMP FIM

    MULTI:
        CALL PROCMULT
        JMP FIM


    ;==========  Final do programa  ==========
        FIM:
            Imprime_msg confirmacao       ;Pergunta se o usuário quer continuar
            MOV AH,01
            int 21h
            cmp AL,53h
            JNE NAOQUER

            mov ax, 3        ;clear screen
            int 10h          
            JMP START        ;Se o usuário digitar S maiúsculo, voltar para o começo

        NAOQUER:
            
            MOV AH,4CH
            INT 21H 

    PROCSUB PROC

        MOV BL,AL        
        MOV BH,DL


        SUB BH,30h       ;Transforma o Primeiro numero "caracter" de BH em numeral
        SUB BL,30h       ;Transforma o Segundo numero "caracter" de BL em numeral

        CMP CL,1         
        JNE NEGATIVBHSUB
        NEG BH           ;Se pimeiro numero for negativo, transformar em numeral negativo
    NEGATIVBHSUB:

        CMP CH,1
        JNE NEGATIVBLSUB
        NEG BL           ;Se o segundo numero for negativo, transformar em numeral negativo
    NEGATIVBLSUB:

        SUB BH,BL        ; subtrai os dois valores

        MOV Dl,3DH       ; imprimir o caracter =
        MOV AH,02
        int 21h


        CMP BH,0
        JNL MENORZEROSUB
        NEG BH
        MOV DL,2DH            ;Se o resultado for negativo, printar "-" e transformar resultado em positivo
        int 21h               ;(Não é possível printar o resultado negativo diretamente)
    MENORZEROSUB: 



        XOR AX,AX           ;Zerar AX
        MOV CL,10
        MOV AL,BH
        DIV CL             ;Dividir o resultado por 10 para printar 2 digitos
        MOV BL,AH          ;BL = Resto AL = Quociente
        MOV AH,02
        CMP AL,0
        JE NOQUOCSUB          ;Pular se Quociente = 0

        MOV DL,AL
        OR  DL,30h       ; soma 30 para conseguir ler o numero pois esta em formato caracter explo 2+3=5+35 35-30=5)
        int 21h           ;Imprimir Quociente (primeiro dígito)

       NOQUOCSUB:
        MOV DL,BL
        OR DL,30h
        int 21h           ;Imprimir Resto (segundo digito) 


        RET 

    PROCSUB ENDP
           

    PROCMULT PROC

    ;=== Printando dígitos ===
        
        POP SI           ;Colocando o endereço do CALL em SI (para usar o ret)

        MOV DL,2AH       ;Imprimir o character *
        MOV AH,02        ;
        INT 21h          ;

        POP CX

        CMP CH,1
        JNE PRINTNEGATIVO2MULT
        MOV DL,'-'                ;printar '-' se o segundo digito for negativo
        int 21h
        PRINTNEGATIVO2MULT:
        MOV DL,BL                 ;printar segundo dígito
        int 21h

        PUSH CX                   ;Devolvendo verificadores de negativo para a pilha

        SUB BH,30H                 ;Tranformando em numeral
        SUB BL,30h


        MOV Dl,3DH       ; imprimir o caracter =
        MOV AH,02
        INT 21h
        

    ;=============== Começo da Multiplicação ===============
    ;A Multiplicação funciona como uma multiplicação de binários
    ;Por Ex
    ;BH:          101 (5)
    ;BL:        x 011 (3)        A cada loop ele irá conferir se BL(segundo dígito) tem 1 como último bit (LSB)
    ;            ----
    ;             101            Se Bl tem 1 como último bit ele irá adicionar BH (101 no exemplo) em CH
    ;            1010            Para simular a adição do "zero" BH será movido para a esquerda
    ;            ----            Para conferir o próximo bit BL será movido para a direita
    ;CH:         1111 (15)       O loop terminará quando BL = 0 (todos os "1s" foram conferidos)
    ;
    ;
        XOR CX,CX
        LOOPMULTIPLICA:
            SHR BL,1             ;Testando o último bit
            JNC PAR
            ADD CH,BH            ;Adicionar a BH se último bit de bl = 1
        PAR:
            SHL BH,1             ;Mover para a esquerda para simular a adição do zero na multiplicação
                                 ;Mover para a direita para que o próximo bit seja conferido

        CMP BL,0
        JNZ LOOPMULTIPLICA       ;O loop acaba quando todos o "1s" foram conferidos, ficando em CH o resultado da multiplicação
            
            
        ;=============== Imprimindo resultado  ===============
        EXIT:
            MOV BH,CH            ;Movendo resultado para Bl
            XOR CX,CX
            POP CX               ;Obtendo os verificadores de negativo

            CMP CH,CL
            JE MESMOSINAL
            MOV DL,'-'           ;Se os dígitos lidos tiverem sinais diferentes, printar "-"
            int 21h
        MESMOSINAL:

            XOR AX,AX           ;Zerar AX
            MOV CL,10
            MOV AL,BH
            DIV CL             ;Dividir o resultado por 10 para printar 2 digitos
            MOV BL,AH          ;BL = Resto AL = Quociente
            MOV AH,02
            CMP AL,0
            JE NOQUOC          ;Pular se Quociente = 0

            MOV DL,AL
            ADD DL,30h
            int 21h           ;Imprimir Quociente (primeiro dígito)

        NOQUOC:
            MOV DL,BL
            ADD DL,30h
            int 21h           ;Imprimir Resto (segundo digito) 

        PUSH SI               ;Devolvento endereço do CALL para a pilha (para o ret usar)

        RET       

        PROCMULT ENDP

        main ENDP
        END main














       
        
            
        

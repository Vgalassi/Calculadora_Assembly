.model small
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

            mov ch,al ; o CH é o identificador de operação no codigo inteiro

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
        NUM:
            ;Clear screen
            mov ax, 3
            int 10h
            MOV AH,09H       ;Processo de enviar a mensagem para receber o primeiro numero 
            LEA DX,calc      ;Mensagem para receber os numero
            INT 21H          ;
            LEA DX,num1
            INT 21H

            mov AH,01        ; recebe o caracter
            INT 21h          ;
            MOV BH,AL        ;E ARMARZENA-LO EM BH "Primeiro numero esta armazenado em BH"

            MOV AH,09H       ;Processo de enviar a mensagem para receber o Segundo numero
            LEA DX,num2
            INT 21H
        
            mov AH,01        ; recebe o outro numero "caracter"
            INT 21h          ;
            MOV BL,AL        ;E ARMAZENA-LO EM BL "segundo numero armazenado em BL"
            

            cmp CH,"1"
            jz SOMA
            cmp CH,"2"
            jz SUBT
            cmp CH,"3"
            jz MULTI
            cmp CH,"4"
            jz SOMA


    ;=============== Inicio Do Código Da Operação De Adição ===============
    SOMA:
        ;Clear screen
        mov ax, 3
        int 10h


        MOV AH,09H       ;Processo de enviar a mensagem De Resultado
        LEA DX,Res       ;
        INT 21H

        ;formação da operação
        MOV DL,BH   
        MOV AH,02
        INT 21H

        MOV DL,2BH       ;Imprimir o character +
        MOV AH,02        ;
        INT 21h          ;
        
        MOV DL,BL
        MOV AH,02
        INT 21H

        sub BH,30h       ;Transforma o Primeiro numero "caracter" de BH em numeral
        sub BL,30h       ;Transforma o Segundo numero "caracter" de BL em numeral
        ADD BL,BH        ; soma dos dois valores 

        OR  BL,30h       ; soma 30 para conseguir ler o numero pois esta em formato caracter explo 2+3=5+35 35-30=5)
        MOV Dl,3DH       ; imprimir o caracter =
        MOV AH,02
        INT 21h
    
        MOV DL,BL        ; mov o valor a ser imprimido para dl pois a funcao soh le em dl
        MOV AH,02        ; imprimi o resultado 
        INT 21h 
        JMP FIM

    SUBT:

        ;Clear screen
        mov ax, 3
        int 10h

        MOV AH,09H       ;Processo de enviar a mensagem De Resultado
        LEA DX,Res       ;
        INT 21H

        ;formação da operação
        MOV DL,BH   
        MOV AH,02
        INT 21H

        MOV DL,2DH       ;Imprimir o character -
        MOV AH,02        ;
        INT 21h          ;
        
        MOV DL,BL
        MOV AH,02
        INT 21H

        sub BH,30h       ;Transforma o Primeiro numero "caracter" de BH em numeral
        sub BL,30h       ;Transforma o Segundo numero "caracter" de BL em numeral
        ADD BL,BH        ; soma dos dois valores 

        OR  BL,30h       ; soma 30 para conseguir ler o numero pois esta em formato caracter explo 2+3=5+35 35-30=5)
        MOV Dl,3DH       ; imprimir o caracter =
        MOV AH,02
        INT 21h
    
        MOV DL,BL        ; mov o valor a ser imprimido para dl pois a funcao soh le em dl
        MOV AH,02        ; imprimi o resultado 
        INT 21h 
        JMP FIM

    MULTI:
        ;Clear screen
        mov ax, 3
        int 10h

        MOV AH,09H       ;Processo de enviar a mensagem De Resultado
        LEA DX,Res       ;
        INT 21H
        ;formação da operação
        MOV DL,BH        ;Imprimindo o Primeiro numero 
        MOV AH,02        ;
        INT 21H          ;

        MOV DL,2AH       ;Imprimir o character *
        MOV AH,02        ;
        INT 21h          ;

        MOV DL,BL        ;Imprimindo o Segundo numero 
        MOV AH,02        ;
        INT 21H          ;
        MOV Dl,3DH       ; imprimir o caracter =
        MOV AH,02
        INT 21h
        
        CMP BH,0
        JE ZERO 
        CMP BL,0
        JE ZERO
                   

        VERIFICADOR:
            XOR CH,CH
            INC CH               ;CH é o contador de Movimento para esquerda
            SHR AL,CL            
            CMP CL,0             ;Comparar Cl com 0 caso a multiplicação seja por 1  

            JNE PULO         
            INC CL               ;Se não for multiplicação por 1 CL = 1
            PULO:

            CMP AL,1             ;Quando o número for dividido até ser = 1, sair do verificador

        JNE VERIFICADOR

            MOV CL,CH            
            MOV CH,BH           ;CH agora tem o valor inicial de BH           
            SHL BH,CL           ;Multiplicar BH por 2^CL
            SHL AL,Cl           ;AL = 2^CL
            SUB BL,AL           ;Substrair para saber o quanto falta para multiplicar
            CMP BL,0            ;SE não não falta nada, pular para o final
            JE EXIT
        SOMADOR:

            DEC BL              
            ADD BH,CH           ;BH irá adicionar o valor inicial de BH(BL)
            CMP BL,0
            JNE SOMADOR
            JP EXIT

        ZERO:
            XOR BH,BH
            EXIT:
            MOV AH,02           ;imprimir "="
            MOV DL,61
            int 21h

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


        FIM:
            MOV AH,4CH
            INT 21H 

        main ENDP
        END main














       
        
            
        
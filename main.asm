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
            PUSH DX            ;Mover DX na pilha (agora a pilha contém os identificadores de negativo)
                               ;Se XL = 1 primeiro numero negativo" Se XH = 1 segundo numero negativo

            MOV BL,AL        ;E ARMAZENA-LO EM BL "segundo numero armazenado em BL"

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


    ;=============== Inicio Do Código Da Operação De Adição ===============
    SOMA:



        MOV DL,2BH       ;Imprimir o character +
        INT 21h          ;
        
        POP CX           ;CL contém os identificadores de negativo
        CMP CH,1
        JNE PRINTNEGATIVO2   ;Se o segundo número é negativo printar "-"
        MOV DL,'-'
        int 21h
        PRINTNEGATIVO2:
        MOV DL,BL
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
        NEG BL
        MOV DL,'-'
        int 21h
    MENORZERO:

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

        POP CX
        CMP CH,1
        JNE PRINTNEGATIVO2SUB
        MOV DL,'-'
        int 21h
        PRINTNEGATIVO2SUB:
        MOV DL,BL
        int 21h


        MOV AL,BL
        MOV DL,BH
        CALL PROCSUB
        JMP FIM

    MULTI:
        CALL PROCMULT
        JMP FIM

        FIM:
            MOV AH,4CH
            INT 21H 

    PROCSUB PROC

        MOV BL,AL
        MOV BH,DL


        SUB BH,30h       ;Transforma o Primeiro numero "caracter" de BH em numeral
        SUB BL,30h       ;Transforma o Segundo numero "caracter" de BL em numeral

        CMP CL,1
        JNE NEGATIVBHSUB
        NEG BH
    NEGATIVBHSUB:

        CMP CH,1
        JNE NEGATIVBLSUB
        NEG BL
    NEGATIVBLSUB:

        SUB BH,BL        ; subtrai os dois valores

        MOV Dl,3DH       ; imprimir o caracter =
        MOV AH,02
        int 21h


        CMP BH,0
        JNL MENORZEROSUB
        NEG BH
        MOV DL,2DH
        int 21h
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
        
        POP SI

        MOV DL,2AH       ;Imprimir o character *
        MOV AH,02        ;
        INT 21h          ;

        POP CX

        CMP CH,1
        JNE PRINTNEGATIVO2MULT
        MOV DL,'-'
        int 21h
        PRINTNEGATIVO2MULT:
        MOV DL,BL
        int 21h

        PUSH CX


        MOV Dl,3DH       ; imprimir o caracter =
        MOV AH,02
        INT 21h
        

        ;=============== Começo da Multiplicação ===============

        SUB BH,30H
        SUB Bl,30H
        MOV CH,-1        ;reinicializando variaveis de loop
        XOR CL,CL
        MOV AL,BL
        CMP BH,0         ;Se algum número for zero, pular para zero
        JE ZERO 
        CMP BL,0
        JE ZERO
                   
        ;=============== Contador de casas para a esquerda ===============
        ;Função:
        ;Conta quanto casas devem ser movidas para a esquerda do digito multiplicado
        ;Registradores:
        ;CH = Indica quantas casas vão ser movidas para esquerda após o loop de contagem
        ;CL = Flag que indica se há multiplicação por 1 (0 = com multiplcação de 1)(1 = sem multiplicação de 1)
        ;Cl também indica quantas casas em AL serão movidas durante cada reptição do loop (1 ou zero)
        ;AL é começa como o segundo digito lido,  a cada ciclo ele é movido Cl vezes par a esquerda
        ;AL é a condição de parada do loop, quando AL = 1 o loop é encerrado

        CONTADOR:    


            
            INC CH               ;CH é o contador de Movimento para esquerda
            SHR AL,CL  

            CMP CL,0             ;Comparar Cl com 0 caso a multiplicação seja por 1  
            JNE PULO         
            INC CL               ;Se não for multiplicação por 1 CL = 1
            PULO:

            CMP AL,1             ;Quando o número for dividido até ser = 1, sair do verificador

        ;=============== Diferença entre o número movido e o real ===============
        ;O Movimento para a esquerda só encobre multiplicações com número 2^X (sendo x o número de casas movidas para a esquerda)
        ;Para outros números é nescessário subtrair multiplicador - 2^X 
        ;E somar o número multiplicado com si mesmo vezes o resultado da subtração
        ;Nessa função se a subtração = 0, significando que o multiplicador é 2^X, pula para a impressão do resultado 
        ;Registradores:
        ;CL recebe o número de vezes do movimento para a esquerda
        ;BH = primeiro digito (número multiplicado)
        ;Bl segundo digito (multiplicador)
        ;AL = 1
    

        JNE CONTADOR

            MOV CL,CH            
            MOV CH,BH           ;CH agora tem o valor inicial de BH           
            SHL BH,CL           ;Multiplicar BH por 2^CL
            SHL AL,Cl           ;AL = 2^CL
            SUB BL,AL           ;Substrair para saber o quanto falta para multiplicar
            CMP BL,0            ;SE não não falta nada, pular para o final
            JE EXIT
        
        ;LOOP para somar o primeiro digito + primeiro digito * (subtração) 
        SOMADOR:

            DEC BL              
            ADD BH,CH           ;BH irá adicionar o valor inicial de BH(BL)
            CMP BL,0
            JNE SOMADOR
            JP EXIT

        ZERO:                   ;Se algum operando for 0          
            XOR BH,BH           


        ;=============== Imprimindo resultado  ===============
        EXIT:
            
            POP CX

            CMP CH,CL
            JE MESMOSINAL
            MOV DL,'-'
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

        PUSH SI

        RET       

        PROCMULT ENDP

        main ENDP
        END main














       
        
            
        

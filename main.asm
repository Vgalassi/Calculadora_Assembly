TITLE Gabriel Hideki Yamamoto 22003967 Vinicius Henrique Galassi 22005768
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

    divisaozero db 10,'ERRO: Divisao por zero',10,'$'
    restodiv db 10,'Resto: ','$'
    confirmacao DB 10,' Quer continuar? (S/N)',10,'$'

.code
    
    Imprime_msg macro var1   ;macro para codigo de impressão 
    MOV AH, 09h
    LEA DX,var1
    INT 21h
    ENDM

    MAIN PROC
        MOV AX,@DATA     ;Inicialização da data base 
        MOV DS,AX        ;
    
    start:

        XOR AX,AX
        XOR BX,BX
        XOR CX,CX

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

            mov ax, 3        ;clear screen
            int 10h
            Imprime_msg error  ;printa a frase avisando o erro 
            jmp start   
    ;=============== Inicialização das msg para receber os Numeros ===============
    ;Nessa etapa vc vai colocar os numeros que seram usados para a operação
    ;Usuario pode escolher digitar numeros de 2 casas, negativos e hexadecimais
    ;O primeiro e o segundo digito é lido
    ;O primeiro digito da operação é printado
        NUM:
            XOR CL,Cl        ;Zerando Cl, pois será utilizado para verificadores de negativo
            mov ax, 3
            int 10h
            Imprime_msg calc
            Imprime_msg num1
        RETORNOERRADO:
            mov AH,01        ; recebe o caracter
            INT 21h
            cmp AL,'-'
            JNE NAONEGATIVO   ;Se o primeiro numero for negativo CL = 1
            int 21h
            MOV CL,1
        NAONEGATIVO:

            cmp AL,30h
            JL INPUTERRADO    ;Conferindo se input é um número (entre 30h e 39h)
            cmp AL,39h
            JG INPUTERRADO
            JMP CORRETO

            INPUTERRADO:
            MOV AH,02           ;Se não for um número imprimir backspace e voltar para a leitura
            MOV DL,08
            int 21H
            JMP RETORNOERRADO
        CORRETO:

            MOV BH,AL        ;E ARMARZENA-LO EM BH "Primeiro numero esta armazenado em BH"
            Imprime_msg num2
        
        RETORNOERRADO2:
            mov AH,01        ; recebe o outro numero "caracter"
            INT 21h

            XOR DX,DX
            cmp AL,'-'
            JNE NAONEGATIVO2     ;Se o segundo número for negativo DH = 1
            int 21h
            MOV DH,1
        NAONEGATIVO2:
            cmp AL,30h
            JL INPUTERRADO2
            cmp AL,39h               ;Conferindo se input é um número (entre 30h e 39h)
            JG INPUTERRADO2
            JMP CORRETO2
        INPUTERRADO2:
            MOV AH,02
            MOV DL,08                 ;Se não for um número imprimir backspace e voltar para a leitura
            int 21H
            JMP RETORNOERRADO2
        CORRETO2:

            MOV DL,CL          ;Mover CL para Dl
            PUSH DX            ;Mover DX na pilha (agora a pilha contém os verificadores de negativo)
                               ;Se XL = 1 primeiro numero negativo" Se XH = 1 segundo numero negativo

            MOV BL,AL          ;ARMAZENAR PRIMEIRO DIGITO EM BL "segundo numero armazenado em BL"

            mov ax, 3        ;clear screen
            int 10h

            Imprime_msg Res

            

            MOV AH,02            

            MOV DL,32            ;print espaço
            int 21h         

            CMP CL,1             ;Printar "-" se CL = 1 (primeiro número negativo)
            JNE PRINTNEGATIVO
            MOV DL,'-'
            int 21h
        PRINTNEGATIVO:
            MOV DL,BH
            int 21h

            
            cmp CH,"1"              ;Printa o sinal da operação de acordo com a operação escolhida
            jz SINALMAIS
            cmp CH,"2"
            jz SINALMENOS
            cmp CH,"3"
            jz SINALMULTI
            cmp CH,"4"
            jz SINALDIV

    RETORNO:
 
        MOV DH,CH        ;DH contém a operação realizada
        POP CX           ;CX contém os verificadores de negativo
        CMP CH,1
        JNE PRINTNEGATIVO2   ;Se o segundo número é negativo printar "-"
        MOV DL,'-'
        int 21h
        PRINTNEGATIVO2:
        MOV DL,BL            ;printar segundo numero
        int 21h

        MOV DL,3DH
        int 21h

        sub BH,30h       ;Transforma o Primeiro numero "caracter" de BH em numeral
        sub BL,30h       ;Transforma o Segundo numero "caracter" de BL em numeral

        
        cmp DH,"1"       
        jz SOMA
        cmp DH,"2"
        jz SUBT
        cmp DH,"3"
        jz MULTI
        cmp DH,"4"
        jz DIVIS

        
    ;==== Depois dessa estapa ====
    ;Na pilha está localizado os verificadores de negativo
    ;DH tem o número da operação
    ;BH tem o primeiro número lido
    ;Bl tem o segundo número lido
    ;

    
    SINALMAIS:
        MOV DL,2BH       ;Imprimir o character +
        INT 21h          ;
        JMP RETORNO
    
    SINALMENOS:
        MOV DL,2DH       ;Imprimir o character -
        MOV AH,02        ;
        int 21h          ;
        jmp RETORNO

    SINALMULTI:
        MOV DL,2AH       ;Imprimir o character *
        MOV AH,02        ;
        int 21h          ;
        jmp RETORNO

    SINALDIV:
        MOV DL,2FH       ;Imprimir o character /
        MOV AH,02        ;
        int 21h          ;
        jmp RETORNO

    SOMA:                ;Chamando as funções das suas devidas operações
        CALL PROCSOMA
        JMP FIM

    SUBT:
        CALL PROCSUB
        JMP FIM

    MULTI:
        CALL PROCMULT
        JMP FIM

    DIVIS:
        CALL PROCDIV
        JMP FIM


    ;==========  Final do programa  ==========
        FIM:
            Imprime_msg confirmacao       ;Pergunta se o usuário quer continuar
            MOV AH,07
        VOLtA:
            int 21h
            cmp AL,53h
            JNE NAOQUER

            mov ax, 3        ;clear screen
            int 10h          
            JMP START        ;Se o usuário digitar "S", voltar para o começo

        NAOQUER:             

            CMP AL,4EH       ;Se digitar N, terminar o programa
            JNE VOLTA
            
            MOV AH,4CH
            INT 21H 
  

    main ENDP

    ;=============== Procedimento de Soma ===============
    ;Realiza a soma entre dois números e imprime o resultado
    ;Registradores:
    ;BH = primeiro número
    ;BL = segundo número
    

    ;Como funciona:
    ;Soma os dois valores utilizando o comando ADD e imprime o resultado

    PROCSOMA proc

        CMP CL,1
        JNE NEGATIVBH        ;Se o primeiro numero for negativo (transformar em negativo numeral)
        NEG BH
    NEGATIVBH:               

        CMP CH,1
        JNE NEGATIVBL        ;Se o segundo numero for negativo (transformálo em negativo numeral)
        NEG BL 
    NEGATIVBL:

        ADD BH,BL        ; soma dos dois valores


        CMP BH,0
        JNL MENORZERO    ;Se o resultado for negativo printar "-" e transformar o resultado de volta para positivo
        NEG BH           ;(não é possível printar negativo diretamente)
        MOV DL,'-'
        int 21h
    MENORZERO:

    ;===Print do resultado (dois dígitos)===

        CALL impressao_resultado
        RET
    
    PROCSOMA endp

    ;=============== Procedimento de subtração ===============
    ;Realiza a subtração entre dois números e imprime o resultado
    ;Registradores:
    ;BH = primeiro número
    ;BL = segundo número
    

    ;Como funciona:
    ;Subtrai os dois valores utilizando o comando SUB e imprime o resultado
    

    PROCSUB PROC


        CMP CL,1         
        JNE NEGATIVBHSUB
        NEG BH                ;Se primeiro numero for negativo, transformar em numeral negativo
    NEGATIVBHSUB:

        CMP CH,1
        JNE NEGATIVBLSUB
        NEG BL                ;Se o segundo numero for negativo, transformar em numeral negativo
    NEGATIVBLSUB:

        SUB BH,BL             ;subtrai os dois valores

        CMP BH,0
        JNL MENORZEROSUB
        NEG BH
        MOV DL,2DH             ;Se o resultado for negativo, printar "-" e transformar resultado em positivo
        int 21h                ;(Não é possível printar o resultado negativo diretamente)
    MENORZEROSUB: 

        CALL impressao_resultado
        RET 

    PROCSUB ENDP

    ;=============== Procedimento Multiplicação ===============
    ;Multiplica dois números e imprime o resultado
    ;A Multiplicação tem em base a multiplicação de binário
    ;Registradores:
    ;BH = primeiro número
    ;BL = segundo  número
    ;CH = resultado multiplicação
    
    ;Como funciona:
    ;Por Ex
    ;BH:          101 (5)
    ;BL:        x 011 (3)        A cada loop ele irá conferir se BL(segundo número) tem 1 como último bit (LSB)
    ;            ----
    ;             101            Se Bl tem 1 como último bit ele irá adicionar BH (101 no exemplo) em CH
    ;            1010            Para simular a adição do "zero" BH será movido para a esquerda
    ;            ----            Para conferir o próximo bit BL será movido para a direita
    ;CH:         1111 (15)       O loop terminará quando BL = 0 (todos os "1s" foram conferidos)
    ;
    ;
    ;Após fazer a multiplicação a impressão do resultado será realizada

    PROCMULT PROC

        POP SI           ;Colocando o endereço do CALL em SI (para usar o ret)
        PUSH CX          ;Colocando identificadores de negativo de volta para pilha


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
            MOV BH,CH                ;Movendo resultado para Bl
            XOR CX,CX
            POP CX                   ;Obtendo os verificadores de negativo

            CMP CH,CL
            JE MESMOSINAL
            MOV DL,'-'               ;Se os dígitos lidos tiverem sinais diferentes, printar "-"
            int 21h
        MESMOSINAL:

        CALL impressao_resultado
        PUSH SI                      ;Devolvento endereço do CALL para a pilha (para o ret usar)
        RET       

    PROCMULT ENDP


    ;=============== Procedimento de divisão ===============
    ;Realiza a divisão entre dois números e imprime o resultado 
    ;A divisão tem em base a divisão de números binários

    ;Registradores:
    ;CL = resto
    ;CH = dividento (passado de BH) 
    ;BH = dividendo
    ;Bl = divisor
    ;AL = quociente
    ;AH = contador de rotações

    ;Como funciona:
    ;A cada ciclo o bit mais significativo de CH(dividendo) se torna bit menos significativo de CL (rotação para a esquerda)
    ;Se Cl for maior do que o divisor, a subtração Cl - Divisor será realizada) e o bit menos significativo de AL será = 1
    ;Se Cl for menor do que o divisor o bit menos significativo de AL será = 0
    ;O loop termina quando AH = 8, (todos os bits do dígito que estava em CH, foram para CL)

    ;Após realizar a divisão, a impressão do quociente e do resto será realizada

    PROCDIV proc

        POP SI                          ;Colocando o endereço do CALL em SI (para usar o ret)
        PUSH CX                         ;Devolvendo verificadores de negativo para a pilha

        CMP BL,0
        JNZ DIVISAOSEMZERO              ; Se o divisor for zero, imprimir mensagem de erro e pular para o final do programa
        Imprime_msg divisaozero
        JMP FIMDIV

    DIVISAOSEMZERO:
        XOR CX,CX
        MOV CH,BH     
        XOR AX,AX
        
    LOOPDIVISAO:

        ROL CX,01h                      ;Passar o MSB de CH para CL
        INC AH                          ;AH = contador de rotações
        SHL AL,1                        ;AL = quociente, mover AL para a esquerda para "dar espaço"       
        CMP CL,BL

        JL MENORDIV
            OR AL,01h                   ;Se o CL (dividendo) for maior que o divisor, adicionar 1 ao LSB do quociente
            SUB CL,BL                   ;Subtrair dividendo - divisor
        MENORDIV:

        CMP AH,8                        ;Quando AH = 8 o loop acaba
    JNE LOOPDIVISAO


    ;=============== Imprimindo Resultado ===============
        MOV BL,CL            ;BL = contém o resto
        MOV BH,AL            ;Bh = contém o quociente

        XOR CX,CX
        POP CX               ;Obtendo os verificadores de negativo

        MOV AH,02
        CMP CH,CL
        JE MESMOSINALDIV
            MOV DL,'-'           ;Se os dígitos lidos tiverem sinais diferentes, printar "-"
            int 21h
        MESMOSINALDIV:

        MOV DL,BH
        ADD DL,30h
        int 21h

        Imprime_msg restodiv      ;imprimindo mensagem de resto

        MOV AH,02
        CMP CH,CL
        JE MESMOSINALDIVR
        CMP BL,0
        JE RESTOZERO
            MOV DL,'-'           ;Se os dígitos lidos tiverem sinais diferentes, printar "-"
            int 21h
        MESMOSINALDIVR:
        
    RESTOZERO:
        MOV DL,BL                ;Imprimindo o resto
        ADD DL,30H
        int 21h
        
    FIMDIV:
        PUSH SI
        RET 

    PROCDIV ENDP

    ;=============== Procedimento de impressão de resultado =============== 
    ;Imprime o valor que está em BH (até dois dígitos)
    ;Registradores:
    ;BH = valor que será impresso
    ;AL = quociente de divisão (primeiro dígito de BH)
    ;BL = resto da divisão (segundo dígito de BH)

    ;Como funciona:
    ;Será realizado uma divisão por 10 de BH e será impresso o resto e o quociente
    ;Se o quociente for zero, só será impresso o resto

    impressao_resultado proc

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

        ret

    impressao_resultado endp

    END main


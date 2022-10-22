.model small



.code
    main proc

            MOV CL,0
            MOV CH,-1

            MOV AH,01                 ;leitura primeiro numero
            int 21h 

            MOV BL,AL                 ;BL recebe primeiro algarismo
            SUB BL,30h

            MOV AH,02               
            MOV DL,120
            int 21h                   ;imprimir "x"
            MOV AH,01

  
            int 21h                   ;leitura segundo número
            MOV BH,AL
            SUB BH,30h
            SUB AL,30h

            CMP BH,0
            JE ZERO 
            CMP BL,0
            JE ZERO
                   

            VERIFICADOR:

                INC CH               ;CH é o contador de Movimento para esquerda
                SHR AL,CL            
                CMP CL,0             ;Comparar Cl com 0 caso a multiplicação seja por 1  

                JNE PULO         
                INC CL               ;Se não for multiplicação por 1 CL = 1
                PULO:

                CMP AL,1             ;Quando o número for dividido até ser = 1, sair do verificador

            JNE VERIFICADOR

                MOV CL,CH            
                MOV CH,BL           ;CH agora tem o valor inicial de BL           
                SHL BL,CL           ;Multiplicar BL por 2^CL
                SHL AL,Cl           ;AL = 2^CL
                SUB BH,AL           ;Substrair para saber o quanto falta para multiplicar
                CMP BH,0            ;SE não não falta nada, pular para o final
                JE EXIT
            SOMADOR:

                DEC BH              
                ADD BL,CH           ;Bl irá adicionar o valor inicial de BL(BH)
                CMP BH,0
                JNE SOMADOR
                JP EXIT

            ZERO:
                XOR BL,BL
            EXIT:
                MOV AH,02           ;imprimir "="
                MOV DL,61
                int 21h

                XOR AX,AX           ;Zerar AX
                MOV CL,10
                MOV AL,BL
                DIV CL             ;Dividir o resultado por 10 para printar 2 digitos
                MOV BH,AH          ;BH = Resto AL = Quociente
                MOV AH,02
                CMP AL,0
                JE NOQUOC          ;Pular se Quociente = 0

                MOV DL,AL
                ADD DL,30h
                int 21h           ;Imprimir Quociente (primeiro dígito)
            NOQUOC:
                MOV DL,BH
                ADD DL,30h
                int 21h           ;Imprimir Resto (segundo digito)



                MOV AH,4CH        ;fim do programa
                int 21h

    main endp
    end main

    












    

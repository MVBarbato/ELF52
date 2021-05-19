        PUBLIC  __iar_program_start
        EXTERN  __vector_table

        SECTION .text:CODE:REORDER(2)
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB

; System Control definitions
SYSCTL_BASE             EQU     0x400FE000
SYSCTL_RCGCGPIO         EQU     0x0608                  
SYSCTL_RCGCGPIO_R       EQU     0x400FE608              ; Run-mode Clock Gating -> Inicializacao -> Habilita clock
SYSCTL_PRGPIO		EQU     0x0A08          
SYSCTL_PRGPIO_R		EQU     0x400FEA08              ; Peripheral Ready      -> Inicializacao -> Indica se a porta GPIO está pronta para uso
SYSCTL_RCGCUART         EQU     0x0618
SYSCTL_PRUART           EQU     0x0A18
; System Control bit definitions
PORTA_BIT               EQU     000000000000001b        ; Define quantos bits que pode se escrever na porta a -> datasheet
PORTF_BIT               EQU     0000000000100000b       ; Define quantos bits que pode se escrever na porta f -> datasheet
PORTJ_BIT               EQU     0000000100000000b       ; Define quantos bits que pode se escrever na porta j -> datasheet
PORTN_BIT               EQU     0001000000000000b       ; Define quantos bits que pode se escrever na porta n -> datasheet
UART0_BIT               EQU     00000001b               ; Define quantos bits que pode se escrever na porta o -> datasheet

; NVIC definitions
NVIC_BASE               EQU     0xE000E000
NVIC_EN1                EQU     0x0104
VIC_DIS1                EQU     0x0184
NVIC_PEND1              EQU     0x0204
NVIC_UNPEND1            EQU     0x0284
NVIC_ACTIVE1            EQU     0x0304
NVIC_PRI12              EQU     0x0430

; GPIO Port definitions
GPIO_PORTA_BASE         EQU     0x40058000
GPIO_PORTF_BASE    	EQU     0x4005D000
GPIO_PORTJ_BASE    	EQU     0x40060000
GPIO_PORTN_BASE    	EQU     0x40064000
GPIO_DIR                EQU     0x0400                  ; GPIO_DIR (Direction) -> entrada ou saida
GPIO_IS                 EQU     0x0404                  ; borda ou nivel
GPIO_IBE                EQU     0x0408                  ; borda
GPIO_IEV                EQU     0x040C                  ; borda de subida ou descida
GPIO_IM                 EQU     0x0410                  ; habilitar interrupcao
GPIO_RIS                EQU     0x0414                  ; indica se houve condicoes para interrup. mesmo sem GPIO_IM 
GPIO_MIS                EQU     0x0418                  ; indica se houve cond para ativar interrup. e a mesma esta declarada em GPIO_IM
GPIO_ICR                EQU     0x041C                  ; ACK da interrupcao -> precisa dela para poder realizar uma nova interrup.
GPIO_AFSEL              EQU     0x0420
GPIO_PUR                EQU     0x0510
GPIO_DEN                EQU     0x051C                  ; GPIO_DEN (Digital Enable) -> Habilitar funcao digital
GPIO_PCTL               EQU     0x052C

; UART definitions
UART_PORT0_BASE         EQU     0x4000C000
UART_FR                 EQU     0x0018
UART_IBRD               EQU     0x0024
UART_FBRD               EQU     0x0028
UART_LCRH               EQU     0x002C
UART_CTL                EQU     0x0030
UART_CC                 EQU     0x0FC8

;UART bit definitions
TXFE_BIT                EQU     10000000b               ; TX FIFO full
RXFF_BIT                EQU     01000000b               ; RX FIFO empty
BUSY_BIT                EQU     00001000b               ; Busy
DELAY                   EQU     0x005F                 

;Universidade Federal do Paraná
;Matheus Victor Barbato

__iar_program_start

;Setup
main:   
        MOV R2, #(UART0_BIT)
	BL UART_enable                                  
        MOV R0, #(PORTA_BIT)
	BL Enable_port                                  
	LDR R0, =GPIO_PORTA_BASE
        MOV R1, #00000011b                              
        BL GPIO_special
	MOV R1, #0xFF                                   
        MOV R2, #0x11                                   
        BL GPIO_select
	LDR R2, =UART_PORT0_BASE
        BL UART_config                                  
        LDR R0, =UART_PORT0_BASE                        
                                                                                                                
loop:
       ;Clean all -  reiniciando váriaveis para novas operações. 
       ;MOV R2, #0
       MOV R5, #0
       MOV R4, #0
       MOV R3, #0
       MOV R9, #0
       MOV R10, #0
       MOV R11, #0
        
        
In_number_1:
        BL Leitura_Serial                               ; le a serial e salva o valor em r1
        MOV R9, R5                                      ; r6 = r3
          
        BL Verifica_op                                  ; verefica se está recebendo uma operação                               
        CMP R4, #0                                      ; se estiver, finaliza num1, salva a operacao em r4
        ITTT HI                                         ; e monta o numero 2
        MOVHI R10, #0                                   ; Zerando a contagem, 
        BLHI Print_serial                               ;
        BHI In_number_2
        
        BL Validate_number                              ; Verifica se a entrada é um numero, caso não seja ignora
        CMP R7, #1                                      ; Então não é um número. Volta pro In_number_1
        IT EQ
        BEQ In_number_1

        CMP R10, #4                                     ; verefica a quantidade de números em R5. MAX 4 digitos
        IT PL
        BLPL op_Step                                    ; Não é possível add mais digitos no In_number_1.
        
        BL Print_serial                                 ; Mostra na serial o valor lido pelo teclado. 
        CMP R10, #4
        ITTT LO
        BLLO Config_number                              ; r6 = r3*10+r1 // R10++
        MOVLO R5, R9                                    ; r3 = r6
        BLO In_number_1
 
 
;Aguarda qual operação será realizada
op_Step:
        BL Leitura_Serial
        BL Verifica_op                                  ; verefica se está recebendo um operando                               
        CMP R4, #0                                      ; se estiver, salva em r4 e vai para In_number_2
        ITTT HI                                         
        MOVHI R10, #0
        BLHI Print_serial
        BHI In_number_2
        B op_Step

In_number_2:
        CMP R10, #4                                   ; Se o segundo numero ja tiver 4 digitos o usuario
        IT PL                                         ; nao precisa digitar igual
        BLPL wait_end_op

        BL Leitura_Serial
        MOV R9, R3                                      ;

        CMP R1, #61
        ITTT EQ
        BLEQ realiza_op                                ; calcula o valor de R5 e R3 com a operação contida em R4                            
        BLEQ Quebra_linha                                 ; e imprimi na tela
        BEQ loop
        
        BL Validate_number                                          ; Verifica se a entrada eh um numero, se não for ignora a leitura
        CMP R7, #1
        IT EQ
        BEQ In_number_2

        CMP R10, #4                                      ; menor que 4 digitos
        ITTTT LO
        BLLO Print_serial
        BLLO Config_number                              ; r6 = r5*10+r1 // R10++
        MOVLO R3, R9                                  ; r5 = r6
        BLO In_number_2

wait_end_op:
        BL Leitura_Serial
        CMP R1, #61
        ITTT EQ
        BLEQ realiza_op                                ; calcula o valor de R5 e R3 com a operação contida em R4                            
        BLEQ Quebra_linha                                 ; e imprimi na tela
        BEQ loop
        B wait_end_op

        B loop  

;Le a serial e salva o valor em R1
Leitura_Serial:
        LDR R2, [R0, #UART_FR]                          ; status da UART
        TST R2, #RXFF_BIT                               ; Verifica se o receptor 
        BEQ Leitura_Serial
        LDR R1, [R0]                                    ; Le a resial e joga em R1
        BX LR

;Escreve na serial o valor contido em R1
Print_serial:    
        LDR R2, [R0, #UART_FR]                          ; status da UART
        TST R2, #TXFE_BIT                               ; transmissor vazio?
        BEQ Print_serial
        
        STR R1, [R0]                                    ; escreve no registrador de dados da UART0 (transmite)
        BX LR

;Habilita UART que estiver no registrador R2
UART_enable:                                            ; -> habilita UART0
        PUSH {R0, R1}
        LDR R0, =SYSCTL_BASE                            ; carrega o valor de SYSCTL_BASE em R0
	LDR R1, [R0, #SYSCTL_RCGCUART]                  ; R1 = [R0 + #SYSCTL_RCGCUART]
	ORR R1, R2                                      ; R2 ou R1 e salva em R1
	STR R1, [R0, #SYSCTL_RCGCUART]                  ; [R0, #SYSCTL_RCGCUART] = R1

waitu	LDR R1, [R0, #SYSCTL_PRUART]                    ; R1 = [R0 + #SYSCTL_PRUART]
	TEQ R1, R2                                      ; Verifica se clock da UART0 está abilitado
	BNE waitu
        
return_UART_enable
        POP {R1}
        POP {R0}
        BX LR

;Configuracao da UART que estiver no registrador R2
UART_config:
        PUSH {R1}
        LDR R1, [R2, #UART_CTL]                         ; R1 = [R0 + #SYSCTL_RCGCUART]
        BIC R1, #0x01                                   ; desabilita UART (bit UARTEN = 0)
        STR R1, [R2, #UART_CTL]                         ; [R2, #UART_CTL] = R1

        ; clock = 16MHz, baud rate = 14400 bps
        MOV R1, #69                                     ; R1 = #69
        STR R1, [R2, #UART_IBRD]                        ; [R2, #UART_IBRD] = R1
        MOV R1, #29                                     ; R1 = #29
        STR R1, [R2, #UART_FBRD]                        ; [R2, #UART_FBRD] = R1
        
        ; 7 bits, 1 stop, with parity, FIFOs disabled, no interrupts                                 ; R1 = #0x60
        MOV R1, #01000110b
        STR R1, [R2, #UART_LCRH]                        ; [R2 + #UART_LCRH] = R1
        
        ; clock source = system clock
        MOV R1, #0x00                                   ; R1 = #0x00   
        STR R1, [R2, #UART_CC]                          ; [R2 + #UART_CC] = R1
        
        LDR R1, [R2, #UART_CTL]                         ; R1 = [R2, #UART_CTL] 
        ORR R1, #0x01                                   ; R1 = R1 OU R0 -> habilita UART (bit UARTEN = 1)
        STR R1, [R2, #UART_CTL]                         ; [R2, #UART_CTL] = R1
        
        POP {R1}
        BX LR

;Habilita a função especial do GPIO no registrador R0
GPIO_special:
        PUSH {R2}
	LDR R2, [R0, #GPIO_AFSEL]                       ; R2 = [R0, #GPIO_AFSEL]
	ORR R2, R1                                      ; R2 = R2 ou R1            
	STR R2, [R0, #GPIO_AFSEL]                       ; [R0, #GPIO_AFSEL] = R2

	LDR R2, [R0, #GPIO_DEN]                         ; R2 = [R0, #GPIO_DEN]
	ORR R2, R1                                      ; R2 = R2 ou R1 
	STR R2, [R0, #GPIO_DEN]                         ; [R0, #GPIO_DEN] = R2

        POP {R2}
        BX LR

;Seleciona a função especial do GPIO no registrador R0
GPIO_select:
        PUSH {R5}
	LDR R5, [R0, #GPIO_PCTL]
        BIC R5, R1
	ORR R5, R2 ; seleciona bits especiais
	STR R5, [R0, #GPIO_PCTL]
        POP {R5}
        BX LR

;Habilita o GPIO que estiver na porta R0
Enable_port:                                            ; -> habilita o GPIO da porta R0
        PUSH {R1, R2}
        LDR R2, =SYSCTL_RCGCGPIO_R                      ; carrega o valor de SYSCTL_RCGCGPIO_R em R2
        LDR R1, [R2]                                    ; carrega o valor que R2 "aponta" em R1
        ORR R1, R0                                      ; operação de OU com R1 e R0
        STR R1, [R2]                                    ; carrega o valor de R1 em R2
check      
        LDR R2, =SYSCTL_PRGPIO_R                        ; carrega SYSCTL_PRGPIO_R em R2
        LDR R1, [R2]                                    ; carrega o valor que R2 "aponta" em R1
        TST R1, R0                                      ; verifica se o clock esta ativo
        BEQ check                                       ; se ainda nao estiver ativo volta para check
return_Enable_port
        POP {R2}
        POP {R1}
        BX LR


;Recebe um numero base + um numero para colocar no final, salva em R9
Config_number:
        PUSH {R7, R8}
        MOV R8, #0x30
        MOV R7, #10
        MUL R9, R9, R7
        SUB R1, R1, R8
        ADD R9, R9, R1
        ADD R10, R10, #1
        POP {R7, R8}
        BX LR

;Printa na serial o valor contido em R1
Show_result:
        PUSH {LR}
        PUSH {R7, R8}                                   ; Conserva os registradores

        MOV R7, #0xaa                                   ; Dado de stop para pilha
        PUSH {R7}                                       ; aplica na pilha o stop  
        MOV R7, #10

        CMP R11, #2                                     ; R11 == 2 -> Div por zero
        ITTT EQ
        MOVEQ R1, #69                                 ; Em hexa - 'E' (0x45) eh sem graça
        PUSHEQ {R1}
        BEQ Print_result

        CMP R11, #1                                     ; R11 == 1 -> numero negativo
        ITTTT EQ
        PUSHEQ {R1}
        MOVEQ R1, #45
        BLEQ Print_serial
        POPEQ {R1}

        CMP R1, #0                                      ; Se resultado igual a zero nao tem 
        ITTT EQ                                         ; pq decompor o numero
        ADDEQ R1, R1, #0x30
        PUSHEQ {R1}
        BEQ Print_result
Decomposition:                                          ; Pega o resto da divisao por 10
        CMP R1, #0                                      ; e joga na pilha
        BEQ Print_result
        UDIV R8, R1, R7
        MUL R6, R8, R7 
        SUB R6, R1, R6
        ADD R6, R6, #0x30
        PUSH {R6}
        MOV R1, R8
        B Decomposition
Print_result                                            ; Tira numero a numero da pilha
        POP {R1}                                        ; ate chegar no 0xaa e vai 
        CMP R1, #0xaa                                   ; mostrando na tela
        IT EQ
        BEQ End_show_result
        BL Print_serial
        B Print_result
End_show_result:
        POP {R7, R8}
        POP {PC}
        

;Gera nova linha na serial                                  
Quebra_linha:
        PUSH {R1, LR}
        MOV R1, #10
        BL Print_serial
        MOV R1, #13
        BL Print_serial
        POP {R1, PC}



;Verefica se a entrada é uma eperação, A operação será armazenada em R4
Verifica_op:
        CMP R1, #43                             ; Sinal de soma em ASCII
        IT EQ
        MOVEQ R4, #2
          
        CMP R1, #45                             ; Sinal de subtração em ASCII
        IT EQ
        MOVEQ R4, #3
          
        CMP R1, #42                             ; Sinal de multiplicação em ASCII
        IT EQ                                   
        MOVEQ R4, #1
          
        CMP R1, #47                             ; Sinal de Divisão em ASCII
        IT EQ
        MOVEQ R4, #4
        BX LR
        

;Realiza a operação contida em R4 entre R5 e R3, salva em R1
realiza_op
        PUSH {LR}
        MOV R1, #61
        BL Print_serial

        ;SOMA
        CMP R4, #2                             
        IT EQ
        ADDEQ R1, R5, R3
         
        ;SUB
        CMP R4, #3                             
        IT EQ
        BLEQ exe_sub
        
        ;MULTIPICACAO
        CMP R4, #1                             
        IT EQ
        MULEQ R1, R5, R3

        ;DIV
        CMP R4, #4                             
        IT EQ
        BLEQ exe_div

        BL Show_result
        POP {PC}   

;Executa subtracao entre R5 e R3, salva em R1. Se negativo R11 = 1
exe_sub:  
        SUBS R1, R5, R3
        ITTT MI
        MOVMI R11, #1
        MVNMI R1, R1
        ADDMI R1, R1, #1
        BX LR


;Executa divisao entre R5 e R3, salva em R1. Se invalida R11 = 2
exe_div:
        UDIV R1, R5, R3
        CMP R3, #0
        IT EQ
        MOVEQ R11, #2
        BX LR

;Verifica se: 0 < entrada < 9
Validate_number:
        MOV R7, #0
        CMP R1, #0x30
        IT LO
        MOVLO R7, #1
        CMP R1, #0x39
        IT HI
        MOVHI R7, #1
        BX LR
        END

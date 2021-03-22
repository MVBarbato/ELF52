        PUBLIC  __iar_program_start
        PUBLIC  __vector_table

        SECTION .text:CODE:REORDER(1)
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB
        
__iar_program_start

;;Universidade Tecnológica Federal do Paraná
;;Arquitetura E Organização De Computadores
;;AUTOR: Matheus Victor Barbato - 1862308
;;Data de criação: 21/03/2021

;. Comentários:
;; R0 - Numerador
;; R1 - Denomonador
;; R2 - Recebe R0*R1
;; R3 - Recebe R0/R1
;; R4 - Recebe R0%R1
;; R8 e R6 são utilizados para realizar a operação de multiplicação.
;; R11 armazena a resposta da multiplicação


;; Le programme principal commence ici
main
        MOV R0, #0x0000000a
        MOV R1, #0x00000004
        MOV R8, R1
        MOV R6, R0
        BL Mul8b
        MOV R2, R11
        BL Div8b
loop:
        B loop

Mul8b:
        MOV R11, #0
        CBZ R6, m_arriere ;; Caso R6 seja igual a zero, deve retornar com o resultado = 0
Repeter_la_multiplication
        ADD R11, R11, R8
        SUB R6, R6, #1
        CBZ R6, m_arriere
        B Repeter_la_multiplication
m_arriere
        BX LR

Div8b:
        CBZ R1, retour_valeur_invalide
        MOV R8, R1
        MOV R6, R3
        MOV R11, #0
Repeter_le_fractionnement
        CMP R11, R0
        BHI division_arriere
        ADD R3, R3, #1  
        MOV R6, R3      
        PUSH {LR}
        BL Mul8b       
        POP {LR}
        B Repeter_le_fractionnement
division_arriere
        SUB R3, R3, #1  
        MOV R6, R3      
        PUSH {LR}       
        BL Mul8b        
        POP {LR}        
        SUBS R4, R0, R11
        BX LR           
retour_valeur_invalide
        BX LR

        ;; Forward declaration of sections.
        SECTION CSTACK:DATA:NOROOT(3)
        SECTION .intvec:CODE:NOROOT(2)
        
        DATA

__vector_table
        DCD     sfe(CSTACK)
        DCD     __iar_program_start

        DCD     NMI_Handler
        DCD     HardFault_Handler
        DCD     MemManage_Handler
        DCD     BusFault_Handler
        DCD     UsageFault_Handler
        DCD     0
        DCD     0
        DCD     0
        DCD     0
        DCD     SVC_Handler
        DCD     DebugMon_Handler
        DCD     0
        DCD     PendSV_Handler
        DCD     SysTick_Handler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Default interrupt handlers.
;;

        PUBWEAK NMI_Handler
        PUBWEAK HardFault_Handler
        PUBWEAK MemManage_Handler
        PUBWEAK BusFault_Handler
        PUBWEAK UsageFault_Handler
        PUBWEAK SVC_Handler
        PUBWEAK DebugMon_Handler
        PUBWEAK PendSV_Handler
        PUBWEAK SysTick_Handler

        SECTION .text:CODE:REORDER:NOROOT(1)
        THUMB

NMI_Handler
HardFault_Handler
MemManage_Handler
BusFault_Handler
UsageFault_Handler
SVC_Handler
DebugMon_Handler
PendSV_Handler
SysTick_Handler
Default_Handler
__default_handler
        CALL_GRAPH_ROOT __default_handler, "interrupt"
        NOCALL __default_handler
        B __default_handler

        END

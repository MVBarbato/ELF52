        PUBLIC  __iar_program_start
        PUBLIC  __vector_table

        SECTION .text:CODE:REORDER(1)
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB
        
__iar_program_start
        
;;Universidade Tecnológica Federal do Paraná
;;Sistemas Microcontrolados
;;AUTOR: Matheus Victor Barbato - 1862308
;;Data de criação: 29/03/2021

;; Comentários:
;; Irei exemplificar para entender a ideia da solução:
;; Seja R0 igual a 0b1011 e R1 igual a ob0111.
;; O número R1 da base binária em decimal seria 1*2^0 + 1*2^1 + 1*2^2
;; Usarei deslocamento para a direita e verificarei o carry.
;; Decompondo R1 em potência binária e deslocando x bits.
;; x será a potência da base 2. Ex 2^3 (x=3)


;; Le programme principal commence ici

main    MOV R0, #11
        MOV R1, #7
        PUSH {R1}
        BL Mul16b
        MOV R0, #0x0001

Mul16b:
        MOV R2, R0
operation
        CMP R1, #0
        BEQ revenir             ;; Se for igual a zero, ira para revenir
        LSRS R1, R1, #1         ;; Deslocamento para a direita em 1 de R1
        ITT CS                  ;; Condicional Carry igual a 1.
          LSLCS R4, R0, R3      ;;condicional t
          ADDCS R2, R2, R4      ;;condicional t
        ADD R3, R3, #1
        B operation
revenir
        SUBS R2, R0
        POP {R1}
Arreter
        B Arreter


        ;; main program ends here

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

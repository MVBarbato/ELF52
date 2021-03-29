        PUBLIC  __iar_program_start
        PUBLIC  __vector_table

        SECTION .text:CODE:REORDER(1)
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB
        
__iar_program_start

;;Universidade Tecnol�gica Federal do Paran�
;;Sistemas Microcontrolados
;;AUTOR: Matheus Victor Barbato - 1862308
;;Data de cria��o: 29/03/2021

;; Coment�rios:

;; Le programme principal commence ici
main    MOV R0, #17
        PUSH {R1, R2}
        MOV R1, R0
        BL factorielle

factorielle
        CMP R1, #0
        ITT EQ
          MOVEQ R0, #1
          BEQ Arreter
        SUB R1, #1
revenir
        CBZ R1, Arreter
        MULS R0, R1
        ADDS R2, R0, R0
        ITTT VS
          MOVVS R0, #0xFFFF
          MOVTVS R0, #0xFFFF
          POPVS {R1, R2}
          BVS Arreter
        SUB R1, #1
        B revenir

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

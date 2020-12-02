; ----------------------------------
;              Timer1
; ----------------------------------

    list p=16f877
    include "p16f877.inc"


; ==============================================================================
;                          variables/constantes
; ==============================================================================
    ; registers
    EXTERN      TMR1_V_COUNT
    ; subprograms
    EXTERN      START_ADC

    ; the TMR1 module is configured to overflow approximately every 500 ms
    ; the TMR1_V_COUNT register keeps track of how many overflows have occured
    ; if the TMR1_V_COUNT reaches 1, then 500 ms has already passed
    constant    TMR1_OVERFLOWED = D'1'

; ==============================================================================
;                          peripheral configuration
; ==============================================================================
TMR1_FILE  CODE
TMR1_Config
    GLOBAL      TMR1_Config
    banksel     T1CON
    ; Prescaler = 1:8
    ; Oscillator shut off
    ; Internal clock (Fosc/4) used
    ; Timer enabled
    movlw       ( 1<<T1CKPS1 | 1<<T1CKPS0 | 0 << TMR1CS | 1<<TMR1ON )
    movwf       T1CON
    clrf        TMR1_V_COUNT   ; initaliser nombre d'overflow compte a 0


; ==============================================================================
;                           Interrupt callbacks
; ==============================================================================

; ----------------------------------
;              TMMR1IF
; ----------------------------------

TMR1IF_Callback
    GLOBAL      TMR1IF_Callback
    banksel     TMR1_V_COUNT

TEST_IF_SECOND_PASSED
    movf        TMR1_V_COUNT, W    ; move what was received into working reg
    xorlw       TMR1_OVERFLOWED    ; this operation will make Z flag = 1 if
                                   ; the TMR1 module has already overflowed
                                   ; this would mean that approximately 1 second has passed
    btfsc       STATUS, Z
    lgoto SECOND_PASSED             ; this instruction is skipped if only 500 ms
                                   ; have occured
INCR_TMR1_V_COUNT
    incf        TMR1_V_COUNT, F    ; 500 ms have passed
    lgoto EXIT_CALLBACK

SECOND_PASSED
    clrf        TMR1_V_COUNT       ; reset overflow count register (0 ms have passed)
    PAGESEL     START_ADC
    lcall        START_ADC

EXIT_CALLBACK             
    return

; ----------------------------------
;          end module code
; ----------------------------------

    end

;******************************************************************************
;   MSP430x42x0 Demo - LCD_A run a 0-9 counter on TI LCD
;
;  Description; Count 0-9 on a TI LCD
;  ACLK = LFXT1 = 32768, MCLK = SMCLK = DCO = 32xACLK = 1.048576MHz
;  Segments attached in accordance with Static LCD diagram in 4xx User's Guide
;  //*An external watch crystal is required on XIN/XOUT for ACLK*//	
;  //* WARNING: Do NOT enable Charge Pump with Static LCD *//
;  //* See Errata for more details: LCDA1 *//
;
;               MSP430F4270
;            -----------------
;        /|\|              XIN|-
;         | |                 | 32kHz
;         --|RST          XOUT|-
;           |                 |
;           |                 |    TI LCD
;           |             S0  |     -----
;           |              -  |--> | 2 1 |
;           |             S6  |     -----
;           |             COM0|-----|
;           |                 |
;           |                 |
;           |                 |
;           |                 |
;
;  JL Bile
;  Texas Instruments Inc.
;  June 2008
;  Built Code Composer Essentials: v3 FET
;*******************************************************************************
 .cdecls C,LIST, "msp430x42x0.h"
;------------------------------------------------------------------------------
            .text                 ; Program Start
;------------------------------------------------------------------------------
RESET       mov.w   #300h,SP                ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
            bis.b   #XCAP14PF,&FLL_CTL0     ; Set load capacitance for xtal
            mov.b   #LCDON + LCDSTATIC + LCDFREQ_128, &LCDACTL ; 4mux LCD ACLK/128
            mov.b   #0x03, &LCDAPCTL0       ; s0-s6 used
ClearLCD    mov.w   #20,R15                 ; 15 LCD memory bytes to clear
Clear1      mov.b   #0,LCDM1(R15)           ; Write zeros in LCD RAM locations
                                            ; to clear display
            dec     R15                     ; All LCD mem clear?
            jc      Clear1                  ; More LCD mem to clear, use JC
                                            ; to get memory location 0
            mov.b   #0,    R15              ; R15 is a scratch loop value  --< check for clear already
            mov.b   #0,    R14              ; R14 is value to display
Loop        mov.b   R14,   R13              ; copy value to R13 to become index
            rla.w   R13
            rla.w   R13                     ; to align with character array
Char_loop   mov.b   LCD_Tab(R13), LCDMEM(R15)
            inc.b   R13
            inc.b   R15
            cmp.b   #4,    R15
            jl      Char_loop
            mov.w   #50000, R15
Delay_loop  dec.w   R15
            tst.w   R15
            jnz     Delay_loop
            cmp     #9,    R14
            jne     Add_One
            clr.b   R14
            jmp     Loop
Add_One     inc.b   R14
            jmp     Loop


LCD_Tab     .word      0x1111                  ; '0'  LCD segments b+a & d+c = lower two bytes
            .word      0x0011                  ; '0'  LCD segments f+e & h+g = upper two bytes
            .word      0x0110                  ; '1'
            .word      0x0000                  ; '1'
            .word      0x1011                  ; '2'
            .word      0x0101                  ; '2'
            .word      0x1111                  ; '3'
            .word      0x0100                  ; '3'
            .word      0x0110                  ; '4'
            .word      0x0110                  ; '4'
            .word      0x1101                  ; '5'
            .word      0x0110                  ; '5'
            .word      0x1101                  ; '6'
            .word      0x0111                  ; '6'
            .word      0x0111                  ; '7'
            .word      0x0000                  ; '7'
            .word      0x1111                  ; '8'
            .word      0x0111                  ; '8'
            .word      0x1111                  ; '9'
            .word      0x0110                  ; '9'
;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect    ".reset"                  ; RESET Vector
            .short   RESET                   ;
            .end
          
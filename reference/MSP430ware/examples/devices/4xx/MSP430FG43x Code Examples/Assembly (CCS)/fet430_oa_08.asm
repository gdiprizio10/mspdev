;******************************************************************************
;   MSP-FET430P430 Demo - OA1, Comparator in General-Purpose Mode
;
;   Description: Use OA1 as a comparator in general-purpose mode. In this
;   example, OA1 is configured for general-purpose mode, but used as a
;   comparator. The reference is supplied by DAC12_0 on the "-" input.
;   The "+" terminal is connected to OA1I0.
;   ACLK = n/a, MCLK = SMCLK = default DCO
;
;                 MSP430FG439
;              -------------------
;          /|\|                XIN|-
;           | |                   |
;           --|RST            XOUT|-
;             |                   |
;      "+" -->|P6.4/OA1I0         |
;             |                   |
;             |          P6.3/OA1O|--> OA1 Output
;             |                   |    Output goes high when
;             |                   |    Input > 1.5V
;
;   M. Mitchell / M. Mitchell
;   Texas Instruments Inc.
;   May 2005
;   Built with Code Composer Essentials Version: 1.0
;******************************************************************************
 .cdecls C,LIST,  "msp430xG43x.h"

;------------------------------------------------------------------------------
            .text                  ; Program Start
;------------------------------------------------------------------------------
RESET       mov.w   #0A00h,SP               ; Initialize stack pointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
REFOn       mov.w   #REFON+REF2_5V,&ADC12CTL0
                                            ; 2.5V reference for DAC120
DAC12_0     mov.w   #DAC12IR+DAC12AMP_2+DAC12ENC,&DAC12_0CTL
                                            ; 1x input range, enable DAC120,
                                            ; low speed/current
            mov.w   #099Ah,&DAC12_0DAT      ; Set DAC120 to output 1.5V
                                            ;
SetupOA     mov.b   #OAN_2+OAPM_1,&OA1CTL0  ; "-" connected to DAC120,
                                            ; "+" connected to OA1I0 (default),
                                            ; slow slew rate
            mov.b   #OARRIP,&OA1CTL1        ; General purpose (default),
                                            ; No r-to-r input
                                            ;						
Mainloop    bis.w   #LPM3,SR                ; Enter LPM3
            nop                             ; Required only for debug
                                            ;
;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; RESET Vector
            .short  RESET                   ;
            .end
/* --COPYRIGHT--,BSD
 * Copyright (c) 2011, Texas Instruments Incorporated
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * *  Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * *  Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * *  Neither the name of Texas Instruments Incorporated nor the names of
 *    its contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * --/COPYRIGHT--*/
#include "inc/hw_memmap.h"
#include "driverlib/5xx_6xx/uart.h"
#include "driverlib/5xx_6xx/ucs.h"
#include "driverlib/5xx_6xx/wdt.h"
#include "driverlib/5xx_6xx/gpio.h"

//******************************************************************************
//! This example shows how to configure the UART module to send data in
//! UART mode and read echoed data
//!
//!                MSP430F5438A
//!             -----------------
//!         /|\|                 |
//!          | |                 |
//!          --|RST              |
//!            |                 |
//!            |     P3.4/UCA0TXD|------------>
//!            |                 | 9600
//!            |     P3.5/UCA0RXD|<------------
//!
//!
//! This example uses the following peripherals and I/O signals.  You must
//! review these and change as needed for your own board:
//! - UART peripheral
//! - GPIO Port peripheral (for UART pins)
//! - UCA0TXD
//! - UCA0RXD
//!
//! This example uses the following interrupt handlers.  To use this example
//! in your own application you must add these interrupt handlers to your
//! vector table.
//! - USCI_A0_VECTOR.
//******************************************************************************
//*****************************************************************************
//
//Select Baud rate
//
//*****************************************************************************
#define BAUD_RATE                               9600
//*****************************************************************************
//
//Initialize received data
//
//*****************************************************************************
unsigned char receivedData = 0x00;
//*****************************************************************************
//
//Initialize trasnmit data
//
//*****************************************************************************
unsigned char transmitData = 0x00;

void main (void)
{
    //Stop WDT
    WDT_hold(__MSP430_BASEADDRESS_WDT_A__);

    //P3.4,5 = USCI_A0 TXD/RXD
    GPIO_setAsPeripheralModuleFunctionInputPin(__MSP430_BASEADDRESS_PORT3_R__,
        GPIO_PORT_P3,
        GPIO_PIN4 + GPIO_PIN5
        );

    if ( STATUS_FAIL == UART_init(__MSP430_BASEADDRESS_USCI_A0__,
             UART_CLOCKSOURCE_SMCLK,
             UCS_getSMCLK(__MSP430_BASEADDRESS_UCS__),
             BAUD_RATE,
             UART_NO_PARITY,
             UART_LSB_FIRST,
             UART_ONE_STOP_BIT,
             UART_MODE,
             UART_OVERSAMPLING_BAUDRATE_GENERATION )){
        return;
    }

    //Enable UART module for operation
    UART_enable(__MSP430_BASEADDRESS_USCI_A0__);

    //Enable Receive Interrupt
    UART_enableInterrupt(__MSP430_BASEADDRESS_USCI_A0__,
        UART_RECEIVE_INTERRUPT);

    //Transmit data
    UART_transmitData(__MSP430_BASEADDRESS_USCI_A0__,
        transmitData++
        );

    //Enter LPM3, interrupts enabled
    __bis_SR_register(LPM3_bits + GIE);
    __no_operation();
}

//******************************************************************************
//
//This is the USCI_A0 interrupt vector service routine.
//
//******************************************************************************
#pragma vector=USCI_A0_VECTOR
__interrupt void USCI_A0_ISR (void)
{
    switch (__even_in_range(UCA0IV,4)){
        //Vector 2 - RXIFG
        case 2:
            //Echo back RXed character, confirm TX buffer is ready first

            //USCI_A0 TX buffer ready?
            while (!UART_getInterruptStatus(__MSP430_BASEADDRESS_USCI_A0__,
                       UART_TRANSMIT_INTERRUPT_FLAG)
                   ) ;

            //Receive echoed data
            receivedData = UART_receiveData(__MSP430_BASEADDRESS_USCI_A0__);

            //Transmit next data
            UART_transmitData(__MSP430_BASEADDRESS_USCI_A0__,
            transmitData++
            );

            break;
        default: break;
    }
}


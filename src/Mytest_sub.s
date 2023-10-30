	THUMB
	AREA mydata, DATA
DELAY_INTERVAL EQU 0x026004	
COUNT 	EQU 10	;we will test count up to 10
SUM		EQU 0
RCC_BASE		EQU		0x40021000
RCC_AHBENR		EQU		RCC_BASE + 0x14
RCC_AHB1ENR   	EQU  	0x40023830

GPIOA_MODER   EQU  0x48000000 ;Address offset:0x00
GPIOA_OTYPER  EQU  0x48000004 ;Address offset: 0x04
GPIOA_OSPEEDR EQU  0x48000008 ;Address offset: 0x08
GPIOA_PUPDR   EQU  0x4800000C ;Address offset: 0x0C
GPIOA_ODR     EQU  0x48000014 ;ddress offset: 0x14
; same offsets for PORTC as well B1 at PC_13
GPIOC_MODER   EQU  0x48000800 ;Address offset:0x00
GPIOC_OSPEEDR EQU  0x48000808 ;Address offset: 0x08
GPIOC_PUPDR   EQU  0x4800080C ;Address offset: 0x0C
GPIOC_ODR     EQU  0x48000814 ;ddress offset: 0x14
	
; RCC_AHB1ENR (RCC AHB1 peripheral clock enable register) enables or disables clock supply to various peripherals. 
; AHB1 indicates these peripherals are on AHB1 bus of processor. To use GPIO port A, we need to enable clock for GPIO-A via this register.

; GPIOD_MODER (GPIO-D Mode register) controls the mode for port D pins. We can configure each pin independently as either of these modes:
; 00 Digital Input
; 01 Digital Output
; Analog Function
; Alternate function peripheral within the microcontroller

; GPIOA_OTYPER (GPIO-A Output Type register) controls whether the pin works in push-pull mode or as an open-drain pin. 
; In case of open drain, we need external pull-up or pull-down.

; GPIOA_OSPEEDR (GPIO-A Output Speed register) controls the maximum switching speed on the port pin. 
; The maximum speed also depends on supply voltage, current drawn from pin and load capacitance. We can configure the speed as low / medium / high / very high.

; GPIOA_PUPDR (GPIO-A Pull-up / Pull-down register) enables internal pull-up or pull-down resistor for each port A pin.

; GPIOA_ODR (GPIO-A Output Data register) is the register to write data to output on the port pins.

; Export functions so they can be called from other file	

	
	AREA MYCODE, CODE ;reserve space in memory
		ENTRY
		EXPORT SystemIn
		EXPORT __main

			
SystemIn FUNCTION
	;GPIOC clock aktif
	
	LDR R6, =RCC_AHBENR	; RCC_AHBENR degerini R6'ya yükle
	LDR R0, =0x000A0000	; 0x000A0000 degerini R0'a yükle 1010 enable A and C
	STR R0, [R6]		; RCC_AHBENR harici degiskenine 0x000A0000 degerini yükle
	
	; Set mode as output
	; LDR	r3, =0x00000100 ; DO NOT USE THIS LINE
	LDR r4, =GPIOA_MODER ; GPIOa_MODER register address 01: General purpose output mode GPIO Moder 01 port 5 as output  01XX XXXX XXXX PA5=01 
	LDR    R3,  [R4] ;Always retrieve current status
	AND.W  R3,  #0xFFFFF7FF 
	ORR.W  R3,  #0x00000400
	STR r3, [r4]
	
	; Set mode as input
	;GPIO Moder 01 PORT 13 as input  00XX  XXXX  XXXX  XXXX  XXXX  XXXX  XXXX = 3FFFFFF PC13=00 as output 
	LDR r4, =GPIOC_MODER ; General purpose INPUT mode
	LDR    R3,  [R4] ;Always retrieve current status
	AND.W  R3,  #0xF3FFFFFF 
	STR r3, [r4]
	
	; Set type as push-pull	OUTPUT(Default)
	LDR    R1,  =GPIOA_OTYPER
	LDR    R0,  [R1]
	AND.W  R0,  #0xFFFFFF0F ; PIN5 is reset as push-pull mode (reset state)
	STR    R0,  [R1]
	
	; Set Speed slow PA5 XXXX  XXXX  XX0X  XXXX
	LDR    R1,  =GPIOA_OSPEEDR
	LDR    R0,  [R1]
	AND.W  R0,  #0xFFFFFFDF ; PIN5 low speed at 0
	STR    R0,  [R1]
	
	; Set Speed slow PC13  XX0X  XXXX  XXXX  XXXX
	LDR    R1,  =GPIOC_OSPEEDR
	LDR    R0,  [R1]
	AND.W  R0,  #0xFFFFDFFF ; PIN13 low speed at 0
	STR    R0,  [R1]
	
	; Set pull-up 00: No pull-up, pull-down 01: Pull-up
	LDR    R1,  =GPIOA_PUPDR
	LDR    R0,  [R1]
	AND.W  R0,  #0xFFFFF3FF ; 00XX XXXX XXXX no need for pull up pull down 
	STR    R0,  [R1]
	
	; Set pull-up PC13 so that it detects a zero when pushed and '1' when not pushed
	LDR    R1,  =GPIOC_PUPDR
	LDR    R0,  [R1]
	AND.W  R0,  #0xF7FFFFFF ; 01XX XXXX XXXX XXXX XXXX XXXX XXXX  need for pull up 
	STR    R0,  [R1]
	BX		LR
	ENDFUNC
		
__main FUNCTION
	LDR r0, =COUNT
	LDR r1, =SUM
	LDR	r2, =1
	
myloop
	ADD r1,r2,r1 ;sum = i+sum
	ADD r2, r2, #1 ; increment i
	SUBS r4, r0, r2 ; r4=r0-r2 check if r0 and r2 are equal
	BNE myloop
	ADD r1,r2,r1
	

turnON ;start of the loop by turning it on

	LDR	r3, =0x00000020
	LDR r4, =GPIOA_ODR ; GPIOA_ADR
	STR r3, [r4]
	
	LDR   R2,  =DELAY_INTERVAL
delay1
    CBZ	  R2,  turnOFF
    SUBS  R2,  R2, #1     
	B     delay1

turnOFF
	LDR	r3, =0x00000000
	LDR r4, =GPIOA_ODR ; GPIOA_ODR
	STR r3, [r4]

	LDR   R2,  =DELAY_INTERVAL
delay2
    CBZ	  R2,  OutHere
    SUBS  R2,  R2, #1     
	B     delay2
OutHere
	B turnON
;stop	B stop

	ENDFUNC ;end main
	END
	THUMB
	AREA mydata, DATA
DELAY_INTERVAL EQU 0x086004	
COUNT 	EQU 10	;we will test count up to 10
SUM		EQU 0
RCC_BASE		EQU		0x40021000
RCC_AHBENR		EQU		RCC_BASE + 0x14
RCC_AHB1ENR   EQU  0x40023830

GPIOA_MODER   EQU  0x48000000 ;Address offset:0x00
GPIOA_OTYPER  EQU  0x48000004 ;Address offset: 0x04
GPIOA_OSPEEDR EQU  0x48000008 ;Address offset: 0x08
GPIOA_PUPDR   EQU  0x4800000C ;Address offset: 0x0C
GPIOA_ODR     EQU  0x48000014 ;ddress offset: 0x14
	
; RCC_AHB1ENR (RCC AHB1 peripheral clock enable register) enables or disables clock supply to various peripherals. 
; AHB1 indicates these peripherals are on AHB1 bus of processor. To use GPIO port A, we need to enable clock for GPIO-A via this register.

; GPIOD_MODER (GPIO-D Mode register) controls the mode for port D pins. We can configure each pin independently as either of these modes:
; Digital Input
; Digital Output
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
		EXPORT __main
  		EXPORT Initialize

Initialize FUNCTION
	;GPIOC clock aktif
	
	LDR R6, =RCC_AHBENR	; RCC_AHBENR degerini R6'ya yükle
	LDR R0, =0x00020000	; 0x000E0000 degerini R0'a yükle
	STR R0, [R6]		; RCC_AHBENR harici degiskenine 0x00020000 degerini yükle
	
	; Set mode as output
	LDR	r3, =0x00000100 ;GPIO Moder 01 port 5 as output 00 00 01 00 00 00 00 00 PA5=1
	LDR r4, =GPIOA_MODER ; GPIOa_MODER register address
	LDR    R3,  [R4]
	AND.W  R3,  #0xFFFFF7FF 
	ORR.W  R3,  #0x00000400
	STR r3, [r4]
	
	; Set type as push-pull	(Default)
	LDR    R1,  =GPIOA_OTYPER
	LDR    R0,  [R1]
	AND.W  R0,  #0xFFFFFF0F ; PIN5 is reset as push-pull mode (reset state)
	STR    R0,  [R1]
	
	; Set Speed slow
	LDR    R1,  =GPIOA_OSPEEDR
	LDR    R0,  [R1]
	AND.W  R0,  #0xFFFFFF0F ; PIN5 low speed
	STR    R0,  [R1]
	
	; Set pull-up
	LDR    R1,  =GPIOA_PUPDR
	LDR    R0,  [R1]
	AND.W  R0,  #0xFFFFFF0F ; no need for pull up pull down 
	STR    R0,  [R1]
ENDFUNC

__main FUNCTION
; Some looping stuff here
 	LDR r0, =COUNT
	LDR r1, =SUM
	LDR	r2, =1
	
myloop
	ADD r1,r2,r1 ;sum = i+sum
	ADD r2, r2, #1 ; increment i
	SUBS r4, r0, r2 ; r4=r0-r2 check if r0 and r2 are equal
	BNE myloop
	ADD r1,r2,r1
 
; REAL Program Turn on and off below
turnON

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
	ENDFUNC
	END

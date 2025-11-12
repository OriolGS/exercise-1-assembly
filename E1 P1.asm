;
;			        Escuela Universitaria 'Tomàs Cerdà'
;                     Fundamentos de Computadores
;                        Ejercicio 1 (1a parte)
;
;   Leer el estado de 6 interruptores/pulsadores E7-E2, 
;   conectados al puerto A (RA5-RA0) y activar los leds S7-S0 
;   conectados al puerto B (RB7-RB0), según la tabla:
;
;	      ENTRADAS                      SALIDAS
;  =======================   =====================================
;  E7  E6  E5  E4  E3  E2    S7	 S6  S5  S4  S3  S2  S1  S0 
;  RA5 RA4 RA3 RA2 RA1 RA0   RB7 RB6 RB5 RB4 RB3 RB2 RB1 RB0 PORTB
;  --- --- --- --- --- ---   --- --- --- --- --- --- --- --- -----
;   x   x   x   x   0   x     0   0   0   0   0   0   0   0  (00h)
;   1   1   1   1   1   x     0   0   0   0   1   1   1   1  (0Fh)
;   0   x   x   x   1   x     1   0   0   0   1   1   1   1  (8Fh)
;   1   0   x   x   1   x     0   1   0   0   1   1   1   1  (4Fh)
;   1   1   0   x   1   x     0   0   1   0   1   1   1   1  (2Fh)
;   1   1   1   0   1   x     0   0   0   1   1   1   1   1  (1Fh)
;  =======================   ======================================
;
					
		List	p=16F887			;Tipo de procesador
		include	"P16F887.INC"		;Definiciones de registros internos

;Ajusta los valores de las palabras de configuración durante el ensamblado.
;Los bits no empleados adquieren el valor por defecto.
;Estos y otros valores se pueden modificar según las necesidades.

	__config _CONFIG1, _LVP_OFF&_PWRTE_ON&_WDT_OFF&_EC_OSC&_FCMEN_OFF&_BOR_OFF 	
		     ;Palabra 1 de configuración
	__config _CONFIG2, _WRT_OFF		
		     ;Palabra 2 de configuración

		org	0x00
		goto	Inicio			;Vector de reset
		org	0x05	

Inicio	bsf	STATUS,RP0	        ;Selecciona Banco 1
			bsf	STATUS,RP1	    ;Selecciona Banco 3
				clrf	ANSEL	;Puerta A digital
				clrf	ANSELH	;Puerta B digital
			bcf		STATUS,RP1	;Selecciona Banco 1
			movlw	b'00000010'		
			movwf	TRISA		;Puerta A se configura como entrada
			movlw	b'00000000'		
			movwf	TRISB		;Puerta B se configura como salida
			movlw	b'00000000'		
			movwf	TRISC		;Puerta C se configura
			movlw	b'00011110'		
			movwf	TRISD		;Puerta D se configura
		bcf		STATUS,RP0		;Selecciona Banco 0

ApagarTodo	
		clrf	PORTB	;Apagar los LEDs conectados al PORTB
		bcf		PORTC,2
		bcf		PORTD,5
		bcf		PORTD,6
		bcf		PORTD,7
		
	
InterE3				 
	btfss PORTA,RA1		;Leer la entrada E3 (RA1)
	goto E3Apagado		;Si está apagado (RA1==0) apagar todos los LEDs
	goto E3Encendido	;Si está encendido (RA1==1) encendres LED's (S3-S0) 
						;   mantener estado LED's (S7-S4)
						;   y mirar pulsadores.

E3Apagado
		goto ApagarTodo	;ApagarTodo

;BUCLE PRINCIPAL
E3Encendido			
	movlw   b'00001111'			;Encendre LEDs S3-S0 (RB3-RB0=1)
	iorwf   PORTB,1				;Mantener estado LEDs S7-S4 (RB7-RB4)
	goto MirarPulsadorE7	
	
MirarPulsadorE7			
	btfsc PORTD,1			;Leer pulsador E7 (RA5)
	goto MirarPulsadorE6 	
	goto PulsadorE7Activo
	
MirarPulsadorE6			
	btfsc PORTD,2
	goto MirarPulsadorE5 	
	goto PulsadorE6Activo			;Si está activo (RA4==0)
					;ir a activar LEDs S7-S4 (RB7-RB4='0100')	
		
MirarPulsadorE5
	btfsc PORTD,3
	goto MirarPulsadorE4 	
	goto PulsadorE5Activo			
					;Leer pulsador E5 (RA3)
					;Si no está activo (RA3==1) ir a MirarPulsadorE4
					;Si está activo (RA3==0)
					;ir a activar LEDs S7-S4 (RB7-RB4='0010')	
		
MirarPulsadorE4
	btfsc PORTD,4
	goto NoActivos 	
	goto PulsadorE4Activo		
					;Leer pulsador E4 (RA2)
					;Si no está activo (RA2==1) ir a NoActivos
					;Si está activo (RA2==0)
					;ir a activar LEDs S7-S4 (RB7-RB4='0001')	
		
NoActivos				
		goto ApagarTodo			;Apagar LEDs S7-S4 (RB7-RB4='0000')
					;Mantener estado LEDs S3-S0 (RB3-RB0)
		
		goto	InterE3

PulsadorE7Activo
        bsf PORTD,5         
        bcf PORTC,2
		bsf PORTD,7
		bcf PORTD,6
		goto InterE3
		
PulsadorE6Activo
        bcf PORTD,5         
        bsf PORTC,2
		bcf PORTD,7
		bsf PORTD,6            ;Activar LEDs S7-S4 (RB7-RB4='1000')
		
		goto InterE3
		
PulsadorE5Activo
        bsf PORTD,5         
        bcf PORTC,2
		bcf PORTD,7
		bsf PORTD,6            ;Activar LEDs S7-S4 (RB7-RB4='0010')	
		
		goto	InterE3		

PulsadorE4Activo
        bcf PORTD,5         
        bsf PORTC,2
		bsf PORTD,7
		bcf PORTD,6            ;Activar LEDs S7-S4 (RB7-RB4='0001')	
		
		goto	InterE3	
		
		end			;Fin del programa


#include "p16f84.inc"

c_stack_empty_addr	set	0x0F

v_stack_count	equ	0x1F

org 0x08
movlw c_stack_empty_addr
movwf FSR
movlw 0
movwf v_stack_count

BEGIN:
	movlw 0x03
	call PUSHW
	
	movlw 0x10
	call PUSHW
	
	movlw 0xA1
	call PUSHW
	
	movlw 0x27
	call PUSHW
	
	movlw 0x00
	call POPW
	
	call POPW
	
	addlw 0x03
	call PUSHW
	
	nop
	
	call CLEAR
	
	movlw 0xFF
	call POPW
	
	movlw 0x01
	call POPW
	
	goto _END

PUSHW:
	incf FSR
	movwf INDF
	incf v_stack_count
	return

POPW:
	movf v_stack_count, W
	btfsc STATUS, Z
	goto _END_POP
	movf INDF, W
	clrf INDF
	decf FSR
	decf v_stack_count
_END_POP:
	return

CLEAR:
	movf v_stack_count, W
	btfsc STATUS, Z
	goto _END_CLEAR
	CLR_LOOP:
		clrf INDF
		decf FSR
		decf v_stack_count
		btfss STATUS, Z
		goto CLR_LOOP
_END_CLEAR:
	return

_END:
	nop
	end
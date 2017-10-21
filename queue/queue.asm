#include "p16f84.inc"

c_q_init_addr	set	0x20

v_q_count	equ 0x1F
v_q_head	equ	0x1E
v_q_tail	equ	0x1D

v_tmp		equ 0x1C

org 0x08
clrf v_q_count
call CLEAR	; reset head and tail

BEGIN:
	movlw 0x03
	call ENQUEUE
	
	movlw 0x10
	call ENQUEUE
	
	movlw 0xA1
	call ENQUEUE
	
	movlw 0x27
	call ENQUEUE
	
	movlw 0x00
	call DEQUEUE
	
	call DEQUEUE
	
	addlw 0x03
	call ENQUEUE
	
	nop
	
	call CLEAR
	
	movlw 0xFF
	call DEQUEUE
	
	movlw 0x01
	call DEQUEUE
	
	goto _END

ENQUEUE:
	movwf v_tmp
	movf v_q_head, W
	movwf FSR
	movf v_tmp, W
	movwf INDF
	incf v_q_count
	incf v_q_head
	return

DEQUEUE:
	movf v_q_count, W
	btfsc STATUS, Z
	goto _END_DEQUEUE
	movf v_q_tail, W
	movwf FSR
	movf INDF, W
	clrf INDF
	decf v_q_count
	incf v_q_tail
_END_DEQUEUE:
	return

CLEAR:
	movf v_q_count, W
	btfsc STATUS, Z
	goto _END_CLEAR
	CLR_LOOP:
		call DEQUEUE
		movf v_q_count, W
		btfss STATUS, Z
		goto CLR_LOOP
_END_CLEAR:
	movlw c_q_init_addr
	movwf v_q_tail
	movwf v_q_head
	return

_END:
	nop
	end
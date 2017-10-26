#include "p16f84.inc"

v_value		equ	0x1F

org 0x08

BEGIN:
	
;	Gray's codes
	clrf v_value
	LOOP_G:
		rrf v_value, W
		andlw b'01111111'	;	do non-cyclic shift
		xorwf v_value, W
	; here, in W, the next Gray's code lies...
		incf v_value
		btfss STATUS, Z
		goto LOOP_G
	;goto _END
	
;	Johnson's codes
	clrf v_value
	LOOP_J_1:
		bsf v_value, 7
		rlf v_value, F
		movf v_value, W
	; here, in W, the next Johnson's code lies...
		xorlw b'11111111'
		btfss STATUS, Z
		goto LOOP_J_1
	LOOP_J_0:
		bcf v_value, 7
		rlf v_value, F
		movf v_value, W
	; here, in W, the next Johnson's code lies...
		btfss STATUS, Z
		goto LOOP_J_0
	goto _END

_END:
	nop
	end

#include "p16f84.inc"

;
;	One-directional list
;
;	Item (buffer block) = 2 bytes:
;		[next_addr][value]
;
;	if buffer block is empty: 	next_addr = 0x00
;	if item is last: 			next_addr = 0xFF
;

c_list_buf_addr	set	0x20

c_list_head_addr	set 0x1F
c_list_start	set 0x28
v_list_start	equ	0x1F

v_iter			equ 0x1C

v_new_value		equ	0x0F
v_next_item		equ 0x0E
v_new_item_addr	equ 0x0D

org 0x08
movlw c_list_start
movwf v_list_start

BEGIN:
	movlw 0xB0
	movwf v_new_value
	
	movlw 0
;	call GET_W_TH_ADDR	; addr => FSR
	movf FSR, W
	
	movlw c_list_head_addr	; insert to head
	
	call INSERT_AFTER_W
	goto _END

	; get pointer to W-th item in list
	; if W > count, returns pointer to last item
	; if list is empty, returns pointer to empty block
	; result => FSR
GET_W_TH_ADDR:
	movwf v_iter
	movf v_list_start, W
	G_LOOP:
		movwf FSR			; get next item in list
		movf INDF, W
		
		btfsc STATUS, Z
		goto _END_GET_W_TH	; empty list
		
		xorlw 0xFF
		btfsc STATUS, Z
		goto _END_GET_W_TH	; last item
		
		movf v_iter, W
		btfsc STATUS, Z
		goto _END_GET_W_TH	; W-th item reached
		
		movf INDF, W
		decf v_iter
		goto G_LOOP
	_END_GET_W_TH:
	return

	; insert new_value after item with address W
	; init [v_new_value]
INSERT_AFTER_W:
	movwf v_iter			; save W
	movwf FSR
	movf INDF, W			; get next address
	btfsc STATUS, Z
	movlw 0xFF		; if empty list, new item is last
	movwf v_next_item		; save next address
	
	call FIND_EMPTY_BLOCK	; FSR <= empty block address
	
	movf FSR, W
	movwf v_new_item_addr	; save pointer to new block
	
	movf v_next_item, W		; write pointer to next item
	movwf INDF
	incf FSR				; write value to new block
	movf v_new_value, W
	movwf INDF
	
	movf v_iter, W
	movwf FSR				; get item with address W
	
	movf v_new_item_addr, W	; write pointer to new item
	movwf INDF
	
	return

FIND_EMPTY_BLOCK:	; return empty block address in FSR
	movlw c_list_buf_addr
	movwf FSR
	F_LOOP:
		movf INDF, W
		btfsc STATUS, Z	; next_addr = 0x00 - empty
		goto _END_F_LOOP
		
		movlw 2
		addwf FSR, F
		goto F_LOOP
	_END_F_LOOP:
	return

_END:
	nop
	end
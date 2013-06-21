/*
 *  Uzebox Kernel - Mode 8
 *  Copyright (C) 2009  Alec Bourque
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *  Uzebox is a reserved trade mark
*/

;****************************************************
; Video Mode 11 - Chip8
; Bitmappep mode: 1bpp with 64x32 and 128x64
;****************************************************	
	
.global InitializeVideoMode
.global DisplayLogo
.global VideoModeVsync
.global ClearVram
.global __do_copy_data ;These must be present or .data/.bss may not be initialized correctly
.global __do_clear_bss ;see: https://savannah.nongnu.org/bugs/index.php?36124
.global sub_mode
.global BlitSprite
.global SetVramPointer

.section .bss
	

.section .data	
	vram_ptr:		.word 0
	sub_mode:		.byte 0
	bytes_per_row:	.byte 8
	
.section .text

sub_video_mode12:
	clr r1				;always zero	
	lds YL,vram_ptr
	lds YH,vram_ptr+1

	cp  YL,r1			;quit if vram pointer is NULL
	cpc YH,r1
	brne .+2
	ret 

	WAIT r16,1350-15-4

	clr r20				;rendered lines counter

	lds r25,sub_mode

	ldi r21,6			;row height=32
	cpse r25,r1		
	ldi r21,3			;row height=64
	mov r22,r21

	ldi r23,192			;screen height=224
	cpse r25,r1		
	ldi r23,192			;screen height=192

	ldi r24,8			;bytes per row=8
	cpse r25,r1		
	ldi r24,16			;bytes per row=16



;*************************************************************
; Rendering main loop starts here
;*************************************************************
next_scan_line:	
	rcall hsync_pulse 

	WAIT r19,330 - AUDIO_OUT_HSYNC_CYCLES + CENTER_ADJUSTMENT -43+5

	;***draw line***
	rcall render_tile_line

	WAIT r19,118 - CENTER_ADJUSTMENT -44-5


	;repeat each line
	clt
	cpi r21,1
	breq .+2
	set
	brts .+2
	add YL,r24
	brts .+2
	adc YH,r1

	dec r21
	brne .+2
	mov r21,r22

	inc r20
	cp r20,r23			;more scanline to draw?
	brne next_scan_line

	nop
	rcall hsync_pulse ;145
	
	;set vsync flag & flip field
	lds ZL,sync_flags
	ldi r20,SYNC_FLAG_FIELD
	ori ZL,SYNC_FLAG_VSYNC
	eor ZL,r20
	sts sync_flags,ZL
			
	;clear any pending timer int
	ldi ZL,(1<<OCF1A)
	sts _SFR_MEM_ADDR(TIFR1),ZL

	clr r1

	ret


;*************************************************
; RENDER TILE LINE
;
; Y  = VRAM adress to draw from (must not be modified)
; r1=0
; r24= bytes per row
; r25= sub mode
;
; Do not destroy registers from the main loop
;
; cycles  = 1495
;*************************************************
render_tile_line:
	movw r2,YL ;push
	mov r18,r24


///64 pixels wide submode @ 22 cycles per pixel///
	ld r16,Y+ ;load next 8 pixels
main_loop_64:		

	rol r16
	sbc r0,r0	
	out _SFR_IO_ADDR(DATA_PORT),r0 ;pixel 0
	ldi r17,6
	dec r17
	brne .-4
	nop

	rol r16
	sbc r0,r0	
	out _SFR_IO_ADDR(DATA_PORT),r0 ;pixel 1
	ldi r17,6
	dec r17
	brne .-4
	nop

	rol r16
	sbc r0,r0	
	out _SFR_IO_ADDR(DATA_PORT),r0 ;pixel 2
	ldi r17,6
	dec r17
	brne .-4
	nop

	rol r16
	sbc r0,r0	
	out _SFR_IO_ADDR(DATA_PORT),r0 ;pixel 3
	ldi r17,6
	dec r17
	brne .-4
	nop

	rol r16
	sbc r0,r0	
	out _SFR_IO_ADDR(DATA_PORT),r0 ;pixel 4
	ldi r17,6
	dec r17
	brne .-4
	nop

	rol r16
	sbc r0,r0	
	out _SFR_IO_ADDR(DATA_PORT),r0 ;pixel 5
	ldi r17,6
	dec r17
	brne .-4
	nop

	rol r16
	sbc r0,r0	
	out _SFR_IO_ADDR(DATA_PORT),r0 ;pixel 6
	ldi r17,6
	dec r17
	brne .-4
	nop

	rol r16
	sbc r0,r0	
	out _SFR_IO_ADDR(DATA_PORT),r0 ;pixel 7
	ldi r17,4
	dec r17
	brne .-4
	rjmp .
	ld r16,Y+ ;load next 8 pixels

	dec r18
	brne main_loop_64

	rjmp .
	clr r0
	out _SFR_IO_ADDR(DATA_PORT),r0 ;clear last pixel


	movw YL,r2 ;pop
	ret


;***********************************
; Set the origin VRAM location 
; C-callable
; r25:r24 = pointer 
;************************************
.section .text.SetVramPointer
SetVramPointer:
	sts vram_ptr,r24
	sts vram_ptr+1,r25
	ret


;***********************************
; Blit a sprite in XOR mode
; C-callable
; r24 = X
; r22 = Y
; r21:r20 = pointer to first sprite byte
; r18 = sprite heigth (1-15)
;************************************
.section .text.BlitSprite
BlitSprite:
	push r16
	push r17

	movw XL,r20

	lds ZL,vram_ptr
	lds ZH,vram_ptr+1

	;X>>3
	mov r25,r24
	lsr r25
	lsr r25
	lsr r25
	add ZL,r25
	adc ZH,r1

	;compute *VRAM+(Y*bytes_per_row)
	lds r25,bytes_per_row
	mul r25,r22	 ; bytes_per_row * Y
	add ZL,r0
	adc ZH,r1
	clr r1

	;r18=sprite height
	;r19=pixels offset to shift
	;r20=vram / shift loop counter
	;r21=vram+1
	;r22=shifted sprite
	;r23=shifted sprite+1
	;r24=collision detected
	;r25=bytes per row

	mov r19,r24	
	andi r19,7	;pixel offset to shift	
	clr r24
	main_loop:	
	clr r23
	ld r22,X+	;load next sprite byte
	mov r20,r19	;copy number of pixels to shift
	cpi r20,0
	breq no_shift
	shift_loop:	
	lsr r22	 ;shift bit into next vram address
	ror r23
	dec r20
	brne shift_loop
	no_shift:

	ld r20,Z
	ldd r21,Z+1
	movw r16,r20	
	eor r20,r22
	eor r21,r23
	st Z,r20
	std Z+1,r21

	//check for collision	
	and r16,r22
	breq .+2
	ser r24
	and r17,r23
	breq .+2
	ser r24

	add ZL,r25	;next pixel row
	adc ZH,r1
	dec r18
	brne main_loop

	andi r24,1	;return if collision was detected
	clr r1

	pop r17
	pop r16

	ret


;***********************************
; CLEAR VRAM
; Fill the screen with the specified tile
; C-callable
; C-prototype: void ClearVram(void)
;************************************
ClearVram:
	lds XL,vram_ptr
	lds XH,vram_ptr+1
	cp  XL,r1			;quit if vram pointer is NULL
	cpc XH,r1
	brne .+2
	ret 

	//submode 0 vram_size
	ldi r24,lo8(256/4)	

clear_loop:	
	st X+,r1
	st X+,r1
	st X+,r1
	st X+,r1
	dec r24
	brne clear_loop

	ret


;Nothing to do in this mode
DisplayLogo:
VideoModeVsync:
InitializeVideoMode:
	ret


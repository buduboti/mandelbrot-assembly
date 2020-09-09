%include 'io.inc'
%include 'gfx.inc'
%include 'mio.inc'

%define WIDTH  1440 ;1364 ; 1366 nem megy...
%define HEIGHT 900  ;768

global _start

section .text
_start:
	.begining:
	mov 	eax, hellomsg
	call 	mio_writestr
	xor 	eax, eax
	call 	mio_readchar
	cmp 	eax, 's'
	je 		.single
	cmp 	eax, 'd'
	je 		.double
	jmp 	.begining

	.double:
	mov		eax, WIDTH		
	mov		ebx, HEIGHT		
	mov		ecx, 1			
	mov		edx, caption	
	call	gfx_init
	
	test	eax, eax		
	jnz		IFS_df

	mov		eax, errormsg
	call	io_writestr
	call	io_writeln
	ret

	.single:
    mov		eax, WIDTH		
	mov		ebx, HEIGHT		
	mov		ecx, 1			
	mov		edx, caption	
	call	gfx_init
	
	test	eax, eax		
	jnz		IFS

	mov		eax, errormsg
	call	io_writestr
	call	io_writeln
	ret

IFS:
	.mainloop:
	push 	eax
	xor 	eax, eax
	call 	gfx_showcursor
	pop 	eax

	call	gfx_map			; map the framebuffer -> EAX will contain the pointer
	xor		ecx, ecx		; ECX - line (Y)
	.yloop:
	cmp		ecx, HEIGHT
	jge		.yend	
	
	xor		edx, edx		; EDX - column (X)
	.xloop:
	cmp		edx, WIDTH
	jge		.xend

	; PIXEL KI 		  #########################################################################################################################################

	call 	Iterate 		; xmm6 = Iterate (byte)
	;xor 	esi, esi
	;pextrd 	edi, xmm6, 3
	;and 	edi, 0x000000ff
	;add 	esi, edi
	;shl 	esi, 8
	;pextrd 	edi, xmm6, 2
	;and 	edi, 0x000000ff
	;add 	esi, edi
	;shl 	esi, 8
	;pextrd 	edi, xmm6, 1
	;and 	edi, 0x000000ff
	;add 	esi, edi
	;shl 	esi, 8
	;pextrd 	edi, xmm6, 0
	;and 	edi, 0x000000ff
	;add 	esi, edi

	movaps 	xmm7, [Max_ITER_v]
	addps 	xmm7, [pici_v]
	roundps xmm7, xmm7, 2

	xor 	esi, esi
	
	movaps 	xmm0, xmm6
	shufps 	xmm0, xmm0, 3
	comiss 	xmm0, xmm7
	jne 	.sz
	xor 	ebx, ebx
	call 	pixelez_s
	add  	eax, 4
	jmp 	.d
	.sz:
	cvtss2si 	edi, xmm0
	mov 	ebx, edi
	and 	ebx, 0x000000ff	
	call 	pixelez_s
	add  	eax, 4
	.d:

	movaps 	xmm0, xmm6
	shufps 	xmm0, xmm0, 2
	comiss 	xmm0, xmm7
	jne 	.sz1
	xor 	ebx, ebx
	call 	pixelez_s
	add  	eax, 4
	jmp 	.d1
	.sz1:
	cvtss2si 	edi, xmm0
	mov 	ebx, edi
	and 	ebx, 0x000000ff	
	call 	pixelez_s
	add  	eax, 4
	.d1:

	movaps 	xmm0, xmm6
	shufps 	xmm0, xmm0, 1
	comiss 	xmm0, xmm7
	jne 	.sz2
	xor 	ebx, ebx
	call 	pixelez_s
	add  	eax, 4
	jmp 	.d2
	.sz2:
	cvtss2si 	edi, xmm0
	mov 	ebx, edi
	and 	ebx, 0x000000ff	
	call 	pixelez_s
	add  	eax, 4
	.d2:

	movaps 	xmm0, xmm6
	comiss 	xmm0, xmm7
	jne 	.sz3
	xor 	ebx, ebx
	call 	pixelez_s
	add  	eax, 4
	jmp 	.d3
	.sz3:
	cvtss2si 	edi, xmm0
	mov 	ebx, edi
	and 	ebx, 0x000000ff	
	call 	pixelez_s
	add  	eax, 4
	.d3:



	; esi-ben 4 pixel értéke

	

;	mov 	ebx, esi
;	shr 	ebx, 8
;	and 	ebx, 0x000000ff
;	call 	pixelez_s
;	add  	eax, 4

;	mov 	ebx, esi
;	shr 	ebx, 16
;	and 	ebx, 0x000000ff
;	call 	pixelez_s
;	add  	eax, 4

;	mov 	ebx, esi
;	shr 	ebx, 24
;	and 	ebx, 0x000000ff
;	call 	pixelez_s
;	add  	eax, 4

	add		edx, 4
	jmp		.xloop
	
	.xend:
	inc		ecx
	jmp		.yloop
	
	.yend:
	call	gfx_unmap		; unmap the framebuffer
	call	gfx_draw		; draw the contents of the framebuffer (*must* be called once in each iteration!)
	
	.eventloop: 			; Handle exit
	call	gfx_getevent
	cmp		eax, 23			; the window close button was pressed: exit
	je		.end
	cmp		eax, 27			; ESC: exit
	je		.end
	cmp 	eax, 'n'
	je 		.zoom_in
	cmp 	eax, 'm'
	je 		.zoom_out
	cmp 	eax, 'w'
	je 		.fel
	cmp 	eax, 'a'
	je 		.bal
	cmp 	eax, 's'
	je 		.le
	cmp 	eax, 'd'
	je 		.jobb

	test	eax, eax		; 0: no more events
	jnz		.eventloop
	jmp 	.mainloop

	.le:
	movaps 	xmm0, [g_2_v]
	divps 	xmm0, [tiz_v]
	movaps 	xmm1, [g_1_v]
	addps 	xmm1, xmm0
	movaps 	[g_1_v], xmm1
	;call 	kiir
	jmp 	.mainloop

	.fel:

	movaps 	xmm0, [g_2_v]
	divps 	xmm0, [tiz_v]
	movaps 	xmm1, [g_1_v]
	subps 	xmm1, xmm0
	movaps 	[g_1_v], xmm1
	;call 	kiir
	jmp 	.mainloop

	.jobb:
	movaps 	xmm0, [f_2_v]
	divps 	xmm0, [tiz_v]
	movaps 	xmm1, [f_1_v]
	addps 	xmm1, xmm0
	movaps 	[f_1_v], xmm1
	;call 	kiir
	jmp 	.mainloop

	.bal:
	movaps 	xmm0, [f_2_v]
	divps 	xmm0, [tiz_v]
	movaps 	xmm1, [f_1_v]
	subps 	xmm1, xmm0
	movaps 	[f_1_v], xmm1
	;call 	kiir
	jmp 	.mainloop


	.zoom_in:
	;koord+=(1-mertek)/2
	;nyujtas*=mertek;
	movaps 	xmm0, [f_1_v]
	movaps 	xmm2, [egy_v]
	subps 	xmm2, [zoom_meret_v] ; (1-m)
	divps 	xmm2, [ketto_v] ; (1-m)/2
	mulps 	xmm2, [f_2_v]
	addps 	xmm0, xmm2 	; xmm0+=(1-m)/2;
	movaps 	[f_1_v], xmm0

	movaps 	xmm1, [f_2_v]
	mulps 	xmm1, [zoom_meret_v]
	movaps 	[f_2_v], xmm1	; 
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	movaps 	xmm0, [g_1_v]
	movaps 	xmm2, [egy_v]
	subps 	xmm2, [zoom_meret_v] ; (1-m)
	divps 	xmm2, [ketto_v] ; (1-m)/2
	mulps 	xmm2, [g_2_v]
	addps 	xmm0, xmm2 	; xmm0+=(1-m)/2;
	movaps 	[g_1_v], xmm0

	movaps 	xmm1, [g_2_v]
	mulps 	xmm1, [zoom_meret_v]
	movaps 	[g_2_v], xmm1

	nop

	push 	eax
	push 	ebx
	push 	edx
	mov 	eax, [Max_ITER]
	;cvtsi2ss 	xmm0, eax

	;movss 		xmm1, [zoom_iter]
	;mulss 		xmm0, xmm1

	;cvtss2si 	eax, xmm0
	
		mov 	ebx, 6
		imul 	ebx
		mov 	ebx, 5
		idiv 	ebx


	mov 	[Max_ITER], eax
	pop 	edx
	pop 	ebx
	pop 	eax

	movaps 	xmm7, [Max_ITER_v]
	mulps 	xmm7, [_1_2]
	movaps 	[Max_ITER_v], xmm7

	jmp 	.mainloop

	.zoom_out:
	;koord+=(1-mertek)/2
	;nyujtas*=mertek;
	movaps 	xmm0, [f_1_v]
	movaps 	xmm2, [egy_v]
	subps 	xmm2, [zoom_meret_inv_v] ; (1-m)
	divps 	xmm2, [ketto_v] ; (1-m)/2
	mulps 	xmm2, [f_2_v]
	addps 	xmm0, xmm2 	; xmm0+=(1-m)/2;
	movaps 	[f_1_v], xmm0

	movaps 	xmm1, [f_2_v]
	mulps 	xmm1, [zoom_meret_inv_v]
	movaps 	[f_2_v], xmm1	; 
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	movaps 	xmm0, [g_1_v]
	movaps 	xmm2, [egy_v]
	subps 	xmm2, [zoom_meret_inv_v] ; (1-m)
	divps 	xmm2, [ketto_v] ; (1-m)/2
	mulps 	xmm2, [g_2_v]
	addps 	xmm0, xmm2 	; xmm0+=(1-m)/2;
	movaps 	[g_1_v], xmm0

	movaps 	xmm1, [g_2_v]
	mulps 	xmm1, [zoom_meret_inv_v]
	movaps 	[g_2_v], xmm1

	push 	eax
	push 	ebx
	push 	edx
	mov 	eax, [Max_ITER]
	;cvtsi2ss 	xmm0, eax

	;movss 		xmm1, [zoom_iter]
	;divss 		xmm0, xmm1

	;cvtss2si 	eax, xmm0
	
		mov 	ebx, 5
		imul 	ebx
		mov 	ebx, 6
		idiv 	ebx


	movaps 	xmm7, [Max_ITER_v]
	divps 	xmm7, [_1_2]
	movaps 	[Max_ITER_v], xmm7


	mov 	[Max_ITER], eax
	pop 	edx
	pop 	eax

	jmp 	.mainloop
    
	; Exit
.end:
	call	gfx_destroy
    ret

Iterate:			
	CVTSI2SS 	xmm0, edx
	shufps 		xmm0, xmm0, 0h
	addps 		xmm0, [INCR]

	movaps 	 	xmm6, [WIDTH_fp_v]
	divps 		xmm0, xmm6
	mulps 		xmm0, [f_2_v]
	addps 		xmm0, [f_1_v] 		; xmm0 = f

	CVTSI2SS 	xmm1, ecx			;convert scalar intiger 2 scaler single
	shufps 		xmm1, xmm1, 0h
	movaps 	 	xmm6, [HEIGHT_fp_v] 
	divps 		xmm1, xmm6
	mulps 		xmm1, [g_2_v]
	addps 		xmm1, [g_1_v] 		; xmm1 = g

	xorps 		xmm2, xmm2
	xorps 		xmm3, xmm3
	xorps 		xmm4, xmm4
	xorps 		xmm6, xmm6
	xor 		ebx, ebx
	movaps 		xmm5, [egy_v]

	.loop_head:
	movaps 		xmm7, xmm2 	; s = r

	mulps 		xmm2, xmm2 	; r^=2 (xmm2)
	
	movaps 		xmm4, xmm3 	; c
	mulps 		xmm4, xmm3 	; xmm4 = c^2 
	subps 		xmm2, xmm4 	; r=_r^2 - _c^2 (xmm2)
	addps 		xmm2, xmm0 	; r=_r^2 - _c^2 + f (xmm2) 
	; r=r^2-c^2+f <xmm4><temp>

	mulps 		xmm3, xmm7 	; c=_c*_r 
	mulps 		xmm3, [ketto_v] 	; c=_c*_r*2
	addps 		xmm3, xmm1	; c = 2*r*c + g
	; save: xmm5

	;xorps 		xmm6, xmm6 		
	movaps 		xmm4, xmm2 	; size = r
	mulps 		xmm4, xmm2 	; size = r^2
 	movaps 		xmm7, xmm3 	; xmm5 = c
	mulps 		xmm7, xmm3	; xmm5 = c^2
	addps 		xmm4, xmm7	; size = r^2 + c^2
	; xmm4 = size = r^2 + c^2 <xmm5><temp>

	;mulps 		xmm5, xmm7 ; masked size
							; 7 - mask
; size > 0
; iterations > 0
nop

	xorps  		xmm7, xmm7
	xor 	esi, esi

	;cmplepd  xmm4, xmm7	
	; check if every pixel is ready
	;push 	 eax
	;movmskpd eax, xmm4

	; incrementing pixels which are not ready
	;movsd 	 xmm7, [ONE_D]
	;shufpd 	 xmm7, xmm7, 0h
	;andpd 	 xmm4, xmm7
	;addpd 	 xmm6, xmm4


	cmpneqps  		xmm7, xmm5 
	movmskps  		esi, xmm7  ; esi - mask
	; esi - mask (4bit)
	; xmm4 - mask (full)
	;movaps 		xmm7, xmm4 	; mask
	;andps 		xmm7, [egy_v]
	cmp 	esi, 0 ; esi - temp
	je	 	.end;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;movaps 		xmm4, xmm6 ; ebx
	movaps 			xmm7, [Max_ITER_v]
	cmpnltps 		xmm7, xmm6
	movmskps 	esi, xmm7
	cmp 	esi, 0
	je 		.u_end

	andps 	xmm5, xmm7
	;movaps 		xmm4, xmm5

	movaps 			xmm7, [Max_ITER_v]
	
	
	cmpnltps 		xmm7, xmm4 
	movmskps  		esi, xmm7  ; esi - mask
	
	call 	esi_xmm5
	;mulps 	xmm7, xmm5
	addps 	xmm6, xmm5	
	
	
	;call 	not7
	;andps 	xmm6, xmm7 ; xmm7 - not_mask
	;addps 	xmm6, xmm5
	;call 	not7

	jmp 	.loop_head
	.end: 	; esi == 0
	;return xmm6

	ret
	.u_end:

;movaps 	xmm6, [Max_ITER_v]

	;xorps 	xmm6, xmm6

	;mov 	edi, 0     
	ret

; xmm0 = f
; xmm1 = g
; xmm2 = r = real
; xmm3 = c = cplx
; xmm4 = size
; xmm5 = s = save
; xmm6 - ret
; xmm7 - mask

esi_xmm5:	; esi alsó négy bitjét kiterjeszti xmm5 egész részére (movmskps - inverze)

	;movaps 	xmm5, [egy_v]
	and 	esi, 0x0000000f
	cmp  	esi, 0
	jne 	.nem0
	andps	xmm5, [_0]
	ret
	.nem0:
	
	cmp  	esi, 1
	jne 	.nem1
	andps	xmm5, [_1]
	ret
	.nem1:
	
	cmp  	esi, 2
	jne 	.nem2
	andps	xmm5, [_2]
	ret
	.nem2:
	
	cmp  	esi, 3
	jne 	.nem3
	andps	xmm5, [_3]
	ret
	.nem3:
	
	cmp  	esi, 4
	jne 	.nem4
	andps	xmm5, [_4]
	ret
	.nem4:
	
	cmp  	esi, 5
	jne 	.nem5
	andps	xmm5, [_5]
	ret
	.nem5:
	
	cmp  	esi, 6
	jne 	.nem6
	andps	xmm5, [_6]
	ret
	.nem6:
	
	cmp  	esi, 7
	jne 	.nem7
	andps	xmm5, [_7]
	ret
	.nem7:
	
	cmp  	esi, 8
	jne 	.nem8
	andps	xmm5, [_8]
	ret
	.nem8:
	
	cmp  	esi, 9
	jne 	.nem9
	andps	xmm5, [_9]
	ret
	.nem9:
	
	cmp  	esi, 10
	jne 	.nema
	andps	xmm5, [_a]
	ret
	.nema:
	
	cmp  	esi, 11
	jne 	.nemb
	andps	xmm5, [_b]
	ret
	.nemb:
	
	cmp  	esi, 12
	jne 	.nemc
	andps	xmm5, [_c]
	ret
	.nemc:
	
	cmp  	esi, 13
	jne 	.nemd
	andps	xmm5, [_d]
	ret
	.nemd:
	
	cmp  	esi, 14
	jne 	.neme
	andps	xmm5, [_e]
	ret
	.neme:
	
 	;movaps 	xmm7, [_f]
	ret

IFS_df:
	.mainloop:
	push 	eax
	xor 	eax, eax
	call 	gfx_showcursor
	pop 	eax

	call	gfx_map			; map the framebuffer -> EAX will contain the pointer
	xor		ecx, ecx		; ECX - line (Y)
	.yloop:
	cmp		ecx, HEIGHT
	jge		.yend	
	
	xor		edx, edx		; EDX - column (X)
	.xloop:
	cmp		edx, WIDTH
	jge		.xend

	; PIXEL KI 		  #########################################################################################################################################

	call 	Iterate_df 		; Bx = Iterate (byte)


	movapd 	xmm7, [Max_ITER_d_v]
	addpd 	xmm7, [pici_d_v]
	roundpd xmm7, xmm7, 2

	xor 	esi, esi

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	movapd 	xmm0, xmm6
	shufpd 	xmm0, xmm0, 1
	comisd 	xmm0, xmm7
	jne 	.sz
	xor 	ebx, ebx
	call 	pixelez_s
	add  	eax, 4
	jmp 	.d
	.sz:
	cvtsd2si 	edi, xmm0
	mov 	ebx, edi
	and 	ebx, 0x000000ff	
	call 	pixelez_s
	add  	eax, 4
	.d:

	movapd 	xmm0, xmm6
	comisd 	xmm0, xmm7
	jne 	.sz1
	xor 	ebx, ebx
	call 	pixelez_s
	add  	eax, 4
	jmp 	.d1
	.sz1:
	cvtsd2si 	edi, xmm0
	mov 	ebx, edi
	and 	ebx, 0x000000ff	
	call 	pixelez_s
	add  	eax, 4
	.d1:

	add 	edx, 2
	jmp		.xloop
	
	.xend:
	inc		ecx
	jmp		.yloop
	
	.yend:
	call	gfx_unmap		; unmap the framebuffer
	call	gfx_draw		; draw the contents of the framebuffer (*must* be called once in each iteration!)
	
	.eventloop: 			; Handle exit
	call	gfx_getevent
	cmp		eax, 23			; the window close button was pressed: exit
	je		.end
	cmp		eax, 27			; ESC: exit
	je		.end
	cmp 	eax, 'n'
	je 		.zoom_in
	cmp 	eax, 'm'
	je 		.zoom_out
	cmp 	eax, 'w'
	je 		.fel
	cmp 	eax, 'a'
	je 		.bal
	cmp 	eax, 's'
	je 		.le
	cmp 	eax, 'd'
	je 		.jobb

	test	eax, eax		; 0: no more events
	jnz		.eventloop
	jmp 	.mainloop

	.le:
	movapd 	xmm0, [g_2_d_v]
	divpd 	xmm0, [tiz_d_v]
	movapd 	xmm1, [g_1_d_v]
	addpd 	xmm1, xmm0
	movapd 	[g_1_d_v], xmm1
	;call 	kiir
	jmp 	.mainloop

	.fel:

	movapd 	xmm0, [g_2_d_v]
	divpd 	xmm0, [tiz_d_v]
	movapd 	xmm1, [g_1_d_v]
	subpd 	xmm1, xmm0
	movapd 	[g_1_d_v], xmm1
	;call 	kiir
	jmp 	.mainloop

	.jobb:
	movapd 	xmm0, [f_2_d_v]
	divpd 	xmm0, [tiz_d_v]
	movapd 	xmm1, [f_1_d_v]
	addpd 	xmm1, xmm0
	movapd 	[f_1_d_v], xmm1
	;call 	kiir
	jmp 	.mainloop

	.bal:
	movapd 	xmm0, [f_2_d_v]
	divpd 	xmm0, [tiz_d_v]
	movapd 	xmm1, [f_1_d_v]
	subpd 	xmm1, xmm0
	movapd 	[f_1_d_v], xmm1
	;call 	kiir
	jmp 	.mainloop


	.zoom_in:
	;koord+=(1-mertek)/2
	;nyujtas*=mertek;
	movapd 	xmm0, [f_1_d_v]
	movapd 	xmm2, [egy_d_v]
	subpd 	xmm2, [zoom_meret_d_v] ; (1-m)
	divpd 	xmm2, [ketto_d_v] ; (1-m)/2
	mulpd 	xmm2, [f_2_d_v]
	addpd 	xmm0, xmm2 	; xmm0+=(1-m)/2;
	movapd 	[f_1_d_v], xmm0

	movapd 	xmm1, [f_2_d_v]
	mulpd 	xmm1, [zoom_meret_d_v]
	movapd 	[f_2_d_v], xmm1	; 
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	movapd 	xmm0, [g_1_d_v]
	movapd 	xmm2, [egy_d_v]
	subpd 	xmm2, [zoom_meret_d_v] ; (1-m)
	divpd 	xmm2, [ketto_d_v] ; (1-m)/2
	mulpd 	xmm2, [g_2_d_v]
	addpd 	xmm0, xmm2 	; xmm0+=(1-m)/2;
	movapd 	[g_1_d_v], xmm0

	movapd 	xmm1, [g_2_d_v]
	mulpd 	xmm1, [zoom_meret_d_v]
	movapd 	[g_2_d_v], xmm1

	nop

	push 	eax
	push 	ebx
	push 	edx
	mov 	eax, [Max_ITER]
	;cvtsi2ss 	xmm0, eax

	;movss 		xmm1, [zoom_iter]
	;mulss 		xmm0, xmm1

	;cvtss2si 	eax, xmm0
	
		mov 	ebx, 6
		imul 	ebx
		mov 	ebx, 5
		idiv 	ebx


	mov 	[Max_ITER], eax
	pop 	edx
	pop 	ebx
	pop 	eax

	movapd 	xmm7, [Max_ITER_d_v]
	mulpd 	xmm7, [_1_2_d]
	movapd 	[Max_ITER_d_v], xmm7

	;call 	kiir
	jmp 	.mainloop

	.zoom_out:
	;koord+=(1-mertek)/2
	;nyujtas*=mertek;
	movapd 	xmm0, [f_1_d_v]
	movapd 	xmm2, [egy_d_v]
	subpd 	xmm2, [zoom_meret_inv_d_v] ; (1-m)
	divpd 	xmm2, [ketto_d_v] ; (1-m)/2
	mulpd 	xmm2, [f_2_d_v]
	addpd 	xmm0, xmm2 	; xmm0+=(1-m)/2;
	movapd 	[f_1_d_v], xmm0

	movapd 	xmm1, [f_2_d_v]
	mulpd 	xmm1, [zoom_meret_inv_d_v]
	movapd 	[f_2_d_v], xmm1	; 
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	movapd 	xmm0, [g_1_d_v]
	movapd 	xmm2, [egy_d_v]
	subpd 	xmm2, [zoom_meret_inv_d_v] ; (1-m)
	divpd 	xmm2, [ketto_d_v] ; (1-m)/2
	mulpd 	xmm2, [g_2_d_v]
	addpd 	xmm0, xmm2 	; xmm0+=(1-m)/2;
	movapd 	[g_1_d_v], xmm0

	movapd 	xmm1, [g_2_d_v]
	mulpd 	xmm1, [zoom_meret_inv_d_v]
	movapd 	[g_2_d_v], xmm1

	push 	eax
	push 	ebx
	push 	edx
	mov 	eax, [Max_ITER]
	;cvtsi2ss 	xmm0, eax

	;movss 		xmm1, [zoom_iter]
	;divss 		xmm0, xmm1

	;cvtss2si 	eax, xmm0
	
		mov 	ebx, 5
		imul 	ebx
		mov 	ebx, 6
		idiv 	ebx


	movapd 	xmm7, [Max_ITER_d_v]
	divpd 	xmm7, [_1_2_d]
	movapd 	[Max_ITER_d_v], xmm7


	mov 	[Max_ITER], eax
	pop 	edx
	pop 	eax

	;call 	kiir
	jmp 	.mainloop
    
	; Exit
.end:
	call	gfx_destroy
    ret

pixelez_s:
	cmp 	ebx, 0     	    ; nincs benne...			;######################################################################################################
	jne	 	.szines										;###########																				###########
	xor 	ebx, ebx									;###########	########	########	###  ###	########	############	########	###########
	mov		[eax], bl		; blue						;###########	####		####		### ### 	####			####		####		###########
	mov		[eax+1], bl		; green						;###########	########	########	#####   	########		####		########	###########
	mov		[eax+2], bl		; red						;###########	####		####		### ###  	####			####		####		###########
	mov		[eax+3], bl		; zero						;###########	####		########	###  ###	########		####		########	###########
	ret 					;next pixel					;###########																				###########
;														;######################################################################################################
	.szines:

	cmp 	bx, 85
	jge 	.tovabb1

	push 	ebx
	xor 	ebx, ebx
	mov 	[eax], bl
	pop 	ebx

	push 	edx
	push 	eax
	mov 	eax, ebx
	mov 	ebx, 3
	imul 	ebx
	mov 	ebx, eax
	pop 	eax
	mov 	[eax+1], bl
	push 	eax
	mov 	eax, 255
	sub 	eax, ebx
	mov 	ebx, eax
	pop 	eax
	mov 	[eax+2], bl
	pop 	edx
	xor 	ebx, ebx
	mov		[eax+3], bl

	ret
	.tovabb1:

	cmp 	bx, 170
	jge 	.tovabb2

		sub 	ebx, 85

	push 	ebx
	xor 	ebx, ebx
	mov 	[eax+2], bl
	pop 	ebx
	push 	edx
	push 	eax
	mov 	eax, ebx
	mov 	ebx, 3
	imul 	ebx
	mov 	ebx, eax
	pop 	eax
	mov 	[eax], bl
	push 	eax
	mov 	eax, 255
	sub 	eax, ebx
	mov 	ebx, eax
	pop 	eax
	mov 	[eax+1], bl
	pop 	edx
	xor 	ebx, ebx
	mov		[eax+3], bl

	ret
	.tovabb2:

		sub 	ebx, 170

	push 	ebx
	xor 	ebx, ebx
	mov 	[eax+1], bl
	pop 	ebx
	push 	edx
	push 	eax
	mov 	eax, ebx
	mov 	ebx, 3
	imul 	ebx
	mov 	ebx, eax
	pop 	eax
	mov 	[eax+2], bl
	push 	eax
	mov 	eax, 255
	sub 	eax, ebx
	mov 	ebx, eax
	pop 	eax
	mov 	[eax], bl
	pop 	edx
	xor 	ebx, ebx
	mov		[eax+3], bl
	ret

Iterate_df:			
	CVTSI2SD 	xmm0, edx
	shufpd 		xmm0, xmm0, 0
	addpd 		xmm0, [INCR_d_v]

	movapd 	 	xmm6, [WIDTH_fp_d_v]
	divpd 		xmm0, xmm6
	mulpd 		xmm0, [f_2_d_v]
	addpd 		xmm0, [f_1_d_v] 		; xmm0 = f

	CVTSI2SD 	xmm1, ecx			;convert scalar intiger 2 scaler single
	shufpd 		xmm1, xmm1, 0
	movapd 	 	xmm6, [HEIGHT_fp_d_v] 
	divpd 		xmm1, xmm6
	mulpd 		xmm1, [g_2_d_v]
	addpd 		xmm1, [g_1_d_v] 		; xmm1 = g

	xorps 		xmm2, xmm2
	xorps 		xmm3, xmm3
	xorps 		xmm4, xmm4
	xorps 		xmm6, xmm6
	xor 		ebx, ebx	
	movapd 		xmm5, [egy_d_v]


	.loop_head:
	movapd 		xmm7, xmm2 	; s = r

	mulpd 		xmm2, xmm2 	; r^=2 (xmm2)
	
	movapd 		xmm4, xmm3 	; c
	mulpd 		xmm4, xmm3 	; xmm4 = c^2 
	subpd 		xmm2, xmm4 	; r=_r^2 - _c^2 (xmm2)
	addpd 		xmm2, xmm0 	; r=_r^2 - _c^2 + f (xmm2) 
	; r=r^2-c^2+f <xmm4><temp>

	mulpd 		xmm3, xmm7 	; c=_c*_r 
	mulpd 		xmm3, [ketto_d_v] 	; c=_c*_r*2
	addpd 		xmm3, xmm1	; c = 2*r*c + g
	; save: xmm5

	;xorps 		xmm6, xmm6 		
	movapd 		xmm4, xmm2 	; size = r
	mulpd 		xmm4, xmm2 	; size = r^2
 	movapd 		xmm7, xmm3 	; xmm5 = c
	mulpd 		xmm7, xmm3	; xmm5 = c^2
	addpd 		xmm4, xmm7	; size = r^2 + c^2
	; xmm4 = size = r^2 + c^2 <xmm5><temp>

	;mulps 		xmm5, xmm7 ; masked size
							; 7 - mask

; size > 0
; iterations > 0
	
	xorps  		xmm7, xmm7
	xor 	esi, esi

	cmpneqpd  		xmm7, xmm5 
	movmskpd  		esi, xmm7  ; esi - mask
	cmp 	esi, 0 ; esi - temp
	je	 	.end;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;movaps 		xmm4, xmm6 ; ebx
	movaps 			xmm7, [Max_ITER_d_v]
	cmpnltpd 		xmm7, xmm6
	movmskpd 	esi, xmm7
	cmp 	esi, 0
	je 		.u_end

	andpd 	xmm5, xmm7
	;movaps 		xmm4, xmm5

	movapd 			xmm7, [Max_ITER_d_v]
	
	
	cmpnltpd 		xmm7, xmm4 
	movmskpd  		esi, xmm7  ; esi - mask
	
	call 	esi_xmm5_d
	addpd 	xmm6, xmm5	
	
	jmp 	.loop_head
	.end: 	; esi == 0
	;return xmm6

	ret
	.u_end:
	ret

esi_xmm5_d:
	and 	esi, 0x00000003
	cmp 	esi, 0
	jne 	.nem0
	andps	xmm5, [_0_d]
	ret
	.nem0:
	
	cmp  	esi, 1
	jne 	.nem1
	andps	xmm5, [_1_d]
	ret
	.nem1:
	
	cmp  	esi, 2
	jne 	.nem2
	andps	xmm5, [_2_d]
	ret
	.nem2:
	
	cmp  	esi, 3
	jne 	.nem3
	andps	xmm5, [_3_d]
	ret
	.nem3:

	ret
	
section .data
	_0 dd 0.0, 0.0, 0.0, 0.0
	_1 dd 1.0, 0.0, 0.0, 0.0
	_2 dd 0.0, 1.0, 0.0, 0.0
	_3 dd 1.0, 1.0, 0.0, 0.0
	_4 dd 0.0, 0.0, 1.0, 0.0
	_5 dd 1.0, 0.0, 1.0, 0.0
	_6 dd 0.0, 1.0, 1.0, 0.0
	_7 dd 1.0, 1.0, 1.0, 0.0
	_8 dd 0.0, 0.0, 0.0, 1.0
	_9 dd 1.0, 0.0, 0.0, 1.0
	_a dd 0.0, 1.0, 0.0, 1.0
	_b dd 1.0, 1.0, 0.0, 1.0
	_c dd 0.0, 0.0, 1.0, 1.0
	_d dd 1.0, 0.0, 1.0, 1.0
	_e dd 0.0, 1.0, 1.0, 1.0
	_f dd 1.0, 1.0, 1.0, 1.0
	Max_ITER_v dd 128.0, 128.0, 128.0, 128.0
	pici_v dd 0.001, 0.001, 0.001, 0.001
	INCR dd 3.0, 2.0, 1.0, 0.0
	;INCR dd 0.0, 1.0, 2.0, 3.0
	iiih dd 0xffffffff, 0xffffffff, 0xffffffff, 0x00000000 
	hhhi dd 0x00000000, 0x00000000, 0x00000000, 0xffffffff  
	konv dd 0.0, 0.0, 0.0, 0.0
	zoom_iter_v dd 1.2, 1.2, 1.2, 1.2
	zoom_meret_v dd 0.5, 0.5, 0.5, 0.5
	zoom_meret_inv_v dd 2.0, 2.0, 2.0, 2.0
	 f_1_v dd -2.25, -2.25, -2.25, -2.25 	; x koord
	 f_2_v dd 3.0, 3.0, 3.0, 3.0		; x nyujt
	 g_1_v dd -1.25, -1.25, -1.25, -1.25 	; y koord
	 g_2_v dd 2.5, 2.5, 2.5, 2.5		; y nyujt
;f_1_v dd -1.173340, -1.173340, -1.173340, -1.173340
;f_2_v dd 0.002930, 0.002930, 0.002930, 0.002930
;g_1_v dd -0.296631, -0.296631, -0.296631, -0.296631
;g_2_v dd 0.002441, 0.002441, 0.002441, 0.002441
	WIDTH_fp_v dd 1364.0, 1364.0, 1364.0, 1364.0
	HEIGHT_fp_v dd 768.0, 768.0, 768.0, 768.0
	ketto_v dd 2.0, 2.0, 2.0, 2.0
	szaz_v dd 100.0, 100.0, 100.0, 100.0
	tiz_v dd 10.0, 10.0, 10.0, 10.0
	egy_v dd 1.0, 1.0, 1.0, 1.0
	_1_2 dd 1.2, 1.2, 1.2, 1.2


	_0_d dq 0.00, 0.00
	_1_d dq 1.00, 0.00
	_2_d dq 0.00, 1.00
	_3_d dq 1.00, 1.00
	WIDTH_fp_d_v dq 1364.00, 1364.00
	HEIGHT_fp_d_v dq 768.00, 768.00
	f_1_d_v dq -2.25, -2.25 	; x koord
	f_2_d_v dq 3.00, 3.00		; x nyujt
	g_1_d_v dq -1.25, -1.25 	; y koord
	g_2_d_v dq 2.50, 2.50		; y nyujt
	INCR_d_v dq 1.00, 0.00
	Max_ITER_d_v dq 128.00, 128.00
	ketto_d_v dq 2.00, 2.00
	egy_d_v dq 1.00, 1.00
	_1_2_d dq 1.20, 1.20
	zoom_meret_d_v dq 0.50, 0.50
	zoom_meret_inv_d_v dq 2.00, 2.00
	tiz_d_v dq 10.00, 10.00
	pici_d_v dq 0.001, 0.001
	
	zoom_meret_s dd 'zoom_meret_s', 0
	zoom_meret_inv_s dd 'zoom_meret_inv_s', 0
	f_1_s dd 'f_1_s', 0 	; x koord
	f_2_s dd 'f_2_s', 0		; x nyujt
	g_1_s dd 'g_1_s', 0 	; y koord
	g_2_s dd 'g_2_s', 0		; y nyujt	

    caption db "Iterated Function Systems", 0
	errormsg db "ERROR: Nem inicializalhato a grafika!", 0
	hellomsg db "A mozgatas a WASD billentyukkel megy, a n illetve m gombokkal zoomol be es ki. Esc-el lehet kilepni. Kerem adja meg, hogy single vagy double float pontossaggal szamoljon a program. (s/d):", 0

	Max_ITER dd 0x80
	zoom_iter dd 1.2
	zoom_meret dd 0.5
	zoom_meret_inv dd 2.0
	f_1 dd -2.25 	; x koord
	f_2 dd 3.0		; x nyujt
	g_1 dd -1.25 	; y koord
	g_2 dd 2.5		; y nyujt
	WIDTH_fp dd 1364.0
	HEIGHT_fp dd 768.0
	ketto dd 2.0
	szaz dd 100.0
	tiz dd 10.0
	egy dd 1.0

	ITER_r dd 0x80
	zoom_iter_d dq 1.2
	zoom_meret_d dq 0.50
	zoom_meret_inv_d dq 2.00
	f_1_d dq -2.25 	; x koord
	f_2_d dq 3.00		; x nyujt
	g_1_d dq -1.25 	; y koord
	g_2_d dq 2.50		; y nyujt
	f_1_r_d dq -2.25 	; x koord
	f_2_r_d dq 3.00		; x nyujt
	g_1_r_d dq -1.25 	; y koord
	g_2_r_d dq 2.50		; y nyujt
	WIDTH_fp_d dq 1364.00
	HEIGHT_fp_d dq 768.00
	ketto_d dq 2.00
	szaz_d dq 100.00
	tiz_d dq 10.00
	egy_d dq 1.00

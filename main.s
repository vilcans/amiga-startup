; Set demo compatibility
; 0: 68000 only, Kickstart 1.3 only, PAL only
; 1: All CPUs, Kickstarts and display modes
; 2: 68010+, Kickstart 3.0+, all display modes
COMPATIBILITY = 0

; Set to 1 to require fast memory
FASTMEM	= 0

; Set to 1 to enable pause on right mouse button
; with single-step on left mouse button
RMBPAUSE = 1

; Set to 1 if you use FPU code in your interrupt
FPUINT = 0

; Set to 1 if you use the copper, blitter or sprites, respectively
COPPER	=	1
BLITTER	=	0
SPRITE	=	0

; Set to 1 to get address of topaz font data in TopazCharData
TOPAZ = 0

; Set to 1 when writing the object file to enable section hack
SECTIONHACK = 0

	; Demo startup must be first for section hack to work
	include	DemoStartup.S


_Precalc:
	; Called as the very first thing, before system shutdown
	rts

_Exit:
	; Called after system restore
	moveq #0,d0
	rts

_Main:
	; Main demo routine, called by the startup.
	; Demo will quit when this routine returns.

	lea	copper,a1
	move.l	a1,$dff080

.loop:
	; Example: Fill screen gradually
	move.l	VBlank(pc),d0
	lea	bitplane,a1
	st.b	(a1,d0.l)

	bra.s	.loop

_Interrupt:
	; Called by the vblank interrupt.
	lea	bitplane,a1
	move.l	a1,$dff0e0

	rts

	section data_c

copper:
	dc.l	$008e2c81,$00902cc1
	dc.l	$00920038,$009400d0
	dc.l	$01001200,$01020000,$01060000,$010c0011
	dc.l	$01080000,$010a0000
	dc.l	$01800abc,$01820123
	dc.l	$01fc0000
	dc.l	$fffffffe

	section	chip,bss_c
Chip:
bitplane:
	ds.b	40*256
bitplaneEnd:

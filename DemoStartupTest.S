;              T         T               T

; Compact demo-startup by Blueberry/Loonies
; Example usage source code
; Version 1.3, August 22, 2013
; Public Domain

; Set demo compatibility
; 0: 68000 only, Kickstart 1.3 only, PAL only
; 1: All CPUs, Kickstarts and display modes
; 2: 68010+, Kickstart 3.0+, all display modes
COMPATIBILITY	=	1

; Set to 1 to require fast memory
FASTMEM	=	0

; Set to 1 to enable pause on right mouse button
; with single-step on left mouse button
RMBPAUSE	=	1

; Set to 1 if you use FPU code in your interrupt
FPUINT	=	0

; Set to 1 if you use the copper, blitter or sprites, respectively
COPPER	=	1
BLITTER	=	0
SPRITE	=	0

; Set to 1 to get address of topaz font data in TopazCharData
TOPAZ	=	0

; Set to 1 when writing the object file to enable section hack
SECTIONHACK	=	0


	; Demo startup must be first for section hack to work
	include	Inc:DemoStartup.S


_Precalc:
	; Called as the very first thing, before system shutdown

	; Example: Copy copperlist to chipram
	lea.l	CopperData(pc),a0
	move.l	ChipPtr(pc),a1
	lea.l	Copper-Chip(a1),a1
	moveq.l	#(CopperData_End-CopperData)/4-1,d7
.loop:	move.l	(a0)+,(a1)+
	dbf	d7,.loop

	rts


_Exit:
	; Called after system restore

	; Example: Cache flush test
	move.w	#1000-1,d7
.code:	move.l	#1,d2
	lea.l	.code+2(pc),a0
	addq.l	#1,(a0)
	CACHEFLUSH
	dbf	d7,.code
	; D2 should be 1000 here

	moveq.l	#0,d0
	rts


_Main:
	; Main demo routine, called by the startup.
	; Demo will quit when this routine returns.

	; Example: Set copper address
	move.l	ChipPtr(pc),a1
	lea.l	Copper-Chip(a1),a1
	move.l	a1,$dff080

MainLoop:
	; Example: Fill screen gradually
	move.l	VBlank(pc),d0
	move.l	ChipPtr(pc),a1
	lea.l	Bitplane-Chip(a1),a1
	st.b	(a1,d0.l)

	bra.w	MainLoop


_Interrupt:
	; Called by the vblank interrupt.

	; Example: Set bitplane pointer
	move.l	ChipPtr(pc),a1
	lea.l	Bitplane-Chip(a1),a1
	move.l	a1,$dff0e0

	rts


	; Example: Copperlist to display one bitplane

CopperData:
	dc.l	$008e2c81,$00902cc1
	dc.l	$00920038,$009400d0
	dc.l	$01001200,$01020000,$01060000,$010c0011
	dc.l	$01080000,$010a0000
	dc.l	$01800abc,$01820123
	dc.l	$01fc0000
	dc.l	$fffffffe
CopperData_End:


	; Place fast-mem space at the end of the code section to have
	; the cruncher remove it.

	; Example: Dummy space

DummySpace:
	ds.b	10000

	align	0,4


	; Place all chip space in the single chip section.
	; Define no other sections.

	section	chip,bss_c
Chip:

	; Example: Single bitplane
Copper:
	ds.b	CopperData_End-CopperData
Bitplane:
	ds.b	320*256/8

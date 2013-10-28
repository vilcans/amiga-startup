	; Create table of precalculated
	; (x >> 0) ^ (x >> 2) ^ (x >> 3) ^ (x >> 5)
	; with bit 0 extended to whole byte,
	; for x in 0..255
	; See http://en.wikipedia.org/wiki/Linear_feedback_shift_register
initRandom:
	lea	linearFeedbackTable(pc),a0
	moveq	#0,d3
.loop:
	move	d3,d0  ; temp lsfr and bit result in bit 0
	move	d0,d1
	lsr	#2,d1  ; lfsr >> 2
	eor	d1,d0  ; (lfsr >> 0) ^ (lfsr >> 2)
	lsr	#1,d1  ; lfsr >> 3
	eor	d1,d0  ; (lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3)
	lsr	#2,d1  ; lfsr >> 5
	eor	d1,d0  ; (lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5)
	lsr	#1,d0
	scs	(a0)+

	addq	#1,d3
	cmp	#256,d3
	bne.s	.loop
	rts

linearFeedbackTable:
	dcb.b	256

; Gets the next random number.
; Assumes d0 contains the previous number
; and that a0 points to linearFeedbackTable.
; Destroys d1.w.
; Example initialization:
;       lea	linearFeedbackTable(pc),a0
;       move #$ace1,d0

getRandom	macro
	sub	d1,d1
	move.b	d0,d1
	move.b	(a0,d1.w),d1
	roxr	#1,d1
	roxr	#1,d0
	endm

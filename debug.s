; Hangs until mousepress with an error color
; Typical usage:
;     cmp ....  ; assertion
;     beq .ok
;     failure $f00
; .ok:
failure        macro
.\@
	move	#\1,$dff180
	move	#0,$dff180
	btst	#10,$dff016
	bne.s	.\@
	endm

; Fails if a condition fails.
;
; Usage:
;     assert <cc>,<color>
;
; This checks whether the condition given in <cc> is valid,
; and if it is not, fails.
; For example:
;
;     assert eq,$f00
;
; This calls the failure macro with red color if the zero flag is not set.
assert	macro
	ifd	DEBUG
	b\1.s	.\@
	failure	\2
.\@:
	endc
	endm

; Asserts the comparison between 32 bit values.
; Out of debug mode, does nothing.
;
; Example:
;
;     assertl eq,#endOfCopperlist,a1,$f00
;
; Checks that a1.l is equal to #endOfCopperlist
; and calls failure with the color $f00 otherwise.
assertl	macro
	ifd	DEBUG
	cmp.l	\2,\3
	assert	\1,\4
	endc
	endm

; Asserts the comparison between 16 bit values.
; Out of debug mode, does nothing.
;
; Example:
;
;     assertw lt,#5,d0,$f00
;
; Checks that d0.w is less than 5 and
; calls failure with the color $f00 otherwise.
assertw	macro
	ifd	DEBUG
	cmp.w	\2,\3
	assert	\1,\4
	endc
	endm

; Asserts the comparison between 8 bit values.
; Out of debug mode, does nothing.
;
; Example:
;
;     assertb eq,#127,d0,$f00
;
; Checks that d0.b is equal to 127 and
; calls failure with the color $f00 otherwise.
assertb	macro
	ifd	DEBUG
	cmp.b	\2,\3
	assert	\1,\4
	endm

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

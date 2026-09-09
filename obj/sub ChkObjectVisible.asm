; ---------------------------------------------------------------------------
; Subroutine to check if an object is off screen

; output:
;	d0 = flag set if object is off screen
; ---------------------------------------------------------------------------

ChkObjectVisible:
		move.w	obX(a0),d0				; get object x-position
		sub.w	(v_scrposx).w,d0			; subtract screen x-position
		bmi.s	.offscreen				; branch if object is off screen to the left
		cmpi.w	#320,d0					; is object on screen?
		bge.s	.offscreen				; if not, object is off screen to the right

		move.w	obY(a0),d1				; get object y-position
		sub.w	(v_scrposy).w,d1			; subtract screen y-position
		bmi.s	.offscreen				; branch if object is off screen to the top
		cmpi.w	#224,d1					; is object on screen?
		bge.s	.offscreen				; if not, object is off screen to the bottom

		moveq	#0,d0					; set Z-flag (object on screen)
		rts
; ---------------------------------------------------------------------------

.offscreen:
		moveq	#1,d0					; clear Z-flag (object off screen)
		rts
; End of function ChkObjectVisible
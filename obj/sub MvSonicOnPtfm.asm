; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	update Sonic's position when standing on a platform.
; Also matches his X-position for moving platforms.
;
; input:
;	d2.w = platform X-position of previous frame
;	d3.w = platform height (MoveWithPlatform_CustomHeight only)
; ---------------------------------------------------------------------------

MvSonicOnPtfm:	; custom platform height (in d3)
		lea	(v_player).w,a1				; get Sonic object
		move.w	obY(a0),d0				; get Y-position of platform
		sub.w	d3,d0					; subtract input height from platform Y-position
		bra.s	MoveWithPlatform			; skip over
; ===========================================================================

MvSonicOnPtfm2:	; assume platform height (fixed to 9px)
		lea	(v_player).w,a1				; get Sonic object
		move.w	obY(a0),d0				; get Y-position of platform
		subi.w	#9,d0					; subtract assumed height of 9px from platform Y-position
; ---------------------------------------------------------------------------

; MvSonic2:
MoveWithPlatform:
		moveq	#0,d1
		move.b	obHeight(a1),d1				; get Sonic's current height
		sub.w	d1,d0					; d1 = Y-position so Sonic's feet are on the platform
		move.w	d0,obY(a1)				; set that as Sonic's new Y-position

		sub.w	obX(a0),d2				; d2 = X-delta of platform since last frame
		sub.w	d2,obX(a1)				; update Sonic's X-position to move with the platform

	.return:
		rts
; End of function MvSonicOnPtfm

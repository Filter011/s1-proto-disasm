; ===========================================================================
; ---------------------------------------------------------------------------
; Object 50 - Yadrin enemy (MZ, SZ)
; ---------------------------------------------------------------------------

Yadrin:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Yad_Index(pc,d0.w),d1
		jmp	Yad_Index(pc,d1.w)
; ===========================================================================
Yad_Index:
		dc.w	Yad_Main-Yad_Index
		dc.w	Yad_Action-Yad_Index

yad_timedelay:	equ objoff_30	; delay before turning around
; ===========================================================================

Yad_Main:	; Routine 0
		move.l	#Map_Yad,obMap(a0)			; set mappings
		move.w	#ArtTile_Yadrin|Tile_Pal2,obGfx(a0)	; set art tile and palette line
		move.b	#sprite_cam_field,obRender(a0)		; set to playfield-positioned mode
		move.b	#4,obPriority(a0)			; set sprite priority
		move.b	#40/2,obActWid(a0)			; set sprite display width
		move.b	#34/2,obHeight(a0)			; set height
		move.b	#16/2,obWidth(a0)			; set width
		move.b	#col_40x32|col_special,obColType(a0)	; set hitbox size to 40x32 (special collision response type for Yadrins to make the harmful on top)

		; Make the Yadrin fall until it has collided with the floor (while invisible)
		bsr.w	ObjectFall				; increase gravity and update position
		bsr.w	ObjFloorDist				; get distance between Yadrin and floor
		tst.w	d1					; has Yadrin hit the floor?
		bpl.s	.hide					; if not, branch
		add.w	d1,obY(a0)				; match object's position with the floor
		move.w	#0,obVelY(a0)				; clear falling speed
		addq.b	#2,obRoutine(a0)			; advance to Moto_Action
		bchg	#0,obStatus(a0)				; make Yadrin face to the left on spawn
	.hide:

	if FixBugs
		; Fix badnik invisibly falling forever if it doesn't have a floor beneath it
		cmpi.w	#$7FF,obY(a0)				; has object fallen below max level height?
		bhi.w	DeleteObject				; if yes, delete it
	endif
		rts						; return (and do NOT display sprite yet)
; ===========================================================================

Yad_Action:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Yad_ActIndex(pc,d0.w),d1
		jsr	Yad_ActIndex(pc,d1.w)

		lea	(Ani_Yad).l,a1
		bsr.w	AnimateSprite
		bra.w	RememberState
; ===========================================================================
Yad_ActIndex:
		dc.w	Yad_Action_Wait-Yad_ActIndex		; 0
		dc.w	Yad_Action_Move-Yad_ActIndex		; 2
; ===========================================================================

Yad_Action_Wait:
		subq.w	#1,yad_timedelay(a0)			; subtract 1 from pause time
		bpl.s	.return					; if time remains, branch

		addq.b	#2,ob2ndRout(a0)			; advance to Yad_Action_Move
		move.w	#-$100,obVelX(a0)			; move Yadrin to the left
		move.b	#1,obAnim(a0)				; set to walk animation
		bchg	#0,obStatus(a0)				; invert horizontal orientation
		bne.s	.return					; if looking left nowallhit, branch
		neg.w	obVelX(a0)				; move Yadrin to the right instead

	.return:
		rts
; ===========================================================================

Yad_Action_Move:
		bsr.w	SpeedToPos				; update Yadrin's position

		bsr.w	ObjFloorDist				; get distance to floor
		cmpi.w	#-8,d1					; is there a steep upward slope ahead?
		blt.s	.pause					; if yes, branch
		cmpi.w	#$C,d1					; is there a large drop ahead?
		bge.s	.pause					; if yes, branch
		add.w	d1,obY(a0)				; match Yadrin's position with floor as it moves

		bsr.w	ChkHitLeftRightWall			; has Yadrin hit a left or right wall?
		bne.s	.pause					; if yes, branch
		rts
; ---------------------------------------------------------------------------

	.pause:
		subq.b	#2,ob2ndRout(a0)			; go back to Yad_Action_Wait
		move.w	#60-1,yad_timedelay(a0)			; set pause time before turning around to 1 second
		move.w	#0,obVelX(a0)				; stop Yadrin moving
		move.b	#0,obAnim(a0)				; set to wait animation
		rts

; ===========================================================================

		include	"_anim/Yadrin.asm"
Map_Yad:	include	"_maps/Yadrin.asm"

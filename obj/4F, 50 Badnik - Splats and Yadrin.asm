; ---------------------------------------------------------------------------
; Object 4F - Splats (scrapped Marble Zone badnik)
; ---------------------------------------------------------------------------
 
Obj4F:
Splats:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	.index(pc,d0.w),d1
		jmp	.index(pc,d1.w)
; ---------------------------------------------------------------------------
.index:
		dc.w	.init-.index				; 0 - object init
		dc.w	.waitforsonic-.index			; 2 - wait for Sonic to enter a certain trigger zone (bounce in place until then)
		dc.w	.chkbounce-.index			; 4 - trigger zone entered, apply movement and check for floor to bounce
		dc.w	.fallthroughfloor-.index		; 6 - special case after hitting lava: phase through floor and despawn on screen exit
; ---------------------------------------------------------------------------
 
.init:
		addq.b	#2,obRoutine(a0)			; set to WaitForSonic
		move.l	#Map_Splats,obMap(a0)			; set maps
		move.w	#ArtTile_Splats|Tile_Pal2,obGfx(a0)	; set art tile
		move.b	#sprite_cam_field,obRender(a0)		; set to playfield-positioned mode
		move.b	#4,obPriority(a0)			; set sprite priority
		move.b	#24/2,obActWid(a0)			; set width
		move.b	#40/2,obHeight(a0)			; set height
		move.b	#col_24x40|col_badnik,obColType(a0)	; set coltype to badnik
		tst.b	obSubtype(a0)				; is subtype anything but zero?
		beq.s	.waitforsonic				; if not, branch
		move.w	#$300,d2				; set trigger zone to start moving to be significantly larger
		bra.s	.triggerzoneset				; skip
; ---------------------------------------------------------------------------
 
.waitforsonic:
		move.w	#$E0,d2					; set default (small) trigger zone
 
.triggerzoneset:
		move.w	#$100,d1				; prepare X velocity to be $100
		bset	#sprite_xflip_bit,obRender(a0)		; make object face to the right
		move.w	(v_player+obX).w,d0			; get Sonic's X position
		sub.w	obX(a0),d0				; subtract object's X position
		bhs.s	.chktriggerzonehit			; if object is to the right of Sonic, branch
		neg.w	d0					; negate distance
		neg.w	d1					; negate prepared X velocity
		bclr	#sprite_xflip_bit,obRender(a0)		; make object face to the left
 
.chktriggerzonehit:
		cmp.w	d2,d0					; is Sonic within the trigger zone?
		bhs.s	.chkbounce				; if not, bounce in place
		move.w	d1,obVelX(a0)				; begin moving horizontally
		addq.b	#2,obRoutine(a0)			; set to .chkbounce
 
.chkbounce:
		bsr.w	ObjectFall				; apply gravity
		move.b	#1,obFrame(a0)				; set frame to 1 (bouncy, flappy ears)
		tst.w	obVelY(a0)				; is object moving upwards?
		bmi.s	.chkwall				; if yes, branch
		move.b	#0,obFrame(a0)				; set frame to 0 (standard, long ears)
		bsr.w	ObjFloorDist				; get object distance to floor
		tst.w	d1					; is object above floor?
		bpl.s	.chkwall				; if yes, branch
		move.w	(a1),d0					; get floor block object is standing on
		andi.w	#$3FF,d0				; ignore solid/orientation bits (i.e. only look at the actual block ID)
		cmpi.w	#$2D2,d0				; is the touched block ID a lava tile? (technically, this should be $2FB, but most of the tiles before are blank/background)
		blo.s	.bounce					; if not, branch
		addq.b	#2,obRoutine(a0)			; set to .fallthroughfloor (makes object fall into lava upon contact)
		bra.s	.chkwall				; skip
; ---------------------------------------------------------------------------
 
.bounce:
		add.w	d1,obY(a0)				; fix to floor (add floor difference to Y pos)
		move.w	#-$400,obVelY(a0)			; bounce up
 
.chkwall:
		bsr.w	ChkHitLeftRightWall			; check if object hit a wall to the left or right
		beq.s	.display				; if not, branch
		neg.w	obVelX(a0)				; invert X movement direction
		bchg	#sprite_xflip_bit,obRender(a0)		; invert sprite flip (render flags)
		bchg	#0,obStatus(a0)				; invert sprite flip (status flags)
 
.display:
		bra.w	RememberState
; ---------------------------------------------------------------------------
 
.fallthroughfloor:
		bsr.w	ObjectFall				; apply gravity
	if FixBugs
		tst.b	obRender(a0)				; is object still on screen?
		bpl.w	DeleteObject				; if not, delete
		bra.w	DisplaySprite				; display
	else
		bsr.w	DisplaySprite
		tst.b	obRender(a0)				; is object still on screen?
		bpl.w	DeleteObject				; if not, delete
		rts
	endif
; ---------------------------------------------------------------------------
 
sub_D2DA:	; this routine is shared with Yadrin
ChkHitLeftRightWall:
		move.w	(v_framecount).w,d0			; get frame counter
		add.w	d7,d0					; add object object enumerator from RAM
		andi.w	#3,d0					; and by 3 (effectively makes it so it's only checked every 4 frames, presumably for performance reasons)
		bne.s	.nowallhit				; if outside a 4th frame, branch
		moveq	#0,d3
		move.b	obActWid(a0),d3				; load object width to d3 (input param for wall col detection subroutines)
		tst.w	obVelX(a0)				; is object moving to the left?
		bmi.s	.chkleftwall				; if yes, branch
		bsr.w	ObjHitWallRight				; get distance to nearest right wall
		tst.w	d1					; did object hit wall?
		bpl.s	.nowallhit				; if not, branch
 
.wallhit:
		moveq	#1,d0					; set Z-flag (wall touched)
		rts
; ---------------------------------------------------------------------------
 
.chkleftwall:
		not.w	d3					; invert object width to make it work for left wall col
		bsr.w	ObjHitWallLeft				; get distance to nearest left wall
		tst.w	d1					; did object hit wall?
		bmi.s	.wallhit				; if yes, branch
 
.nowallhit:
		moveq	#0,d0					; clear Z-flag (wall not touched)
		rts

; ===========================================================================

Map_Splats:	include "_maps/Splats.asm"

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

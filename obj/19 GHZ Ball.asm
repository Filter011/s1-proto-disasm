; ===========================================================================
; ---------------------------------------------------------------------------
; Object 19 - Ball obstacle (GHZ)
; ---------------------------------------------------------------------------

GHZBall:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	GHZBall_Index(pc,d0.w),d1
		jmp	GHZBall_Index(pc,d1.w)
; ===========================================================================
GHZBall_Index:
		dc.w	GHZBall_Main-GHZBall_Index
		dc.w	GHZBall_Roll-GHZBall_Index
		dc.w	GHZBall_InAir-GHZBall_Index
		dc.w	GHZBall_Delete-GHZBall_Index
		dc.w	GHZBall_ChkPush-GHZBall_Index
; ===========================================================================

GHZBall_Main:	; Routine 0
		move.b	#48/2,obHeight(a0)
		move.b	#24/2,obWidth(a0)
		bsr.w	ObjectFall
		jsr	(ObjFloorDist).l
		tst.w	d1
		bpl.s	.floornotfound
		add.w	d1,obY(a0)
		move.w	#0,obVelY(a0)
		move.b	#8,obRoutine(a0)			; advance to GHZ_Ball_ChkPush
		move.l	#Map_GBall,obMap(a0)
		move.w	#ArtTile_GHZ_Giant_Ball|Tile_Pal3,obGfx(a0)
		move.b	#sprite_cam_field,obRender(a0)
		move.b	#3,obPriority(a0)
		move.b	#48/2,obActWid(a0)
		move.b	#1,obDelayAni(a0)
		bsr.w	GHZBall_Animate

.floornotfound:
		rts
; ===========================================================================

GHZBall_ChkPush: ; Routine 8
		move.w	#48/2+sonic_solid_width,d1		; SolidObject input: width
		move.w	#48/2,d2				; SolidObject input: height (initial)
		move.w	#48/2,d3				; SolidObject input: height (stood-on)
		move.w	obX(a0),d4				; SolidObject input: object X-position (stood-on)
		bsr.w	SolidObject
		btst	#5,obStatus(a0)				; is the ball being pushed?
		bne.s	.pushed					; if so, branch
		move.w	(v_player+obX).w,d0			; get player's X position
		sub.w	obX(a0),d0				; subtract object position from player's X position
		blo.s	.notouch				; if lower than total value, branch

.pushed:
		move.b	#2,obRoutine(a0)			; advance to GHZBall_Roll
		move.w	#$80,obInertia(a0)

.notouch:
		bsr.w	GHZBall_Animate
	if FixBugs=0
		bsr.w	DisplaySprite
	endif
		bra.w	GHZBall_ChkDel
; ===========================================================================

GHZBall_Roll:	; Routine 2
		btst	#1,obStatus(a0)				; is the ball in the air?
		bne.w	GHZBall_InAir				; if so, branch
		bsr.w	GHZBall_Animate
		bsr.w	GHZBall_Angle
		bsr.w	SpeedToPos
		move.w	#48/2+sonic_solid_width,d1		; SolidObject input: width
		move.w	#48/2,d2				; SolidObject input: height (initial)
		move.w	#48/2,d3				; SolidObject input: height (stood-on)
		move.w	obX(a0),d4				; SolidObject input: object X-position (stood-on)
		bsr.w	SolidObject
		jsr	(Sonic_AnglePos).l
		cmpi.w	#$20,obX(a0)
		bhs.s	.faster
		move.w	#$20,obX(a0)
		move.w	#$400,obInertia(a0)

.faster:
		btst	#1,obStatus(a0)				; is the ball in the air?
		beq.s	.notinair				; if not, branch
		move.w	#-$400,obVelY(a0)			; set ball to bounce upwards

.notinair:
	if FixBugs=0
		bsr.w	DisplaySprite
	endif
		bra.w	GHZBall_ChkDel
; ===========================================================================

GHZBall_InAir:	; Routine 4
		bsr.w	GHZBall_Animate
		bsr.w	SpeedToPos
		move.w	#48/2+sonic_solid_width,d1		; SolidObject input: width
		move.w	#48/2,d2				; SolidObject input: height (initial)
		move.w	#48/2,d3				; SolidObject input: height (stood-on)
		move.w	obX(a0),d4				; SolidObject input: object X-position (stood-on)
		bsr.w	SolidObject
		jsr	(Sonic_Floor).l
		btst	#1,obStatus(a0)				; is the ball in the air?
		beq.s	.notinair				; if not, branch
		move.w	obVelY(a0),d0
		addi.w	#$28,d0
		move.w	d0,obVelY(a0)
		bra.s	.display
; ===========================================================================

.notinair:
		nop						; unknown removed code

.display:
	if FixBugs=0
		bsr.w	DisplaySprite
	endif
		bra.w	GHZBall_ChkDel
; ===========================================================================

GHZBall_Animate:
		tst.b	obFrame(a0)
		beq.s	.evenframes
		move.b	#0,obFrame(a0)				; every odd frame, set to frame 0
		rts
; ===========================================================================

.evenframes:
		move.b	obInertia(a0),d0			; get byte of inertia
		beq.s	loc_5E02				; if zero, branch
		bmi.s	loc_5E0A				; if negative, branch
		subq.b	#1,obTimeFrame(a0)
		bpl.s	loc_5E02
		neg.b	d0
		addq.b	#8,d0
		blo.s	loc_5DEC
		moveq	#0,d0

loc_5DEC:
		move.b	d0,obTimeFrame(a0)
		move.b	obDelayAni(a0),d0
		addq.b	#1,d0
		cmpi.b	#4,d0
		bne.s	loc_5DFE
		moveq	#1,d0

loc_5DFE:
		move.b	d0,obDelayAni(a0)

loc_5E02:
		move.b	obDelayAni(a0),obFrame(a0)
		rts
; ===========================================================================

loc_5E0A:
		subq.b	#1,obTimeFrame(a0)
		bpl.s	loc_5E02
		addq.b	#8,d0
		blo.s	loc_5E16
		moveq	#0,d0

loc_5E16:
		move.b	d0,obTimeFrame(a0)
		move.b	obDelayAni(a0),d0
		subq.b	#1,d0
		bne.s	loc_5E24
		moveq	#3,d0

loc_5E24:
		move.b	d0,obDelayAni(a0)
		bra.s	loc_5E02
; ===========================================================================

GHZBall_ChkDel:
		out_of_range.w	DeleteObject
	if FixBugs
		bra.w	DisplaySprite
	else
		rts
	endif
; ===========================================================================

GHZBall_Delete:	; Routine 6
		bsr.w	DeleteObject
		rts
; ===========================================================================

GHZBall_Angle:
		move.b	obAngle(a0),d0
		bsr.w	CalcSine
		move.w	d0,d2
		muls.w	#56,d2
		asr.l	#8,d2
		add.w	d2,obInertia(a0)
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
		rts
; ===========================================================================

Map_GBall:	include "_maps/GHZ Ball.asm"
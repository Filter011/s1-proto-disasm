; ===========================================================================
; ---------------------------------------------------------------------------
; Object 28 - Animals from destroyed badniks and prison capsules
; ---------------------------------------------------------------------------

Animals:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Anml_Index(pc,d0.w),d1
		jmp	Anml_Index(pc,d1.w)
; ===========================================================================
Anml_Index:
		dc.w	Anml_Main-Anml_Index		; 0  - init
		dc.w	Anml_ChkFloor-Anml_Index	; 2  - wait for first floor hit after initial spawn

		; --- Animals spawned from broken badniks and post-boss prison capsules ---
		dc.w	Anml_NormalGravity-Anml_Index	; 4  - type 0: Pocky/bunny (GHZ/CWZ)
		dc.w	Anml_SlowGravity-Anml_Index	; 6  - type 1: Cucky/chicken (GHZ/SZ)
		dc.w	Anml_NormalGravity-Anml_Index	; 8  - type 2: Pecky/penguin (LZ)
		dc.w	Anml_NormalGravity-Anml_Index	; A  - type 3: Ricky/squirrel (SLZ)
		dc.w	Anml_NormalGravity-Anml_Index	; C  - type 4: Picky/pig (MZ/SZ)
		dc.w	Anml_SlowGravity-Anml_Index	; E  - type 5: Flicky/bird (MZ/CWZ)
		dc.w	Anml_NormalGravity-Anml_Index	; 10 - type 6: Rocky/seal (LZ/SLZ)

animal_id:		equ objoff_30	; animal ID from Anml_VarIndex
animal_speedX:		equ objoff_32	; base animal X-speed
animal_speedY:		equ objoff_34	; base animal Y-speed
; ===========================================================================

; Configuration values for animals per zone, and their speeds.

Anml_VarIndex:	; two animal IDs per zone, must be "even/odd"
		dc.b 0,	1		; Green Hill Zone
		dc.b 2, 3		; Labyrinth Zone
		dc.b 4, 5		; Marble Zone
		dc.b 6, 3		; Star Light Zone
		dc.b 4, 1		; Sparkling Zone
		dc.b 0, 5		; Clock Work Zone

Anml_Variables:	; horizontal speed, vertical speed, mappings
		dc.w -$200, -$400	; type 0: Pocky/bunny (GHZ/CWZ)
		dc.l Map_Animal1
		dc.w -$200, -$300	; type 1: Cucky/chicken (GHZ/SZ)
		dc.l Map_Animal2
		dc.w -$140, -$200	; type 2: Pecky/penguin (LZ)
		dc.l Map_Animal1
		dc.w -$100, -$180	; type 3: Ricky/squirrel (SLZ)
		dc.l Map_Animal2
		dc.w -$180, -$300	; type 4: Picky/pig (MZ/SZ)
		dc.l Map_Animal3
		dc.w -$300, -$400	; type 5: Flicky/bird (MZ/CWZ)
		dc.l Map_Animal2
		dc.w -$280, -$380	; type 6: Rocky/seal (LZ/SLZ)
		dc.l Map_Animal3
; ===========================================================================

Anml_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; advance to Anml_ChkFloor

		bsr.w	RandomNumber				; get random number to select animal to spawn
		andi.w	#1,d0					; limit to two choices
		moveq	#0,d1
		move.b	(v_zone).w,d1				; get current zone ID
		add.w	d1,d1					; double for word-based addressing
		add.w	d0,d1					; add random result
		move.b	Anml_VarIndex(pc,d1.w),d0		; get animal ID for zone (animal 0 or 1)
		move.b	d0,animal_id(a0)			; remember animal ID
		lsl.w	#3,d0					; multiply by 8 bytes per Anml_Variables entry
		lea	Anml_Variables(pc,d0.w),a1		; load animal variables array and advance to data for current animal
		move.w	(a1)+,animal_speedX(a0)			; load horizontal speed
		move.w	(a1)+,animal_speedY(a0)			; load vertical speed
		move.l	(a1)+,obMap(a0)				; load mappings
		move.w	#ArtTile_Animal_1,obGfx(a0)		; VRAM setting for animal 0
		btst	#0,animal_id(a0)			; is 0th animal used? (even number)
		beq.s	.setupAnimal				; if yes, branch
		move.w	#ArtTile_Animal_2,obGfx(a0)		; VRAM setting for animal 1

	.setupAnimal:
		move.b	#24/2,obHeight(a0)			; set height
		move.b	#sprite_cam_field,obRender(a0)		; set to playfield-positioned mode
		bset	#sprite_xflip_bit,obRender(a0)		; set X-flip flag
		move.b	#6,obPriority(a0)			; set sprite priority (very low)
		move.b	#16/2,obActWid(a0)			; set sprite display width
		move.b	#8-1,obTimeFrame(a0)			; initial animation delay for flying animals (slow gravity)
		move.b	#2,obFrame(a0)				; set initial frame to ".flap2"
		move.w	#-$400,obVelY(a0)			; launch animal upwards initially

		tst.b	(v_bossstatus).w			; is this animal from a prison capsule?
		bne.s	Anml_ChkFloor.fromPrison		; if yes, don't load points object
		bsr.w	FindFreeObj				; find a free object slot
		bne.s	.display				; if object RAM is full, branch
		_move.b	#id_Points,obID(a1)			; load points object
		move.w	obX(a0),obX(a1)				; copy X-position
		move.w	obY(a0),obY(a1)				; copy Y-position

	.display:
		bra.w	DisplaySprite				; display animal
; ===========================================================================

Anml_ChkFloor:	; Routine 2
		tst.b	obRender(a0)				; has animal gone offscreen?
		bpl.w	DeleteObject				; if yes, delete it

		bsr.w	ObjectFall				; make animal fall and update position
		tst.w	obVelY(a0)				; is animal still going upwards?
		bmi.s	.display				; if yes, skip ground collision check

		jsr	(ObjFloorDist).l			; get distance to floor
		tst.w	d1					; has animal hit the floor?
		bpl.s	.display				; if not, branch
		add.w	d1,obY(a0)				; align animal to floor

.fromPrison:
		move.w	animal_speedX(a0),obVelX(a0)		; reset to base X-speed
		move.w	animal_speedY(a0),obVelY(a0)		; reset to base Y-speed
		move.b	#1,obFrame(a0)				; set initial frame to ".flap1"

		move.b	animal_id(a0),d0			; get animal ID
		add.b	d0,d0					; double for word-based routine numbers
		addq.b	#4,d0					; skip over Anml_Main and Anml_ChkFloor routines
		move.b	d0,obRoutine(a0)			; advance to routine for this animal (Anml_NormalGravity or Anml_SlowGravity)

		tst.b	(v_bossstatus).w			; is this animal from a prison capsule?
		beq.s	.display				; if not, branch
		btst	#4,(v_vblank_byte).w			; reverse prison escape direction every 16-32 frames in a 32 frame window
		beq.s	.display				; branch on other frames
		neg.w	obVelX(a0)				; invert X-direction (hop left and right on floor)
		bchg	#sprite_xflip_bit,obRender(a0)		; flip X-orientation

	.display:
		bra.w	DisplaySprite				; display animal

; ===========================================================================
; ---------------------------------------------------------------------------
; Type 0 animals: normal gravity, animate on floor hit
; ---------------------------------------------------------------------------

Anml_NormalGravity: ; Routine 4/8/A/C/10
		bsr.w	ObjectFall				; make animal fall and update position
		move.b	#1,obFrame(a0)				; use frame 1 while going up
		tst.w	obVelY(a0)				; is animal going down?
		bmi.s	.chkDel					; if not, branch
		move.b	#0,obFrame(a0)				; use frame 0 while going down

		jsr	(ObjFloorDist).l			; get distance to floor
		tst.w	d1					; has animal hit the floor?
		bpl.s	.chkDel					; if not, branch
		add.w	d1,obY(a0)				; align animal to floor
		move.w	animal_speedY(a0),obVelY(a0)		; make animal bounce upwards again

	.chkDel:
		tst.b	obRender(a0)				; has animal gone offscreen?
		bpl.w	DeleteObject				; if yes, delete it
		bra.w	DisplaySprite				; otherwise, display it


; ===========================================================================
; ---------------------------------------------------------------------------
; Type 1 animals: reduced gravity, animate every other frame
; ---------------------------------------------------------------------------

Anml_SlowGravity: ; Routine 6/E
		bsr.w	SpeedToPos				; update animal position
		addi.w	#$18,obVelY(a0)				; make animal fall (slowly)
		tst.w	obVelY(a0)				; is animal going down?
		bmi.s	.animate				; if not, branch

		jsr	(ObjFloorDist).l			; get distance to floor
		tst.w	d1					; has animal hit the floor?
		bpl.s	.animate				; if not, branch
		add.w	d1,obY(a0)				; align animal to floor
		move.w	animal_speedY(a0),obVelY(a0)		; make animal bounce upwards again

	.animate:
		subq.b	#1,obTimeFrame(a0)			; decrement animation delay
		bpl.s	.chkDel					; if time remains, branch
		move.b	#2-1,obTimeFrame(a0)			; change sprite every two frames
		addq.b	#1,obFrame(a0)				; go to next sprite
		andi.b	#1,obFrame(a0)				; alternate between sprite 0 and 1

	.chkDel:
		tst.b	obRender(a0)				; has animal gone offscreen?
		bpl.w	DeleteObject				; if yes, delete it
		bra.w	DisplaySprite				; otherwise, display it


; ===========================================================================
; ---------------------------------------------------------------------------
; Object 29 - points that appear from destroyed badniks and other places
; ---------------------------------------------------------------------------

Points:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Poi_Index(pc,d0.w),d1
	if FixBugs
		; Objects shouldn't call DisplaySprite and DeleteObject on
		; the same frame or else cause a null-pointer dereference.
		jmp	Poi_Index(pc,d1.w)
	else
		jsr	Poi_Index(pc,d1.w)
		bra.w	DisplaySprite
	endif
; ===========================================================================
Poi_Index:
		dc.w	Poi_Main-Poi_Index
		dc.w	Poi_Slower-Poi_Index
; ===========================================================================

Poi_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; advance to Poi_Slower
		move.l	#Map_Points,obMap(a0)			; set mappings
		move.w	#ArtTile_Points|Tile_Pal2,obGfx(a0)	; set art tile and palette
		move.b	#sprite_cam_field,obRender(a0)		; set to playfield-positioned mode
		move.b	#1,obPriority(a0)			; set sprite priority (above Sonic)
		move.b	#16/2,obActWid(a0)			; set display width
		move.w	#-$300,obVelY(a0)			; move points object upwards
; ---------------------------------------------------------------------------

Poi_Slower:	; Routine 2
		tst.w	obVelY(a0)				; has point object stopped moving up?
		bpl.w	DeleteObject				; if yes, delete it
		bsr.w	SpeedToPos				; update position based on velocity
		addi.w	#$18,obVelY(a0)				; reduce upward speed
	if FixBugs
		bra.w	DisplaySprite				; display points object
	else
		rts						; return to top Points routine for display
	endif

; ===========================================================================

Map_Animal1:	include	"_maps/Animals 1.asm"
Map_Animal2:	include	"_maps/Animals 2.asm"
Map_Animal3:	include	"_maps/Animals 3.asm"
Map_Points:	include	"_maps/Points.asm"

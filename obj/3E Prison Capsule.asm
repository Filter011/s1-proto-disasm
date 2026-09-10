; ===========================================================================
; ---------------------------------------------------------------------------
; Object 3E - Prison capsule after boss fights
; ---------------------------------------------------------------------------

Prison:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Pri_Index(pc,d0.w),d1
		jsr	Pri_Index(pc,d1.w)
	if FixBugs
		; Objects shouldn't call DisplaySprite and DeleteObject on
		; the same frame, or else cause a null-pointer dereference.
		out_of_range.w	DeleteObject			; is capsule offscreen? if yes, delete capsule
		bra.w	DisplaySprite
	else
		bsr.w	DisplaySprite
		out_of_range.w	DeleteObject			; is capsule offscreen? if yes, delete capsule
		rts
	endif
; ===========================================================================
Pri_Index:
		dc.w	Pri_Main-Pri_Index			; 0
		dc.w	Pri_BodyMain-Pri_Index			; 2
		dc.w	Pri_Switch-Pri_Index			; 4
		dc.w	Pri_Explosion-Pri_Index			; 6
		dc.w	Pri_Explosion-Pri_Index			; 8
		dc.w	Pri_Explosion-Pri_Index			; A
		dc.w	Pri_Animals-Pri_Index			; C
		dc.w	Pri_EndAct-Pri_Index			; E
		; Only the third Pri_Explosion is used in-game. The first two are
		; leftover pointers for deleted subtypes of the object, which the
		; S2NA symbol tables call masincenter and masincenter2.

pri_origY:	equ objoff_30		; original y-axis position
; ===========================================================================

Pri_Var:	; routine, width, priority, frame
		dc.b 2,	64/2, 4, 0	; subtype 0 - capsule
		dc.b 4,	24/2, 5, 1	; subtype 1 - switch
		dc.b 6,	32/2, 4, 3	; subtype 2 - (unused/deleted)
		dc.b 8,	32/2, 3, 5	; subtype 3 - (unused/deleted)
; ===========================================================================

Pri_Main:	; Routine 0
		move.l	#Map_Pri,obMap(a0)			; set mappings
		move.w	#ArtTile_Prison_Capsule,obGfx(a0)	; set art tile
		move.b	#sprite_cam_field,obRender(a0)		; set to playfield-positioned mode
		move.w	obY(a0),pri_origY(a0)			; remember initial Y-position

		moveq	#0,d0
		move.b	obSubtype(a0),d0			; get prison subtype
		lsl.w	#2,d0					; multiply by 4 bytes per entry
		lea	Pri_Var(pc,d0.w),a1			; get values for subtype
		move.b	(a1)+,obRoutine(a0)			; set routine number
		move.b	(a1)+,obActWid(a0)			; set sprite display width
		move.b	(a1)+,obPriority(a0)			; set sprite priority
		move.b	(a1)+,obFrame(a0)			; set frame ID

		; Another unused leftover from the deleted subtypes.
		cmpi.w	#2*4,d0					; is this object subtype 2? (unused)
		bne.s	.return					; if not, branch
		move.b	#col_32x32|col_boss,obColType(a0)	; set special collision type
		move.b	#8,obBossHits(a0)			; were capsules once supposed to behave like bosses?

	.return:
		rts
; ===========================================================================

Pri_BodyMain:	; Routine 2
		cmpi.b	#2,(v_bossstatus).w			; has the prison been opened from switch?
		beq.s	.openCapsule				; if yes, branch

		move.w	#64/2+sonic_solid_width,d1		; solid width
		move.w	#48/2,d2				; solid height (initial)
		move.w	#48/2,d3				; solid height (stood on)
		move.w	obX(a0),d4				; X-position (stood on)
		bra.w	SolidObject				; make capsule solid
; ---------------------------------------------------------------------------

.openCapsule:
		tst.b	obSolid(a0)				; was Sonic standing on the capsule as it opened
		beq.s	.showOpened				; if not, branch
		clr.b	obSolid(a0)				; clear capsule's collision flag
		bclr	#3,(v_player+obStatus).w		; clear Sonic's on-platform flag
		bset	#1,(v_player+obStatus).w		; set Sonic to be in air

	.showOpened:
		move.b	#2,obFrame(a0)				; use frame number 2 (destroyed prison)
		rts
; ===========================================================================

; Pri_Switched:
Pri_Switch:	; Routine 4
		move.w	#24/2+sonic_solid_width,d1		; solid width
		move.w	#16/2,d2				; solid height (initial)
		move.w	#16/2,d3				; solid height (stood on)
		move.w	obX(a0),d4				; X-position (stood on)
		bsr.w	SolidObject				; make switch solid and set obSolid if Sonic stands on it
		lea	(Ani_Pri).l,a1				; load animation script
		bsr.w	AnimateSprite				; animate switch
		move.w	pri_origY(a0),obY(a0)			; force Y-position to stay at initial

		tst.b	obSolid(a0)				; is Sonic standing on the switch?
		beq.s	.return					; if not, branch
		addq.w	#8,obY(a0)				; move switch down 8px
		move.b	#$A,obRoutine(a0)			; advance to Pri_Explosion
		move.w	#1*60,obTimeFrame(a0)			; set time between animal spawns
		clr.b	(f_timecount).w				; stop time counter
		clr.b	obSolid(a0)				; clear capsule's collision flag
		bclr	#3,(v_player+obStatus).w		; clear Sonic's on-platform flag
		bset	#1,(v_player+obStatus).w		; set Sonic to be in air

	.return:
		rts
; ===========================================================================

Pri_Explosion:	; Routine $A (also routine 6/8, but those are unused)
		move.b	(v_vblank_byte).w,d0			; get V-Blank counter
		andi.b	#7,d0 					; limits spawning explosions to every 8 frames
		bne.s	.chkSpawnAnimals 			; if on other frame, branch

		bsr.w	FindFreeObj				; find a free object slot
		bne.s	.chkSpawnAnimals			; if object RAM is full, branch
		_move.b	#id_Explosion,obID(a1)			; load an explosion object
		move.w	obX(a0),obX(a1)				; use prison X-position for explosion base
		move.w	obY(a0),obY(a1)				; use prison Y-position for explosion base
		jsr	(RandomNumber).l			; get a random number in d0/d1
		move.w	d0,d1 					; copy random number to d1
		moveq	#0,d1 					; ditch the first byte
		move.b	d0,d1					; get lower byte from random result
		lsr.b	#2,d1					; divide by 4
		subi.w	#32,d1					; pull 32px to the left
		add.w	d1,obX(a1)				; randomly adjust explosion X-position
		lsr.w	#8,d0					; put upper byte of random result into lower byte
		lsr.b	#3,d0					; divide by 8
		add.w	d0,obY(a1)				; randomly adjust explosion Y-position

	.chkSpawnAnimals:
		subq.w	#1,obTimeFrame(a0)			; decrement explosion timer
		bne.s	.return					; if time hasn't expired, branch
		move.b	#2,(v_bossstatus).w			; set prison as being opened
		move.b	#$C,obRoutine(a0)			; advance to Pri_Animals (replace explosions with animals)
		move.b	#9,obFrame(a0)				; 'delete' switch by turning it invisible
		move.w	#3*60,obTimeFrame(a0)			; set time delay to 3 seconds
		addi.w	#32,obY(a0)				; load all animals 32px below explosions

	.return:
		rts
; ===========================================================================

Pri_Animals:	; Routine $C
		move.b	(v_vblank_byte).w,d0			; get V-Blank counter
		andi.b	#7,d0 					; limits spawning explosions to every 8 frames
		bne.s	.chkDelay 				; if on other frame, branch

		; These animals hop out almost as soon as they are spawned in.
		bsr.w	FindFreeObj				; find a free object slot
		bne.s	.chkDelay				; if object RAM is full, branch
		_move.b	#id_Animals,obID(a1)			; load an animal object
		move.w	obX(a0),obX(a1)				; spawn at current X-position
		move.w	obY(a0),obY(a1)				; spawn at current Y-position

	.chkDelay:
		subq.w	#1,obTimeFrame(a0)			; decrement timer until checking if animals have gone offscreen
		bne.s	.return					; if time remains, branch (probably to avoid lag frames)
		addq.b	#2,obRoutine(a0)			; advance to Pri_EndAct
		move.w	#1*60,obTimeFrame(a0)			; set time delay to 1 second

	.return:
		rts
; ===========================================================================

Pri_EndAct:	; Routine $E
		subq.w	#1,obTimeFrame(a0)			; decrement timer until checking if animals have gone offscreen
		bne.s	.return					; if time remains, branch
		bsr.w	GotThroughAct				; all animal objects have been deleted, launch end-of-level title cards (object 3A)
	if FixBugs
		; Avoid returning to Prison to prevent display-and-delete
		; and double-delete bugs.
		addq.l	#4,sp					; don't return to Prison to avoid DisplaySprite
	endif
		bra.w	DeleteObject				; delete prison switch object

	.return:
		rts
; ===========================================================================

		include "_anim/Prison Capsule.asm"
Map_Pri:	include "_maps/Prison Capsule.asm"
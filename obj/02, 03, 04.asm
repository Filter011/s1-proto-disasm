; ===========================================================================
; ---------------------------------------------------------------------------
; Object 02 - Animated object positioned towards the right of the screen
; ---------------------------------------------------------------------------

Obj02:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj02_Index(pc,d0.w),d1
		jmp	Obj02_Index(pc,d1.w)
; ===========================================================================
Obj02_Index:
		dc.w	Obj02_Main-Obj02_Index			; 0
		dc.w	Obj02_Display-Obj02_Index		; 2
		dc.w	Obj02_Delete-Obj02_Index		; 4 (unused)
		dc.w	Obj02_Delete-Obj02_Index		; 6 (unused)
; ===========================================================================

Obj02_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; advance to Obj02_Display
		move.w	#$200,obX(a0)				; set X-position
		move.w	#$60,obY(a0)				; set Y-position
		move.l	#Map_02,obMap(a0)			; set mappings
		move.w	#ArtTile_Debug_Numbers|Tile_Pal4,obGfx(a0) ; set art tile and palette line
		move.b	#sprite_cam_field,obRender(a0)		; set to playfield positioning mode
		move.b	#col_40x40,obColProp(a0)		; set col type
		move.b	#3,obPriority(a0)			; set sprite priority

Obj02_Display:	; Routine 2
		bsr.w	DisplaySprite
		subq.b	#1,obTimeFrame(a0)			; decrement delay timer
		bpl.s	.wait					; branch if positive
		move.b	#16,obTimeFrame(a0)			; set delay to 16 frames
		move.b	obFrame(a0),d0				; set frame to d0
		addq.b	#1,d0					; increment frame
		cmpi.b	#2,d0					; is frame number 2?
		blo.s	.dontrevert				; if lower than 2, branch
		moveq	#0,d0					; reset frame number to 0

.dontrevert:
		move.b	d0,obFrame(a0)				; set the frame to use

.wait:
		rts
; ===========================================================================

Obj02_Delete:	; Routine 4, 6 (unused)
		bsr.w	DeleteObject
		rts

; ===========================================================================

Map_02:		include "_maps/02.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 03 - Non-animated object positioned at the left of the screen
; ---------------------------------------------------------------------------

Obj03:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj03_Index(pc,d0.w),d1
		jmp	Obj03_Index(pc,d1.w)
; ===========================================================================
Obj03_Index:
		dc.w	Obj03_Main-Obj03_Index			; 0
		dc.w	Obj03_Display-Obj03_Index		; 2
		dc.w	Obj03_Delete-Obj03_Index		; 4 (unused)
		dc.w	Obj03_Delete-Obj03_Index		; 6 (unused)
; ===========================================================================

Obj03_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; advance to Obj03_Display
		move.w	#$100,obX(a0)				; set X-position
		move.w	#$40,obY(a0)				; set Y-position
		move.l	#Map_02,obMap(a0)			; set mappings
		move.w	#ArtTile_Debug_Numbers|Tile_Pal4,obGfx(a0) ; set art tile and palette line
		move.b	#sprite_cam_field,obRender(a0)		; set to playfield positioning mode
		move.b	#col_40x40,obColProp(a0)		; set col type
		move.b	#3,obFrame(a0)				; set initial frame
		move.b	#5,obPriority(a0)			; set sprite priority

Obj03_Display:	; Routine 2
		bsr.w	DisplaySprite
		subq.b	#1,obTimeFrame(a0)			; decrement delay timer
		bpl.s	.dontset				; branch if positive
		move.b	#16,obTimeFrame(a0)			; set delay to 16 frames

.dontset:
		rts
; ===========================================================================

Obj03_Delete:	; Routine 4, 6 (unused)
		bsr.w	DeleteObject
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 04 - Animated object with a fixed Y position
; ---------------------------------------------------------------------------

Obj04:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj04_Index(pc,d0.w),d1
		jmp	Obj04_Index(pc,d1.w)
; ===========================================================================
Obj04_Index:
		dc.w	Obj04_Main-Obj04_Index			; 0
		dc.w	Obj04_Display-Obj04_Index		; 2
		dc.w	Obj04_Delete-Obj04_Index		; 4 (unused)
		dc.w	Obj04_Delete-Obj04_Index		; 6 (unused)
; ===========================================================================

Obj04_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; advance to Obj04_Display
		move.w	#$40,obY(a0)				; set Y-position
		move.l	#Map_02,obMap(a0)			; set mappings
		move.w	#ArtTile_Monitor|Tile_Pal2,obGfx(a0)	; set art tile and palette line
		move.b	#sprite_cam_field,obRender(a0)		; set to playfield positioning mode
		move.b	#col_40x40,obColProp(a0)		; set col type
		move.b	#2,obFrame(a0)				; set initial frame
		move.b	#3,obPriority(a0)			; set sprite priority

Obj04_Display:	; Routine 2
		bsr.w	DisplaySprite
		subq.b	#1,obTimeFrame(a0)			; decrement delay timer
		bpl.s	locret_4D26				; branch if positive
		move.b	#20,obTimeFrame(a0)			; set delay to 20 frames
		move.b	obFrame(a0),d0				; set frame to d0
		addq.b	#1,d0					; increment frame
		cmpi.b	#4,d0					; is frame number 4?
		blo.s	loc_4D22				; if lower than 4, branch
		moveq	#2,d0					; reset frame number to 2

loc_4D22:
		move.b	d0,obFrame(a0)				; set the frame to use

locret_4D26:
		rts
; ===========================================================================

Obj04_Delete:	; Routine 4, 6 (unused)
		bsr.w	DeleteObject
		rts
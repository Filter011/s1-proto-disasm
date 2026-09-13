; ===========================================================================
; ---------------------------------------------------------------------------
; Object 21 - SCORE, TIME, RING
; ---------------------------------------------------------------------------

HUD:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	HUD_Index(pc,d0.w),d1
		jmp	HUD_Index(pc,d1.w)
; ===========================================================================
HUD_Index:
		dc.w	HUD_Main-HUD_Index
		dc.w	HUD_Display-HUD_Index
; ===========================================================================

HUD_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; advance to HUD_Flash
		move.w	#$80+$10,obX(a0)			; set screen X-position
		move.w	#$80+$88,obScreenY(a0)			; set screen Y-position
		move.l	#Map_HUD,obMap(a0)			; set mappings
		move.w	#ArtTile_HUD,obGfx(a0)			; set art tile (mappings themselves are high-prio)
		move.b	#sprite_cam_screen,obRender(a0)		; set to screen-positioned mode
		move.b	#0,obPriority(a0)			; set to maximum sprite priority
; ---------------------------------------------------------------------------

HUD_Display:	; Routine 2
		jmp	(DisplaySprite).l
; ===========================================================================

Map_HUD:	include "_maps/HUD.asm"
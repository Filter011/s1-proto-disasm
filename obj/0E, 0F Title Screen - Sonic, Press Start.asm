; ===========================================================================
; ---------------------------------------------------------------------------
; Object 0E - Sonic on the title screen
; ---------------------------------------------------------------------------

TitleSonic:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	TSon_Index(pc,d0.w),d1
		jmp	TSon_Index(pc,d1.w)
; ===========================================================================
TSon_Index:
		dc.w	TSon_Main-TSon_Index
		dc.w	TSon_Delay-TSon_Index
		dc.w	TSon_Move-TSon_Index
		dc.w	TSon_Animate-TSon_Index
; ===========================================================================

TSon_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; advance to TSon_Delay
	if FixBugs
		; Fix horizontal title screen position
		move.w	#$80+$78,obX(a0)			; +8px
	else
		move.w	#$80+$70,obX(a0)			; original X-position
	endif
		move.w	#$80+$5E,obScreenY(a0)			; set initial Y-position
		move.l	#Map_TSon,obMap(a0)			; set mappings
		move.w	#ArtTile_Title_Sonic|Tile_Pal2,obGfx(a0) ; set art tile and palette line
		move.b	#1,obPriority(a0)			; set sprite priority
		move.b	#30-1,obDelayAni(a0)			; set time delay before Sonic moves in to 0.5 seconds
		lea	(Ani_TSon).l,a1				; load animation script
		bsr.w	AnimateSprite				; advance animation once
; ---------------------------------------------------------------------------

TSon_Delay:	; Routine 2
		subq.b	#1,obDelayAni(a0)			; decrement animation delay
		bpl.s	.wait					; if time remains, branch
		addq.b	#2,obRoutine(a0)			; advance to TSon_Move
		bra.w	DisplaySprite				; start displaying Sonic's sprite
	.wait:
		rts
; ===========================================================================

TSon_Move:	; Routine 4
		subq.w	#8,obScreenY(a0)			; move Sonic up
		cmpi.w	#$80+$16,obScreenY(a0)			; has Sonic reached final Y-position?
		bne.s	.display				; if not, branch
		addq.b	#2,obRoutine(a0)			; advance to TSon_Animate
	.display:
		bra.w	DisplaySprite				; display Sonic sprite
		rts						; redundant rts
; ===========================================================================

TSon_Animate:	; Routine 6
		lea	(Ani_TSon).l,a1				; load animation script
		bsr.w	AnimateSprite				; advance animation (will loop on the last two finger-wagging frames)
		bra.w	DisplaySprite				; display Sonic sprite
		rts						; redundant rts


; ===========================================================================
; ---------------------------------------------------------------------------
; Object 0F - "PRESS START BUTTON" and masking sprites on title screen
; ---------------------------------------------------------------------------

PSB:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	PSB_Index(pc,d0.w),d1
		jsr	PSB_Index(pc,d1.w)
		bra.w	DisplaySprite
; ===========================================================================
PSB_Index:
		dc.w	PSB_Main-PSB_Index
		dc.w	PSB_PrsStart-PSB_Index
		dc.w	PSB_Exit-PSB_Index
; ===========================================================================

PSB_Main:	; Routine 0

		; This code handles three different variations of title screen objects,
		; all depending on what the frame ID was when the object was loaded

		addq.b	#2,obRoutine(a0)			; advance to PSB_PrsStart (animate)
	if FixBugs
		; Fix horizontal title screen position
		move.w	#$80+$58,obX(a0)			; +8px
	else
		move.w	#$80+$50,obX(a0)			; original X-position
	endif
		move.w	#$80+$B0,obScreenY(a0)			; set Y-position
		move.l	#Map_PSB,obMap(a0)			; set mappings
		move.w	#ArtTile_Title_Foreground,obGfx(a0)	; set art tile (PSB tiles are inside the foreground emblem's graphics)

		cmpi.b	#2,obFrame(a0)				; is object masking sprites?
		bne.s	PSB_PrsStart				; if not, branch (object is "PRESS START")

		addq.b	#2,obRoutine(a0)			; advance to PSB_Exit (static)
; ---------------------------------------------------------------------------

PSB_Exit:	; Routine 4
		rts						; return to display sprite
; ===========================================================================

PSB_PrsStart:	; Routine 2
		lea	(Ani_PSB).l,a1				; "PRESS START" is animated
		bra.w	AnimateSprite				; flash PSB object

; ===========================================================================

		include	"_anim/Title Screen Sonic.asm"
		include	"_anim/Press Start.asm"

		include	"obj/sub AnimateSprite.asm"	; mixed in here, this was probably the first use of it

Map_PSB:	include	"_maps/Press Start.asm"
Map_TSon:	include	"_maps/Title Screen Sonic.asm"

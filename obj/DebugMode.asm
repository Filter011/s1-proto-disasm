; ===========================================================================
; ---------------------------------------------------------------------------
; When Debug Mode is currently in use (entered from Sonic objects)
; ---------------------------------------------------------------------------
debug_movedelay:  equ 12	; frames to wait when holding down D-Pad before starting to move
debug_startspeed: equ 15	; initial movement speed when first holding D-Pad
; ---------------------------------------------------------------------------

DebugMode:
		moveq	#0,d0
		move.b	(v_debuguse).w,d0			; get debug mode state (0 if just launched, 2 if already active)
		move.w	Debug_Index(pc,d0.w),d1			; find relevant section in offset table
		jmp	Debug_Index(pc,d1.w)			; jump to that label
; ===========================================================================
Debug_Index:
		dc.w	Debug_Init-Debug_Index			; 0 - init
		dc.w	Debug_Action-Debug_Index		; 2 - main mode
; ===========================================================================

; Debug_Main:
Debug_Init:	; Routine 0
		addq.b	#2,(v_debuguse).w			; set to Debug_Action

		move.b	#fr_Null,obFrame(a0)			; set Sonic's frame to null (blank)
		move.b	#id_Walk,obAnim(a0)			; set Sonic's animation to walk (0)

		moveq	#0,d0
		move.b	(v_zone).w,d0				; get current Zone ID
		lea	(DebugList).l,a2			; load debug item index list
		add.w	d0,d0					; double for word-based indexing
		adda.w	(a2,d0.w),a2				; go to debug item list for Zone ID
		move.w	(a2)+,d6				; load number of entries in debug item list
		cmp.b	(v_debugitem).w,d6			; is currently selected item index past end of list?
		bhi.s	.finishDebugSetup			; if not, branch
		move.b	#0,(v_debugitem).w			; go back to start of list

	.finishDebugSetup:
		bsr.w	Debug_ShowItem				; load selected item graphics when entering debug mode
		move.b	#debug_movedelay,(v_debugspeedtimer).w
	if FixBugs
		; If the D-Pad is held while entering debug mode, the initial move speed
		; is incredibly slow. The cause is this value getting set to just a 1,
		; instead of the normal 15 when no D-Pad button is pressed in Debug_Control.
		move.b	#debug_startspeed,(v_debugspeed).w	; set initial move speed (normal)
	else
		move.b	#1,(v_debugspeed).w			; set initial move speed (just 1)
	endif
; ---------------------------------------------------------------------------

Debug_Action:	; Routine 2
		moveq	#0,d0
		move.b	(v_zone).w,d0				; use Zone ID to select debug list
		lea	(DebugList).l,a2			; load debug item index list
		add.w	d0,d0					; double for word-based indexing
		adda.w	(a2,d0.w),a2				; go to debug item list for Zone ID
		move.w	(a2)+,d6				; load number of entries in debug item list

		bsr.w	Debug_Control				; allow movement and object spawning, and update graphics
		jmp	(DisplaySprite).l			; display debug object
; End of function DebugMode


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to allow movement in debug mode, spawning objects,
; and updating displayed debug object sprite graphics.
; ---------------------------------------------------------------------------

Debug_Control:
		moveq	#0,d4					; clear d4 for button input buffer
		move.w	#1,d1					; set d1 to 1 (useless, cleared again below)

		move.b	(v_jpadpress1).w,d4			; get buttons that were pressed this frame
		bne.s	Debug_Move_GetDirections		; if any button was pressed, branch (immediately move a bit)

		tst.b	(v_jpadhold1).w				; get buttons that were already held down
		bne.s	Debug_Move_Delay			; if any button was held down, branch

		; No D-Pad buttons were pressed...
		move.b	#debug_movedelay,(v_debugspeedtimer).w	; reset movement delay
		move.b	#debug_startspeed,(v_debugspeed).w	; reset initial move speed
		rts

; ---------------------------------------------------------------------------
; Allow freely moving around in debug mode
; ---------------------------------------------------------------------------

Debug_Move_Delay:
		subq.b	#1,(v_debugspeedtimer).w		; decrement delay for held buttons before moving
		bne.s	Debug_Move				; if time remains, branch
		move.b	#1,(v_debugspeedtimer).w		; keep delay to 1 so that the above branch keeps triggering
		addq.b	#1,(v_debugspeed).w			; accelerate speed for held D-Pad
		bne.s	Debug_Move_GetDirections		; if speed didn't reach max yet, branch
		move.b	#$FF,(v_debugspeed).w			; keep speed fixed at max until D-Pad is released again

Debug_Move_GetDirections:
		move.b	(v_jpadhold1).w,d4			; get held buttons for the directional checks

Debug_Move:
		moveq	#0,d1
		move.b	(v_debugspeed).w,d1			; get current debug move speed
		addq.w	#1,d1					; add one unit to base speed (at max speed, $FF+1=$100)
		swap	d1					; move delta to upper word (calculations use longwords for subpixels)
		asr.l	#4,d1					; divide speed by 16 to reasonably slow it down (upper nybble is pixels per frame)

		move.l	obY(a0),d2				; d2 = current debug object Y-position
		move.l	obX(a0),d3				; d3 = current debug object X-position

	.chkUp:
		btst	#bitUp,d4				; is up being held?
		beq.s	.chkDown				; if not, branch
		sub.l	d1,d2					; move up
	if FixBugs
		; These boundary checks only consider absolute values, which allows going offscreen.
		; From Sonic 2 onward, the active level boundaries are instead used for the checks.
		; Left/right bounds technically lack those fixes, they were added here for consistency.
		moveq	#0,d0					; clear d0
		move.w	(v_limittop2).w,d0			; get current top level boundary
		swap	d0					; move to upper word for long comparison
		cmp.l	d0,d2					; would new Y-position exceed top level boundary?
		bge.s	.chkDown				; if not, branch
		move.l	d0,d2					; keep Y-position within top level bound
	else
		bcc.s	.chkDown				; would new Y-position underflow? if not, branch
		moveq	#0,d2					; keep Y-position within absolute top bound
	endif

	.chkDown:
		btst	#bitDn,d4				; is down being held?
		beq.s	.chkLeft				; if not, branch
		add.l	d1,d2					; move down
	if FixBugs
		; See above.
		moveq	#0,d0					; clear d0
		move.w	(v_limitbtm2).w,d0			; get current bottom level boundary
		addi.w	#224-1,d0				; add screen height
		swap	d0					; move to upper word for long comparison
		cmp.l	d0,d2					; would new Y-position exceed bottom level boundary?
		blt.s	.chkLeft				; if not, branch
		move.l	d0,d2					; keep Y-position within bottom level bound
	else
		cmpi.l	#$7FF<<16,d2				; would new Y-position exceed maximum bottom?
		blo.s	.chkLeft				; if not, branch
		move.l	#$7FF<<16,d2				; keep Y-position within bottom bound
	endif

	.chkLeft:
		btst	#bitL,d4				; is left being held?
		beq.s	.chkRight				; if not, branch
		sub.l	d1,d3					; move left
	if FixBugs
		; See above.
		moveq	#0,d0					; clear d0
		move.w	(v_limitleft2).w,d0			; get current left level boundary
		swap	d0					; move to upper word for long comparison
		cmp.l	d0,d3					; would new X-position exceed left level boundary?
		bge.s	.chkRight				; if not, branch
		move.l	d0,d3					; keep X-position within left level bound
	else
		bcc.s	.chkRight				; would new X-position underflow? if not, branch
		moveq	#0,d3					; keep X-position within absolute left bound
	endif

	.chkRight:
		btst	#bitR,d4				; is right being held?
		beq.s	.setNewDebugPosition			; if not, branch
		add.l	d1,d3					; move right
	if FixBugs
		; See above. Also, right side lacked any boundary check to begin with.
		moveq	#0,d0					; clear d0
		move.w	(v_limitright2),d0			; get current right level boundary
		addi.w	#320-1,d0				; add screen width
		swap	d0					; move to upper word for long comparison
		cmp.l	d0,d3					; would new X-position exceed right level boundary?
		blt.s	.setNewDebugPosition			; if not, branch
		move.l	d0,d3					; keep X-position within right level bound
	endif

.setNewDebugPosition:
		move.l	d2,obY(a0)				; set new Y-position
		move.l	d3,obX(a0)				; set new X-position
		; continue to Debug_ChgItem...

; ---------------------------------------------------------------------------
; Allow spawning debug objects and cycling through item list
; ---------------------------------------------------------------------------

Debug_ChgItem:
		; Cycle forwards one item in list when pressing A
		btst	#bitA,(v_jpadpress2).w			; is button A pressed?
		beq.s	.checkCreateItem			; if not, branch
		addq.b	#1,(v_debugitem).w			; go forwards 1 item
		cmp.b	(v_debugitem).w,d6			; is newly selected item index past end of list?
		bhi.s	.display				; if not, branch
		move.b	#0,(v_debugitem).w			; go back to start of list

	.display:
		bra.w	Debug_ShowItem				; update displayed sprite for debug object
; ===========================================================================

.checkCreateItem:
		; Spawn new object when pressing C
		btst	#bitC,(v_jpadpress2).w			; is button C pressed?
		beq.s	Debug_ExitDebugMode			; if not, branch

		jsr	(FindFreeObj).l				; find a free object slot
		bne.s	Debug_ExitDebugMode			; if none are free, branch
	if FixBugs
		; Fix not being able to place more rings and such after collecting one
		clr.b	(v_objstate+2).w			; free up object state for spawned object (target for obRespawnNo=0)
	endif
		move.w	obX(a0),obX(a1)				; set new object's X-position
		move.w	obY(a0),obY(a1)				; set new object's Y-position
		_move.b	obMap(a0),obID(a1)			; create object (ID is stored in list with mappings as map+(object<<24))
		rts

; ---------------------------------------------------------------------------
; Allow exiting debug mode to revert back to normal Sonic state
; ---------------------------------------------------------------------------

Debug_ExitDebugMode:
		btst	#bitB,(v_jpadpress2).w			; is button B pressed?
		beq.s	.return					; if not, stay in debug mode

		moveq	#0,d0					; prepare 0 value
		move.w	d0,(v_debuguse).w			; deactivate debug mode
		move.l	#Map_Sonic,(v_player+obMap).w		; reset Sonic's mappings
		move.w	#ArtTile_Sonic,(v_player+obGfx).w	; reset Sonic's art tile
		move.b	d0,(v_player+obAnim).w			; reset Sonic's animation to walking
		move.w	d0,obSubpixelX(a0)			; clear Sonic's X subpixel portion
		move.w	d0,obSubpixelY(a0)			; clear Sonic's Y subpixel portion

	.return:
		rts
; End of function Debug_Control

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to set mappings and graphics for displayed debug object.
; Each entry in DebugList is 8 bytes in the following format:
; 	0:   object ID
;	0-3: mappings address (upper byte is ignored for 24-bit addressing)
;	4:   subtype
;	5:   frame ID
;	6-7: VRAM settings
; ---------------------------------------------------------------------------

Debug_ShowItem:
		moveq	#0,d0
		move.b	(v_debugitem).w,d0			; get currently selected item in debug list
		lsl.w	#3,d0					; each entry is 8 bytes
		move.l	(a2,d0.w),obMap(a0)			; load mappings for displayed item
		move.w	6(a2,d0.w),obGfx(a0)			; load VRAM setting for displayed item
		move.b	5(a2,d0.w),obFrame(a0)			; load frame number for displayed item
		rts
; End of function Debug_ShowItem


; ===========================================================================
; ---------------------------------------------------------------------------
; Debug mode item lists
; ---------------------------------------------------------------------------
DebugList:
		dc.w .GHZ-DebugList
		dc.w .LZ-DebugList
		dc.w .MZ-DebugList
		dc.w .SLZ-DebugList
		dc.w .SZ-DebugList
		dc.w .CWZ-DebugList

dbug:		macro map,object,subtype,frame,vram
		dc.l map+(object<<24)
		dc.b subtype,frame
		dc.w vram
		endm

dbugheader:	macro	{INTLABEL}
__LABEL__:	label	*
		dc.w	((__LABEL___end)-(__LABEL__)-2)/8
		endm

; ---------------------------------------------------------------------------

.GHZ:		dbugheader
		;	mappings	object			subtype	frame	VRAM setting
		dbug 	Map_Ring,	id_Rings,		0,	0,	ArtTile_Ring|Tile_Pal2
		dbug	Map_Monitor,	id_Monitor,		0,	0,	ArtTile_Monitor
		dbug	Map_Crab,	id_Crabmeat,		0,	0,	ArtTile_Crabmeat
		dbug	Map_Buzz,	id_BuzzBomber,		0,	0,	ArtTile_Buzz_Bomber
		dbug	Map_Chop,	id_Chopper,		0,	0,	ArtTile_Chopper
		dbug	Map_Spike,	id_Spikes,		0,	0,	ArtTile_Spikes
		dbug	Map_Plat_GHZ,	id_BasicPlatform,	0,	0,	ArtTile_Level|Tile_Pal3
		dbug	Map_PRock,	id_PurpleRock,		0,	0,	ArtTile_GHZ_Purple_Rock|Tile_Pal4
		dbug	Map_Moto,	id_MotoBug,		0,	0,	ArtTile_Moto_Bug
		dbug	Map_Spring,	id_Springs,		0,	0,	ArtTile_Spring_Horizontal
		dbug	Map_Newt,	id_Newtron,		0,	0,	ArtTile_Newtron|Tile_Pal2
		dbug	Map_Edge,	id_EdgeWalls,		0,	0,	ArtTile_GHZ_Edge_Wall|Tile_Pal3
		dbug	Map_GBall,	id_GHZBall,		0,	0,	ArtTile_GHZ_Giant_Ball|Tile_Pal3
.GHZ_end:

; ---------------------------------------------------------------------------

.LZ:		dbugheader
		;	mappings	object			subtype	frame	VRAM setting
		dbug 	Map_Ring,	id_Rings,		0,	0,	ArtTile_Ring|Tile_Pal2
		dbug	Map_Monitor,	id_Monitor,		0,	0,	ArtTile_Monitor
		dbug	Map_Crab,	id_Crabmeat,		0,	0,	ArtTile_Crabmeat
.LZ_end:

; ---------------------------------------------------------------------------

.MZ:		dbugheader
		;	mappings	object			subtype	frame	VRAM setting
		dbug 	Map_Ring,	id_Rings,		0,	0,	ArtTile_Ring|Tile_Pal2
		dbug	Map_Monitor,	id_Monitor,		0,	0,	ArtTile_Monitor
		dbug	Map_Buzz,	id_BuzzBomber,		0,	0,	ArtTile_Buzz_Bomber
		dbug	Map_Spike,	id_Spikes,		0,	0,	ArtTile_Spikes
		dbug	Map_Spring,	id_Springs,		0,	0,	ArtTile_Spring_Horizontal
		dbug	Map_Fire,	id_LavaMaker,		0,	0,	ArtTile_MZ_Fireball
		dbug	Map_Brick,	id_MarbleBrick,		0,	0,	ArtTile_Level|Tile_Pal3
		dbug	Map_Geyser,	id_GeyserMaker,		0,	0,	ArtTile_MZ_Lava|Tile_Pal4
		dbug	Map_LWall,	id_LavaWall,		0,	0,	ArtTile_MZ_Lava|Tile_Pal4
		dbug	Map_Push,	id_PushBlock,		0,	0,	ArtTile_MZ_Block|Tile_Pal3
		dbug	Map_Splats,	id_Splats,		0,	0,	ArtTile_Splats
	if FixBugs
		dbug	Map_Yad,	id_Yadrin,		0,	0,	ArtTile_Yadrin|Tile_Pal2
	else
		; Yadrin is using Sonic's palette, when it should be using it's own.
		dbug	Map_Yad,	id_Yadrin,		0,	0,	ArtTile_Yadrin
	endif
		dbug	Map_Smab,	id_SmashBlock,		0,	0,	ArtTile_MZ_Block|Tile_Pal3
	if FixBugs
		dbug	Map_MBlock,	id_MovingBlock,		0,	0,	ArtTile_MZ_Block|Tile_Pal3
		dbug	Map_CFlo,	id_CollapseFloor,	0,	0,	ArtTile_MZ_Block|Tile_Pal3
	else
		; The moving block is using Sonic's palette, when it should be using the 2nd level palette line.
		dbug	Map_MBlock,	id_MovingBlock,		0,	0,	ArtTile_MZ_Block
		; The collapsing floor is using the last palette, when it should be using the 2nd level palette line.
		dbug	Map_CFlo,	id_CollapseFloor,	0,	0,	ArtTile_MZ_Block|Tile_Pal4
	endif
		dbug	Map_LTag,	id_LavaTag,		0,	0,	ArtTile_Monitor|Tile_Prio
		dbug	Map_Bas,	id_Basaran,		0,	0,	ArtTile_Basaran|Tile_Pal2
.MZ_end:

; ---------------------------------------------------------------------------

.SLZ:		dbugheader
		;	mappings	object			subtype	frame	VRAM setting
		dbug 	Map_Ring,	id_Rings,		0,	0,	ArtTile_Ring|Tile_Pal2
		dbug	Map_Monitor,	id_Monitor,		0,	0,	ArtTile_Monitor
		dbug	Map_Elev,	id_Elevator,		0,	0,	ArtTile_SLZ_Platform|Tile_Pal3
		dbug	Map_CFlo,	id_CollapseFloor,	0,	2,	ArtTile_SLZ_Smashable_Wall|Tile_Pal3
		dbug	Map_Plat_SLZ,	id_BasicPlatform,	0,	0,	ArtTile_SLZ_Platform|Tile_Pal3
		dbug	Map_Circ,	id_CirclingPlatform,	0,	0,	ArtTile_SLZ_Platform|Tile_Pal3
		dbug	Map_Stair,	id_Staircase,		0,	0,	ArtTile_SLZ_Platform|Tile_Pal3
		dbug	Map_Fan,	id_Fan,			0,	0,	ArtTile_SLZ_Fan|Tile_Pal3
		dbug	Map_Seesaw,	id_Seesaw,		0,	0,	ArtTile_SLZ_Seesaw
		dbug	Map_Spring,	id_Springs,		0,	0,	ArtTile_Spring_Horizontal
		dbug	Map_Fire,	id_LavaMaker,		0,	0,	ArtTile_SLZ_Fireball
		dbug	Map_Crab,	id_Crabmeat,		0,	0,	ArtTile_Crabmeat
		dbug	Map_Buzz,	id_BuzzBomber,		0,	0,	ArtTile_Buzz_Bomber
.SLZ_end:

; ---------------------------------------------------------------------------

.SZ:		dbugheader
		;	mappings	object			subtype	frame	VRAM setting
		dbug 	Map_Ring,	id_Rings,		0,	0,	ArtTile_Ring|Tile_Pal2
		dbug	Map_Monitor,	id_Monitor,		0,	0,	ArtTile_Monitor
		dbug	Map_Spike,	id_Spikes,		0,	0,	ArtTile_Spikes
		dbug	Map_Spring,	id_Springs,		0,	0,	ArtTile_Spring_Horizontal
		dbug	Map_Roll,	id_Roller,		0,	0,	ArtTile_Roller|Tile_Pal2
		dbug	Map_Light,	id_SpinningLight,	0,	0,	ArtTile_Level
		dbug	Map_Bump,	id_Bumper,		0,	0,	ArtTile_SZ_Bumper
		dbug	Map_Crab,	id_Crabmeat,		0,	0,	ArtTile_Crabmeat
		dbug	Map_Buzz,	id_BuzzBomber,		0,	0,	ArtTile_Buzz_Bomber
	if FixBugs
		dbug	Map_Yad,	id_Yadrin,		0,	0,	ArtTile_Yadrin|Tile_Pal2
	else
		; Yadrin is using Sonic's palette, when it should be using it's own.
		dbug	Map_Yad,	id_Yadrin,		0,	0,	ArtTile_Yadrin
	endif
		dbug	Map_Plat_SZ,	id_BasicPlatform,	0,	0,	ArtTile_Level|Tile_Pal3
		dbug	Map_FBlock,	id_FloatingBlock,	0,	0,	ArtTile_Level|Tile_Pal3
		dbug	Map_But,	id_Button,		0,	0,	ArtTile_Button+4
.SZ_end:

; ---------------------------------------------------------------------------

.CWZ:		dbugheader
		;	mappings	object			subtype	frame	VRAM setting
		dbug 	Map_Ring,	id_Rings,		0,	0,	ArtTile_Ring|Tile_Pal2
		dbug	Map_Monitor,	id_Monitor,		0,	0,	ArtTile_Monitor
		dbug	Map_Crab,	id_Crabmeat,		0,	0,	ArtTile_Crabmeat
.CWZ_end:

; ---------------------------------------------------------------------------

;.DebugUnused:	dbugheader
		;	mappings	object			subtype	frame	VRAM setting
		dbug 	Map_Hog,	id_BallHog,		0,	0,	ArtTile_Ball_Hog|Tile_Pal2
		dbug	Map_Jaws,	id_Jaws,		0,	0,	ArtTile_Jaws
	if FixBugs
		dbug	Map_Burro,	id_Burrobot,		0,	0,	ArtTile_Burrobot|Tile_Pal2
	else
		; This uses Jaws's art tile instead of Burrobot's art tile.
		dbug	Map_Burro,	id_Burrobot,		0,	0,	ArtTile_Jaws|Tile_Pal2
	endif
;.DebugUnused_end:
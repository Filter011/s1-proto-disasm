; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to collide Sonic with objects using obColType(a0)
; 
; input:
;	a0 = address of OST of Sonic
; 
; output:
;	d0.l = (unused) -1 if Sonic touches an enemy or harmful object while invincible, or is hurt/killed
;	a2 = address of OST of object hurting/killing Sonic
; ---------------------------------------------------------------------------

ReactToItem:
		nop						; useless nop (probably so an rts could easily be inserted here)
		moveq	#0,d5
		move.b	obHeight(a0),d5				; load Sonic's height
		subq.b	#3,d5					; shrink by 3px
		move.w	obX(a0),d2				; load Sonic's x-axis position
		move.w	obY(a0),d3				; load Sonic's y-axis position
		subq.w	#sonic_react_width,d2			; d2 = X-position of Sonic's left edge
		sub.w	d5,d3					; d3 = Y-position of Sonic's top edge

		move.w	#sonic_react_width*2,d4			; d4 = Sonic's hitbox width
		add.w	d5,d5					; d5 = Sonic's hitbox height

		lea	(v_lvlobjspace).w,a1			; set object RAM start address
		move.w	#(v_lvlobjend-v_lvlobjspace)/object_size-1,d6 ; iterate through the entire level object RAM space
; .loop:
React_LoopObjects:
		tst.b	obRender(a1)				; is object on screen? (sprite rendered)
		bpl.s	React_CheckNext				; if not, don't check collision for it
		move.b	obColType(a1),d0			; load collision type
		bne.s	React_CheckHitboxOverlap		; if non-zero (i.e. not col_none), check for collision
; .next:
React_CheckNext:
		lea	object_size(a1),a1			; next object RAM
		dbf	d6,React_LoopObjects			; repeat $5F more times

		moveq	#0,d0					; no collision was processed
		rts

; ===========================================================================
;.sizes:
React_Sizes:

; Flags to further split objects into individual property subgroups.
col_none:	equ 0			; marker for no-collision objects
col_badnik:	equ 0			; destroyable badniks
col_boss:	equ 0			; Eggman bosses
col_item:	equ $40			; monitors, rings, giant rings
col_hurt:	equ $80			; damaging objects when touched
col_special:	equ $C0			; objects with special collision properties (Yadrin, Caterkiller, SYZ bumpers)

; Hitbox sizes are stored as box extents (half-width and half-height; similar to radii).
hitbox: macro width,height,{INTLABEL}
__LABEL__:	label	(*-React_Sizes)/2+1
		dc.b	width/2, height/2
		endm

		;     width, height
col_40x40:	hitbox	 40, 40		; $01 - GHZ ball
col_24x40:	hitbox	 24, 40		; $02 - (unused)
col_40x24:	hitbox	 40, 24		; $03 - (unused)
col_8x32:	hitbox	  8, 32		; $04 - GHZ spike pole, SYZ boss spike
col_24x36:	hitbox	 24, 36		; $05 - Ball Hog, Burrobot
col_32x32:	hitbox	 32, 32		; $06 - SBZ spikeball, Crabmeat, Monitor, SYZ spikeball, Prison
col_12x12:	hitbox	 12, 12		; $07 - Cannonball, Crab/Buzz missile, Ring
col_48x24:	hitbox	 48, 24		; $08 - Buzz Bomber
col_24x32:	hitbox	 24, 32		; $09 - Chopper
col_32x24:	hitbox	 32, 24		; $0A - Jaws
col_16x16:	hitbox	 16, 16		; $0B - MZ fire, Fireball, Batbrain, LZ spikeball, SLZ seesaw spike, Orbinaut, Caterkiller
col_40x32:	hitbox	 40, 32		; $0C - Newtron, Motobug, Yadrin
col_40x16:	hitbox	 40, 16		; $0D - Newtron
col_28x28:	hitbox	 28, 28		; $0E - Roller
col_48x48:	hitbox	 48, 48		; $0F - Bosses
col_80x32:	hitbox	 80, 32		; $10 - MZ vertical stomper
col_32x48:	hitbox	 32, 48		; $11 - MZ sideways stomper
col_24x64:	hitbox	 24, 64		; $12 - Giant ring
col_64x224:	hitbox	 64,224		; $13 - MZ geyser
col_128x64:	hitbox	128, 64		; $14 - MZ lava wall, MZ lava tag
col_256x64:	hitbox	256, 64		; $15 - MZ lava tag
col_64x64:	hitbox	 64, 64		; $16 - MZ lava tag
col_16x16_alt:	hitbox	 16, 16		; $17 - SYZ bumper
col_8x8:	hitbox	  8,  8		; $18 - SYZ spike chain, Bomb shrapnel, Orbinaut spike, LZ gargoyle fire
col_64x16:	hitbox	 64, 16		; $19 - SLZ swing

; (This list could theoretically go up to $3F entries...)


; ===========================================================================
; ---------------------------------------------------------------------------
; Object has a valid obColType set, check if Sonic is intersecting
; with its hitbox and handle collision if so.
; 
; input:
;	d2 = X-position of Sonic's left edge
;	d3 = Y-position of Sonic's top edge
;	d4 = Sonic's hitbox width
;	d5 = Sonic's hitbox height
;	a0 = OST of Sonic
;	a1 = OST of object to check
; ---------------------------------------------------------------------------

; .proximity:
React_CheckHitboxOverlap:
		andi.w	#$FF-(col_item|col_hurt|col_special),d0	; mask out subgroup bits / limit to $3F entries in React_Sizes
		add.w	d0,d0					; double for word-based indexing
		lea	React_Sizes-2(pc,d0.w),a2		; load React_Sizes array (skip over first entry, colType can't be 0)

.checkXOverlap:
		moveq	#0,d1					; clear d1 (hitbox sizes are stored as bytes)
		move.b	(a2)+,d1				; get object's horizontal hitbox radius
		move.w	obX(a1),d0				; get object's current X-position
		sub.w	d1,d0					; get object's left edge
		sub.w	d2,d0					; compare against Sonic's left edge
		bhs.s	.sonicLeft				; branch if Sonic is to the left of object

		add.w	d1,d1					; convert radius to full width
		add.w	d1,d0					; add width to get distance between right and left edges
		blo.s	.checkYOverlap				; branch if hitboxes overlap horizontally
		bra.s	React_CheckNext				; otherwise, object is not in collision range

	.sonicLeft:
		cmp.w	d4,d0					; is horizontal separation greater than Sonic's width?
		bhi.s	React_CheckNext				; if yes, object is not in collision range
; ---------------------------------------------------------------------------

; .withinx:
.checkYOverlap:
		moveq	#0,d1					; clear d1 (hitbox sizes are stored as bytes)
		move.b	(a2)+,d1				; get object's vertical hitbox radius
		move.w	obY(a1),d0				; get object's current Y-position
		sub.w	d1,d0					; get object's top edge
		sub.w	d3,d0					; compare against Sonic's top edge
		bhs.s	.sonicAbove

		add.w	d1,d1					; convert radius to full height
		add.w	d0,d1					; add height to get distance between bottom and top edges
		blo.s	React_CollisionDetected			; branch if hitboxes overlap vertically
		bra.s	React_CheckNext				; otherwise, object is not in collision range

	.sonicAbove:
		cmp.w	d5,d0					; is vertical separation greater than Sonic's height?
		bhi.s	React_CheckNext				; if yes, object is not in collision range
		; Continue to React_CollisionDetected...

; ---------------------------------------------------------------------------
; Sonic is touching this object, check what it should do now
; ---------------------------------------------------------------------------

React_CollisionDetected:
		move.b	obColType(a1),d1			; load object collision type
		andi.b	#col_item|col_hurt|col_special,d1	; is obColType $3F or lower?
		beq.w	React_Enemy				; if yes, this is a badnik (col_badnik)
		cmpi.b	#col_special,d1				; is obColType $C0 or higher?
		beq.w	React_Special				; if yes, this is a special object (col_special)
		tst.b	d1					; is obColType $80-$BF?
		bmi.w	React_ChkHurt				; if yes, this is a damaging object (col_hurt)

		; Otherwise, obColType is $40-$7F (col_item)
		move.b	obColType(a1),d0			; reload collision type
		andi.b	#$FF-(col_item|col_hurt|col_special),d0	; mask out special subgroup bits
		cmpi.b	#6,d0				; has a monitor been touched? ($46)
		beq.s	React_Monitor				; if yes, branch

		; Assume object is a ring (standard, lost, or giant)
		cmpi.w	#90,flashtime(a0)			; has Sonic recently been hurt and has more than 90 frames of flashing time left?
		bhs.w	.return					; if yes, prevent collecting ring
		addq.b	#2,obRoutine(a1)			; advance the ring's routine counter (e.g. Ring_Collect)

	.return:
		rts


; ===========================================================================
; ---------------------------------------------------------------------------
; Handle touching monitors
; ---------------------------------------------------------------------------

React_Monitor:
		tst.w	obVelY(a0)				; is Sonic moving upwards?
		bpl.s	.chkBreakMonitor			; if not, branch
	if FixBugs
		; Fix bumping monitors while Sonic isn't airborne
		btst	#1,obStatus(a0)				; is Sonic in air?
		beq.s	.chkBreakMonitor			; if not, don't bump monitor
	endif

.chkBumpMonitor:
		move.w	obY(a0),d0				; get Sonic's Y-position
		subi.w	#16,d0					; check 16px higher
		cmp.w	obY(a1),d0				; has Sonic touched the monitor from below?
		blo.s	.return					; if not, branch

		neg.w	obVelY(a0)				; reverse Sonic's vertical speed
		move.w	#-$180,obVelY(a1)			; bump monitor upwards a little
		tst.b	ob2ndRout(a1)				; is monitor being stood on or already set to fall?
		bne.s	.return					; if yes, do nothing
		addq.b	#4,ob2ndRout(a1)			; advance the monitor's secondary routine counter to ".fall" state
		rts
; ---------------------------------------------------------------------------

.chkBreakMonitor:
		cmpi.b	#id_Roll,obAnim(a0)			; is Sonic rolling/jumping?
		bne.s	.return					; if not, don't break monitor
		neg.w	obVelY(a0)				; reverse Sonic's y-motion
		addq.b	#2,obRoutine(a1)			; advance the monitor's routine counter

	.return:
		rts


; ===========================================================================
; ---------------------------------------------------------------------------
; Handle touching badniks
; ---------------------------------------------------------------------------

React_Enemy:
		tst.b	(v_invinc).w				; is Sonic invincible?
		bne.s	.checkBossHit				; if yes, branch
		cmpi.b	#id_Roll,obAnim(a0)			; is Sonic rolling/jumping?
		bne.s	React_ChkHurt

	.checkBossHit:
		tst.b	obColProp(a1)				; is target a boss? (has boss HP set)
		beq.s	React_BadnikHit				; if not, it's a badnik

React_BossHit:
		neg.w	obVelX(a0)				; repel Sonic horizontally
		neg.w	obVelY(a0)				; repel Sonic verticallly
		asr.w	obVelX(a0)				; halve current X-speed
		asr.w	obVelY(a0)				; halve current Y-speed
		move.b	#col_none,obColType(a1)			; set boss to no collision while it's damaged

		subq.b	#1,obColProp(a1)			; decrement 1 boss HP
		bne.s	.return					; if boss HP remain, branch
		bset	#7,obStatus(a1)				; set flag that boss has been defeated

	.return:
		rts
; ===========================================================================

React_BadnikHit:
		bset	#7,obStatus(a1)				; set flag that badnik has been broken (pretty much unused, badnik gets replaced by explosion)

		; Points and points object
		moveq	#10,d0					; give 100 points
		bsr.w	AddPoints				; add d0 to current score

		; Change badnik into gray explosion
		_move.b	#id_ExplosionItem,obID(a1)		; change badnik into an to explosion/animal object
		move.b	#0,obRoutine(a1)			; set to "ExItem_Animal" routine to also spawn animal/points objects

		; Bounce Sonic vertically
		tst.w	obVelY(a0)				; is Sonic moving upwards?
		bmi.s	.slowFromBelow				; if yes, branch
		move.w	obY(a0),d0				; get Sonic's Y-position
		cmp.w	obY(a1),d0				; was Sonic below badnik on impact?
		bhs.s	.boostFromBelow				; if yes, branch
		neg.w	obVelY(a0)				; negate Sonic's Y-speed to make him bounce upwards
		rts

	.slowFromBelow:
		addi.w	#$100,obVelY(a0)			; slow down Sonic going up if badnik touched from below
		rts

	.boostFromBelow:
		subi.w	#$100,obVelY(a0)			; add a bit of boost speed when touching from below
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Handle taking damage
; ---------------------------------------------------------------------------

React_ChkHurt:
		tst.b	(v_invinc).w				; is Sonic invincible?
		beq.s	.damage					; if not, branch

; .isflashing:
.noDamage:
		moveq	#-1,d0					; collision detected
		rts
; ---------------------------------------------------------------------------

; .notinvincible:
.damage:
		nop						; useless nop (probably so an rts could easily be inserted here)
		tst.w	flashtime(a0)				; is Sonic flashing?
		bne.s	.noDamage				; if yes, don't take damage

		movea.l	a1,a2					; damaging object needs to be in a2 for HurtSonic/KillSonic
		; continue straight to HurtSonic...

; ---------------------------------------------------------------------------
; Hurting Sonic subroutine
; 
; input:
;	a0 = address of OST of Sonic
;	a2 = address of OST of object hurting Sonic
; 
; output:
;	d0.l = (unused) -1
;	a1 = address of OST of ring loss object (if Sonic had rings)
; ---------------------------------------------------------------------------

HurtSonic:
		tst.b	(v_shield).w				; does Sonic have a shield?
		bne.s	.bounceSonicAway			; if yes, branch
		tst.w	(v_rings).w				; does Sonic have any rings?
		beq.s	.hitWithoutRings			; if not, branch to kill Sonic

		bsr.w	FindFreeObj				; find a free object slot
		bne.s	.bounceSonicAway			; if object RAM is full, branch
		_move.b	#id_RingLoss,obID(a1)			; load bouncing multi rings object
		move.w	obX(a0),obX(a1)				; spawn at Sonic's X-position
		move.w	obY(a0),obY(a1)				; spawn at Sonic's Y-position

	.bounceSonicAway:
		move.b	#0,(v_shield).w				; remove a potential shield
		move.b	#4,obRoutine(a0)			; set Sonic to "Sonic_Hurt" routine
		bsr.w	Sonic_ResetOnFloor			; reset airborne state
		bset	#1,obStatus(a0)				; force airborne flag again

		move.w	#-$400,obVelY(a0)			; bounce Sonic vertically
		move.w	#-$200,obVelX(a0)			; bounce Sonic horizontally
		move.w	obX(a0),d0				; get Sonic's X-position
		cmp.w	obX(a2),d0				; compare with X-position of collided object
		blo.s	.setDamageState				; if Sonic is left of the object, branch
		neg.w	obVelX(a0)				; if Sonic is right of the object, reverse

	.setDamageState:
		move.w	#0,obInertia(a0)			; cancel ground speed
		move.b	#id_Hurt,obAnim(a0)			; set Sonic to hurt animation
		move.w	#10*60,flashtime(a0)			; set temporary invulnerability time to 10 seconds
		move.w	#sfx_Death,d0				; use generic damage sound
		cmpi.b	#id_Spikes,obID(a2)			; was damage caused by spikes?
		bne.s	.sound					; if not, branch
		move.w	#sfx_HitSpikes,d0			; use spike damage sound

	.sound:
		jsr	(QueueSound2).l				; play selected sound

		moveq	#-1,d0					; collision detected
		rts
; ===========================================================================

; .norings:
.hitWithoutRings:
		tst.w	(f_debugmode).w
		bne.s	.bounceSonicAway
		; continue straight to KillSonic...


; ---------------------------------------------------------------------------
; Subroutine to kill Sonic
; 
; input:
;	a0 = address of OST of Sonic
;	a2 = address of OST of object killing Sonic
; 
; output:
;	d0.l = (unused) -1
; ---------------------------------------------------------------------------

KillSonic:
		tst.w	(v_debuguse).w				; is debug mode active?
		bne.s	.return

		move.b	#6,obRoutine(a0)			; set Sonic to "Sonic_Death" routine
		bsr.w	Sonic_ResetOnFloor			; reset airborne state
		bset	#1,obStatus(a0)				; force airborne flag again

		move.w	#-$700,obVelY(a0)			; launch Sonic upwards while dying
		move.w	#0,obVelX(a0)				; stop horizontal movement
		move.w	#0,obInertia(a0)			; stop ground movement

		move.w	obY(a0),respawny(a0)			; (unused) backup Y-position before dying

		move.b	#id_Death,obAnim(a0)			; set Sonic to use death animation
		move.w	#sfx_Death,d0				; play normal death sound
		cmpi.b	#id_Spikes,obID(a2)			; check if you were killed by spikes
		bne.s	.sound					; if not, branch
		move.w	#sfx_HitSpikes,d0			; play spikes death sound

	.sound:
		jsr	(QueueSound2).l				; play selected sound

	; .dontdie:
	.return:
		moveq	#-1,d0					; collision detected
		rts
; End of function KillSonic


; ===========================================================================
; ---------------------------------------------------------------------------
; Handle special collision with objects whose obColType is $C0 or above
; ---------------------------------------------------------------------------

React_Special:
		move.b	obColType(a1),d1			; get colType of collided object
		andi.b	#$FF-(col_item|col_hurt|col_special),d1	; mask out special subgroup bits

		cmpi.b	#$C,d1
		beq.s	React_Yadrin
		cmpi.b	#$17,d1
		beq.s	React_SZBumper

		rts						; otherwise, invalid special collision
; ===========================================================================

; .yadrin:
React_Yadrin:
		; The Yadrin's spiked section collision works by having an imaginary,
		; 24x8 pixels wide hitbox at its top, offset by 4px to expose the face.
		sub.w	d0,d5					; d5 = pixels Sonic's bottom edge is clipping into Yadrin's top edge
		cmpi.w	#8,d5					; is Sonic at least 8px into the Yadrin from above?
		bhs.s	.normalBadnik				; if yes, treat as normal badnik

		move.w	obX(a1),d0				; get Yadrin's current X-position
		subq.w	#4,d0					; get left edge of special collision region
		btst	#0,obStatus(a1)				; is Yadrin facing left?
		beq.s	.checkSpikedSection			; if not, branch
		subi.w	#16,d0					; mirror collision region horizontally

	.checkSpikedSection:
		sub.w	d2,d0					; compare spiked section against Sonic's left edge
		bhs.s	.sonicLeft				; branch if Sonic is left of spiked section
		addi.w	#24,d0					; spiked section is 24px wide
		blo.s	.damaging				; branch if Sonic overlaps it
		bra.s	.normalBadnik				; otherwise, handle as normal enemy collision

	.sonicLeft:
		cmp.w	d4,d0					; is Sonic too far left to overlap spiked section?
		bhi.s	.normalBadnik				; if yes, handle as normal enemy collision
; ---------------------------------------------------------------------------

	.damaging:
		bra.w	React_ChkHurt				; take damage when touching Yadrin's spiked section

	.normalBadnik:
		bra.w	React_Enemy				; treat as normal badnik when touching Yadrin in other ways
; ===========================================================================

React_SZBumper:
		addq.b	#1,obColProp(a1)			; set flag that object has been touched (handled in object itself)
		rts
; End of function React_Special
; ===========================================================================

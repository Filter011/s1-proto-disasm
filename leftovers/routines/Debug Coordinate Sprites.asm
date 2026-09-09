; ---------------------------------------------------------------------------
; Unused Early Debug Coordinates routines
;
; This can be seen in early footage of the game.
; ---------------------------------------------------------------------------

; sub_2ED0:
Debug_Coord_Sprites:
		lea	(Debug_Coords_XY_Index).l,a0		; get index of x and y positions for the coords
		lea	(v_debugnumbers1).w,a1			; set object RAM to load to
		move.w	#(Debug_Coords_XY_Index_end-Debug_Coords_XY_Index)/4-1,d1 ; load 12 digits

.loop:
		move.b	#id_Obj05,obID(a1)			; load object 05
		move.w	(a0)+,obX(a1)				; set X position
		move.w	(a0)+,obScreenY(a1)			; set Y position
		lea	object_size(a1),a1			; go to next object RAM slot
		dbf	d1,.loop				; loop until all digits have been loaded
		rts
; ===========================================================================

; Format: dc.w $X, $Y
; Each entry is a digit.
Debug_Coords_XY_Index:
		dc.w $158, $148
		dc.w $160, $148
		dc.w $168, $148
		dc.w $170, $148
		dc.w $180, $148
		dc.w $188, $148
		dc.w $190, $148
		dc.w $198, $148
; In earlier builds, this was set to 8 digits instead of 12.
		dc.w $158, $98
		dc.w $160, $98
		dc.w $168, $98
		dc.w $170, $98
Debug_Coords_XY_Index_end:

; ===========================================================================
; sub_2F24:
Debug_Coord_B_Sprites:
		lea	(Debug_Coords_B_XY_Index).l,a0		; get index of x and y positions for the coords
		lea	(v_debugnumbers2).w,a1			; set object RAM to load to
		move.w	#(Debug_Coords_B_XY_Index_end-Debug_Coords_B_XY_Index)/4-1,d1 ; load 52 digits

.loop:
		move.b	#id_Obj05,obID(a1)			; load object 05
		move.w	(a0)+,obX(a1)				; set X position
		move.w	(a0)+,obScreenY(a1)			; set Y position
		lea	object_size(a1),a1			; go to next object RAM slot
		dbf	d1,.loop				; loop until all digits have been loaded
		rts
; ===========================================================================

; Format: dc.w $X, $Y
; Each entry is a digit.
Debug_Coords_B_XY_Index:
		dc.w $158, $90
		dc.w $160, $90
		dc.w $168, $90
		dc.w $170, $90
		dc.w $180, $90
		dc.w $188, $90
		dc.w $190, $90
		dc.w $198, $90
		dc.w $158, $A0
		dc.w $160, $A0
		dc.w $168, $A0
		dc.w $170, $A0
		dc.w $180, $A0
		dc.w $188, $A0
		dc.w $190, $A0
		dc.w $198, $A0
		dc.w $158, $A8
		dc.w $160, $A8
		dc.w $168, $A8
		dc.w $170, $A8
		dc.w $180, $A8
		dc.w $188, $A8
		dc.w $190, $A8
		dc.w $198, $A8
		dc.w $158, $B0
		dc.w $160, $B0
		dc.w $168, $B0
		dc.w $170, $B0
		dc.w $180, $B0
		dc.w $188, $B0
		dc.w $190, $B0
		dc.w $198, $B0
		dc.w $158, $B8
		dc.w $160, $B8
		dc.w $168, $B8
		dc.w $170, $B8
		dc.w $180, $B8
		dc.w $188, $B8
		dc.w $190, $B8
		dc.w $198, $B8
		dc.w $100, $98
		dc.w $108, $98
		dc.w $110, $98
		dc.w $118, $98
		dc.w $128, $98
		dc.w $130, $98
		dc.w $138, $98
		dc.w $140, $98
		dc.w $128, $A8
		dc.w $130, $A8
		dc.w $138, $A8
		dc.w $140, $A8
Debug_Coords_B_XY_Index_end:
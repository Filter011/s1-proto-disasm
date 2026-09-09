; ===========================================================================
; ---------------------------------------------------------------------------
; RAM Variables
; ---------------------------------------------------------------------------

	include	"s1.sounddriver.ram.asm"

; Sign-extends a 32-bit integer to 64-bit
; (All RAM addresses are run through this function to allow them to work in both 16-bit and 32-bit addressing modes.)
ramaddr function x,(-(x&$80000000)<<1)|x

; v = Variables // f = Flags
	phase ramaddr ( $FFFF0000 )
v_ram_start_def:
v_ram_start:		equ	v_ram_start_def&$FFFFFF		; 24-bit addressing

v_256x256_def:		ds.b	chunk_size*$52			; 256x256 tile mappings ($52 chunks)
v_256x256:		equ	v_256x256_def&$FFFFFF		; 24-bit addressing
v_256x256_end:

v_lvllayout:		ds.b	layout_row*8			; level layouts (FG/BG rows interlaced, 8 rows and $400 total)
v_lvllayout_fg:		equ	v_lvllayout			; start address of foreground's first row
v_lvllayout_bg:		equ	v_lvllayout+layout_row_interlaced ; start address of background's first row
v_lvllayout_end:

v_bgscroll_buffer:	ds.b	$200				; background scroll buffer
v_ngfx_buffer:		ds.b	$200				; Nemesis graphics decompression buffer
v_ngfx_buffer_end:

v_spritequeue:		ds.b	spritelayer_num*spritelayer_size ; sprite display queue, in order of priority (8*$80=$400 bytes)

v_16x16:		ds.b	block_size*$300			; 16x16 tile mappings ($300 blocks)
v_16x16_end:

v_sgfx_buffer:		ds.b	tile_size*23			; buffered Sonic graphics ($17 cells)
v_sgfx_buffer_end:

			ds.b	$20				; unused
v_tracksonic:		ds.b	$100				; sonic position table ($100 bytes)

v_hscrolltablebuffer:	ds.b	$380				; scrolling table data
v_hscrolltablebuffer_end:
			ds.b	$80				; would be unused, but data from v_hscrolltablebuffer can spill into here
v_hscrolltablebuffer_end_padded:

v_objspace:		ds.b	object_size*$80			; RAM for object space ($40 bytes per object)

; Title screen objects
v_titlesonic:		equ	v_objspace+object_size*1	; object variable space for Sonic in the title screen ($40 bytes)
v_pressstart:		equ	v_objspace+object_size*2	; object variable space for the "PRESS START BUTTON" text ($40 bytes)
v_ttlsonichide:		equ	v_objspace+object_size*3	; object variable space for hiding part of Sonic ($40 bytes)

; Level objects
v_player:		equ	v_objspace+object_size*0	; object variable space for Sonic ($40 bytes)
v_hud:			equ	v_objspace+object_size*1	; object variable space for the HUD ($40 bytes)

v_titlecard:		equ	v_objspace+object_size*2	; object variable space for the title card ($100 bytes)
v_ttlcardname:		equ	v_titlecard+object_size*0	; object variable space for the title card zone name text ($40 bytes)
v_ttlcardzone:		equ	v_titlecard+object_size*1	; object variable space for the title card "ZONE" text ($40 bytes)
v_ttlcardact:		equ	v_titlecard+object_size*2	; object variable space for the title card act text ($40 bytes)
v_ttlcardoval:		equ	v_titlecard+object_size*3	; object variable space for the title card oval ($40 bytes)

v_gameovertext1:	equ	v_objspace+object_size*2	; object variable space for the "GAME" in "GAME OVER" text ($40 bytes)
v_gameovertext2:	equ	v_objspace+object_size*3	; object variable space for the "OVER" in "GAME OVER" text ($40 bytes)

v_shieldobj:		equ	v_objspace+object_size*6	; object variable space for the shield ($40 bytes)
v_starsobj1:		equ	v_objspace+object_size*8	; object variable space for the invincibility stars #1 ($40 bytes)
v_starsobj2:		equ	v_objspace+object_size*9	; object variable space for the invincibility stars #2 ($40 bytes)
v_starsobj3:		equ	v_objspace+object_size*10	; object variable space for the invincibility stars #3 ($40 bytes)
v_starsobj4:		equ	v_objspace+object_size*11	; object variable space for the invincibility stars #4 ($40 bytes)

v_endcard:		equ	v_objspace+object_size*24	; object variable space for the level results card ($1C0 bytes)
v_endcardsonic:		equ	v_endcard+object_size*0		; object variable space for the level results card "SONIC HAS" text ($40 bytes)
v_endcardpassed:	equ	v_endcard+object_size*1		; object variable space for the level results card "PASSED" text ($40 bytes)
v_endcardact:		equ	v_endcard+object_size*2		; object variable space for the level results card act text ($40 bytes)
v_endcardscore:		equ	v_endcard+object_size*3		; object variable space for the level results card score tally ($40 bytes)
v_endcardtime:		equ	v_endcard+object_size*4		; object variable space for the level results card time bonus tally ($40 bytes)
v_endcardring:		equ	v_endcard+object_size*5		; object variable space for the level results card ring bonus tally ($40 bytes)
v_endcardoval:		equ	v_endcard+object_size*6		; object variable space for the level results card oval ($40 bytes)

; This has an issue where inertia overwrites v_endcard.
v_debugnumbers1:	equ	v_objspace+object_size*16	; object variable space for the unused debug numbers ($300 bytes)
v_debugnumxpos:		equ	v_debugnumbers1+object_size*0	; object variable space for the x position of the unused debug numbers ($100 bytes)
v_debugnumypos:		equ	v_debugnumbers1+object_size*4	; object variable space for the y position of the unused debug numbers ($100 bytes)
v_debugnuminertia:	equ	v_debugnumbers1+object_size*8	; object variable space for the inertia of the unused debug numbers ($100 bytes)

; This has an issue where it spills into v_lvlobjspace due to how many numbers it loads in (52 numbers).
v_debugnumbers2:	equ	v_objspace+object_size*10	; object variable space for the unused debug numbers ($D00 bytes)

v_vanishsonic:		equ	v_objspace+object_size*7	; object variable space for when sonic is vanishing after interacting with a giant ring ($40 bytes)

v_lvlobjspace:		equ	v_objspace+object_size*32	; level object variable space ($1800 bytes)
v_lvlobjend:		equ	v_lvlobjspace+object_size*96
v_objspace_end:		equ	v_lvlobjend

v_snddriver_ram:	SMPS_RAM				; start of RAM for the sound driver data ($5C0 bytes)
			ds.b	$40				; unused

v_gamemode:		ds.b	1
			ds.b	1				; unused
v_jpadhold2:		ds.b	1
v_jpadpress2:		ds.b	1
v_jpadhold1:		ds.b	1
v_jpadpress1:		ds.b	1
			ds.b	6				; unused
v_vdp_buffer1:		ds.w	1
			ds.b	6				; unused
v_generictimer:		ds.w	1
v_scrposy_vdp:		ds.w	1
v_bgscrposy_vdp:	ds.w	1				; background screen position y (duplicate) (2 bytes)
v_scrposx_vdp:		ds.w	1
v_bgscrposx_vdp:	ds.w	1				; background screen position x (duplicate) (2 bytes)
v_bg3scrposy_vdp:	ds.w	1
v_bg3scrposx_vdp:	ds.w	1
v_bg3scrposy_vdp_dup:	ds.w	1
v_hblank_hreg:		ds.b	1				; VDP H.interrupt register buffer (8Axx)
v_hblank_line:		ds.b	1				; screen line where water starts and palette is changed by HBlank
v_pfade_start:		ds.b	1				; palette fading - start position in bytes
v_pfade_size:		ds.b	1				; palette fading - number of colouds
v_lvlcount:		ds.b	1
v_lvlcount2:		ds.b	1
v_vblank_routine:	ds.b	1
			ds.b	1				; unused
v_spritecount:		ds.b	1
			ds.b	5				; unused
v_pcyc_num:		ds.w	1				; palette cycling - current reference number (2 bytes)
v_pcyc_time:		ds.w	1				; palette cycling - time until the next change (2 bytes)
v_random:		ds.l	1
f_pause:		ds.w	1
			ds.b	8				; unused
v_vdp_buffer2:		ds.w	1
			ds.b	2				; unused
f_hblank:		ds.w	1
			ds.b	2				; unused
f_water:		ds.w	1
			ds.b	2				; unused
v_pal_buffer:		ds.b	$16				; palette data buffer (used for palette cycling) ($16 bytes)
v_levseldelay:		ds.w	1				; level select - time until change when up/down is held (2 bytes)
v_levselitem:		ds.w	1				; level select - item selected (2 bytes)
v_levselsound:		ds.w	1				; level select - sound selected (2 bytes)
			ds.b	$14				; unused

plc_slot_size:		equ	4+2				; size of a single PLC slot: 6 bytes = 4 bytes (data address) + 2 bytes (VRAM target address)
v_plc_buffer:		ds.b	plc_slot_size*16		; pattern load cues buffer (maximum $10 PLCs)
v_plc_buffer_dest:	equ	v_plc_buffer+4			; VRAM destination for 1st item in PLC buffer (2 bytes)
v_plc_buffer_only_end:
v_plc_ptrnemcode:	ds.l	1				; pointer for nemesis decompression code ($1502 or $150C)
v_plc_repeatcount:	ds.l	1
v_plc_paletteindex:	ds.l	1
v_plc_previousrow:	ds.l	1
v_plc_dataword:		ds.l	1
v_plc_shiftvalue:	ds.l	1
v_plc_patternsleft:	ds.w	1
v_plc_framepatternsleft:ds.w	1
			ds.b	4				; unused
v_plc_buffer_end:

v_misc_variables:
v_scrposx:		ds.l	1
v_screenposx:		equ	v_scrposx
v_scrposy:		ds.l	1
v_screenposy:		equ	v_scrposy
v_bgscrposx:		ds.l	1
v_bgscreenposx:		equ	v_bgscrposx
v_bgscrposy:		ds.l	1
v_bgscreenposy:		equ	v_bgscrposy
v_bg2scrposx:		ds.l	1
v_bg2screenposx:	equ	v_bg2scrposx
v_bg2scrposy:		ds.l	1
v_bg2screenposy:	equ	v_bg2scrposy
v_bg3scrposx:		ds.l	1
v_bg3screenposx:	equ	v_bg3scrposx
v_bg3scrposy:		ds.l	1
v_bg3screenposy:	equ	v_bg3scrposy
v_limitleft1:		ds.w	1
v_limitright1:		ds.w	1				; unused
v_limittop1:		ds.w	1
v_limitbtm1:		ds.w	1
v_limitleft2:		ds.w	1
v_limitright2:		ds.w	1
v_limittop2:		ds.w	1
v_limitbtm2:		ds.w	1
v_unused11:		ds.w	1
v_limitleft3:		ds.w	1
			ds.b	6				; unused
v_scrshiftx:		ds.w	1
v_scrshifty:		ds.w	1
v_lookshift:		ds.w	1
f_rst_hscroll:		ds.b	1
f_rst_vscroll:		ds.b	1
v_dle_routine:		ds.b	1
			ds.b	1				; unused
f_nobgscroll:		ds.b	1
			ds.b	1				; unused
v_unused9:		ds.b	1
			ds.b	1				; unused
v_unused10:		ds.b	1
			ds.b	1				; unused
v_fg_xblock:		ds.b	1
v_fg_yblock:		ds.b	1
v_bg1_xblock:		ds.b	1
v_bg1_yblock:		ds.b	1
v_bg2_xblock:		ds.b	1
v_bg2_yblock:		ds.b	1				; unused
v_bg3_xblock:		ds.b	1				; unused
v_bg3_yblock:		ds.b	1				; unused
			ds.b	2				; unused
v_fg_scroll_flags:	ds.w	1
v_bg1_scroll_flags:	ds.w	1
v_bg2_scroll_flags:	ds.w	1
v_bg3_scroll_flags:	ds.w	1				; unused
f_bgscrollvert:		ds.b	1
			ds.b	3				; unused
v_sonspeedmax:		ds.w	1
v_sonspeedacc:		ds.w	1
v_sonspeeddec:		ds.w	1
v_sonframenum:		ds.b	1				; frame to display for Sonic
f_sonframechg:		ds.b	1
v_anglebuffer:		ds.b	1				; primary angle buffer
			ds.b	1				; unused
v_anglebuffer2:		ds.b	1				; secondary angle buffer
			ds.b	1				; unused
v_opl_routine:		ds.b	1				; ObjPosLoad - routine counter
			ds.b	1				; unused
v_opl_screen:		ds.w	1				; ObjPosLoad - screen variable (2 bytes)
v_opl_data:		ds.b	$10				; ObjPosLoad - data buffer ($10 bytes)
v_ssangle:		ds.w	1				; Special Stage angle (2 bytes)
v_ssrotate:		ds.w	1				; Special Stage rotation speed (2 bytes)
			ds.b	$C				; unused
v_btnpushtime1:		ds.w	1
v_btnpushtime2:		ds.w	1
v_palchgspeed:		ds.w	1
v_collindex:		ds.l	1
v_palss_num:		ds.w	1
v_palss_time:		ds.w	1
v_palss_index:		ds.w	1
v_ssbganim:		ds.w	1
			ds.b	2				; unused
v_obj31ypos:		ds.w	1				; y-position of object 31 (MZ stomper) (2 bytes)
			ds.b	1				; unused
v_bossstatus:		ds.b	1
v_trackpos:		ds.b	1
v_trackbyte:		ds.b	1
f_lockscreen:		ds.b	1
			ds.b	1				; unused
v_256loop1:		ds.b	1				; 256x256 level tile which contains a loop (GHZ/SLZ)
v_256loop2:		ds.b	1				; 256x256 level tile which contains a loop (GHZ/SLZ)
v_256roll1:		ds.b	1				; 256x256 level tile which contains a roll tunnel (GHZ)
v_256roll2:		ds.b	1				; 256x256 level tile which contains a roll tunnel (GHZ)
v_lani0_frame:		ds.b	1				; level graphics animation 0 - current frame
v_lani0_time:		ds.b	1				; level graphics animation 0 - time until next frame
v_lani1_frame:		ds.b	1				; level graphics animation 1 - current frame
v_lani1_time:		ds.b	1				; level graphics animation 1 - time until next frame
v_lani2_frame:		ds.b	1				; level graphics animation 2 - current frame
v_lani2_time:		ds.b	1				; level graphics animation 2 - time until next frame
v_lani3_frame:		ds.b	1				; level graphics animation 3 - current frame
			ds.b	$29				; unused
f_switch:		ds.w	1
			ds.b	$E				; unused
v_scroll_block_1_size:	ds.w	1
			ds.b	$E				; unused
v_misc_variables_end:

v_spritetablebuffer:	ds.b	$280
v_spritetablebuffer_end:
			ds.b	$80				; unused

v_palette:	; main palette
v_palette_line_1:	ds.b $20
v_palette_line_2:	ds.b $20
v_palette_line_3:	ds.b $20
v_palette_line_4:	ds.b $20
v_palette_end:

v_palette_fading:	; duplicate palette, used for transitions
v_palette_fading_line_1:	ds.b $20
v_palette_fading_line_2:	ds.b $20
v_palette_fading_line_3:	ds.b $20
v_palette_fading_line_4:	ds.b $20
v_palette_fading_end:

v_objstate:		ds.b	$C0				; object state list
v_objstate_end:
			ds.b	$140				; stack
v_systemstack:
v_crossresetram:
			ds.b	2				; unused
f_restart:		ds.w	1				; restart level flag (2 bytes)
v_framecount:		ds.b	1				; frame counter (adds 1 every frame) (2 bytes)
v_framebyte:		ds.b	1				; low byte for frame counter
v_debugitem:		ds.w	1
v_debuguse:		ds.w	1				; debug mode use & routine counter (when Sonic is a ring/item)
v_debugspeedtimer:	ds.b	1				; debug mode - timer before movement starts
v_debugspeed:		ds.b	1				; debug mode - movement speed
v_vblank_count:		ds.w	1				; vertical interrupt counter (adds 1 every VBlank)
v_vblank_word:		ds.b	1				; low word for vertical interrupt counter (2 bytes)
v_vblank_byte:		ds.b	1				; low byte for vertical interrupt counter
v_zone:			ds.b	1				; current zone number
v_act:			ds.b	1				; current act number
v_zone_act:		equ	v_zone				; when v_zone is read as word
v_lives:		ds.b	1
			ds.b	8				; unused
v_lifecount:		ds.b	1				; lives counter value (for actual number, see "v_lives")
f_lifecount:		ds.b	1				; lives counter update flag
f_ringcount:		ds.b	1
f_timecount:		ds.b	1
f_scorecount:		ds.b	1				; score counter update flag
v_rings:		ds.b	1
v_ringbyte:		ds.b	1				; low byte for rings
v_time:			ds.b	1
v_timemin:		ds.b	1				; time - minutes
v_timesec:		ds.b	1				; time - seconds
			ds.b	1				; unused
v_score:		ds.l	1
			ds.b	2				; unused
v_shield:		ds.b	1
v_invinc:		ds.b	1
v_shoes:		ds.b	1
v_unused1:		ds.b	1
			ds.b	$20				; unused
v_scorecopy:		ds.l	1
v_timebonus:		ds.w	1
v_ringbonus:		ds.w	1
f_endactbonus:		ds.b	1
			ds.b	5				; unused
v_oscillate:		ds.w	1				; oscillation bitfield

v_timingandscreenvariables:
			ds.b	$40				; values which oscillate - for swinging platforms, et al
			ds.b	$20				; unused, but gets cleared
v_ani0_time:		ds.b	1				; synchronised sprite animation 0 - time until next frame (used for synchronised animations)
v_ani0_frame:		ds.b	1				; synchronised sprite animation 0 - current frame
v_ani1_time:		ds.b	1				; synchronised sprite animation 1 - time until next frame
v_ani1_frame:		ds.b	1				; synchronised sprite animation 1 - current frame
v_ani2_time:		ds.b	1				; synchronised sprite animation 2 - time until next frame
v_ani2_frame:		ds.b	1				; synchronised sprite animation 2 - current frame
v_ani3_time:		ds.b	1				; synchronised sprite animation 3 - time until next frame
v_ani3_frame:		ds.b	1				; synchronised sprite animation 3 - current frame
v_ani3_buf:		ds.w	1				; synchronised sprite animation 3 - info buffer (2 bytes)
			ds.b	$36				; unused
v_timingandscreenvariables_end:

			ds.b	$E0				; unused
v_unused12:		ds.w	1				; value that's set to 1 during initation, unused otherwise (2 bytes)
			ds.b	6				; unused
v_unused13:		ds.w	1				; value that's set to 0 during initation of a level, unused otherwise (2 bytes)
			ds.b	6				; unused
f_demo:			ds.w	1
v_demonum:		ds.w	1
			ds.l	1				; unused
v_megadrive:		ds.b	1
			ds.b	1				; unused
f_debugmode:		ds.b	1
			ds.b	1				; unused
v_init:			ds.l	1				; 'init' text string (4 bytes)
v_ram_end:
	dephase

; Special Stage
	phase	$FF0000
ss_layout_rowlength_prev:	equ $40
ss_layout_rows_prev:	equ $40
ss_layout_rowlength:	equ $80
ss_layout_rows:		equ $24
ss_matrixsize:		equ 16

v_sslayout_base:	ds.b	$172E
v_sslayout_prev:	equ	$FF1020
v_sslayout_actual:	ds.b	ss_layout_rowlength*ss_layout_rows ; actual SS layout, after padding
v_sslayout_end:							; end of SS layout buffer
			ds.b	$16D2				; unused in SS
v_ss_spritesettings:	ds.b	8*$4F				; sprite mappings/VRAM settings loaded from SS_MapIndex (total $278 bytes)
			ds.b	$188				; unused in SS
v_ss_animations:	ds.b	8*$20				; animation update queue (8 bytes per entry, $20 entries total)
v_ss_animations_end:						; end of animation update queue
	org	$FFFF8000					; (need 32-bit addressing starting at FFFF8000)
v_ss_rotationmatrix:	ds.b	2*2*ss_matrixsize*ss_matrixsize	; rotated X/Y sprite coordinates (words) per visible cell (2*2*$10*$10 = $400 bytes)
			ds.b	$2600				; unused in SS
v_ss_scroll_bubbles:	ds.b	$28				; buffer to store scroll positions for SS background bubbles
			ds.b	$D8				; unused in SS
v_ss_scroll_clouds:	ds.b	$1C				; buffer to store scroll positions for SS background clouds
	dephase

	phase	v_objstate
v_regbuffer:		ds.b	object_size			; stores registers d0-a7 during an error event
v_spbuffer:		ds.l	1				; stores most recent sp address
v_errortype:		ds.b	1				; error type
	dephase


	!org 0
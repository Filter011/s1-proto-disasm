; Sonic the Hedgehog (Prototype)
; Split/Text Disassembly.

; Intended for tab width of 8

; ===========================================================================
; ASSEMBLY OPTIONS:

FixBugs	= 0
;	| If 1, enables various bugfixes across the game and sound driver
;	| See also FixMusicAndSFXDataBugs

AllOptimizations = 0
;	| If 1, enables all optimizations
ZeroOffsetOptimization = 0|AllOptimizations
;	| If 1, makes a handful of zero-offset instructions smaller
PaddingOptimization = 0|AllOptimizations
;	| If 1, removes about 64 KB of various superfluous padding

; ===========================================================================
; AS-specific macros and assembler settings
	cpu 68000
	include "MacroSetup.asm"

; ===========================================================================
; Simplifying macros and functions
	include "Macros.asm"

; ===========================================================================
; Equates section - Names for constants
	include "_Constants.asm"

; ===========================================================================
; Equates section - Names for variables
	include "_Variables.asm"

; ===========================================================================
; Expressing sprite mappings and DPLCs in a portable and human-readable form
SonicMappingsVer = 1
SonicDplcVer = 1
	include	"_maps/_MapMacros.asm"

; ===========================================================================
; start of ROM

StartOfROM:
	if * <> 0
		fatal "StartOfROM was $\{*} but it should be 0"
	endif

Vectors:
		dc.l v_systemstack&$FFFFFF			; Initial stack pointer value
		dc.l EntryPoint					; Start of program
		dc.l BusError					; Bus error
		dc.l AddressError				; Address error (4)
		dc.l IllegalInstr				; Illegal instruction
		dc.l ZeroDivide					; Division by zero
		dc.l ChkInstr					; CHK exception
		dc.l TrapvInstr					; TRAPV exception (8)
		dc.l PrivilegeViol				; Privilege violation
		dc.l Trace					; TRACE exception
		dc.l Line1010Emu				; Line-A emulator
		dc.l Line1111Emu				; Line-F emulator (12)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved) (16)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved) (20)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved) (24)
		dc.l ErrorExcept				; Spurious exception
		dc.l ErrorTrap					; IRQ level 1
		dc.l ErrorTrap					; IRQ level 2
		dc.l ErrorTrap					; IRQ level 3 (28)
		dc.l HBlank					; IRQ level 4 (horizontal retrace interrupt)
		dc.l ErrorTrap					; IRQ level 5
		dc.l VBlank					; IRQ level 6 (vertical retrace interrupt)
		dc.l ErrorTrap					; IRQ level 7 (32)
		dc.l ErrorTrap					; TRAP #00 exception
		dc.l ErrorTrap					; TRAP #01 exception
		dc.l ErrorTrap					; TRAP #02 exception
		dc.l ErrorTrap					; TRAP #03 exception (36)
		dc.l ErrorTrap					; TRAP #04 exception
		dc.l ErrorTrap					; TRAP #05 exception
		dc.l ErrorTrap					; TRAP #06 exception
		dc.l ErrorTrap					; TRAP #07 exception (40)
		dc.l ErrorTrap					; TRAP #08 exception
		dc.l ErrorTrap					; TRAP #09 exception
		dc.l ErrorTrap					; TRAP #10 exception
		dc.l ErrorTrap					; TRAP #11 exception (44)
		dc.l ErrorTrap					; TRAP #12 exception
		dc.l ErrorTrap					; TRAP #13 exception
		dc.l ErrorTrap					; TRAP #14 exception
		dc.l ErrorTrap					; TRAP #15 exception (48)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.b "SEGA MEGA DRIVE "				; Hardware system ID (Console name.)
		dc.b "(C)SEGA 1989.JAN"				; Copyright holder and release date (Year and month.)
	rept 2
		dc.b "                "				; Domestic/International name (Blank, both are identical.)
		dc.b "                "
		dc.b "                "
	endr
		dc.b "GM 00000000-00"				; Serial/version number (Has not been set yet aside from being classed as game.)
Checksum:	dc.w 0						; Checksum
		dc.b "J               "				; I/O support (Only supports 3 button controllers.)
ROMStartLoc:	dc.l StartOfROM					; Start address of ROM
ROMEndLoc:	dc.l EndOfROM-1					; End address of ROM
RAMStartLoc:	dc.l v_ram_start				; Start address of RAM
RAMEndLoc:	dc.l (v_ram_end-1)&$FFFFFF			; End address of RAM
		dc.l $20202020					; SRAM (none)
		dc.l $20202020					; SRAM start ($200001)
		dc.l $20202020					; SRAM end ($20xxxx)
Notes:		dc.b "                                                    " ; Notes (Unused, anything can be put in this space, but it has to be 52 bytes.)
		dc.b "JU              "				; Region (Country code. Oddly, there's no European region set, although, it can still be played in those regions.)
EndOfHeader:

; ===========================================================================
; Crash/Freeze the 68000.
ErrorTrap:
		nop						; no operation
		nop						; ''
		bra.s	ErrorTrap				; loop forever
; ===========================================================================

; ---------------------------------------------------------------------------
; Entry point for the game on boot or soft-reset
; (This section from a standard Mega Drive devkit library)
; ---------------------------------------------------------------------------

EntryPoint:
		tst.l	(port_1_control_hi).l			; test port A & B control registers

SkipSetup:
		bne.w	GameProgram				; if either of them are already initialized, branch
		tst.w	(expansion_control_hi).l		; test port C control register
		bne.s	SkipSetup				; if any port was already initialized, skip the VDP and Z80 setup code (this is a soft-reset)

		lea	SetupValues(pc),a5			; load setup values array address
		movem.l	(a5)+,d5-a4				; d5 = VDP register start number; d6 = size of RAM/4; d7 = VDP register diff;a0 = start of Z80 RAM; a1 = Z80 bus request; a2 = Z80 reset; a3 = VDP data; a4 = VDP control

		move.w	console_version-1-z80_bus_request(a1),d0 ; get hardware version (from $A10001)
		andi.w	#$F<<8,d0				; only look at Mega Drive version
		beq.s	SkipSecurity				; if the console has no TMSS, skip the security stuff
		move.l	#"SEGA",security_addr-z80_bus_request(a1) ; write "SEGA" to TMSS security register ($A14000)

SkipSecurity:
		move.w	(a4),d0					; clear write-pending flag in VDP (prevents issues if 68k was reset while writing a command to VDP)
		moveq	#0,d0
		movea.l	d0,a6
		move.l	a6,usp					; set usp to $0

		moveq	#SetupValues_VDP_End-SetupValues_VDP-1,d1 ; write to all VDP registers
VDPInitLoop:	move.b	(a5)+,d5				; add $8000 to value
		move.w	d5,(a4)					; write value to VDP register
		add.w	d7,d5					; next register
		dbf	d1,VDPInitLoop				; loop until all registers are set up

		move.l	#$40000080,(a4)				; write DMA destination to VDP (VRAM 0000)
		move.w	d0,(a3)					; set DMA fill value to 00 (DMA starts here, clears entire VRAM)

		move.w	d7,(a1)					; stop the Z80
		move.w	d7,(a2)					; reset the Z80
WaitForZ80:	btst	d0,(a1)					; has the Z80 stopped?
		bne.s	WaitForZ80				; if not, loop until it has

		moveq	#SetupValues_Z80_End-SetupValues_Z80-1,d2 ; write all Z80 boot code
Z80InitLoop:	move.b	(a5)+,(a0)+				; write boot code to Z80 RAM
		dbf	d2,Z80InitLoop				; loop until all boot code has been written

		move.w	d0,(a2)					; set Z80 reset on
		move.w	d0,(a1)					; set Z80 stop off
		move.w	d7,(a2)					; set Z80 reset off

ClrRAMLoop:	move.l	d0,-(a6)				; clear 4 bytes of RAM
		dbf	d6,ClrRAMLoop				; repeat until the entire RAM is cleared

		move.l	#($8100+%0100)<<16|$8F00+%0010,(a4)	; VDP display mode and VDP increment
		move.l	#$C0000000,(a4)				; CRAM write mode
		moveq	#(palette_size)/4-1,d3

ClrCRAMLoop:	move.l	d0,(a3)
		dbf	d3,ClrCRAMLoop				; repeat until the entire CRAM is clear

		move.l	#$40000010,(a4)				; set VDP to VSRAM write
		moveq	#(vsram_size)/4-1,d4
ClrVSRAMLoop:	move.l	d0,(a3)					; clear 4 bytes of VSRAM
		dbf	d4,ClrVSRAMLoop				; repeat until the entire VSRAM is clear

		moveq	#SetupValues_PSG_End-SetupValues_PSG-1,d5 ; write to all PSG registers
PSGInitLoop:	move.b	(a5)+,psg_input-vdp_data_port-1(a3)	; write PSG volume values to PSG port ($C00011)
		dbf	d5,PSGInitLoop				; repeat for all channels

		move.w	d0,(a2)					; set Z80 reset on
		movem.l	(a6),d0-a6				; clear all registers
		disable_ints					; disable interrupts
		bra.s	GameProgram				; begin actual game
; ===========================================================================

SetupValues:	dc.l $8000					; VDP register start number
		dc.l (v_ram_end-v_ram_start_def)/4-1		; size of RAM/4 ($3FFF)
		dc.l $100					; VDP register diff

		dc.l z80_ram					; start of Z80 RAM
		dc.l z80_bus_request				; Z80 bus request
		dc.l z80_reset					; Z80 reset
		dc.l vdp_data_port				; VDP data
		dc.l vdp_control_port				; VDP control

	SetupValues_VDP:
		; Note that most of these are immediately overwritten again in VDPSetupArray
		dc.b %0100					; VDP $80 - 8-colour mode
		dc.b %00010100					; VDP $81 - Megadrive mode, DMA enable
		dc.b vram_fg>>10				; VDP $82 - foreground nametable address
		dc.b window_plane_icd>>10			; VDP $83 - window nametable address
		dc.b vram_bg>>13				; VDP $84 - background nametable address
		dc.b vram_sprites_icd>>9			; VDP $85 - sprite table address
		dc.b 0						; VDP $86 - unused
		dc.b 0						; VDP $87 - background colour
		dc.b 0						; VDP $88 - unused
		dc.b 0						; VDP $89 - unused
		dc.b 255					; VDP $8A - H_Int register
		dc.b 0						; VDP $8B - full screen scroll
		dc.b %10000001					; VDP $8C - 40 cell display
		dc.b vram_hscroll_icd>>10			; VDP $8D - hscroll table address
		dc.b 0						; VDP $8E - unused
		dc.b 1						; VDP $8F - VDP increment
		dc.b 1						; VDP $90 - 64 cell hscroll size
		dc.b 0						; VDP $91 - window h position
		dc.b 0						; VDP $92 - window v position
		dc.w $FFFF					; VDP $93/94 - DMA length
		dc.w 0						; VDP $95/96 - DMA source
		dc.b %10000000					; VDP $97 - DMA fill VRAM
	SetupValues_VDP_End:

	SetupValues_Z80:
		; Z80 instructions (not the sound driver; that gets loaded later)
		save
		CPU Z80						; start assembling Z80 code
		phase	0					; pretend we're at address 0

	zStartupCodeStartLoc:
		xor	a					; clear a to 0
		ld	bc,(z80_ram_end-z80_ram)-(zStartupCodeEndLoc-zStartupCodeStartLoc)-1 ; prepare to loop this many times
		ld	de,zStartupCodeEndLoc-zStartupCodeStartLoc+1 ; initial destination address
		ld	hl,zStartupCodeEndLoc-zStartupCodeStartLoc ; initial source address
		ld	sp,hl					; set the address the stack starts at
		ld	(hl),a					; set first byte of the stack to 0
		ldir						; loop to fill the stack (entire remaining available Z80 RAM) with 0
		pop	ix					; clear ix
		pop	iy					; clear iy
		ld	i,a					; clear i
		ld	r,a					; clear r
		ex	af,af'					; swap af with af'
		exx						; swap bc/de/hl with their shadow registers too
		pop	af					; clear af
		pop	bc					; clear bc
		pop	de					; clear de
		pop	hl					; clear hl
		ex	af,af'					; swap af with af'
		exx						; swap bc/de/hl with their shadow registers too
		pop	af					; clear af
		pop	de					; clear de
		pop	hl					; clear hl
		ld	sp,hl					; clear sp
		di						; clear iff1 (for interrupt handler)
		im	1					; interrupt handling mode = 1
		ld	(hl),0E9h				; replace the first instruction with a jump to itself
		jp	(hl)	 				; jump to the first instruction (to stay there forever)
	zStartupCodeEndLoc:
		dephase						; stop pretending
		restore
		padding off					; unfortunately our flags got reset so we have to set them again...
	SetupValues_Z80_End:

	SetupValues_PSG:
		dc.b $9F,$BF,$DF,$FF				; values for PSG channel volumes
	SetupValues_PSG_End:
; End of SetupValues


; ===========================================================================
; ---------------------------------------------------------------------------
; Proper game entry point for Sonic the Hedgehog after initialization
; ---------------------------------------------------------------------------

GameProgram:
		btst	#6,(expansion_control).l		; has port C been initialized?
		beq.s	CheckSumCheck				; if not, branch
		cmpi.l	#"init",(v_init).w			; has checksum routine already run?
		beq.w	GameInit				; if yes, branch

CheckSumCheck:
		movea.l	#EndOfHeader,a0				; start checking bytes after the header ($200)
		movea.l	#ROMEndLoc,a1				; stop at end of ROM
		move.l	(a1),d0					; retrieve long of ROM end
		moveq	#0,d1
	.loop:	add.w	(a0)+,d1				; add next byte value of ROM word
		cmp.l	a0,d0					; has iterator reached end of ROM?
		bhs.s	.loop					; if not, loop until so
		movea.l	#Checksum,a1				; read the checksum
		cmp.w	(a1),d1					; compare calculated value with checksum in ROM header
	if 0
		bne.w	CheckSumError				; if they don't match, a checksum error has occurred
	else
		nop						; removed the branch to the checksum error, so the checksum won't throw an error regardless of the value
		nop
	endif

CheckSumOk:
		lea	(v_crossresetram).w,a6			; load cross-reset RAM location
		moveq	#0,d7					; overwrite with 0
		move.w	#(v_ram_end-v_crossresetram)/4-1,d6	; write to all of cross-reset RAM ($FE00-$FFFF)
.clearRAM:	move.l	d7,(a6)+				; clear RAM
		dbf	d6,.clearRAM				; loop until done

		move.b	(console_version).l,d0			; get hardware information from console
		andi.b	#%11000000,d0				; filter to only overseas flag and PAL flag
		move.b	d0,(v_megadrive).w			; store region settings

		move.w	#1,(v_unused12).w			; set an unused flag to 1

		move.l	#"init",(v_init).w			; set flag so checksum won't run again

GameInit:
		lea	(v_ram_start).l,a6			; load start location of RAM
		moveq	#0,d7					; overwrite with 0
		move.w	#(v_crossresetram-v_ram_start_def)/4-1,d6 ; write to all of RAM except cross-reset RAM ($0000-$FDFF)
.clearRAM:	move.l	d7,(a6)+				; clear RAM
		dbf	d6,.clearRAM				; loop until done

		bsr.w	VDPSetupGame				; initialize (proper) VDP registers
		bsr.w	DACDriverLoad				; initialize Z80 DAC driver
		bsr.w	JoypadInit				; initialize controller ports
		move.b	#id_Sega,(v_gamemode).w			; set first Game Mode to Sega Screen

MainGameLoop:
		move.b	(v_gamemode).w,d0			; load Game Mode
		andi.w	#$1C,d0					; limit Game Mode value to $1C max (change to a maximum of 7C to add more game modes)
		jsr	GameModeArray(pc,d0.w)			; jump to apt location in ROM
		bra.s	MainGameLoop				; loop indefinitely
; ===========================================================================
; ---------------------------------------------------------------------------
; Main game mode array
; ---------------------------------------------------------------------------

GameModeArray:

gmptr:		macro gamemode,{INTLABEL}
__LABEL__:	label	*-GameModeArray
		bra.w	gamemode
		endm

id_Sega:	gmptr	GM_Sega					; Sega Screen ($00)
id_Title:	gmptr	GM_Title				; Title Screen ($04)
id_Demo:	gmptr	GM_Level				; Demo Mode ($08)
id_Level:	gmptr	GM_Level				; Normal Level ($0C)
id_Special:	gmptr	GM_Special				; Special Stage ($10)

		rts						; redundant rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Error handler
; ---------------------------------------------------------------------------

; Unused, as the checksum check doesn't care if the checksum is wrong.
ChecksumError:
		bsr.w	VDPSetupGame
		move.l	#$C0000000,(vdp_control_port).l		; Set VDP to CRAM write
		moveq	#(palette_size)/2-1,d7			; write to entire palette
.fillred:	move.w	#cRed,(vdp_data_port).l			; fill palette with red
		dbf	d7,.fillred				; repeat until CRAM is filled
		bra.s	*
; ===========================================================================

BusError:	move.b	#2,(v_errortype).w			; set error code
		bra.s	ErrorHandler_WithAddress		; continue to handler (with pc value)
; ---------------------------------------------------------------------------
AddressError:	move.b	#4,(v_errortype).w			; set error code
		bra.s	ErrorHandler_WithAddress		; continue to handler (with pc value)
; ---------------------------------------------------------------------------
IllegalInstr:	move.b	#6,(v_errortype).w			; set error code
		addq.l	#2,2(sp)				; skip over illegal instruction on recovery
		bra.s	ErrorHandler_WithoutAddress		; continue to handler
; ---------------------------------------------------------------------------
ZeroDivide:	move.b	#8,(v_errortype).w			; set error code
		bra.s	ErrorHandler_WithoutAddress		; continue to handler
; ---------------------------------------------------------------------------
ChkInstr:	move.b	#$A,(v_errortype).w			; set error code
		bra.s	ErrorHandler_WithoutAddress		; continue to handler
; ---------------------------------------------------------------------------
TrapvInstr:	move.b	#$C,(v_errortype).w			; set error code
		bra.s	ErrorHandler_WithoutAddress		; continue to handler
; ---------------------------------------------------------------------------
PrivilegeViol:	move.b	#$E,(v_errortype).w			; set error code
		bra.s	ErrorHandler_WithoutAddress		; continue to handler
; ---------------------------------------------------------------------------
Trace:		move.b	#$10,(v_errortype).w			; set error code
		bra.s	ErrorHandler_WithoutAddress		; continue to handler
; ---------------------------------------------------------------------------
Line1010Emu:	move.b	#$12,(v_errortype).w			; set error code
		addq.l	#2,2(sp)				; skip over illegal instruction on recovery
		bra.s	ErrorHandler_WithoutAddress		; continue to handler
; ---------------------------------------------------------------------------
Line1111Emu:	move.b	#$14,(v_errortype).w			; set error code
		addq.l	#2,2(sp)				; skip over illegal instruction on recovery
		bra.s	ErrorHandler_WithoutAddress		; continue to handler
; ---------------------------------------------------------------------------
ErrorExcept:	move.b	#0,(v_errortype).w			; set error code (generic fallback error)
		bra.s	ErrorHandler_WithoutAddress		; continue to handler
; ===========================================================================

; loc_434:
ErrorHandler_WithAddress:
		disable_ints					; disable interrupts so we stay here
		addq.w	#2,sp					; skip sr value
		move.l	(sp)+,(v_spbuffer).w			; retrieve pc value from before the crash
		addq.w	#2,sp					; skip second sr value
		movem.l	d0-a7,(v_regbuffer).w			; backup all registers values from before the crash

		bsr.w	ShowErrorMessage			; write error text to screen
		move.l	2(sp),d0				; get error address
		bsr.w	ShowErrorValue				; write value to screen
		move.l	(v_spbuffer).w,d0			; get origin pc value
		bsr.w	ShowErrorValue				; write value to screen
		bra.s	ErrorHandler_TryRecovery		; skip over
; ===========================================================================

; loc_45C:
ErrorHandler_WithoutAddress:
		disable_ints					; disable interrupts so we stay here
		movem.l	d0-a7,(v_regbuffer).w			; backup all registers values from before the crash

		bsr.w	ShowErrorMessage			; write error text to screen
		move.l	2(sp),d0				; load error address
		bsr.w	ShowErrorValue				; write value to screen
; ---------------------------------------------------------------------------

; loc_472:
ErrorHandler_TryRecovery:
		bsr.w	ErrorWaitForC				; loop until C has been pressed
		movem.l	(v_regbuffer).w,d0-a7			; restore registers before exception
		enable_ints					; enable ints
		rte						; try resuming normal operation (may or may not work, depending on type of crash)
; ===========================================================================

ShowErrorMessage:
		lea	(vdp_data_port).l,a6			; set VDP data port
		locVRAM	ArtTile_Error_Handler_Font*tile_size	; set target VRAM location for error text font
		lea	(Art_Text).l,a0				; load error text font
		move.w	#(Art_Text_end-Art_Text-tile_size)/2-1,d1 ; load font (strangely, this does not load the final tile)
.loadgfx:	move.w	(a0)+,(a6)				; dump graphics to VRAM
		dbf	d1,.loadgfx				; loop until font has been loaded

		moveq	#0,d0
		move.b	(v_errortype).w,d0			; load error code
		move.w	ErrorText(pc,d0.w),d0			; find offset in error texts array
		lea	ErrorText(pc,d0.w),a0			; load error text for error code
		locVRAM	vram_fg+(12*$80)+(2*2)			; write error message directly to plane A nametable (row 12 + column 2 = $C04)
		moveq	#19-1,d1				; number of characters in error text message (minus 1)
.showchars:	moveq	#0,d0
		move.b	(a0)+,d0				; get next character from error text
		addi.w	#-'0'+ArtTile_Error_Handler_Font,d0	; rebase from ASCII to a VRAM index
		move.w	d0,(a6)					; write to VRAM
		dbf	d1,.showchars				; repeat for number of characters
		rts
; End of function ShowErrorMessage
; ===========================================================================

ErrorText:	dc.w .exception-ErrorText			; 0
		dc.w .bus-ErrorText				; 2
		dc.w .address-ErrorText				; 4
		dc.w .illinstruct-ErrorText			; 6
		dc.w .zerodivide-ErrorText			; 8
		dc.w .chkinstruct-ErrorText			; $A
		dc.w .trapv-ErrorText				; $C
		dc.w .privilege-ErrorText			; $E
		dc.w .trace-ErrorText				; $10
		dc.w .line1010-ErrorText			; $12
		dc.w .line1111-ErrorText			; $14

.exception:	dc.b "ERROR EXCEPTION    "
.bus:		dc.b "BUS ERROR          "
.address:	dc.b "ADDRESS ERROR      "
.illinstruct:	dc.b "ILLEGAL INSTRUCTION"
.zerodivide:	dc.b "@ERO DIVIDE        "			; Note: @ is Z due to the font arrangement
.chkinstruct:	dc.b "CHK INSTRUCTION    "
.trapv:		dc.b "TRAPV INSTRUCTION  "
.privilege:	dc.b "PRIVILEGE VIOLATION"
.trace:		dc.b "TRACE              "
.line1010:	dc.b "LINE 1010 EMULATOR "
.line1111:	dc.b "LINE 1111 EMULATOR "
		even

; ===========================================================================

; Input: d0 = number to write (8 digits)
ShowErrorValue:
		move.w	#ArtTile_Error_Handler_Font+$A,(a6)	; display "$" symbol
		moveq	#8-1,d2					; write 8 digits
	.loop:	rol.l	#4,d0					; shift to next digit
		bsr.s	.writeDigit				; write number to VRAM
		dbf	d2,.loop				; loop until done
		rts
; ---------------------------------------------------------------------------

.writeDigit:
		move.w	d0,d1					; make a copy (need to preserve d0 for the loop)
		andi.w	#$F,d1					; limit digit to one nybble
		cmpi.w	#$A,d1					; is digit $A-$F?
		blo.s	.write					; if not, branch
		addq.w	#7,d1					; adjust tile offset for hex letters
	.write:	addi.w	#ArtTile_Error_Handler_Font,d1		; add art tile offset
		move.w	d1,(a6)					; write to VRAM nametable
		rts
; End of function ShowErrorValue
; ===========================================================================

ErrorWaitForC:
		bsr.w	ReadJoypads				; keep reading joypads
		cmpi.b	#btnC,(v_jpadpress1).w			; has button C been pressed?
		bne.w	ErrorWaitForC				; if not, keep looping
		rts						; return to try recovering execution
; End of function ErrorWaitForC
; End of error handler (as a whole)


; ===========================================================================
; ---------------------------------------------------------------------------
; Uncompressed art text for debug mode, level select, and errors
; (formerly "menutext.bin")
; ---------------------------------------------------------------------------

Art_Text:	bincludeEndMarker	"artunc/Level Select & Debug Text.unc"


; ===========================================================================
; ---------------------------------------------------------------------------
; Vertical interrupt
; ---------------------------------------------------------------------------

VBlank:
		movem.l	d0-a6,-(sp)				; backup all registers except stack pointer (a7)

		tst.b	(v_vblank_routine).w			; was a VBlank routine set?
		beq.s	VBlank_Exit

		move.w	(vdp_control_port).l,d0			; clear write-pending flag in VDP (prevents issues if 68k was reset while writing a command to VDP)
		move.l	#$40000010,(vdp_control_port).l		; set VDP to VSRAM write mode
		move.l	(v_scrposy_vdp).w,(vdp_data_port).l	; send screen y-axis pos. to VSRAM

		; Wait here in a loop doing nothing for a while. This seems to be a pretty harsh attempt
		; to push CRAM dots outside of the visible view area, due to Sonic 1 not using all
		; the available screen space PAL offers, as they would otherwise be seen at the bottom.
		btst	#6,(v_megadrive).w			; are we on a PAL machine?
		beq.s	.notPAL					; if not, branch
		move.w	#$700,d0				; intentionally lag the control port to move the CRAM dots on PAL machines
	.waitPAL:
		dbf	d0,.waitPAL

.notPAL:
		move.b	(v_vblank_routine).w,d0			; copy specified VBlank routine to d0
		move.b	#id_VBlank_00,(v_vblank_routine).w		; reset actual routine to return
		move.w	#1,(f_hblank).w				; set HInt flag (unused)
		andi.w	#$3E,d0					; mask out irrelevant bits in VBlank routine
		move.w	VBlank_Index(pc,d0.w),d0			; load address to relevant VBlank routine
		jsr	VBlank_Index(pc,d0.w)			; jump to VBlank routine and then return here

VBlank_Exit:
		addq.l	#1,(v_vblank_count).w			; increment VBlank counter
		jsr	(UpdateMusic).l				; run sound driver to advance music
		movem.l	(sp)+,d0-a6				; restore all backed-up registers
		rte						; return from interrupt and resume normal operation

; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 00 - Return to caller
; ---------------------------------------------------------------------------

VBlank_00:
		rts
; ===========================================================================
VBlank_Index:

vbptr:		macro vblankmode,{INTLABEL}
__LABEL__:	label	*-VBlank_Index
		dc.w	vblankmode-VBlank_Index
		endm

id_VBlank_00:	vbptr	VBlank_00				; $00 - (return to caller)
id_VBlank_02:	vbptr	VBlank_02				; $02 - Sega Screen
id_VBlank_04:	vbptr	VBlank_04				; $04 - Title Screen
id_VBlank_06:	vbptr	VBlank_06				; $06 - (unused)
id_VBlank_08:	vbptr	VBlank_08				; $08 - Levels, Demos
id_VBlank_0A:	vbptr	VBlank_0A				; $0A - Special Stage
id_VBlank_0C:	vbptr	VBlank_0C				; $0C - Title Cards
id_VBlank_0E:	vbptr	VBlank_0E				; $0E - (unused)
id_VBlank_10:	vbptr	VBlank_10				; $10 - Paused
id_VBlank_12:	vbptr	VBlank_12				; $12 - Palette Fade
; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 02 - Sega Screen
; ---------------------------------------------------------------------------

VBlank_02:
		bsr.w	VBlank_StandardTransfers		; do standard screen transfers
		tst.w	(v_generictimer).w			; is generic timer set?
		beq.w	.end					; if not, branch
		subq.w	#1,(v_generictimer).w			; decrement generic timer
	.end:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 04 - Title Screen, Level Select
; ---------------------------------------------------------------------------

VBlank_04:
		bsr.w	VBlank_StandardTransfers		; do standard screen transfers
		bsr.w	LoadTilesAsYouMove_BGOnly		; update background tiles as title screen scrolls
		bsr.w	ProcessPLC_9Tiles			; decompress up to 9 Nemesis-compressed tiles

		tst.w	(v_generictimer).w			; is generic timer set?
		beq.w	.end					; if not, branch
		subq.w	#1,(v_generictimer).w			; decrement generic timer
	.end:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 06 - Unused
; ---------------------------------------------------------------------------

VBlank_06:
		bsr.w	VBlank_StandardTransfers		; do standard screen transfers
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 10 - While game is paused
; ---------------------------------------------------------------------------

VBlank_10:
		cmpi.b	#id_Special,(v_gamemode).w		; is game on special stage?
		beq.w	VBlank_0A				; if yes, branch
		; fall-through...

; ---------------------------------------------------------------------------
; VBlank 08 - Levels and Demos
; ---------------------------------------------------------------------------

VBlank_08:
		bsr.w	ReadJoypads				; read joypads and update buffered inputs in RAM
		stopZ80						; request Z80 stop
		waitZ80						; wait until Z80 has stopped

		writeCRAM	v_palette,0			; write palette buffer to CRAM
		writeVRAM	v_hscrolltablebuffer,vram_hscroll ; transfer H-scroll buffer table to actual H-scroll VRAM

		move.w	#vreg_bgvram|vram_bg>>13,(a5)		; set vram for background plane register
		move.w	(v_hblank_hreg).w,(a5)			; write HBlank trigger scan line for water palette swap to VDP
		move.w	(v_bg3scrposy_vdp).w,(v_bg3scrposy_vdp_dup).w

		writeVRAM	v_spritetablebuffer,vram_sprites  ; transfer sprite buffer table to actual sprites VRAM

		tst.b	(f_sonframechg).w			; has Sonic's sprite changed?
		beq.s	.nochg					; if not, branch
		writeVRAM	v_sgfx_buffer,ArtTile_Sonic*tile_size ; load new Sonic gfx
		move.b	#0,(f_sonframechg).w			; clear Sonic gfx update flag
	.nochg:

		startZ80					; restart Z80
		bsr.w	LoadTilesAsYouMove			; update level tiles while screen is moving
		jsr	(AnimateLevelGfx).l			; updated animated tiles
		jsr	(UpdateHUD).l				; update HUD data
		bsr.w	ProcessPLC_3Tiles			; decompress up to 3 Nemesis-compressed tiles (instead of the usual 9)
		moveq	#0,d0
		move.b	(v_lvlcount).w,d0			; get level counter
		move.b	(v_lvlcount2).w,d1			; get secondary level counter
		cmp.b	d0,d1					; compare level counters
		bhs.s	.higherorequal				; if higher or equal, branch
		move.b	d0,(v_lvlcount2).w			; send level counter value to secondary level counter
	.higherorequal:

		move.b	#0,(v_lvlcount).w			; clear level counter
		tst.w	(v_generictimer).w			; is generic timer set?
		beq.w	.end					; if not, branch
		subq.w	#1,(v_generictimer).w			; decrement generic timer
	.end:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 0A - Special Stages
; ---------------------------------------------------------------------------

VBlank_0A:
		bsr.w	ReadJoypads				; read joypads and update buffered inputs in RAM
		stopZ80						; request Z80 stop
		waitZ80						; wait until Z80 has stopped
		writeCRAM	v_palette,0			; write palette buffer to CRAM
		writeVRAM	v_spritetablebuffer,vram_sprites  ; transfer sprite buffer table to actual sprites VRAM
		writeVRAM	v_hscrolltablebuffer,vram_hscroll ; transfer H-scroll buffer table to actual H-scroll VRAM
		startZ80					; restart Z80

		bsr.w	PalCycle_SS				; advance special stage palette cycle and animate bird/fish graphics

		tst.b	(f_sonframechg).w			; has Sonic's sprite changed?
		beq.s	.nochg					; if not, branch
		writeVRAM	v_sgfx_buffer,ArtTile_Sonic*tile_size ; load new Sonic gfx
		move.b	#0,(f_sonframechg).w			; clear Sonic gfx update flag
	.nochg:

		tst.w	(v_generictimer).w			; is generic timer set?
		beq.w	.end					; if not, branch
		subq.w	#1,(v_generictimer).w			; decrement generic timer
	.end:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 0C - While title cards are displayed (Levels)
; ---------------------------------------------------------------------------

VBlank_0C:
		bsr.w	ReadJoypads				; read joypads and update buffered inputs in RAM
		stopZ80						; request Z80 stop
		waitZ80						; wait until Z80 has stopped
		writeCRAM	v_palette,0			; write palette buffer to CRAM
		writeVRAM	v_spritetablebuffer,vram_sprites  ; transfer sprite buffer table to actual sprites VRAM
		writeVRAM	v_hscrolltablebuffer,vram_hscroll ; transfer H-scroll buffer table to actual H-scroll VRAM
		tst.b	(f_sonframechg).w			; has Sonic's sprite changed?
		beq.s	.nochg					; if not, branch
		writeVRAM	v_sgfx_buffer,ArtTile_Sonic*tile_size ; load new Sonic gfx
		move.b	#0,(f_sonframechg).w			; clear Sonic gfx update flag
	.nochg:

		startZ80					; restart Z80
		bsr.w	LoadTilesAsYouMove
		jsr	(AnimateLevelGfx).l
		jsr	(UpdateHUD).l
		bsr.w	ProcessPLC_9Tiles			; decompress up to 9 Nemesis-compressed tiles
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 0E - Unused
; ---------------------------------------------------------------------------

VBlank_0E:
		bsr.w	VBlank_StandardTransfers		; do standard screen transfers
		bsr.w	ExecuteObjects
		bsr.w	BuildSprites
		addq.b	#1,(v_lvlcount).w			; increase level counter
		move.b	#id_VBlank_0E,(v_vblank_routine).w	; set itself to land back here again if not further altered
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 12 - During palette fades
; ---------------------------------------------------------------------------

VBlank_12:
		bsr.w	VBlank_StandardTransfers		; do standard screen transfers
		bra.w	ProcessPLC_9Tiles			; decompress up to 9 Nemesis-compressed tiles
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to perform standard VRAM transfers (palette, sprites, H-scroll)
; ---------------------------------------------------------------------------

VBlank_StandardTransfers:
		bsr.w	ReadJoypads				; read joypads and update buffered inputs in RAM
		stopZ80						; request Z80 stop
		waitZ80						; wait until Z80 has stopped
		writeCRAM	v_palette,0			; write palette buffer to CRAM
		writeVRAM	v_spritetablebuffer,vram_sprites  ; transfer sprite buffer table to actual sprites VRAM
		writeVRAM	v_hscrolltablebuffer,vram_hscroll ; transfer H-scroll buffer table to actual H-scroll VRAM
		startZ80					; restart Z80
		rts
; End of function VBla_StandardTransfers

; ===========================================================================
; ---------------------------------------------------------------------------
; Horizontal interrupt (unused)
; Transfers 68K fading palette to CRAM.
; ---------------------------------------------------------------------------

HBlank:
		tst.w	(f_hblank).w				; is hblank flag enabled?
		beq.s	.return					; if not, branch

		move.l	a5,-(sp)				; backup a5 register
		writeCRAM	v_palette_fading,0		; write fading palette buffer to CRAM
		movem.l	(sp)+,a5				; pop register from stack

		move.w	#0,(f_hblank).w				; clear hblank flag

.return:
		rte						; return from horizontal interrupt and resume normal operation
; End of function HBlank


; ===========================================================================
; ---------------------------------------------------------------------------
; Secondary horizontal interrupt (unused)
; Initializes background plane and sprite locations, loads sprites into VRAM,
; transfers sprite table into sprite VRAM.
; ---------------------------------------------------------------------------

HBlank2:
		tst.w	(f_hblank).w				; is hblank flag enabled?
		beq.s	.return					; if not, branch

		movem.l	d0/a0/a5,-(sp)				; backup d0, a0 and a5 registers
		move.w	#0,(f_hblank).w				; clear hblank flag
		move.w	#vreg_bgvram|(vram_win>>13),(vdp_control_port).l ; set background nametable address
		move.w	#vreg_spritevram|(vram_sprites>>9),(vdp_control_port).l	; set sprite table address
		locVRAM vram_sprites				; set VRAM target location to sprite table
		lea	(v_spritetablebuffer).w,a0		; load sprite table buffer to a0
		lea	(vdp_data_port).l,a5			; load VDP data port to a5
		move.w	#(v_spritetablebuffer_end-v_spritetablebuffer)/4-1,d0 ; set repeat times

.spriteTableToVDP:
		move.l	(a0)+,(a5)				; move sprite table buffer to VDP data port
		dbf	d0,.spriteTableToVDP			; repeat until the entirety of the sprite table buffer has been written

		movem.l	(sp)+,d0/a0/a5				; restore d0, a0 and a5

.return:
		rte						; return from horizontal interrupt and resume normal operation
; End of function HBlank2


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to initialise joypads (run once during boot)
; ---------------------------------------------------------------------------

JoypadInit:
		stopZ80						; request Z80 stop on
		waitZ80						; wait until it has stopped
		moveq	#$40,d0					; prepare initialise value
		move.b	d0,(port_1_control).l			; init port 1 (joypad 1)
		move.b	d0,(port_2_control).l			; init port 2 (joypad 2)
		move.b	d0,(expansion_control).l		; init port 3 (expansion/extra)
		startZ80					; request Z80 stop off
		rts
; End of function JoypadInit

; ---------------------------------------------------------------------------
; Subroutine to read joypad input, and send it to the RAM
; ---------------------------------------------------------------------------

ReadJoypads:
		stopZ80						; request Z80 stop on
		waitZ80						; wait until it has stopped
		lea	(v_jpadhold1).w,a0			; address where joypad states are written
		lea	(port_1_data).l,a1			; first joypad port
		bsr.s	.read					; do the first joypad
		addq.w	#2,a1					; do the second joypad (port_2_data)
		bsr.s	.read					; second joypad port
		startZ80					; request Z80 stop off
		rts

.read:
		move.b	#0,(a1)					; read A and Start input (TH poll low)
		nop						; wait a bit
		nop						; ''
		move.b	(a1),d0					; write A and Start input states to d0

		lsl.b	#2,d0					; move A and Start to topmost bits
		andi.b	#%11000000,d0				; clear all other inputs from the poll

		move.b	#$40,(a1)				; read D-Pad, B, and C input (TH poll high)
		nop						; wait a bit
		nop						; ''
		move.b	(a1),d1					; write D-Pad, B, and C input states to d1

		andi.b	#%00111111,d1				; clear all other inputs from the poll
		or.b	d1,d0					; merge but poll results into d0
		not.b	d0					; flip bits so that 0=released and 1=pressed

		move.b	(a0),d1					; get buttons pressed the previous frame
		eor.b	d0,d1					; XOR with buttons pressed this frame

		move.b	d0,(a0)+				; write HELD buttons
		and.b	d0,d1					; find buttons pressed this frame
		move.b	d1,(a0)+				; write PRESSED buttons
		rts						; return to VBlank routine
; End of function ReadJoypads


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to setup the VDP with values used for the game itself
; ---------------------------------------------------------------------------

VDPSetupGame:
		lea	(vdp_control_port).l,a0			; load VDP control port
		lea	(vdp_data_port).l,a1			; load VDP data port
		lea	(VDPSetupArray).l,a2			; load address of register values
		moveq	#(VDPSetupArray_End-VDPSetupArray)/2-1,d7 ; set repeat times
.setreg:
		move.w	(a2)+,(a0)				; save register value to VDP
		dbf	d7,.setreg				; repeat until all register values have been sent

		move.w	(VDPSetupArray+2).l,d0			; get second entry of VDPSetupArray
		move.w	d0,(v_vdp_buffer1).w			; buffer register $81 (used for enabling/disabling display)

		moveq	#cBlack,d0				; set d0 to 0 (black)
		move.l	#$C0000000,(vdp_control_port).l		; set VDP to CRAM write
		move.w	#(palette_size)/2-1,d7			; set repeat times to cover full CRAM
.clrCRAM:
		move.w	d0,(a1)					; clear colours
		dbf	d7,.clrCRAM				; repeat until the entire palette is clear (black)

		clr.l	(v_scrposy_vdp).w			; clear single vertical scroll buffer
		clr.l	(v_scrposx_vdp).w			; clear single horizontal scroll buffer
		move.l	d1,-(sp)				; store d1 data in the stack for now
		fillVRAM 0,0,$10000				; clear the entirety of VRAM
		move.l	(sp)+,d1				; reload d1 data back out of the stack
		rts
; End of function VDPSetupGame

; ---------------------------------------------------------------------------
; VDP register settings to use for the game. Do note that a handful of these
; are getting rewritten for every game mode change, though the majority
; will stay at their initial settings defined in this array.
; ---------------------------------------------------------------------------
; See here for details on VDP registers:
; https://segaretro.org/Sega_Mega_Drive/VDP_registers
; ---------------------------------------------------------------------------

VDPSetupArray:
		dc.w vreg_mode1|%000100				; 8-color mode
		dc.w vreg_mode2|%00110100			; vertical interrupts, DMA, Mega Drive display
		dc.w vreg_fgvram|(vram_fg>>10)			; foreground nametable address
		dc.w vreg_winvram|(vram_win>>10)		; window nametable address
		dc.w vreg_bgvram|(vram_bg>>13)			; background nametable address
		dc.w vreg_spritevram|(vram_sprites>>9)		; sprite table address
		dc.w $8600					; (unused, only relevant for 128KB VRAM mode)
		dc.w vreg_bgcolor|0<<4|0			; background colour (palette line 0, entry 0)
		dc.w $8800					; (unused, only relevant for Master System)
		dc.w $8900					; (unused, only relevant for Master System)
		dc.w vreg_hintrate|$00				; horizontal interrupt register
		dc.w vreg_mode3|%0000				; full-screen vertical scrolling
		dc.w vreg_mode4|%10000001			; 40-cell display mode
		dc.w vreg_hscrollvram|(vram_hscroll>>10)	; background H-scroll address
		dc.w $8E00					; (unused, only relevant for 128KB VRAM mode)
		dc.w vreg_autoinc|2				; VDP auto-increment size (2)
		dc.w vreg_planesize|%000001			; 64-cell H-scroll size
		dc.w vreg_winxpos|0				; window horizontal position
		dc.w vreg_winypos|0				; window vertical position
VDPSetupArray_End:


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to clear the screen (plane mappings, sprites, and scroll data)
; ---------------------------------------------------------------------------

ClearScreen:
		fillVRAM 0, vram_fg, vram_fg+plane_size_64x32	; clear foreground namespace
		fillVRAM 0, vram_bg, vram_bg+plane_size_64x32	; clear background namespace

		move.l	#0,(v_scrposy_vdp).w			; clear single vertical scroll buffer
		move.l	#0,(v_scrposx_vdp).w			; clear single horizontal scroll buffer

	if FixBugs
		clearRAM v_spritetablebuffer,v_spritetablebuffer_end ; clear sprite table buffer
		clearRAM v_hscrolltablebuffer,v_hscrolltablebuffer_end_padded ; clear H-Scroll table buffer
	else
		; Both of these clear loops clear one more longwords than they should.
		; This will clear the first 4 bytes of v_palette_water and v_objspace, respectively.
		clearRAM v_spritetablebuffer,v_spritetablebuffer_end+4 ; clear sprite table buffer
		clearRAM v_hscrolltablebuffer,v_hscrolltablebuffer_end_padded+4 ; clear H-Scroll table buffer
	endif

		rts
; End of function ClearScreen

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load the DAC driver
; ---------------------------------------------------------------------------

; SoundDriverLoad: <-- old misnomer
DACDriverLoad:
		nop						; delay
		stopZ80						; request Z80 stop on
		deassertZ80Reset				; request Z80 reset off
		lea	(DACDriver).l,a0			; load DAC driver address as source
		lea	(z80_ram).l,a1				; set Z80 RAM address as target
		move.w	#(DACDriver_end-DACDriver)-1,d0

.loadDAC:
		move.b	(a0)+,(a1)+
		dbf	d0,.loadDAC

		moveq	#0,d0
		lea	(z80_ram+zVoiceTblAdr).l,a1		; load zVoiceTblAdr
		move.b	d0,(a1)+				; write 0 to 1FF8
		move.b	#$80,(a1)+				; write $80 to 1FF9 (zVoiceTblAdr = 8000h)
		move.b	#make68kBank($38000),(a1)+		; write unknown bank address $38000 (7) to 1FFA
		move.b	#$80,(a1)+				; write $80 to 1FFB (zBank = 8007h)
		move.b	d0,(a1)+				; write 0 to 1FFC
		move.b	d0,(a1)+				; write 0 to 1FFD
		move.b	d0,(a1)+				; write 0 to 1FFE
		move.b	d0,(a1)+				; write 0 to 1FFF
		assertZ80Reset					; request Z80 reset on
		nop						; delay (while the Z80 resets)
		nop						; ''
		nop						; ''
		nop						; ''
		deassertZ80Reset				; request Z80 reset off
		startZ80					; request Z80 stop off
		rts
; End of function DACDriverLoad

; ---------------------------------------------------------------------------
; Unused bytes.
; My thought is that these are external variables for a Z80 Sound Driver (which doesn't exist here).
; ---------------------------------------------------------------------------
;unk_119C:
		dc.b 3
		dc.b 0
		dc.w little_endian($1400)
		dc.b 0
		dc.b 0
		dc.b 0
		dc.b 0

; ===========================================================================
; >>> Subroutines to queue sound commands to be executed by the sound driver during VBlank
	; includes QueueSound1, QueueSound2, QueueSound3
	; (formerly called PlaySound, PlaySound_Special, PlaySound_Unknown)
	include	"_include/Queue Sound Routines.asm"


; ===========================================================================
; >>> Subroutine to allow pausing the game
	include "_include/PauseGame.asm"


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to copy a tile map from RAM to VRAM namespace

; input:
;	a1 = tile map address
;	d0 = VRAM address
;	d1 = width (cells)
;	d2 = height (cells)
; ---------------------------------------------------------------------------

TilemapToVRAM:
		lea	(vdp_data_port).l,a6			; load VDP data port address
		move.l	#$800000,d4				; prepare plane width size for VDP address advancing (row)

Tilemap_Line:
		move.l	d0,4(a6)				; set the VDP the VRAM write mode with address
		move.w	d1,d3					; load width of rectangle

Tilemap_Cell:
		move.w	(a1)+,(a6)				; copy tile map to VRAM plane space
		dbf	d3,Tilemap_Cell				; repeat for the entire width
		add.l	d4,d0					; advance VDP value address to the next row
		dbf	d2,Tilemap_Line				; repeat for the entire height
		rts
; End of function TilemapToVRAM

; ===========================================================================
; >>> Nemesis decompression algorithm, primarily (but not exclusively) used for PLCs
	include "_include/Decompression/Nemesis Decompression.asm"

; ---------------------------------------------------------------------------
; Subroutine to add entries from a given Pattern Load Cue list ID to the
; PLC decompression queue (decompressed later during VBlank)
; ---------------------------------------------------------------------------
; ARGUMENTS
; d0 = index of PLC list
; ---------------------------------------------------------------------------
; NOTICE: This subroutine does not check for buffer overruns. The programmer
;         (or hacker) is responsible for making sure that no more than
;         16 load requests are copied into the buffer.
;         _________DO NOT PUT MORE THAN 16 LOAD REQUESTS IN A LIST!__________
;         (or if you change the size of Plc_Buffer, the limit becomes (Plc_Buffer_Only_End-Plc_Buffer)/plc_slot_size)
; ---------------------------------------------------------------------------

; LoadPLC:
AddPLC:
		movem.l	a1-a2,-(sp)				; store register data
		lea	(ArtLoadCues).l,a1			; load PLC list address
		add.w	d0,d0					; double for word-based indexing
		move.w	(a1,d0.w),d0				; load correct relative add address
		lea	(a1,d0.w),a1				; add and load actual address of list
		lea	(v_plc_buffer).w,a2			; load PLC process list

.findspace:
		tst.l	(a2)					; is this slot taken?
		beq.s	.copytoRAM				; if not, branch
		addq.w	#plc_slot_size,a2			; advance to next slot
		bra.s	.findspace				; recheck
; ===========================================================================

.copytoRAM:
		move.w	(a1)+,d0				; load size of list
		bmi.s	.return					; if there is no list, branch

.loop:
		move.l	(a1)+,(a2)+				; copy Nemesis art address
		move.w	(a1)+,(a2)+				; copy VRAM location to dump to
		dbf	d0,.loop				; repeat for all entries

.return:
		movem.l	(sp)+,a1-a2				; restore register data
		rts
; End of function AddPLC

; ===========================================================================
; ---------------------------------------------------------------------------
; Identical to AddPLC, but also stops the current PLC process, and loads
; a brand new queue. (The same 16th entry warning as above applies!)
; ---------------------------------------------------------------------------

; LoadPLC2:
NewPLC:
		movem.l	a1-a2,-(sp)				; store register data
		lea	(ArtLoadCues).l,a1			; load PLC list address
		add.w	d0,d0					; double for word-based indexing
		move.w	(a1,d0.w),d0				; load correct relative add address
		lea	(a1,d0.w),a1				; add and load actual address of list
		bsr.s	ClearPLC				; clear the current PLC entries first
		lea	(v_plc_buffer).w,a2			; load PLC process list
		move.w	(a1)+,d0				; load size of list
		bmi.s	.return					; if there is no list, branch

.loop:
		move.l	(a1)+,(a2)+				; copy Nemesis art address
		move.w	(a1)+,(a2)+				; copy VRAM location to dump to
		dbf	d0,.loop				; repeat for all entries

.return:
		movem.l	(sp)+,a1-a2				; restore register data
		rts
; End of function NewPLC

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to clear the pattern load cues
; Clear the pattern load queue ($FFF680 - $FFF700)
; ---------------------------------------------------------------------------

ClearPLC:
		lea	(v_plc_buffer).w,a2			; load PLC process list
		moveq	#(v_plc_buffer_end-v_plc_buffer)/4-1,d0	; set size of list

.loop:
		clr.l	(a2)+					; clear PLC process list
		dbf	d0,.loop				; repeat until entire list is cleared
		rts
; End of function ClearPLC

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	check the PLC buffer and begin decompression if it contains
; anything. ProcessPLC handles the actual decompression during VBlank
; ---------------------------------------------------------------------------

RunPLC:
		tst.l	(v_plc_buffer).w			; are there any PLC entries left to process?
		beq.s	.return					; if not, branch
		tst.w	(v_plc_patternsleft).w			; is a section counter already set (is art already being decompressed)?
		bne.s	.return					; if so, branch

		movea.l	(v_plc_buffer).w,a0			; load address of first entry's art
		lea	(NemPCD_WriteRowToVDP).l,a3		; load address of dumping routine to use (VDP variant)
		lea	(v_ngfx_buffer).w,a1			; load RLE huffman buffer
		move.w	(a0)+,d2				; load number of sections to decompress (Each section is $20 bytes)
		bpl.s	.skipXor				; if this data doesn't use XOR variant, branch
		adda.w	#NemPCD_WriteRowToVDP_XOR-NemPCD_WriteRowToVDP,a3 ; advance to XOR variant
; loc_1404:
.skipXor:
		andi.w	#$7FFF,d2				; clear XOR flag

	if FixBugs=0
		; Relocated to bugfix below
		move.w	d2,(v_plc_patternsleft).w		; save section counter
	endif
		bsr.w	NemDec_BuildCodeTable			; decompress the huffman tree RLE table
		move.b	(a0)+,d5				; load lookup field
		asl.w	#8,d5					; ''
		move.b	(a0)+,d5				; ''
		moveq	#$10,d6					; prepare bit shift counter (shifting up to a word in size)
		moveq	#0,d0
		move.l	a0,(v_plc_buffer).w			; store current entry address
		move.l	a3,(v_plc_ptrnemcode).w			; store dumping routine (XOR/Non-XOR)
		move.l	d0,(v_plc_repeatcount).w		; clear RLE dump counter
		move.l	d0,(v_plc_paletteindex).w		; clear RLE dump nybble
		move.l	d0,(v_plc_previousrow).w		; clear previous XOR dump
		move.l	d5,(v_plc_dataword).w			; store lookup field
		move.l	d6,(v_plc_shiftvalue).w			; store bit shift counter
	if FixBugs
		; Fix a race condition with Pattern Load Cues
		; https://info.sonicretro.org/SCHG_How-to:Fix_a_race_condition_with_Pattern_Load_Cues
		move.w	d2,(v_plc_patternsleft).w		; save section counter
	endif

.return:
		rts
; End of function RunPLC

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to decompress and dump a specified number of Nemesis-compressed
; PLC tiles from the PLC process list to VRAM. These are called from VBlank,
; probably done to smooth out level loading because of how slow Nemesis is.
; (Note: Process"D"PLC is an old misnomer!)
; ---------------------------------------------------------------------------

; sub_1438: ProcessDPLC_9Tiles:
ProcessPLC_9Tiles:
		tst.w	(v_plc_patternsleft).w			; is a section counter set (is art being decompressed)?
		beq.w	ProcessPLC_Return			; if not, branch (nothing to decompress)

		move.w	#9,(v_plc_framepatternsleft).w		; set tile counter to 9 (number of tiles to decompress in a frame)
		moveq	#0,d0
		move.w	(v_plc_buffer_dest).w,d0		; load VRAM address for this frame
		addi.w	#9*tile_size,(v_plc_buffer_dest).w	; increase address for next frame
		bra.s	ProcessPLC				; continue
; ===========================================================================

; sub_1454: ProcessDPLC2: ProcessPLC_3Tiles:
ProcessPLC_3Tiles:
		tst.w	(v_plc_patternsleft).w			; is a section counter set (is art being decompressed)?
		beq.s	ProcessPLC_Return			; if not, branch (nothing to decompress)

		move.w	#3,(v_plc_framepatternsleft).w		; set tile counter to 3 (number of tiles to decompress in a frame)
		moveq	#0,d0
		move.w	(v_plc_buffer_dest).w,d0		; load VRAM address for this frame
		addi.w	#3*tile_size,(v_plc_buffer_dest).w	; increase address for next frame
		; fall-through to ProcessPLC...
; ---------------------------------------------------------------------------

; loc_146C: ProcessPLC:
ProcessPLC:
		lea	(vdp_control_port).l,a4			; load VDP control port address
		lsl.l	#2,d0					; get address MSB bits and send to LSB of long-word
		lsr.w	#2,d0					; send rest back
		ori.w	#$4000,d0				; set mode bits
		swap	d0					; align for VDP port
		move.l	d0,(a4)					; set VDP address/mode
		subq.w	#4,a4					; move a4 down to VDP data port
		movea.l	(v_plc_buffer).w,a0			; load current entry address
		movea.l	(v_plc_ptrnemcode).w,a3			; load dumping routine to use (XOR/Non-XOR)
		move.l	(v_plc_repeatcount).w,d0		; load RLE dump counter
		move.l	(v_plc_paletteindex).w,d1		; load RLE dump nybble
		move.l	(v_plc_previousrow).w,d2		; load previous XOR dump
		move.l	(v_plc_dataword).w,d5			; load lookup field
		move.l	(v_plc_shiftvalue).w,d6			; load bit shift counter
		lea	(v_ngfx_buffer).w,a1			; load RLE huffman buffer

; loc_14A0:
.loop:
		movea.w	#8,a5					; set size of data to decompress (20 bytes, 1 tile)
		bsr.w	NemPCD_NewRow				; continue the decompression
		subq.w	#1,(v_plc_patternsleft).w		; decrease section count by 1
		beq.s	ProcessPLC_ShiftCue			; if decompression is finished, branch
		subq.w	#1,(v_plc_framepatternsleft).w		; decrease tile counter
		bne.s	.loop					; if still running, branch to decompress another tile

		move.l	a0,(v_plc_buffer).w			; store current entry address
		move.l	a3,(v_plc_ptrnemcode).w			; store dumping routine to use (XOR/Non-XOR)
		move.l	d0,(v_plc_repeatcount).w		; store RLE dump counter
		move.l	d1,(v_plc_paletteindex).w		; store RLE dump nybble
		move.l	d2,(v_plc_previousrow).w		; store previous XOR dump
		move.l	d5,(v_plc_dataword).w			; store lookup field
		move.l	d6,(v_plc_shiftvalue).w			; store bit shift counter

ProcessPLC_Return:
		rts
; ===========================================================================

; loc_14D2:
ProcessPLC_ShiftCue:
		lea	(v_plc_buffer).w,a0			; load PLC process list
		moveq	#(v_plc_buffer_only_end-v_plc_buffer-plc_slot_size)/4-1,d0 ; set size of list

; loc_14D8:
.loop:
		move.l	plc_slot_size(a0),(a0)+			; shift contents of PLC buffer up 6 bytes
		dbf	d0,.loop				; repeat til done

	if FixBugs
		; The above code does not properly 'pop' the 16th PLC entry.
		; Because of this, occupying the 16th slot will cause it to
		; be repeatedly decompressed infinitely.
		; Granted, this could be considered more of an optimisation
		; than a bug: treating the 16th entry as a dummy that
		; should never be occupied makes this code unnecessary.
		; Still, the overhead of this code is minimal.
		if (v_plc_buffer_only_end-v_plc_buffer-plc_slot_size)&2
			move.w	plc_slot_size(a0),(a0)
		endif
		clr.l	(v_plc_buffer_only_end-plc_slot_size).w
	endif

		rts
; End of function ProcessPLC

; ===========================================================================
; ---------------------------------------------------------------------------
; Like AddPLC, but instead of adding entries to a queue to be processed later,
; this will decompress and transfer all entries of the given PLC ID's list
; immediately, blocking until it is done. Does not use or affect the queue.
; ---------------------------------------------------------------------------

QuickPLC:
		lea	(ArtLoadCues).l,a1			; load PLC list address
		add.w	d0,d0					; double for word-based indexing
		move.w	(a1,d0.w),d0				; load correct relative add address
		lea	(a1,d0.w),a1				; add and load actual address of list
		move.w	(a1)+,d1				; load size of list

.loop:
		movea.l	(a1)+,a0				; load Nemesis art address
		moveq	#0,d0
		move.w	(a1)+,d0				; load VRAM dump address
		lsl.l	#2,d0					; get address MSB bits and send to LSB of long-word
		lsr.w	#2,d0					; send rest back
		ori.w	#$4000,d0				; set mode bits
		swap	d0					; align for VDP port
		move.l	d0,(vdp_control_port).l			; set VDP address/mode
		bsr.w	NemDec					; decompress the entire entry
		dbf	d1,.loop				; repeat for all entries in the list
		rts
; End of function QuickPLC

; ===========================================================================
; >>> Other decompression algorithms
	include "_include/Decompression/Enigma Decompression.asm"
	include "_include/Decompression/Kosinski Decompression.asm"


; ===========================================================================
; >>> Palette logic routines
	include "_include/PaletteCycle.asm"
	include	"_include/Palette Fading.asm" ; includes "PaletteFadeIn", "PaletteFadeOut"


; ===========================================================================
; ---------------------------------------------------------------------------
; Palette cycling routine - Sega logo
; ---------------------------------------------------------------------------

PalCycle_Sega:
		subq.w	#1,(v_pcyc_time).w			; decrement timer
		bpl.s	.return					; if time remains, branch

		move.w	#3,(v_pcyc_time).w			; reset timer to 3 frames
		move.w	(v_pcyc_num).w,d0			; get cycle number
		bmi.s	.return					; if negative, return
		subq.w	#2,(v_pcyc_num).w			; decrement cycle number by 2
		lea	(Pal_SegaCyc).l,a0			; load Sega palette cycle data
		lea	(v_palette_line_1+(2*2)).w,a1		; target palette line 1, colors 2-B
		adda.w	d0,a0
		move.l	(a0)+,(a1)+				; write 2 colors
		move.l	(a0)+,(a1)+				; write 2 colors
		move.l	(a0)+,(a1)+				; write 2 colors
		move.l	(a0)+,(a1)+				; write 2 colors
		move.l	(a0)+,(a1)+				; write 2 colors
		move.w	(a0)+,(a1)+				; write 1 color

.return:
		rts
; End of function PalCycle_Sega

; ===========================================================================
; >>> Palette cycle data used for Sega screen
Pal_SegaCyc:	binclude	"palette/Cycle - Sega.bin"


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load main palettes into the fading buffer.
; These get displayed once PaletteFadeIn/PaletteWhiteIn is called.

; input:
; d0 = index number for palette
; ---------------------------------------------------------------------------

PalLoad_Fade:
		lea	(Pal_Index).l,a1			; get palette pointers
		lsl.w	#3,d0					; multiply input ID by 8 (size of one palette index entry)
		adda.w	d0,a1					; add to palette index pointer to get relevant palette entry
		movea.l	(a1)+,a2				; get palette data address
		movea.w	(a1)+,a3				; get target RAM address
		adda.w	#v_palette_fading-v_palette,a3		; load to palette fade-in buffer instead of active palette buffer (+$80)
		move.w	(a1)+,d7				; get length of palette data

.loop:
		move.l	(a2)+,(a3)+				; move two colors from palette data to palette buffer RAM
		dbf	d7,.loop				; loop until all colors are loaded
		rts
; End of function PalLoad_Fade

; ---------------------------------------------------------------------------
; Subroutine to directly load main palettes to the active palette.
; Same as PalLoad_Fade, but without adding $80.
; ---------------------------------------------------------------------------

PalLoad:
		lea	(Pal_Index).l,a1			; get palette pointers
		lsl.w	#3,d0					; multiply input ID by 8 (size of one palette index entry)
		adda.w	d0,a1					; add to palette index pointer to get relevant palette entry
		movea.l	(a1)+,a2				; get palette data address
		movea.w	(a1)+,a3				; get target RAM address
		move.w	(a1)+,d7				; get length of palette data

.loop:
		move.l	(a2)+,(a3)+				; move two colors from palette data to palette buffer RAM
		dbf	d7,.loop				; loop until all colors are loaded
		rts
; End of function PalLoad

; ===========================================================================
; >>> Palette pointers and palette binary includes
	include "_include/Palette Index.asm"


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to wait for VBlank routines to complete
; ---------------------------------------------------------------------------

; DelayProgram: <-- old misnomer
; WaitForVBla: <-- old name
WaitForVBlank:
		enable_ints					; enable interrupts so vertical interrupts can occur

.wait:
		tst.b	(v_vblank_routine).w			; has VBlank routine finished?
		bne.s	.wait					; if not, loop until it has
		rts						; resume normal operation
; End of function WaitForVBlank

; ===========================================================================
; >>> Subroutines for generic calculations
	include	"obj/sub RandomNumber.asm"
	include	"obj/sub CalcSine.asm"
	include	"obj/sub CalcSqrt.asm"
	include	"obj/sub CalcAngle.asm"


; ===========================================================================
; ---------------------------------------------------------------------------
; Sega screen
; ---------------------------------------------------------------------------

; SegaScreen:
GM_Sega:
		; fading out from previous game mode
		move.b	#bgm_Fade,d0				; set fade-out music command
		bsr.w	QueueSound2				; fade-out music
		bsr.w	ClearPLC				; stop any potential in-progress PLC
		bsr.w	PaletteFadeOut				; fade-out previous game mode
; ---------------------------------------------------------------------------

		; screen setup and loading patterns
		lea	(vdp_control_port).l,a6			; load VDP control port
		move.w	#vreg_mode1|%000100,(a6)		; use 8-colour mode
		move.w	#vreg_fgvram|(vram_fg>>10),(a6)		; set foreground nametable address
		move.w	#vreg_bgvram|(vram_bg>>13),(a6)		; set background nametable address
		move.w	#vreg_bgcolor|0<<4|0,(a6)		; set background colour (palette entry 0)
		move.w	#vreg_mode3|%0000,(a6)			; full-screen vertical scrolling

		disable_display					; disable screen output
		bsr.w	ClearScreen				; wipe the screen

		locVRAM	ArtTile_Sega_Tiles*tile_size		; set target VRAM location for Sega logo patterns
		lea	(Nem_SegaLogo).l,a0			; load Sega logo patterns
		bsr.w	NemDec					; decompress Nemesis-compressed patterns directly to VRAM

		lea	(v_ram_start).l,a1			; set start of RAM to be used as decompression buffer
		lea	(Eni_SegaLogo).l,a0			; load Sega logo mappings
		move.w	#ArtTile_Sega_Tiles,d0			; set art tile for Sega screen mappings
		bsr.w	EniDec					; decompress Enigma-compressed mappings to RAM buffer

		copyTilemap v_ram_start,vram_fg+$61C,12,4	; transfer decompressed patterns to VRAM (FG plane, Sega logo)

		moveq	#palid_SegaBG,d0			; load Sega screen palette...
		bsr.w	PalLoad					; ...directly to active palette (not fade-in buffer)
		move.w	#40,(v_pcyc_num).w			; set cycle number to 40
		move.w	#0,(v_pal_buffer+$12).w			; clear some palcycle buffer (unused?)
		move.w	#0,(v_pal_buffer+$10).w			; clear some palcycle buffer (unused?)
		move.w	#60*3,(v_generictimer).w		; run Sega screen for 3 seconds
		enable_display					; enable screen output
; ---------------------------------------------------------------------------

Sega_MainLoop:
		move.b	#id_VBlank_02,(v_vblank_routine).w	; set VBlank routine to $02
		bsr.w	WaitForVBlank				; wait for VBlank to finish
		bsr.w	PalCycle_Sega				; run sega logo palette cycle
		tst.w	(v_generictimer).w			; has generic timer reached zero?
		beq.s	.timerfinished				; if so, branch
		andi.b	#btnStart,(v_jpadpress1).w		; check if Start is pressed
		beq.s	Sega_MainLoop				; if not, branch
; ---------------------------------------------------------------------------

.timerfinished:		; transition to title screen
		move.b	#id_Title,(v_gamemode).w		; go to Title screen
		rts						; return to MainGameLoop
; End of function GM_Sega


; ===========================================================================
; ---------------------------------------------------------------------------
; Title screen
; ---------------------------------------------------------------------------

; TitleScreen:
GM_Title:		; fading out from previous game mode
		bsr.w	ClearPLC				; stop any potential in-progress PLC
		bsr.w	PaletteFadeOut				; fade-out previous game mode
; ---------------------------------------------------------------------------

		; screen setup and loading patterns
		lea	(vdp_control_port).l,a6			; load VDP control port
		move.w	#vreg_mode1|%000100,(a6)		; use 8-colour mode
		move.w	#vreg_fgvram|(vram_fg>>10),(a6)		; set foreground nametable address
		move.w	#vreg_bgvram|(vram_bg>>13),(a6)		; set background nametable address
		move.w	#vreg_planesize|%000001,(a6)		; 64-cell hscroll size
		move.w	#vreg_winypos|0,(a6)			; window vertical position
		move.w	#vreg_mode3|%0011,(a6)			; line scroll mode (per-row horizontally, full-screen vertically)
		move.w	#vreg_bgcolor|2<<4|0,(a6)		; set background colour (palette line 2, entry 0)

		disable_display					; disable screen output
		bsr.w	ClearScreen				; wipe the screen
		clearRAM v_objspace				; clear object RAM

		locVRAM	ArtTile_Title_Foreground*tile_size	; set target VRAM location title screen foreground emblem
		lea	(Nem_TitleFg).l,a0			; load title screen foreground emblem patterns
		bsr.w	NemDec					; decompress Nemesis-compressed patterns directly to VRAM

		locVRAM	ArtTile_Title_Sonic*tile_size		; set target VRAM location big Sonic object
		lea	(Nem_TitleSonic).l,a0			; load big Sonic title screen patterns
		bsr.w	NemDec					; decompress Nemesis-compressed patterns directly to VRAM

		lea	(vdp_data_port).l,a6			; load VDP data transfer port
		locVRAM	ArtTile_Level_Select_Font*tile_size,4(a6) ; set target VRAM location for level select font
		lea	(Art_Text).l,a5				; load uncompressed level select font
		move.w	#(Art_Text_end-Art_Text)/2-1,d1		; set loop count for level select
Tit_LoadText:
		move.w	(a5)+,(a6)				; write one row of the level select font to VRAM
		dbf	d1,Tit_LoadText				; loop until it's fully loaded

	if FixBugs
		; Fix title screen position
		; https://info.sonicretro.org/SCHG_How-to:Fix_the_Title_Screen_position_in_Sonic_1
		copyTilemap	Unc_Title,vram_fg+$208,34,22
	else
		copyTilemap	Unc_Title,vram_fg+$206,34,22
	endif

		move.w	#0,(v_debuguse).w			; exit debug mode if necessary
		move.w	#0,(f_demo).w				; disable demo mode
		move.w	#id_GHZ_act1,(v_zone_act).w		; set level to GHZ1 (000)
		bsr.w	LevelSizeLoad				; load level size (will use GHZ1's sizes)
		bsr.w	DeformLayers				; initialize background deformation before fade-in (redundant here)

		locVRAM	ArtTile_Level*tile_size			; set target VRAM location for level patterns
		lea	(Nem_GHZ_1st).l,a0			; load first half of GHZ patterns
		bsr.w	NemDec					; decompress Nemesis-compressed patterns directly to VRAM

		lea	(Blk16_GHZ).l,a0			; load GHZ 16x16 blocks mappings
		lea	(v_16x16).w,a4				; set target buffer for blocks mappings
		move.w	#(v_16x16_end-v_16x16)/4-1,d0

.loadblocks:
		move.l	(a0)+,(a4)+
		dbf	d0,.loadblocks

		lea	(Blk256_GHZ).l,a0			; load GHZ 256x256 mappings
		lea	(v_256x256).l,a1			; set target buffer for chunks mappings
		bsr.w	KosDec					; decompress Kosinski-compressed chunks mappings to buffer

		bsr.w	LevelLayoutLoad				; load level layout for the background

		lea	(vdp_control_port).l,a5			; set VDP control port
		lea	(vdp_data_port).l,a6			; set VDP data port
		lea	(v_bgscrposx).w,a3			; get current background X position
		lea	(v_lvllayout_bg).w,a4			; get location in level layout RAM where background is stored
		move.w	#$4000+(vram_bg-vram_fg),d2		; =$6000 (VRAM write command $4000 + nametable start address relative to vram_fg)
		bsr.w	DrawChunks				; draw initial background layer

		moveq	#palid_Title,d0				; load title screen palette...
		bsr.w	PalLoad_Fade				; ...to fade-in buffer
		move.b	#bgm_Title,d0				; set title screen music
		bsr.w	QueueSound2				; play title screen music
		move.b	#0,(f_debugmode).w			; disable debug mode (cheat remains active though)
		move.w	#376,(v_generictimer).w			; run title screen for 376 frames (6 seconds plus some change)

		move.b	#id_TitleSonic,(v_titlesonic).w		; load big sonic object
		move.b	#id_PSBTM,(v_pressstart).w		; load "PRESS START BUTTON" object
		move.b	#id_PSBTM,(v_ttlsonichide).w		; load title screen HUD object
		move.b	#2,(v_ttlsonichide+obFrame).w		; load object which hides part of Sonic's torso behind the emblem

		moveq	#plcid_Main,d0				; load main patterns (rings, etc.)
		bsr.w	NewPLC					; (these get loaded once for the title screen and then never again, except when exiting Special Stages)
; ---------------------------------------------------------------------------

		; fade-in palette and enter main loop
		enable_display					; enable display
		bsr.w	PaletteFadeIn				; fade-in title screen

; ---------------------------------------------------------------------------
; Title screen main loop
; ---------------------------------------------------------------------------

Tit_MainLoop:
		move.b	#id_VBlank_04,(v_vblank_routine).w	; set VBlank routine to $04
		bsr.w	WaitForVBlank				; wait for VBlank to finish
		bsr.w	ExecuteObjects				; execute title screen objects
		bsr.w	DeformLayers				; run background deformation
		bsr.w	BuildSprites				; display sprites
		bsr.w	PalCycle_Title				; run title screen palette cycle
		bsr.w	RunPLC					; run any potential PLC

		move.w	(v_player+obX).w,d0			; get current title screen position (big Sonic object)
		addq.w	#2,d0					; move it 2px to the right
		move.w	d0,(v_player+obX).w			; write new X position
		cmpi.w	#$1C00,d0				; has Sonic object passed $1C00 on x-axis?
		blo.s	Tit_ChkStartOrDemo			; if not, branch
		; Will never happen due to the short title screen generic timer.
		; This likely was an old failsafe before Demos were introduced.
		move.b	#id_Sega,(v_gamemode).w			; return to Sega screen
		rts
; ===========================================================================

; loc_26E4:
Tit_ChkStartOrDemo:
		tst.w	(v_generictimer).w			; has title screen timer expired?
		beq.w	GotoDemo				; if yes, launch Demo mode
		andi.b	#btnStart,(v_jpadpress1).w		; check if Start is pressed
		beq.w	Tit_MainLoop				; if not, continue looping title screen
		btst	#bitA,(v_jpadhold1).w			; check if A was held while pressing Start
		beq.w	PlayLevel				; if not, begin game by playing normal level
; ---------------------------------------------------------------------------

Tit_EnterLevelSelect:

	if FixBugs
		; Fix the level selects graphics bug
		; https://info.sonicretro.org/SCHG_How-to:Fix_the_Level_Select_graphics_bug
		move.b	#id_VBlank_04,(v_vblank_routine).w	; set VBlank routine to $04
		bsr.w	WaitForVBlank				; run VBlank one extra frame to prevent graphical glitches
	endif

		moveq	#palid_LevelSel,d0			; load level select palette...
		bsr.w	PalLoad					; ...directly to active palette

		clearRAM v_hscrolltablebuffer			; clear H-Scroll buffer
		move.l	d0,(v_scrposy_vdp).w			; clear VSRAM (d0 is still 0)
		disable_ints					; disable interrupts

		lea	(vdp_data_port).l,a6			; prepare VDP data write
		locVRAM	vram_bg					; write to background nametable
		move.w	#plane_size_64x32/4-1,d1		; write full screen
.LevSelClearBG:	move.l	d0,(a6)					; clear background plane
		dbf	d1,.LevSelClearBG			; loop until plane is fully cleared

		bsr.w	LevSelTextLoad				; load level select text before entering main loop

; ---------------------------------------------------------------------------
; Level Select main loop
; ---------------------------------------------------------------------------

LevelSelect:
		move.b	#id_VBlank_04,(v_vblank_routine).w	; set VBlank routine to $04
		bsr.w	WaitForVBlank				; wait for VBlank to finish
		bsr.w	LevSelControls				; update selected line if necessary
		bsr.w	RunPLC					; run any potential PLC
		tst.l	(v_plc_buffer).w			; are any patterns in the PLC still left to be loaded?
		bne.s	LevelSelect				; if yes, block quitting level select until finished
		andi.b	#btnABC+btnStart,(v_jpadpress1).w	; is A, B, C, or Start pressed?
		beq.s	LevelSelect				; if not, loop level select

LevSel_SelectionMade:
		move.w	(v_levselitem).w,d0			; get currently selected line
		cmpi.w	#levsel_sndtest_row,d0			; have you selected item $13 (sound test)?
		bne.s	LevSel_Level_SS				; if not, go to Level/SS subroutine
		move.w	(v_levselsound).w,d0			; get currently selected sound test entry
		addi.w	#$80,d0					; make it $80-based
		; What follows below are workarounds for bugs within the Sound Driver, these can be removed if FixBugs is enabled, but these are kept here for documentation.
	if FixBugs
		cmpi.w	#bgm__Last,d0				; compare the last BGM with the level select sound
		bls.s	.notBGM					; if lower than or same, branch
	else
		; Bug: There's no pointers for BGM ids $92 or $93, so the game crashes when it tries to play them
		cmpi.w	#bgm__Last+2,d0				; compare the last BGM+2 ($93) with the level select sound
		blo.s	.notBGM					; if lower than $93, branch
	endif
		cmpi.w	#sfx__First,d0				; compare the first SFX with the level select sound
		blo.s	LevelSelect				; if lower than SFX, branch

.notBGM:
		bsr.w	QueueSound2				; play selected sound
		bra.s	LevelSelect				; loop level select
; ===========================================================================

LevSel_Level_SS:
		add.w	d0,d0					; double selected line for word-based indexing
		move.w	LevSel_Ptrs(pc,d0.w),d0			; find relevant level pointer from table
		bmi.s	LevelSelect				; if it's an invalid entry, branch back to main loop
		cmpi.w	#id_SS<<8,d0				; check if selected level Special Stage (0700 is used as dummy value)
		bne.s	LevSel_Level				; if not, branch
		move.b	#id_Special,(v_gamemode).w		; set screen mode to $10 (Special Stage)
		rts
; ===========================================================================

LevSel_Level:
		andi.w	#$3FFF,d0				; mask out invalid bits of level number
		btst	#bitB,(v_jpadhold1).w			; is B button held?
		beq.s	.notB					; if not, ignore below
		move.w	#id_GHZ_act4,d0				; set the zone and act to Green Hill Act 4

.notB:
		move.w	d0,(v_zone_act).w			; set new level number (zone and act)

PlayLevel:
		move.b	#id_Level,(v_gamemode).w		; set screen mode to $0C (level)
		move.b	#3,(v_lives).w				; set lives to 3
		moveq	#0,d0
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		move.l	d0,(v_score).w				; clear score
		move.b	#bgm_Fade,d0				; set music fade-out command
		bsr.w	QueueSound2				; fade out music
		rts						; return to MainGameLoop to start level
; End of function GM_Title

; ===========================================================================
; ---------------------------------------------------------------------------
; Level select - level pointers
; ---------------------------------------------------------------------------
; This is just for the pointers. For the text itself, see: LevelMenuText
; ---------------------------------------------------------------------------

LevSel_Ptrs:
		dc.w id_GHZ_act1
		dc.w id_GHZ_act2
		dc.w id_GHZ_act3
		dc.w id_LZ_act1
		dc.w id_LZ_act2
		dc.w id_LZ_act3
		dc.w id_MZ_act1
		dc.w id_MZ_act2
		dc.w id_MZ_act3
		dc.w id_SLZ_act1
		dc.w id_SLZ_act2
		dc.w id_SLZ_act3
		dc.w id_SZ_act1
		dc.w id_SZ_act2
		dc.w id_SZ_act3
		dc.w id_CWZ_act1
		dc.w id_CWZ_act2
		dc.w id_CWZ_act1+$8000	; CWZ3
		dc.w id_SS<<8		; Special Stage (dummy value)
		dc.w id_SS<<8		; Special Stage (Sound Test)
		dc.w $8000
LevSel_PtrsEnd:	even

; ===========================================================================
; ---------------------------------------------------------------------------
; Demo mode loading routine
; ---------------------------------------------------------------------------

GotoDemo:	; wait half a second on the final frame of Sonic's finger wagging before going to demo
		move.w	#30,(v_generictimer).w			; set timeout to 30 frames

; loc_27FE:
GotoDemo_PreDelayLoop:
		move.b	#id_VBlank_04,(v_vblank_routine).w	; set VBlank routine to $04
		bsr.w	WaitForVBlank				; wait for VBlank to finish
		bsr.w	DeformLayers				; run background deformation
		bsr.w	PaletteCycle				; run normal palette cycle routine (this briefly uses GHZ's cycle)
		bsr.w	RunPLC					; run any potential PLC

		move.w	(v_player+obX).w,d0			; get current title screen position (big Sonic object)
		addq.w	#2,d0					; move it 2px to the right
		move.w	d0,(v_player+obX).w			; write new X position
		cmpi.w	#$1C00,d0				; has Sonic object passed $1C00 on x-axis?
		blo.s	GotoDemo_ChkLoop			; if not, branch
		; Will never happen due to the short title screen generic timer.
		; This likely was an old failsafe before Demos were introduced.
		move.b	#id_Sega,(v_gamemode).w			; return to Sega screen
		rts
; ===========================================================================

; loc_282C:
GotoDemo_ChkLoop:
		tst.w	(v_generictimer).w			; has pre-delay timer expired?
		bne.w	GotoDemo_PreDelayLoop			; if not, branch
; ---------------------------------------------------------------------------

		; start loading demo now
		move.b	#bgm_Fade,d0				; set music fade-out command
		bsr.w	QueueSound2				; fade out music

		move.w	(v_demonum).w,d0			; load demo number
		andi.w	#7,d0					; limit to four demo entries
		add.w	d0,d0					; double for word-based indexing
		move.w	Demo_Levels(pc,d0.w),d0			; load level number for demo
		move.w	d0,(v_zone_act).w			; set level for demo

		addq.w	#1,(v_demonum).w			; add 1 to demo number
		cmpi.w	#6,(v_demonum).w			; is demo number less than 6?
		blo.s	GotoDemo_NoReset			; if yes, branch
		move.w	#0,(v_demonum).w			; reset demo number to 0

; loc_2860:
GotoDemo_NoReset:
		move.w	#1,(f_demo).w				; turn demo mode on
		move.b	#id_Demo,(v_gamemode).w			; set screen mode to 08 (demo)
		cmpi.w	#$600,d0				; is level number 0600 (Special Stage dummy value)?
		bne.s	Demo_Level				; if not, branch
		move.b	#id_Special,(v_gamemode).w		; set game mode to $10 (Special Stage)

Demo_Level:
		move.b	#3,(v_lives).w				; set lives to 3
		moveq	#0,d0
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		move.l	d0,(v_score).w				; clear score
		rts
; End of function GotoDemo

; ===========================================================================
; ---------------------------------------------------------------------------
; Levels used in demos
; ---------------------------------------------------------------------------

Demo_Levels:	; previously in "misc/Demo Level Order - Intro.bin"
		dc.w id_GHZ_act1
		dc.w $600
		dc.w id_MZ_act1
		dc.w $600
		dc.w id_SZ_act1
		dc.w $600
		; The demo levels below are unused
		dc.w id_SLZ_act1
		dc.w $600
		dc.w id_MZ_act1
		dc.w $600
		dc.w id_SZ_act1
		dc.w $600
		even

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to change what you're selecting in the level select
; ---------------------------------------------------------------------------

LevSelControls:
		move.b	(v_jpadpress1).w,d1			; get current button presses
		andi.b	#btnUp+btnDn,d1				; is up/down pressed this frame?
		bne.s	LevSel_UpDown				; if yes, branch
		subq.w	#1,(v_levseldelay).w			; if held, subtract 1 from delay until next move
		bpl.s	LevSel_SndTest				; if time remains, branch

LevSel_UpDown:
		move.w	#12-1,(v_levseldelay).w			; reset time delay
		move.b	(v_jpadhold1).w,d1			; get currently held buttons
		andi.b	#btnUp+btnDn,d1				; is up/down held?
		beq.s	LevSel_SndTest				; if not, branch
		move.w	(v_levselitem).w,d0			; get currently selected line
		btst	#bitUp,d1				; is up held?
		beq.s	LevSel_Down				; if not, branch
		subq.w	#1,d0					; move up 1 selection
		bhs.s	LevSel_Down				; if entry is still valid, branch
		moveq	#levsel_line_count-1,d0			; if selection moves below 0, jump to selection last row

LevSel_Down:
		btst	#bitDn,d1				; is down held?
		beq.s	LevSel_Refresh				; if not, branch
		addq.w	#1,d0					; move down 1 selection
		cmpi.w	#levsel_line_count,d0			; is selection past the last one now?
		blo.s	LevSel_Refresh				; if not, branch
		moveq	#0,d0					; if selection moves past the last row, jump to selection 0

LevSel_Refresh:
		move.w	d0,(v_levselitem).w			; set new selection
		bsr.w	LevSelTextLoad				; refresh text
		rts
; ===========================================================================

LevSel_SndTest:
		cmpi.w	#levsel_sndtest_row,(v_levselitem).w	; is sound test row selected?
		bne.s	LevSel_NoMove				; if not, branch
		move.b	(v_jpadpress1).w,d1			; get currently pressed buttons
		andi.b	#btnR+btnL,d1				; is left/right pressed?
		beq.s	LevSel_NoMove				; if not, branch

		move.w	(v_levselsound).w,d0			; get currently selected sound test number
		btst	#bitL,d1				; is left pressed?
		beq.s	LevSel_Right				; if not, branch
		subq.w	#1,d0					; subtract 1 from sound test
		bhs.s	LevSel_Right				; is result still positive? if yes, branch
		moveq	#sfx__Last-$80,d0 			; if sound test moves below 0, set to last entry (non-$80 based)

LevSel_Right:
		btst	#bitR,d1				; is right pressed?
		beq.s	LevSel_Refresh2				; if not, branch
		addq.w	#1,d0					; add 1 to sound test
		cmpi.w	#sfx__Last-$80+1,d0			; is result now past the last entry?
		blo.s	LevSel_Refresh2				; if not, branch
		moveq	#0,d0					; if sound test moves above last entry, set to 0

LevSel_Refresh2:
		move.w	d0,(v_levselsound).w			; set sound test number
		bsr.w	LevSelTextLoad				; refresh text

LevSel_NoMove:
		rts
; End of function LevSelControls

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load level select text
; ---------------------------------------------------------------------------

levsel_line_count:	equ 20	; total number of lines
levsel_line_length:	equ 24	; characters per line
levsel_sndtest_row:	equ levsel_line_count-1  ; row index of the sound test
levsel_sndtest_col:	equ levsel_line_length-8 ; column offset for the sound test number

levsel_start_row:	equ 4	; top tile offset for start position
levsel_start_col:	equ 8	; left tile offset for start position
levsel_vram_main:	equ vram_bg+(levsel_start_row<<7)+(levsel_start_col<<1)	; nametable address in VRAM
levsel_vram_sndtestnum:	equ levsel_vram_main+(levsel_sndtest_row<<7)+(levsel_sndtest_col<<1) ; nametable address for sound test numbers

levsel_white:		equ ArtTile_Level_Select_Font|Tile_Pal4|Tile_Prio ; VRAM setting for white text (non-selected lines)
levsel_yellow:		equ ArtTile_Level_Select_Font|Tile_Pal3|Tile_Prio ; VRAM setting for yellow text (selected line)

; ---------------------------------------------------------------------------

LevSelTextLoad:
		; Write main text in white
		lea	(LevelMenuText).l,a1			; load menu text offset
		lea	(vdp_data_port).l,a6			; prepare VDP data write
		locVRAM	levsel_vram_main,d4			; prepare base VRAM nametable location in d4
		move.w	#levsel_white,d3			; VRAM setting
		moveq	#levsel_line_count-1,d1			; number of lines of text to write
.DrawAll:	move.l	d4,4(a6)				; write to VDP
		bsr.w	LevSel_ChgLine				; draw line of text
		addi.l	#$00800000,d4				; jump to next line
		dbf	d1,.DrawAll				; repeat until all lines are drawn

		; Draw currently selected line in yellow
		moveq	#0,d0
		move.w	(v_levselitem).w,d0			; get currently selected line
		move.w	d0,d1					; back up selected line
		locVRAM	levsel_vram_main,d4			; prepare base VRAM nametable location in d4
		lsl.w	#7,d0					; times $80
		swap	d0					; swap so that line now becomes VRAM nametable offset
		add.l	d0,d4					; add that to base VRAM location
		lea	(LevelMenuText).l,a1			; load menu text offset
	if levsel_line_length=24
		lsl.w	#3,d1					; times 8
		move.w	d1,d0					; copy result
		add.w	d1,d1					; times...
		add.w	d0,d1					; ...3 (because default line length 8 x 3 = 24)
	else
		; The above calculation assumes 24 as line length, we need a different approach if it changes.
		mulu.w	#levsel_line_length,d1			; multiply selected line index by line length
	endif
		adda.w	d1,a1					; add to menu text offset
		move.w	#levsel_yellow,d3 			; prepare selected-line VRAM setting
		move.l	d4,4(a6)				; write to VDP
		bsr.w	LevSel_ChgLine				; recolour selected line

		; Write sound test numbers
		move.w	#levsel_white,d3			; draw numbers in white by default
		cmpi.w	#levsel_sndtest_row,(v_levselitem).w	; is currently selected line the sound test?
		bne.s	LevSel_DrawSnd				; if not, branch
		move.w	#levsel_yellow,d3			; draw numbers in yellow
LevSel_DrawSnd:
		locVRAM	levsel_vram_sndtestnum			; write sound test number position to VRAM
		move.w	(v_levselsound).w,d0			; get currently selected sound test number
		addi.w	#$80,d0					; make sound ID to be drawn $80-based
		move.b	d0,d2					; backup number
		lsr.b	#4,d0					; move first digit to lower nybble
		bsr.w	LevSel_ChgSnd				; draw 1st digit
		move.b	d2,d0					; restore backup
		bsr.w	LevSel_ChgSnd				; draw 2nd digit
		rts
; ===========================================================================

LevSel_ChgSnd:
		andi.w	#$F,d0					; mask out upper nybble
		cmpi.b	#$A,d0					; is digit $A-$F?
		blo.s	.DrawNum				; if not, branch
		addi.b	#7,d0					; use letter characters
.DrawNum:	add.w	d3,d0					; combine number with VRAM setting (white or yellow)
		move.w	d0,(a6)					; send to VRAM
		rts
; ===========================================================================

LevSel_ChgLine:
		moveq	#levsel_line_length-1,d2		; number of characters per line

.LineLoop:	moveq	#0,d0
		move.b	(a1)+,d0				; get current character
		bpl.s	.CharOk					; is it a valid ASCII character? if yes, branch
		move.w	#0,(a6)					; draw a blank character
		dbf	d2,.LineLoop				; loop until all characters are drawn
		rts

.CharOk:	add.w	d3,d0					; combine char with VRAM setting (white or yellow)
		move.w	d0,(a6)					; send to VRAM
		dbf	d2,.LineLoop				; loop until all characters are drawn
		rts
; End of function LevSelTextLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Level select menu text
; ---------------------------------------------------------------------------
; This is just for the actual text. For the level pointers, see: LevSel_Ptrs
; ---------------------------------------------------------------------------

LevelMenuText:
	charset ' ', $FF
	charset '0','9',$00
	charset '$', $0A
	charset '-', $0B
	charset '=', $0C
	charset '>', $0D
	;charset '>', $0E ; there are two right arrows in the font for some reason
	charset 'Y','Z',$0F ; Y and Z come before A-X
	charset 'A','X',$11

		dc.b "GREEN HILL ZONE STAGE 1 "
		dc.b "                STAGE 2 "
		dc.b "                STAGE 3 "
		dc.b "LABYRINTH ZONE  STAGE 1 "
		dc.b "                STAGE 2 "
		dc.b "                STAGE 3 "
		dc.b "MARBLE ZONE     STAGE 1 "
		dc.b "                STAGE 2 "
		dc.b "                STAGE 3 "
		dc.b "STAR LIGHT ZONE STAGE 1X"
		dc.b "                STAGE 2X"
		dc.b "                STAGE 3X"
		dc.b "SPARKLING ZONE  STAGE 1 "
		dc.b "                STAGE 2 "
		dc.b "                STAGE 3 "
		dc.b "CLOCK WORK ZONE STAGE 1 "
		dc.b "                STAGE 2 "
		dc.b "                STAGE 3X"
		dc.b "SPECIAL STAGE           "
		dc.b "SOUND SELECT            "

	if MOMPASS=1
		if *-(levsel_line_count*levsel_line_length)<>LevelMenuText
			warning "LevelMenuText does not match expected line count/length."
		endif
		; disable warning by default
		;if (LevSel_PtrsEnd-LevSel_Ptrs)/2<>levsel_line_count
		;	warning "LevSel_Ptrs does not match expected line count."
		;endif
	endif

	charset
	even

; ===========================================================================
; ---------------------------------------------------------------------------
; Music playlist for the start of a level. Note that restarting the music
; after invincibility has worn off is controlled in MusicList2 (part of
; Sonic's object). Bosses have the post-defeat music hardcoded.
; ---------------------------------------------------------------------------

MusicList:
		dc.b bgm_GHZ		; GHZ
		dc.b bgm_LZ		; LZ
		dc.b bgm_MZ		; MZ
		dc.b bgm_SLZ		; SLZ
		dc.b bgm_SZ		; SZ
		dc.b bgm_CWZ		; CWZ
		even

; ===========================================================================
; ---------------------------------------------------------------------------
; Level
; ---------------------------------------------------------------------------

; Level:
GM_Level:	; fading out from previous game mode
		move.b	#bgm_Fade,d0				; queue music fade-out command
		bsr.w	QueueSound2				; fade out music
; ---------------------------------------------------------------------------

		; load title cards, queue PLCs, setup screen, play music
		locVRAM ArtTile_Title_Card*tile_size		; set VRAM target location for title cards
		lea	(Nem_TitleCard).l,a0			; load title card patterns
		bsr.w	NemDec					; decompress Nemesis-compressed patterns directly to VRAM

		bsr.w	ClearPLC				; clear any remaining PLC entries

		moveq	#0,d0
		move.b	(v_zone).w,d0				; get current Zone ID
		lsl.w	#4,d0					; multiply by $10 (number of bytes per level header entry)
		lea	(LevelHeaders).l,a2			; load level headers
		lea	(a2,d0.w),a2				; get relevant header for current level
		moveq	#0,d0
		move.b	(a2),d0					; get first PLC entry
		beq.s	Level_NoPLC				; if it's null, branch (never the case)
		bsr.w	AddPLC					; load level patterns for current Zone

; loc_2C0A:
Level_NoPLC:
		moveq	#plcid_Main2,d0				; load secondary standard patterns (monitors, etc.)
		bsr.w	AddPLC					; (these can be overwritten by stuff like the sign post art)

		bsr.w	PaletteFadeOut				; fade out from the previous screen
		bsr.w	ClearScreen				; wipe the screen
		lea	(vdp_control_port).l,a6			; load VDP control port
		move.w	#vreg_mode3|%0011,(a6)			; line scroll mode (per-row horizontally, full-screen vertically)
		move.w	#vreg_fgvram|(vram_fg>>10),(a6)		; set foreground nametable address
		move.w	#vreg_bgvram|(vram_bg>>13),(a6)		; set background nametable address
		move.w	#vreg_spritevram|(vram_sprites>>9),(a6)	; set sprite table address
		move.w	#0,(v_unused13).w			; set an unused variable to 0
		move.w	#vreg_hintrate|175,(v_hblank_hreg).w	; set HBlank counter to scanline 175 (even though horizontal interrupts aren't normally used here...)
		move.w	#vreg_mode1|%000100,(a6)		; use 8-colour mode
		move.w	#vreg_bgcolor|2<<4|0,(a6)		; set background colour (line 3; colour 0)

		clearRAM v_objspace				; clear object RAM
		clearRAM v_misc_variables			; clear various miscellaneous RAM
		clearRAM v_timingandscreenvariables		; clear various timing and screen RAM (for animated tiles, etc.)

		moveq	#palid_Sonic,d0				; load Sonic's palette...
		bsr.w	PalLoad					; ...directly to active palette (for title cards)

		moveq	#0,d0
		move.b	(v_zone).w,d0				; get current Zone ID
		lea	(MusicList).l,a1			; load music playlist
		move.b	(a1,d0.w),d0				; get music ID for current level
		bsr.w	QueueSound1				; play music
		move.b	#id_TitleCard,(v_titlecard).w		; load title card object
; ---------------------------------------------------------------------------

Level_TtlCardLoop: ; move in title cards, stay on them until PLCs have finished
		move.b	#id_VBlank_0C,(v_vblank_routine).w ; set VBlank routine to $0C
		bsr.w	WaitForVBlank				; wait until VBlank has finished
		bsr.w	ExecuteObjects				; execute title cards object
		bsr.w	BuildSprites				; build sprites to show title cards
		bsr.w	RunPLC					; decompress level graphics
	if FixBugs=0
		move.w	(v_ttlcardact+obX).w,d0			; get current position of the "ACT" element of the title cards
		cmp.w	(v_ttlcardact+card_mainX).w,d0		; has "ACT" element reached its target position?
		bne.s	Level_TtlCardLoop			; if not, loop until it has
	else
		; Check if *every* title card element has reached their target position.
		; Decompression is normally slow enough that every element is able
		; to reach their target position before it's finished, but if
		; decompression is upgraded with something faster, then the risk
		; of decompression finishing and exiting this loop before all of the title
		; card is finished moving into place is increased.
		lea	(v_titlecard).w,a0			; get title card elements
		moveq	#4-1,d1					; number of title card elements

Level_CheckTtlCard:
		move.w	obX(a0),d0				; get current position of a title card element
		cmp.w	card_mainX(a0),d0			; has this title card element reached its target position?
		bne.s	Level_TtlCardLoop			; if not, loop until it has
		lea	object_size(a0),a0			; next title card element
		dbf	d1,Level_CheckTtlCard			; loop until every element has reached its target position
	endif
		tst.l	(v_plc_buffer).w			; have patterns been fully decompressed and loaded?
		bne.s	Level_TtlCardLoop			; if not, loop until they have
; ---------------------------------------------------------------------------

		; PLCs have finished, load/initialize remaining data

	if FixBugs
		; Do VBlank for one extra frame to provide enough processing time
		; for the remaining data initialization below. Without it, it's
		; possible for VBlank to interrupt in the middle of a transfer,
		; resulting in visual corruption. This will also make title cards
		; smoother should decompression get upgraded with something faster.
		move.b	#id_VBlank_TitleCards,(v_vblank_routine).w ; set VBlank routine to $0C
		bsr.w	WaitForVBlank				; wait until VBlank has finished
	endif

		bsr.w	DebugPosLoadArt				; call a routine that immediately returns (this is a disabled development function)
		jsr	(Hud_Base).l				; load basic HUD graphics (only in levels, not in the ending demos)

		moveq	#palid_Sonic,d0				; load Sonic's palette to fade-in buffer
		bsr.w	PalLoad_Fade				; (doesn't actually do anything, the PalFadeIn_Alt call below skips the first palette line)
		bsr.w	LevelSizeLoad				; load level size and set default level boundaries
		bsr.w	DeformLayers				; initialize background deformation
		bsr.w	LevelDataLoad				; load block mappings and palettes
		bsr.w	LoadAnimatedBlocks			; load animated block mappings
		bsr.w	LoadTilesFromStart			; fully draw the foreground and background once before fade-in
		jsr	(ConvertCollisionArray).l		; call a routine that immediately returns (this is a disabled development function)
		move.l	#Col_GHZ,(v_collindex).w		; load Green Hill's collision
		cmpi.b	#id_LZ,(v_zone).w			; is the current zone Labyrinth?
		bne.s	.notLZ					; if not, go to the next condition
		move.l	#Col_LZ,(v_collindex).w			; load Labyrinth's collision

.notLZ:
		cmpi.b	#id_MZ,(v_zone).w			; is the current zone Marble?
		bne.s	.notMZ					; if not, go to the next condition
		move.l	#Col_MZ,(v_collindex).w			; load Marble's collision

.notMZ:
		cmpi.b	#id_SLZ,(v_zone).w			; is the current zone Star Light?
		bne.s	.notSLZ					; if not, go to the next condition
		move.l	#Col_SLZ,(v_collindex).w		; load Star Light's collision

.notSLZ:
		cmpi.b	#id_SZ,(v_zone).w			; is the current zone Sparkling?
		bne.s	.notSZ					; if not, go to the last condition
		move.l	#Col_SZ,(v_collindex).w			; load Sparkling's collision

.notSZ:
		cmpi.b	#id_CWZ,(v_zone).w			; is the current zone Clock Work?
		bne.s	.notCWZ					; if not, then just skip loading collision
		move.l	#Col_CWZ,(v_collindex).w		; load Clock Work's collision

.notCWZ:
		move.b	#id_SonicPlayer,(v_player).w		; load Sonic object

		move.b	#id_HUD,(v_hud).w			; load HUD object

		btst	#bitA,(v_jpadhold1).w			; is A button held?
		beq.s	loc_2D54				; if not, branch
		move.b	#1,(f_debugmode).w			; enable debug mode

loc_2D54:
		move.w	#0,(v_jpadhold2).w			; clear button input states for Sonic player object
		move.w	#0,(v_jpadhold1).w			; clear actual button input states for controller 1

		bsr.w	ObjPosLoad				; initialize object manager
		bsr.w	ExecuteObjects				; load objects that are already visible during fade-in
		bsr.w	BuildSprites				; build sprites for objects before fade-in

		moveq	#0,d0
		move.w	d0,(v_rings).w				; clear rings
		move.b	d0,(v_lifecount).w			; clear extra lives flags when getting 50/100 rings
		move.l	d0,(v_time).w				; clear time
		move.b	d0,(v_shield).w				; clear shield
		move.b	d0,(v_invinc).w				; clear invincibility
		move.b	d0,(v_shoes).w				; clear speed shoes
		move.b	d0,(v_unused1).w			; clear unused flag (goggles?)
		move.w	d0,(v_debuguse).w			; exit debug mode if necessary
		move.w	d0,(f_restart).w			; clear level restart flag
		move.w	d0,(v_framecount).w			; reset frames since level start to 0
		bsr.w	OscillateNumInit			; initialize oscillation values
		move.b	#1,(f_scorecount).w			; update score counter
		move.b	#1,(f_ringcount).w			; update ring counter
		move.b	#1,(f_timecount).w			; update time counter

		move.w	#0,(v_btnpushtime1).w			; clear button push counters for demos
		lea	(DemoDataPtr).l,a1			; load demo data
		moveq	#0,d0
		move.b	(v_zone).w,d0				; get current Zone ID
		lsl.w	#2,d0					; multiply by 4 for longword-based indexing
		movea.l	(a1,d0.w),a1				; get demo pointer for current level
		move.b	1(a1),(v_btnpushtime2).w		; load initial demo key press duration
		subq.b	#1,(v_btnpushtime2).w			; subtract 1 from demo key pressduration
		move.w	#1800,(v_generictimer).w		; run regular demos for 30 seconds

		move.b	#id_VBlank_08,(v_vblank_routine).w	; set VBlank routine to $08
		bsr.w	WaitForVBlank				; wait until VBlank has finished

		move.w	#$202F,(v_pfade_start).w		; set to fade in 2nd, 3rd & 4th palette lines
		bsr.w	PalFadeIn_Alt				; fade-in main palette
; ---------------------------------------------------------------------------

		; level has faded in, make title cards move and enter main loop
		addq.b	#2,(v_ttlcardname+obRoutine).w		; make title card move (name)
		addq.b	#4,(v_ttlcardzone+obRoutine).w		; make title card move ("ZONE")
		addq.b	#4,(v_ttlcardact+obRoutine).w		; make title card move ("ACT")
		addq.b	#4,(v_ttlcardoval+obRoutine).w		; make title card move (blue oval)
		; enter main loop...

; ---------------------------------------------------------------------------
; Main level loop (when all title card and loading sequences are finished)
; ---------------------------------------------------------------------------

Level_MainLoop:
		bsr.w	PauseGame				; handle pausing the game when pressing start
		move.b	#id_VBlank_08,(v_vblank_routine).w	; set VBlank routine to $08
		bsr.w	WaitForVBlank				; wait until VBlank has finished
		addq.w	#1,(v_framecount).w			; add 1 to level timer

		bsr.w	WaterFeatures				; apply water features
		bsr.w	MoveSonicInDemo				; simulate controls in demos (immediately returns outside demos)
		move.w	(v_jpadhold1).w,(v_jpadhold2).w		; copy player inputs to secondary inputs
		bsr.w	ExecuteObjects				; execute all objects in object RAM

		tst.w	(v_debuguse).w				; is debug mode being used?
		bne.s	Level_DoScroll				; if yes, continue plane scrolling even when dying
		cmpi.b	#6,(v_player+obRoutine).w		; has Sonic just died?
		bhs.s	Level_SkipScroll			; if yes, don't do plane scrolling

Level_DoScroll:
		bsr.w	DeformLayers				; scroll planes and do background deformation

Level_SkipScroll:
		bsr.w	BuildSprites				; build sprite table
		bsr.w	ObjPosLoad				; run the object manager to load level objects
		bsr.w	PaletteCycle				; run palette cycles
		bsr.w	RunPLC					; run PLC, if any
		bsr.w	OscillateNumDo				; advance oscillation values
		bsr.w	SynchroAnimate				; advance animation timers
		bsr.w	SignpostArtLoad				; check if sign post art needs to be loaded and lock left boundary

Level_CheckRestart:
		cmpi.b	#id_Demo,(v_gamemode).w			; are we in a demo?
		beq.s	Level_ChkDemo				; if yes, branch
		tst.w	(f_restart).w				; is the level set to restart?
		bne.w	GM_Level				; if yes, restart level
		cmpi.b	#id_Level,(v_gamemode).w		; is game mode still set to level?
		beq.w	Level_MainLoop				; if yes, loop level game mode
		rts						; if game mode changed, return to MainGameLoop
; ===========================================================================

Level_ChkDemo:
		tst.w	(f_restart).w				; is level set to restart?
		bne.s	Level_EndDemo				; if yes, branch
		tst.w	(v_generictimer).w			; is there time left on the demo?
		beq.s	Level_EndDemo				; if not, branch
		cmpi.b	#id_Demo,(v_gamemode).w			; is game mode still demo?
		beq.w	Level_MainLoop				; if yes, loop level game mode
		move.b	#id_Sega,(v_gamemode).w			; otherwise, return to Sega screen
		rts						; return to MainGameLoop
; ===========================================================================

Level_EndDemo:
		cmpi.b	#id_Demo,(v_gamemode).w			; is game mode still demo?
		bne.s	Level_FadeDemo				; if not, slowly fade-out demo
		move.b	#id_Sega,(v_gamemode).w			; return to Sega screen

Level_FadeDemo:
		move.w	#60,(v_generictimer).w			; run fade-out for one second
		move.w	#$003F,(v_pfade_start).w		; set palette fade-out position and size

Level_FDLoop:
		move.b	#id_VBlank_08,(v_vblank_routine).w	; set VBlank routine to $08
		bsr.w	WaitForVBlank				; wait until VBlank has finished
		bsr.w	MoveSonicInDemo				; continue updating demo controls during fade-out
		bsr.w	ExecuteObjects				; continue executing objects during fade-out
		bsr.w	BuildSprites				; continue building sprites during fade-out
		bsr.w	ObjPosLoad				; continue running object manager during fade-out

		subq.w	#1,(v_palchgspeed).w			; decrement palette fade-out delay
		bpl.s	Level_FDLoop_NoDim			; if time remains, branch
		move.w	#2,(v_palchgspeed).w			; reset palette fade-out delay
		bsr.w	FadeOut_ToBlack				; dim palette further

; loc_2EC8:
Level_FDLoop_NoDim:
		tst.w	(v_generictimer).w			; has fade-out loop finished?
		bne.s	Level_FDLoop				; if not, loop
		rts						; return to MainGameLoop
; End of function GM_Level

; ===========================================================================
; >>> Misc level logic for specific circumstances
	include "leftovers/routines/Debug Coordinate Sprites.asm"
	include	"leftovers/routines/Window Plane Mask.asm"
	include "_include/WaterFeatures.asm"
	include	"_include/MoveSonicInDemo.asm"

; ===========================================================================

; sub_314C:
Zone6_LoadAnimatedChunks:
		cmpi.b	#id_06,(v_zone).w			; is this Zone 6?
		bne.s	locret_3176				; if not, branch
		bsr.w	sub_3178
		lea	(v_256x256+chunk_size*4+$100).l,a1
		bsr.s	sub_3166
		lea	(v_256x256+chunk_size*25+$180).l,a1

sub_3166:
		lea	(Anim256Unk1).l,a0
		move.w	#(Anim256Unk1_end-Anim256Unk1)/2-1,d1

.loadChunks:
		move.w	(a0)+,(a1)+
		dbf	d1,.loadChunks

locret_3176:
		rts
; ===========================================================================

sub_3178:
		lea	(v_256x256).l,a1
		lea	(Anim256Unk2).l,a0
		move.w	#(Anim256Unk2_end-Anim256Unk2)/2-1,d1

.loadChunks2:
		move.w	(a0)+,d0
		ori.w	#$2000,(a1,d0.w)
		dbf	d1,.loadChunks2
		rts
; ===========================================================================

Anim256Unk1:	bincludeEndMarker	"level/map256/Anim Unknown 1.unc"

Anim256Unk2:	bincludeEndMarker	"level/map256/Anim Unknown 2.unc"

; ===========================================================================

LoadAnimatedBlocks:
		cmpi.b	#id_MZ,(v_zone).w			; is this Marble Zone?
		beq.s	.MZ					; if yes, branch
		cmpi.b	#id_SLZ,(v_zone).w			; is this Star Light Zone?
		beq.s	.SLZ					; if yes, branch
		tst.b	(v_zone).w				; is this Green Hill Zone?
		bne.s	.notGHZ					; if not, branch

.SLZ:
		lea	(v_16x16+block_size*$2F2).w,a1		; load ROM address for animated blocks to load in the main block RAM
		lea	(Anim16GHZ).l,a0			; load animated GHZ blocks
		move.w	#(Anim16GHZ_end-Anim16GHZ)/2-1,d1	; load approx. size of the blocks

	.load_GHZ_Blocks:
		move.w	(a0)+,(a1)+
		dbf	d1,.load_GHZ_Blocks

.notGHZ:
		rts
; ===========================================================================

.MZ:
		lea	(v_16x16+block_size*$2F4).w,a1		; load ROM address for animated blocks to load in the main block RAM
		lea	(Anim16MZ).l,a0				; load animated MZ blocks
		move.w	#(Anim16MZ_end-Anim16MZ)/2-1,d1		; load approx. size of the blocks

	.load_MZ_Blocks:
		move.w	(a0)+,(a1)+
		dbf	d1,.load_MZ_Blocks
		rts
; ===========================================================================

Anim16GHZ:	bincludeEndMarker	"level/map16/Anim GHZ.unc"

Anim16MZ:	bincludeEndMarker	"level/map16/Anim MZ.unc"

; ===========================================================================

DebugPosLoadArt:
		rts

		locVRAM ArtTile_Debug_Numbers*tile_size		; set VRAM location
		lea	(Art_Text).l,a0				; load text art
		move.w	#(tile_size*10)/2-1,d1			; write 10 tiles (numbers 0 to 9)
		bsr.s	.writeText				; write debug numbers art
		lea	(Art_Text).l,a0				; load text art
		adda.w	#tile_size*17,a0			; skip 17 tiles (start at A)
		move.w	#(tile_size*6)/2-1,d1			; write 6 tiles (hexes A to F)

	.writeText:
		move.w	(a0)+,(vdp_data_port).l			; write to VDP data port
		dbf	d1,.writeText				; loop for number of tiles to write
		rts
; ===========================================================================

	.1bppConvert:
		moveq	#0,d0
		move.b	(a0)+,d0				; get byte from Art_Text
		ror.w	#1,d0					; rotate right by 1 in word
		lsr.b	#3,d0					; divide byte by 8
		rol.w	#1,d0					; rotate left by 1 in word
		move.b	.1bpp(pc,d0.w),d2			; get table based on d0 and store in d2
		lsl.w	#8,d2					; shift up a byte
		moveq	#0,d0
		move.b	(a0)+,d0				; get next byte from Art_Text
		ror.w	#1,d0					; rotate right by 1 in word
		lsr.b	#3,d0					; divide byte by 8
		rol.w	#1,d0					; rotate left by 1 in word
		move.b	.1bpp(pc,d0.w),d2			; get table based on d0 and store in d2
		move.w	d2,(vdp_data_port).l			; write to VDP data port
		dbf	d1,.writeText				; loop for number of tiles to write
		rts
; ===========================================================================

	.1bpp:
		dc.b	%0000
		dc.b	%0110
		dc.b	%0110<<4
		dc.b	%01100110
		even

; ===========================================================================
; >>> Routines to set and update values that change on a fixed timer
	include	"_include/Oscillatory Routines.asm"


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to change synchronised animation variables (rings)
; ---------------------------------------------------------------------------

SynchroAnimate:

; Used for GHZ spiked log
Sync1:
		subq.b	#1,(v_ani0_time).w			; has first timer reached 0?
		bpl.s	Sync2					; if not, branch
		move.b	#12-1,(v_ani0_time).w			; reset first timer to 12 frames
		subq.b	#1,(v_ani0_frame).w			; go to next frame (backwards)
		andi.b	#7,(v_ani0_frame).w 			; limit to frames 0-7

; Used for rings and giant rings
Sync2:
		subq.b	#1,(v_ani1_time).w			; has second timer reached 0?
		bpl.s	Sync3					; if not, branch
		move.b	#8-1,(v_ani1_time).w			; reset second timer to 8 frames
		addq.b	#1,(v_ani1_frame).w			; go to next frame
		andi.b	#3,(v_ani1_frame).w			; limit to frames 0-3

; Used for nothing
Sync3:
		subq.b	#1,(v_ani2_time).w			; has third timer reached 0?
		bpl.s	Sync4					; if not, branch
		move.b	#8-1,(v_ani2_time).w			; reset third timer to 8 frames
		addq.b	#1,(v_ani2_frame).w			; go to next frame
		cmpi.b	#6,(v_ani2_frame).w			; limit to frames 0-5
		blo.s	Sync4					; if still frame 0-5, branch
		move.b	#0,(v_ani2_frame).w			; set to frame 0 when it reached frame 6

; Used for bouncing rings
Sync4:
		tst.b	(v_ani3_time).w				; is ring loss timer active at all?
		beq.s	SyncEnd					; if not, don't advance animation
		moveq	#0,d0
		move.b	(v_ani3_time).w,d0			; get remaining ring loss timer
		add.w	(v_ani3_buf).w,d0			; add buffered timer value
		move.w	d0,(v_ani3_buf).w			; set that as new buffered timer
		rol.w	#7,d0					; align for speed
		andi.w	#3,d0					; limit to frames 0-3
		move.b	d0,(v_ani3_frame).w			; set as current frame for lost rings
		subq.b	#1,(v_ani3_time).w			; decrease ring loss timer

SyncEnd:
		rts
; End of function SynchroAnimate

; ===========================================================================
; ---------------------------------------------------------------------------
; End-of-act signpost pattern loading subroutine. Also locks left boundary.
; ---------------------------------------------------------------------------

SignpostArtLoad:
		tst.w	(v_debuguse).w				; is debug mode being used?
		bne.w	.return					; if yes, do not lock screen or load art
		cmpi.w	#id_MZ_act3,(v_zone).w			; is this MZ3?
		beq.s	.isMZ3					; if so, load the signpost
		cmpi.b	#act3,(v_act).w				; is this a third act?
		beq.s	.return					; if yes, don't load art (due to the boss fight)

	.isMZ3:
		move.w	(v_scrposx).w,d0			; get current X-camera position
		move.w	(v_limitright2).w,d1			; get right level boundary
		subi.w	#$100,d1				; check for $100 pixels before the right boundary
		cmp.w	d1,d0					; has Sonic reached the right edge of the level?
		blt.s	.return					; if not, branch

		tst.b	(f_timecount).w				; has time already stopped from touching the signpost?
		beq.s	.return					; if yes, branch
		cmp.w	(v_limitleft2).w,d1			; has left boundary already been locked?
		beq.s	.return					; if yes, branch
		move.w	d1,(v_limitleft2).w			; lock left level boundary to current screen position
		moveq	#plcid_Signpost,d0			; load signpost, hidden points, giant ring flash patterns
		bra.w	NewPLC					; add to new PLC queue

.return:
		rts
; End of function SignpostArtLoad


; ===========================================================================
; ---------------------------------------------------------------------------
; Special Stage
; ---------------------------------------------------------------------------

; SpecialStage:
GM_Special:
		bsr.w	PaletteFadeOut				; fade out from the previous screen
		disable_display					; disable screen output
		bsr.w	ClearScreen				; wipe screen
; ---------------------------------------------------------------------------

		; load special stage patterns
		fillVRAM 0, ArtTile_SS_Plane_1*tile_size+plane_size_64x32, ArtTile_SS_Plane_5*tile_size ; clear nametables
		moveq	#plcid_SpecialStage,d0			; load special stage patterns
		bsr.w	QuickPLC				; execute PLCs immediately (no queue)
		bsr.w	SS_BGLoad				; load background clouds/bubbles/birds/fish mappings

		clearRAM v_objspace				; clear object RAM space
		clearRAM v_misc_variables			; clear various level variables
		clearRAM v_timingandscreenvariables		; clear various timing variables
		clearRAM v_ngfx_buffer				; clear Nemesis decompression buffer

		moveq	#palid_Special,d0			; load special stage palette...
		bsr.w	PalLoad_Fade				; ...into the palette fade-in buffer
		jsr	(SS_Load).l				; load SS layout data

		move.l	#0,(v_scrposx).w			; reset X-camera position
		move.l	#0,(v_scrposy).w			; reset Y-camera position
		move.b	#id_SonicSpecial,(v_player).w		; load special stage Sonic object
		move.w	#$458,(v_player+obX).w
		move.w	#$4A0,(v_player+obY).w

		lea	(vdp_control_port).l,a6			; load VDP control port
		move.w	#vreg_mode3|%0011,(a6)			; line scroll mode (per-row horizontally, full-screen vertically)
		move.w	#vreg_mode1|%000100,(a6)		; use 8-colour mode
		move.w	#vreg_hintrate|175,(v_hblank_hreg).w	; set HBlank counter to scanline 175 (even though horizontal interrupts aren't used here...)
		move.w	#vreg_planesize|%010001,(a6)		; 128-cell hscroll size
		bsr.w	PalCycle_SS				; initialize palette cycle and background for fade-in
		clr.w	(v_ssangle).w				; set stage angle to "upright"
		move.w	#$40,(v_ssrotate).w			; set initial stage rotation speed ($40, see object 09)
		move.w	#bgm_SS,d0				; play special stage BG music
		bsr.w	QueueSound2				; play it

		move.w	#0,(v_btnpushtime1).w			; clear button push counters for demos
		lea	(DemoDataPtr).l,a1			; load demo data
		moveq	#0,d0
		move.b	(v_zone).w,d0				; get current Zone ID
		lsl.w	#2,d0					; multiply by 4 for longword-based indexing
		movea.l	(a1,d0.w),a1				; get demo pointer for current level
		move.b	1(a1),(v_btnpushtime2).w		; load initial demo key press duration
		subq.b	#1,(v_btnpushtime2).w			; subtract 1 from demo key pressduration
		move.w	#1800,(v_generictimer).w		; run regular demos for 30 seconds
		enable_display					; enable screen out-put
		bsr.w	PaletteFadeIn

; ---------------------------------------------------------------------------
; Special Stage main loop
; ---------------------------------------------------------------------------

SS_MainLoop:
		bsr.w	PauseGame				; handle pausing the game when pressing start
		move.b	#id_VBlank_0A,(v_vblank_routine).w
		bsr.w	WaitForVBlank				; wait until VBlank has finished
		bsr.w	MoveSonicInDemo				; simulate controls in demos (immediately returns outside demos)
		move.w	(v_jpadhold1).w,(v_jpadhold2).w		; copy controller 1 inputs to Sonic player object inputs

		bsr.w	ExecuteObjects				; execute Special Stage object
		bsr.w	BuildSprites				; build sprites
		jsr	(SS_ShowLayout).l			; render Special Stage layout
		bsr.w	SS_BGAnimate				; animate Special Stage background

		tst.w	(f_demo).w				; is demo mode on?
		beq.s	SS_ChkEnd				; if not, branch
		tst.w	(v_generictimer).w			; is there time left on the demo?
		beq.s	SS_ToSegaScreen				; if not, return to Sega screen

SS_ChkEnd:
		cmpi.b	#id_Special,(v_gamemode).w		; is game mode still the Special Stage?
		beq.w	SS_MainLoop				; if yes, loop game mode
		rts
; ===========================================================================

SS_ToSegaScreen:
		move.b	#id_Sega,(v_gamemode).w			; set game mode to Sega screen
		rts
; ===========================================================================

; >>> Special Stage background drawing and palette cycle logic
	include	"_include/Special Stage Background & Palette Cycle.asm"


; ===========================================================================
; ---------------------------------------------------------------------------
; >> END OF MAIN GAME LOGIC - Everything below this point is file includes <<
; ---------------------------------------------------------------------------
; ===========================================================================
; >>> Level rendering, loading, and updating
		include "_include/LevelSizeLoad & BgScrollSpeed.asm"
		include "_include/DeformLayers.asm"
		include	"_include/Level Drawing.asm"
		include	"_include/LevelLayoutLoad.asm"

		include "_include/DynamicLevelEvents.asm"


; ===========================================================================
; >>> Various level objects
		include "obj/02, 03, 04.asm"
		include "obj/05, 06, 07 Debug Numbers.asm"
		include "obj/11 Bridge.asm"
		include "obj/15 Swinging Platforms.asm"
		include "obj/17 GHZ Spiked Pole Helix.asm"
		include "obj/18 Platforms.asm"
		include "obj/19 GHZ Ball.asm"
		include "obj/1A, 53 Collapsing Ledge and Floors.asm"
		include "obj/1B.asm"
		include "obj/1C GHZ Scenery.asm"
		include "obj/1D Unused - Switch.asm"
		include "obj/2A GHZ Edge Door.asm"


; ===========================================================================
; >>> Title screen objects (includes AnimateSprite)
		include "obj/0E, 0F Title Screen - Sonic, Press Start.asm"


; ===========================================================================
; >>> Badniks, explosions, and Badnik-related objects
		include "obj/1E, 20 Badnik - Ball Hog and Cannonball.asm"
		include "obj/24 Unused - Small Explosion.asm"
		include "obj/27, 3F Explosions.asm"
		include "_anim/Ball Hog.asm"
Map_Hog:	include "_maps/Ball Hog.asm"
Map_Cannonball:	include "_maps/Cannonball.asm"
Map_UnkExplode:	include "_maps/Missile Dissolve.asm"
		include "_maps/Explosions.asm"
		include "obj/28, 29 Animals and Points.asm"
		include "obj/1F Badnik - Crabmeat.asm"
		include "obj/22, 23 Badnik - Buzz Bomber and Missile.asm"


; ===========================================================================
; >>> Rings
		include "obj/25, 37 Rings.asm"
		include "obj/4B Giant Ring.asm"
		include "_anim/Rings.asm"
Map_Ring:	include "_maps/Rings.asm"
Map_GRing:	include "_maps/Giant Ring.asm"


; ===========================================================================
; >>> Monitors
		include "obj/26, 2E Monitors and Power-Ups.asm"


; ===========================================================================
; Subroutines to run, render, and update objects
		include	"_include/ExecuteObjects.asm"
		include "_include/Object Pointers.asm" ; includes Obj_Index
		include "obj/sub ObjectFall & SpeedToPos.asm"
		include "obj/sub DisplaySprite.asm"
		include "obj/sub DeleteObject.asm"
		include	"_include/BuildSprites.asm"
		include	"obj/sub ChkObjectVisible.asm"
		include	"_include/ObjPosLoad.asm"
		include	"obj/sub FindFreeObj.asm"


; ===========================================================================
; >>> More level objects
		include "obj/2B Badnik - Chopper.asm"
		include "obj/2C Badnik - Jaws.asm"
		include "obj/2D Badnik - Burrobot.asm"
		include "obj/2F, 35 MZ Large Grassy Platforms and Burning Grass.asm"
Map_Fire:	include "_maps/Fireballs.asm"
		include "obj/30 MZ Large Green Glass Blocks.asm"
		include "obj/31 MZ Chained Stompers.asm"
		include "obj/45 MZ Sideways Stomper.asm"
Map_CStom:	include "_maps/Chained Stompers.asm"
Map_SStom:	include "_maps/Sideways Stomper.asm"
		include "obj/32 Button.asm"
		include "obj/33 MZ Pushable Blocks.asm"
		include "obj/sub SolidObject.asm"


; ===========================================================================
; >>> Title card objects
		include "obj/34 Title Cards.asm"
		include "obj/39 Game Over.asm"
		include "obj/3A Got Through Act.asm"
		include	"_maps/Title Cards.asm" ; includes "Map_Card", "Map_Over", and "Map_Got"


; ===========================================================================
; >>> More level objects
		include "obj/36 Spikes.asm"
		include "obj/3B Purple Rock.asm"
		include "obj/49 GHZ Waterfall Sound.asm"
Map_PRock:	include "_maps/Purple Rock.asm"
		include "obj/3C GHZ, SLZ Smashable Wall.asm" ; includes SmashObject


; ===========================================================================
; >>> Bosses and related objects
		include "obj/3D, 48 Boss - GHZ Main and Wrecking Ball.asm"
		include "_anim/Eggman.asm"
Map_Eggman:	include "_maps/Eggman.asm"
Map_BossItems:	include "_maps/Boss Items.asm"
		include "obj/3E Prison Capsule.asm"


; ===========================================================================
; >>> More level objects
		include "obj/40 Badnik - Motobug.asm" ; includes "obj/sub RememberState.asm" subroutine
		include "obj/41 Springs.asm"
		include "obj/42 Badnik - Newtron.asm"
		include "obj/43 Badnik - Roller.asm"
		include "obj/44 GHZ Edge Walls.asm"
		include "obj/13, 14 MZ Fire Balls and Maker.asm"
		include "obj/46 MZ Bricks.asm"
		include "obj/12 SZ Search Light.asm"
		include "obj/47 SZ Bumper.asm"
		include "obj/0D Signpost.asm" ; includes "GotThroughAct" subroutine
		include "obj/4C, 4D MZ Lava Geyser and Maker.asm"
		include "obj/4E MZ Wall of Lava.asm"
		include "obj/54 MZ Invisible Lava Tag.asm"
		include "_anim/Lava Geyser.asm"
		include "_anim/Wall of Lava.asm"
Map_Geyser:	include "_maps/Lava Geyser.asm"
Map_LWall:	include "_maps/Wall of Lava.asm"
		include "obj/4F, 50 Badnik - Splats and Yadrin.asm"
		include "obj/51 MZ Smashable Green Block.asm"
		include "obj/52 Moving Blocks.asm"
		include "obj/55 Badnik - Basaran.asm"
		include "obj/56 Floating Blocks and Doors.asm"
		include "obj/57 SZ Spiked Ball and Chain.asm"
		include "obj/58 SZ Big Spiked Ball.asm"
		include "obj/59 SLZ Elevators.asm"
		include "obj/5A SLZ Circling Platform.asm"
		include "obj/5B SLZ Staircase.asm"
		include "obj/5C SLZ Foreground Pylon.asm"
		include "obj/5D SLZ Fan.asm"
		include "obj/5E SLZ Seesaw.asm"


; ===========================================================================
; >>> Main Sonic player object
		include	"obj/01 Sonic.asm"


; ===========================================================================
; >>> Various unique objects
		include "obj/38 Shield and Invincibility.asm"
		include "obj/4A Special Stage Entry (Unused).asm"
		include "_anim/Shield and Invincibility.asm"
Map_Shield:	include "_maps/Shield and Invincibility.asm"
		include "_anim/Special Stage Entry (Unused).asm"
Map_Vanish:	include "_maps/Special Stage Entry (Unused).asm"


; ===========================================================================
; >>> Object-to-object touch response handler for Sonic
		include "obj/Sonic ReactToItem.asm"


; ===========================================================================
; >>> Collision subroutines for Sonic and other objects
		include "obj/Sonic AnglePos.asm"
		include "obj/sub FindNearestTile.asm"
		include "obj/sub FindFloor.asm"
		include "obj/sub FindWall.asm"
		include	"_include/ConvertCollisionArray (Unused).asm"
		include	"obj/Sonic Collision.asm"


; ===========================================================================
; >>> Special Stage rendering and objects
		; The following includes "SS_ShowLayout", "SS_AniWallsRings",
		; "SS_FindFreeAnimationSlot", "SS_AniItems", and "SS_Load"
		include	"_include/Special Stage Loading & Drawing.asm"

		include "_include/Special Stage Mappings & VRAM Pointers.asm"
Map_SS_Up:
Map_SS_Goal:	include	"_maps/SS UP Block.asm"

Map_SS_Down:
Map_SS_Goal_R:	include	"_maps/SS DOWN Block.asm"
		include	"leftovers/routines/Special Stage Layout Load.asm"
		include "obj/09 Sonic in Special Stage.asm"


; ===========================================================================
; >>> Sonic animation test object that is randomly mixed in here
		include "obj/10 Sonic Animation Test.asm"


; ===========================================================================
; >>> Subroutine for in-place level animations in VRAM
		include "_include/AnimateLevelGfx.asm"


; ===========================================================================
; >>> HUD objects
		include "obj/21 HUD.asm"
		include	"obj/sub AddPoints.asm"
		include	"_include/HUD Update.asm"

Art_Hud:	binclude	"artunc/HUD Numbers.unc" ; 8x16 pixel numbers on HUD
		even
Art_LivesNums:	binclude	"artunc/Lives Counter Numbers.unc" ; 8x8 pixel numbers on lives counter
		even


; ===========================================================================
; >>> Debug Mode
		include "obj/DebugMode.asm"


; ===========================================================================
; >>> Level definitions
		include "_include/LevelHeaders.asm"
		include "_include/Pattern Load Cues.asm"


; ===========================================================================

; ---------------------------------------------------------------------------
; >> END OF PRIMARY INCLUDES - Everything below this point is art includes <<
; ---------------------------------------------------------------------------

		; Unused ASCII art starts at $30000 in this prototype, which amounts
		; to $5A90 bytes of padding.
		; From a technical standpoint, this padding serves no purpose.
	if PaddingOptimization=0
		align	$8000
	endif

; ===========================================================================
; ---------------------------------------------------------------------------
; Compressed graphics - Unused 8x8 ASCII Art
; ---------------------------------------------------------------------------
byte_18000:	binclude	"leftovers/artnem/8x8 ASCII.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics and mappings - Sega screen
; ---------------------------------------------------------------------------
Nem_SegaLogo:	binclude	"artnem/Sega Logo.nem"
		even
Eni_SegaLogo:	binclude	"tilemaps/Sega Logo.eni"
		even

; ---------------------------------------------------------------------------
; Compressed graphics and uncompressed mappings - Title screen
; ---------------------------------------------------------------------------
Unc_Title:	binclude	"tilemaps/Title Screen.unc" ; title screen foreground (mappings)
		even
Nem_TitleFg:	binclude	"artnem/Title Screen Foreground.nem"
		even
Nem_TitleSonic:	binclude	"artnem/Title Screen Sonic.nem"
		even

; ---------------------------------------------------------------------------
; Uncompressed graphics - Sonic
; ---------------------------------------------------------------------------

		; Sonic's data starts at $1C000 in this prototype, which amounts
		; to $5EC bytes of padding.
		; From a technical standpoint, this padding serves no purpose.
	if PaddingOptimization=0
		align	$4000
	endif

Map_Sonic:	include	"_maps/Sonic.asm"

SonicDynPLC:	include	"_maps/Sonic - Dynamic Gfx Script.asm"

Art_Sonic:	binclude	"artunc/Sonic.unc"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - various
; ---------------------------------------------------------------------------
Nem_Smoke:	binclude	"artnem/Unused - Smoke.nem"
		even
Nem_Splash:	binclude	"artnem/Unused - Water Splashes.nem"
		even
Nem_SzSparkle:	binclude	"artnem/Unused - SZ Sparkles.nem"
		even
Nem_Shield:	binclude	"artnem/Shield.nem"
		even
Nem_Stars:	binclude	"artnem/Invincibility Stars.nem"
		even
Nem_LzSonic:	binclude	"artnem/Unused - LZ Sonic.nem" ; Sonic holding his breath
		even
Nem_UnkFire:	binclude	"artnem/Unused - Fireball.nem" ; unused fireball
		even
Nem_Warp:	binclude	"artnem/Unused - SStage Flash.nem"
		even
Nem_Goggle:	binclude	"artnem/Unused - Goggles.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - GHZ stuff
; ---------------------------------------------------------------------------

		; GHZ compressed graphics start at $27400 in this prototype, which amounts
		; to $3EA bytes of padding.
		; From a technical standpoint, this padding serves no purpose.
	if PaddingOptimization=0
		align	$400
	endif

Nem_Stalk:	binclude	"artnem/GHZ Flower Stalk.nem"
		even
Nem_Swing:	binclude	"artnem/GHZ Swinging Platform.nem"
		even
Nem_Bridge:	binclude	"artnem/GHZ Bridge.nem"
		even
Nem_GhzMovingBlock:	binclude	"artnem/Unused - GHZ Block.nem"
		even
Nem_Ball:	binclude	"artnem/GHZ Giant Ball.nem"
		even
Nem_Spikes:	binclude	"artnem/Spikes.nem"
		even
Nem_GhzLog:	binclude	"artnem/Unused - GHZ Log.nem"
		even
Nem_SpikePole:	binclude	"artnem/GHZ Spiked Log.nem"
		even
Nem_PplRock:	binclude	"artnem/GHZ Purple Rock.nem"
		even
Nem_GhzWall1:	binclude	"artnem/GHZ Breakable Wall.nem"
		even
Nem_GhzWall2:	binclude	"artnem/GHZ Edge Wall.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - MZ stuff
; ---------------------------------------------------------------------------
Nem_MzMetal:	binclude	"artnem/MZ Metal Blocks.nem"
		even
Nem_MzSwitch:	binclude	"artnem/MZ Switch.nem"
		even
Nem_MzGlass:	binclude	"artnem/MZ Green Glass Block.nem"
		even
Nem_UnkGrass:	binclude	"artnem/Unused - Grass.nem"
		even
Nem_MzFire:	binclude	"artnem/Fireballs.nem"
		even
Nem_Lava:	binclude	"artnem/MZ Lava.nem"
		even
Nem_MzBlock:	binclude	"artnem/MZ Green Pushable Block.nem"
		even
Nem_MzUnkBlock:	binclude	"artnem/Unused - MZ Background.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - SLZ stuff
; ---------------------------------------------------------------------------
Nem_Seesaw:	binclude	"artnem/SLZ Seesaw.nem"
		even
Nem_Fan:	binclude	"artnem/SLZ Fan.nem"
		even
Nem_SlzWall:	binclude	"artnem/SLZ Breakable Wall.nem"
		even
Nem_Pylon:	binclude	"artnem/SLZ Pylon.nem"
		even
Nem_SlzSwing:	binclude	"artnem/SLZ Swinging Platform.nem"
		even
Nem_SlzPlatfm:	binclude	"artnem/SLZ Platforms.nem"
		even
Nem_SlzBlock:	binclude	"artnem/SLZ 32x32 Block.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - SZ stuff
; ---------------------------------------------------------------------------
Nem_Bumper:	binclude	"artnem/SZ Bumper.nem"
		even
Nem_SyzSpike2:	binclude	"artnem/SZ Small Spikeball.nem"
		even
Nem_Switch:	binclude	"artnem/Switch.nem"
		even
Nem_SyzSpike1:	binclude	"artnem/SZ Large Spikeball.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - enemies
; ---------------------------------------------------------------------------
Nem_BallHog:	binclude	"artnem/Unused - Enemy Ball Hog.nem"
		even
Nem_Crabmeat:	binclude	"artnem/Enemy Crabmeat.nem"
		even
Nem_Buzz:	binclude	"artnem/Enemy Buzz Bomber.nem"
		even
Nem_Ball_Explosion:	binclude	"artnem/Unused - Ball Hog's Ball Explosion.nem"
		even
Nem_Burrobot:	binclude	"artnem/Enemy Burrobot.nem"
		even
Nem_Chopper:	binclude	"artnem/Enemy Chopper.nem"
		even
Nem_Jaws:	binclude	"artnem/Enemy Jaws.nem"
		even
Nem_BallHog_Ball:	binclude	"artnem/Unused - Ball Hog's Ball.nem"
		even
Nem_Roller:	binclude	"artnem/Enemy Roller.nem"
		even
Nem_Motobug:	binclude	"artnem/Enemy Motobug.nem"
		even
Nem_Newtron:	binclude	"artnem/Enemy Newtron.nem"
		even
Nem_Yadrin:	binclude	"artnem/Enemy Yadrin.nem"
		even
Nem_Basaran:	binclude	"artnem/Enemy Basaran.nem"
		even
Nem_Splats:	binclude	"artnem/Enemy Splats.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - various
; ---------------------------------------------------------------------------
Nem_TitleCard:	binclude	"artnem/Title Cards.nem"
		even
Nem_HUD:	binclude	"artnem/HUD.nem"
		even
Nem_Lives:	binclude	"artnem/HUD - Life Counter Icon.nem"
		even
Nem_Ring:	binclude	"artnem/Rings.nem"
		even
Nem_Monitors:	binclude	"artnem/Monitors.nem"
		even
Nem_Explode:	binclude	"artnem/Explosion.nem"
		even
Nem_Points:	binclude	"artnem/Points.nem"
		even
Nem_GameOver:	binclude	"artnem/Game Over.nem"
		even
Nem_HSpring:	binclude	"artnem/Spring Horizontal.nem"
		even
Nem_VSpring:	binclude	"artnem/Spring Vertical.nem"
		even
Nem_SignPost:	binclude	"artnem/Signpost.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - animals
; ---------------------------------------------------------------------------
Nem_Rabbit:	binclude	"artnem/Animal Rabbit.nem"
		even
Nem_Chicken:	binclude	"artnem/Animal Chicken.nem"
		even
Nem_Penguin:	binclude	"artnem/Animal Blackbird.nem"
		even
Nem_Seal:	binclude	"artnem/Animal Seal.nem"
		even
Nem_Pig:	binclude	"artnem/Animal Pig.nem"
		even
Nem_Flicky:	binclude	"artnem/Animal Flicky.nem"
		even
Nem_Squirrel:	binclude	"artnem/Animal Squirrel.nem"
		even

; ---------------------------------------------------------------------------
; Level data
; ---------------------------------------------------------------------------

		; Level data starts at $30000 in this prototype, which amounts
		; to $3B2 bytes of padding.
		; From a technical standpoint, this padding serves no purpose.
	if PaddingOptimization=0
		align	$1000
	endif

Blk16_GHZ:	binclude	"level/map16/GHZ.unc"
		even
Nem_GHZ_1st:	binclude	"artnem/8x8 - GHZ1.nem"
		even
Nem_GHZ_2nd:	binclude	"artnem/8x8 - GHZ2.nem"
		even
Blk256_GHZ:	binclude	"level/map256/GHZ.kos"
		even

Blk16_LZ:	binclude	"level/map16/LZ.unc"
		even
Nem_LZ:		binclude	"artnem/8x8 - LZ.nem"
		even
Blk256_LZ:	binclude	"level/map256/LZ.kos"
		even

Blk16_MZ:	binclude	"level/map16/MZ.unc"
		even
Nem_MZ:		binclude	"artnem/8x8 - MZ.nem"
		even
Blk256_MZ:	binclude	"level/map256/MZ.kos"
		even

; 0x3DA48
; Duplicate cut-off chunk data from MZ.
		dc.w $F0, 0, 0, 0, 0, 0, 0, 0

; 0x3DA58
; Cut-off chunk data.
		binclude	"leftovers/level/map256/Chunk Data.kos"
		even

; 0x3DB78
		binclude	"unknown/3DB78.dat"
		even

Blk16_SLZ:	binclude	"level/map16/SLZ.unc"
		even
Nem_SLZ:	binclude	"artnem/8x8 - SLZ.nem"
		even
Blk256_SLZ:	binclude	"level/map256/SLZ.kos"
		even

Blk16_SZ:	binclude	"level/map16/SZ.unc"
		even
Nem_SZ:		binclude	"artnem/8x8 - SZ.nem"
		even
Blk256_SZ:	binclude	"level/map256/SZ.kos"
		even

Blk16_CWZ:	binclude	"level/map16/CWZ.unc"
		even
Nem_CWZ:	binclude	"artnem/8x8 - CWZ.nem"
		even
Blk256_CWZ:	binclude	"level/map256/CWZ.kos"
		even

; 0x570DC
; Duplicate cut-off chunk data from CWZ.
		dc.w $FFF8, $FCAA, $AAFF, $F8FC, $FFF8, $FCFF, $F8FC, $FFF8
		dc.w $FC00, $F001, $FFF8, $FCFF, $F8FC, $FFF8, $FC02, $FF
		dc.w $F89F, $F0, 0, 0, 0, 0, 0, 0
; And another duplicate of cut-off chunk data from CWZ.
		dc.w $F89F, $F0, 0, 0, 0, 0, 0, 0

; 0x5711C
		binclude	"unknown/5711C.dat"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - bosses
; ---------------------------------------------------------------------------
Nem_Eggman:	binclude	"artnem/Boss - Main.nem"
		even
Nem_Weapons:	binclude	"artnem/Boss - Weapons.nem"
		even
Nem_Prison:	binclude	"artnem/Prison Capsule.nem"
		even

; ---------------------------------------------------------------------------
; Demos
; ---------------------------------------------------------------------------
Demo_GHZ:	include "demodata/Intro - GHZ.asm"	; Green Hill's demo (act 2?)
Demo_MZ:	include "demodata/Intro - MZ.asm"	; Marble's demo
Demo_SZ:	include "demodata/Intro - SZ.asm"	; Sparkling's demo (?)
Demo_SS:	include "demodata/Intro - Special Stage.asm" ; Special stage demo

; ---------------------------------------------------------------------------
; Compressed graphics - special stage
; ---------------------------------------------------------------------------

		; Special stage data starts at $63000 in this prototype, which amounts
		; to $1972 bytes of padding.
		; From a technical standpoint, this padding serves no purpose.
	if PaddingOptimization=0
		align	$3000
	endif

Map_SSWalls:	include "_maps/SS Walls.asm"

Nem_SSWalls:	binclude	"artnem/Special Walls.nem"
		even
Eni_SSBg1:	binclude	"tilemaps/SS Background 1.eni"
		even
Nem_SSBgFish:	binclude	"artnem/Special Birds & Fish.nem"
		even
Eni_SSBg2:	binclude	"tilemaps/SS Background 2.eni"
		even
Nem_SSBgCloud:	binclude	"artnem/Special Clouds.nem"
		even
Nem_SSGOAL:	binclude	"artnem/Special GOAL.nem"
		even
Nem_SSRBlock:	binclude	"artnem/Special R.nem"
		even
Nem_SSSkull:	binclude	"artnem/Special Skull.nem"
		even
Nem_SSUBlock:	binclude	"artnem/Special U.nem"
		even
Nem_SS1UpBlock:	binclude	"artnem/Special 1UP.nem"
		even
Nem_SSEmStars:	binclude	"artnem/Special Emerald Twinkle.nem"
		even
Nem_SSRedWhite:	binclude	"artnem/Special Red-White.nem"
		even
Nem_SSZone1:	binclude	"artnem/Special ZONE1.nem"
		even
Nem_SSZone2:	binclude	"artnem/Special ZONE2.nem"
		even
Nem_SSZone3:	binclude	"artnem/Special ZONE3.nem"
		even
Nem_SSZone4:	binclude	"artnem/Special ZONE4.nem"
		even
Nem_SSZone5:	binclude	"artnem/Special ZONE5.nem"
		even
Nem_SSZone6:	binclude	"artnem/Special ZONE6.nem"
		even
Nem_SSUpDown:	binclude	"artnem/Special UP-DOWN.nem"
		even
Nem_SSEmerald:	binclude	"artnem/Special Emeralds.nem"
		even

; ---------------------------------------------------------------------------
; Collision data
; ---------------------------------------------------------------------------

		; Collision data starts at $68000 in this prototype, which amounts
		; to $241A bytes of padding.
		; From a technical standpoint, this padding serves no purpose.
	if PaddingOptimization=0
		align	$4000
	endif

AngleMap:	binclude	"collide/Angle Map.bin"
		even
CollArray1:	binclude	"collide/Collision Array (Normal).bin"
		even
CollArray2:	binclude	"collide/Collision Array (Rotated).bin"
		even
Col_GHZ:	binclude	"collide/GHZ.bin"
		even
Col_LZ:		binclude	"collide/LZ.bin"
		even
Col_MZ:		binclude	"collide/MZ.bin"
		even
Col_SLZ:	binclude	"collide/SLZ.bin"
		even
Col_SZ:		binclude	"collide/SZ.bin"
		even
Col_CWZ:	binclude	"collide/CWZ.bin"
		even

; ---------------------------------------------------------------------------
; Special Stage layout
; ---------------------------------------------------------------------------
SS_1:		bincludeEndMarker	"sslayout/1.unc"

; ---------------------------------------------------------------------------
; Animated uncompressed graphics
; ---------------------------------------------------------------------------
Art_GhzWater:	binclude	"artunc/GHZ Waterfall.unc"
		even
Art_GhzFlower1:	binclude	"artunc/GHZ Flower Large.unc"
		even
Art_GhzFlower2:	binclude	"artunc/GHZ Flower Small.unc"
		even
Art_MzLava1:	binclude	"artunc/MZ Lava Surface.unc"
		even
Art_MzLava2:	binclude	"artunc/MZ Lava.unc"
		even
Art_MzSaturns:	binclude	"artunc/MZ Saturns.unc"
		even
Art_MzTorch:	binclude	"artunc/MZ Background Torch.unc"
		even

; ---------------------------------------------------------------------------
; Level	layout index
; Format: foreground, background, leftover/unused
; ---------------------------------------------------------------------------
Level_Index:
		; GHZ
		dc.w Level_GHZ1-Level_Index, Level_GHZ1BG-Level_Index, Level_GHZ1Unk-Level_Index
		dc.w Level_GHZ2-Level_Index, Level_GHZ2BG-Level_Index, Level_GHZ2Unk-Level_Index
		dc.w Level_GHZ3-Level_Index, Level_GHZ3BG-Level_Index, Level_GHZ3Unk-Level_Index
		dc.w Level_GHZ4Unk-Level_Index, Level_GHZ4Unk-Level_Index, Level_GHZ4Unk-Level_Index
		; LZ
		dc.w Level_LZ1-Level_Index, Level_LZBG-Level_Index, Level_LZ1Unk-Level_Index
		dc.w Level_LZ2-Level_Index, Level_LZBG-Level_Index, Level_LZ2Unk-Level_Index
		dc.w Level_LZ3-Level_Index, Level_LZBG-Level_Index, Level_LZ3Unk-Level_Index
		dc.w Level_LZ4Unk-Level_Index, Level_LZ4Unk-Level_Index, Level_LZ4Unk-Level_Index
		; MZ
		dc.w Level_MZ1-Level_Index, Level_MZ1BG-Level_Index, Level_MZ1-Level_Index
		dc.w Level_MZ2-Level_Index, Level_MZ2BG-Level_Index, Level_MZ2Unk-Level_Index
		dc.w Level_MZ3-Level_Index, Level_MZ3BG-Level_Index, Level_MZ3Unk-Level_Index
		dc.w Level_MZ4Unk-Level_Index, Level_MZ4Unk-Level_Index, Level_MZ4Unk-Level_Index
		; SLZ
		dc.w Level_SLZ1-Level_Index, Level_SLZBG-Level_Index, Level_SLZUnk-Level_Index
		dc.w Level_SLZ2-Level_Index, Level_SLZBG-Level_Index, Level_SLZUnk-Level_Index
		dc.w Level_SLZ3-Level_Index, Level_SLZBG-Level_Index, Level_SLZUnk-Level_Index
		dc.w Level_SLZUnk-Level_Index, Level_SLZUnk-Level_Index, Level_SLZUnk-Level_Index
		; SZ
		dc.w Level_SZ1-Level_Index, Level_SZBG-Level_Index, Level_SZ1Unk-Level_Index
		dc.w Level_SZ2-Level_Index, Level_SZBG-Level_Index, Level_SZ2Unk-Level_Index
		dc.w Level_SZ3-Level_Index, Level_SZBG-Level_Index, Level_SZ3Unk-Level_Index
		dc.w Level_SZ4Unk-Level_Index, Level_SZ4Unk-Level_Index, Level_SZ4Unk-Level_Index
		; CWZ
		dc.w Level_CWZ1-Level_Index, Level_CWZ2-Level_Index, Level_CWZ2-Level_Index
		dc.w Level_CWZ2-Level_Index, Level_CWZ2BG-Level_Index, Level_CWZ2BG-Level_Index
		dc.w Level_CWZ3-Level_Index, Level_CWZ3-Level_Index, Level_CWZ3-Level_Index
		dc.w Level_CWZ4-Level_Index, Level_CWZ4-Level_Index, Level_CWZ4-Level_Index
		; Zone 6
		dc.w Level_0601-Level_Index, Level_06BG-Level_Index, Level_06BG-Level_Index
		dc.w Level_0602-Level_Index, Level_0602-Level_Index, Level_0602-Level_Index
		dc.w Level_0603-Level_Index, Level_0603-Level_Index, Level_0603-Level_Index
		dc.w Level_0604-Level_Index, Level_0604-Level_Index, Level_0604-Level_Index

Level_GHZ1:	binclude	"level/layout/ghz1.bin"
		even
Level_GHZ1BG:	binclude	"level/layout/ghzbg1.bin"
		even
Level_GHZ1Unk:	dc.l 0
Level_GHZ2:	binclude	"level/layout/ghz2.bin"
		even
Level_GHZ2BG:	binclude	"level/layout/ghzbg2.bin"
		even
Level_GHZ2Unk:	dc.l 0
Level_GHZ3:	binclude	"level/layout/ghz3.bin"
		even
Level_GHZ3BG:	binclude	"level/layout/ghzbg3.bin"
		even
Level_GHZ3Unk:	dc.l 0
Level_GHZ4Unk:	dc.l 0

Level_LZ1:	binclude	"level/layout/lz1.bin"
		even
Level_LZBG:	binclude	"level/layout/lzbg.bin"
		even
Level_LZ1Unk:	dc.l 0
Level_LZ2:	binclude	"level/layout/lz2.bin"
		even
Level_LZ2Unk:	dc.l 0
Level_LZ3:	binclude	"level/layout/lz3.bin"
		even
Level_LZ3Unk:	dc.l 0
Level_LZ4Unk:	dc.l 0

Level_MZ1:	binclude	"level/layout/mz1.bin"
		even
Level_MZ1BG:	binclude	"level/layout/mzbg1.bin"
		even
Level_MZ2:	binclude	"level/layout/mz2.bin"
		even
Level_MZ2BG:	binclude	"level/layout/mzbg2.bin"
		even
Level_MZ2Unk:	dc.l 0
Level_MZ3:	binclude	"level/layout/mz3.bin"
		even
Level_MZ3BG:	binclude	"level/layout/mzbg3.bin"
		even
Level_MZ3Unk:	dc.l 0
Level_MZ4Unk:	dc.l 0

Level_SLZ1:	binclude	"level/layout/slz1.bin"
		even
Level_SLZBG:	binclude	"level/layout/slzbg.bin"
		even
Level_SLZ2:	binclude	"level/layout/slz2.bin"
		even
Level_SLZ3:	binclude	"level/layout/slz3.bin"
		even
Level_SLZUnk:	dc.l 0

Level_SZ1:	binclude	"level/layout/sz1.bin"
		even
Level_SZBG:	binclude	"level/layout/szbg.bin"
		even
Level_SZ1Unk:	dc.l 0
Level_SZ2:	binclude	"level/layout/sz2.bin"
		even
Level_SZ2Unk:	dc.l 0
Level_SZ3:	binclude	"level/layout/sz3.bin"
		even
Level_SZ3Unk:	dc.l 0
Level_SZ4Unk:	dc.l 0

Level_CWZ1:	binclude	"level/layout/cwz1.bin"
		even
Level_CWZ2:	binclude	"level/layout/cwz2.bin"
		even
Level_CWZ2BG:	binclude	"level/layout/cwz2bg.bin"
		even
Level_CWZ3:	binclude	"level/layout/cwz3.bin"
		even
Level_CWZ4:	dc.l 0

Level_0601:	binclude	"leftovers/level/layout/test.bin"
		even
Level_06BG:	dc.l 0
Level_0602:	dc.l 0
Level_0603:	dc.l 0
Level_0604:	dc.l 0

; ---------------------------------------------------------------------------

		; ObjPos_Index starts at $70000 in this prototype, which amounts
		; to $1C26 bytes of padding.
		; From a technical standpoint, this padding serves no purpose.
	if PaddingOptimization=0
		align	$2000
	endif

; ---------------------------------------------------------------------------
; Object locations index
; ---------------------------------------------------------------------------
ObjPos_Index:
		; GHZ
		dc.w ObjPos_GHZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_GHZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_GHZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_GHZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; LZ
		dc.w ObjPos_LZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_LZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_LZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_LZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; MZ
		dc.w ObjPos_MZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_MZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_MZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_MZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; SLZ
		dc.w ObjPos_SLZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SLZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SLZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SLZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; SZ
		dc.w ObjPos_SZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; CWZ
		dc.w ObjPos_CWZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_CWZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_CWZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_CWZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; No entries for Zone 6
		dc.b $FF, $FF, 0, 0, 0,	0

ObjPos_GHZ1:	binclude	"level/objpos/ghz1.bin"
		even
ObjPos_GHZ2:	binclude	"level/objpos/ghz2.bin"
		even
ObjPos_GHZ3:	binclude	"level/objpos/ghz3.bin"
		even

ObjPos_LZ1:	binclude	"level/objpos/lz1.bin"
		even
ObjPos_LZ2:	binclude	"level/objpos/lz2.bin"
		even
ObjPos_LZ3:	binclude	"level/objpos/lz3.bin"
		even

ObjPos_MZ1:	binclude	"level/objpos/mz1.bin"
		even
ObjPos_MZ2:	binclude	"level/objpos/mz2.bin"
		even
ObjPos_MZ3:	binclude	"level/objpos/mz3.bin"
		even

ObjPos_SLZ1:	binclude	"level/objpos/slz1.bin"
		even
ObjPos_SLZ2:	binclude	"level/objpos/slz2.bin"
		even
ObjPos_SLZ3:	binclude	"level/objpos/slz3.bin"
		even

ObjPos_SZ1:	binclude	"level/objpos/sz1.bin"
		even
ObjPos_SZ2:	binclude	"level/objpos/sz2.bin"
		even
ObjPos_SZ1_PB:	binclude	"leftovers/level/objpos/sz1.bin"
		even
ObjPos_SZ3:	binclude	"level/objpos/sz3.bin"
		even

ObjPos_CWZ1:	binclude	"level/objpos/cwz1.bin"
		even
ObjPos_CWZ2:	binclude	"level/objpos/cwz2.bin"
		even
ObjPos_CWZ3:	binclude	"level/objpos/cwz3.bin"
		even

ObjPos_Null:	dc.b $FF, $FF, 0, 0, 0,	0

; ---------------------------------------------------------------------------

		; SoundDriver starts at $74000 in this prototype, which amounts
		; to $12DC bytes of padding.
		; From a technical standpoint, this padding serves no purpose.
	if PaddingOptimization=0
		align	$2000
	endif

; ---------------------------------------------------------------------------

SoundDriver:
		include "s1.sounddriver.asm"
		even

; ---------------------------------------------------------------------------

	if PaddingOptimization=0
		cnop -1,2<<lastbit(*-1)
		dc.b $FF
	endif

; end of 'ROM'
EndOfROM:

		END

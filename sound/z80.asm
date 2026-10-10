	save
	!org	0		; z80 Align, handled by the build process
	cpu Z80
	listing purecode

; function to decide whether an offset's full range won't fit in one byte
offsetover1byte function from,maxsize, ((from&0FFh)>(100h-maxsize))

; macro to make sure that ($ & 0FF00h) == (($+maxsize) & 0FF00h)
ensure1byteoffset macro maxsize
	if offsetover1byte($,maxsize)
startpad := $
		align 100h
		if MOMPASS=1
endpad := $
		if endpad-startpad>=1h
							; warn because otherwise you'd have no clue why you're running out of space so fast
			message "had to insert \{endpad-startpad}h bytes of padding before improperly located data at 0\{startpad}h in Z80 code"
		endif
		endif
	endif
	endm

; Data offset equates
zLowAdr:	equ	0			; data low address
zHighAdr:	equ	1			; data high address
zSizeLow:	equ	2			; data size (low byte)
zSizeHigh:	equ	3			; data size (high byte)
zLoopFlag:	equ	4			; loop flag
zPriority:	equ	5			; priority flag
zLoopLow:	equ	6			; loop low byte
zLoopHigh:	equ	7			; loop high byte
zLoopSizeLow:	equ	8			; loop size low byte
zLoopSizeHigh:	equ	9			; loop size high byte
zSampleRate:	equ	11			; sample rate

; ===========================================================================

;Z80Driver_Start:
	di					; disable interrupts
	di
	di
	ld	sp,zStack
	xor	a
	ld	(zDAC_Status),a
	ld	a,(zBankHigh)
	rlca
	ld	(zBankRegister),a
	ld	b,8
	ld	a,(zBankLow)

zBankLoop:
	ld	(zBankRegister),a
	rrca					; move next bit into position
	djnz	zBankLoop
	jr	zCheckForSamples
; ===========================================================================
; JMan2050's DAC decode lookup table
; ===========================================================================
	ensure1byteoffset 10h
zDACDecodeTbl:
	db	   0,	 1,   2,   4,   8,  10h,  20h,  40h
	db	 80h,	-1,  -2,  -4,  -8, -10h, -20h, -40h
; ===========================================================================

zCheckForSamples:
	ld	hl,zDAC_Sample

zWaitDACLoop:
	ld	a,(hl)
	or	a
	jp	p,zWaitDACLoop
	push	af
	push	hl
	ld	a,80h
	ld	(zDAC_Status),a
	ld	hl,zYM2612_A0
	ld	(hl),2Bh
	inc	hl
	ld	(hl),80h
	xor	a
	ld	(zDAC_Status),a
	dec	hl
	ld	ix,zLoopDataStr
	ld	d,0
	exx
	pop	hl
	ld	(zDAC_Update),a
	pop	af
	ld	(zVoiceFlag),a
	sub	81h
	ld	(hl),a
	ld	de,0
	ld	iy,zPCM_Table
	cp	6				; is the sample 87h or higher?
	jr	c,loc_73			; if not, branch
	ld	(zVoiceFlag),a
	ld	(zDAC_Update),a
	ld	iy,(zVoiceTblAdr)
	sub	7

loc_73:
	add	a,a
	add	a,a
	ld	c,a
	add	a,a
	add	a,c
	ld	c,a				; multiply by 12
	ld	b,0
	add	iy,bc
	ld	e,(iy+zLowAdr)
	ld	d,(iy+zHighAdr)
	ld	a,(zVoiceFlag)
	or	a
	jp	m,loc_8F
	ld	hl,(zVoiceTblAdr)
	add	hl,de
	ex	de,hl

loc_8F:
	ld	c,(iy+zSizeLow)
	ld	b,(iy+zSizeHigh)
	ld	a,(iy+zLoopFlag)
	ld	(zRepeatFlag),a
	exx
	ld	c,80h
	exx

zPlayPCMLoop:
	ld	hl,zDAC_Sample			; 10
	ld	a,(de)				; 7
	and	0F0h				; 7
	rrca					; 4
	rrca					; 4
	rrca					; 4
	rrca					; 4
	add	a,zDACDecodeTbl&0FFh		; 7
	exx					; 4
	ld	e,a				; 4
	ld	a,(de)				; 7
	add	a,c				; 4
	ld	c,a				; 4
	ld	a,80h				; 7
	ld	(zDAC_Status),a			; 13
	ld	b,(iy+zSampleRate)		; 19

.loop1:
	bit	7,(hl)				; 12
	jr	nz,.loop1			; 12
	ld	(hl),2Ah			; 10
	inc	hl				; 6
	xor	a				; 4
	ld	(hl),c				; 7
	ld	(zDAC_Status),a			; 13
	dec	hl				; 6
	djnz	$				; 8
	exx					; 4
	ld	a,(de)				; 7
	and	0Fh				; 7
	add	a,zDACDecodeTbl&0FFh		; 7
	exx					; 4
	ld	e,a				; 4
	ld	a,(de)				; 7
	add	a,c				; 4
	ld	c,a				; 4
	ld	a,80h				; 7
	ld	(zDAC_Status),a			; 13
	ld	b,(iy+zSampleRate)		; 19

.loop2:
	bit	7,(hl)				; 12
	jr	nz,.loop2			; 12
	ld	(hl),2Ah			; 10
	inc	hl				; 6
	xor	a				; 4
	ld	(hl),c				; 7
	ld	(zDAC_Status),a			; 13
	dec	hl				; 6
	djnz	$				; 8
	exx					; 4
	bit	7,(iy+zPriority)		; 20
	jr	nz,loc_F5			; 12
	bit	7,(hl)				; 12
	jp	nz,zWaitDACLoop			; 10

loc_F5:
	inc	de				; 6
	dec	bc				; 6
	ld	a,c				; 4
	or	b				; 4
	jp	nz,zPlayPCMLoop			; 10
						; 420 cycles in total
	ld	a,(zRepeatFlag)
	or	a
	jp	z,loc_153
	exx
	jp	p,loc_10C
	and	7Fh
	ld	(ix+0),c

loc_10C:
	dec	a
	ld	(zRepeatFlag),a
	jr	z,loc_133
	ld	c,(ix+0)
	exx
	ld	l,(iy+zLoopLow)
	ld	h,(iy+zLoopHigh)
	ld	b,h
	ld	c,l
	ld	e,(iy+zLowAdr)
	ld	d,(iy+zHighAdr)
	ld	hl,(zVoiceTblAdr)
	add	hl,de
	ld	e,(iy+zSizeLow)
	ld	d,(iy+zSizeHigh)
	add	hl,de
	ex	de,hl
	jp	zPlayPCMLoop
; ===========================================================================

loc_133:
	ld	c,(ix+0)
	exx
	ld	c,(iy+zLoopSizeLow)
	ld	b,(iy+zLoopSizeHigh)
	ld	l,(iy+zSizeLow)
	ld	h,(iy+zSizeHigh)
	ld	e,(iy+zLowAdr)
	ld	d,(iy+zHighAdr)
	add	hl,de
	ld	de,(zVoiceTblAdr)
	add	hl,de
	ex	de,hl
	jp	zPlayPCMLoop
; ===========================================================================

loc_153:
	ld	hl,zDAC_Update
	ld	a,(hl)
	or	a
	jp	m,zCheckForSamples
	xor	a
	ld	(hl),a
	jp	zCheckForSamples

; ===========================================================================

zPCMMetadata macro label,loopFlag,priority,loopLabel
	dw	label					; Start
	dw	label.size				; Length
	if loopFlag
		db	80h				; Loop Flag
	else
		db	0				; Loop Flag
	endif
	if priority
		db	80h				; Priority
	else
		db	0				; Priority
	endif
	if loopLabel
		dw	loopLabel			; Loop Start
		dw	loopLabel_End-loopLabel		; Loop Length
	else
		ds	4
	endif
	db	0					; Padding
	db	dpcmLoopCounter(label.sample_rate)	; Pitch
	endm

; DPCM metadata
zPCM_Table:
	zPCMMetadata zDAC_Kick,0,0,0
	zPCMMetadata zDAC_Snare,0,0,0
zTimpani_Pitch = $+zSampleRate
	zPCMMetadata zDAC_Timpani,0,0,0

; DPCM data
zDAC_Kick:	include "sound/dac/dpcm/generated/kick.inc"
zDAC_Snare:	include "sound/dac/dpcm/generated/snare.inc"
zDAC_Timpani:	include "sound/dac/dpcm/generated/timpani.inc"

	if MOMPASS=2
		if $ > 2000h
			fatal "The driver is too big	; the maximum size it can take is 2000h. It currently takes \{$}h bytes. You won't be able to use this thing."
		else
			message "Driver size: \{$}h bytes."
		endif
	endif

	restore
	padding off
	!org (DACDriver+Size_of_DAC_driver_guess)
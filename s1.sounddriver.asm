; ---------------------------------------------------------------------------
; Modified SMPS 68k Type 1b sound driver
; The source code to a similar version of the driver can be found here:
; https://hiddenpalace.org/News/Sega_of_Japan_Sound_Documents_and_Source_Code
; ---------------------------------------------------------------------------

; Constants
SMPS_TRACK_COUNT = (SMPS_RAM.v_track_ram_end-SMPS_RAM.v_track_ram)/SMPS_Track.len
SMPS_MUSIC_TRACK_COUNT = (SMPS_RAM.v_music_track_ram_end-SMPS_RAM.v_music_track_ram)/SMPS_Track.len
SMPS_MUSIC_FM_DAC_TRACK_COUNT = (SMPS_RAM.v_music_fmdac_tracks_end-SMPS_RAM.v_music_fmdac_tracks)/SMPS_Track.len
SMPS_MUSIC_FM_TRACK_COUNT = (SMPS_RAM.v_music_fm_tracks_end-SMPS_RAM.v_music_fm_tracks)/SMPS_Track.len
SMPS_MUSIC_PSG_TRACK_COUNT = (SMPS_RAM.v_music_psg_tracks_end-SMPS_RAM.v_music_psg_tracks)/SMPS_Track.len
SMPS_SFX_TRACK_COUNT = (SMPS_RAM.v_sfx_track_ram_end-SMPS_RAM.v_sfx_track_ram)/SMPS_Track.len
SMPS_SFX_FM_TRACK_COUNT = (SMPS_RAM.v_sfx_fm_tracks_end-SMPS_RAM.v_sfx_fm_tracks)/SMPS_Track.len
SMPS_SFX_PSG_TRACK_COUNT = (SMPS_RAM.v_sfx_psg_tracks_end-SMPS_RAM.v_sfx_psg_tracks)/SMPS_Track.len
SMPS_SPECIAL_SFX_TRACK_COUNT = (SMPS_RAM.v_spcsfx_track_ram_end-SMPS_RAM.v_spcsfx_track_ram)/SMPS_Track.len
SMPS_SPECIAL_SFX_FM_TRACK_COUNT = (SMPS_RAM.v_spcsfx_fm_tracks_end-SMPS_RAM.v_spcsfx_fm_tracks)/SMPS_Track.len
SMPS_SPECIAL_SFX_PSG_TRACK_COUNT = (SMPS_RAM.v_spcsfx_psg_tracks_end-SMPS_RAM.v_spcsfx_psg_tracks)/SMPS_Track.len
; ---------------------------------------------------------------------------

; Go_SoundTypes:
Go_SoundPriorities:	dc.l SoundPriorities
; Go_SoundD0:
Go_SpecSoundIndex:	dc.l SpecSoundIndex
Go_MusicIndex:		dc.l MusicIndex
Go_SoundIndex:		dc.l SoundIndex
Go_ModulationIndex:	dc.l ModulationIndex
Go_PSGIndex:		dc.l PSGIndex
			dc.l sfx__First
			dc.l UpdateMusic
Go_SpeedUpIndex:	dc.l SpeedUpIndex

; ===========================================================================
; ---------------------------------------------------------------------------
; PSG instruments used in music
; ---------------------------------------------------------------------------
PSGIndex:
		dc.l PSG1, PSG2, PSG3
		dc.l PSG4, PSG6, PSG5
		dc.l PSG7, PSG8, PSG9

PSG1:		dc.b 0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,TBEND

PSG2:		dc.b 0,2,4,6,8,$10,TBEND

PSG3:		dc.b 0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,TBEND

PSG4:		dc.b 0,0,2,3,4,4,5,5,5,6,TBEND

PSG5:		dc.b 3,3,3,2,2,2,2,1,1,1,0,0,0,0,TBEND

PSG6:		dc.b 0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,4,TBEND

PSG7:		dc.b 0,0,0,0,0,0,1,1,1,1,1,2,2,2,2,2,3,3,3,4,4,4,5,5,5,6,7,TBEND

PSG8:		dc.b 0,0,0,0,0,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3,4,4,4,4,4,5,5,5,5,5,6,6,6,6,6,7,7,7,TBEND

PSG9:		dc.b 0,1,2,3,4,5,6,7,8,9,$A,$B,$C,$D,$E,$F,TBEND

; ===========================================================================
; ---------------------------------------------------------------------------
; Global modulation index
; ---------------------------------------------------------------------------
ModulationIndex:
		dc.b $D, 1, 7, 4	; 0
		dc.b 1, 1, 1, 4		; 1
		dc.b 2, 1, 2, 4		; 2
		dc.b 8, 1, 6, 4		; 3
		; Warning: If the set value for the global modulation is beyond 3, it will use the speed up index as part of the index!

; ===========================================================================
; ---------------------------------------------------------------------------
; New tempos for songs during speed shoes
; ---------------------------------------------------------------------------
; DANGER! several songs will use the first few bytes of MusicIndex as their main
; tempos while speed shoes are active. If you don't want that, you should add
; their "correct" sped-up main tempos to the list.
; byte_71A94:
SpeedUpIndex:
		dc.b 7		; GHZ
		dc.b $72	; LZ
		dc.b $73	; MZ
		dc.b $26	; SLZ
		dc.b $15	; SYZ
		dc.b 8		; SBZ
		dc.b $FF	; Invincibility
		dc.b 5		; Extra Life
		;dc.b ?		; Special Stage
		;dc.b ?		; Title Screen
		;dc.b ?		; Ending
		;dc.b ?		; Boss
		;dc.b ?		; FZ
		;dc.b ?		; Sonic Got Through
		;dc.b ?		; Game Over
		;dc.b ?		; Continue Screen
		;dc.b ?		; Credits

; ===========================================================================
; ---------------------------------------------------------------------------
; Music	Pointers
; ---------------------------------------------------------------------------
MusicIndex:
ptr_mus81:	dc.l Music81
ptr_mus82:	dc.l Music82
ptr_mus83:	dc.l Music83
ptr_mus84:	dc.l Music84
ptr_mus85:	dc.l Music85
ptr_mus86:	dc.l Music86
ptr_mus87:	dc.l Music87
ptr_mus88:	dc.l Music88
ptr_mus89:	dc.l Music89
ptr_mus8A:	dc.l Music8A
ptr_mus8B:	dc.l Music8B
ptr_mus8C:	dc.l Music8C
ptr_mus8D:	dc.l Music8D
ptr_mus8E:	dc.l Music8E
ptr_mus8F:	dc.l Music8F
ptr_mus90:	dc.l Music90
ptr_mus91:	dc.l Music91
		; Note the lack of a pointer for music $92
ptr_musend

; ===========================================================================
; ---------------------------------------------------------------------------
; Priority of sound. New music or SFX must have a priority higher than or equal
; to what is stored in v_sndprio or it won't play. If bit 7 of new priority is
; set ($80 and up), the new music or SFX will not set its priority -- meaning
; any music or SFX can override it (as long as it can override whatever was
; playing before). Usually, SFX will only override SFX, special SFX ($D0-$DF)
; will only override special SFX and music will only override music.
; ---------------------------------------------------------------------------
; SoundTypes:
SoundPriorities:
		dc.b     $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80	; $81
		dc.b $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80	; $90
		dc.b $70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70	; $A0
		dc.b $70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70	; $B0
		dc.b $70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70	; $C0
		dc.b $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80	; $D0
		dc.b $80,$80,$80,$80,$80,$80						; $E0
		even

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to update music more than once per frame
; (Called by horizontal & vert. interrupts)
; ---------------------------------------------------------------------------

UpdateMusic:
		stopZ80
		waitZ80
		btst	#7,(z80_ram+zDAC_Status).l		; Is DAC accepting new samples?
		beq.s	.driverinput				; Branch if yes
		startZ80
		nop
		nop
		nop
		nop
		nop
		bra.s	UpdateMusic
; ===========================================================================

.driverinput:
		lea	(v_snddriver_ram&$FFFFFF).l,a6
		clr.b	SMPS_RAM.f_voice_selector(a6)
		tst.b	SMPS_RAM.f_pausemusic(a6)		; Is music paused?
		bne.w	PauseMusic				; If yes, branch
		subq.b	#1,SMPS_RAM.v_main_tempo_timeout(a6)	; Has main tempo timer expired?
		bne.s	.skipdelay
		jsr	TempoWait(pc)

.skipdelay:
		move.b	SMPS_RAM.v_fadeout_counter(a6),d0
		beq.s	.skipfadeout
		jsr	DoFadeOut(pc)

.skipfadeout:
		tst.b	SMPS_RAM.f_fadein_flag(a6)
		beq.s	.skipfadein
		jsr	DoFadeIn(pc)

.skipfadein:
	if FixBugs
		tst.l	SMPS_RAM.v_soundqueue0(a6)		; Is a music or sound queued for playing?
	else
		; DANGER! The following line only checks v_soundqueue0 and v_soundqueue1, breaking v_soundqueue2.
		tst.w	SMPS_RAM.v_soundqueue0(a6)		; Is a music or sound queued for playing?
	endif
		beq.s	.nosndinput				; if not, branch
		jsr	CycleSoundQueue(pc)

.nosndinput:
		lea	SMPS_RAM.v_music_dac_track(a6),a5
		tst.b	SMPS_Track.PlaybackControl(a5)		; Is DAC track playing?
		bpl.s	.dacdone				; Branch if not
		jsr	DACUpdateTrack(pc)

.dacdone:
		clr.b	SMPS_RAM.f_updating_dac(a6)
		moveq	#SMPS_MUSIC_FM_TRACK_COUNT-1,d7		; 6 FM tracks

.bgmfmloop:
		adda.w	#SMPS_Track.len,a5
		tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
		bpl.s	.bgmfmnext				; Branch if not
		jsr	FMUpdateTrack(pc)

.bgmfmnext:
		dbf	d7,.bgmfmloop

		moveq	#SMPS_MUSIC_PSG_TRACK_COUNT-1,d7	; 3 PSG tracks

.bgmpsgloop:
		adda.w	#SMPS_Track.len,a5
		tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
		bpl.s	.bgmpsgnext				; Branch if not
		jsr	PSGUpdateTrack(pc)

.bgmpsgnext:
		dbf	d7,.bgmpsgloop

		move.b	#$80,SMPS_RAM.f_voice_selector(a6)	; Now at SFX tracks
		moveq	#SMPS_SFX_FM_TRACK_COUNT-1,d7		; 3 FM tracks (SFX)

.sfxfmloop:
		adda.w	#SMPS_Track.len,a5
		tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
		bpl.s	.sfxfmnext				; Branch if not
		jsr	FMUpdateTrack(pc)

.sfxfmnext:
		dbf	d7,.sfxfmloop

		moveq	#SMPS_SFX_PSG_TRACK_COUNT-1,d7		; 3 PSG tracks (SFX)

.sfxpsgloop:
		adda.w	#SMPS_Track.len,a5
		tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
		bpl.s	.sfxpsgnext				; Branch if not
		jsr	PSGUpdateTrack(pc)

.sfxpsgnext:
		dbf	d7,.sfxpsgloop

		move.b	#$40,SMPS_RAM.f_voice_selector(a6)	; Now at special SFX tracks
		adda.w	#SMPS_Track.len,a5
		tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
		bpl.s	.specfmdone				; Branch if not
		jsr	FMUpdateTrack(pc)

.specfmdone:
		adda.w	#SMPS_Track.len,a5
		tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
		bpl.s	DoStartZ80				; Branch if not
		jsr	PSGUpdateTrack(pc)

DoStartZ80:
		startZ80
		rts
; End of function UpdateMusic

; ===========================================================================

; UpdateDAC:
DACUpdateTrack:
		subq.b	#1,SMPS_Track.DurationTimeout(a5)	; Has DAC sample timeout expired?
		bne.s	.return					; Return if not
		move.b	#$80,SMPS_RAM.f_updating_dac(a6)	; Set flag to indicate this is the DAC
;DACDoNext:
		movea.l	SMPS_Track.DataPointer(a5),a4		; DAC track data pointer

.sampleloop:
		moveq	#0,d5
		move.b	(a4)+,d5				; Get next SMPS unit
		cmpi.b	#$E0,d5					; Is it a coord. flag?
		blo.s	.notcoord				; Branch if not
		jsr	CoordFlag(pc)
		bra.s	.sampleloop
; ===========================================================================

.notcoord:
		tst.b	d5					; Is it a sample?
		bpl.s	.gotduration				; Branch if not (duration)
		move.b	d5,SMPS_Track.SavedDAC(a5)		; Store new sample
		move.b	(a4)+,d5				; Get another byte
		bpl.s	.gotduration				; Branch if it is a duration
		subq.w	#1,a4					; Put byte back
		move.b	SMPS_Track.SavedDuration(a5),SMPS_Track.DurationTimeout(a5) ; Use last duration
		bra.s	.gotsampleduration
; ===========================================================================

.gotduration:
		jsr	SetDuration(pc)

.gotsampleduration:
		move.l	a4,SMPS_Track.DataPointer(a5) 		; Save pointer
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is track being overridden?
		bne.s	.return					; Return if yes
		moveq	#0,d0
		move.b	SMPS_Track.SavedDAC(a5),d0		; Get sample
		cmpi.b	#$80,d0					; Is it a rest?
		beq.s	.return					; Return if yes
		btst	#3,d0					; Is bit 3 set (samples between $88-$8F)?
		bne.s	.timpani				; Various timpani
		tst.b	(z80_ram+zDAC_Update).l			; Is the DAC update flag set?
		bne.s	.return					; if not, branch
		move.b	d0,(z80_ram+zDAC_Sample).l

.return:
		rts
; ===========================================================================

.timpani:
		subi.b	#$88,d0					; Convert into an index
		move.b	DAC_sample_rate(pc,d0.w),d0
		tst.b	(z80_ram+zDAC_Update).l			; Is the DAC update flag set?
		bne.s	.noupdate				; if not, branch
		move.b	d0,(z80_ram+zTimpani_Pitch).l
		move.b	#$83,(z80_ram+zDAC_Sample).l		; use timpani

.noupdate:
		rts
; End of function DACUpdateTrack

; ===========================================================================
; Note: $8C-$8F are so slow you may want to skip them.
timpaniLoopCounter function scale,dpcmLoopCounter(int(zDAC_Timpani.sample_rate*scale))

DAC_sample_rate:
		dc.b timpaniLoopCounter(1.30)
		dc.b timpaniLoopCounter(1.17)
		dc.b timpaniLoopCounter(0.99)
		dc.b timpaniLoopCounter(0.97)
		dc.b $FF, $FF, $FF, $FF
		even
; ===========================================================================

FMUpdateTrack:
		subq.b	#1,SMPS_Track.DurationTimeout(a5)	; Update duration timeout
		bne.s	.notegoing				; Branch if it hasn't expired
		bclr	#4,SMPS_Track.PlaybackControl(a5)	; Clear 'do not attack next note' bit
		jsr	FMDoNext(pc)
		jsr	FMPrepareNote(pc)
		jsr	FMPan_Set(pc)
		bra.w	FMNoteOn
; ===========================================================================

.notegoing:
		jsr	NoteTimeoutUpdate(pc)
		jsr	DoModulation(pc)
		bra.w	FMUpdateFreq
; End of function FMUpdateTrack
; ===========================================================================

FMDoNext:
		movea.l	SMPS_Track.DataPointer(a5),a4		; Track data pointer
		bclr	#1,SMPS_Track.PlaybackControl(a5)	; Clear 'track at rest' bit

.noteloop:
		moveq	#0,d5
		move.b	(a4)+,d5				; Get byte from track
		cmpi.b	#$E0,d5					; Is this a coord. flag?
		blo.s	.gotnote				; Branch if not
		jsr	CoordFlag(pc)
		bra.s	.noteloop
; ===========================================================================

.gotnote:
		jsr	FMNoteOff(pc)
		tst.b	d5					; Is this a note?
		bpl.s	.gotduration				; Branch if not
		jsr	FMSetFreq(pc)
		move.b	(a4)+,d5				; Get another byte
		bpl.s	.gotduration				; Branch if it is a duration
		subq.w	#1,a4					; Otherwise, put it back
		bra.w	FinishTrackUpdate
; ===========================================================================

.gotduration:
		jsr	SetDuration(pc)
		bra.w	FinishTrackUpdate
; End of function FMDoNext
; ===========================================================================

FMSetFreq:
		subi.b	#$80,d5					; Make it a zero-based index
		beq.s	TrackSetRest
		add.b	SMPS_Track.Transpose(a5),d5		; Add track transposition
		andi.w	#$7F,d5					; Clear high byte and sign bit
		lsl.w	#1,d5
		lea	FMFrequencies(pc),a0
		move.w	(a0,d5.w),d6
		move.w	d6,SMPS_Track.Freq(a5)			; Store new frequency
		rts
; End of function FMSetFreq
; ===========================================================================

SetDuration:
		move.b	d5,d0
		move.b	SMPS_Track.TempoDivider(a5),d1		; Get dividing timing

.multloop:
		subq.b	#1,d1
		beq.s	.donemult
		add.b	d5,d0
		bra.s	.multloop
; ===========================================================================

.donemult:
		move.b	d0,SMPS_Track.SavedDuration(a5)		; Save duration
		move.b	d0,SMPS_Track.DurationTimeout(a5)	; Save duration timeout
		rts
; End of function SetDuration

; ===========================================================================

TrackSetRest:
		bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
		clr.w	SMPS_Track.Freq(a5)			; Clear frequency
		; Fall into FinishTrackUpdate
; ===========================================================================

FinishTrackUpdate:
		move.l	a4,SMPS_Track.DataPointer(a5)		; Store new track position
		move.b	SMPS_Track.SavedDuration(a5),SMPS_Track.DurationTimeout(a5) ; Reset note timeout
		btst	#4,SMPS_Track.PlaybackControl(a5)	; Is track set to not attack note?
		bne.s	.return					; If so, branch
		move.b	SMPS_Track.NoteTimeoutMaster(a5),SMPS_Track.NoteTimeout(a5) ; Reset note fill timeout
		clr.b	SMPS_Track.VolEnvIndex(a5)		; Reset PSG volume envelope index (even on FM tracks...)
		btst	#3,SMPS_Track.PlaybackControl(a5)	; Is modulation on?
		beq.s	.return					; If not, return
		movea.l	SMPS_Track.ModulationPtr(a5),a0		; Modulation data pointer
		move.b	(a0)+,SMPS_Track.ModulationWait(a5)	; Reset wait
		move.b	(a0)+,SMPS_Track.ModulationSpeed(a5)	; Reset speed
		move.b	(a0)+,SMPS_Track.ModulationDelta(a5)	; Reset delta
		move.b	(a0)+,d0				; Get steps
		lsr.b	#1,d0					; Halve them
		move.b	d0,SMPS_Track.ModulationSteps(a5)	; Then store
		clr.w	SMPS_Track.ModulationVal(a5)		; Reset frequency change

.return:
		rts
; End of function FinishTrackUpdate
; ===========================================================================

; NoteFillUpdate
NoteTimeoutUpdate:
		tst.b	SMPS_Track.NoteTimeout(a5)		; Is note fill on?
		beq.s	.return
		subq.b	#1,SMPS_Track.NoteTimeout(a5)		; Update note fill timeout
		bne.s	.return					; Return if it hasn't expired
		bset	#1,SMPS_Track.PlaybackControl(a5)	; Put track at rest
		tst.b	SMPS_Track.VoiceControl(a5)		; Is this a PSG track?
		bmi.w	.psgnoteoff				; If yes, branch
		jsr	FMNoteOff(pc)
		addq.w	#4,sp					; Do not return to caller
		rts
; ===========================================================================

.psgnoteoff:
		jsr	PSGNoteOff(pc)
		addq.w	#4,sp					; Do not return to caller

.return:
		rts
; End of function NoteTimeoutUpdate
; ===========================================================================

DoModulation:
		addq.w	#4,sp					; Do not return to caller (but see below)
		btst	#3,SMPS_Track.PlaybackControl(a5)	; Is modulation active?
		beq.s	.nomod					; Return if not
		tst.b	SMPS_Track.ModulationWait(a5)		; Has modulation wait expired?
		beq.s	.waitdone				; If yes, branch
		subq.b	#1,SMPS_Track.ModulationWait(a5)	; Update wait timeout
		rts
; ===========================================================================

.waitdone:
		subq.b	#1,SMPS_Track.ModulationSpeed(a5)	; Update speed
		beq.s	.updatemodulation			; If it expired, want to update modulation
		rts
; ===========================================================================

.updatemodulation:
		movea.l	SMPS_Track.ModulationPtr(a5),a0
		move.b	1(a0),SMPS_Track.ModulationSpeed(a5)
		tst.b	SMPS_Track.ModulationSteps(a5)
		bne.s	.calcfreq
		move.b	3(a0),SMPS_Track.ModulationSteps(a5)
		neg.b	SMPS_Track.ModulationDelta(a5)
		rts
; ===========================================================================

.calcfreq:
		subq.b	#1,SMPS_Track.ModulationSteps(a5)	; Update modulation steps
		move.b	SMPS_Track.ModulationDelta(a5),d6	; Get modulation delta
		ext.w	d6
		add.w	SMPS_Track.ModulationVal(a5),d6		; Add cumulative modulation change
		move.w	d6,SMPS_Track.ModulationVal(a5)		; Store it
		add.w	SMPS_Track.Freq(a5),d6			; Add note frequency to it
		subq.w	#4,sp					; In this case, we want to return to caller after all

.nomod:
		rts
; End of function DoModulation
; ===========================================================================

FMPrepareNote:
		btst	#1,SMPS_Track.PlaybackControl(a5)	; Is track resting?
		bne.s	locret_744E0				; Return if so
		move.w	SMPS_Track.Freq(a5),d6			; Get current note frequency
		beq.s	FMSetRest				; Branch if zero

FMUpdateFreq:
		move.b	SMPS_Track.Detune(a5),d0		; Get detune value
		ext.w	d0
		add.w	d0,d6					; Add note frequency
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is track being overridden?
		bne.s	locret_744E0				; Return if so
		tst.b	SMPS_RAM.v_se_mode_flag(a6)
		beq.s	.nofm3sm
		cmpi.b	#2,SMPS_Track.VoiceControl(a5)
		beq.s	FM3SpcUpdateFreq

.nofm3sm:
		move.w	d6,d1
		lsr.w	#8,d1
		move.b	#$A4,d0					; Register for upper 6 bits of frequency
		jsr	WriteFMIorII(pc)
		move.b	d6,d1
		move.b	#$A0,d0					; Register for lower 8 bits of frequency
		jsr	WriteFMIorII(pc)

locret_744E0:
		rts
; ===========================================================================

FMSetRest:
		bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
		rts
; End of function FMPrepareNote

; ===========================================================================

FM3SpcUpdateFreq:
		lea	.fm3freqs(pc),a1
		lea	SMPS_RAM.v_detune_start(a6),a2
		moveq	#(.fm3freqs_end-.fm3freqs)/2-1,d7

.loopfm3:
		move.w	d6,d1
		move.w	(a2)+,d0
		add.w	d0,d1
		move.w	d1,d3
		lsr.w	#8,d1
		move.b	(a1)+,d0
		jsr	WriteFMI(pc)
		move.b	d3,d1
		move.b	(a1)+,d0
		jsr	WriteFMI(pc)
		dbf	d7,.loopfm3
		rts
; ===========================================================================

.fm3freqs:
		dc.b $AD, $A9
		dc.b $AC, $A8
		dc.b $AE, $AA
		dc.b $A6, $A2
.fm3freqs_end:
; ===========================================================================

FMPan_Set:
		btst	#1,SMPS_Track.PlaybackControl(a5)
		bne.s	.tables
		moveq	#0,d0
		move.b	SMPS_Track.PanNumber(a5),d0
		lsl.w	#1,d0
		jmp	.tables(pc,d0.w)
; ===========================================================================

.tables:
		rts
; ===========================================================================
		bra.s	FMPan_Cont
; ===========================================================================
		bra.s	FMPan_Reset
; ===========================================================================
		bra.s	FMPan_Reset
; ===========================================================================

FMPan_Chk:
		btst	#1,SMPS_Track.PlaybackControl(a5)
		bne.s	.table
		moveq	#0,d0
		move.b	SMPS_Track.PanNumber(a5),d0
		lsl.w	#1,d0
		jmp	.table(pc,d0.w)
; ===========================================================================

.table:
		rts
; ===========================================================================
		rts
; ===========================================================================
		bra.s	FMPan_Cont
; ===========================================================================
		bra.s	FMPan_Cont
; ===========================================================================

FMPan_Reset:
		move.b	SMPS_Track.PanLength(a5),SMPS_Track.PanContinue(a5)
		clr.b	SMPS_Track.PanStart(a5)

FMPan_Cont:
		move.b	SMPS_Track.PanContinue(a5),d0
		cmp.b	SMPS_Track.PanLength(a5),d0
		bne.s	loc_7457E
		move.b	SMPS_Track.PanLimit(a5),d3
		cmp.b	SMPS_Track.PanStart(a5),d3
		bpl.s	loc_74576
		cmpi.b	#2,SMPS_Track.PanNumber(a5)
		beq.s	locret_745AE
		clr.b	SMPS_Track.PanStart(a5)

loc_74576:
		clr.b	SMPS_Track.PanContinue(a5)
		addq.b	#1,SMPS_Track.PanStart(a5)

loc_7457E:
		moveq	#0,d0
		move.b	SMPS_Track.PanTable(a5),d0
		subq.w	#1,d0
		lsl.w	#2,d0
		movea.l	FMPan_Table(pc,d0.w),a0
		moveq	#0,d0
		move.b	SMPS_Track.PanStart(a5),d0
		subq.w	#1,d0
		move.b	(a0,d0.w),d1
		move.b	SMPS_Track.AMSFMSPan(a5),d0
		andi.b	#$37,d0
		or.b	d0,d1
		move.b	#$B4,d0
		jsr	WriteFMIorIIMain(pc)
		addq.b	#1,SMPS_Track.PanContinue(a5)

locret_745AE:
		rts
; ===========================================================================

FMPan_Table:
		dc.l FMPan_1_Data
		dc.l FMPan_2_Data
		dc.l FMPan_3_Data
FMPan_1_Data:
		dc.b $40, $80
FMPan_2_Data:
		dc.b $40, $C0, $80
FMPan_3_Data:
		dc.b $C0, $80, $C0, $40
		even
; ===========================================================================

PauseMusic:
		bmi.s	.unpausemusic				; Branch if music is being unpaused
		cmpi.b	#2,SMPS_RAM.f_pausemusic(a6)
		beq.w	.unpausedallfm
		move.b	#2,SMPS_RAM.f_pausemusic(a6)
		moveq	#2,d2
		move.b	#$B4,d0					; Command to set AMS/FMS/panning
		moveq	#0,d1					; No panning, AMS or FMS

.killpanloop:
		jsr	WriteFMI(pc)
		jsr	WriteFMII(pc)
		addq.b	#1,d0
		dbf	d2,.killpanloop

		moveq	#2,d2
		moveq	#$28,d0					; Key on/off register

.noteoffloop:
		move.b	d2,d1					; FM1, FM2, FM3
		jsr	WriteFMI(pc)
		addq.b	#4,d1					; FM4, FM5, FM6
		jsr	WriteFMI(pc)
		dbf	d2,.noteoffloop

		jsr	PSGSilenceAll(pc)
		bra.w	DoStartZ80
; ===========================================================================

.unpausemusic:
		clr.b	SMPS_RAM.f_pausemusic(a6)
		moveq	#SMPS_Track.len,d3
		lea	SMPS_RAM.v_music_fmdac_tracks(a6),a5
		moveq	#SMPS_MUSIC_FM_DAC_TRACK_COUNT-1,d4	; 6 FM + 1 DAC tracks

.bgmfmloop:
		btst	#7,SMPS_Track.PlaybackControl(a5)	; Is track playing?
		beq.s	.bgmfmnext				; Branch if not
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is track being overridden?
		bne.s	.bgmfmnext				; Branch if yes
		move.b	#$B4,d0					; Command to set AMS/FMS/panning
		move.b	SMPS_Track.AMSFMSPan(a5),d1		; Get value from track RAM
		jsr	WriteFMIorII(pc)

.bgmfmnext:
		adda.w	d3,a5
		dbf	d4,.bgmfmloop

		lea	SMPS_RAM.v_sfx_fm_tracks(a6),a5
		moveq	#SMPS_SFX_FM_TRACK_COUNT-1,d4		; 3 FM tracks (SFX)

.sfxfmloop:
		btst	#7,SMPS_Track.PlaybackControl(a5)	; Is track playing?
		beq.s	.sfxfmnext				; Branch if not
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is track being overridden?
		bne.s	.sfxfmnext				; Branch if yes
		move.b	#$B4,d0					; Command to set AMS/FMS/panning
		move.b	SMPS_Track.AMSFMSPan(a5),d1		; Get value from track RAM
		jsr	WriteFMIorII(pc)

.sfxfmnext:
		adda.w	d3,a5
		dbf	d4,.sfxfmloop

		lea	SMPS_RAM.v_spcsfx_track_ram(a6),a5
		btst	#7,SMPS_Track.PlaybackControl(a5)	; Is track playing?
		beq.s	.unpausedallfm				; Branch if not
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is track being overridden?
		bne.s	.unpausedallfm				; Branch if yes
		move.b	#$B4,d0					; Command to set AMS/FMS/panning
		move.b	SMPS_Track.AMSFMSPan(a5),d1		; Get value from track RAM
		jsr	WriteFMIorII(pc)

.unpausedallfm:
		bra.w	DoStartZ80

; ---------------------------------------------------------------------------
; Subroutine to play a sound or music track
; ---------------------------------------------------------------------------

; Sound_Play:
CycleSoundQueue:
		movea.l	(Go_SoundPriorities).l,a0
		lea	SMPS_RAM.v_soundqueue0(a6),a1		; load music track number
		_move.b	SMPS_RAM.v_sndprio(a6),d3		; Get priority of currently playing SFX
		moveq	#SMPS_RAM.v_soundqueue_end-SMPS_RAM.v_soundqueue_start-1,d4 ; number of soundqueues

.inputloop:
		move.b	(a1),d0					; move track number to d0
		move.b	d0,d1
		clr.b	(a1)+					; Clear entry
		subi.b	#bgm__First,d0				; Make it into 0-based index
		blo.s	.nextinput				; If negative (i.e., it was $80 or lower), branch
		andi.w	#$7F,d0					; Clear high byte and sign bit
		move.b	(a0,d0.w),d2				; Get sound type
		cmp.b	d3,d2					; Is it a lower priority sound?
		blo.s	.nextinput
		move.b	d2,d3					; Store new priority
		move.b	d1,SMPS_RAM.v_sound_id(a6)		; Queue sound for playing

.nextinput:
		dbf	d4,.inputloop

		tst.b	d3					; We don't want to change sound priority if it is negative
		bmi.s	PlaySoundID
		_move.b	d3,SMPS_RAM.v_sndprio(a6)		; Set new sound priority
; End of function CycleSoundQueue

; ===========================================================================

; Sound_ChkValue:
PlaySoundID:
		moveq	#0,d7
		move.b	SMPS_RAM.v_sound_id(a6),d7
		move.b	#$80,SMPS_RAM.v_sound_id(a6)
		cmpi.b	#$80,d7					; is sound id negative?
		beq.s	.nosound				; if equal to negative, branch
		blo.w	StopAllSound				; if lower than negative, stop all sound
	if FixBugs
		cmpi.b	#bgm__Last,d7				; is this music?
	else
		; Bug: Should not include +$E, all entries after $91 up to $9F will try to be played even though the slots aren't occupied by any music
		; Luckily, there is a workaround for this bug in LevelSelect, but even there it's bugged.
		cmpi.b	#bgm__Last+$E,d7			; is this music?
	endif
		bls.w	Sound_PlayBGM				; if so, branch
		cmpi.b	#sfx__First,d7				; is this between music and sfx?
		blo.w	.nosound				; if so, branch
		cmpi.b	#sfx__Last,d7				; is this sfx?
		bls.w	Sound_PlaySFX				; if so, branch
		cmpi.b	#spec__First,d7				; is this between sfx and special sfx?
		blo.w	.nosound				; if so, branch
		cmpi.b	#dac__First,d7				; is this between special sfx and dac?
		blo.w	Sound_PlaySpecial			; if so, branch
		cmpi.b	#flg__First,d7				; is this between dac and sound commands?
		blo.s	Sound_PlayDAC				; if so, branch
	if FixBugs
		cmpi.b	#flg__Last,d7				; is this sound commands?
	else
		; Bug: Should not include +1
		cmpi.b	#flg__Last+1,d7				; is this sound commands?
	endif
		bls.s	Sound_E0toE4				; if so, branch

.nosound:
		rts
; ===========================================================================

Sound_E0toE4:
		subi.b	#flg__First,d7
		lsl.w	#2,d7
		jmp	Sound_ExIndex(pc,d7.w)
; ===========================================================================
Sound_ExIndex:
ptr_flgE0:	bra.w	FadeOutMusic				; $E0
ptr_flgE1:	bra.w	StopSFX					; $E1
ptr_flgE2:	bra.w	SpeedUpMusic				; $E2
ptr_flgE3:	bra.w	SlowDownMusic				; $E3
ptr_flgE4:	bra.w	StopSpecialSFX				; $E4
ptr_flgend:
; ===========================================================================

Sound_PlayDAC:
		addi.b	#$88-dac__First,d7
		move.b	d7,(z80_ram+zDAC_Sample).l
		nop
		nop
		nop
		clr.b	(a0)+
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Play music track $81-$9F
; ---------------------------------------------------------------------------
; Sound_81to9F:
Sound_PlayBGM:
		cmpi.b	#bgm_ExtraLife,d7			; is the "extra life" music to be played?
		bne.s	.bgmnot1up				; if not, branch
		tst.b	SMPS_RAM.f_1up_playing(a6)		; Is a 1-up music playing?
		bne.w	.return					; if yes, branch
		lea	SMPS_RAM.v_music_track_ram(a6),a5
		moveq	#SMPS_MUSIC_TRACK_COUNT-1,d0		; 1 DAC + 6 FM + 3 PSG tracks

.clearsfxloop:
		bclr	#2,SMPS_Track.PlaybackControl(a5)	; Clear 'SFX is overriding' bit
		adda.w	#SMPS_Track.len,a5
		dbf	d0,.clearsfxloop

		lea	SMPS_RAM.v_sfx_track_ram(a6),a5
		moveq	#SMPS_SFX_TRACK_COUNT-1,d0		; 3 FM + 3 PSG tracks (SFX)

.cleartrackplayloop:
		bclr	#7,SMPS_Track.PlaybackControl(a5)	; Clear 'track is playing' bit
		adda.w	#SMPS_Track.len,a5
		dbf	d0,.cleartrackplayloop

		movea.l	a6,a0
		lea	SMPS_RAM.v_1up_ram_copy(a6),a1
		move.w	#(SMPS_RAM.v_1up_ram_end-SMPS_RAM.v_1up_ram)/4-1,d0 ; Backup $220 bytes: all variables and music track data

.backupramloop:
		move.l	(a0)+,(a1)+
		dbf	d0,.backupramloop

		move.b	#$80,SMPS_RAM.f_1up_playing(a6)
		_clr.b	SMPS_RAM.v_sndprio(a6)			; Clear priority
		bra.s	.bgm_loadMusic
; ===========================================================================

.bgmnot1up:
		clr.b	SMPS_RAM.f_1up_playing(a6)
		clr.b	SMPS_RAM.v_fadein_counter(a6)

.bgm_loadMusic:
		jsr	InitMusicPlayback(pc)
		movea.l	(Go_SpeedUpIndex).l,a4
		subi.b	#bgm__First,d7
		move.b	(a4,d7.w),SMPS_RAM.v_speeduptempo(a6)
		movea.l	(Go_MusicIndex).l,a4
		lsl.w	#2,d7
		movea.l	(a4,d7.w),a4				; a4 now points to (uncompressed) song data
		moveq	#0,d0
		move.w	(a4),d0					; load voice pointer
		add.l	a4,d0					; It is a relative pointer
		move.l	d0,SMPS_RAM.v_voice_ptr(a6)
		move.b	5(a4),d0				; load tempo
		move.b	d0,SMPS_RAM.v_tempo_mod(a6)
		tst.b	SMPS_RAM.f_speedup(a6)
		beq.s	.nospeedshoes
		move.b	SMPS_RAM.v_speeduptempo(a6),d0

.nospeedshoes:
		move.b	d0,SMPS_RAM.v_main_tempo(a6)
		move.b	d0,SMPS_RAM.v_main_tempo_timeout(a6)
		moveq	#0,d1
		movea.l	a4,a3
		addq.w	#6,a4					; Point past header
	if FixBugs
		; Fix the 0FM/DAC fade-in bug
		; https://info.sonicretro.org/SCHG_How-to:Fix_Song_Restoration_Bugs_in_Sonic_1%27s_Sound_Driver
		move.b	4(a3),d4				; load tempo dividing timing
		moveq	#SMPS_Track.len,d6
		moveq	#0,d7
		move.b	#1,d5					; Note duration for first "note"
		move.b	2(a3),d7				; load number of FM+DAC tracks
		beq.w	.bgm_fmdone				; branch if zero
		subq.b	#1,d7
		move.b	#$C0,d1					; Default AMS+FMS+Panning
	else
		moveq	#0,d7
		move.b	2(a3),d7				; load number of FM+DAC tracks
		beq.w	.bgm_fmdone				; branch if zero
		subq.b	#1,d7
		move.b	#$C0,d1					; Default AMS+FMS+Panning
		move.b	4(a3),d4				; load tempo dividing timing
		moveq	#SMPS_Track.len,d6
		move.b	#1,d5					; Note duration for first "note"
	endif
		lea	SMPS_RAM.v_music_fmdac_tracks(a6),a1
		lea	FMDACInitBytes(pc),a2

.bgm_fmloadloop:
		bset	#7,SMPS_Track.PlaybackControl(a1)	; Initial playback control: set 'track playing' bit
		move.b	(a2)+,SMPS_Track.VoiceControl(a1)	; Voice control bits
		move.b	d4,SMPS_Track.TempoDivider(a1)
		move.b	d6,SMPS_Track.StackPointer(a1)		; set "gosub" (coord flag $F8) stack init value
		move.b	d1,SMPS_Track.AMSFMSPan(a1)		; Set AMS/FMS/Panning
		move.b	d5,SMPS_Track.DurationTimeout(a1)	; Set duration of first "note"
		moveq	#0,d0
		move.w	(a4)+,d0				; load DAC/FM pointer
		add.l	a3,d0					; Relative pointer
		move.l	d0,SMPS_Track.DataPointer(a1)		; Store track pointer
		move.w	(a4)+,SMPS_Track.Transpose(a1)		; load FM channel modifier
		adda.w	d6,a1
		dbf	d7,.bgm_fmloadloop

		cmpi.b	#7,2(a3)				; Are 7 FM tracks defined?
		bne.s	.silencefm6
		moveq	#$2B,d0					; DAC enable/disable register
		moveq	#0,d1					; Disable DAC
		jsr	WriteFMI(pc)
		bra.w	.bgm_fmdone
; ===========================================================================

.silencefm6:
		moveq	#$28,d0					; Key on/off register
		moveq	#6,d1					; Note off on all operators of channel 6
		jsr	WriteFMI(pc)
		move.b	#$42,d0					; TL for operator 1 of FM6
		moveq	#$7F,d1					; Total silence
		jsr	WriteFMII(pc)
		move.b	#$4A,d0					; TL for operator 3 of FM6
		moveq	#$7F,d1					; Total silence
		jsr	WriteFMII(pc)
		move.b	#$46,d0					; TL for operator 2 of FM6
		moveq	#$7F,d1					; Total silence
		jsr	WriteFMII(pc)
		move.b	#$4E,d0					; TL for operator 4 of FM6
		moveq	#$7F,d1					; Total silence
		jsr	WriteFMII(pc)
		move.b	#$B6,d0					; AMS/FMS/panning of FM6
		move.b	#$C0,d1					; Stereo
		jsr	WriteFMII(pc)

.bgm_fmdone:
		moveq	#0,d7
		move.b	3(a3),d7				; Load number of PSG tracks
		beq.s	.bgm_psgdone				; branch if zero
		subq.b	#1,d7
		lea	SMPS_RAM.v_music_psg_tracks(a6),a1
		lea	PSGInitBytes(pc),a2

.bgm_psgloadloop:
		bset	#7,SMPS_Track.PlaybackControl(a1)	; Initial playback control: set 'track playing' bit
		move.b	(a2)+,SMPS_Track.VoiceControl(a1)	; Voice control bits
		move.b	d4,SMPS_Track.TempoDivider(a1)
		move.b	d6,SMPS_Track.StackPointer(a1)		; set "gosub" (coord flag $F8) stack init value
		move.b	d5,SMPS_Track.DurationTimeout(a1)	; Set duration of first "note"
		moveq	#0,d0
		move.w	(a4)+,d0				; load PSG channel pointer
		add.l	a3,d0					; Relative pointer
		move.l	d0,SMPS_Track.DataPointer(a1)		; Store track pointer
		move.w	(a4)+,SMPS_Track.Transpose(a1)		; load PSG modifier
		move.b	(a4)+,d0				; load redundant byte
		move.b	(a4)+,SMPS_Track.VoiceIndex(a1)		; Initial PSG tone
		adda.w	d6,a1
		dbf	d7,.bgm_psgloadloop

.bgm_psgdone:
		lea	SMPS_RAM.v_sfx_track_ram(a6),a1
		moveq	#SMPS_SFX_TRACK_COUNT-1,d7		; 6 SFX tracks

.sfxstoploop:
		tst.b	SMPS_Track.PlaybackControl(a1)		; Is SFX playing?
		bpl.w	.sfxnext				; Branch if not
		moveq	#0,d0
		move.b	SMPS_Track.VoiceControl(a1),d0		; Get voice control bits
		bmi.s	.sfxpsgchannel				; Branch if this is a PSG channel
		subq.b	#2,d0					; SFX can't have FM1 or FM2
		lsl.b	#2,d0					; Convert to index
		bra.s	.gotchannelindex
; ===========================================================================

.sfxpsgchannel:
		lsr.b	#3,d0					; Convert to index

.gotchannelindex:
		lea	SFX_BGMChannelRAM(pc),a0
		movea.l	(a0,d0.w),a0
		bset	#2,SMPS_Track.PlaybackControl(a0)	; Set 'SFX is overriding' bit

.sfxnext:
		adda.w	d6,a1
		dbf	d7,.sfxstoploop

	if FixBugs
		tst.b	SMPS_RAM.v_spcsfx_fm4_track.PlaybackControl(a6)	; Is special SFX being played?
	else
		; Bug: This checks for both PlaybackControl and VoiceControl, when it should only be doing PlaybackControl.
		tst.w	SMPS_RAM.v_spcsfx_fm4_track.PlaybackControl(a6)	; Is special SFX being played?
	endif
		bpl.s	.checkspecialpsg			; Branch if not
		bset	#2,SMPS_RAM.v_music_fm4_track.PlaybackControl(a6) ; Set 'SFX is overriding' bit

.checkspecialpsg:
	if FixBugs
		tst.b	SMPS_RAM.v_spcsfx_psg3_track.PlaybackControl(a6) ; Is special SFX being played?
	else
		; Bug: This checks for both PlaybackControl and VoiceControl, when it should only be doing PlaybackControl.
		tst.w	SMPS_RAM.v_spcsfx_psg3_track.PlaybackControl(a6) ; Is special SFX being played?
	endif
		bpl.s	.sendfmnoteoff				; Branch if not
		bset	#2,SMPS_RAM.v_music_psg3_track.PlaybackControl(a6) ; Set 'SFX is overriding' bit

.sendfmnoteoff:
		lea	SMPS_RAM.v_music_fm_tracks(a6),a5
		moveq	#SMPS_MUSIC_FM_TRACK_COUNT-1,d4		; 6 FM tracks

.fmnoteoffloop:
		jsr	FMNoteOff(pc)
		adda.w	d6,a5
		dbf	d4,.fmnoteoffloop			; run all FM tracks
		moveq	#SMPS_MUSIC_PSG_TRACK_COUNT-1,d4	; 3 PSG tracks

.psgnoteoffloop:
		jsr	PSGNoteOff(pc)
		adda.w	d6,a5
		dbf	d4,.psgnoteoffloop			; run all PSG tracks

.return:
		addq.w	#4,sp					; Tamper with return value to not return to caller
		rts
; ===========================================================================

FMDACInitBytes:	dc.b 6, 0, 1, 2, 4, 5, 6			; first byte is for DAC; then notice the 0, 1, 2 then 4, 5, 6; this is the gap between parts I and II for YM2612 port writes
		even
PSGInitBytes:	dc.b $80, $A0, $C0				; Specifically, these configure writes to the PSG port for each channel
		even
; ===========================================================================
; ---------------------------------------------------------------------------
; Play normal sound effect
; ---------------------------------------------------------------------------
; Sound_A0toCF:
Sound_PlaySFX:
		tst.b	SMPS_RAM.f_1up_playing(a6)		; Is 1-up playing?
		bne.w	.return					; Exit is it is
		cmpi.b	#sfx_Ring,d7				; is ring sound effect played?
		bne.s	.sfx_notRing				; if not, branch
		tst.b	SMPS_RAM.v_ring_speaker(a6)		; Is the ring sound playing on right speaker?
		bne.s	.gotringspeaker				; Branch if not
		move.b	#sfx_RingLeft,d7			; play ring sound in left speaker

.gotringspeaker:
		bchg	#0,SMPS_RAM.v_ring_speaker(a6)		; change speaker
; Sound_notB5:
.sfx_notRing:
		cmpi.b	#sfx_Push,d7				; is "pushing" sound played?
		bne.s	.sfx_notPush				; if not, branch
		tst.b	SMPS_RAM.f_push_playing(a6)		; Is pushing sound already playing?
		bne.w	.return					; Return if not
		move.b	#$80,SMPS_RAM.f_push_playing(a6)	; Mark it as playing
; Sound_notA7:
.sfx_notPush:
		movea.l	(Go_SoundIndex).l,a0
		subi.b	#sfx__First,d7				; Make it 0-based
		lsl.w	#2,d7					; Convert sfx ID into index
		movea.l	(a0,d7.w),a3				; SFX data pointer
		movea.l	a3,a1
		moveq	#0,d0
		move.w	(a1)+,d0				; Voice pointer
		add.l	a3,d0					; Relative pointer
		move.l	d0,SMPS_RAM.v_lfo_voice_ptr(a6)
		move.b	(a1)+,d5				; Dividing timing
	if FixBugs
		moveq	#0,d7
	else
		; DANGER! There is a missing 'moveq	#0,d7' here, without which SFXes whose
		; index entry is above $3F will cause a crash.
		; This bug is fixed in Ristar's driver.
	endif
		move.b	(a1)+,d7				; Number of tracks (FM + PSG)
		subq.b	#1,d7
		moveq	#SMPS_Track.len,d6

.sfx_loadloop:
		moveq	#0,d3
		move.b	SMPS_Track.VoiceControl(a1),d3		; Channel assignment bits
		move.b	d3,d4
		bmi.s	.sfxinitpsg				; Branch if PSG
		subq.w	#2,d3					; SFX can only have FM3, FM4 or FM5
		lsl.w	#2,d3
		lea	SFX_BGMChannelRAM(pc),a5
		movea.l	(a5,d3.w),a5
		bset	#2,SMPS_Track.PlaybackControl(a5)	; Mark music track as being overridden
		bra.s	.sfxoverridedone
; ===========================================================================

.sfxinitpsg:
		lsr.w	#3,d3
		movea.l	SFX_BGMChannelRAM(pc,d3.w),a5
		bset	#2,SMPS_Track.PlaybackControl(a5)	; Mark music track as being overridden
		cmpi.b	#$C0,d4					; Is this PSG 3?
		bne.s	.sfxoverridedone			; Branch if not
		move.b	d4,d0
		ori.b	#$1F,d0					; Command to silence PSG 3
		move.b	d0,(psg_input).l
		bchg	#5,d0					; Command to silence noise channel
		move.b	d0,(psg_input).l

.sfxoverridedone:
		movea.l	SFX_SFXChannelRAM(pc,d3.w),a5
		movea.l	a5,a2
		moveq	#(SMPS_Track.len)/4-1,d0		; $30 bytes

.clearsfxtrackram:
		clr.l	(a2)+
		dbf	d0,.clearsfxtrackram

		move.w	(a1)+,SMPS_Track.PlaybackControl(a5)	; Initial playback control bits
		move.b	d5,SMPS_Track.TempoDivider(a5)		; Initial voice control bits
		moveq	#0,d0
		move.w	(a1)+,d0				; Track data pointer
		add.l	a3,d0					; Relative pointer
		move.l	d0,SMPS_Track.DataPointer(a5)		; Store track pointer
		move.w	(a1)+,SMPS_Track.Transpose(a5)		; load FM/PSG channel modifier
		move.b	#1,SMPS_Track.DurationTimeout(a5)	; Set duration of first "note"
		move.b	d6,SMPS_Track.StackPointer(a5)		; set "gosub" (coord flag $F8) stack init value
		tst.b	d4					; Is this a PSG channel?
		bmi.s	.sfxpsginitdone				; Branch if yes
		move.b	#$C0,SMPS_Track.AMSFMSPan(a5)		; AMS/FMS/Panning

.sfxpsginitdone:
		dbf	d7,.sfx_loadloop

		tst.b	SMPS_RAM.v_sfx_fm4_track.PlaybackControl(a6) ; Is special SFX being played?
		bpl.s	.doneoverride				; Branch if not
		bset	#2,SMPS_RAM.v_spcsfx_fm4_track.PlaybackControl(a6) ; Set 'SFX is overriding' bit

.doneoverride:
		tst.b	SMPS_RAM.v_sfx_psg3_track.PlaybackControl(a6) ; Is SFX being played?
		bpl.s	.return					; Branch if not
		bset	#2,SMPS_RAM.v_spcsfx_psg3_track.PlaybackControl(a6) ; Set 'SFX is overriding' bit

.return:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; RAM addresses for FM and PSG channel variables used by the SFX
; ---------------------------------------------------------------------------

SFX_BGMChannelRAM:
		dc.l (v_snddriver_ram.v_music_fm3_track)&$FFFFFF
		dc.l 0
		dc.l (v_snddriver_ram.v_music_fm4_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_music_fm5_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_music_psg1_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_music_psg2_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_music_psg3_track)&$FFFFFF ; Plain PSG3
		dc.l (v_snddriver_ram.v_music_psg3_track)&$FFFFFF ; Noise

SFX_SFXChannelRAM:
		dc.l (v_snddriver_ram.v_sfx_fm3_track)&$FFFFFF
		dc.l 0
		dc.l (v_snddriver_ram.v_sfx_fm4_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_sfx_fm5_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_sfx_psg1_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_sfx_psg2_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_sfx_psg3_track)&$FFFFFF ; Plain PSG3
		dc.l (v_snddriver_ram.v_sfx_psg3_track)&$FFFFFF ; Noise
; ===========================================================================
; ---------------------------------------------------------------------------
; Play GHZ waterfall sound
; ---------------------------------------------------------------------------
; Sound_D0toDF:
Sound_PlaySpecial:
		tst.b	SMPS_RAM.f_1up_playing(a6)		; Is 1-up playing?
		bne.w	.locret					; Return if so
		movea.l	(Go_SpecSoundIndex).l,a0
		subi.b	#spec__First,d7				; Make it 0-based
		lsl.w	#2,d7
		movea.l	(a0,d7.w),a3
		movea.l	a3,a1
		moveq	#0,d0
		move.w	(a1)+,d0				; Voice pointer
		add.l	a3,d0					; Relative pointer
		move.l	d0,SMPS_RAM.v_special_voice_ptr(a6)	; Store voice pointer
		move.b	(a1)+,d5				; Dividing timing
	if FixBugs
		moveq	#0,d7
	else
		; Bug: There is a missing 'moveq	#0,d7' here, without which special SFXes whose
		; index entry is above $3F will cause a crash. This instance was not fixed in Ristar's driver.
	endif
		move.b	(a1)+,d7				; Number of tracks (FM + PSG)
		subq.b	#1,d7
		moveq	#SMPS_Track.len,d6

.sfxloadloop:
		move.b	SMPS_Track.VoiceControl(a1),d4		; Voice control bits
		bmi.s	.sfxoverridepsg				; Branch if PSG
		bset	#2,SMPS_RAM.v_music_fm4_track.PlaybackControl(a6) ; Set 'SFX is overriding' bit
		lea	SMPS_RAM.v_spcsfx_fm4_track(a6),a5
		bra.s	.sfxinitpsg
; ===========================================================================

.sfxoverridepsg:
		bset	#2,SMPS_RAM.v_music_psg3_track.PlaybackControl(a6) ; Set 'SFX is overriding' bit
		lea	SMPS_RAM.v_spcsfx_psg3_track(a6),a5

.sfxinitpsg:
		movea.l	a5,a2
		moveq	#(SMPS_Track.len)/4-1,d0		; $30 bytes

.clearsfxtrackram:
		clr.l	(a2)+
		dbf	d0,.clearsfxtrackram

		move.w	(a1)+,SMPS_Track.PlaybackControl(a5)	; Initial playback control bits & voice control bits (TrackPlaybackControl)
		move.b	d5,SMPS_Track.TempoDivider(a5)
		moveq	#0,d0
		move.w	(a1)+,d0				; Track data pointer
		add.l	a3,d0					; Relative pointer
		move.l	d0,SMPS_Track.DataPointer(a5)		; Store track pointer
		move.w	(a1)+,SMPS_Track.Transpose(a5)		; load FM/PSG channel modifier
		move.b	#1,SMPS_Track.DurationTimeout(a5)	; Set duration of first "note"
		move.b	d6,SMPS_Track.StackPointer(a5)		; set "gosub" (coord flag $F8) stack init value
		tst.b	d4					; Is this a PSG channel?
		bmi.s	.sfxpsginitdone				; Branch if yes
		move.b	#$C0,SMPS_Track.AMSFMSPan(a5)		; AMS/FMS/Panning

.sfxpsginitdone:
		dbf	d7,.sfxloadloop

		tst.b	SMPS_RAM.v_sfx_fm4_track.PlaybackControl(a6) ; Is track playing?
		bpl.s	.doneoverride				; Branch if not
		bset	#2,SMPS_RAM.v_spcsfx_fm4_track.PlaybackControl(a6) ; Set 'SFX is overriding' bit

.doneoverride:
		tst.b	SMPS_RAM.v_sfx_psg3_track.PlaybackControl(a6) ; Is track playing?
		bpl.s	.locret					; Branch if not
		bset	#2,SMPS_RAM.v_spcsfx_psg3_track.PlaybackControl(a6) ; Set 'SFX is overriding' bit
		ori.b	#$1F,d4					; Command to silence channel
		move.b	d4,(psg_input).l
		bchg	#5,d4					; Command to silence noise channel
		move.b	d4,(psg_input).l

.locret:
		rts
; End of function PlaySoundID

; ===========================================================================
; ---------------------------------------------------------------------------
; Unused RAM addresses for FM and PSG channel variables used by the Special SFX
; ---------------------------------------------------------------------------
; The first block would have been used for overriding the music tracks
; as they have a lower priority, just as they are in Sound_PlaySFX
; The third block would be used to set up the Special SFX
; The second block, however, is for the SFX tracks, which have a higher priority
; and would be checked for if they're currently playing
; If they are, then the third block would be used again, this time to mark
; the new tracks as 'currently playing'

; These were actually used in Moonwalker's driver (and other SMPS 68k Type 1a drivers)

; BGMFM4PSG3RAM:
;SpecSFX_BGMChannelRAM:
		dc.l (v_snddriver_ram.v_music_fm4_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_music_psg3_track)&$FFFFFF
; SFXFM4PSG3RAM:
;SpecSFX_SFXChannelRAM:
		dc.l (v_snddriver_ram.v_sfx_fm4_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_sfx_psg3_track)&$FFFFFF
; SpecialSFXFM4PSG3RAM:
;SpecSFX_SpecSFXChannelRAM:
		dc.l (v_snddriver_ram.v_spcsfx_fm4_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_spcsfx_psg3_track)&$FFFFFF

; ===========================================================================

; Snd_FadeOut1: Snd_FadeOutSFX: FadeOutSFX:
StopSFX:
		_clr.b	SMPS_RAM.v_sndprio(a6)
		moveq	#$27,d0
		moveq	#0,d1
		jsr	WriteFMI(pc)
		lea	SMPS_RAM.v_sfx_track_ram(a6),a5
		moveq	#SMPS_SFX_TRACK_COUNT-1,d7		; 3 FM + 3 PSG tracks (SFX)

.trackloop:
		tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
		bpl.w	.nexttrack				; Branch if not
		bclr	#7,SMPS_Track.PlaybackControl(a5)	; Stop track
		moveq	#0,d3
		move.b	SMPS_Track.VoiceControl(a5),d3		; Get voice control bits
		bmi.s	.trackpsg				; Branch if PSG
		jsr	FMNoteOff(pc)
		cmpi.b	#4,d3					; Is this FM4?
		bne.s	.getfmpointer				; Branch if not
		tst.b	SMPS_RAM.v_spcsfx_fm4_track.PlaybackControl(a6) ; Is special SFX playing?
		bpl.s	.getfmpointer				; Branch if not
	if FixBugs
		movea.l	a5,a3
	else
		; Bug: There is a missing 'movea.l	a5,a3' here, without which the
		; code is broken. It is dangerous to do a fade out when a GHZ waterfall
		; is playing its sound
	endif
		lea	SMPS_RAM.v_spcsfx_fm4_track(a6),a5
		movea.l	SMPS_RAM.v_special_voice_ptr(a6),a1	; Get special voice pointer
		bra.s	.gotfmpointer
; ===========================================================================

.getfmpointer:
		subq.b	#2,d3					; SFX only has FM3 and up
		lsl.b	#2,d3
		lea	SFX_BGMChannelRAM(pc),a0
		movea.l	a5,a3
		movea.l	(a0,d3.w),a5
		movea.l	SMPS_RAM.v_voice_ptr(a6),a1		; Get music voice pointer

.gotfmpointer:
		bclr	#2,SMPS_Track.PlaybackControl(a5)	; Clear 'SFX is overriding' bit
		bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
	if FixBugs
		moveq	#0,d0
	else
		; DANGER! `SetVoice` expects d0 to be a word, but it's only passed
		; as a byte below. This may result in restoring invalid/broken FM
		; voices during fade out sequence if upper byte of d0 was trashed.
	endif
		move.b	SMPS_Track.VoiceIndex(a5),d0		; Current voice
		jsr	SetVoice(pc)
		movea.l	a3,a5
		bra.s	.nexttrack
; ===========================================================================

.trackpsg:
		jsr	PSGNoteOff(pc)
		lea	SMPS_RAM.v_spcsfx_psg3_track(a6),a0
	if FixBugs
		; cfStopTrack does this check but this function oddly lacks it.
		tst.b	SMPS_Track.PlaybackControl(a0)		; Is track playing?
		bpl.s	.getchannelptr				; Branch if not
	endif
		cmpi.b	#$E0,d3					; Is this a noise channel?
		beq.s	.gotpsgpointer				; Branch if yes
		cmpi.b	#$C0,d3					; Is this PSG 3?
		beq.s	.gotpsgpointer				; Branch if yes

.getchannelptr:
		lsr.b	#3,d3
		lea	SFX_BGMChannelRAM(pc),a0
		movea.l	(a0,d3.w),a0

.gotpsgpointer:
		bclr	#2,SMPS_Track.PlaybackControl(a0)	; Clear 'SFX is overriding' bit
		bset	#1,SMPS_Track.PlaybackControl(a0)	; Set 'track at rest' bit
		cmpi.b	#$E0,SMPS_Track.VoiceControl(a0)	; Is this a noise channel?
		bne.s	.nexttrack				; Branch if not
		move.b	SMPS_Track.PSGNoise(a0),(psg_input).l	; Set noise type

.nexttrack:
		adda.w	#SMPS_Track.len,a5
		dbf	d7,.trackloop

		rts
; End of function StopSFX

; ===========================================================================

; Snd_FadeOut2: FadeOutSFX2: FadeOutSpecialSFX:
StopSpecialSFX:
		lea	SMPS_RAM.v_spcsfx_fm4_track(a6),a5
		tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
		bpl.s	.fadedfm				; Branch if not
		bclr	#7,SMPS_Track.PlaybackControl(a5)	; Stop track
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is SFX overriding?
		bne.s	.fadedfm				; Branch if not
		jsr	SendFMNoteOff(pc)
		lea	SMPS_RAM.v_music_fm4_track(a6),a5
		bclr	#2,SMPS_Track.PlaybackControl(a5)	; Clear 'SFX is overriding' bit
		bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
		tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
		bpl.s	.fadedfm				; Branch if not
		movea.l	SMPS_RAM.v_voice_ptr(a6),a1		; Voice pointer
	if FixBugs
		moveq	#0,d0
	else
		; DANGER! `SetVoice` expects d0 to be a word, but it's only passed
		; as a byte below. This may result in restoring invalid/broken FM
		; voices during fade out sequence if upper byte of d0 was trashed.
	endif
		move.b	SMPS_Track.VoiceIndex(a5),d0		; Current voice
		jsr	SetVoice(pc)

.fadedfm:
		lea	SMPS_RAM.v_spcsfx_psg3_track(a6),a5
		tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
		bpl.s	.fadedpsg				; Branch if not
		bclr	#7,SMPS_Track.PlaybackControl(a5)	; Stop track
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is SFX overriding?
		bne.s	.fadedpsg				; Return if not
		jsr	SendPSGNoteOff(pc)
		lea	SMPS_RAM.v_music_psg3_track(a6),a5
		bclr	#2,SMPS_Track.PlaybackControl(a5)	; Clear 'SFX is overriding' bit
		bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
		tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
		bpl.s	.fadedpsg				; Return if not
		cmpi.b	#$E0,SMPS_Track.VoiceControl(a5)	; Is this a noise channel?
		bne.s	.fadedpsg				; Return if not
		move.b	SMPS_Track.PSGNoise(a5),(psg_input).l	; Set noise type

.fadedpsg:
		rts
; End of function StopSpecialSFX

; ===========================================================================
; ---------------------------------------------------------------------------
; Fade out music
; ---------------------------------------------------------------------------
; Sound_E0:
FadeOutMusic:
		jsr	StopSFX(pc)
		jsr	StopSpecialSFX(pc)
		move.b	#3,SMPS_RAM.v_fadeout_delay(a6)		; Set fadeout delay to 3
		move.b	#$28,SMPS_RAM.v_fadeout_counter(a6)	; Set fadeout counter
		clr.b	SMPS_RAM.v_music_dac_track.PlaybackControl(a6) ; Stop DAC track
		clr.b	SMPS_RAM.f_speedup(a6)			; Disable speed shoes tempo
		rts

; ===========================================================================

DoFadeOut:
		move.b	SMPS_RAM.v_fadeout_delay(a6),d0		; Has fadeout delay expired?
		beq.s	.continuefade				; Branch if yes
		subq.b	#1,SMPS_RAM.v_fadeout_delay(a6)
		rts
; ===========================================================================

.continuefade:
		subq.b	#1,SMPS_RAM.v_fadeout_counter(a6)	; Update fade counter
		beq.w	StopAllSound				; Branch if fade is done
		move.b	#3,SMPS_RAM.v_fadeout_delay(a6)		; Reset fade delay
		lea	SMPS_RAM.v_music_fm_tracks(a6),a5
		moveq	#SMPS_MUSIC_FM_TRACK_COUNT-1,d7		; 6 FM tracks

.fmloop:
		tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
		bpl.s	.nextfm					; Branch if not
		addq.b	#1,SMPS_Track.Volume(a5)		; Increase volume attenuation
		bpl.s	.sendfmtl				; Branch if still positive
		bclr	#7,SMPS_Track.PlaybackControl(a5)	; Stop track
		bra.s	.nextfm
; ===========================================================================

.sendfmtl:
		jsr	SendVoiceTL(pc)

.nextfm:
		adda.w	#SMPS_Track.len,a5
		dbf	d7,.fmloop

		moveq	#SMPS_MUSIC_PSG_TRACK_COUNT-1,d7	; 3 PSG tracks

.psgloop:
		tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
		bpl.s	.nextpsg				; branch if not
		addq.b	#1,SMPS_Track.Volume(a5)		; Increase volume attenuation
		cmpi.b	#$10,SMPS_Track.Volume(a5)		; Is it greater than $F?
		blo.s	.sendpsgvol				; Branch if not
		bclr	#7,SMPS_Track.PlaybackControl(a5)	; Stop track
		bra.s	.nextpsg
; ===========================================================================

.sendpsgvol:
		move.b	SMPS_Track.Volume(a5),d6		; Store new volume attenuation
		jsr	SetPSGVolume(pc)

.nextpsg:
		adda.w	#SMPS_Track.len,a5
		dbf	d7,.psgloop

		rts
; End of function DoFadeOut

; ===========================================================================

FMSilenceAll_Special:
		moveq	#4-1,d4
		moveq	#$40,d3
		moveq	#$7F,d1

.tlloop:
		move.b	d3,d0
		jsr	WriteFMIorII(pc)
		addq.b	#4,d3
		dbf	d4,.tlloop

		moveq	#4-1,d4
		move.b	#$80,d3
		moveq	#$F,d1

.rrloop:
		move.b	d3,d0
		jsr	WriteFMIorII(pc)
		addq.b	#4,d3
		dbf	d4,.rrloop

		rts
; End of function FMSilenceAll_Special

; ===========================================================================

FMSilenceAll:
		moveq	#3-1,d2					; 3 FM channels for each YM2612 parts
		moveq	#$28,d0					; FM key on/off register

.noteoffloop:
		move.b	d2,d1
		jsr	WriteFMI(pc)
		addq.b	#4,d1					; Move to YM2612 part 1
		jsr	WriteFMI(pc)
		dbf	d2,.noteoffloop

		moveq	#$40,d0					; Set TL on FM channels...
		moveq	#$7F,d1					; ... to total attenuation...
		moveq	#3-1,d3					; ... for all 3 channels...

.channelloop:
		moveq	#4-1,d2					; ... for all operators on each channel...

.channeltlloop:
		jsr	WriteFMI(pc)				; ... for part 0...
		jsr	WriteFMII(pc)				; ... and part 1.
		addq.w	#4,d0					; Next TL operator
		dbf	d2,.channeltlloop

		subi.b	#$F,d0					; Move to TL operator 1 of next channel
		dbf	d3,.channelloop

		rts
; End of function FMSilenceAll

; ===========================================================================
; ---------------------------------------------------------------------------
; Stop music
; ---------------------------------------------------------------------------
; Sound_E4: StopSoundAndMusic:
StopAllSound:
		moveq	#$2B,d0					; Enable/disable DAC
		move.b	#$80,d1					; Enable DAC
		jsr	WriteFMI(pc)
		moveq	#$27,d0					; Timers, FM3/FM6 mode
		moveq	#0,d1					; FM3/FM6 normal mode, disable timers
		jsr	WriteFMI(pc)
		movea.l	a6,a0
	if FixBugs
		move.w	#(SMPS_RAM.v_1up_ram_copy)/4-1,d0	; Clear $3A0 bytes: all variables and all track data
	else
		; Bug: This should be clearing all variables and track data, but misses the last $10 bytes of v_spcsfx_psg3_Track.
		move.w	#(SMPS_RAM.v_1up_ram_copy-$10)/4-1,d0	; Clear $390 bytes: all variables and most track data
	endif

.clearramloop:
		clr.l	(a0)+
		dbf	d0,.clearramloop
		move.b	#$80,SMPS_RAM.v_sound_id(a6)		; set music to $80 (silence)
		jsr	FMSilenceAll(pc)
		bra.w	PSGSilenceAll
; ===========================================================================

InitMusicPlayback:
		movea.l	a6,a0
		; Save several values
		_move.b	SMPS_RAM.v_sndprio(a6),d1
		move.b	SMPS_RAM.f_1up_playing(a6),d2
		move.b	SMPS_RAM.f_speedup(a6),d3
		move.b	SMPS_RAM.v_fadein_counter(a6),d4
	if FixBugs
		move.l	SMPS_RAM.v_soundqueue0(a6),d5
	else
		; Bug: v_soundqueue0 and the other queues are not saved
	endif
		move.w	#(SMPS_RAM.v_1up_ram_end-SMPS_RAM.v_1up_ram)/4-1,d0

.clearramloop:
		clr.l	(a0)+
		dbf	d0,.clearramloop

		; Restore the values saved above
		_move.b	d1,SMPS_RAM.v_sndprio(a6)
		move.b	d2,SMPS_RAM.f_1up_playing(a6)
		move.b	d3,SMPS_RAM.f_speedup(a6)
		move.b	d4,SMPS_RAM.v_fadein_counter(a6)
	if FixBugs
		move.l	d5,SMPS_RAM.v_soundqueue0(a6)
	else
		; Bug: Like above, v_soundqueue0 and the other queues are not restored either
	endif
		move.b	#$80,SMPS_RAM.v_sound_id(a6)		; set music to $80 (silence)
	if FixBugs
		lea	SMPS_RAM.v_music_dac_track.VoiceControl(a6),a1
		lea	FMDACInitBytes(pc),a2
		moveq	#SMPS_MUSIC_FM_DAC_TRACK_COUNT-1,d1	; 7 DAC/FM tracks
		bsr.s	.writeloop
		lea	PSGInitBytes(pc),a2
		moveq	#SMPS_MUSIC_PSG_TRACK_COUNT-1,d1	; 3 PSG tracks

.writeloop:
		move.b	(a2)+,(a1)				; Write track's channel byte
		lea	SMPS_Track.len(a1),a1			; Next track
		dbf	d1,.writeloop				; Loop for all DAC/FM/PSG tracks

		rts
	else
		; Bug: This is missing the FM channels
		bra.w	PSGSilenceAll
	endif
; ===========================================================================

TempoWait:
		move.b	SMPS_RAM.v_main_tempo(a6),SMPS_RAM.v_main_tempo_timeout(a6)
		addq.b	#1,SMPS_RAM.v_music_dac_track.DurationTimeout(a6)
		addq.b	#1,SMPS_RAM.v_music_fm1_track.DurationTimeout(a6)
		addq.b	#1,SMPS_RAM.v_music_fm2_track.DurationTimeout(a6)
		addq.b	#1,SMPS_RAM.v_music_fm3_track.DurationTimeout(a6)
		addq.b	#1,SMPS_RAM.v_music_fm4_track.DurationTimeout(a6)
		addq.b	#1,SMPS_RAM.v_music_fm5_track.DurationTimeout(a6)
		addq.b	#1,SMPS_RAM.v_music_fm6_track.DurationTimeout(a6)
		addq.b	#1,SMPS_RAM.v_music_psg1_track.DurationTimeout(a6)
		addq.b	#1,SMPS_RAM.v_music_psg2_track.DurationTimeout(a6)
		addq.b	#1,SMPS_RAM.v_music_psg3_track.DurationTimeout(a6)
		rts
; ===========================================================================

SpeedUpMusic:
		move.b	SMPS_RAM.v_speeduptempo(a6),SMPS_RAM.v_main_tempo(a6)
		move.b	SMPS_RAM.v_speeduptempo(a6),SMPS_RAM.v_main_tempo_timeout(a6)
		move.b	#$80,SMPS_RAM.f_speedup(a6)
		rts
; ===========================================================================

SlowDownMusic:
		move.b	SMPS_RAM.v_tempo_mod(a6),SMPS_RAM.v_main_tempo(a6)
		move.b	SMPS_RAM.v_tempo_mod(a6),SMPS_RAM.v_main_tempo_timeout(a6)
		clr.b	SMPS_RAM.f_speedup(a6)
		rts
; ===========================================================================

DoFadeIn:
		tst.b	SMPS_RAM.v_fadein_delay(a6)		; Has fadein delay expired?
		beq.s	.continuefade				; Branch if yes
		subq.b	#1,SMPS_RAM.v_fadein_delay(a6)
		rts
; ===========================================================================

.continuefade:
		tst.b	SMPS_RAM.v_fadein_counter(a6)		; Is fade done?
		beq.s	.fadedone				; Branch if yes
		subq.b	#1,SMPS_RAM.v_fadein_counter(a6)	; Update fade counter
		move.b	#2,SMPS_RAM.v_fadein_delay(a6)		; Reset fade delay
		lea	SMPS_RAM.v_music_fm_tracks(a6),a5
		moveq	#SMPS_MUSIC_FM_TRACK_COUNT-1,d7		; 6 FM tracks

.fmloop:
		tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
		bpl.s	.nextfm					; Branch if not
		subq.b	#1,SMPS_Track.Volume(a5)		; Reduce volume attenuation
		jsr	SendVoiceTL(pc)

.nextfm:
		adda.w	#SMPS_Track.len,a5
		dbf	d7,.fmloop
		moveq	#SMPS_MUSIC_PSG_TRACK_COUNT-1,d7	; 3 PSG tracks

.psgloop:
		tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
		bpl.s	.nextpsg				; Branch if not
		subq.b	#1,SMPS_Track.Volume(a5)		; Reduce volume attenuation
	if FixBugs
		move.b	SMPS_Track.Volume(a5),d6
		cmpi.b	#$10,d6					; Is it is < $10?
		blo.s	.sendpsgvol				; Branch if yes
		moveq	#$F,d6					; Limit to $F (maximum attenuation)

.sendpsgvol:
	else
		; Bug: SMPS_Track.Volume is not moved to d6 here, resulting in crackling and loud PSG noises when fading in
	endif
		jsr	SetPSGVolume(pc)

.nextpsg:
		adda.w	#SMPS_Track.len,a5
		dbf	d7,.psgloop
		rts
; ===========================================================================

.fadedone:
		bclr	#2,SMPS_RAM.v_music_dac_track.PlaybackControl(a6) ; Clear 'SFX overriding' bit
		clr.b	SMPS_RAM.f_fadein_flag(a6)		; Stop fadein

	if FixBugs
		; Fix the DAC fade-in bug
		; https://info.sonicretro.org/SCHG_How-to:Fix_Song_Restoration_Bugs_in_Sonic_1%27s_Sound_Driver
		tst.b	SMPS_RAM.v_music_dac_track.PlaybackControl(a6) ; is the DAC channel running?
		bpl.s	.Resume_NoDAC				; if not, branch

		moveq	#signextendB($B6),d0			; prepare FM channel 3/6 L/R/AMS/FMS address
		move.b	SMPS_RAM.v_music_dac_track.AMSFMSPan(a6),d1 ; load DAC channel's L/R/AMS/FMS value
		jmp	WriteFMII(pc)				; write to FM 6
.Resume_NoDAC:
	endif
		rts
; End of function DoFadeIn

; ===========================================================================

FMNoteOn:
		btst	#1,SMPS_Track.PlaybackControl(a5)	; Is track resting?
		bne.s	.return					; Return if so
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is track being overridden?
		bne.s	.return					; Return if so
		moveq	#$28,d0					; Note on/off register
		move.b	SMPS_Track.VoiceControl(a5),d1		; Get channel bits
		ori.b	#$F0,d1					; Note on on all operators
		bra.w	WriteFMI
; ===========================================================================

.return:
		rts
; ===========================================================================

FMNoteOff:
		btst	#4,SMPS_Track.PlaybackControl(a5)	; Is 'do not attack next note' set?
		bne.s	locret_74E42				; Return if yes
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is SFX overriding?
		bne.s	locret_74E42				; Return if yes

SendFMNoteOff:
		moveq	#$28,d0					; Note on/off register
		move.b	SMPS_Track.VoiceControl(a5),d1		; Note off to this channel
		bra.w	WriteFMI
; ===========================================================================

locret_74E42:
		rts
; End of function FMNoteOff

; ===========================================================================

WriteFMIorIIMain:
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is track being overriden by sfx?
		bne.s	.return					; Return if yes
		bra.w	WriteFMIorII
; ===========================================================================

.return:
		rts
; ===========================================================================

WriteFMIorII:
		btst	#2,SMPS_Track.VoiceControl(a5)		; Is this bound for part I or II?
		bne.s	WriteFMIIPart				; Branch if for part II
		add.b	SMPS_Track.VoiceControl(a5),d0		; Add in voice control bits
; End of function WriteFMIorII

; ===========================================================================

; These are what are in the default SMPS 68k Type 1b driver
; Why the final chose the ones from the Type 1a driver is a mystery

WriteFMI:
		lea	(ym2612_a0).l,a0

.waitym1:
		btst	#7,(a0)					; Is FM busy?
		bne.s	.waitym1				; Loop if so
		move.b	d0,(a0)

.waitym2:
		btst	#7,(a0)					; Is FM busy?
		bne.s	.waitym2				; Loop if so
		move.b	d1,ym2612_d0-ym2612_a0(a0)
		rts
; End of function WriteFMI

; ===========================================================================

WriteFMIIPart:
		move.b	SMPS_Track.VoiceControl(a5),d2		; Get voice control bits
		bclr	#2,d2					; Clear chip toggle
		add.b	d2,d0					; Add in to destination register

; ===========================================================================

WriteFMII:
		lea	(ym2612_a0).l,a0

.waitym1:
		btst	#7,(a0)					; Is FM busy?
		bne.s	.waitym1				; Loop if so
		move.b	d0,ym2612_a1-ym2612_a0(a0)

.waitym2:
		btst	#7,(a0)					; Is FM busy?
		bne.s	.waitym2				; Loop if so
		move.b	d1,ym2612_d1-ym2612_a0(a0)
		rts
; End of function WriteFMII

; ===========================================================================
; ---------------------------------------------------------------------------
; FM Note Values: b-0 to a#8
;
; Each row is an octave, starting with B and ending with A-sharp/B-flat.
; Notably, this differs from the PSG frequency table, which starts with C and
; ends with B. This is caused by 'FMSetFreq' subtracting $80 from the note
; instead of $81, meaning that the first frequency in the table ironically
; corresponds to the 'rest' note. The only way to use this frequency in a
; real note is to transpose the channel to a lower semitone.
;
; Rather than use a complete lookup table, other SMPS drivers such as
; Sonic 3's compute the octave, and only store a single octave's worth of
; notes in the table.
;
; Invalid transposition values will cause this table to be overflowed,
; resulting in garbage data being used as frequency values. In drivers that
; compute the octave instead, invalid transposition values merely cause the
; notes to wrap-around (the note below the lowest note will be the highest
; note). It's important to keep this in mind when porting buggy songs.
; ---------------------------------------------------------------------------
MakeFMFrequency function frequency,roundFloatToInteger(frequency*1024*1024*2/FM_Sample_Rate)
MakeFMFrequenciesOctave macro octave
		; Frequencies for the base octave. The first frequency is B, the last frequency is B-flat.
		irp op, 15.39, 16.35, 17.34, 18.36, 19.45, 20.64, 21.84, 23.13, 24.51, 25.98, 27.53, 29.15
			dc.w MakeFMFrequency(op)+octave*$800
		endm
	endm

; word_74E9C: FM_Notes:
FMFrequencies:
		MakeFMFrequenciesOctave 0
		MakeFMFrequenciesOctave 1
		MakeFMFrequenciesOctave 2
		MakeFMFrequenciesOctave 3
		MakeFMFrequenciesOctave 4
		MakeFMFrequenciesOctave 5
		MakeFMFrequenciesOctave 6
		MakeFMFrequenciesOctave 7

; ===========================================================================

PSGUpdateTrack:
		subq.b	#1,SMPS_Track.DurationTimeout(a5)	; Update note timeout
		bne.s	.notegoing
		bclr	#4,SMPS_Track.PlaybackControl(a5)	; Clear 'do not attack note' bit
		jsr	PSGDoNext(pc)
		jsr	PSGDoNoteOn(pc)
		bra.w	PSGDoVolFX
; ===========================================================================

.notegoing:
		jsr	NoteTimeoutUpdate(pc)
		jsr	PSGUpdateVolFX(pc)
		jsr	DoModulation(pc)
		jsr	PSGUpdateFreq(pc)
		rts
; End of function PSGUpdateTrack

; ===========================================================================

PSGDoNext:
		bclr	#1,SMPS_Track.PlaybackControl(a5)	; Clear 'track at rest' bit
		movea.l	SMPS_Track.DataPointer(a5),a4		; Get track data pointer

.noteloop:
		moveq	#0,d5
		move.b	(a4)+,d5				; Get byte from track
		cmpi.b	#$E0,d5					; Is it a coord. flag?
		blo.s	.gotnote				; Branch if not
		jsr	CoordFlag(pc)
		bra.s	.noteloop
; ===========================================================================

.gotnote:
		tst.b	d5					; Is it a note?
		bpl.s	.gotduration				; Branch if not
		jsr	PSGSetFreq(pc)
		move.b	(a4)+,d5				; Get another byte
		tst.b	d5					; Is it a duration?
		bpl.s	.gotduration				; Branch if yes
		subq.w	#1,a4					; Put byte back
		bra.w	FinishTrackUpdate
; ===========================================================================

.gotduration:
		jsr	SetDuration(pc)
		bra.w	FinishTrackUpdate
; End of function PSGDoNext

; ===========================================================================

PSGSetFreq:
		subi.b	#$81,d5					; Convert to 0-based index
		blo.s	.restpsg				; If $80, put track at rest
		add.b	SMPS_Track.Transpose(a5),d5		; Add in channel transposition
		andi.w	#$7F,d5					; Clear high byte and sign bit
		lsl.w	#1,d5
		lea	PSGFrequencies(pc),a0
		move.w	(a0,d5.w),SMPS_Track.Freq(a5)		; Set new frequency
		bra.w	FinishTrackUpdate
; ===========================================================================

.restpsg:
		bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
		move.w	#-1,SMPS_Track.Freq(a5)			; Invalidate note frequency
		jsr	FinishTrackUpdate(pc)
		bra.w	PSGNoteOff
; End of function PSGSetFreq

; ===========================================================================

PSGDoNoteOn:
		move.w	SMPS_Track.Freq(a5),d6			; Get note frequency
		bmi.s	PSGSetRest				; If invalid, branch
; End of function PSGDoNoteOn

; ===========================================================================

PSGUpdateFreq:
		move.b	SMPS_Track.Detune(a5),d0		; Get detune value
		ext.w	d0
		add.w	d0,d6					; Add to frequency
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is track being overridden?
		bne.s	.locret					; Return if yes
		btst	#1,SMPS_Track.PlaybackControl(a5)	; Is track at rest?
		bne.s	.locret					; Return if yes
		move.b	SMPS_Track.VoiceControl(a5),d0		; Get channel bits
		cmpi.b	#$E0,d0					; Is it a noise channel?
		bne.s	.notnoise				; Branch if not
		move.b	#$C0,d0					; Use PSG 3 channel bits

.notnoise:
		move.w	d6,d1
		andi.b	#$F,d1					; Low nibble of frequency
		or.b	d1,d0					; Latch tone data to channel
		lsr.w	#4,d6					; Get upper 6 bits of frequency
		andi.b	#$3F,d6					; Send to latched channel
		move.b	d0,(psg_input).l
		move.b	d6,(psg_input).l

.locret:
		rts
; End of function PSGUpdateFreq

; ===========================================================================

PSGSetRest:
		bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
		rts

; ===========================================================================

PSGUpdateVolFX:
		tst.b	SMPS_Track.VoiceIndex(a5)		; Test PSG tone
		beq.w	locret_750A2				; Return if it is zero

PSGDoVolFX:
		move.b	SMPS_Track.Volume(a5),d6		; Get volume
		moveq	#0,d0
		move.b	SMPS_Track.VoiceIndex(a5),d0		; Get PSG tone
		beq.s	SetPSGVolume
		movea.l	(Go_PSGIndex).l,a0
		subq.w	#1,d0
		lsl.w	#2,d0
		movea.l	(a0,d0.w),a0
		move.b	SMPS_Track.VolEnvIndex(a5),d0		; Get volume envelope index
		move.b	(a0,d0.w),d0				; Volume envelope value
		addq.b	#1,SMPS_Track.VolEnvIndex(a5)		; Increment volume envelope index
		btst	#7,d0					; Is volume envelope value negative?
		beq.s	.gotflutter				; Branch if not
		cmpi.b	#TBEND,d0				; Is it the terminator?
		beq.s	VolEnvCmd_End				; If so, branch
		cmpi.b	#TBBAK,d0
		beq.s	VolEnvCmd_Back
		cmpi.b	#TBREPT,d0
		beq.s	VolEnvCmd_Rept

.gotflutter:
		add.w	d0,d6					; Add volume envelope value to volume
		cmpi.b	#$10,d6					; Is volume $10 or higher?
		blo.s	SetPSGVolume				; Branch if not
		moveq	#$F,d6					; Limit to silence and fall through
; End of function PSGUpdateVolFX

; ===========================================================================

SetPSGVolume:
		btst	#1,SMPS_Track.PlaybackControl(a5)	; Is track at rest?
		bne.s	locret_750A2				; Return if so
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is SFX overriding?
		bne.s	locret_750A2				; Return if so
		btst	#4,SMPS_Track.PlaybackControl(a5)	; Is track set to not attack next note?
		bne.s	PSGCheckNoteTimeout 			; Branch if yes

PSGSendVolume:
		or.b	SMPS_Track.VoiceControl(a5),d6		; Add in track selector bits
		addi.b	#$10,d6					; Mark it as a volume command
		move.b	d6,(psg_input).l

locret_750A2:
		rts
; ===========================================================================

PSGCheckNoteTimeout:
		tst.b	SMPS_Track.NoteTimeoutMaster(a5)	; Is note timeout on?
		beq.s	PSGSendVolume				; Branch if not
		tst.b	SMPS_Track.NoteTimeout(a5)		; Has note timeout expired?
		bne.s	PSGSendVolume				; Branch if not
		rts
; End of function SetPSGVolume

; ===========================================================================

VolEnvCmd_End:
		subq.b	#1,SMPS_Track.VolEnvIndex(a5)		; Decrement volume envelope index
		rts
; ===========================================================================

VolEnvCmd_Back:
		move.b	SMPS_Track.VoiceControl(a0,d0.w),SMPS_Track.VolEnvIndex(a5)
		bra.w	PSGDoVolFX
; ===========================================================================

VolEnvCmd_Rept:
		clr.b	SMPS_Track.VolEnvIndex(a5)
		bra.w	PSGDoVolFX
; ===========================================================================

PSGNoteOff:
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is SFX overriding?
		bne.s	locret_750DE				; Return if so

SendPSGNoteOff:
		move.b	SMPS_Track.VoiceControl(a5),d0		; PSG channel to change
		ori.b	#$1F,d0					; Maximum volume attenuation
		move.b	d0,(psg_input).l
	if FixBugs
		; This is the same fix that S&K's driver uses:
		cmpi.b	#$DF,d0					; Are stopping PSG3?
		bne.s	locret_750DE
		move.b	#$FF,(psg_input).l			; If so, stop noise channel while we're at it
	else
		; DANGER! If InitMusicPlayback doesn't silence all channels, there's the
		; risk of music accidentally playing noise because it can't detect if
		; the PSG4/noise channel needs muting on track initialisation.
	endif

locret_750DE:
		rts
; End of function PSGNoteOff

; ===========================================================================

PSGSilenceAll:
		lea	(psg_input).l,a0
		move.b	#$9F,(a0)				; Silence PSG 1
		move.b	#$BF,(a0)				; Silence PSG 2
		move.b	#$DF,(a0)				; Silence PSG 3
		move.b	#$FF,(a0)				; Silence noise channel
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; PSG Note Values: c-1 to a-6
;
; Each row is an octave, starting with C and ending with B. Sonic 3's driver
; adds another octave at the start, as well as two more notes and the end to
; complete the last octave. Notably, a-6 is changed from 223721.56Hz to
; 6991.28Hz. These changes need to be applied here in order for ports of
; songs from Sonic 3 and later to sound correct.
;
; Here is what Sonic 3's version of this table looks like:
;		MakePSGFrequencies  109.34,    109.34,    109.34,    109.34,    109.34,    109.34,    109.34,    109.34,    109.34,    110.20,    116.76,    123.73
;		MakePSGFrequencies  130.98,    138.78,    146.99,    155.79,    165.22,    174.78,    185.19,    196.24,    207.91,    220.63,    233.52,    247.47
;		MakePSGFrequencies  261.96,    277.56,    293.59,    311.58,    329.97,    349.56,    370.39,    392.49,    415.83,    440.39,    468.03,    494.95
;		MakePSGFrequencies  522.71,    556.51,    588.73,    621.44,    661.89,    699.12,    740.79,    782.24,    828.59,    880.79,    932.17,    989.91
;		MakePSGFrequencies 1045.42,   1107.52,   1177.47,   1242.89,   1316.00,   1398.25,   1491.47,   1575.50,   1669.55,   1747.82,   1864.34,   1962.46
;		MakePSGFrequencies 2071.49,   2193.34,   2330.42,   2485.78,   2601.40,   2796.51,   2943.69,   3107.23,   3290.01,   3495.64,   3608.40,   3857.25
;		MakePSGFrequencies 4142.98,   4302.32,   4660.85,   4863.50,   5084.56,   5326.69,   5887.39,   6214.47,   6580.02,   6991.28, 223721.56, 223721.56
; ---------------------------------------------------------------------------
MakePSGFrequency function frequency,min($3FF,roundFloatToInteger(PSG_Sample_Rate/(frequency*2)))
MakePSGFrequencies macro
		irp op,ALLARGS
			dc.w MakePSGFrequency(op)
		endm
	endm

PSGFrequencies:
		MakePSGFrequencies  130.98,    138.78,    146.99,    155.79,    165.22,    174.78,    185.19,    196.24,    207.91,    220.63,    233.52,    247.47
		MakePSGFrequencies  261.96,    277.56,    293.59,    311.58,    329.97,    349.56,    370.39,    392.49,    415.83,    440.39,    468.03,    494.95
		MakePSGFrequencies  522.71,    556.51,    588.73,    621.44,    661.89,    699.12,    740.79,    782.24,    828.59,    880.79,    932.17,    989.91
		MakePSGFrequencies 1045.42,   1107.52,   1177.47,   1242.89,   1316.00,   1398.25,   1491.47,   1575.50,   1669.55,   1747.82,   1864.34,   1962.46
		MakePSGFrequencies 2071.49,   2193.34,   2330.42,   2485.78,   2601.40,   2796.51,   2943.69,   3107.23,   3290.01,   3495.64,   3608.40,   3857.25
		MakePSGFrequencies 4142.98,   4302.32,   4660.85,   4863.50,   5084.56,   5326.69,   5887.39,   6214.47,   6580.02, 223721.56

; ===========================================================================

CoordFlag:
		subi.w	#$E0,d5
		lsl.w	#2,d5
		jmp	CoordFlagLookup(pc,d5.w)
; End of function CoordFlag

; ===========================================================================
CoordFlagLookup:
		bra.w	cfPanningAMSFMS				; $E0
; ===========================================================================
		bra.w	cfDetune				; $E1
; ===========================================================================
		bra.w	cfSetCommunication			; $E2
; ===========================================================================
		bra.w	cfGlobalMod				; $E3
; ===========================================================================
		bra.w	cfFadeInToPrevious			; $E4
; ===========================================================================
		bra.w	cfChangePFMVolume			; $E5
; ===========================================================================
		bra.w	cfChangeFMVolume			; $E6
; ===========================================================================
		bra.w	cfHoldNote				; $E7
; ===========================================================================
		bra.w	cfNoteTimeout				; $E8
; ===========================================================================
		bra.w	cfSetLFO				; $E9
; ===========================================================================
		bra.w	cfSetTempo				; $EA
; ===========================================================================
		bra.w	cfSetSoundQueue				; $EB
; ===========================================================================
		bra.w	cfChangePSGVolume			; $EC
; ===========================================================================
		bra.w	cfClearPush				; $ED
; ===========================================================================
		bra.w	cfYM1					; $EE
; ===========================================================================
		bra.w	cfSetVoice				; $EF
; ===========================================================================
		bra.w	cfModulation				; $F0
; ===========================================================================
		bra.w	cfEnableModulation			; $F1
; ===========================================================================
		bra.w	cfStopTrack				; $F2
; ===========================================================================
		bra.w	cfSetPSGNoise				; $F3
; ===========================================================================
		bra.w	cfDisableModulation			; $F4
; ===========================================================================
		bra.w	cfSetPSGTone				; $F5
; ===========================================================================
		bra.w	cfJumpTo				; $F6
; ===========================================================================
		bra.w	cfRepeatAtPos				; $F7
; ===========================================================================
		bra.w	cfJumpToGosub				; $F8
; ===========================================================================
		bra.w	cfJumpReturn				; $F9
; ===========================================================================
		bra.w	cfSetTempoDivider			; $FA
; ===========================================================================
		bra.w	cfChangeTransposition			; $FB
; ===========================================================================
		bra.w	cfSetTempoDividerAll			; $FC
; ===========================================================================
		bra.w	cfStopSpecialFM4			; $FD
; ===========================================================================
		bra.w	cfFE_SpcFM3Mode				; $FE
; ===========================================================================
		moveq	#0,d0					; $FF
		move.b	(a4)+,d0
		lsl.w	#2,d0
		jmp	cfMetaJumpTable(pc,d0.w)
; ===========================================================================

cfMetaJumpTable:
		bra.w	cfSSG_Reg				; $FF, $00
; ===========================================================================
		bra.w	cfSSG_Reg				; $FF, $01
; ===========================================================================

cfPanningAMSFMS:
		move.b	(a4)+,d1				; New AMS/FMS/panning value
		tst.b	SMPS_Track.VoiceControl(a5)		; Is this a PSG track?
		bmi.s	.return					; Return if yes
		move.b	SMPS_Track.AMSFMSPan(a5),d0		; Get current AMS/FMS/panning
		andi.b	#$37,d0					; Retain bits 0-2, 3-4 if set
		or.b	d0,d1					; Mask in new value
		move.b	d1,SMPS_Track.AMSFMSPan(a5)		; Store value
		move.b	#$B4,d0					; Command to set AMS/FMS/panning
		bra.w	WriteFMIorIIMain
; ===========================================================================

.return:
		rts
; ===========================================================================

cfDetune:
		move.b	(a4)+,SMPS_Track.Detune(a5)		; Set detune value
		rts
; ===========================================================================

cfSetCommunication:
		move.b	(a4)+,SMPS_RAM.v_communication_byte(a6)	; Set otherwise unused communication byte to parameter
		rts
; ===========================================================================

cfGlobalMod:
		movea.l	(Go_ModulationIndex).l,a0		; Get global modulation index
		moveq	#0,d0
		move.b	(a4)+,d0				; Move first byte into d0
		subq.b	#1,d0					; Subtract 1 from d0
		lsl.w	#2,d0					; Multiply by 4
		adda.w	d0,a0					; Add d0 to the modulation index
		bset	#3,SMPS_Track.PlaybackControl(a5)	; Enable modulation
		move.l	a0,SMPS_Track.ModulationPtr(a5)		; Save pointer to modulation data
		move.b	(a0)+,SMPS_Track.ModulationWait(a5)	; Modulation delay
		move.b	(a0)+,SMPS_Track.ModulationSpeed(a5)	; Modulation speed
		move.b	(a0)+,SMPS_Track.ModulationDelta(a5)	; Modulation delta
		move.b	(a0)+,d0				; Modulation steps...
		lsr.b	#1,d0					; ... divided by 2...
		move.b	d0,SMPS_Track.ModulationSteps(a5)	; ... before being stored
		clr.w	SMPS_Track.ModulationVal(a5)		; Total accumulated modulation frequency change
		rts
; ===========================================================================

cfFadeInToPrevious:
		movea.l	a6,a0
		lea	SMPS_RAM.v_1up_ram_copy(a6),a1
		move.w	#(SMPS_RAM.v_1up_ram_end-SMPS_RAM.v_1up_ram)/4-1,d0 ; $220 bytes to restore: all variables and music track data

.restoreramloop:
		move.l	(a1)+,(a0)+
		dbf	d0,.restoreramloop

	if FixBugs
		; Fix the FM 6 restoration bug
		; https://info.sonicretro.org/SCHG_How-to:Fix_Song_Restoration_Bugs_in_Sonic_1%27s_Sound_Driver
		move.b	#$2B,d0		; Register: DAC mode (bit 7 = enable)
		moveq	#0,d1		; Value: DAC mode disable
		jsr	WriteFMI(pc)	; Write to YM2612 Port 0
	endif

		bset	#2,SMPS_RAM.v_music_dac_track.PlaybackControl(a6) ; Set 'SFX overriding' bit
		movea.l	a5,a3
		move.b	#$28,d6
		sub.b	SMPS_RAM.v_fadein_counter(a6),d6	; If fade already in progress, this adjusts track volume accordingly
		moveq	#SMPS_MUSIC_FM_TRACK_COUNT-1,d7 	; 6 FM tracks
		lea	SMPS_RAM.v_music_fm_tracks(a6),a5

.fmloop:
		btst	#7,SMPS_Track.PlaybackControl(a5)	; Is track playing?
		beq.s	.nextfm					; Branch if not
		bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
		add.b	d6,SMPS_Track.Volume(a5)		; Apply current volume fade-in
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is SFX overriding?
		bne.s	.nextfm					; Branch if yes
		moveq	#0,d0
		move.b	SMPS_Track.VoiceIndex(a5),d0		; Get voice
		movea.l	SMPS_RAM.v_voice_ptr(a6),a1		; Voice pointer
		jsr	SetVoice(pc)

.nextfm:
		adda.w	#SMPS_Track.len,a5
		dbf	d7,.fmloop

		moveq	#SMPS_MUSIC_PSG_TRACK_COUNT-1,d7	; 3 PSG tracks

.psgloop:
		btst	#7,SMPS_Track.PlaybackControl(a5)	; Is track playing?
		beq.s	.nextpsg				; Branch if not
		bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
		jsr	PSGNoteOff(pc)
		add.b	d6,SMPS_Track.Volume(a5)		; Apply current volume fade-in

.nextpsg:
		adda.w	#SMPS_Track.len,a5
		dbf	d7,.psgloop

		movea.l	a3,a5
		move.b	#$80,SMPS_RAM.f_fadein_flag(a6)		; Trigger fade-in
		move.b	#$28,SMPS_RAM.v_fadein_counter(a6)	; Fade-in delay
		clr.b	SMPS_RAM.f_1up_playing(a6)
		addq.w	#8,sp					; Tamper return value so we don't return to caller
		rts
; ===========================================================================
; Leftover unused coord flag to set total level and set release rate to off.
cfSilence:
		jsr	FMSilenceAll_Special(pc)
		bra.w	cfStopTrack
; ===========================================================================
; Leftover unused coord flag to set panning values.
cfAutoPan:
		move.b	(a4)+,SMPS_Track.PanNumber(a5)
		beq.s	.disable
		move.b	(a4)+,SMPS_Track.PanTable(a5)
		move.b	(a4)+,SMPS_Track.PanStart(a5)
		move.b	(a4)+,SMPS_Track.PanLimit(a5)
		move.b	(a4),SMPS_Track.PanLength(a5)
		move.b	(a4)+,SMPS_Track.PanContinue(a5)
		rts
; ===========================================================================

.disable:
		move.b	#$B4,d0
		move.b	SMPS_Track.AMSFMSPan(a5),d1
		bra.w	WriteFMIorIIMain
; ===========================================================================

cfChangePFMVolume:
		move.b	(a4)+,d0
		tst.b	SMPS_Track.VoiceControl(a5)		; is track FM?
		bpl.s	cfChangeFMVolume			; if so, branch
		add.b	d0,SMPS_Track.Volume(a5)
		addq.w	#1,a4
		rts
; ===========================================================================

cfChangeFMVolume:
		move.b	(a4)+,d0				; Get parameter
		add.b	d0,SMPS_Track.Volume(a5)		; Add to current volume
		bra.w	SendVoiceTL
; ===========================================================================

cfHoldNote:
		bset	#4,SMPS_Track.PlaybackControl(a5)	; Set 'do not attack next note' bit
		rts
; ===========================================================================

cfNoteTimeout:
		move.b	(a4),SMPS_Track.NoteTimeout(a5)		; Note fill timeout
		move.b	(a4)+,SMPS_Track.NoteTimeoutMaster(a5)	; Note fill master
		rts
; ===========================================================================

cfSetLFO:
		movea.l	SMPS_RAM.v_voice_ptr(a6),a1
		beq.s	.lfo_ss
		movea.l	SMPS_RAM.v_lfo_voice_ptr(a6),a1

.lfo_ss:
		move.b	(a4),d3					; d3 = slot data
		adda.w	#9,a0					; a0 = DR1 addr
		lea	LFO_Reg_Table(pc),a2
		moveq	#(LFO_Reg_Table_end-LFO_Reg_Table)-1,d6	; loop time

.lfo_loop:
		move.b	(a1)+,d1				; d1 = DR data
		move.b	(a2)+,d0				; d0 = DR reg.
		btst	#7,d3					; if slot bit data = 0
		beq.s	.lfo_not				; then not write
		bset	#7,d1					; AMON on
		jsr	WriteFMIorIIMain(pc)			; DR write

.lfo_not:
		lsl.w	#1,d3
		dbf	d6,.lfo_loop
		move.b	(a4)+,d1				; lfo data get
		moveq	#$22,d0					; FM reg
		jsr	WriteFMI(pc)
		move.b	(a4)+,d1				; d1 = ams,pms data
		move.b	SMPS_Track.AMSFMSPan(a5),d0		; d0 = pan data
		andi.b	#$C0,d0					; lr data get
		or.b	d0,d1					; d1 = lr,ams,pms data
		move.b	d1,SMPS_Track.AMSFMSPan(a5)		; pan data store
		move.b	#$B4,d0					; d0 = pan register
		bra.w	WriteFMIorIIMain
; ===========================================================================

LFO_Reg_Table:
		dc.b $60, $68, $64, $6C
LFO_Reg_Table_end:
; ===========================================================================

cfSetTempo:
		move.b	(a4),SMPS_RAM.v_main_tempo(a6)		; Set main tempo
		move.b	(a4)+,SMPS_RAM.v_main_tempo_timeout(a6)	; And reset timeout (!)
		rts
; ===========================================================================

cfSetSoundQueue:
		move.b	(a4)+,SMPS_RAM.v_soundqueue0(a6)
		rts
; ===========================================================================

cfChangePSGVolume:
		move.b	(a4)+,d0				; Get volume change
		add.b	d0,SMPS_Track.Volume(a5)		; Apply it
		rts
; ===========================================================================

cfClearPush:
		move.b	#0,SMPS_RAM.f_push_playing(a6)		; Allow push sound to be played once more
		rts
; ===========================================================================

cfYM1:
		move.b	(a4)+,d0
		move.b	(a4)+,d1
		bra.w	WriteFMI
; ===========================================================================

cfSetVoice:
		moveq	#0,d0
		move.b	(a4)+,d0				; Get new voice
		move.b	d0,SMPS_Track.VoiceIndex(a5)		; Store it
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is SFX overriding this track?
		bne.w	locret_75454				; Return if yes
		movea.l	SMPS_RAM.v_voice_ptr(a6),a1		; Music voice pointer
		tst.b	SMPS_RAM.f_voice_selector(a6)		; Are we updating a music track?
		beq.s	SetVoice				; If yes, branch
		movea.l	SMPS_RAM.v_lfo_voice_ptr(a6),a1		; SFX voice pointer
		tst.b	SMPS_RAM.f_voice_selector(a6)		; Are we updating a SFX track?
		bmi.s	SetVoice				; If yes, branch
		movea.l	SMPS_RAM.v_special_voice_ptr(a6),a1	; Special SFX voice pointer
		; Fall into SetVoice
; ===========================================================================

SetVoice:
		subq.w	#1,d0
		bmi.s	.havevoiceptr
		move.w	#25,d1

.voicemultiply:
		adda.w	d1,a1
		dbf	d0,.voicemultiply

.havevoiceptr:
		move.b	(a1)+,d1				; feedback/algorithm
		move.b	d1,SMPS_Track.FeedbackAlgo(a5)		; Save it to track RAM
		move.b	d1,d4
		move.b	#$B0,d0					; Command to write feedback/algorithm
		jsr	WriteFMIorII(pc)
		lea	FMInstrumentOperatorTable(pc),a2
		moveq	#FMInstrumentOperatorTable_End-FMInstrumentOperatorTable-1,d3 ; Don't want to send TL yet

.sendvoiceloop:
		move.b	(a2)+,d0
		move.b	(a1)+,d1
		jsr	WriteFMIorII(pc)
		dbf	d3,.sendvoiceloop

		moveq	#FMInstrumentTLTable_End-FMInstrumentTLTable-1,d5
		andi.w	#FMSlotMask_End-FMSlotMask-1,d4		; Get algorithm
		move.b	FMSlotMask(pc,d4.w),d4			; Get slot mask for algorithm
		move.b	SMPS_Track.Volume(a5),d3		; Track volume attenuation

.sendtlloop:
		move.b	(a2)+,d0
		move.b	(a1)+,d1
		lsr.b	#1,d4					; Is bit set for this operator in the mask?
		bhs.s	.sendtl					; Branch if not
		add.b	d3,d1					; Include additional attenuation

.sendtl:
		jsr	WriteFMIorII(pc)
		dbf	d5,.sendtlloop

		move.b	#$B4,d0					; Register for AMS/FMS/Panning
		move.b	SMPS_Track.AMSFMSPan(a5),d1		; Value to send
		jsr	WriteFMIorII(pc)

locret_75454:
		rts
; ===========================================================================

FMSlotMask:
		dc.b 8,	8, 8, 8, $A, $E, $E, $F
FMSlotMask_End:
; ===========================================================================

SendVoiceTL:
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is SFX overriding?
		bne.s	.locret					; Return if so
		moveq	#0,d0
		move.b	SMPS_Track.VoiceIndex(a5),d0		; Current voice
		movea.l	SMPS_RAM.v_voice_ptr(a6),a1		; Voice pointer
		tst.b	SMPS_RAM.f_voice_selector(a6)
		beq.s	.gotvoiceptr
		movea.l	SMPS_RAM.v_lfo_voice_ptr(a6),a1
		tst.b	SMPS_RAM.f_voice_selector(a6)
		bmi.s	.gotvoiceptr
		movea.l	SMPS_RAM.v_special_voice_ptr(a6),a1

.gotvoiceptr:
		subq.w	#1,d0
		bmi.s	.gotvoice
		move.w	#25,d1

.voicemultiply:
		adda.w	d1,a1
		dbf	d0,.voicemultiply

.gotvoice:
		adda.w	#21,a1					; Want TL
		lea	FMInstrumentTLTable(pc),a2
		move.b	SMPS_Track.FeedbackAlgo(a5),d0		; Get feedback/algorithm
		andi.w	#FMSlotMask_End-FMSlotMask-1,d0		; Want only algorithm
		move.b	FMSlotMask(pc,d0.w),d4			; Get slot mask
		move.b	SMPS_Track.Volume(a5),d3		; Get track volume attenuation
		bmi.s	.locret					; If negative, stop
		moveq	#(FMInstrumentTLTable_End-FMInstrumentTLTable)-1,d5

.sendtlloop:
		move.b	(a2)+,d0
		move.b	(a1)+,d1
		lsr.b	#1,d4					; Is bit set for this operator in the mask?
		bhs.s	.senttl					; Branch if not
		add.b	d3,d1					; Include additional attenuation
		blo.s	.senttl					; Branch on overflow
		jsr	WriteFMIorII(pc)

.senttl:
		dbf	d5,.sendtlloop

.locret:
		rts
; ===========================================================================

FMInstrumentOperatorTable:
		dc.b  $30					; Detune/multiple operator 1
		dc.b  $38					; Detune/multiple operator 3
		dc.b  $34					; Detune/multiple operator 2
		dc.b  $3C					; Detune/multiple operator 4
		dc.b  $50					; Rate scalling/attack rate operator 1
		dc.b  $58					; Rate scalling/attack rate operator 3
		dc.b  $54					; Rate scalling/attack rate operator 2
		dc.b  $5C					; Rate scalling/attack rate operator 4
		dc.b  $60					; Amplitude modulation/first decay rate operator 1
		dc.b  $68					; Amplitude modulation/first decay rate operator 3
		dc.b  $64					; Amplitude modulation/first decay rate operator 2
		dc.b  $6C					; Amplitude modulation/first decay rate operator 4
		dc.b  $70					; Secondary decay rate operator 1
		dc.b  $78					; Secondary decay rate operator 3
		dc.b  $74					; Secondary decay rate operator 2
		dc.b  $7C					; Secondary decay rate operator 4
		dc.b  $80					; Secondary amplitude/release rate operator 1
		dc.b  $88					; Secondary amplitude/release rate operator 3
		dc.b  $84					; Secondary amplitude/release rate operator 2
		dc.b  $8C					; Secondary amplitude/release rate operator 4
FMInstrumentOperatorTable_End:

FMInstrumentTLTable:
		dc.b  $40					; Total level operator 1
		dc.b  $48					; Total level operator 3
		dc.b  $44					; Total level operator 2
		dc.b  $4C					; Total level operator 4
FMInstrumentTLTable_End:
; ===========================================================================

cfModulation:
		bset	#3,SMPS_Track.PlaybackControl(a5)	; Turn on modulation
		move.l	a4,SMPS_Track.ModulationPtr(a5)		; Save pointer to modulation data
		move.b	(a4)+,SMPS_Track.ModulationWait(a5)	; Modulation delay
		move.b	(a4)+,SMPS_Track.ModulationSpeed(a5)	; Modulation speed
		move.b	(a4)+,SMPS_Track.ModulationDelta(a5)	; Modulation delta
		move.b	(a4)+,d0				; Modulation steps...
		lsr.b	#1,d0					; ... divided by 2...
		move.b	d0,SMPS_Track.ModulationSteps(a5)	; ... before being stored
		clr.w	SMPS_Track.ModulationVal(a5)		; Total accumulated modulation frequency change
		rts
; ===========================================================================

cfEnableModulation:
		bset	#3,SMPS_Track.PlaybackControl(a5)	; Turn on modulation
		rts
; ===========================================================================

cfStopTrack:
		bclr	#7,SMPS_Track.PlaybackControl(a5)	; Stop track
		bclr	#4,SMPS_Track.PlaybackControl(a5)	; Clear 'do not attack next note' bit
		tst.b	SMPS_Track.VoiceControl(a5)		; Is this a PSG track?
		bmi.s	.stoppsg				; Branch if yes
		tst.b	SMPS_RAM.f_updating_dac(a6)		; Is this the DAC we are updating?
		bmi.w	.exit					; Exit if yes
		jsr	FMNoteOff(pc)
		bra.s	.stoppedchannel
; ===========================================================================

.stoppsg:
		jsr	PSGNoteOff(pc)

.stoppedchannel:
		tst.b	SMPS_RAM.f_voice_selector(a6)		; Are we updating SFX?
		bpl.w	.exit					; Exit if not
		_clr.b	SMPS_RAM.v_sndprio(a6)			; Clear priority
		moveq	#0,d0
		move.b	SMPS_Track.VoiceControl(a5),d0		; Get voice control bits
		bmi.s	.getpsgptr				; Branch if PSG
		lea	SFX_BGMChannelRAM(pc),a0
		movea.l	a5,a3
		cmpi.b	#4,d0					; Is this FM4?
		bne.s	.getpointer				; Branch if not
		tst.b	SMPS_RAM.v_spcsfx_fm4_track.PlaybackControl(a6)	; Is special SFX playing?
		bpl.s	.getpointer				; Branch if not
		lea	SMPS_RAM.v_spcsfx_fm4_track(a6),a5
		movea.l	SMPS_RAM.v_special_voice_ptr(a6),a1	; Get voice pointer
		bra.s	.gotpointer
; ===========================================================================

.getpointer:
		subq.b	#2,d0					; SFX can only use FM3 and up
		lsl.b	#2,d0
		movea.l	(a0,d0.w),a5
		tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
		bpl.s	.novoiceupd				; Branch if not
		movea.l	SMPS_RAM.v_voice_ptr(a6),a1		; Get voice pointer

.gotpointer:
		bclr	#2,SMPS_Track.PlaybackControl(a5)	; Clear 'SFX overriding' bit
		bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
	if FixBugs
		moveq	#0,d0
	else
		; DANGER! `SetVoice` expects d0 to be a word, but it's only passed
		; as a byte below. This may result in restoring invalid/broken FM
		; voices during fade out sequence if upper byte of d0 was trashed.
	endif
		move.b	SMPS_Track.VoiceIndex(a5),d0		; Current voice
		jsr	SetVoice(pc)

.novoiceupd:
		movea.l	a3,a5
		cmpi.b	#2,SMPS_Track.VoiceControl(a5)
		bne.s	.exit
		clr.b	SMPS_RAM.v_se_mode_flag(a6)
		moveq	#0,d1
		moveq	#$27,d0
		jsr	WriteFMI(pc)
		bra.s	.exit
; ===========================================================================

.getpsgptr:
		lea	SMPS_RAM.v_spcsfx_psg3_track(a6),a0
		tst.b	SMPS_Track.PlaybackControl(a0)		; Is track playing?
		bpl.s	.getchannelptr				; Branch if not
		cmpi.b	#$E0,d0					; Is it the noise channel?
		beq.s	.gotchannelptr				; Branch if yes
		cmpi.b	#$C0,d0					; Is it PSG 3?
		beq.s	.gotchannelptr				; Branch if yes

.getchannelptr:
		lea	SFX_BGMChannelRAM(pc),a0
		lsr.b	#3,d0
		movea.l	(a0,d0.w),a0

.gotchannelptr:
		bclr	#2,SMPS_Track.PlaybackControl(a0)	; Clear 'SFX overriding' bit
		bset	#1,SMPS_Track.PlaybackControl(a0)	; Set 'track at rest' bit
		cmpi.b	#$E0,SMPS_Track.VoiceControl(a0)	; Is this a noise pointer?
		bne.s	.exit					; Branch if not
		move.b	SMPS_Track.PSGNoise(a0),(psg_input).l	; Set noise tone

.exit:
		addq.w	#8,sp					; Tamper with return value so we don't go back to caller
		rts
; ===========================================================================

cfSetPSGNoise:
		move.b	#$E0,SMPS_Track.VoiceControl(a5)	; Turn channel into noise channel
		move.b	(a4)+,SMPS_Track.PSGNoise(a5)		; Save noise tone
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is track being overridden?
		bne.s	.locret					; Return if yes
		move.b	-1(a4),(psg_input).l			; Set tone

.locret:
		rts
; ===========================================================================

cfDisableModulation:
		bclr	#3,SMPS_Track.PlaybackControl(a5)	; Disable modulation
		rts
; ===========================================================================

cfSetPSGTone:
		move.b	(a4)+,SMPS_Track.VoiceIndex(a5)		; Set current PSG tone
		rts
; ===========================================================================

cfJumpTo:
		move.b	(a4)+,d0				; High byte of offset
		lsl.w	#8,d0					; Shift it into place
		move.b	(a4)+,d0				; Low byte of offset
		adda.w	d0,a4					; Add to current position
		subq.w	#1,a4					; Put back one byte
		rts
; ===========================================================================

cfRepeatAtPos:
		moveq	#0,d0
		move.b	(a4)+,d0				; Loop index
		move.b	(a4)+,d1				; Repeat count
		tst.b	SMPS_Track.LoopCounters(a5,d0.w)	; Has this loop already started?
		bne.s	.loopexists				; Branch if yes
		move.b	d1,SMPS_Track.LoopCounters(a5,d0.w)	; Initialize repeat count

.loopexists:
		subq.b	#1,SMPS_Track.LoopCounters(a5,d0.w)	; Decrease loop's repeat count
		bne.s	cfJumpTo				; If nonzero, branch to target
		addq.w	#2,a4					; Skip target address
		rts
; ===========================================================================

cfJumpToGosub:
		moveq	#0,d0
		move.b	SMPS_Track.StackPointer(a5),d0		; Current stack pointer
		subq.b	#4,d0					; Add space for another target
		move.l	a4,(a5,d0.w)				; Put in current address (*before* target for jump!)
		move.b	d0,SMPS_Track.StackPointer(a5)		; Store new stack pointer
		bra.s	cfJumpTo
; ===========================================================================

cfJumpReturn:
		moveq	#0,d0
		move.b	SMPS_Track.StackPointer(a5),d0		; Track stack pointer
		movea.l	(a5,d0.w),a4				; Set track return address
		addq.w	#2,a4					; Skip jump target address from gosub flag
		addq.b	#4,d0					; Actually 'pop' value
		move.b	d0,SMPS_Track.StackPointer(a5)		; Set new stack pointer
		rts
; ===========================================================================

cfSetTempoDivider:
		move.b	(a4)+,SMPS_Track.TempoDivider(a5)	; Set tempo divider on current track
		rts
; ===========================================================================

cfChangeTransposition:
		move.b	(a4)+,d0				; Get parameter
		add.b	d0,SMPS_Track.Transpose(a5)		; Add to transpose value
		rts
; ===========================================================================

cfSetTempoDividerAll:
		lea	SMPS_RAM.v_music_track_ram(a6),a0
		move.b	(a4)+,d0				; Get new tempo divider
		moveq	#SMPS_Track.len,d1
		moveq	#SMPS_MUSIC_TRACK_COUNT-1,d2		; 1 DAC + 6 FM + 3 PSG tracks

.trackloop:
		move.b	d0,SMPS_Track.TempoDivider(a0)		; Set track's tempo divider
		adda.w	d1,a0
		dbf	d2,.trackloop
		rts
; ===========================================================================

cfStopSpecialFM4:
		bclr	#7,SMPS_Track.PlaybackControl(a5)	; Stop track
		bclr	#4,SMPS_Track.PlaybackControl(a5)	; Clear 'do not attack next note' bit
		jsr	FMNoteOff(pc)
		tst.b	SMPS_RAM.v_sfx_fm4_track.PlaybackControl(a6) ; Is SFX using FM4?
		bmi.s	.exit					; Branch if yes
		movea.l	a5,a3
		lea	SMPS_RAM.v_music_fm4_track(a6),a5
		movea.l	SMPS_RAM.v_voice_ptr(a6),a1		; Voice pointer
		bclr	#2,SMPS_Track.PlaybackControl(a5)	; Clear 'SFX is overriding' bit
		bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
	if FixBugs
		moveq	#0,d0
	else
		; Bug: The low bit is not cleared here
	endif
		move.b	SMPS_Track.VoiceIndex(a5),d0		; Current voice
		jsr	SetVoice(pc)
		movea.l	a3,a5

.exit:
		addq.w	#8,sp					; Tamper with return value so we don't return to caller
		rts
; ===========================================================================

cfFE_SpcFM3Mode:
		lea	SMPS_RAM.v_detune_start(a6),a0
		moveq	#(SMPS_RAM.v_detune_end-SMPS_RAM.v_detune_start)-1,d0

.clear:
		move.b	(a4)+,(a0)+
		dbf	d0,.clear
		move.b	#$80,SMPS_RAM.v_se_mode_flag(a6)
		move.b	#$27,d0
		moveq	#$40,d1
		bra.w	WriteFMI
; ===========================================================================

cfSSG_Reg:
		lea	SSG_Reg_Table(pc),a1
		moveq	#(SSG_Reg_Table_end-SSG_Reg_Table)/2-1,d3

.loop:
		move.b	(a1)+,d0
		move.b	(a4)+,d1
		bset	#3,d1
		jsr	WriteFMIorIIMain(pc)
		move.b	(a1)+,d0
		moveq	#$1F,d1
		jsr	WriteFMIorIIMain(pc)
		dbf	d3,.loop
		rts
; ===========================================================================

SSG_Reg_Table:
		dc.b $90, $50
		dc.b $98, $58
		dc.b $94, $54
		dc.b $9C, $5C
SSG_Reg_Table_end:
; ===========================================================================
; ---------------------------------------------------------------------------
; DAC driver
; ---------------------------------------------------------------------------
DACDriver:	include	"sound/z80.asm"
DACDriver_end:

; ---------------------------------------------------------------------------
; SMPS2ASM - A collection of macros that make SMPS's bytecode human-readable.
; ---------------------------------------------------------------------------
FixMusicAndSFXDataBugs = FixBugs
SonicDriverVer = 1 ; Tell SMPS2ASM that we're using Sonic 1's driver.
		include "sound/_smps2asm_inc.asm"

; ---------------------------------------------------------------------------
; Music data
; ---------------------------------------------------------------------------
Music81:	include	"sound/music/Mus81 - GHZ.asm"
		even
Music82:	include	"sound/music/Mus82 - LZ.asm"
		even
Music83:	include	"sound/music/Mus83 - MZ.asm"
		even
Music84:	include	"sound/music/Mus84 - SLZ.asm"
		even
Music85:	include	"sound/music/Mus85 - SZ.asm"
		even
Music86:	include	"sound/music/Mus86 - CWZ.asm"
		even
Music87:	include	"sound/music/Mus87 - Invincibility.asm"
		even
Music88:	include	"sound/music/Mus88 - Extra Life.asm"
		even
Music89:	include	"sound/music/Mus89 - Special Stage.asm"
		even
Music8A:	include	"sound/music/Mus8A - Title Screen.asm"
		even
Music8B:	include	"sound/music/Mus8B - Ending.asm"
		even
Music8C:	include	"sound/music/Mus8C - Boss.asm"
		even
Music8D:	include	"sound/music/Mus8D - FZ.asm"
		even
Music8E:	include	"sound/music/Mus8E - Sonic Got Through.asm"
		even
Music8F:	include	"sound/music/Mus8F - Game Over.asm"
		even
Music90:	include	"sound/music/Mus90 - Continue Screen.asm"
		even
Music91:	include	"sound/music/Mus91 - Credits.asm"
		even
; ---------------------------------------------------------------------------
; Sound	effect pointers
; ---------------------------------------------------------------------------
SoundIndex:
ptr_sndA0:	dc.l SoundA0
ptr_sndA1:	dc.l SoundA1
ptr_sndA2:	dc.l SoundA2
ptr_sndA3:	dc.l SoundA3
ptr_sndA4:	dc.l SoundA4
ptr_sndA5:	dc.l SoundA5
ptr_sndA6:	dc.l SoundA6
ptr_sndA7:	dc.l SoundA7
ptr_sndA8:	dc.l SoundA8
ptr_sndA9:	dc.l SoundA9
ptr_sndAA:	dc.l SoundAA
ptr_sndAB:	dc.l SoundAB
ptr_sndAC:	dc.l SoundAC
ptr_sndAD:	dc.l SoundAD
ptr_sndAE:	dc.l SoundAE
ptr_sndAF:	dc.l SoundAF
ptr_sndB0:	dc.l SoundB0
ptr_sndB1:	dc.l SoundB1
ptr_sndB2:	dc.l SoundB2
ptr_sndB3:	dc.l SoundB3
ptr_sndB4:	dc.l SoundB4
ptr_sndB5:	dc.l SoundB5
ptr_sndB6:	dc.l SoundB6
ptr_sndB7:	dc.l SoundB7
ptr_sndB8:	dc.l SoundB8
ptr_sndB9:	dc.l SoundB9
ptr_sndBA:	dc.l SoundBA
ptr_sndBB:	dc.l SoundBB
ptr_sndBC:	dc.l SoundBC
ptr_sndBD:	dc.l SoundBD
ptr_sndBE:	dc.l SoundBE
ptr_sndBF:	dc.l SoundBF
ptr_sndC0:	dc.l SoundC0
ptr_sndC1:	dc.l SoundC1
ptr_sndC2:	dc.l SoundC2
ptr_sndC3:	dc.l SoundC3
ptr_sndC4:	dc.l SoundC4
ptr_sndC5:	dc.l SoundC5
ptr_sndC6:	dc.l SoundC6
ptr_sndC7:	dc.l SoundC7
ptr_sndC8:	dc.l SoundC8
ptr_sndC9:	dc.l SoundC9
ptr_sndCA:	dc.l SoundCA
ptr_sndCB:	dc.l SoundCB
ptr_sndCC:	dc.l SoundCC
ptr_sndCD:	dc.l SoundCD
ptr_sndCE:	dc.l SoundCE
ptr_sndCF:	dc.l SoundCF
ptr_sndend:
; ---------------------------------------------------------------------------
; Special sound effect pointers
; ---------------------------------------------------------------------------
SpecSoundIndex:
ptr_sndD0:	dc.l SoundD0
ptr_sndD1:	dc.l SoundD1
ptr_sndD2:	dc.l SoundD2
ptr_specend:

SoundA0:	include "sound/sfx/SndA0 - Jump.asm"
		even
SoundA1:	include "sound/sfx/SndA1.asm"
		even
SoundA2:	include "sound/sfx/SndA2.asm"
		even
SoundA3:	include "sound/sfx/SndA3 - Death.asm"
		even
SoundA4:	include "sound/sfx/SndA4 - Skid.asm"
		even
SoundA5:	include "sound/sfx/SndA5.asm"
		even
SoundA6:	include "sound/sfx/SndA6 - Hit Spikes.asm"
		even
SoundA7:	include "sound/sfx/SndA7 - Push Block.asm"
		even
SoundA8:	include "sound/sfx/SndA8.asm"
		even
SoundA9:	include "sound/sfx/SndA9.asm"
		even
SoundAA:	include "sound/sfx/SndAA - Splash.asm"
		even
SoundAB:	include "sound/sfx/SndAB.asm"
		even
SoundAC:	include "sound/sfx/SndAC - Hit Boss.asm"
		even
SoundAD:	include "sound/sfx/SndAD.asm"
		even
SoundAE:	include "sound/sfx/SndAE - Fireball.asm"
		even
SoundAF:	include "sound/sfx/SndAF - Shield.asm"
		even
SoundB0:	include "sound/sfx/SndB0.asm"
		even
SoundB1:	include "sound/sfx/SndB1.asm"
		even
SoundB2:	include "sound/sfx/SndB2.asm"
		even
SoundB3:	include "sound/sfx/SndB3.asm"
		even
SoundB4:	include "sound/sfx/SndB4 - Bumper.asm"
		even
SoundB5:	include "sound/sfx/SndB5 - Ring.asm"
		even
SoundB6:	include "sound/sfx/SndB6 - Spikes Move.asm"
		even
SoundB7:	include "sound/sfx/SndB7 - Rumbling.asm"
		even
SoundB8:	include "sound/sfx/SndB8.asm"
		even
SoundB9:	include "sound/sfx/SndB9 - Collapse.asm"
		even
SoundBA:	include "sound/sfx/SndBA.asm"
		even
SoundBB:	include "sound/sfx/SndBB - Door.asm"
		even
SoundBC:	include "sound/sfx/SndBC - Teleport.asm"
		even
SoundBD:	include "sound/sfx/SndBD - ChainStomp.asm"
		even
SoundBE:	include "sound/sfx/SndBE - Roll.asm"
		even
SoundBF:	include "sound/sfx/SndBF.asm"
		even
SoundC0:	include "sound/sfx/SndC0 - Basaran Flap.asm"
		even
SoundC1:	include "sound/sfx/SndC1 - Break Item.asm"
		even
SoundC2:	include "sound/sfx/SndC2.asm"
		even
SoundC3:	include "sound/sfx/SndC3.asm"
		even
SoundC4:	include "sound/sfx/SndC4 - Bomb.asm"
		even
SoundC5:	include "sound/sfx/SndC5 - Cash Register.asm"
		even
SoundC6:	include "sound/sfx/SndC6 - Ring Loss.asm"
		even
SoundC7:	include "sound/sfx/SndC7 - Chain Rising.asm"
		even
SoundC8:	include "sound/sfx/SndC8 - Burning.asm"
		even
SoundC9:	include "sound/sfx/SndC9.asm"
		even
SoundCA:	include "sound/sfx/SndCA.asm"
		even
SoundCB:	include "sound/sfx/SndCB - Wall Smash.asm"
		even
SoundCC:	include "sound/sfx/SndCC - Spring.asm"
		even
SoundCD:	include "sound/sfx/SndCD - Switch.asm"
		even
SoundCE:	include "sound/sfx/SndCE - Ring Left Speaker.asm"
		even
SoundCF:	include "sound/sfx/SndCF - Signpost.asm"
		even
SoundD0:	include "sound/sfx/SndD0 - Waterfall.asm"
		even
; Leftovers from Michael Jackson's Moonwalker begin here.
SoundD1:	include "sound/sfx/SndD1.asm"
		even
SoundD2:	include "sound/sfx/SndD2.asm"
		even
SoundD3:	include "sound/sfx/SndD3.asm"
		even
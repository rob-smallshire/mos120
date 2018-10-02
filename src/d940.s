;*************************************************************************
;*************************************************************************
;**                                                                     **
;**      SYSTEM STARTUP                                                 **
;**                                                                     **
;*************************************************************************
;*************************************************************************

;* DEFAULT PAGE &02 SETTINGS (VECTORS, OSBYTE VARIABLES)
;* RESET CODE

;*************************************************************************
;*                                                                       *
;*       DEFAULT SYSTEM SETTINGS FOR PAGE &02                            *
;*                                                                       *
;*************************************************************************

; ### -------------------------------------------------------------------------
; ### |                                                                       |
; ### |       DEFAULT VECTOR TABLE                                            |
; ### |                                                                       |
; ### -------------------------------------------------------------------------

.org		$d940

		.word	$E310		; USERV				&200
		.word	$DC54		; BRKV 				&202
		.word	$DC93		; IRQ1V				&204
		.word	$DE89		; IRQ2V				&206
		.word	$DF89		; CLIV 				&208
		.word	$E772		; BYTEV				&20A
		.word	$E7EB		; WORDV				&20C
		.word	$E0A4		; WRCHV				&20E
		.word	$DEC5		; RDCHV				&210
		.word	$F27D		; FILEV				&212
		.word	$F18E		; ARGSV				&214
		.word	$F4C9		; BGETV				&216
		.word	$F529		; BPUTV				&218
		.word	$FFA6		; GBPBV				&21A
		.word	$F3CA		; FINDV				&21C
		.word	$F1B1		; FSCV 				&21E
		.word	$FFA6		; EVNTV				&220
		.word	$FFA6		; UPTV 				&222
		.word	$FFA6		; NETV 				&224
		.word	$FFA6		; VDUV 				&226
		.word	$EF02		; KEYV 				&228
		.word	$E4B3		; INSBV				&22A
		.word	$E464		; REMVB				&22C
		.word	$E1D1		; CNPV 				&22E
		.word	$FFA6		; IND1V				&230
		.word	$FFA6		; IND2V				&232
		.word	$FFA6		; IND3V				&234

; ### -------------------------------------------------------------------------
; ### |                                                                       |
; ### |       DEFAULT MOS VARIABLES SETTINGS                                  |
; ### |                                                                       |
; ### -------------------------------------------------------------------------

;* Read/Written by OSBYTE &A6 to &FC

		.word	$0190		; OSBYTE variables base address          &236   *FX166/7
					;  (address to add to osbyte number)
		.word	$0D9F		; Address of extended vectors            &238   *FX168/9
		.word	$02A1		; Address of ROM information table       &23A   *FX170/1
		.word	$F02B		; Address of key translation table       &23C   *FX172/3
		.word	$0300		; Address of VDU variables               &23E   *FX174/5

		.byte	$00		; CFS/Vertical sync Timeout counter      &240   *FX176
		.byte	$00		; Current input buffer number            &241   *FX177
		.byte	$FF		; Keyboard interrupt processing flag     &242   *FX178
		.byte	$00		; Primary OSHWM (default PAGE)           &243   *FX179
		.byte	$00		; Current OSHWM (PAGE)                   &244   *FX180
		.byte	$01		; RS423 input mode                       &245   *FX181
		.byte	$00		; Character explosion state              &246   *FX182
		.byte	$00		; CFS/RFS selection, CFS=0 ROM=2         &247   *FX183
		.byte	$00		; Video ULA control register copy        &248   *FX184
		.byte	$00		; Pallette setting copy                  &249   *FX185
		.byte	$00		; ROM number selected at last BRK        &24A   *FX186
		.byte	$FF		; BASIC ROM number                       &24B   *FX187
		.byte	$04		; Current ADC channel number             &24C   *FX188
		.byte	$04		; Maximum ADC channel number             &24D   *FX189
		.byte	$00		; ADC conversion 0/8bit/12bit            &24E   *FX190
		.byte	$FF		; RS423 busy flag (bit 7=0, busy)        &24F   *FX191

		.byte	$56		; ACIA control register copy             &250   *FX192
		.byte	$19		; Flash counter                          &251   *FX193
		.byte	$19		; Flash mark period count                &252   *FX194
		.byte	$19		; Flash space period count               &253   *FX195
		.byte	$32		; Keyboard auto-repeat delay             &254   *FX196
		.byte	$08		; Keyboard auto-repeat rate              &255   *FX197
		.byte	$00		; *EXEC file handle                      &256   *FX198
		.byte	$00		; *SPOOL file handle                     &257   *FX199
		.byte	$00		; Break/Escape handing                   &258   *FX200
		.byte	$00		; Econet keyboard disable flag           &259   *FX201
		.byte	$20		; Keyboard status                        &25A   *FX202
					;   bit 3=1 shift pressed
					;   bit 4=0 caps  lock
					;   bit 5=0 shift lock
					;   bit 6=1 control bit
					;   bit 7=1 shift enabled
		.byte	$09		; Serial input buffer full threshold     &25B   *FX203
		.byte	$00		; Serial input suppression flag          &25C   *FX204
		.byte	$00		; Cassette/RS423 flag (0=CFS, &40=RS423) &25D   *FX205
		.byte	$00		; Econet OSBYTE/OSWORD interception flag &25E   *FX206
		.byte	$00		; Econet OSRDCH interception flag        &25F   *FX207

		.byte	$00		; Econet OSWRCH interception flag        &260   *FX208
		.byte	$50		; Speech enable/disable flag (&20/&50)   &261   *FX209
		.byte	$00		; Sound output disable flag              &262   *FX210
		.byte	$03		; BELL channel number                    &263   *FX211
		.byte	$90		; BELL amplitude/Envelope number         &264   *FX212
		.byte	$64		; BELL frequency                         &265   *FX213
		.byte	$06		; BELL duration                          &266   *FX214
		.byte	$81		; Startup message/!BOOT error status     &267   *FX215
		.byte	$00		; Length of current soft key string      &268   *FX216
		.byte	$00		; Lines printed since last paged halt    &269   *FX217
		.byte	$00		; 0-(Number of items in VDU queue)       &26A   *FX218
		.byte	$09		; TAB key value                          &26B   *FX219
		.byte	$1B		; ESCAPE character                       &26C   *FX220

		;  The following are input buffer code interpretation variables for
		;  bytes entered into the input buffer with b7 set (is 128-255).
		;  The standard keyboard only enters characters &80-&BF with the
		;  function keys, but other characters can be entered, for instance
		;  via serial input of via other keyboard input systems.
		;  0=ignore key
		;  1=expand as soft key
		;  2-FF add to base for ASCII code
		.byte	$01		; C0-&CF                                 &26D   *FX221
		.byte	$D0		; D0-&DF                                 &26E   *FX222
		.byte	$E0		; E0-&EF                                 &26F   *FX223
		.byte	$F0		; F0-&FF                                 &270   *FX224
		.byte	$01		; 80-&8F function key                    &271   *FX225
		.byte	$80		; 90-&9F Shift+function key              &272   *FX226
		.byte	$90		; A0-&AF Ctrl+function key               &273   *FX227
		.byte	$00		; B0-&BF Shift+Ctrl+function key         &274   *FX228

		.byte	$00		; ESCAPE key status (0=ESC, 1=ASCII)     &275   *FX229
		.byte	$00		; ESCAPE action                          &276   *FX230
		.byte	$FF		; USER 6522 Bit IRQ mask                 &277   *FX231
		.byte	$FF		; 6850 ACIA Bit IRQ bit mask             &278   *FX232
		.byte	$FF		; System 6522 IRQ bit mask               &279   *FX233
		.byte	$00		; Tube prescence flag                    &27A   *FX234
		.byte	$00		; Speech processor prescence flag        &27B   *FX235
		.byte	$00		; Character destination status           &27C   *FX236
		.byte	$00		; Cursor editing status                  &27D   *FX237

;****************** Soft Reset high water mark ***************************

		.byte	$00		; unused                                 &27E   *FX238
		.byte	$00		; unused                                 &27F   *FX239
		.byte	$00		; Country code                           &280   *FX240
		.byte	$00		; User flag                              &281   *FX241
		.byte	$64		; Serial ULA control register copy       &282   *FX242
		.byte	$05		; Current system clock state             &283   *FX243
		.byte	$FF		; Soft key consitancy flag               &284   *FX244
		.byte	$01		; Printer destination                    &285   *FX245
		.byte	$0A		; Printer ignore character               &286   *FX246

;****************** Hard Reset High water mark ***************************

		.byte	$00		; Break Intercept Vector JMP opcode      &288   *FX247
		.byte	$00		; Break Intercept Vector address low     &288   *FX248
		.byte	$00		; Break Intercept Vector address high    &289   *FX249
		.byte	$00		; unused (memory used for VDU)           &28A   *FX250
		.byte	$00		; unused (memory used for display)       &28B   *FX251
		.byte	$FF		; Current language ROM number            &28C   *FX252

;****************** Power-On Reset High Water mark ***********************


;**************************************************************************
;**************************************************************************
;**                                                                      **
;**      RESET (BREAK) ENTRY POINT                                       **
;**                                                                      **
;**      Power up Enter with nothing set, 6522 System VIA IER bits       **
;**      0 to 6 will be clear                                            **
;**                                                                      **
;**      BREAK IER bits 0 to 6 one or more will be set 6522 IER          **
;**      not reset by BREAK                                              **
;**                                                                      **
;**************************************************************************
;**************************************************************************

		lda	#$40		; set NMI first instruction to RTI
		sta	$0D00		; NMI ram start

		sei			; disable interrupts just in case
		cld			; clear decimal flag
		ldx	#$FF		; reset stack to where it should be
		txs			; (&1FF)
		lda	$FE4E		; read interupt enable register of the system VIA
		asl			; shift bit 7 into carry
		pha			; save what's left
		beq	$D9E7		; if Power up A=0 so D9E7
		lda	$0258		; else if BREAK pressed read BREAK Action flags (set by
					; *FX200,n)
		lsr			; divide by 2
		cmp	#$01		; if (bit 1 not set by *FX200)
		bne	$DA03		; then &DA03
		lsr			; divide A by 2 again (A=0 if *FX200,2/3 else A=n/4

;********** clear memory routine ******************************************

		ldx	#$04		; get page to start clearance from (4)
		stx	$01		; store it in ZP 01
		sta	$00		; store A at 00

		tay			; and in Y to set loop counter

		sta	($00),Y		; clear store
		cmp	$01		; until address &01 =0
		beq	$D9FD		; 
		iny			; increment pointer
		bne	$D9EE		; if not zero loop round again
		iny			; else increment again (Y=1) this avoids overwriting
					; RTI instruction at &D00
		inx			; increment X
		inc	$01		; increment &01
		bpl	$D9EE		; loop until A=&80 then exit
					; note that RAM addressing for 16k loops around so
					; &4000=&00 hence checking &01 for 00.  This avoids
					; overwriting zero page on BREAK


		stx	$028E		; writes marker for available RAM 40 =16k,80=32
		stx	$0284		; write soft key consistency flag

;**+********** set up system VIA *****************************************

		ldx	#$0F		; set PORT B to output on bits 0-3 Input 4-7
		stx	$FE42		; 


;*************************************************************************
;*                                                                       *
;*        set addressable latch IC 32 for peripherals via PORT B         *
;*                                                                       *
;*       ;bit 3 set sets addressed latch high adds 8 to VIA address      *
;*       ;bit 3 reset sets addressed latch low                           *
;*                                                                       *
;*       Peripheral              VIA bit 3=0             VIA bit 3=1     *
;*                                                                       *
;*       Sound chip              Enabled                 Disabled        *
;*       speech chip (RS)        Low                     High            *
;*       speech chip (WS)        Low                     High            *
;*       Keyboard Auto Scan      Disabled                Enabled         *
;*       C0 address modifier     Low                     High            *
;*       C1 address modifier     Low                     High            *
;*       Caps lock  LED          ON                      OFF             *
;*       Shift lock LED          ON                      OFF             *
;*                                                                       *
;*       C0 & C1 are involved with hardware scroll screen address        *
;*************************************************************************

		; X=&F on entry

		dex			; loop start
		stx	$FE40		; write latch IC32
		cpx	#$09		; is it 9
		bcs	$DA08		; if so go back and do it again
					; X=8 at this point
					; Caps lock On, SHIFT lock undetermined
					; Keyboard Autoscan on
					; sound disabled (may still sound)
		inx			; X=9
		txa			; A=X
		jsr	$F02A		; interrogate keyboard
		cpx	#$80		; for keyboard links 9-2 and CTRL key (1)
		ror	$FC		; rotate MSB into bit 7 of &FC

		tax			; get back value of X for loop
		dex			; decrement it
		bne	$DA11		; and if >0 do loop again
					;  on exit if Carry set link 3 made
					; link 2 = bit 0 of &FC and so on
					; if CTRL pressed bit 7 of &FC=1
					; X=0
		stx	$028D		; clear last BREAK flag
		rol	$FC		; CTRL is now in carry &FC is keyboard links
		jsr	$EEEB		; set LEDs carry on entry  bit 7 of A on exit
		ror			; get carry back into carry flag

;****** set up page 2 ****************************************************

		ldx	#$9C		; 
		ldy	#$8D		; 
		pla			; get back A from &D9DB
		beq	$DA36		; if A=0 power up reset so DA36 with X=&9C Y=&8D
		ldy	#$7E		; else Y=&7E
		bcc	$DA42		; and if not CTRL-BREAK DA42 WARM RESET
		ldy	#$87		; else Y=&87 COLD RESET
		inc	$028D		; &28D=1

		inc	$028D		; &28D=&28D+1
		lda	$FC		; get keyboard links set
		eor	#$FF		; invert
		sta	$028F		; and store at &28F
		ldx	#$90		; X=&90

;**********: set up page 2 *************************************************

		; on entry    &28D=0 Warm reset, X=&9C, Y=&7E
		; &28D=1 Power up  , X=&90, Y=&8D
		; &28D=2 Cold reset, X=&9C, Y=&87

		lda	#$00		; A=0
		cpx	#$CE		; zero &200+X to &2CD
		bcc	$DA4A		; 
		lda	#$FF		; then set &2CE to &2FF to &FF
		sta	$0200,X		; 
		inx			; 
		bne	$DA44		; 
					; A=&FF X=0
		sta	$FE63		; set port A of user via to all outputs (printer out)

		txa			; A=0
		ldx	#$E2		; X=&E2
		sta	$00,X		; zero zeropage &E2 to &FF
		inx			; 
		bne	$DA56		; X=0

		lda	$D93F,Y		; copy data from &D93F+Y
		sta	$01FF,Y		; to &1FF+Y
		dey			; until
		bne	$DA5B		; 1FF+Y=&200

		lda	#$62		; A=&62
		sta	$ED		; store in &ED
		jsr	$FB0A		; set up ACIA
					; X=0

;************** clear interrupt and enable registers of Both VIAs ********

		lda	#$7F		; 
		inx			; 
		sta	$FE4D,X		; 
		sta	$FE6D,X		; 
		dex			; 
		bpl	$DA6E		; 

		cli			; briefly allow interrupts to clear anything pending
		sei			; disallow again N.B. All VIA IRQs are disabled
		bit	$FC		; if bit 6=1 then JSR &F055 (normally 0)
		bvc	$DA80		; else DA80
		jsr	$F055		; F055 JMP (&FDFE) probably causes a BRK unless
					; hardware there redirects it.
					; 
		ldx	#$F2		; enable interrupts 1,4,5,6 of system VIA
		stx	$FE4E		; 
					; 0      Keyboard enabled as needed
					; 1      Frame sync pulse
					; 4      End of A/D conversion
					; 5      T2 counter (for speech)
					; 6      T1 counter (10 mSec intervals)
					; 
		ldx	#$04		; set system VIA PCR
		stx	$FE4C		; 
					; CA1 to interrupt on negative edge (Frame sync)
					; CA2 Handshake output for Keyboard
					; CB1 interrupt on negative edge (end of conversion)
					; CB2 Negative edge (Light pen strobe)
					; 
		lda	#$60		; set system VIA ACR
		sta	$FE4B		; 
					; disable latching
					; disable shift register
					; T1 counter continuous interrupts
					; T2 counter timed interrupt

		lda	#$0E		; set system VIA T1 counter (Low)
		sta	$FE46		; 
					; this becomes effective when T1 hi set

		sta	$FE6C		; set user VIA PCR
					; CA1 interrupt on -ve edge (Printer Acknowledge)
					; CA2 High output (printer strobe)
					; CB1 Interrupt on -ve edge (user port)
					; CB2 Negative edge (user port)

		sta	$FEC0		; set up A/D converter
					; Bits 0 & 1 determine channel selected
					; Bit 3=0 8 bit conversion bit 3=1 12 bit

		cmp	$FE6C		; read user VIA IER if = &0E then DAA2 chip present
		beq	$DAA2		; so goto DAA2
		inc	$0277		; else increment user VIA mask to 0 to bar all
					; user VIA interrupts

		lda	#$27		; set T1 (hi) to &27 this sets T1 to &270E (9998 uS)
		sta	$FE47		; or 10msec, interrupts occur every 10msec therefore
		sta	$FE45		; 

		jsr	$EC60		; clear the sound channels

		lda	$0282		; read serial ULA control register
		and	#$7F		; zero bit 7
		jsr	$E6A7		; and set up serial ULA

		ldx	$0284		; get soft key status flag
		beq	$DABD		; if 0 (keys OK) then DABD
		jsr	$E9C8		; else reset function keys


;*************************************************************************
;*                                                                       *
;*       Check sideways ROMs and make ROM list                           *
;*                                                                       *
;*************************************************************************

		; X=0
		jsr	$DC16		; set up ROM latch and RAM copy to X
		ldx	#$03		; set X to point to offset in table
		ldy	$8007		; get copyright offset from ROM

		;  DF0C = ")C(",0
		lda	$8000,Y		; get first byte
		cmp	$DF0C,X		; compare it with table byte
		bne	$DAFB		; if not the same then goto DAFB
		iny			; point to next byte
		dex			; (s)
		bpl	$DAC5		; and if still +ve go back to check next byte

		; this point is reached if 5 bytes indicate valid
		; ROM (offset +4 in (C) string)


;*************************************************************************
;* Check first 1K of each ROM against higher priority ROMs to ensure that*
;* there are no duplicates, if duplicate found ignore lower priority ROM *
;*************************************************************************

		ldx	$F4		; get RAM copy of ROM No. in X
		ldy	$F4		; and Y

		iny			; increment Y to check
		cpy	#$10		; if ROM 15 is current ROM
		bcs	$DAFF		; if equal or more than 16 goto &DAFF
					; to store catalogue byte
		tya			; else put Y in A
		eor	#$FF		; invert it
		sta	$FA		; and store at &FA
		lda	#$7F		; store &7F at
		sta	$FB		; &FB to get address &7FFF-Y

		sty	$FE30		; set new ROM
		lda	($FA),Y		; Get byte
		stx	$FE30		; switch back to previous ROM
		cmp	($FA),Y		; and compare with previous byte called
		bne	$DAD5		; if not the same then go back and do it again
					; with next rom up
		inc	$FA		; else increment &FA to point to new location
		bne	$DAE3		; if &FA<>0 then check next byte
		inc	$FB		; else inc &FB
		lda	$FB		; and check that it doesn't exceed
		cmp	#$84		; &84 (1k checked)
		bcc	$DAE3		; then check next byte(s)

		ldx	$F4		; X=(&F4)
		bpl	$DB0C		; if +ve then &DB0C

		lda	$8006		; get rom type
		sta	$02A1,X		; store it in catalogue
		and	#$8F		; check for BASIC (bit 7 not set)
		bne	$DB0C		; if not BASIC the DB0C
		stx	$024B		; else store X at BASIC pointer

		inx			; increment X to point to next ROM
		cpx	#$10		; is it 15 or less
		bcc	$DABD		; if so goto &DABD for next ROM

; ### OS SERIES V
; ### GEOFF COX
;*************************************************************************
;*                                                                       *
;*       Check SPEECH System                                             *
;*                                                                       *
;*************************************************************************

		; X=&10
		bit	$FE40		; if bit 7 low then we have speech system fitted
		bmi	$DB27		; else goto DB27

		dec	$027B		; (027B)=&FF to indicate speech present

		ldy	#$FF		; Y=&FF
		jsr	$EE7F		; initialise speech generator
		dex			; via this
		bne	$DB19		; loop
					; X=0
		stx	$FE48		; set T2 timer for speech
		stx	$FE49		; 

;*********** SCREEN SET UP **********************************************
		; X=0
		lda	$028F		; get back start up options (mode)
		jsr	$C300		; then jump to screen initialisation

		ldy	#$CA		; Y=&CA
		jsr	$E4F1		; to enter this in keyboard buffer
					; this enables the *KEY 10 facility

;********* enter BREAK intercept with Carry Clear ************************

		jsr	$EAD9		; check to see if BOOT address is set up, if so
					; JMP to it

		jsr	$F140		; set up cassette options
		lda	#$81		; test for tube to FIFO buffer 1
		sta	$FEE0		; 
		lda	$FEE0		; 
		ror			; put bit 0 into carry
		bcc	$DB4D		; if no tube then DB4D
		ldx	#$FF		; else
		jsr	$F168		; issue ROM service call &FF
					; to initialise TUBE system
		bne	$DB4D		; if not 0 on exit (Tube not initialised) DB4D
		dec	$027A		; else set tube flag to show it's active

		ldy	#$0E		; set current value of PAGE
		ldx	#$01		; issue claim absolute workspace call
		jsr	$F168		; via F168
		ldx	#$02		; send private workspace claim call
		jsr	$F168		; via F168
		sty	$0243		; set primary OSHWM
		sty	$0244		; set current OSHWM
		ldx	#$FE		; issue call for Tube to explode character set etc.
		ldy	$027A		; Y=FF if tube present else Y=0
		jsr	$F168		; and make call via F168

		and	$0267		; if A=&FE and bit 7 of 0267 is set then continue
		bpl	$DB87		; else ignore start up message
		ldy	#$02		; output to screen
		jsr	$DEA9		; 'BBC Computer ' message
		lda	$028D		; 0=warm reset, anything else continue
		beq	$DB82		; 
		ldy	#$16		; by checking length of RAM
		bit	$028E		; 
		bmi	$DB7F		; and either
		ldy	#$11		; 
		jsr	$DEA9		; finishing message with '16K' or '32K'
		ldy	#$1B		; and two newlines
		jsr	$DEA9		; 

;*********: enter BREAK INTERCEPT ROUTINE WITH CARRY SET (call 1)

		sec			; 
		jsr	$EAD9		; look for break intercept jump do *TV etc
		jsr	$E9D9		; set up LEDs in accordance with keyboard status
		php			; save flags
		pla			; and get back in A
		lsr			; zero bits 4-7 and bits 0-2 bit 4 which was bit 7
		lsr			; may be set
		lsr			; 
		lsr			; 
		eor	$028F		; eor with start-up options which may or may not
		and	#$08		; invert bit 4
		tay			; Y=A
		ldx	#$03		; make fs initialisation call, passing boot option in Y
		jsr	$F168		; Eg, RUN, EXEC or LOAD !BOOT file
		beq	$DBBE		; if a ROM accepts this call then DBBE
		tya			; else put Y in A
		bne	$DBB8		; if Y<>0 DBB8
		lda	#$8D		; else set up standard cassete baud rates
		jsr	$F135		; via &F135

		ldx	#$D2		; 
		ldy	#$EA		; 
		dec	$0267		; decrement ignore start up message flag
		jsr	OSCLI		; and execute */!BOOT
		inc	$0267		; restore start up message flag
		bne	$DBBE		; if not zero then DBBE

		lda	#$00		; else A=0
		tax			; X=0
		jsr	$F137		; set tape speed

;******** Preserve current language on soft RESET ************************

		lda	$028D		; get last RESET Type
		bne	$DBC8		; if not soft reset DBC8

		ldx	$028C		; else get current language ROM address
		bpl	$DBE6		; if +ve (language available) then skip search routine


;*************************************************************************
;*                                                                       *
;*       SEARCH FOR LANGUAGE TO ENTER (Highest priority)                 *
;*                                                                       *
;*************************************************************************

		ldx	#$0F		; set pointer to highest available rom

		lda	$02A1,X		; get rom type from map
		rol			; put hi-bit into carry, bit 6 into bit 7
		bmi	$DBE6		; if bit 7 set then ROM has a language entry so DBE6

		dex			; else search for language until X=&ff
		bpl	$DBCA		; 

;*************** check if tube present ***********************************

		lda	#$00		; if bit 7 of tube flag is set BMI succeeds
		bit	$027A		; and TUBE is connected else
		bmi	$DC08		; make error

;********* no language error ***********************************************

		brk			; 
		.byte	$F9		; error number
		.byte	"Language?"		; message
		brk			; 

		clc			; 


;*************************************************************************
;*                                                                       *
;*       OSBYTE 142 - ENTER LANGUAGE ROM AT &8000                        *
;*                                                                       *
;*       X=rom number C set if OSBYTE call clear if initialisation       *
;*                                                                       *
;*************************************************************************

		php			; save flags
		stx	$028C		; put X in current ROM page
		jsr	$DC16		; select that ROM
		lda	#$80		; A=128
		ldy	#$08		; Y=8
		jsr	$DEAB		; display text string held in ROM at &8008,Y
		sty	$FD		; save Y on exit (end of language string)
		jsr	OSNEWL		; two line feeds
		jsr	OSNEWL		; are output
		plp			; then get back flags
		lda	#$01		; A=1 required for language entry
		bit	$027A		; check if tube exists
		bmi	$DC08		; and goto DC08 if it does
		jmp	$8000		; else enter language at &8000


;*************************************************************************
;*                                                                       *
;*       TUBE FOUND, ENTER TUBE SOFTWARE                                 *
;*                                                                       *
;*************************************************************************

		jmp	$0400		; enter tube environment


;*************************************************************************
;*                                                                       *
;*       OSRDRM entry point                                              *
;*                                                                       *
;*       get byte from PHROM or page ROM                                 *
;*       Y= rom number, address is in &F6/7                              *
;*************************************************************************

		ldx	$F4		; get current ROM number into X
		sty	$F4		; store new number in &F4
		sty	$FE30		; switch in ROM
		ldy	#$00		; get current PHROM address
		lda	($F6),Y		; and get byte

;******** Set up Sideways ROM latch and RAM copy *************************
		; on entry X=ROM number

		stx	$F4		; RAM copy of rom latch
		stx	$FE30		; write to rom latch
		rts			; and return


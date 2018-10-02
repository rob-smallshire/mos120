;**************** BUFFER ADDRESS HI LOOK UP TABLE ************************
.org		$e435

_LE435:		.byte	$03		; keyboard
		.byte	$0A		; rs423 input
		.byte	$08		; rs423 output
		.byte	$07		; printer
		.byte	$07		; sound 0
		.byte	$07		; sound 1
		.byte	$07		; sound 2
		.byte	$07		; sound 3
		.byte	$09		; speech

;**************** BUFFER ADDRESS LO LOOK UP TABLE ************************
_LE43E:		.byte	$00
		.byte	$00
		.byte	$C0
		.byte	$C0
		.byte	$50
		.byte	$60
		.byte	$70
		.byte	$80
		.byte	$00

;**************** BUFFER START ADDRESS OFFSET ****************************
_LE447:		.byte	$E0
		.byte	$00
		.byte	$40
		.byte	$C0
		.byte	$F0
		.byte	$F0
		.byte	$F0
		.byte	$F0
		.byte	$C0

;*******: get nominal buffer addresses in &FA/B **************************

		;  ON ENTRY X=buffer number
		; Buffer number  Address         Flag    Out pointer     In pointer
		; 0=Keyboard     3E0-3FF         2CF     2D8             2E1
		; 1=RS423 Input  A00-AFF         2D0     2D9             2E2
		; 2=RS423 output 900-9BF         2D1     2DA             2E3
		; 3=printer      880-8BF         2D2     2DB             2E4
		; 4=sound0       840-84F         2D3     2DC             2E5
		; 5=sound1       850-85F         2D4     2DD             2E6
		; 6=sound2       860-86F         2D5     2DE             2E7
		; 7=sound3       870-87F         2D6     2DF             2E8
		; 8=speech       8C0-8FF         2D7     2E0             2E9

_LE450:		lda	_LE43E,X		; get buffer base address lo
		sta	$FA		; store it
		lda	_LE435,X		; get buffer base address hi
		sta	$FB		; store it
		rts			; exit


;*************************************************************************
;*                                                                       *
;*       OSBYTE 152 Examine Buffer status                                *
;*                                                                       *
;*************************************************************************
;on entry X = buffer number
;on exit FA/B points to buffer start  Y is offset to next character
;if buffer is empty C=1, Y is preserved else C=0

_LE45B:		bit	_BD9B7		; set V and
		bvs	_BE461		; jump to E461


;*************************************************************************
;*                                                                       *
;*       OSBYTE 145 Get byte from Buffer                                 *
;*                                                                       *
;*************************************************************************
;on entry X = buffer number
; ON EXIT Y is character extracted
;if buffer is empty C=1, else C=0

_LE460:		clv			; clear V

_BE461:		jmp	($022c)		; Jump via REMV


;*************************************************************************
;*                                                                       *
;*       REMV buffer remove vector default entry point                   *
;*                                                                       *
;*************************************************************************
;on entry X = buffer number
;on exit if buffer is empty C=1, Y is preserved else C=0

_LE464:		php			; push flags
		sei			; bar interrupts
		lda	$02d8,X		; get output pointer for buffer X
		cmp	$02e1,X		; compare to input pointer
		beq	_BE4E0		; if equal buffer is empty so E4E0 to exit
		tay			; else A=Y
		jsr	_LE450		; and get buffer pointer into FA/B
		lda	($FA),Y		; read byte from buffer
		bvs	_BE491		; if V is set (on input) exit with CARRY clear
					; Osbyte 152 has been done
		pha			; else must be osbyte 145 so save byte
		iny			; increment Y
		tya			; A=Y
		bne	_BE47E		; if end of buffer not reached <>0 E47E

		lda	_LE447,X		; get pointer start from offset table

_BE47E:		sta	$02d8,X		; set buffer output pointer
		cpx	#$02		; if buffer is input (0 or 1)
		bcc	_BE48F		; then E48F

		cmp	$02e1,X		; else for output buffers compare with buffer start
		bne	_BE48F		; if not the same buffer is not empty so E48F

		ldy	#$00		; buffer is empty so Y=0
		jsr	_LE494		; and enter EVENT routine to signal EVENT 0 buffer
					; becoming empty

_BE48F:		pla			; get back byte from buffer
		tay			; put it in Y
_BE491:		plp			; get back flags
		clc			; clear carry to indicate success
		rts			; and exit


;**************************************************************************
;**************************************************************************
;**                                                                      **
;**      CAUSE AN EVENT                                                  **
;**                                                                      **
;**************************************************************************
;**************************************************************************
;on entry Y=event number
;A and X may be significant Y=A, A=event no. when event generated @E4A1
;on exit carry clear indicates action has been taken else carry set

_LE494:		php			; push flags
		sei			; bar interrupts
		pha			; push A
		sta	$FA		; &FA=A
		lda	$02bf,Y		; get enable event flag
		beq	_BE4DF		; if 0 event is not enabled so exit
		tya			; else A=Y
		ldy	$FA		; Y=A
		jsr	_LF0A5		; vector through &220
		pla			; get back A
		plp			; get back flags
		clc			; clear carry for success
		rts			; and exit

;********* check event 2 character entering buffer ***********************

_BE4A8:		tya			; A=Y
		ldy	#$02		; Y=2
		jsr	_LE494		; check event
		tay			; Y=A


;*************************************************************************
;*                                                                       *
;*       OSBYTE 138 Put byte into Buffer                                 *
;*                                                                       *
;*************************************************************************
;on entry X is buffer number, Y is character to be written

_BE4AF:		tya			; A=Y

_LE4B0:		jmp	($022a)		; jump to INSBV


;*************************************************************************
;*                                                                       *
;*       INSBV insert character in buffer vector default entry point     *
;*                                                                       *
;*************************************************************************
;on entry X is buffer number, A is character to be written

_LE4B3:		php			; save flags
		sei			; bar interrupts
		pha			; save A
		ldy	$02e1,X		; get buffer input pointer
		iny			; increment Y
		bne	_BE4BF		; if Y=0 then buffer is full else E4BF
		ldy	_LE447,X		; get default buffer start

_BE4BF:		tya			; put it in A
		cmp	$02d8,X		; compare it with input pointer
		beq	_BE4D4		; if equal buffer is full so E4D4
		ldy	$02e1,X		; else get buffer end in Y
		sta	$02e1,X		; and set it from A
		jsr	_LE450		; and point &FA/B at it
		pla			; get back byte
		sta	($FA),Y		; store it in buffer
		plp			; pull flags
		clc			; clear carry for success
		rts			; and exit

_BE4D4:		pla			; get back byte
		cpx	#$02		; if we are working on input buffer
		bcs	_BE4E0		; then E4E0

		ldy	#$01		; else Y=1
		jsr	_LE494		; to service input buffer full event
		pha			; push A

;***** return with carry set *********************************************

_BE4DF:		pla			; restore A

_BE4E0:		plp			; restore flags
		sec			; set carry
		rts			; and exit


;***************** CODE MODIFIER ROUTINE *********************************
;*                 CHECK FOR ALPHA CHARACTER                             *
;*************************************************************************
		; ENTRY  character in A
		; exit with carry set if non-Alpha character
_LE4E3:		pha			; Save A
		and	#$DF		; convert lower to upper case
		cmp	#$41		; is it 'A' or greater ??
		bcc	_BE4EE		; if not exit routine with carry set
		cmp	#$5B		; is it less than 'Z'
		bcc	_BE4EF		; if so exit with carry clear
_BE4EE:		sec			; else clear carry
_BE4EF:		pla			; get back original value of A
		rts			; and Return

;*******: INSERT byte in Keyboard buffer *********************************

_LE4F1:		ldx	#$00		; X=0 to indicate keyboard buffer

;*************************************************************************
;*                                                                       *
;*       OSBYTE 153 Put byte in input Buffer checking for ESCAPE         *
;*                                                                       *
;*************************************************************************
;on entry X = buffer number (either 0 or 1)
;X=1 is RS423 input
;X=0 is Keyboard
;Y is character to be written

_LE4F3:		txa			; A=buffer number
		and	$0245		; and with RS423 mode (0 treat as keyboard
					; 1 ignore Escapes no events no soft keys)
		bne	_BE4AF		; so if RS423 buffer AND RS423 in normal mode (1) E4AF

		tya			; else Y=A character to write
		eor	$026c		; compare with current escape ASCII code (0=match)
		ora	$0275		; or with current ESCAPE status (0=ESC, 1=ASCII)
		bne	_BE4A8		; if ASCII or no match E4A8 to enter byte in buffer
		lda	$0258		; else get ESCAPE/BREAK action byte
		ror			; Rotate to get ESCAPE bit into carry
		tya			; get character back in A
		bcs	_BE513		; and if escape disabled exit with carry clear
		ldy	#$06		; else signal EVENT 6 Escape pressed
		jsr	_LE494		; 
		bcc	_BE513		; if event handles ESCAPE then exit with carry clear
		jsr	_LE674		; else set ESCAPE flag
_BE513:		clc			; clear carry
		rts			; and exit

;******** get a byte from keyboard buffer and interpret as necessary *****
;on entry A=cursor editing status 1=return &87-&8B,
;2= use cursor keys as soft keys 11-15
;this area not reached if cursor editing is normal

_BE515:		ror			; get bit 1 into carry
		pla			; get back A
		bcs	_BE592		; if carry is set return
					; else cursor keys are 'soft'
_BE519:		tya			; A=Y get back original key code (&80-&FF)
		pha			; PUSH A
		lsr			; get high nybble into lo
		lsr			; 
		lsr			; 
		lsr			; A=8-&F
		eor	#$04		; and invert bit 2
					; &8 becomes &C
					; &9 becomes &D
					; &A becomes &E
					; &B becomes &F
					; &C becomes &8
					; &D becomes &9
					; &E becomes &A
					; &F becomes &B

		tay			; Y=A = 8-F
		lda	$0265,Y		; read 026D to 0274 code interpretation status
					; 0=ignore key, 1=expand as 'soft' key
					; 2-&FF add this to base for ASCII code
					; note that provision is made for keypad operation
					; as codes &C0-&FF cannot be generated from keyboard
					; but are recognised by OS
					; 
		cmp	#$01		; is it 01
		beq	_BE594		; if so expand as 'soft' key via E594
		pla			; else get back original byte
		bcc	_BE539		; if above CMP generated Carry then code 0 must have
					; been returned so E539 to ignore
		and	#$0F		; else add ASCII to BASE key number so clear hi nybble
		clc			; clear carry
		adc	$0265,Y		; add ASCII base
		clc			; clear carry
		rts			; and exit
					; 
;*********** ERROR MADE IN USING EDIT FACILITY ***************************

_BE534:		jsr	_LE86F		; produce bell
		pla			; get back A, buffer number
		tax			; X=buffer number

;********get byte from buffer ********************************************

_BE539:		jsr	_LE460		; get byte from buffer X
		bcs	_BE593		; if buffer empty E593 to exit
		pha			; else Push byte
		cpx	#$01		; and if RS423 input buffer is not the one
		bne	_BE549		; then E549

		jsr	_LE173		; else oswrch
		ldx	#$01		; X=1 (RS423 input buffer)
		sec			; set carry

_BE549:		pla			; get back original byte
		bcc	_BE551		; if carry clear (I.E not RS423 input) E551
		ldy	$0245		; else Y=RS423 mode (0 treat as keyboard )
		bne	_BE592		; if not 0 ignore escapes etc. goto E592

_BE551:		tay			; Y=A
		bpl	_BE592		; if code is less that &80 its simple so E592
		and	#$0F		; else clear high nybble
		cmp	#$0B		; if less than 11 then treat as special code
		bcc	_BE519		; or function key and goto E519
		adc	#$7B		; else add &7C (&7B +C) to convert codes B-F to 7-B
		pha			; Push A
		lda	$027d		; get cursor editing status
		bne	_BE515		; if not 0 (normal) E515
		lda	$027c		; else get character destination status

;Bit 0 enables  RS423 driver
;BIT 1 disables VDU driver
;Bit 2 disables printer driver
;BIT 3 enables  printer independent of CTRL B or CTRL C
;Bit 4 disables spooled output
;BIT 5 not used
;Bit 6 disables printer driver unless VDU 1 precedes character
;BIT 7 not used

		ror			; get bit 1 into carry
		ror			; 
		pla			; 
		bcs	_BE539		; if carry is set E539 screen disabled
		cmp	#$87		; else is it COPY key
		beq	_BE5A6		; if so E5A6

		tay			; else Y=A
		txa			; A=X
		pha			; Push X
		tya			; get back Y
		jsr	_LD8CE		; execute edit action

		pla			; restore X
		tax			; 
_LE577:		bit	$025f		; check econet RDCH flag
		bpl	_BE581		; if not set goto E581
		lda	#$06		; else Econet function 6
_LE57E:		jmp	($0224)		; to the Econet vector

;********* get byte from key string **************************************
;on entry 0268 contains key length
;and 02C9 key string pointer to next byte

_BE581:		lda	$0268		; get length of keystring
		beq	_BE539		; if 0 E539 get a character from the buffer
		ldy	$02c9		; get soft key expansion pointer
		lda	$0b01,Y		; get character from string
		inc	$02c9		; increment pointer
		dec	$0268		; decrement length

;************** exit with carry clear ************************************

_BE592:		clc			; 
_BE593:		rts			; exit
					; 
;*** expand soft key strings *********************************************
; ### Y=pointer to sring number

_BE594:		pla			; restore original code
		and	#$0F		; blank hi nybble to get key string number
		tay			; Y=A
		jsr	_LE3A8		; get string length in A
		sta	$0268		; and store it
		lda	$0b00,Y		; get start point
		sta	$02c9		; and store it
		bne	_LE577		; if not 0 then get byte via E577 and exit

;*********** deal with COPY key ******************************************

_BE5A6:		txa			; A=X
		pha			; Push A
		jsr	_LD905		; read a character from the screen
		tay			; Y=A
		beq	_BE534		; if not valid A=0 so BEEP
		pla			; else restore X
		tax			; 
		tya			; and Y
		clc			; clear carry
		rts			; and exit



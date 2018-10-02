;*************************************************************************
;*                                                                       *
;*       OSFIND  ENTRY                                                   *
;*       file handling                                                   *
;*                                                                       *
;*************************************************************************
;on entry A determines Action Y may contain file handle or
;X/Y point to filename terminated by &0D in memory
;A=0	closes file in channel Y if Y=0 closes all files
;A=&40  open a file for input  (reading) X/Y points to filename
;A=&80  open a file for output (writing) X/Y points to filename
;A=&C0  open a file for input and output (random access)
;ON EXIT Y=0 if no file found else Y=channel number in use for file

		; save A X and Y
.org		$f3ca

		sta	$BC		; file status or temporary store
		txa			; A=X
		pha			; save X on stack
		tya			; A=Y
		pha			; save Y on stack
		lda	$BC		; file status or temporary store
		bne	$F3F2		; if A is non zero open a file via F3F2

;************ close a file ***********************************************

		tya			; A=Y
		bne	$F3E3		; if A<> 0 close specified file else close them all
		jsr	$E275		; close spool/exec files via OSBYTE 77
		jsr	$F478		; tidy up
		lsr	$E2		; CFS status byte is shifted left and right to zero
		asl	$E2		; bit 0
		bcc	$F3EF		; and if carry clear no input file was open so F3EF

		lsr			; A contains file handle so shift bit 0 into carry
		bcs	$F3DD		; if carry set close input file
		lsr			; else shift bit 1 into carry
		bcs	$F3EC		; if carry set close output file
		jmp	$FBB1		; else report 'Channel Error' as CFS can only support
					; 1 input and 1 output file

		jsr	$F478		; tidy up
		jmp	$F471		; and exit

;************ OPEN A FILE ************************************************

		jsr	$F25A		; get filename from BUFFER
		bit	$BC		; file status or temporary store
		bvc	$F436		; check A at input if bit 6 not set its an output file

;********* Input files +**************************************************

		lda	#$00		; else its an input file
		sta	$039E		; BGET buffer offset for next byte
		sta	$03DD		; Expected BGET file block number lo
		sta	$03DE		; expected BGET file block number hi
		lda	#$3E		; A=&3E
		jsr	$F33D		; CFS status =CFS status AND A
		jsr	$FB1A		; claim serial system and set OPTions
		php			; save flags on stack
		jsr	$F631		; search for file
		jsr	$F6B4		; check protection bit of block status and respond
		plp			; get back flags
		ldx	#$FF		; X=&FF increment to 0 on next instruction

		inx			; X=X+1
		lda	$03B2,X		; get file name and
		sta	$03A7,X		; store as BGET filename
		bne	$F416		; until end of filename

		lda	#$01		; A=1 to show file open
		jsr	$F344		; set status bits from A
		lda	$02EA		; CFS currently resident file block length lo
		ora	$02EB		; CFS currently resident file block length hi
		bne	$F42F		; if block length is 0
		jsr	$F342		; set CFS status bit 3 (EOF reached)
					; else
		lda	#$01		; A=1
		ora	$0247		; filing system flag 0=CFS 2=RFS
		bne	$F46F		; and exit after restoring registers

;******************* open an output file***********************************

		txa			; A=X

		bne	$F43C		; if X=0 then zero length filename so
		jmp	$EA8F		; Bad String error

		ldx	#$FF		; X=&FF
		inx			; X=X+1
					; copy sought filename to header block
		lda	$03D2,X		; sought filename
		sta	$0380,X		; BPUT file header block
		bne	$F43E		; until A=0 end of filename
		lda	#$FF		; A=&FF
		ldx	#$08		; X=8

		sta	$038B,X		; set 38C/93 to &FF
		dex			; X=X-1
		bne	$F44B		; 

		txa			; A=X=0
		ldx	#$14		; X=14
		sta	$0380,X		; BPUT file header block
		inx			; X=X+1
		cpx	#$1E		; this zeros 394/D
		bne	$F454		; 

		rol	$0397		; 
		jsr	$FB27		; Set cassette optionsinto (BB),set C7=6
					; claim serial system for cassette
		jsr	$F934		; prompt to start recording
		jsr	$FAF2		; enable second processor and reset serial system
		lda	#$02		; A=2
		jsr	$F344		; set status bits from A
		lda	#$02		; A=2
		sta	$BC		; file status or temporary store
		pla			; get back A
		tay			; Y=A
		pla			; get back A
		tax			; X=A
		lda	$BC		; file status or temporary store
		rts			; return
					; 

		lda	#$02		; A=2 clearing all but bit 1 of status byte
		and	$E2		; CFS status byte, with output file open
		beq	$F477		; if file not open then exit
		lda	#$00		; else A=0
		sta	$0397		; setting block length to current value of BPUT offset
		lda	#$80		; A=&80
		ldx	$039D		; get BPUT buffer ofset
		stx	$0396		; setting block length to current value of BPUT offset
		sta	$0398		; mark current block as last
		jsr	$F496		; save block to tape
		lda	#$FD		; A=&FD
		jmp	$F33D		; CFS status =CFS status AND A

;*********** SAVE BLOCK TO TAPE ********************************************

		jsr	$FB1A		; claim serial system and set OPTions

		ldx	#$11		; X=11
		lda	$038C,X		; copy header block from 38C-39D
		sta	$03BE,X		; to 3BE/DF
		dex			; X=X-1
		bpl	$F49B		; 
					; X=&FF
		stx	$B2		; current load address high word
		stx	$B3		; current load address high word
		inx			; X=X+1, (X=0)
		stx	$B0		; current load address lo byte set to &00
		lda	#$09		; A=9 to set current load address at &900
		sta	$B1		; current load address
		ldx	#$7F		; X=&7F
		jsr	$FB81		; copy from 301/C+X to 3D2/C sought filename
		sta	$03DF		; copy of last read block flag
		jsr	$FB8E		; switch Motor On
		jsr	$FBE2		; set up CFS for write operation
		jsr	$F7EC		; write block to Tape
		inc	$0394		; block number lo
		bne	$F4C8		; 
		inc	$0395		; block number hi
		rts			; return


;*************************************************************************
;*                                                                       *
;*                                                                       *
;*       OSBGET  get a byte from a file                                  *
;*                                                                       *
;*                                                                       *
;*************************************************************************
		; on ENTRY       Y contains channel number
		; on EXIT        X and Y are preserved C=0 indicates valid character
		;            A contains character (or error) A=&FE End Of File

		; push X and Y
		txa			; A=X
		pha			; save A on stack
		tya			; A=Y
		pha			; save A on stack
		lda	#$01		; A=1
		jsr	$FB9C		; check conditions for OSBGET are OK
		lda	$E2		; CFS status byte
		asl			; shift bit 7 into carry (EOF warning given)
		bcs	$F523		; if carry set F523
		asl			; shift bit 6 into carry
		bcc	$F4E3		; if clear EOF not reached F4E3
		lda	#$80		; else A=&80 setting bit 7 of status byte EOF warning
		jsr	$F344		; set status bits from A
		lda	#$FE		; A=&FE
		bcs	$F51B		; if carry set F51B

		ldx	$039E		; BGET buffer offset for next byte
		inx			; X=X+1
		cpx	$02EA		; CFS currently resident file block length lo
		bne	$F516		; read a byte
					; else
		bit	$02EC		; block flag of currently resident block
		bmi	$F513		; if bit 7=1 this is the last block so F513 else
		lda	$02ED		; last character of currently resident block
		pha			; save A on stack
		jsr	$FB1A		; claim serial system and set OPTions
		php			; save flags on stack
		jsr	$F6AC		; read in a new block
		plp			; get back flags
		pla			; get back A
		sta	$BC		; file status or temporary store
		clc			; clear carry flag
		bit	$02EC		; block flag of currently resident block
		bpl	$F51D		; if not last block (bit 7=0)
		lda	$02EA		; CFS currently resident file block length lo
		ora	$02EB		; CFS currently resident file block length hi
		bne	$F51D		; if block size not 0 F51D else
		jsr	$F342		; set CFS status bit 6 (EOF reached)
		bne	$F51D		; goto F51D

		jsr	$F342		; set CFS status bit 6 (EOF reached)
		dex			; X=X-1
		clc			; clear carry flag
		lda	$0A00,X		; read byte from cassette buffer

		sta	$BC		; file status or temporary store
		inc	$039E		; BGET buffer offset for next byte
		jmp	$F471		; exit via F471

		brk			; 
		.byte	$DF		; error number
		.byte	"EOF"		; 
		brk			; 


;*************************************************************************
;*                                                                       *
;*                                                                       *
;*       OSBPUT  WRITE A BYTE TO FILE                                    *
;*                                                                       *
;*                                                                       *
;*************************************************************************
;ON ENTRY  Y contains channel number A contains byte to be written

		sta	$C4		; store A in temorary store
		txa			; and stack X and Y
		pha			; save  on stack
		tya			; A=Y
		pha			; save on stack

		lda	#$02		; A=2
		jsr	$FB9C		; check conditions necessary for OSBPUT are OK
		ldx	$039D		; BPUT buffer offset for next byte
		lda	$C4		; get back original value of A
		sta	$0900,X		; Cassette buffer
		inx			; X=X+1
		bne	$F545		; if not 0 F545, otherwise buffer is full so
		jsr	$F496		; save block to tape
		jsr	$FAF2		; enable second processor and reset serial system
		inc	$039D		; BPUT buffer offset for next byte
		lda	$C4		; get back A
		jmp	$F46F		; and exit


;*************************************************************************
;*                                                                       *
;*                                                                       *
;*       OSBYTE 139      Select file options                             *
;*                                                                       *
;*                                                                       *
;*************************************************************************
;ON ENTRY  Y contains option value  X contains option No. see *OPT X,Y
;this applies largely to CFS LOAD SAVE CAT and RUN
;X=1	is message switch
;   	Y=0 no messages
;   	Y=1 short messages
;   	Y=2 gives detailed information on load and execution addresses

;X=2	is error handling
;   	Y=0 ignore errors
;   	Y=1 prompt for a retry
;   	Y=2 abort operation

;X=3	is interblock gap for BPUT# and PRINT#
;   	Y=0-127 set gap in 1/10ths Second
;   	Y > 127 use default values

		txa			; A=X
		beq	$F57E		; if A=0 F57E
		cpx	#$03		; if X=3
		beq	$F573		; F573 to set interblock gap
		cpy	#$03		; else if Y>2 then BAD COMMAND error
		bcs	$F55E		; 
		dex			; X=X-1
		beq	$F561		; i.e. if X=1 F561 message control
		dex			; X=X-1
		beq	$F568		; i.e. if X=2 F568 error response
		jmp	$E310		; else E310 to issue Bad Command error

;*********** message control *********************************************

		lda	#$33		; to set lower two bits of each nybble as mask
		iny			; Y=Y+1
		iny			; Y=Y+1
		iny			; Y=Y+1
		bne	$F56A		; goto F56A

;*********** error response *********************************************

		lda	#$CC		; setting top two bits of each nybble as mask
		iny			; Y=Y+1
		and	$E3		; clear lower two bits of each nybble
		ora	$F581,Y		; or with table value
		sta	$E3		; store it in &E3
		rts			; return

		; setting of &E3
		; 
		; lower nybble sets LOAD options
		; upper sets SAVE options

		; 0000   Ignore errors,          no messages
		; 0001   Abort if error,         no messages
		; 0010   Retry after error,      no messages
		; 1000   Ignore error            short messages
		; 1001   Abort if error          short messages
		; 1010   Retry after error       short messages
		; 1100   Ignore error            long messages
		; 1101   Abort if error          long messages
		; 1110   Retry after error       long messages

;***********set interblock gap *******************************************

		tya			; A=Y
		bmi	$F578		; if Y>127 use default values
		bne	$F57A		; if Y<>0 skip next instruction
		lda	#$19		; else A=&19

		sta	$03D1		; sequential block gap
		rts			; return
					; 
		tay			; Y=A
		beq	$F56D		; jump to F56D

;*********** DEFAULT OPT VALUES TABLE ************************************

		.byte	$A1		; %1010 0001
		.byte	$00		; %0000 0000
		.byte	$22		; %0010 0010
		.byte	$11		; %0001 0001
		.byte	$00		; %0000 0000
		.byte	$88		; %1000 1000
		.byte	$CC		; %1100 1100

		dec	$C0		; filing system buffer flag
		lda	$0247		; filing system flag 0=CFS 2=RFS
		beq	$F596		; if CFS F596

		jsr	$EE51		; read RFS data rom or Phrom
		tay			; Y=A
		clc			; clear carry flag
		bcc	$F5B0		; jump to F5B0

		lda	$FE08		; ACIA status register
		pha			; save A on stack
		and	#$02		; clear all but bits 0,1 A=(0-3)
		beq	$F5A9		; if 0 F5A9 transmit data register full or RDR empty
		ldy	$CA		; 
		beq	$F5A9		; 
		pla			; get back A
		lda	$BD		; character temporary storage
		sta	$FE09		; ACIA transmit data register
		rts			; return
					; 
		ldy	$FE09		; read ACIA recieve data register
		pla			; get back A
		lsr			; bit 2 to carry (data carrier detect)
		lsr			; 
		lsr			; 

		ldx	$C2		; progress flag
		beq	$F61D		; if &C2=0 exit
		dex			; X=X-1
		bne	$F5BD		; if &C2>1 then F5BD
		bcc	$F61D		; else if carrier tone from cassette detected exit

		ldy	#$02		; Y=2

		bne	$F61B		; 
		dex			; X=X-1
		bne	$F5D3		; if &C2>2
		bcs	$F61D		; if carrier tone from cassette not detected  exit
		tya			; A=Y
		jsr	$FB78		; set (BE/C0) to 0
		ldy	#$03		; Y=3
		cmp	#$2A		; is A= to synchronising byte &2A?
		beq	$F61B		; if so F61B
		jsr	$FB50		; control cassette system
		ldy	#$01		; Y=1
		bne	$F61B		; goto F61B
		dex			; X=X-1
		bne	$F5E2		; if &C2>3
		bcs	$F5DC		; 
		sty	$BD		; get character read into Y
		beq	$F61D		; if 0 exit via F61D
		lda	#$80		; else A=&80
		sta	$C0		; filing system buffer flag
		bne	$F61D		; and exit

		dex			; X=X-1
		bne	$F60E		; if &C2>4 F60E
		bcs	$F616		; if carry set F616
		tya			; A=Y
		jsr	$F7B0		; perform CRC
		ldy	$BC		; file status or temporary store
		inc	$BC		; file status or temporary store
		bit	$BD		; if bit 7 set this is the last byte read
		bmi	$F600		; so F600
		jsr	$FBD3		; check if second processor file test tube prescence
		beq	$F5FD		; if return with A=0 F5FD
		stx	$FEE5		; Tube FIFO3
		bne	$F600		; 

		txa			; A=X restore value
		sta	($B0),Y		; store to current load address
		iny			; Y=Y+1
		cpy	$03C8		; block length
		bne	$F61D		; exit
		lda	#$01		; A=1
		sta	$BC		; file status or temporary store
		ldy	#$05		; Y=5
		bne	$F61B		; exit

		tya			; A=Y
		jsr	$F7B0		; perform CRC
		dec	$BC		; file status or temporary store
		bpl	$F61D		; exit

		jsr	$FB46		; reset ACIA
		ldy	#$00		; Y=0
		sty	$C2		; progress flag
		rts			; return


;*************************************************************************
;*                                                                       *
;*       FSCV &01 - check for end of file                                *
;*                                                                       *
;*************************************************************************
		; 
		pha			; save A on stack
		tya			; A=Y
		pha			; save Y on stack
		txa			; A=X to put X into Y
		tay			; Y=A
		lda	#$03		; A=3
		jsr	$FB9C		; confirm file is open
		lda	$E2		; CFS status byte
		and	#$40		; 
		tax			; X=A
		pla			; get back A
		tay			; Y=A
		pla			; get back A
		rts			; return
					; 
		lda	#$00		; A=0
		sta	$B4		; current block no. lo
		sta	$B5		; current block no. hi
		lda	$B4		; current block no. lo
		pha			; save A on stack
		sta	$B6		; next block no. lo
		lda	$B5		; current block no. hi
		pha			; save A on stack
		sta	$B7		; next block no. hi
		jsr	$FA46		; print message following call

		.byte	"Searching"		; 
		.byte	$0D		; newline
		brk			; 

		lda	#$FF		; A=&FF
		jsr	$F348		; read data from CFS/RFS
		pla			; get back A
		sta	$B5		; current block no. hi
		pla			; get back A
		sta	$B4		; current block no. lo
		lda	$B6		; next block no. lo
		ora	$B7		; next block no. hi
		bne	$F66D		; 
		sta	$B4		; current block no. lo
		sta	$B5		; current block no. hi
		lda	$C1		; checksum result
		bne	$F66D		; 
		ldx	#$B1		; current load address
		jsr	$FB81		; copy from 301/C+X to 3D2/C sought filename
		lda	$0247		; filing system flag 0=CFS 2=RFS
		beq	$F685		; if cassette F685
		bvs	$F685		; 

		brk			; 
		.byte	$D6		; Error number
		.byte	"File not found"
		brk			; 

		ldy	#$FF		; Y=&FF
		sty	$03DF		; copy of last read block flag
		rts			; return



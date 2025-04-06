; -------------------------------------------------------------------
; Task description: 
;   Mirroring of an ASCII string in the internal memory (the first character 
;   replaces the last and so on, the terminating 0 is not affected).
;   Input: Start address of the string (pointer)
;   Output: Mirrored string at the same place
; -------------------------------------------------------------------


; Definitions
; -------------------------------------------------------------------

; Address symbols for creating pointers

STR_ADDR_IRAM  EQU 0x40

; Test data for input parameters
; (Try also other values while testing your code.)

; Store the string in the code memory as an array

ORG 0x0070 ; Move if more code memory is required for the program code
STR_ADDR_CODE:
DB "Hello !dlrow"
DB 0

; Interrupt jump table
ORG 0x0000;
    SJMP  MAIN                  ; Reset vector



; Beginning of the user program, move it freely if needed
ORG 0x0010

; -------------------------------------------------------------------
; MAIN program
; -------------------------------------------------------------------
; Purpose: Prepare the inputs and call the subroutines
; -------------------------------------------------------------------

MAIN:

    ; Prepare input parameters for the subroutine
	MOV R5,#HIGH(STR_ADDR_CODE)
	MOV R6,#LOW(STR_ADDR_CODE)
	MOV R7,#STR_ADDR_IRAM
	CALL STR_CODE2IRAM ; Copy the string from code memory to internal memory
	
	MOV R7, #STR_ADDR_IRAM
; Infinite loop: Call the subroutine repeatedly

LOOP:

    CALL STR_MIRROR ; Call string mirror subroutine

    SJMP  LOOP




; ===================================================================           
;                           SUBROUTINE(S)
; ===================================================================           


; -------------------------------------------------------------------
; STR_CODE2IRAM
; -------------------------------------------------------------------
; Purpose: Initializing DPTR, R0, R1
; -------------------------------------------------------------------
; INPUT(S):
;   R7 - Base address of string in the internal memory
; OUTPUT(S): 
;   -
; MODIFIES:
;   DPTR
;   R0
;   R1
; -------------------------------------------------------------------

STR_CODE2IRAM:

    MOV DPTR,#STR_ADDR_CODE ; We put the pointer at the starting position of the string
    MOV AR0, AR7 ; As we cant use @R7 we transfer the base address to R0
    MOV AR1, AR7 ; As we cant use @R7 we transfer the base address to R1
    JMP TRANSFER_IRAM
	RET

; -------------------------------------------------------------------
; TRANSFER_IRAM
; -------------------------------------------------------------------
; Purpose: Copy the string from code memory to internal memory
; -------------------------------------------------------------------
; INPUT(S):
;   DPTR - Base address of string in the internal memory after moving from R7
; OUTPUT(S): 
;   -
; MODIFIES:
;   A
;   R0
;   DPTR
; -------------------------------------------------------------------

TRANSFER_IRAM:

   CLR A
   MOVC A,@A+DPTR ; Transfering from code to internal memory
   JZ LOOP ; If we came to the end of the string then go to LOOP which calls STR_MIRROR
   MOV @R0,A ; Writing of the current character to the position R0
   INC R0 ; Moving the current position by 1
   INC DPTR ; Moving the pointer to the character from one to another
   SJMP TRANSFER_IRAM

; -------------------------------------------------------------------
; STR_MIRROR
; -------------------------------------------------------------------
; Purpose: Mirror the string in place
; -------------------------------------------------------------------
; INPUT(S):
;   R0 - Position of the right end of the string including NULL character
;   R1 - Position of the left end of the string
; OUTPUT(S): 
;   -
; MODIFIES:
;   R0
;   A
;   R1
;	PSW
; -------------------------------------------------------------------

STR_MIRROR:

	DEC R0 ; Excluding NULL character from the string
	MOV A, R1 ;  \
	SUBB A, R0 ;  -> Checking if we got to the middle of the string (odd strlen case)
	JZ endPROG ; /
	MOV A, @R0 ; \
	XCH A, @R1 ;  -> Changing the letters in position R1 and R0
	MOV @R0, A ; /
	INC R1 ; Increasing the left end of the string
	MOV A, R1 ;  \
	SUBB A, R0 ;  -> Checking if we got to the middle of the string (even strlen case)
	JZ endPROG ; /
  	JMP LOOP ; Repeating until we get to the middle of the string (mirror every character)
	RET

endPROG:
    jmp $

; End of the source file
END

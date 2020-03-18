TITLE Low Level I/O Procedures     (lowlevelio.asm)

; Author: Nate Kimball
; Last Modified: 03/13/20
; OSU email address: kimbalna@oregonstate.edu
; Course number/section: CS271-400
; Project Number: 6                     Due Date: 03/15/20
; Description: A program that prompts a user for 10 valid signed integers and, upon validation, 
;	       displays the numbers, their sum, and their average. The program uses "the hard way"
;	       to store and load string bytes. Rather than using WriteInt/WriteDec, the program
;              converts the user's input strings to ASCII integers to determine if what is entered
;              is valid. It then converts the numbers back to strings for output.

INCLUDE Irvine32.inc

MAXSIZE = 80							; The maximum size for an incoming string integer.
INTCOUNT = 10							; The number of integers the user will enter. 

;displayArr: Macro that loops through an array offset and prints each string within the array.
;parameters: @arr, LENGTHOF arr, arrSize

displayArr  MACRO	arr, arrLen, arrSize
	local	LOOPPRINTARR
	push	edi
	push	edx
	push	ecx
	mov	edi, arr
	mov	ecx, arrSize
LOOPPRINTARR:							; Loop to print incoming array.
	mov	edx, edi
	call	WriteString
	call	CrLf
	add	edi, arrLen
	loop	LOOPPRINTARR
	call	CrLf
	pop	ecx
	pop	edx
	pop	edi
ENDM

;displayString: Macro that displays a string to the output screen.
;parameters: @string

displayString	MACRO	string
	push	edx				
	mov	edx, string
	call	WriteString
	pop	edx				
ENDM

;displayLineNum: Macro that displays the line count to the output screen.
;parameters: Unsigned int representing the line count, a single space

displayLineNum	MACRO	lineNum, space
	local	EQUALTOTEN
	push	eax
	push	ebx
	mov	ebx, lineNum
	inc	ebx
	cmp	ebx, 10
	je	EQUALTOTEN					; To right-align, add a space if line count < 10.
	displayString space
EQUALTOTEN:
	mov	eax, ebx
	call	WriteDec
	pop	ebx
	pop	eax
ENDM

;getString: Macro that prompts a user for a string and stores it to a location in memory.
;parameters: @prompt, @inString, maxSize

getString		MACRO	prompt, lineCount, inString, maxSize, space
	push	edx
	push	ecx
	displayLineNum	lineCount, space
	displayString	prompt	
	mov	edx, inString
	mov	ecx, maxSize
	call	ReadString
	pop	ecx
	pop	edx
ENDM

;getString: Macro that places the digit length of a number into ECX.
;parameters: @number
;preconditions: previous ECX value should be stored first before calling. 

getNumLength	MACRO	number
	local	LOOPNUMLENGTH
	push	edx
	push	ebx
	push	eax

	; Divide number by 10 until quotient is 0, adding 1 to ECX each time.
	mov	ebx, number
	mov	ecx, 0

	; If the number is negative, use its two's complement for length check.
	test	ebx, ebx
	jns	LOOPNUMLENGTH
	neg	ebx

LOOPNUMLENGTH:
	inc	ecx
	mov	eax, ebx
	mov	ebx, 10
	mov	edx, 0
	idiv	ebx
	mov	ebx, eax
	cmp	ebx, 0
	jne	LOOPNUMLENGTH


	pop	eax
	pop	ebx
	pop	edx
ENDM

.data

prompt		BYTE	". Enter a signed integer: ", 0
promptbad	BYTE	"Bruh, that's not right. What are you even doing?", 0
promptsub	BYTE	"   > Subtotal: ", 0
endprompt1	BYTE	"Here are the numbers you entered: ", 0
endprompt2	BYTE	"And here is the sum of those numbers: ", 0
endprompt3	BYTE	"Aaaaaaaaaaand their rounded average: ", 0
space		BYTE	" ", 0
separator	BYTE	", ", 0
userString	BYTE	MAXSIZE+1	DUP(?)	; The string entered in by the user.
outputStr	BYTE	MAXSIZE+1	DUP(?)	; A string memory location to hold a converted number.
userNums	SDWORD	10		DUP(?)  ; An array of the numeric representations of each string.
userSum		SDWORD	0			; The sum of all the user's input.
average		SDWORD	0			; The average of all valid user input, hard rounded.
lineCount	DWORD	0			; The current line count. 
welcArrSize	DWORD	16			; The number of lines in the welcome array.
instArrSize	DWORD	7			; The number of lines in the instruction array.
gbyeArrSize	DWORD	20			; The number of lines in the goodbye array.

welcArr		BYTE	"888                              888                               888 ", 0                    
       		BYTE	"888  e88~-_  Y88b    e    /      888  e88~~8e  Y88b    /  e88~~8e  888 ", 0                   
       		BYTE	"888 d888   i  Y88b  d8b  /  ____ 888 d888  88b  Y88b  /  d888  88b 888 ", 0                    
       		BYTE	"888 8888   |   Y888/Y88b/        888 8888__888   Y88b/   8888__888 888 ", 0                     
       		BYTE	"888 Y888   '    Y8/  Y8/         888 Y888    ,    Y8/    Y888    , 888 ", 0                     
       		BYTE	"888  '88_-~      Y    Y          888  '88___/      Y      '88___/  888 ", 0
       		BYTE	"        ____  ______    ___                      __                    ", 0
       		BYTE	"       /  _/_/_/ __ \  / _ \_______  _______ ___/ /_ _________ ___     ", 0
       		BYTE	"      _/ /_/_// /_/ / / ___/ __/ _ \/ __/ -_) _  / // / __/ -_|_-<     ", 0
       		BYTE	"     /___/_/  \____/ /_/  /_/  \___/\__/\__/\_,_/\_,_/_/  \__/___/     ", 0
       		BYTE	"                                                                       ", 0
       		BYTE	"        B   Y      N   A   T   E      K   I   M   B   A   L   L        ", 0
       		BYTE	"        ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___        ", 0
       		BYTE	"        \\/ \\/ \\/ \\/ \\/ \\/ \\/ \\/ \\/ \\/ \\/ \\/ \\/ \\/        ", 0
		BYTE	"																		", 0
		BYTE	"*EC: Valid user input is numbered and subtotal is displayed.           ", 0
 
instArr		BYTE    "Alright, we made it all the way to Project 6! To celebrate, why don't  ", 0
		BYTE	"you throw down 10 signed integers for me? I'll be validating them so no", 0
		BYTE	"shenanigans. Also, make them small enough to fit in a 32-bit register  ", 0
		BYTE	"or your computer will probably explode.                                ", 0
		BYTE	"                                                                       ", 0
		BYTE	"Once you do all that, I'll read out what you entered and display the   ", 0
		BYTE	"sum and average for the numbers.                                       ", 0

goodbyeArr	BYTE	"      .--.___.----.___.--._                                            ", 0
		BYTE	"     /|  |   |    |   |  | `--.                                        ", 0
		BYTE	"    /                          `.                                      ", 0
		BYTE	"   |       |        |           |                                      ", 0 
		BYTE	"   |       |        |      |     |    THANK                            ", 0
		BYTE	"   |  `    |  `     |    ` |     |    YOU                              ", 0 
		BYTE	"   |    `  |      ` |      |   ` |    FOR                              ", 0 
		BYTE	"  '|  `    | ` ` `  |  ` ` |  `  |    A                                ", 0
		BYTE	"  ||`   `  |     `  |   `  |`   `|    GREAT                            ", 0 
		BYTE	"  ||  `    |  `     | `    |  `  |    CLASS!                           ", 0
		BYTE	"  ||    `  |   ` `  |    ` | `  `|                                     ", 0
		BYTE	"  || `     | `      | ` `  |  `  |    THIS                             ", 0
		BYTE	"  ||  ___  |  ____  |  __  |  _  |    WAS                              ", 0
		BYTE	"  | \_____/ \______/ \____/ \___/     FUN!                             ", 0 
		BYTE	"  |     `----._                                                        ", 0
		BYTE	"  |    /       \                                                       ", 0          
		BYTE	"  |         .--.\                                                      ", 0
		BYTE	"  |        '    \                                                      ", 0
		BYTE	"  `.      |  _.-'                                                      ", 0
		BYTE	"     `.|__.-'                                                          ", 0
.code

main PROC
	
	; Print the welcome string array.
	push	OFFSET welcArr
	push	LENGTHOF welcArr
	push	welcArrSize
	call	printArr

	; Print the instruction string array.
	push	OFFSET instArr
	push	LENGTHOF instArr
	push	instArrSize
	call	printArr

	; Set up to read values from user. readVal should only return when valid input is entered.
	mov	ecx, INTCOUNT
	mov	ebx, 0

; Loop the process of getting values from the user INTCOUNT times.
READUSERINPUT:

	; Get a valid values from the user by calling readVal each time through loop.
	push	OFFSET space
	push	OFFSET prompt
	push	OFFSET promptbad
	push	OFFSET promptsub
	push	OFFSET userString
	push	OFFSET userNums
	push	OFFSET userSum
	push	MAXSIZE
	push	ebx
	call	readVal

	; push @outputStr and @userSum to stack to call writeVal.
	; mov		outputStr, 0
	push	OFFSET outputStr
	push	OFFSET userSum
	call	writeVal

	; If this is the last time through the loop, don't display the subtotal.
	cmp	ecx, 1
	jle	ENDUSERINPUTLOOP

	; Otherwise, print the running total.
	displayString OFFSET promptsub	
	displayString OFFSET outputStr

	; Increase the line counter and loop
	inc	ebx
ENDUSERINPUTLOOP:
	call	CrLf
	loop	READUSERINPUT

	; Print out the array of signed integers collected from the user input.
	push	OFFSET endprompt1
	push	OFFSET separator
	push	OFFSET outputStr
	push	OFFSET userNums
	push	INTCOUNT
	call	printNumArr
	call	CrLf
	call	CrLf

	; Print out the sum, starting with the prompt.
	displayString OFFSET endprompt2

	; Convert the total sum to a string and print that value.
	push	OFFSET outputStr
	push	OFFSET userSum
	call	writeVal
	displayString OFFSET outputStr
	call	CrLf
	call	CrLf

	; Find the average of the numbers and print that value.
	; Start with the prompt.
	displayString OFFSET endprompt3

	; Solve for the average using the total sum and integer count.
	push	OFFSET average
	push	OFFSET userSum
	push	INTCOUNT
	call	getAverage
	
	; Convert average to string and display.
	push	OFFSET outputStr
	push	OFFSET average
	call	writeVal
	displayString OFFSET outputStr
	call	CrLf
	call	CrLf

	; Print the goodbye array.
	push	OFFSET goodbyeArr
	push	LENGTHOF goodbyeArr
	push	gbyeArrSize
	call	printArr

	exit

main ENDP

;readVal: Procedure that gets user input and converts the digit string to numeric while validating.
;parameters: (40) @space (36) @prompt (32) @promptbad (28) @promptsub (24) @userString 
;			 (20) @userNums (16) @userSum (12) MAXSIZE (8) lineCount
;returns: N/A (36 to fix stack)
;preconditions: N/A
;registers changed: N/A; All registers restored using pushad/popad

readVal PROC

	push	ebp
	mov	ebp, esp
	pushad

; Prompt user signed integer. 
READVALFROMUSER:

	getString	[ebp+36], [ebp+8], [ebp+24], [ebp+12], [ebp+40]

	mov	esi, [ebp+24]
	mov	edi, [ebp+20]
	mov	eax, [ebp+8]
	mov	ebx, 4
	mul	ebx
	add	edi, eax
	mov	ebx, -1						; EBX = 0, positive. EBX = 1, negative.
	mov	edx, 0						; Converted number

; Check each character in the user's input string, validate, and convert to number.
CHECKCHAR:
	lodsb
	cmp	ebx, 0
	jge	VALIDATECHAR

	; Check first character to see if it is a + or - sign. 
	inc	ebx
	cmp	al, 43
	je	CONTINUECHECK
	cmp	al, 45
	je	ISNEGATIVE
	jmp	VALIDATECHAR

; If number has a minus sign, set EBX to 1 to indicate the number should be negative.
ISNEGATIVE:
	inc	ebx

; If number had either a minus or plus sign, flag it as checked and move to the next char.
CONTINUECHECK:
	dec	ecx
	jmp	CHECKCHAR

; Check this char to see if it's a digit. If so, convert and add. Otherwise, reprompt.
VALIDATECHAR:
	cmp	al, 48
	jl	BADINPUT
	cmp	al, 57
	jg	BADINPUT

	; Continue conversion of this string to its numeric equivalent.
	sub	al, 48						; Convert character to numeric equivalent
	add	edx, eax					; Add its value to the running total
	lodsb							; Check the next char
	cmp	al, 0						; If it's null, we're done
	je	CHECKSIGNEDRANGE				
	mov	eax, 10						; Otherwise, multiply the total value by 10 and store
	mul	edx
	js	BADINPUT					; If this caused overflow, it's bad input. Reprompt user.
	mov	edx, eax
	mov	eax, 0						; Reset char pointer for next char in user string
	std	
	lodsb
	cld
	jmp	CHECKCHAR
; Once this number has been converted, check to make sure its signed range can fit in 32 bits.
CHECKSIGNEDRANGE:

	; If it's a negative number, get its two's complement and reject if its not signed
	cmp	ebx, 1
	jne	CHECKPOSNUMBER
	neg	edx
	jns	BADINPUT
	jmp	INPUTISVALID

	; If it's a positive number, reject if it is signed. 
CHECKPOSNUMBER:
	test	edx, edx
	js	BADINPUT

; If this number is valid, add it to the userSum and userNums array, then return.
INPUTISVALID:
	mov	[edi], edx
	mov	ebx, [ebp+16]
	add	edx, [ebx]
	mov	[ebx], edx

	popad
	pop	ebp
	ret	36

; If user entered something invalid, alert them and reprompt for integer.
BADINPUT:
	displayString	[ebp+32]
	call	CrLf
	jmp	READVALFROMUSER

readVal ENDP

;writeVal: Procedure to convert a number to a string and print it.
;parameters: (12) @outputStr (8) @userNum
;returns: N/A (8 to fix stack)
;preconditions: @userNum holds a valid signed integer.
;registers changed: N/A; All registers restored using pushad/popad

writeVal PROC
	push	ebp
	mov	ebp, esp
	pushad

	mov	esi, [ebp+8]
	mov	esi, [esi]
	mov	edi, [ebp+12]
	
	; Get digit length of @userNum and store to ECX
	getNumLength esi

	; Set the offset of EDI to the last character and work backwards. 
	add	edi, ecx
	mov	ebx, esi

	; If the number is signed, add 1 and use two's complement.
	test	esi, esi
	jns	REVERSEDIRECTION
	neg	ebx
	inc	edi

	; Flip direction for string writing and add null terminating character.
REVERSEDIRECTION:
	std
	mov	eax, 0
	stosb

	; Convert each number and add to the output string, from right to left.
WRITENUMLOOP:
	mov	eax, ebx
	mov	ebx, 10
	mov	edx, 0
	idiv	ebx
	mov	ebx, eax
	add	edx, 48
	mov	eax, edx
	stosb
	loop	WRITENUMLOOP

	; If the number is negative, add the minus sign to it.
	test	esi, esi
	jns	EXITWRITENUM
	mov	eax, 45
	stosb

	; Move the converted number to memory and return.
EXITWRITENUM:
	mov	[ebp+12], edi
	popad
	pop	ebp
	ret	8

writeVal ENDP

;printArr: Procedure to output an array of strings to user using displayArr macro.
;parameters: (16) @arr (12) LENGTHOF arr (8) arrSize
;returns: N/A (12 to fix stack)
;preconditions: arr and arrSize defined in .data
;registers changed: N/A; All registers restored using pushad/popad

printArr PROC

	push	ebp
	mov	ebp, esp

	; Call the displayArr macro using passed in parameters.
	displayArr	[ebp+16], [ebp+12], [ebp+8]

	pop	ebp
	ret	12

printArr ENDP

;printNumArr: Procedure to output an array of signed 32-bit integers to user by converting each
;			  number to a string and using displayString to print them.
;parameters: (24) @prompt (20) @separator (16) @outputStr (12) @arr (8) arrSize
;returns: N/A (16 to fix stack)
;preconditions: @arr is filled with signed integers.
;registers changed: N/A; All registers restored using pushad/popad

printNumArr PROC

	push	ebp
	mov	ebp, esp
	pushad

	; Use the array size as the loop counter (10) and move in the number array to register.
	mov	ecx, [ebp+8]
	mov	esi, [ebp+12]

	; Display the passed-in prompt.
	displayString [ebp+24]
	call	CrLf

; Loop through the number array, converting each one to a string and displaying. 
PRINTNUMARRLOOP:
	push	[ebp+16]
	push	esi
	call	writeVal

	; Print the converted number string to output.
	displayString [ebp+16]

	; Put a comma and space between the numbers unless this is the last one. 
	cmp	ecx, 1
	jle	ENDNUMARRLOOP
	displayString [ebp+20]

	; Set the offset to the next number in the array.
	add	esi, 4
ENDNUMARRLOOP:
	loop	PRINTNUMARRLOOP

	popad
	pop	ebp
	ret	16

printNumArr ENDP

;getAverage: Procedure to calculate an average, given a total and a count. The value is stored
;            to the passed signed integer value.
;parameters: (16) @average (12) @userSum (8) INTCOUNT
;returns: N/A (12 to fix stack)
;preconditions: @userSum and INTCOUNT hold valid signed integers.
;registers changed: N/A; All registers restored using pushad/popad

getAverage PROC

	push	ebp
	mov	ebp, esp
	pushad

	; Divide the sum by the count to determine the average.
	mov	eax, [ebp+12]
	mov	eax, [eax]
	cdq
	mov	ebx, [ebp+8]
	idiv	ebx

	; Store the hard-rounded average to @average
	mov	ebx, [ebp+16]
	mov	[ebx], eax

	popad
	pop	ebp
	ret	12

getAverage ENDP

END main

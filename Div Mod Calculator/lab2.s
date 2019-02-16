	.text
	.global div_and_mod

div_and_mod:
	STMFD r13!, {r2 - r12, r14}

	MOV r2, #0 	; the temp quotient / counter
	MOV r3, #0 	; the remainder
	MOV r4, r1	; contains the temp dividend and is the number being divided another number
	MOV r5, r0	; contains the temp divisor which is doing the dividing
	MOV r6, #0 	; zero register

	CMP r4, #0
	BEQ remainder	; if the dividend is 0 jump to remainder

	CMP r4, #0
	BLT ndivide ; if the dividend is less than 0 start the negitive divide

	CMP r5, #0
	BLT ndivide2 ; if the divisor < 0 go to ndivide2

	CMP r4, #0
	BGT divide	; assuming both are positive jump to divide

ndivide:
	CMP r5, #0
	BLT turnpos
	ADD r4, r4, r5 ; dividend = (negative dividend) + divisor
	SUB r2, r2, #1 ; adds 1 to the counter
	CMP r4, #0
	BGT remainder2 ; jump to remainder if the number is positive and the dividend is less than the divisor

	CMP r4, #0
	BLT ndivide	; jump to divide if the dividend > divisor

ndivide2:	; if he divisor is negative
	ADD r4, r4, r5 ; dividend = dividend + (negative) divisor
	SUB r2, r2, #1 ; adds 1 to the counter
	CMP r4, #0
	BLT remainder3 ; jump to remainder if the number is positive and the dividend is less than the divisor

	CMP r4, #0
	BGT ndivide2	; jump to divide if the dividend > divisor

turnpos:
	SUB r4, r6, r4	; this will make the dividend positive
	SUB r5, r6, r5	; this will make the divisor positive

divide:
	CMP r4, #0
	BEQ count1 ; if the dividend ends up to be 0 jump to count 1

	CMP r4, r5
	BLT remainder ; jump to remainder if the number is positive and the dividend is less than the divisor

	SUB r4, r4, r5 ; dividend = dividend - divisor
	ADD r2, r2, #1 ; adds 1 to the counter

	CMP r4, r5
	BGE divide	; jump to divide if the dividend > divisor

count1:
	SUB r2, r2, #0 ; adds 1 to the counter

remainder:
	ADD r3, r3, r4	; put the remainder in r3
	ADD r0, r3, #0 	; r0 has the remainder
	ADD r1, r2, #0 	; r1 has the quotient

	CMP r4, r4
	B done ; branch to done

remainder2:
	ADD r0, r4, #0 	; r0 has the remainder
	ADD r1, r2, #0 	; r1 has the quotient

	CMP r4, r4
	B done

remainder3:
	SUB r3, r6, r4	; r3 = r6 - r4
;	SUB r2, r2, #1	; r2 = r2 - 1
	ADD r0, r3, #0 	; r0 has the remainder
	ADD r1, r2, #0 	; r1 has the quotient

done:
	LDMFD r13!, {r2-r12, r14}
	MOV pc, lr 		; Return to the C program



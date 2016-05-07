jmp main

inputStr1: db "4556AB000000000000"
inputStr2: db "ff1000000000000000"


input:   db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00H
input2:	 db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00H
result:	 db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00H, 00h, 00h, 00h

MsgAnswer: db "Answer is: ", 0h

PrintLn:
	mov ah, 2
	mov dl, 13
	int 21h
	mov dl, 10
	int 21h
	ret

loopRead:
	mov ah,01
readLoopStart:
	int 21h
	cmp al,13
	je exitRead
	cmp al,3ah ; rakamlan dokuz
	jl digit
	cmp al,97
	jge kucukharf
	sub al,55
	jmp cont
	digit:
		sub al,30h
		jmp cont
	kucukharf:
		sub al,87
	cont:
	mov dl, al
	MOV ch, AL
	shl dl, 4
	int 21h
	cmp al,13
	je exitReadWithShift
	cmp al,3ah ; rakamlan dokuz
	jl digit2
	cmp al,97
	jge kucukharf2
	sub al,55
	jmp cont2
	digit2:
		sub al,30h
		jmp cont2
	kucukharf2:
		sub al,87
	cont2:
		add dl, al
		push bx
		push dx
		mov dx, bx
		add dx, 8
		
	loopKaydir:
		cmp bx,dx
		je loopKaydirEnd
		mov al, [bx+1]
		mov [bx], al
		inc bx
		jmp loopKaydir
	loopKaydirEnd:	
	pop dx	
	mov [bx],dl
	
	pop bx
	jmp readLoopStart	

exitReadWithShift:
	mov dx, bx
	add dx, 8
	loopKaydir2:
		mov ah, [bx]
		shl ah, 4
		mov [bx], ah
		cmp bx,dx
		je loopKaydirEnd2
		mov cl, [bx+1]
		shr cl, 4
		add [bx],cl
		inc bx
		jmp loopKaydir2
	loopKaydirEnd2:
	add [bx], ch
exitRead:
	ret
main:

mov bx, input
call loopRead

call PrintLn

mov bx, input2
call loopRead

call PrintLn

mov si,input
mov bx,input2
mov di,result
add di, 16
add si, 8
add bx, 8

mov ch,9
outerLoop:

	mov cl,9
	push di
multloop: 
	mov al,[si]
	mul BYTE [bx]
	add [di+1], al
	adc [di],ah
	
	jnc noCarry
	push di
	push ax
	carryLoop:
		dec di
		mov al, 01h
		add [di], al
		jc carryLoop
	pop ax
	pop di
	

noCarry:
	dec si
	dec di
	dec cl
	jnz multloop
multloopEnd:
	pop di
	dec di
	dec bx
	add si,9
	dec ch
	jnz outerLoop

mov ah,2
mov si, MsgAnswer
printText:
	mov dl, [si]
	or dl, dl
	jz printTextEnd
	int 21h
	inc si
	jmp printText
printTextEnd:


mov si, result
mov ah, 2
mov ch, 18

printResult: 
	mov al,[si]
	shr al,4
	cmp al,10
	jge harf
	add al, 30h
	jmp continuePrintResult
	harf:
	add al, 55
continuePrintResult:
	mov dl, al
	int 21h

	mov al,[si]
	and al,0fh
	cmp al,10
	jge harf2
	add al, 30h
	jmp continuePrintResult2
	harf2:
	add al, 55
continuePrintResult2:
	mov dl, al
	int 21h
	
	inc si
	dec ch
	jnz printResult

int 	20h

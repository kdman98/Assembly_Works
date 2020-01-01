TITLE GUGUDAN
INCLUDE Irvine32.inc
.data
Str_input byte "Enter a digit(2~9): "
v1 dword 0 ; sum
v2 dword 1 ; inc
multi byte " * ",0
equals byte " = ",0

.code
main PROC
mov ecx, lengthof Str_input
mov esi, offset Str_input
mov edx, offset str_input
call writestring
call ReadInt
mov v1, eax
mov ebx,eax ; ebx always point digit
mov ecx,9
L2:
	call writedec
	mov edx, offset multi
	call writestring
	mov eax,v2
	call writedec
	inc v2
	mov edx, offset equals
	call writestring
	mov eax,v1
	call writedec
	add eax,ebx
	mov v1,eax
	mov eax,ebx
	call crlf
	loop L2
exit

main ENDP

END main

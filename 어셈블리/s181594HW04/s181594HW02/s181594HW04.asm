TITLE BugHouse
INCLUDE Irvine32.inc
.data
Str_inputR byte "Enter R: ",0
Str_inputC byte "Enter C: ",0
arr dword 1,1,1,1,1,1,1,1,1,1
inputR byte ?
inputC byte ?
outloop byte ?
.code
main PROC
mov edx, offset str_inputR
call writestring
call readint
mov inputR,al
mov edx, offset str_inputC
call writestring
call readint
mov inputC,al
mov eax,0


movzx ecx,inputR

rowL:
	push ecx ; 5 save
	movzx ecx,inputC
	mov outloop,cl
	outL:
		mov eax,0
		mov ebx,0
		push ecx ; 9 save

		mov cl,outloop
		sub ebx,type arr
		inL:
			add ebx, type arr
			add eax, arr[ebx] ; 8~0
			
			loop inL

		mov arr[ebx], eax ; type...
		pop ecx ; 9 load
		dec outloop
		loop outL
	pop ecx ; 5 load
	loop rowL

mov cl,inputC
mov eax,0
sub ebx, type arr
		
		
		inlast:
			add ebx, type arr
			add eax, arr[ebx] ; 8~0
			
			loop inlast

call writedec
call crlf


exit

main ENDP
END main
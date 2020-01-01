TITLE workTime ; 20181594 구산 
INCLUDE Irvine32.inc
ReadFile PROTO, filehandle:DWORD,pBuffer:PTR BYTE, ; 입 력 버 퍼 offset offset 이 저 장된 reg 도 가 능 )
nBufsize:DWORD,; 읽 고자 하 는 최 대 byte 수
pBytesRead:PTR DWORD, ; 실 제 읽 은 개 수 저 장을 위 한 변 수 offset 위 와 동 일
pOverlapped:PTR DWORD ; 무 시 (0 을 전 달 의 미가 있 지만 생 략한다
BUF_SIZE = 512


.data
stdinHandle HANDLE ?
stdoutHandle HANDLE ?
inBuf BYTE BUF_SIZE DUP(?) ; input buf
bytesREAD DWORD ? ; 실 제로 읽 은 byte 개 수 저 장
outBuf BYTE BUF_SIZE DUP(?) ; output buf
bytesWRITE DWORD ? ; 실 제로 쓰 여진 byte 개 수 저 장
task dword 1024 dup(0) ; 과제 
work dword 1024 dup(0) ; 작업시간
blank byte ' '
sum dword 0
diff dword 100

ent byte 0Dh, 0Ah
.code



main proc

INVOKE getstdhandle, STD_OUTPUT_HANDLE
mov stdouthandle, eax
INVOKE Getstdhandle, STD_INPUT_HANDLE
mov stdinHandle,eax
mov edx,offset inbuf
call read_a_line
mov edx,offset inbuf
mov ecx,2
call parseinteger32
mov ecx,eax

line_loop:
push ecx
					;task 배열 만들기 시작 @@@@@
mov sum,0
mov edx,offset inbuf
mov eax,stdinHandle
mov byte ptr [edx],' '
inc edx
mov byte ptr [edx],' '
inc edx
call read_a_line ; edx 문자열 주소, eax 핸들 ecx 읽은 문자수
cmp ecx,0
je endfile
mov byte ptr [edx+ecx],' '


mov edx,offset inbuf

xor ebx,ebx ; clear reg
xor esi,esi; esi used for flag!
xor edi,edi; to save address of array
add ecx,3
loopperline:;readaline에서 읽은 ecx 활용, 숫자 다음 띄어쓰기에서 숫자 읽음
   push ecx
   xor eax,eax
   cmp byte ptr [edx+ebx],'0'
   jb notnumber
   cmp byte ptr [edx+ebx],'9'
   ja notnumber
   mov esi,1
   jmp justbeforeloop

   notnumber:
   cmp esi,1 
   je callparse
   jmp justbeforeloop
   
   callparse:
   mov esi,0
   push ecx
   mov ecx,ebx
   inc ecx
   call parseinteger32 ; 수 하나 읽어오는 함수

   mov task[edi],eax ; 배열에 차례차례 저장, 0번째 수는 갯수!
   
   
   add edi,type task

   ; call dumpregs 디버깅용
   pop ecx
  
   add edx,ebx;
   xor ebx,ebx;
   ;add edi, type arr

   justbeforeloop:
      inc ebx
   pop ecx
   loop loopperline
 
						 ;work 배열 만들기 시작@@@@
mov edx,offset inbuf
mov eax,stdinHandle
mov byte ptr [edx],' '
inc edx
mov byte ptr [edx],' '
inc edx
call read_a_line ; edx 문자열 주소, eax 핸들 ecx 읽은 문자수
mov byte ptr [edx+ecx],' '


mov edx,offset inbuf

xor ebx,ebx ; clear reg
xor esi,esi; esi used for flag!
xor edi,edi; to save address of array
add ecx,3
loopperline2:;readaline에서 읽은 ecx 활용, 숫자 다음 띄어쓰기에서 숫자 읽음
   push ecx
   xor eax,eax
   cmp byte ptr [edx+ebx],'0'
   jb notnumber2
   cmp byte ptr [edx+ebx],'9'
   ja notnumber2
   mov esi,1
   jmp justbeforeloop2

   notnumber2:
   cmp esi,1 
   je callparse2
   jmp justbeforeloop2
   
   callparse2:
   mov esi,0
   push ecx
   mov ecx,ebx
   inc ecx
   call parseinteger32 ; 수 하나 읽어오는 함수
  
   mov work[edi],eax ; 배열에 차례차례 저장, 0번째 수는 갯수!
   
   
   add edi,type work

   ; call dumpregs 디버깅용
   pop ecx
  
   add edx,ebx;
   xor ebx,ebx;
   ;add edi, type arr

   justbeforeloop2:
      inc ebx
   pop ecx
   loop loopperline2

  
  
  ;;비교 작업 시작
  mov ecx,task[0]
  mov edi,4 ; task index
  
  taskloop:
	push ecx
	xor ebx,ebx ; for index to make ZERO
	mov ecx, work[0]
	xor edx,edx ; for -1
	mov esi,4
	mov diff,100
	workloop:
		mov eax,dword ptr work[esi]
		sub eax,dword ptr task[edi]
		js notnew

		cmp diff,eax ; diff is minimum difference
		jb notnew
		mov ebx,esi
		mov diff,eax
		inc edx
		notnew:

		add esi,type work
		loop workloop
	cmp edx,0
	je cantfinish
	
	mov eax,work[ebx] ;; TODO : -1 출력의 경우ㅡ
	add sum,eax
	mov work[ebx],0
	add edi, type task
	pop ecx
	loop taskloop

  jmp printsum

  cantfinish:
  mov sum,-1

  printsum:
  mov eax,sum
  mov edx,offset inbuf
  call inttostr

  invoke writefile,stdouthandle,offset inbuf,ecx,addr byteswrite,0; write int
  invoke writefile,stdouthandle,offset ent,2,addr byteswrite,0 ; crlf
  
  
  ;다 끝내고 다음 두 줄 받으러 갈 때
  pop ecx
  dec ecx
  cmp ecx,0
  ja line_loop

  endfile:
  xor eax,eax
main ENDP

Read_a_Line PROC
;; Input EAX : File Handle
;; EDX : Buffer offset to store the string
;; Output ECX : # of chars read(0 if none(i.e.
;; Function
;; Read a line from a ~.txt file until CR,
;; CR, LF are ignored and 0 is appended at the end.
;; ECX o nly counts valid chars just before CR.
.data
Single_Buf__ BYTE ? ; two underscores
Byte_Read__ DWORD ? ;
.code
xor ecx, ecx ; reset counter
Read_Loop :
;; Note: Win32 API functions do not preserve
;;EAX, EBX, ECX, and EDX.
push eax ; save registers
push ecx
push edx ; read a single char
INVOKE ReadFile , EAX, OFFSET Single_Buf__, 1, OFFSET Byte_Read__, 0
pop edx ; restore registers
pop ecx
pop eax
cmp DWORD PTR Byte_Read__, 0 ; check # of chars read
je Read_End ; if read nothing, return
;; Each end of line consists of CR and then LF
mov bl, Single_Buf__ ; load the char
cmp bl, 0dh
je Read_Loop ; if CR, read once more
cmp bl, 0ah
je Read_End ; End of line detected, return
mov [edx], bl ; move the char to input buf
inc edx ; ++1 buf pointer
inc ecx ; ++1 char counter
jmp Read_Loop ; go to start to read the next line
Read_End:
mov BYTE PTR [edx], 0 ; append 0 at the end
ret
Read_a_Line ENDP


IntToStr PROC
;;INPUT
;;  eax : integer to convert(32bit signed)
;;  edx : string buffer offset
;;OUTPUT
;;  integer string in the buffer (EOS('\0' (== 0)) appended)
;;  ecx : the string size (excluding 0)
push eax
push ebx
push edx
push esi
push edi

mov esi, eax
mov edi, edx

test eax, 80000000h
jz P1
 neg eax
P1:
 xor ecx, ecx
 mov ebx, 10
ConvLoop:
 cdq
 div ebx
 or dx, 0030h
 push dx
 inc ecx
cmp eax, 0
jnz ConvLoop

mov ebx, ecx

test esi, 80000000h
jz P2
 mov BYTE PTR [edi], '-'
 inc edi
 inc ebx
P2:
RevLoop:
 pop ax
 mov [edi], al
 inc edi
loop RevLoop
mov BYTE PTR [edi], 0

mov ecx, ebx

pop edi
pop esi
pop edx
pop ebx
pop eax

ret
IntToStr ENDP

END main
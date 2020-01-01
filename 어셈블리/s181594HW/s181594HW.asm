TITLE square ; 20181594 구산
INCLUDE Irvine32.inc
ReadFile PROTO, filehandle:DWORD,pBuffer:PTR BYTE, ; 입 력 버 퍼 offset offset 이 저 장된 reg 도 가 능 )
nBufsize:DWORD,; 읽 고자 하 는 최 대 byte 수
pBytesRead:PTR DWORD, ; 실 제 읽 은 개 수 저 장을 위 한 변 수 offset 위 와 동 일
pOverlapped:PTR DWORD ; 무 시 (0 을 전 달 의 미가 있 지만 생 략한다
BUF_SIZE = 100
.data
stdinHandle HANDLE ?
stdoutHandle HANDLE ?
inBuf BYTE BUF_SIZE DUP(?) ; input buf
bytesREAD DWORD ? ; 실 제로 읽 은 byte 개 수 저 장
outBuf BYTE BUF_SIZE DUP(?) ; output buf
bytesWRITE DWORD ? ; 실 제로 쓰 여진 byte 개 수 저 장

var1 word 1000h,2000h
.code
movzx ax,var1


main proc



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
END main
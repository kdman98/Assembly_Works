TITLE square ; 20181594 ���� 20181616 ������ 20181658 ������
INCLUDE Irvine32.inc
ReadFile PROTO, filehandle:DWORD,pBuffer:PTR BYTE, ; �� �� �� �� offset offset �� �� ��� reg �� �� �� )
nBufsize:DWORD,; �� ���� �� �� �� �� byte ��
pBytesRead:PTR DWORD, ; �� �� �� �� �� �� �� ���� �� �� �� �� offset �� �� �� ��
pOverlapped:PTR DWORD ; �� �� (0 �� �� �� �� �̰� �� ���� �� ���Ѵ�
BUF_SIZE = 1024
.data
stdinHandle HANDLE ?
stdoutHandle HANDLE ?
inBuf BYTE BUF_SIZE DUP(?) ; input buf
bytesREAD DWORD ? ; �� ���� �� �� byte �� �� �� ��
outBuf BYTE BUF_SIZE DUP(?) ; output buf
bytesWRITE DWORD ? ; �� ���� �� ���� byte �� �� �� ��
arr dword 1024 dup(?) ; ���� �迭
blank byte ' '
ent byte 0Dh, 0Ah
.code



main proc

INVOKE getstdhandle, STD_OUTPUT_HANDLE
mov stdouthandle, eax
INVOKE Getstdhandle, STD_INPUT_HANDLE
mov stdinHandle,eax

line_loop:
mov edx,offset inbuf
mov eax,stdinHandle
mov byte ptr [edx],' '
inc edx
mov byte ptr [edx],' '
inc edx
call read_a_line ; edx ���ڿ� �ּ�, eax �ڵ� ecx ���� ���ڼ�
mov byte ptr [edx+ecx],' '

cmp ecx, 0
je endfile

mov edx,offset inbuf
;������� ���� �ڵ� ����

xor ebx,ebx ; clear reg
xor esi,esi; esi used for flag!
add ecx,3
loopperline:;readaline���� ���� ecx Ȱ��
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
   call parseinteger32 ; �ƴ� ���ڱ� �� eax�� ���ڸ� ������????
   ; call dumpregs ������

   ;; ����
   push edx
   imul eax
   pop edx

   ;; ¦��/���� �Ǵ��ؼ� ¦�� ����ȭ�ϱ�
   test eax, 00000001h
   jz evn
   neg eax
   evn:

   pop ecx
   pushad
   
   call inttostr
   invoke writefile,stdouthandle,edx,ecx,addr byteswrite,0 ; 
   popad
   pushad
   invoke writefile,stdouthandle,offset blank,1,addr byteswrite,0 ; ����
   popad
   add edx,ebx;
   xor ebx,ebx;
   ;add edi, type arr

   justbeforeloop:
      inc ebx
   pop ecx
   loop loopperline

   invoke writefile,stdouthandle,offset ent,2,addr byteswrite,0 ; ����

   jmp line_loop

;���� �ڵ� ��

endfile:

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
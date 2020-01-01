TITLE Poly
INCLUDE Irvine32.inc
INCLUDE CSE3030_PHW02_2019.inc
.code
main PROC
mov eax, 0
mov ecx, 38
L1: add eax, x1
loop L1
mov ecx, 47
L2: add eax, x2
loop L2
mov ecx, 19
L3: add eax, x3
loop L3
call Writeint
exit
main ENDP
END main
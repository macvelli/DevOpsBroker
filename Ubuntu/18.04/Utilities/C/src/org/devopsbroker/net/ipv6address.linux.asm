;
; ipv6address.linux.asm - DevOpsBroker NASM file for the IPv6Address struct
;
; Copyright (C) 2019 Edward Smith <edwardsmith@devopsbroker.org>
;
; This program is free software: you can redistribute it and/or modify it under
; the terms of the GNU General Public License as published by the Free Software
; Foundation, either version 3 of the License, or (at your option) any later
; version.
;
; This program is distributed in the hope that it will be useful, but WITHOUT
; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
; FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
; details.
;
; You should have received a copy of the GNU General Public License along with
; this program.  If not, see <http://www.gnu.org/licenses/>.
;
; -----------------------------------------------------------------------------
; Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-43
;
; This file defines the following x86-64 assembly language functions for the
; IPv6Address struct:
;
;   o IPv6Address *b7808f25_createIPv6Address(char *ipAddress);
;   o void b7808f25_destroyIPv6Address(IPv6Address *ipv6Address);
;   o int b7808f25_initIPv6Address(IPv6Address *ipv6Address, char *ipAddress);
;   o void b7808f25_deriveSubnetPrefix(IPv6Address *ipv6Address, IPv6Address *subnetPrefix);
;   o void b7808f25_extractString(IPv6Address *ipv6Address, char *buffer);
;   o void b7808f25_isIpAddressZero(IPv6Address *ipv6Address);
;
; Recommended representation as text
;
; In an attempt to simplify IPv6 addresses, the standards provide flexibility in
; their representation. However, this also complicates several common operations:
; searching for a specific address in a text file or stream, and comparing two
; addresses to determine their equivalence. To mitigate these problems, a
; canonical format is defined[8] for rendering IPv6 addresses in text:
;
;    o Leading zeros in each 16-bit field are suppressed. For example,
;      2001:0db8::0001 is rendered as 2001:db8::1, though any all-zero field
;      that is explicitly presented is rendered as 0.
;    o "::" is not used to shorten just a single 0 field. For example,
;      2001:db8:0:0:0:0:2:1 is shortened to 2001:db8::2:1, but
;      2001:db8:0000:1:1:1:1:1 is rendered as 2001:db8:0:1:1:1:1:1.
;    o Representations are shortened as much as possible. The longest sequence
;      of consecutive all-zero fields is replaced with double-colon. If there
;      are multiple longest runs of all-zero fields, then it is the leftmost
;      that is compressed. E.g., 2001:db8:0:0:1:0:0:1 is rendered as
;      2001:db8::1:0:0:1 rather than as 2001:db8:0:0:1::1.
;    o Hexadecimal digits are expressed as lower-case letters. For example,
;      2001:db8::1 is preferred over 2001:DB8::1.
; -----------------------------------------------------------------------------
;

; ════════════════════════════ Include Directives ════════════════════════════


; ═══════════════════════════════ Preprocessor ═══════════════════════════════

; character values
%define FWDSLASH  0x2F
%define ZERO      0x30
%define NINE      0x39
%define COLON     0x3A
%define UPPER_W   0x57
%define LOWER_A   0x61
%define LOWER_F   0x66

%define ERROR_CODE   -1

; ═════════════════════════════ Initialized Data ═════════════════════════════

section .data               ; DX directives

; ════════════════════════════ Uninitialized Data ════════════════════════════

section .bss                ; RESX directives

; ══════════════════════════════ Assembly Code ═══════════════════════════════

	section .text

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ External Resources ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

extern  malloc
extern  free
extern  abort
extern  a25c96b2_invalidIPv6Address

; ~~~~~~~~~~~~~~~~~~~~~~~~ b7808f25_createIPv6Address ~~~~~~~~~~~~~~~~~~~~~~~~

	global  b7808f25_createIPv6Address:function
b7808f25_createIPv6Address:
; Parameters:
;	rdi : char *ipAddress

.prologue:                            ; functions typically have a prologue
	mov        rsi, rdi               ; prepare to make b7808f25_initIPv6Address call
	push       rsi                    ; save ipAddress onto the stack

	; malloc(sizeof(IPv6Address))
.malloc:
	mov        rdi, 0x14              ; sizeof(IPv6Address) is 20 bytes
	call       malloc WRT ..plt

	pop        rsi                    ; retrieve ipAddress from the stack
	sub        rsp, 8                 ; align stack frame before making function calls

	test       rax, rax               ; if (ptr == NULL)
	je    .fatalError

	; int b7808f25_initIPv6Address(IPv6Address *ipv6Address, char *ipAddress);
	mov        rdi, rax               ; ipv6Address = rax
	call       b7808f25_initIPv6Address

	test       eax, eax
	jz         .epilogue

	; a25c96b2_invalidIPv6Address(char *ipAddress);
.invalidIPv6Address:
	mov        rdi, rsi               ; ipAddress = rsi
	call       a25c96b2_invalidIPv6Address

.epilogue:                            ; functions typically have an epilogue
	add        rsp, 8                 ; re-align stack frame before return
	mov        rax, rdi               ; return IPv6Address *ipv6Address
	ret                               ; pop return address from stack and jump there

	; abort();
.fatalError:
	call       abort WRT ..plt

; ~~~~~~~~~~~~~~~~~~~~~~~~ b7808f25_destroyIPv6Address ~~~~~~~~~~~~~~~~~~~~~~~~

	global  b7808f25_destroyIPv6Address:function
b7808f25_destroyIPv6Address:

.prologue:                            ; functions typically have a prologue
	sub        rsp, 8                 ; align stack frame before making function calls

	; free(IPv6Address *ipv6Address)
.free:
	call       free WRT ..plt

.epilogue:                            ; functions typically have an epilogue
	add        rsp, 8                 ; re-align stack frame before return
	ret                               ; pop return address from stack and jump there

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~ b7808f25_deriveSubnet ~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  b7808f25_deriveSubnet:function
b7808f25_deriveSubnet:
; Parameters:
;	rdi : IPv6Address *ipv6Address
;	rsi : IPv6Address *ipv6Subnet
; Local Variables:
;	rax : 64 bit variable

.prologue:                            ; functions typically have a prologue
	mov        rax, [rdi]             ; put highest 64 bits of IPv6 address into subnet
	mov        [rsi], rax

	xor        rax, rax               ; set the lowest 64 bits of subnet to zero
	mov        [rsi + 8], rax

	mov        [rsi + 16], dword 64   ; set cidrSuffix to 64

.epilogue:                            ; functions typically have an epilogue
	ret                               ; pop return address from stack and jump there

; ~~~~~~~~~~~~~~~~~~~~~~~~~ b7808f25_initIPv6Address ~~~~~~~~~~~~~~~~~~~~~~~~~

	global  b7808f25_initIPv6Address:function
b7808f25_initIPv6Address:
; Parameters:
;	rdi : IPv6Address *ipv6Address
;	rsi : char *ipAddress
; Local Variables:
;	rax : Hextet value buffer
;	dx  : shorthandIndex (dh), ':' (dl)
;	cl  : Hextet index
;   r8  : Hextet character buffer

.prologue:                            ; functions typically have a prologue
	prefetcht0 [rsi]                  ; prefetch the ipAddress string into the CPU cache
	xor        rax, rax               ; clear rax
	mov        dx, 0xff3a             ; shorthandIndex = -1, dl = ':'
	xor        cl, cl                 ; hextetIndex = 0

.doWhile:
	mov        r8, [rsi]              ; move hextet into r8

	cmp        r8b, dl                ; if (ch == ':')
	je         processShorthandAddress

	inc        cl                     ; hextetIndex++
	lea        r10, [rel $+9]         ; convert string to hextet
	jmp short  convertStringToHextet

	cmp        cl, 4                  ; if (hextetIndex == 4)
	je         .doFourHextets
	cmp        cl, 8                  ; if (hextetIndex < 8)
	jb         .doWhile

.doEightHextets:
	bswap      rax                    ; change to big endian
	mov        [rdi + 8], rax         ; set the second eight bytes of the IPv6 address
	xor        eax, eax               ; return value = 0
	ret                               ; pop return address from stack and jump there

.doFourHextets:
	bswap      rax                    ; change to big endian
	mov        [rdi], rax             ; set the first eight bytes of the IPv6 address
	xor        rax, rax               ; clear rax
	jmp        .doWhile

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~ convertStringToHextet ~~~~~~~~~~~~~~~~~~~~~~~~~~~

convertStringToHextet:
; Parameters:
;	r8  : Hextet string
;	rax : Hextet value
;	dl  : ':'
; Local Variables:
;	ch  : charIndex

	mov        ch, 4                  ; charIndex = 4
	cmp        r8b, dl                ; if (ch > ':')
	ja         .hexChar

.decimalChar:
	sub        r8b, ZERO              ; if (ch >= '0')
	jae        .assignValue

.invalidIPv6Address:
	mov        eax, ERROR_CODE        ; Set return value to ERROR_CODE
	ret                               ; pop return address from stack and jump there

.hexChar:
	or         r8b, 0x20               ; toLowerCase(ch) --> ch |= 0x20
	cmp        r8b, LOWER_F           ; if (ch > 'f')
	jae short  .invalidIPv6Address
	sub        r8b, LOWER_A           ; if (ch < 'a')
	jb short   .invalidIPv6Address

	add        r8b, 0x0A              ; digit += 10

.assignValue:
	dec        ch                     ; charIndex--
	shl        rax, 4                 ; Assign hexadecimal value to rax
	or         al, r8b
	inc        rsi                    ; ipAddress++

	shr        r8, 8                  ; ch = next character
	test       ch, ch                 ; if (charIndex == 0)
	jz         .validateFifthChar

	; while (ch && ch != ':')
	test       r8b, r8b               ; if (ch == '\0')
	jz         .epilogue
	cmp        r8b, dl                ; if (ch == ':')
	je         .adjustStringPtr
	jb         .decimalChar
	jmp        .hexChar

.validateFifthChar:
	test       r8b, r8b               ; if (ch == '\0')
	jz         .epilogue
	cmp        r8b, dl                ; if (ch == ':')
	jne short  .invalidIPv6Address

.adjustStringPtr:
	inc        rsi                    ; ipAddress++

.epilogue:                            ; functions typically have an epilogue
	jmp        r10                    ; jump to the return address

; ~~~~~~~~~~~~~~~~~~~~~~~~~~ processShorthandAddress ~~~~~~~~~~~~~~~~~~~~~~~~~~

processShorthandAddress:
; Parameters:
;	rdi : IPv6Address *ipv6Address
;	rsi : char *ipAddress
; Local Variables:
;	rax : Hextet value buffer
;	dx  : shorthandIndex (dh), ':' (dl)
;	cl  : Hextet index
;   r8  : Hextet character buffer

; TODO: This needs to be finished and tested

	inc        cl                     ; hextetIndex++
	mov        dh, cl                 ; shorthandIndex = hextetIndex
	shr        r8, 8                  ; ch = next character

	test       r8b, r8b               ; if (ch == '\0')
	jz         .makeAdjustments

.doWhile:
	cmp        cl, 4                  ; if (hextetIndex != 4)
	jne        .convertString

.saveFourHextets:
	bswap      rax                    ; change to big endian
	mov        r11, rax               ; save first eight bytes of IPv6 address into r11
	xor        rax, rax               ; clear rax

.convertString:
	inc        cl                     ; hextetIndex++
	lea        r10, [rel $+9]         ; convert string to hextet
	jmp short  convertStringToHextet

	cmp        cl, 6                  ; if (hextetIndex < 6)
	je         .validateAddress

	mov        r8, [rsi]              ; move hextet into r8
	jmp        .doWhile

.validateAddress:
	test       r8b, r8b               ; if (ch == '\0')
	jz         .makeAdjustments

.invalidIPv6Address:
	mov        eax, ERROR_CODE        ; Set return value to ERROR_CODE
	ret                               ; pop return address from stack and jump there

.makeAdjustments:
	ret                               ; pop return address from stack and jump there

; ~~~~~~~~~~~~~~~~~~~~~~~~~ b7808f25_isIpAddressZero ~~~~~~~~~~~~~~~~~~~~~~~~~

	global  b7808f25_isIpAddressZero:function
b7808f25_isIpAddressZero:
; Parameters:
;	rdi : IPv6Address *ipv6Address
; Local Variables:
;	rax : IPv6 address buffer register

.prologue:                            ; functions typically have a prologue
	mov        rax, [rdi]

	test       rax, rax               ; if (ipv6AddressPrefix == 0)
	jz         .testIPv6Suffix

.returnFalse:
	xor        rax, rax               ; return value = 0
	ret                               ; pop return address from stack and jump there

.testIPv6Suffix:
	mov        rax, [rdi+8]

	test       rax, rax               ; if (ipv6AddressSuffix != 0)
	jnz        .returnFalse

.returnTrue:
	xor        rax, rax               ; return value = 1
	inc        al
	ret                               ; pop return address from stack and jump there

; ~~~~~~~~~~~~~~~~~~~~ b7808f25_extractString (using SSE2) ~~~~~~~~~~~~~~~~~~~

	global  b7808f25_extractString:function
b7808f25_extractString:
; Parameters:
;	rdi : IPv6Address *ipv6Address
;	rsi : char *buffer
; Local Variables:
;	xmm0 : IPv6 address

.prologue:                            ; functions typically have a prologue
	movdqu     xmm0, [rdi]            ; set xmm0 to the IPv6 address
	movd       xmm15, [rdi + 16]      ; set xmm1 to the IPv6 cidrSuffix

	; TODO: Check for special case where xmm0 is zero

	lea        r10, [rel $+12]        ; put the shorthand bytemask into r11
	jmp        calculateShorthandBytemask

	mov        eax, 0x000A000A        ; set every word in xmm1 to ten
	movd       xmm1, eax
	pshufd     xmm1, xmm1, 0b         ; broadcast ten to every dword in xmm1

	mov        eax, 0x00300030        ; set every word in xmm2 to '0'
	movd       xmm2, eax
	pshufd     xmm2, xmm2, 0b         ; broadcast '0' to every dword in xmm2

	mov        eax, 0x00570057        ; set every word in xmm3 to 'W'
	movd       xmm3, eax
	pshufd     xmm3, xmm3, 0b         ; broadcast 'W' to every dword in xmm3

.firstCharacter:
	movdqa     xmm4, xmm0             ; xmm4 = xmm0 / 16
	psrlw      xmm4, 4

	movdqa     xmm5, xmm4             ; xmm5 = xmm0 % 16
	psllw      xmm5, 4
	psubw      xmm0, xmm5             ; xmm0 -= xmm5

	movdqa     xmm6, xmm1             ; if (xmm0 < 10) then set xmm6 word to 0xffff
	pcmpgtw    xmm6, xmm0

	movdqa     xmm7, xmm2             ; xmm7 = '0'
	pand       xmm7, xmm6
	pandn      xmm6, xmm3             ; xmm6 = 'W'
	por        xmm6, xmm7             ; blend xmm6 and xmm7
	paddw      xmm0, xmm6             ; add '0' or 'W' to xmm0 remainder

	movdqa     xmm8, xmm0             ; place first character into xmm8

.secondCharacter:
	movdqa     xmm0, xmm4             ; set up xmm0 for second character
	psrlw      xmm4, 4                ; xmm4 = xmm0 / 16

	movdqa     xmm5, xmm4             ; xmm5 = xmm0 % 16
	psllw      xmm5, 4
	psubw      xmm0, xmm5             ; xmm0 -= xmm5

	movdqa     xmm6, xmm1             ; if (xmm0 < 10) then set xmm6 word to 0xffff
	pcmpgtw    xmm6, xmm0

	movdqa     xmm7, xmm2             ; xmm7 = '0'
	pand       xmm7, xmm6
	pandn      xmm6, xmm3             ; xmm6 = 'W'
	por        xmm6, xmm7             ; blend xmm6 and xmm7
	paddw      xmm0, xmm6             ; add '0' or 'W' to xmm0 remainder

	psllw      xmm8, 8                ; place second character into xmm8
	por        xmm8, xmm0

.thirdCharacter:
	movdqa     xmm0, xmm4             ; set up xmm0 for third character
	psrlw      xmm4, 4                ; xmm4 = xmm0 / 16

	movdqa     xmm5, xmm4             ; xmm5 = xmm0 % 16
	psllw      xmm5, 4
	psubw      xmm0, xmm5             ; xmm0 -= xmm5

	movdqa     xmm6, xmm1             ; if (xmm0 < 10) then set xmm6 word to 0xffff
	pcmpgtw    xmm6, xmm0

	movdqa     xmm7, xmm2             ; xmm7 = '0'
	pand       xmm7, xmm6
	pandn      xmm6, xmm3             ; xmm6 = 'W'
	por        xmm6, xmm7             ; blend xmm6 and xmm7
	paddw      xmm0, xmm6             ; add '0' or 'W' to xmm0 remainder

	movdqa     xmm9, xmm0             ; place third character into xmm9

.fourthCharacter:
	pcmpgtw    xmm1, xmm4             ; if (xmm4 < 10) then set xmm1 word to 0xffff

	pand       xmm2, xmm1             ; xmm1 = '0'
	pandn      xmm1, xmm3             ; xmm3 = 'W'
	por        xmm1, xmm2             ; blend xmm1 and xmm2
	paddw      xmm4, xmm1             ; add '0' or 'W' to xmm4

	psllw      xmm9, 8                ; place fourth character into xmm9
	por        xmm9, xmm4

.unpackWords:
	movdqa     xmm10, xmm8            ; set xmm10 to first two characters
	punpcklwd  xmm10, xmm9            ; unpack the lower words from xmm9 and xmm10
	punpckhwd  xmm8, xmm9             ; unpack the higher words from xmm8 and xmm9

.populateBuffer:
	xor        rdx, rdx               ; clear rdx
	xor        rcx, rcx               ; clear rcx
	mov        ax, ZERO               ; ah = 0, al = '0'
	mov        r8, 0x3A00000000       ; set high dword of r8 to ':'

.firstHextet:
	movd       edx, xmm10             ; move first hextet into edx

	lea        r10, [rel $+12]        ; process the first hextet
	jmp near   processHextet

.secondHextet:
	psrldq     xmm10, 4               ; move second hextet into edx
	movd       edx, xmm10
	shr        r11, 8                 ; shift to the next bytemask

	lea        r10, [rel $+12]        ; process the second hextet
	jmp near   processHextet

.thirdHextet:
	psrldq     xmm10, 4               ; move third hextet into edx
	movd       edx, xmm10
	shr        r11, 8                 ; shift to the next bytemask

	lea        r10, [rel $+12]         ; process the third hextet
	jmp near   processHextet

.fourthHextet:
	psrldq     xmm10, 4               ; move fourth hextet into edx
	movd       edx, xmm10
	shr        r11, 8                 ; shift to the next bytemask

	lea        r10, [rel $+12]         ; process the fourth hextet
	jmp near   processHextet

.fifthHextet:
	movd       edx, xmm8              ; move fifth hextet into edx
	shr        r11, 8                 ; shift to the next bytemask

	lea        r10, [rel $+12]         ; process the fifth hextet
	jmp near   processHextet

.sixthHextet:
	psrldq     xmm8, 4                ; move sixth hextet into edx
	movd       edx, xmm8
	shr        r11, 8                 ; shift to the next bytemask

	lea        r10, [rel $+9]         ; process the sixth hextet
	jmp short  processHextet

.seventhHextet:
	psrldq     xmm8, 4                ; move seventh hextet into edx
	movd       edx, xmm8
	shr        r11, 8                 ; shift to the next bytemask

	lea        r10, [rel $+9]         ; process the seventh hextet
	jmp short  processHextet

.eighthHextet:
	psrldq     xmm8, 4                ; move eighth hextet into edx
	movd       edx, xmm8
	shr        r11, 8                 ; shift to the next bytemask

	lea        r10, [rel $+9]         ; process the eighth hextet
	jmp short  processHextet

.cidrSuffix:
	mov        cl, ah                 ; preserve isShorthand value
	movd       eax, xmm15             ; retrieve cidrSuffix from xmm15

.isShorthand:
	test       cl, cl                 ; if (isShorthand) skip correcting buffer pointer
	jnz        .calcCIDRSuffix
	dec        rsi                    ; correct string buffer pointer position

	test       eax, eax               ; if (cidrSuffix != 0)
	jnz        .calcCIDRSuffix

.skipCIDRSuffix:
	mov        [rsi], eax             ; write out '\0' to [rsi]
	ret                               ; pop return address from stack and jump there

.calcCIDRSuffix:
	mov        r10b, 0x0a             ; r10b = 10 (constant)
	xor        rdx, rdx               ; clear out rdx

	cmp        al, 0x64               ; if (value >= 100)
	jae        .greaterThanEqualTo100
	cmp        al, r10b               ; else if (value >= 10)
	jae        .greaterThanEqualTo10
	jmp        .lessThan10            ; else value < 10

.greaterThanEqualTo100:
	div        r10b                   ; value % 10 (AH), value /= 10 (AL)
	add        ah, ZERO               ; remainder += '0'
	mov        dl, ah

	xor        ah, ah                 ; remainder = 0

.greaterThanEqualTo10:
	div        r10b                   ; value % 10 (AH), value /= 10 (AL)
	add        ah, ZERO               ; remainder += '0'
	shl        edx, 8                 ; dl register buffer = ah
	mov        dl, ah

.lessThan10:
	add        al, ZERO               ; quotient += '0'
	shl        edx, 8                 ; dl register buffer = al
	mov        dl, al

.outputCidrSuffix:
	shl        edx, 8                 ; append '/'
	mov        dl, 0x2F
	mov        [rsi], rdx             ; write out cidrSuffix to [rsi]

.epilogue:                            ; functions typically have an epilogue
	ret                               ; pop return address from stack and jump there

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ processHextet ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

processHextet:
; Parameters:
;	edx : Hextet
;	r8  : ':'
;	r11 : shorthand bytemask
;	ah  : boolean isShorthand
;	al  : '0'
; Local Variables:
;	rcx : hextet length

	cmp        r11b, 0x01             ; if (bytemask[0] == 1)
	je         .writeHextet
	cmp        r11b, 0xff             ; if (bytemask[0] == -1)
	je         .shorthandHextet

	mov        [rsi], dword 0x3A00    ; write out '0:' to [rsi]
	inc        rsi                    ; rsi += 2
	inc        rsi
	jmp        r10                    ; jump to the return address

.shorthandHextet:
	test       ah, ah
	jnz        .epilogue

	mov        [rsi], dword 0x3A      ; write out shorthand to [rsi]
	inc        rsi                    ; rsi += 1
	inc        ah                     ; isShorthand = true
	jmp        r10                    ; jump to the return address

.writeHextet:
	xor        ah, ah                 ; isShorthand = false
	or         rdx, r8                ; append ':' to the hextet
	mov        cl, 5
.LWHILE0:
	cmp        dl, al                 ; while (rdx[0] == '0')
	jne        .LEND0
	shr        rdx, 8                 ; remove leading zero
	dec        cl
	jmp        .LWHILE0

.LEND0:
	mov        [rsi], rdx             ; write out hextet to [rsi]
	add        rsi, rcx               ; move rsi pointer

.epilogue:                            ; functions typically have an epilogue
	jmp        r10                    ; jump to the return address

; ~~~~~~~~~~~~~~~~~~~~~~~~ calculateShorthandBytemask ~~~~~~~~~~~~~~~~~~~~~~~~

calculateShorthandBytemask:
; Parameters:
;	xmm0 : IPv6 address
;	r11  : shorthand bytemask register
; Local Variables:
;	xmm1  : 128-bit value temp register
;	rdx   : 64-bit value temp register
;	rcx   : Bit value register
;	ah/al : Loop counters

.prologue:
	movdqa     xmm1, xmm0             ; xmm1 = xmm0
	mov        rcx, 0x01              ; rcx = 1
	xor        r11, r11               ; r11 = 0
	movq       rdx, xmm0              ; move first qword into rdx
	mov        ah, 1                  ; ah = 1
	mov        al, 3                  ; al = 3

.processFourHextets:
	test       dx, dx                 ; if (dx == '0000')
	jz         .LELSE0
	or         r11, rcx               ; set bit to 1 if not zero, else skip
.LELSE0:
	shl        rcx, 8

	test       al, al                 ; while (al > 0)
	jz         .nextFourHextets

	shr        rdx, 16
	dec        al
	jmp        .processFourHextets

.nextFourHextets:
	test       ah, ah                 ; if (ah == 0)
	jz         .LIF1

	psrldq     xmm1, 8                ; shift to the next qword in xmm1
	movq       rdx, xmm1              ; move second qword into rdx
	xor        ah, ah                 ; ah = 0
	mov        al, 3                  ; al = 3
	jmp        .processFourHextets

.LIF1:                                ; if (r11 == ones in all bytes)
	mov        rax, 0x101010101010101
	cmp        r11, rax               ; NOTE: cannot use a 64-bit immediate value with cmp
	je         .epilogue

.reduceBytemask:
	mov        r8, r11                ; r8 = shorthand bytemask
	xor        dx, dx                 ; best length = 0, best index = 0
	xor        cx, cx                 ; current length = 0, current index = 0

	mov        al, 6                  ; al = (number of hextets - 1) <-- really minus 2

.outerLoop:
	test       r8w, r8w               ; if (r8w == '0000:0000')
	jnz        .outerLoopWhile

	mov        ch, ah                 ; current length = 1
.innerLoop:
	inc        ch                     ; current length += 1

	test       al, al                 ; if (al == 0)
	jz         .checkForNewBestLength

	shr        r8, 8
	dec        al                     ; decrement outer loop index
	test       r8w, r8w
	jz         .innerLoop             ; while (r8w == '0000:0000')

.checkForNewBestLength:
	cmp        ch, dh
	jbe        .adjustCurrentIndex

	mov        dh, ch                 ; found a new best length for shorthand bytemask
	mov        dl, cl

	test       al, al                 ; if (al == 0)
	jz         .wasShorthandFound

.adjustCurrentIndex:
	add        cl, ch
	jmp        .outerLoop

.outerLoopWhile:
	test       al, al                 ; while (al > 0)
	jz         .wasShorthandFound

	shr        r8, 8                  ; shift shorthand block one byte to the right
	inc        cl                     ; increment current index
	dec        al                     ; decrement outer loop index
	jmp        .outerLoop

.wasShorthandFound:
	test       dh, dh                 ; if (best length != 0)
	jnz        .shorthandFound

; No shorthand found
	inc        al
	or         r11, rax
	jmp        .epilogue

.shorthandFound:
	sub        dh, 2                  ; best length -= 2
	mov        rax, 0xffff            ; rax = 1111111111111111b
	mov        cl, 0xff               ; cl = 11111111b

.buildAdjustBytemaskLoop:
	test       dh, dh
	jz         .applyAdjustment

	dec        dh
	shl        rax, 8
	or         al, cl
	jmp        .buildAdjustBytemaskLoop

.applyAdjustment:
	mov        cl, dl                 ; put best index into cl
	shl        cl, 3                  ; adjust the index for byte shift
	shl        rax, cl                ; move bytemask adjustment to proper index
	or         r11, rax               ; apply adjustment to shorthand bytemask

.epilogue:                            ; functions typically have an epilogue
	jmp        r10                    ; jump to the return address

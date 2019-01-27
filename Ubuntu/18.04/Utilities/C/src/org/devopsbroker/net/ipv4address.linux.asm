;
; ipv4address.linux.asm - DevOpsBroker NASM file for the IPv4Address struct
;
; Copyright (C) 2018 Edward Smith <edwardsmith@devopsbroker.org>
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
; Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-39
;
; This file defines the following x86-64 assembly language functions for the
; IPv4Address struct:
;
;   o IPv4Address *e1e7e8f5_createIPv4Address(char *ipAddress);
;   o void e1e7e8f5_destroyIPv4Address(IPv4Address *ipv4Address);
;   o int e1e7e8f5_initIPv4Address(IPv4Address *ipv4Address, char *ipAddress);
;   o void e1e7e8f5_deriveSubnetMask(IPv4Address *ipv4Address);
;   o char *e1e7e8f5_toString(IPv4Address *ipv4Address, IPv4StringType strType);
;   o void e1e7e8f5_extractString(IPv4Address *ipv4Address, IPv4StringType strType, char *buffer);
; -----------------------------------------------------------------------------
;

; ════════════════════════════ Include Directives ════════════════════════════


; ═══════════════════════════════ Preprocessor ═══════════════════════════════

%define ZERO         0x30
%define NINE         0x39

%define ERROR_CODE   -1
%define STRBUF_LEN   20

; ═════════════════════════════ Initialized Data ═════════════════════════════

;	section .data           ; DX directives

; ════════════════════════════ Uninitialized Data ════════════════════════════

;	section .bss            ; RESX directives

; ══════════════════════════════ Assembly Code ═══════════════════════════════

	section .text

; ~~~~~~~~~~~~~~~~~~~~~~~~ e1e7e8f5_createIPv4Address ~~~~~~~~~~~~~~~~~~~~~~~~

	global  e1e7e8f5_createIPv4Address:function
	extern  malloc
	extern  abort
e1e7e8f5_createIPv4Address:
; Parameters:
;	rdi : char *ipAddress

.prologue:                            ; functions typically have a prologue
	push       rdi                    ; save rdi onto the stack

.malloc:                              ; malloc(sizeof(IPv4Address))
	mov        rdi, 0x10              ; sizeof(IPv4Address) is 16 bytes
	call       malloc WRT ..plt
	test       rax, rax               ; if (ptr == NULL)
	jne        .initIPv4Address
	call       abort WRT ..plt

.initIPv4Address:                     ; e1e7e8f5_initIPv4Address(IPv4Address *ipv4Address, char *ipAddress)
	pop        rdi                    ; retrieve rdi from the stack
	mov        rsi, rdi
	mov        rdi, rax
	call       e1e7e8f5_initIPv4Address

	test       eax, eax
	jnz        .epilogue

	mov        rax, rdi               ; return IPv4Address *ipv4Address

.epilogue:                            ; functions typically have an epilogue
	ret                               ; pop return address from stack and jump there

; ~~~~~~~~~~~~~~~~~~~~~~~~ e1e7e8f5_destroyIPv4Address ~~~~~~~~~~~~~~~~~~~~~~~~

	global  e1e7e8f5_destroyIPv4Address:function
	extern  free
e1e7e8f5_destroyIPv4Address:

.prologue:                            ; functions typically have a prologue
	sub        rsp, 8                 ; Re-align stack frame before making call

.free:                                ; free(IPv4Address *ipv4Address)
	call       free WRT ..plt

.epilogue:                            ; functions typically have an epilogue
	add        rsp, 8                 ; Re-align stack frame before making ret
	ret                               ; pop return address from stack and jump there

; ~~~~~~~~~~~~~~~~~~~~~~~~~ e1e7e8f5_initIPv4Address ~~~~~~~~~~~~~~~~~~~~~~~~~

	global  e1e7e8f5_initIPv4Address:function
e1e7e8f5_initIPv4Address:
; Parameters:
;	rdi : IPv4Address *ipv4Address
;	rsi : char *ipAddress
; Local Variables:
;	rdx : char *source
;	cl  : multiplication constant
;	r8b : numChars
;	r9d : ipv4 address accumulator
;	r10 : return instruction pointer

.prologue:                            ; functions typically have a prologue
	mov        rdx, [rsi]             ; put first eight characters into rdx
	mov        cl, 10                 ; set multiplication constant
	xor        r8, r8                 ; numChars = 0
	xor        r9, r9                 ; accumulator = 0

.firstOctet:
	lea        r10, [rel $+12]
	jmp        convertStringToOctet

	cmp        dl, 0x2E               ; '.'
	jne        .invalidIPv4Address    ; Error if current character not decimal

	mov        r9b, al                ; accumulate octet
	shr        rdx, 8                 ; shift to the next character
	inc        r8b

.secondOctet:
	lea        r10, [rel $+12]
	jmp        convertStringToOctet

	cmp        dl, 0x2E               ; '.'
	jne        .invalidIPv4Address    ; Error if current character not decimal

	shl        r9d, 8                 ; accumulate octet
	mov        r9b, al

	shr        rdx, 8                 ; shift to the next character
	inc        r8b

	add        rsi, r8                ; put next eight characters into rdx
	mov        rdx, [rsi]
	xor        r8b, r8b               ; numChars = 0

.thirdOctet:
	lea        r10, [rel $+12]
	jmp        convertStringToOctet

	cmp        dl, 0x2E               ; '.'
	jne        .invalidIPv4Address    ; Error if current character not decimal

	shl        r9d, 8                 ; accumulate octet
	mov        r9b, al

	shr        rdx, 8                 ; shift to the next character
	inc        r8b

.fourthOctet:
	lea        r10, [rel $+12]
	jmp        convertStringToOctet

	shl        r9d, 8                 ; accumulate octet
	mov        r9b, al
	bswap      r9d                    ; change address to network byte order (big endian)

	test       dl, dl                 ; '\0'
	je         .epilogue
	cmp        dl, 0x2F               ; '/'
	jne        .invalidIPv4Address    ; Error if current character not null or '/'

	shr        rdx, 8                 ; shift to the next character
	inc        r8b

	cmp        r8b, 6                 ; if (numChars > 6)
	jbe        .getCIDRSuffix

	mov        edx, [rsi + r8]        ; put next four characters into edx

.getCIDRSuffix:
	xor        eax, eax               ; return value = 0
	lea        r10, [rel $+12]
	jmp        convertStringToOctet

	test       dl, dl                 ; '\0'
	jne        .invalidIPv4Address    ; Error if current character not null

	cmp        al, 0x20               ; if (cidrSuffix > 32)
	ja         .invalidIPv4Address    ; Error if cidrSuffix is greater than 32

	test       al, al                 ; if (cidrSuffix == 0)
	jz         .epilogue

	shl        rax, 32                ; cidrSuffix <<= 32
	or         r9, rax                ; address |= cidrSuffix
	mov        [rdi], r9              ; ipv4Address->address = [r9]
;	                                    ipv4Address->cidrSuffix = [r9 + 4]

	mov        esi, r9d               ; uint32_t ipv4Address = r9d
	shr        rax, 32                ; uint32_t cidrSuffix = eax
	mov        ecx, 0x20              ; ecx = 32

	call       e1e7e8f5_deriveSubnetMask.subnetMask

	xor        eax, eax               ; Set return value to zero
	ret                               ; pop return address from stack and jump there

.invalidIPv4Address:
	mov        eax, ERROR_CODE        ; Set return value to error_code
	ret                               ; pop return address from stack and jump there

.epilogue:                            ; functions typically have an epilogue
	mov        [rdi], r9              ; ipv4Address->address = [r9]
;	                                    ipv4Address->cidrSuffix = [r9 + 4]

	xor        eax, eax               ; Set return value to zero
	ret                               ; pop return address from stack and jump there

; ~~~~~~~~~~~~~~~~~~~~~~~~~ e1e7e8f5_deriveSubnetMask ~~~~~~~~~~~~~~~~~~~~~~~~~

	global  e1e7e8f5_deriveSubnetMask:function
e1e7e8f5_deriveSubnetMask:
; Parameters:
;	rdi : IPv4Address *ipv4Address

.prologue:                            ; functions typically have a prologue
	mov        rax, [rdi]

	mov        esi, eax               ; uint32_t ipv4Address = ipv4Address->[rdi]
	shr        rax, 32                ; uint32_t cidrSuffix = ipv4Address->[rdi + 4]
	mov        ecx, 0x20              ; ecx = 32

.subnetMask:
	sub        ecx, eax               ; if (cidrSuffix == 32)
	jne        .LELSE0
	mov        eax, 0xffffffff        ; subnetMask = 0xffffffff
	jmp        .routingPrefix

.LELSE0:
	mov        eax, 0x01              ; subnetMask = ((1 << (32 - cidrSuffix)) - 1) ^ 0xffffffffu
	shl        eax, cl
	dec        eax
	not        eax
	bswap      eax                    ; change subnetMask to network byte order (big endian)

.routingPrefix:
	and        esi, eax               ; routingPrefix = ipv4Address & subnetMask
	shl        rsi, 32                ; routingPrefix <<= 32
	or         rax, rsi               ; subnetMask |= routingPrefix
	mov        [rdi + 8], rax         ; ipv4Address->subnetMask = [rax]
;	                                    ipv4Address->routingPrefix = [rax + 4]

.epilogue:                            ; functions typically have an epilogue
	ret                               ; pop return address from stack and jump there

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ e1e7e8f5_toString ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  e1e7e8f5_toString:function
	extern  malloc
	extern  abort
e1e7e8f5_toString:
; Parameters:
;	rdi : IPv4Address *ipv4Address
;	rsi : IPv4StringType strType

.prologue:                            ; functions typically have a prologue
	push       rdi                    ; save rdi and rsi onto the stack
	push       rsi

.malloc:                              ; char *ipAddress = malloc(sizeof(char) * 20);
	mov        rdi, STRBUF_LEN
	sub        rsp, 8                 ; Re-align stack frame before making call
	call       malloc WRT ..plt
	test       rax, rax               ; if (ptr == NULL)
	jnz        .extractString
	call       abort WRT ..plt        ; TODO: Need to call the printErrorMessage function

.extractString:
	add        rsp, 8                 ; retrieve rdi and rsi from the stack
	pop        rsi
	pop        rdi

	mov        rdx, rax               ; pass char *ipAddress to extractString()
	call       e1e7e8f5_extractString

.epilogue:                            ; functions typically have an epilogue
	mov        rax, rdx               ; return char *ipAddress
	ret                               ; pop return address from stack and jump there

; ~~~~~~~~~~~~~~~~~~~~~~~~~~ e1e7e8f5_extractString ~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  e1e7e8f5_extractString:function
e1e7e8f5_extractString:
; Parameters:
;	rdi : IPv4Address *ipv4Address
;	rsi : IPv4StringType strType
;	rdx : char *buffer

.prologue:                            ; functions typically have a prologue
	movzx      rcx, sil               ; extract lower byte from strType
	mov        eax, [rdi + (rcx * 4)] ; uint32_t address = ipv4Address->[rdi + (rsi * 4)]
	xor        sil, sil               ; clear the lower rsi byte

	mov        r11d, eax              ; save address value in r11d

	mov        r10b, 0x0a             ; r10b = 10 (constant)
	xor        ecx, ecx               ; clear rcx to use as register buffer
	xor        r8, r8                 ; numBytes = 0

	push       r12                    ; preserve r12 caller state

.firstOctet:
	mov        r9b, 0x2e              ; '.'
	and        eax, 0xff
	lea        r12, [rel $+9]
	jmp        convertOctetToString

.secondOctet:
	shr        r11d, 8
	mov        eax, r11d
	and        eax, 0xff
	lea        r12, [rel $+9]
	jmp        convertOctetToString

.thirdOctet:
	shr        r11d, 8
	mov        eax, r11d
	and        eax, 0xff
	lea        r12, [rel $+9]
	jmp        convertOctetToString

.LIF0:
	shr        r11d, 8
	mov        eax, r11d
	test       si, si                 ; if (strType != 0)
	jnz        .cidrSuffix

.fourthOctet:
	xor        r9b, r9b               ; '\0'
	lea        r12, [rel $+9]
	jmp        convertOctetToString
	jmp        .epilogue

.cidrSuffix:
	mov        r9b, 0x2F              ; '/'
	lea        r12, [rel $+9]
	jmp        convertOctetToString

	mov        eax, [rdi + 4]         ; uint32_t cidrSuffix = ipv4Address->[rdi + 4]
	xor        r9b, r9b               ; '\0'
	lea        r12, [rel $+9]
	jmp        convertOctetToString

.epilogue:                            ; functions typically have an epilogue
	pop        r12                    ; preserve r12 caller state
	ret                               ; pop return address from stack and jump there

; ════════════════════════════ Private Functions ═════════════════════════════

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~ convertOctetToString ~~~~~~~~~~~~~~~~~~~~~~~~~~~

convertOctetToString:
; Parameters:
;	al  : value
;	ecx : register buffer
;   r8b : numBytes
;	r9b : last byte
;	r10b : 10

	mov        cl, r9b
	inc        r8b

	cmp        al, 0x64               ; if (value >= 100)
	jae        .greaterThanEqualTo100
	cmp        al, r10b               ; else if (value >= 10)
	jae        .greaterThanEqualTo10
	jmp        .lessThan10            ; else value < 10

.greaterThanEqualTo100:
	div        r10b                   ; value % 10 (AH), value /= 10 (AL)
	add        ah, ZERO               ; remainder += '0'
	shl        ecx, 8                 ; cl register buffer = ah
	mov        cl, ah
	inc        r8b

	xor        ah, ah                 ; remainder = 0

.greaterThanEqualTo10:
	div        r10b                   ; value % 10 (AH), value /= 10 (AL)
	add        ah, ZERO               ; remainder += '0'
	shl        ecx, 8                 ; cl register buffer = ah
	mov        cl, ah
	inc        r8b

.lessThan10:
	add        al, ZERO               ; quotient += '0'
	shl        ecx, 8                 ; cl register buffer = al
	mov        cl, al
	inc        r8b

	mov        [rdx], ecx
	add        rdx, r8
	xor        r8b, r8b

.epilogue:                            ; functions typically have an epilogue
	jmp        r12                    ; jump to the return address

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~ convertStringToOctet ~~~~~~~~~~~~~~~~~~~~~~~~~~~

convertStringToOctet:
; Parameters:
;	rdx : string to convert
;	cl  : multiplication constant
;	r8b : numChars

.firstChar:                           ; if (ch < '0' || ch > '9')
	cmp        dl, NINE               ; Error if character greater than nine
	jg         e1e7e8f5_initIPv4Address.invalidIPv4Address
	sub        dl, ZERO               ; Error if character less than zero
	jl         e1e7e8f5_initIPv4Address.invalidIPv4Address

	mov        al, dl                 ; value = digit
	shr        rdx, 8                 ; shift to the next character
	inc        r8b

.secondChar:
	cmp        dl, NINE               ; Error if character greater than nine
	jg         e1e7e8f5_initIPv4Address.invalidIPv4Address
	cmp        dl, ZERO
	jl         .epilogue              ; Let e1e7e8f5_initIPv4Address catch the error

	sub        dl, ZERO
	mul        cl                     ; value = (value * 10) + digit
	add        al, dl
	shr        rdx, 8                 ; shift to the next character
	inc        r8b

.thirdChar:
	cmp        dl, NINE               ; Error if character greater than nine
	jg         e1e7e8f5_initIPv4Address.invalidIPv4Address
	cmp        dl, ZERO
	jl         .epilogue              ; Let e1e7e8f5_initIPv4Address catch the error

	sub        dl, ZERO
	mul        cl                     ; value = (value * 10) + digit
	add        al, dl
	shr        rdx, 8                 ; shift to the next character
	inc        r8b

.epilogue:                            ; functions typically have an epilogue
	jmp        r10                    ; jump to the return address

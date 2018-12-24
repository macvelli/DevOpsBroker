;
; ipv4address.amd64.asm - DevOpsBroker NASM file for the IPv4Address struct
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
;   o void e1e7e8f5_initIPv4Address(IPv4Address *ipv4Address, char *ipAddress);
;   o void e1e7e8f5_deriveSubnetMask(IPv4Address *ipv4Address);
;   o char *e1e7e8f5_toString(IPv4Address *ipv4Address, IPv4StringType strType);
;   o void e1e7e8f5_extractString(IPv4Address *ipv4Address, IPv4StringType strType, char *buffer);
; -----------------------------------------------------------------------------
;

; ════════════════════════════ Include Directives ════════════════════════════


; ═══════════════════════════════ Preprocessor ═══════════════════════════════

%define ZERO        0x30
%define ERROR_CODE  -1

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
;	rdi -> r15 : char *ipAddress

.prologue:                            ; functions typically have a prologue
	push       r15                    ; save r15 onto the stack
	mov        r15, rdi               ; save char *ipAddress into r15

.malloc:                              ; malloc(sizeof(IPv4Address))
	mov        edi, 0x10
	call       malloc WRT ..plt
	test       rax, rax               ; if (ptr == NULL)
	jne        .initIPv4Address
	call       abort WRT ..plt        ; TODO: Need to call the printErrorMessage function

.initIPv4Address:                     ; e1e7e8f5_initIPv4Address(IPv4Address *ipv4Address, char *ipAddress)
	mov        rdi, rax
	mov        rsi, r15
	mov        r15, rax               ; save IPv4Address *ipv4Address into r15
	call       e1e7e8f5_initIPv4Address

.epilogue:                            ; functions typically have an epilogue
	mov        rax, r15               ; return IPv4Address *ipv4Address
	pop        r15                    ; restore r15 from the stack
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
	extern  a25c96b2_getCIDRSuffix
	extern  a25c96b2_getOctetValue
	extern  a25c96b2_invalidIPv4Address
e1e7e8f5_initIPv4Address:
;	rdi -> r15 : IPv4Address *ipv4Address
;	rsi : char *ipAddress

.prologue:                            ; functions typically have a prologue
	push       r15                    ; save r14 and r15 onto the stack
	push       r14
	push       rsi                    ; save ipAddress for possible invalidIPAddress call
	mov        r15, rdi               ; save IPv4Address *ipv4Address into r15

.localVariables:
;	r14 : uint32_t ipv4AddressValue
	push       rsi                    ; char *source = ipAddress
	xor        r14, r14               ; ipv4AddressValue = 0

.convertOctetValues:                  ; a25c96b2_getOctetValue(char **ipAddress)
	lea        rdi, [rsp]             ; parameter &source
	call       a25c96b2_getOctetValue
	cmp        eax, ERROR_CODE
	je         .invalidIPAddress
	mov        r14d, eax
	shl        r14d, 24               ; ipv4AddressValue <<= 24

	call       a25c96b2_getOctetValue
	cmp        eax, ERROR_CODE
	je         .invalidIPAddress
	shl        eax, 16                ; octetValue <<= 16
	or         r14d, eax              ; ipv4AddressValue |= octetValue

	call       a25c96b2_getOctetValue
	cmp        eax, ERROR_CODE
	je         .invalidIPAddress
	shl        eax, 8                 ; octetValue <<= 8
	or         r14d, eax              ; ipv4AddressValue |= octetValue

	call       a25c96b2_getOctetValue
	cmp        eax, ERROR_CODE
	je         .invalidIPAddress
	or         r14d, eax              ; ipv4AddressValue |= octetValue

.initIPv4Address:
	mov        rdi, [rsp]             ; parameter source

	movzx      esi, byte [rdi]        ; esi = *source
	cmp        esi, 0x2F              ; '/'
	je        .setCIDRSuffix

	mov        [r15], r14             ; ipv4Address->address = ipv4AddressValue
	xor        r14, r14               ; r14 = 0
	mov        [r15+8], r14           ; ipv4Address->subnetMask and ipv4Address->routingPrefix = 0

	add        rsp, 16                ; Discard local variables before popping registers from stack
	pop        r14                    ; restore r14 and r15 from the stack
	pop        r15
	ret                               ; pop return address from stack and jump there

.invalidIPAddress:                    ; a25c96b2_invalidIPv4Address(const char *ipAddress)
	add        rsp, 8                 ; Discard local variables
	pop        rdi                    ; parameter char *ipAddress
	add        rsp, 8                 ; Re-align stack frame before making call
	call       a25c96b2_invalidIPv4Address

.setCIDRSuffix:                       ; a25c96b2_getCIDRSuffix(const char *ipAddress, const int maxValue)
	inc        rdi                    ; source++
	mov        esi, 32                ; parameter maxValue
	call       a25c96b2_getCIDRSuffix
	cmp        eax, ERROR_CODE
	je         .invalidIPAddress

	shl        rax, 32                ; cidrSuffix <<= 32
	or         r14, rax               ; ipv4AddressValue |= cidrSuffix
	mov        [r15], r14             ; ipv4Address->address and ipv4Address->cidrSuffix
	shr        rax, 32

.subnetMask:
	sub        esi, eax               ; if (cidrSuffixValue == 32)
	jne        .LELSE0
	mov        eax, 0xffffffff        ; subnetMask = 0xffffffff
	jmp        .routingPrefix

.LELSE0:
	mov        eax, 0x01              ; subnetMask = ((1 << (32 - cidrSuffixValue)) - 1) ^ 0xffffffffu
	mov        cl, sil
	shl        eax, cl
	sub        eax, 1
	xor        eax, 0xffffffff

.routingPrefix:
	and        r14d, eax              ; routingPrefix = ipv4AddressValue & subnetMask
	shl        rax, 32                ; subnetMask <<= 32
	or         r14, rax               ; routingPrefix |= subnetMask
	mov        [r15+8], r14           ; ipv4Address->subnetMask and ipv4Address->routingPrefix

.epilogue:                            ; functions typically have an epilogue
	add        rsp, 16                ; Discard local variables before popping registers from stack
	pop        r14                    ; restore r14 and r15 from the stack
	pop        r15
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
;	rdi -> r15 : IPv4Address *ipv4Address
;	rsi -> r14 : IPv4StringType strType

.prologue:                            ; functions typically have a prologue
	push       r15                    ; save r14 and r15 onto the stack
	push       r14
	mov        r15, rdi               ; save IPv4Address *ipv4Address into r15
	mov        r14d, esi              ; save IPv4StringType strType into r14d

.malloc:                              ; char *ipAddress = malloc(sizeof(char) * 20);
	mov        rdi, 0x14
	sub        rsp, 8                 ; Re-align stack frame before making call
	call       malloc WRT ..plt
	test       rax, rax               ; if (ptr == NULL)
	jne        .firstOctet
	call       abort WRT ..plt        ; TODO: Need to call the printErrorMessage function

.firstOctet:
	add        rsp, 8                 ; save char *ipAddress onto the stack
	push       rax

	mov        r8, rax                ; char *target = ipAddress
	mov        r10b, 0x0a             ; r10b = 10
	movsxd     rsi, r14d              ; put strType back into rsi
	and        si, 0xff

	mov        edx, [r15 + (rsi * 4)] ; uint32_t address = ipv4Address->[r15 + (rsi * 4)]
	mov        eax, edx               ; value = (address >> 24)
	shr        eax, 24
	mov        dil, 0x2E              ; '.'
	call       convertOctetToString

.secondOctet:
	mov        eax, edx               ; value = (address >> 16) & 0xFF
	shr        eax, 16
	xor        ah, ah
	call       convertOctetToString

.thirdOctet:
	mov        eax, edx               ; value = (address >> 8) & 0xFF
	shr        eax, 8
	xor        ah, ah
	call       convertOctetToString

.fourthOctet:
	mov        eax, edx               ; value = address & 0xFF
	xor        ah, ah
	mov        dil, r11b              ; '\0'
	call       convertOctetToString

.cidrSuffix:
	xor        r14b, r14b             ; set lower eight bits on r14 to zero
	test       r14w, r14w             ; if (strType != 0)
	jz         .epilogue

	mov        ax, [r15+12]           ; value = ipv4Address->cidrSuffix
	mov        [r8-1], byte 0x2F      ; *(target-1) = '/'
	call       convertOctetToString

.epilogue:                            ; functions typically have an epilogue
	pop        rax                    ; return char *ipAddress
	pop        r14                    ; restore r14 and r15 from the stack
	pop        r15
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

;	bswap      eax                    ; change the endian order of the bytes
	mov        r11d, eax              ; save address value in r11d

	mov        r10b, 0x0a             ; r10b = 10 (constant)
	xor        ecx, ecx               ; clear rcx to use as register buffer
	xor        r8, r8                 ; numBytes = 0

.firstOctet:
	mov        r9b, 0x2e              ; '.'
	and        eax, 0xff
	call       convertOctetToString

.secondOctet:
	shr        r11d, 8
	mov        eax, r11d
	and        eax, 0xff
	call       convertOctetToString

.thirdOctet:
	shr        r11d, 8
	mov        eax, r11d
	and        eax, 0xff
	call       convertOctetToString

.LIF0:
	shr        r11d, 8
	mov        eax, r11d
	test       si, si                 ; if (strType != 0)
	jnz        .cidrSuffix

.fourthOctet:
	xor        r9b, r9b               ; '\0'
	call       convertOctetToString
	jmp        .epilogue

.cidrSuffix:
	mov        r9b, 0x2F              ; '/'
	call       convertOctetToString

	mov        eax, [rdi + 4]         ; uint32_t cidrSuffix = ipv4Address->[rdi + 4]
	xor        r9b, r9b               ; '\0'
	call       convertOctetToString

.epilogue:                            ; functions typically have an epilogue
	ret                               ; pop return address from stack and jump there

; ════════════════════════════ Private Functions ═════════════════════════════

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
	shl        rcx, 8                 ; cl register buffer = ah
	mov        cl, ah
	inc        r8b

.lessThan10:
	add        al, ZERO               ; quotient += '0'
	shl        rcx, 8                 ; cl register buffer = al
	mov        cl, al
	inc        r8b

	mov        [rdx], ecx
	add        rdx, r8
	xor        r8b, r8b

	ret                               ; pop return address from stack and jump there

;
; getHextetValue.asm - DevOpsBroker NASM file for the getHextetValue function
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
; Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-38
;
; uint16_t b7808f25_getHextetValue(char **ipAddress);
; -----------------------------------------------------------------------------
;

; ════════════════════════════ Include Directives ════════════════════════════


; ═══════════════════════════════ Preprocessor ═══════════════════════════════

%define ZERO      0x30
%define NINE      0x39
%define LOWER_A   0x61
%define LOWER_F   0x66
%define UPPER_W   0x57

; ═════════════════════════════ Initialized Data ═════════════════════════════

;	seciton .data           ; DX directives

; ════════════════════════════ Uninitialized Data ════════════════════════════

;	seciton .bss            ; RESX directives

; ══════════════════════════════ Assembly Code ═══════════════════════════════

	global  b7808f25_getHextetValue:function
	extern  a25c96b2_invalidIPv6Address
	section .text
b7808f25_getHextetValue:
;	rdi : char **ipAddress

.prologue:                            ; functions typically have a prologue
	mov        rsi, [rdi]             ; char *source = *ipAddress
	movzx      edx, byte [rsi]        ; uint32_t ch = *source
	xor        eax, eax               ; value = 0
	xor        ecx, ecx               ; numChars = 0

.LIF0:                                ; if (ch >= '0' && ch <= '9')
	cmp        edx, ZERO
	jb         .invalidIPAddress      ; Error if character less than zero
	cmp        edx, NINE
	ja         .LIF1                  ; Evaluate for hexadecimal character
	sub        edx, ZERO              ; digit = ch - '0'
	jmp        .modifyValue           ; Modify the value with digit

.invalidIPAddress:
	sub        rsp, 8                 ; Re-align stack frame before making call
	mov        rdi, [rdi]             ; Pass *ipAddress as parameter
	call       a25c96b2_invalidIPv6Address

.LIF1:
	or         edx, 0x20              ; ch |= 0x20
	cmp        edx, LOWER_A
	jb         .invalidIPAddress      ; Error if character less than lowercase 'a'
	cmp        edx, LOWER_F
	ja         .invalidIPAddress      ; Error if character greater than lowercase 'f'
	sub        edx, UPPER_W           ; digit = ch - 'a' + 10

.modifyValue:
	shl        eax, 4                 ; value <<= 4
	or         eax, edx               ; value += digit
	inc        ecx                    ; numChars++

	inc        rsi                    ; source++
	movzx      edx, byte [rsi]        ; ch = *source

	; while (ch && ch != ':' && ch != '/' && numChars < 4)
	cmp        edx, 0x3A              ; ':'
	je         .incrementSource
	test       edx, edx               ; '\0'
	jz         .epilogue
	cmp        edx, 0x2F              ; '/'
	je         .epilogue
	cmp        ecx, 4
	jne short  .LIF0
	jmp short  .invalidIPAddress      ; Error if we already processed four characters

.incrementSource:
	inc        rsi                    ; source++

.epilogue:                            ; functions typically have an epilogue
	mov        [rdi], rsi             ; update *ipAddress value
	ret                               ; pop return address from stack and jump there

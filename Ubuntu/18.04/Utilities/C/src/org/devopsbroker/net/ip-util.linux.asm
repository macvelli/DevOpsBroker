;
; ip-util.linux.asm - DevOpsBroker NASM file for the IP-related utility functions
;
; Copyright (C) 2018-2019 Edward Smith <edwardsmith@devopsbroker.org>
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
; This file implements the following x86-64 assembly language functions for the
; org.devopsbroker.net.ip-util.h header file:
;
;   o int a25c96b2_detectIPType(const char *ipAddress);
; -----------------------------------------------------------------------------
;

; ════════════════════════════ Include Directives ════════════════════════════


; ═══════════════════════════════ Preprocessor ═══════════════════════════════

; character values
%define DECIMAL   0x2E
%define COLON     0x3A
%define LOWER_A   0x61
%define LOWER_F   0x66

%define ERROR_CODE  -1

; ═════════════════════════════ Initialized Data ═════════════════════════════

;	section .data           ; DX directives

; ════════════════════════════ Uninitialized Data ════════════════════════════

;	section .bss            ; RESX directives

; ══════════════════════════════ Assembly Code ═══════════════════════════════

	global  a25c96b2_detectIPType:function
	section .text
a25c96b2_detectIPType:
; Parameters:
;	rdi : char *ipAddress

.prologue:                            ; functions typically have a prologue
	mov        rcx, [rdi]             ; put first eight characters into rcx
	mov        ah, 5                  ; loop counter = 5
	mov        al, DECIMAL            ; al = '.'
	mov        dl, COLON              ; dl = ':'

	test       cl, cl                 ; if (ch == '\0')
	jz short   .invalidIPAddress

.LWHILE0:                             ; while (ch)
	cmp        cl, al                 ; if (ch == '.')
	jne short  .isIPv6Address
	mov        eax, 4
	ret                               ; Detected an IPv4 Address

.isIPv6Address:
	cmp        cl, dl                 ; if (ch == ':')
	jne        .LIF1
	mov        eax, 6
	ret                               ; Detected an IPv6 Address

.LIF1:
	or         cl, 0x20              ; ch |= 0x20
	cmp        cl, LOWER_F           ; if (ch > 'f')
	jg short   .invalidIPAddress
	cmp        cl, LOWER_A           ; if (ch < 'a')
	jl         .nextChar
	mov        eax, 6
	ret                               ; Detected an IPv6 Address

.nextChar:
	shr        rcx, 8                 ; shift to the next character
	dec        ah                     ; loopCounter--

	; while (ch && loopCounter > 0)
	test       ah, ah
	jz short   .invalidIPAddress
	test       cl, cl                 ; if (ch == '\0')
	jnz        .LWHILE0
	; Error if we already processed five characters

.invalidIPAddress:
	mov        eax, ERROR_CODE        ; Set return value to ERROR_CODE
	ret                               ; pop return address from stack and jump there

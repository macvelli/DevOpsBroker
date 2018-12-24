;
; detectIPType.asm - DevOpsBroker NASM file for the detectIPType function
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
; int a25c96b2_detectIPType(const char *ipAddress);
; -----------------------------------------------------------------------------
;

; ════════════════════════════ Include Directives ════════════════════════════


; ═══════════════════════════════ Preprocessor ═══════════════════════════════

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
;	rdi : char *ipAddress

.prologue:                            ; functions typically have a prologue
	movzx      esi, byte [rdi]        ; int ch = *ipAddress
	xor        edx, edx               ; numChars = 0

	test       esi, esi               ; '\0'
	jz short   .invalidIPAddress

.LWHILE0:                             ; while (ch)
	cmp        esi, 0x2E              ; '.'
	jne        .LIF0
	mov        eax, 4
	ret                               ; Detected an IPv4 Address

.LIF0:
	cmp        esi, 0x3A              ; ':'
	jne        .LIF1
	mov        eax, 6
	ret                               ; Detected an IPv6 Address

.LIF1:
	or         esi, 0x20              ; ch |= 0x20
	cmp        esi, LOWER_A
	jl         .nextChar
	cmp        esi, LOWER_F
	jg         .nextChar
	mov        eax, 6
	ret                               ; Detected an IPv6 Address

.nextChar:
	inc        rdi                    ; ipAddress++
	movzx      esi, byte [rdi]        ; ch = *ipAddress
	inc        edx                    ; numChars++

	; while (ch && numChars < 5)
	test       esi, esi               ; '\0'
	jz         .invalidIPAddress
	cmp        edx, 5
	jne short  .LWHILE0
	; Error if we already processed five characters

.invalidIPAddress:
	mov        eax, ERROR_CODE        ; Set return value to ERROR_CODE

.epilogue:                            ; functions typically have an epilogue
	ret                               ; pop return address from stack and jump there

;
; getCIDRSuffix.asm - DevOpsBroker NASM file for the getCIDRSuffix function
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
; int a25c96b2_getCIDRSuffix(const char *ipAddress, const int maxValue);
; -----------------------------------------------------------------------------
;

; ════════════════════════════ Include Directives ════════════════════════════


; ═══════════════════════════════ Preprocessor ═══════════════════════════════

%define ZERO      0x30
%define NINE      0x39

%define ERROR_CODE  -1

; ═════════════════════════════ Initialized Data ═════════════════════════════

;	seciton .data           ; DX directives

; ════════════════════════════ Uninitialized Data ════════════════════════════

;	seciton .bss            ; RESX directives

; ══════════════════════════════ Assembly Code ═══════════════════════════════

	global  a25c96b2_getCIDRSuffix:function
	section .text
a25c96b2_getCIDRSuffix:
;	rdi : char *ipAddress
;	esi : int maxValue

.prologue:                            ; functions typically have a prologue
	movzx      edx, byte [rdi]        ; int ch = *ipAddress
	xor        eax, eax               ; value = 0
	xor        ecx, ecx               ; numChars = 0

.LIF0:                                ; if (ch < '0' || ch > '9')
	cmp        edx, NINE
	jg         .invalidCIDRSuffix     ; Error if character greater than nine
	sub        edx, ZERO
	jl         .invalidCIDRSuffix     ; Error if character less than zero

.modifyValue:
	lea        eax, [eax+eax*4]       ; value = (value * 10) + digit
	lea        eax, [edx+eax*2]

	cmp        eax, esi               ; Error if value greater than maxValue
	jg         .invalidCIDRSuffix
	inc        ecx                    ; numChars++

	inc        rdi                    ; ipAddress++
	movzx      edx, byte [rdi]        ; ch = *ipAddress

	; while (ch && numChars < 3)
	test       edx, edx               ; '\0'
	jz         .epilogue
	cmp        ecx, 3                 ; Error if we already processed three characters
	jne short  .LIF0

.invalidCIDRSuffix:
	mov        eax, ERROR_CODE        ; Set return value to ERROR_CODE

.epilogue:                            ; functions typically have an epilogue
	ret                               ; pop return address from stack and jump there

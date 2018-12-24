;
; getOctetValue.asm - DevOpsBroker NASM file for the getOctetValue function
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
; int a25c96b2_getOctetValue(char **ipAddress);
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

	global  a25c96b2_getOctetValue:function
	section .text
a25c96b2_getOctetValue:
;	rdi : char **ipAddress

.prologue:                            ; functions typically have a prologue
	mov        rsi, [rdi]             ; char *source = *ipAddress
	movzx      edx, byte [rsi]        ; uint32_t ch = *source
	xor        eax, eax               ; value = 0
	xor        ecx, ecx               ; numChars = 0

.LIF0:                                ; if (ch < '0' || ch > '9')
	cmp        edx, NINE
	jg         .invalidIPAddress      ; Error if character greater than nine
	sub        edx, ZERO
	jl         .invalidIPAddress      ; Error if character less than zero

.modifyValue:
	lea        eax, [eax+eax*4]       ; value = (value * 10) + digit
	lea        eax, [edx+eax*2]

	cmp        eax, 0xff              ; Error if value greater than 255
	jg         .invalidIPAddress
	inc        ecx                    ; numChars++

	inc        rsi                    ; source++
	movzx      edx, byte [rsi]        ; ch = *source

	; while (ch && ch != '.' && ch != '/' && numChars < 3)
	cmp        edx, 0x2E              ; '.'
	je         .incrementSource
	test       edx, edx               ; '\0'
	jz         .epilogue
	cmp        edx, 0x2F              ; '/'
	je         .epilogue
	cmp        ecx, 3
	jne short  .LIF0
	; Error if we already processed three characters

.invalidIPAddress:
	mov        eax, ERROR_CODE        ; Set return value to ERROR_CODE
	ret                               ; pop return address from stack and jump there

.incrementSource:
	inc        rsi                    ; source++

.epilogue:                            ; functions typically have an epilogue
	mov        [rdi], rsi             ; update *ipAddress value
	ret                               ; pop return address from stack and jump there

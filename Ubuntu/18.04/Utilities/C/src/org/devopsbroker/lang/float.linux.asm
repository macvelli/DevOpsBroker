;
; float.linux.asm - DevOpsBroker NASM file for float-related functionality
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
; Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-44
;
; This file implements the following x86-64 assembly language functions for the
; org.devopsbroker.lang.float.h header file:
;
;   o float b08dcfcc_parseFloat(const char *source);
; -----------------------------------------------------------------------------
;

; ════════════════════════════ Include Directives ════════════════════════════


; ═══════════════════════════════ Preprocessor ═══════════════════════════════

; character values
%define NEGATIVE    0x2D
%define DECIMAL     0x2E
%define ZERO        0x30
%define NINE        0x39

; float Values
%define TEN         0x41200000        ; 10.0f
%define NAN         0x7fc00000        ; NaN

; ═════════════════════════════ Initialized Data ═════════════════════════════

section .data               ; DX directives

; ════════════════════════════ Uninitialized Data ════════════════════════════

section .bss                ; RESX directives

; ══════════════════════════════ Assembly Code ═══════════════════════════════

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~ b08dcfcc_parseFloat ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  b08dcfcc_parseFloat:function
	section .text
b08dcfcc_parseFloat:
; Parameters:
;	rdi : char *source
; Local Variables:
;	ax   : numChars(ah), isNegative(al)
;	dx   : maxChars(dh), '.'(dl)
;	rcx  : 64-bit character buffer
;	r8d  : transient storage variable
;	xmm0 : function return value
;	xmm1 : calculation register
;	xmm2 : constant value / magnitude
;	xmm3 : constant value

.prologue:                            ; functions typically have a prologue
	mov        rcx, [rdi]             ; put first eight characters into rcx
	xor        ax, ax                 ; numChars(ah) = 0, isNegative(al) = false
	pxor       xmm0, xmm0             ; value = 0

	mov        edx, TEN
	movd       xmm2, edx
	mov        dh, 8                  ; dh = maximum number of characters
	mov        dl, DECIMAL            ; dl = '.'

	cmp        cl, NEGATIVE           ; if (ch == '-')
	jne        .positiveFloat

	mov        al, cl                 ; isNegative = true
	inc        ah                     ; numChars++
	shr        rcx, 8                 ; shift to the next character

.positiveFloat:

	test       cl, cl
	jz         .invalidFloat

	cmp        cl, dl                 ; if (ch == '.')
	je         .processDecimal

	; Calculate the integer portion of the float
.whileInteger:
	cmp        cl, NINE
	jg         .invalidFloat          ; Error if character greater than nine
	sub        cl, ZERO
	jl         .invalidFloat          ; Error if character less than zero

	mulss      xmm0, xmm2             ; value = (value * 10) + digit
	movzx      r8d, cl
	cvtsi2ss   xmm1, r8d
	addss      xmm0, xmm1

	inc        ah                     ; numChars++
	shr        rcx, 8                 ; shift to the next character

	; while (ch && ch != '.' && numChars < 8)
	cmp        cl, dl                 ; if (ch == '.')
	je         .processDecimal
	test       cl, cl                 ; if (ch == '\0')
	jz         .epilogue
	cmp        ah, dh                 ; if (numChars == 8)
	jne        .whileInteger
	; Error if we already processed eight characters

.invalidFloat:
	mov        eax, NAN               ; Set return value to NaN
	movd       xmm0, eax
	ret                               ; pop return address from stack and jump there

.processDecimal:
	inc        ah                     ; numChars++

	cmp        ah, dh                 ; if (numChars == 8)
	je         .invalidFloat

	shr        rcx, 8                 ; shift to the next character
	movss      xmm3, xmm2             ; xmm3 = 10

	; Calculate the decimal portion of the float
.whileDecimal:
	cmp        cl, NINE
	jg         .invalidFloat          ; Error if character greater than nine
	sub        cl, ZERO
	jl         .invalidFloat          ; Error if character less than zero

	movzx      r8d, cl                ; value += (digit / magnitude)
	cvtsi2ss   xmm1, r8d
	divss      xmm1, xmm2
	addss      xmm0, xmm1
	mulss      xmm2, xmm3             ; magnitude *= 10

	inc        ah                     ; numChars++
	shr        rcx, 8                 ; shift to the next character

	; while (ch && ch != '.' && numChars < 8)
	test       cl, cl                 ; if (ch == '\0')
	jz         .epilogue
	cmp        ah, dh                 ; if (numChars == 8)
	jne        .whileDecimal
	; Return if we already processed eight characters

.epilogue:                            ; functions typically have an epilogue
	ret                               ; pop return address from stack and jump there

;
; cpuid.linux.asm - DevOpsBroker NASM file for CPUID-related functionality
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
; Developed on Ubuntu 18.04.2 LTS running kernel.osrelease = 4.18.0-15
;
; This file implements the following x86-64 assembly language functions for the
; org.devopsbroker.info.cpuid.h header file:
;
;   o void f618482d_getProcessorInfo(CPUID *cpuid);
;   o void f618482d_getVendorID(CPUID *cpuid);
; -----------------------------------------------------------------------------
;

; ════════════════════════════ Include Directives ════════════════════════════


; ═══════════════════════════════ Preprocessor ═══════════════════════════════

; CPUID Leaf Codes
%define VENDOR_ID    0x00
%define PROC_INFO    0x01

; ═════════════════════════════ Initialized Data ═════════════════════════════

section .data               ; DX directives

; ════════════════════════════ Uninitialized Data ════════════════════════════

section .bss                ; RESX directives

; ══════════════════════════════ Assembly Code ═══════════════════════════════

; ~~~~~~~~~~~~~~~~~ f618482d_getProcessorInfo  (using SSE2) ~~~~~~~~~~~~~~~~~~

	global  f618482d_getProcessorInfo:function
	section .text
f618482d_getProcessorInfo:
; Parameters:
;	rdi : CPUID *cpuid
; Local Variables:
;	eax : information category
;	ebx : additional feature information
;	edx : feature information bits 0-31
;	ecx : feature information bits 32-61
;	rsi : preserve rbx value

.prologue:                            ; functions typically have a prologue
	mov        eax, PROC_INFO         ; retrieve processor information and feature flags
	mov        rsi, rbx               ; preserve rbx value in rsi

.processorInfo:
	cpuid

.featureFlags:
	xor        eax, eax
	mov        al, dl
	mov        ah, dl

	movd       xmm0, eax
	pshuflw    xmm0, xmm0, 0b

	mov        al, dh
	mov        ah, dh

	movd       xmm1, eax
	pshuflw    xmm1, xmm1, 0b
	movlhps    xmm0, xmm1

	mov        rax, 0x8040201008040201
	movq       xmm2, rax
	movlhps    xmm2, xmm2

	mov        rax, 0x0101010101010101
	movq       xmm3, rax
	movlhps    xmm3, xmm3

	pxor       xmm4, xmm4
	pand       xmm0, xmm2
	pcmpeqb    xmm0, xmm4
	pandn      xmm0, xmm3

	movdqa     [rdi+32], xmm0

	shr        edx, 16
	mov        al, dl
	mov        ah, dl

	movd       xmm0, eax
	pshuflw    xmm0, xmm0, 0b

	mov        al, dh
	mov        ah, dh

	movd       xmm1, eax
	pshuflw    xmm1, xmm1, 0b
	movlhps    xmm0, xmm1

	pand       xmm0, xmm2
	pcmpeqb    xmm0, xmm4
	pandn      xmm0, xmm3

	movdqa     [rdi+48], xmm0

	mov        al, cl
	mov        ah, cl

	movd       xmm0, eax
	pshuflw    xmm0, xmm0, 0b

	mov        al, ch
	mov        ah, ch

	movd       xmm1, eax
	pshuflw    xmm1, xmm1, 0b
	movlhps    xmm0, xmm1

	pand       xmm0, xmm2
	pcmpeqb    xmm0, xmm4
	pandn      xmm0, xmm3

	movdqa     [rdi+64], xmm0

	shr        ecx, 16
	mov        al, cl
	mov        ah, cl

	movd       xmm0, eax
	pshuflw    xmm0, xmm0, 0b

	mov        al, ch
	mov        ah, ch

	movd       xmm1, eax
	pshuflw    xmm1, xmm1, 0b
	movlhps    xmm0, xmm1

	pand       xmm0, xmm2
	pcmpeqb    xmm0, xmm4
	pandn      xmm0, xmm3

	movdqa     [rdi+80], xmm0

.epilogue:                            ; functions typically have an epilogue
	mov        rbx, rsi               ; restore rbx value from rsi
	ret                               ; pop return address from stack and jump there

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~ f618482d_getVendorID ~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  f618482d_getVendorID:function
	section .text0x2000000000
f618482d_getVendorID:
; Parameters:
;	rdi : CPUID *cpuid
; Local Variables:
;	eax : information category
;	ebx : first four characters of vendor ID
;	edx : next four characters of vendor ID
;	ecx : last four characters of vendor ID
;	rsi : preserve rbx value

.prologue:                            ; functions typically have a prologue
	mov        eax, VENDOR_ID         ; retrieve Vendor ID
	mov        rsi, rbx               ; preserve rbx value in rsi
	xor        rcx, rcx               ; rcx = 0

.vendorId:
	cpuid

	shl        rdx, 32
	or         rbx, rdx

	mov        [rdi], rbx             ; populate cpuid->vendorId[] string
	mov        [rdi+8], rcx
	mov        [rdi+16], eax          ; cpuid->maxCpuIdLevel = eax

.epilogue:                            ; functions typically have an epilogue
	mov        rbx, rsi               ; restore rbx value from rsi
	ret                               ; pop return address from stack and jump there

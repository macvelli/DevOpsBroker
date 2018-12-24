;
; memory.linux.asm - DevOpsBroker NASM file for memory-related functionality
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
; Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-42
;
; This file implements the following x86-64 assembly language functions for the
; org.devopsbroker.lang.memory.h header file:
;
;   o void f668c4bd_meminit(void *ptr, size_t size);
;   o void f668c4bd_memcopy(void *source, void *dest, size_t numBytes);
; -----------------------------------------------------------------------------
;

; ════════════════════════════ Include Directives ════════════════════════════


; ═══════════════════════════════ Preprocessor ═══════════════════════════════


; ═════════════════════════════ Initialized Data ═════════════════════════════

section .data               ; DX directives

; ════════════════════════════ Uninitialized Data ════════════════════════════

section .bss                ; RESX directives

; ══════════════════════════════ Assembly Code ═══════════════════════════════

	global  f668c4bd_meminit
	section .text
f668c4bd_meminit:

.prologue:                            ; functions typically have a prologue
	xor        rax, rax               ; zero out rax for memory initialization

	cmp        rsi, 0x08
	jae        .eightBytes
	cmp        sil, 0x04
	jae        .fourBytes
	jnz        .bytes
	jz         .epilogue

.eightBytes:
	mov        [rdi], rax

	sub        rsi, 0x08
	jz         .epilogue

	add        rdi, 0x08

	cmp        rsi, 0x08
	jae        .eightBytes
	cmp        sil, 0x04
	jb         .bytes

.fourBytes:
	mov        [rdi], eax

	sub        sil, 0x04
	jz         .epilogue

	add        rdi, 0x04

.bytes:
	mov        [rdi], al
	inc        rdi
	dec        sil

	jnz        .bytes

.epilogue:                            ; functions typically have an epilogue
	ret                               ; pop return address from stack and jump there

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ f668c4bd_memcopy ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  f668c4bd_memcopy
	section .text
f668c4bd_memcopy:

.prologue:                            ; functions typically have a prologue
	cmp        rdx, 0x08
	jae        .eightBytes
	cmp        dl, 0x04
	jae        .fourBytes
	jnz        .bytes
	jz         .epilogue

.eightBytes:
	mov        rcx, [rdi]
	mov        [rsi], rcx

	sub        rdx, 0x08
	jz         .epilogue

	add        rdi, 0x08
	add        rsi, 0x08

	cmp        rdx, 0x08
	jae        .eightBytes
	cmp        dl, 0x04
	jb         .bytes

.fourBytes:
	mov        ecx, [rdi]
	mov        [rsi], ecx

	sub        sil, 0x04
	jz         .epilogue

	add        rdi, 0x04
	add        rsi, 0x04

.bytes:
	mov        cl, [rdi]
	mov        [rsi], cl

	inc        rdi
	inc        rsi
	dec        cl

	jnz        .bytes

.epilogue:                            ; functions typically have an epilogue
	ret                               ; pop return address from stack and jump there

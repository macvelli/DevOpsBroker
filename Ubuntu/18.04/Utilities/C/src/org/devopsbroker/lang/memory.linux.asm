;
; memory.linux.asm - DevOpsBroker NASM file for memory-related functionality
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
; Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-42
;
; This file implements the following x86-64 assembly language functions for the
; org.devopsbroker.lang.memory.h header file:
;
;   o void *f668c4bd_malloc(size_t size);
;   o void f668c4bd_memcopy(void *source, void *dest, size_t numBytes);
;   o void f668c4bd_meminit(void *ptr, size_t size);
;   o void *f668c4bd_realloc(void *ptr, size_t origSize, size_t newSize);
; -----------------------------------------------------------------------------
;

; ════════════════════════════ Include Directives ════════════════════════════


; ═══════════════════════════════ Preprocessor ═══════════════════════════════


; ═════════════════════════════ Initialized Data ═════════════════════════════

section .data               ; DX directives

; ════════════════════════════ Uninitialized Data ════════════════════════════

section .bss                ; RESX directives

; ══════════════════════════════ Assembly Code ═══════════════════════════════

	section .text

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ External Resources ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

extern  malloc
extern  free
extern  abort

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ f668c4bd_malloc ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  f668c4bd_malloc:function
f668c4bd_malloc:
; Parameters:
;	rdi : size_t size
; Local Variables:
;	rax : void *ptr

.prologue:                            ; functions typically have a prologue
	add        rdi, 0x0F              ; size = ((size + 15) / 16) * 16
	shr        rdi, 4
	shl        rdi, 4

.malloc:
	sub        rsp, 8                 ; align stack frame before calling malloc()
	call       malloc WRT ..plt

	test       rax, rax               ; if (ptr == NULL)
	je         .fatalError

.epilogue:                            ; functions typically have an epilogue
	add        rsp, 8                 ; re-align stack frame before return
	ret                               ; pop return address from stack and jump there

.fatalError:
	call       abort WRT ..plt

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ f668c4bd_memcopy ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  f668c4bd_memcopy:function
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

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ f668c4bd_meminit ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  f668c4bd_meminit:function
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

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ f668c4bd_realloc ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  f668c4bd_realloc:function
f668c4bd_realloc:
; Parameters:
;	rdi : void *ptr
;	rsi : size_t origSize
;	rdx : size_t newSize
; Local Variables:
;	rax : void *newPtr

.prologue:                            ; functions typically have a prologue
	mov        eax, 0x0F              ; rax = 15

.align:
	add        rsi, rax               ; origSize = ((origSize + 15) / 16) * 16
	add        rdx, rax               ; newSize = ((newSize + 15) / 16) * 16

	shr        rsi, 4
	shr        rdx, 4

	shl        rsi, 4
	shl        rdx, 4

.malloc:
	cmp        rsi, rdx               ; if (origSize > newSize)
	ja         .fatalError

	push       rdi                    ; save void *ptr
	push       rsi                    ; save size_t origSize
	sub        rsp, 8                 ; align stack frame before calling malloc()

	mov        rdi, rax               ; set size parameter for malloc() call
	call       malloc WRT ..plt

	test       rax, rax               ; if (ptr == NULL)
	je         .fatalError

	add        rsp, 8
	pop        rsi                    ; retrieve size_t origSize
	pop        rdi                    ; retrieve void *ptr
	push       rax                    ; save void *newPtr

.copy:
	prefetcht0 [rdi]                  ; prefetch the pointer data into the CPU cache
	mov        rcx, rdi               ; save void *ptr
	shl        rsi, 4                 ; rsi = numCopies
	mov        edx, 0x10              ; rdx = 16

.whileData:
	movdqa     xmm0, [rdi]            ; newPtr[data] = ptr[data]
	movdqa     [rax], xmm0

	dec        rsi                    ; numCopies--
	test       rsi, rsi               ; if (numCopies == 0)
	jz         .free

	add        rdi, rdx               ; ptr += 16
	add        rax, rdx               ; newPtr += 16
	jmp        .whileData

.free:
	mov        rdi, rcx               ; set ptr parameter for free() call
	call       free WRT ..plt

.epilogue:                            ; functions typically have an epilogue
	pop        rax                    ; retrieve void *newPtr
	ret                               ; pop return address from stack and jump there

.fatalError:
	call       abort WRT ..plt

; ═════════════════════════════ Private Routines ═════════════════════════════

;
; listarray.linux.asm - DevOpsBroker NASM file for the ListArray struct
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
; Developed on Ubuntu 18.04.2 LTS running kernel.osrelease = 4.18.0-16
;
; This file defines the following x86-64 assembly language functions for the
; ListArray struct:
;
;   o void b196167f_add(ListArray *listArray, void *element);
;   o void b196167f_destroyAllElements(ListArray *listArray);
;   o void b196167f_initListArray(ListArray *listArray);
; -----------------------------------------------------------------------------
;

; ════════════════════════════ Include Directives ════════════════════════════


; ═══════════════════════════════ Preprocessor ═══════════════════════════════

; Constants
%define DEFAULT_SIZE   0x08
%define MALLOC_SIZE    0x40

; ═════════════════════════════ Initialized Data ═════════════════════════════

section .data               ; DX directives

; ════════════════════════════ Uninitialized Data ════════════════════════════

section .bss                ; RESX directives

; ══════════════════════════════ Assembly Code ═══════════════════════════════

	section .text

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ External Resources ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

extern  reallocarray
extern  malloc
extern  free
extern  abort

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ b196167f_add ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  b196167f_add:function
b196167f_add:
; Parameters:
;	rdi : ListArray *listArray
;	rsi : void *element
; Local Variables:
;	rdx : listArray->values
;	ecx : listArray->length
;	r8d : listArray->size

.prologue:                            ; functions typically have a prologue
	mov        rdx, [rdi]             ; load listArray->values into rdx
	mov        ecx, [rdi+8]           ; load listArray->length into ecx
	mov        r8d, [rdi+12]          ; load listArray->size into r8d

.shouldWeResize:
	lea        r10, [rel .addElement]
	cmp        ecx, r8d               ; if (listArray->length == listArray->size)
	je         resizeArray

.addElement:
	mov        [rdx + rcx*8], rsi     ; save element into values[length]
	inc        ecx                    ; length++

.epilogue:                            ; functions typically have an epilogue
	mov        [rdi+8], ecx           ; save listArray->length
	ret                               ; pop return address from stack and jump there

; ~~~~~~~~~~~~~~~~~~~~~~~ b196167f_destroyAllElements ~~~~~~~~~~~~~~~~~~~~~~~~

	global  b196167f_destroyAllElements:function
b196167f_destroyAllElements:
; Parameters:
;	rdi : ListArray *listArray
; Local Variables:
;	rsi : listArray->values
;	rdx : listArray->length

.prologue:                            ; functions typically have a prologue
	mov        rsi, [rdi]             ; load listArray->values into rsi
	mov        edx, [rdi+8]           ; load listArray->length into edx

	test       edx, edx               ; if (listArray->length == 0)
	jz         .emptyListArray

	sub        rsp, 8                 ; align stack frame before calling free()

.whileData:
	lodsq                             ; load quadword from listArray->values
	dec        edx                    ; listArray->length--

.free:                                ; free(listArray->values[i])
	push       rsi                    ; save listArray->values
	push       rdx                    ; save listArray->length

	mov        rdi, rax
	call       free WRT ..plt

	pop        rdx                    ; retrieve listArray->length
	pop        rsi                    ; retrieve listArray->values

	test       edx, edx               ; if (listArray->length != 0)
	jnz        .whileData

.epilogue:
	add        rsp, 8                 ; unalign stack frame after calling free()
	mov        [rdi+8], edx           ; save listArray->length
	ret                               ; pop return address from stack and jump there

.emptyListArray:
	ret                               ; pop return address from stack and jump there

; ~~~~~~~~~~~~~~~~~~~~~~~~~~ b196167f_initListArray ~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  b196167f_initListArray:function
b196167f_initListArray:
; Parameters:
;	rdi : ListArray *listArray

.prologue:                            ; functions typically have a prologue
	push       rdi                    ; save ListArray *listArray

.malloc:                              ; malloc(sizeof(void*) * DEFAULT_SIZE)
	mov        rdi, MALLOC_SIZE
	call       malloc WRT ..plt

	test       rax, rax               ; if (ptr == NULL)
	jz         .fatalError
	pop        rdi                    ; retrieve ListArray *listArray

.initListArray:
	mov        [rdi], rax                     ; listArray->values
	mov        [rdi+8], dword 0x00            ; listArray->length = 0
	mov        [rdi+12], dword DEFAULT_SIZE   ; listArray->size = 8

.epilogue:                            ; functions typically have an epilogue
	ret                               ; pop return address from stack and jump there

.fatalError:
	call       abort WRT ..plt

; ═════════════════════════════ Private Routines ═════════════════════════════

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ resizeArray ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

resizeArray:
; Parameters:
;	rdi : ListArray *listArray
;	rsi : void *element
; Local Variables:
;	rdx : listArray->values
;	ecx : listArray->length
;	r8d : listArray->size

	prefetcht0 [rdx]                  ; prefetch the values array elements into the CPU cache
	shl        r8d, 1                 ; listArray->size *= 2

	push       rsi                    ; save void *element
	push       rdi                    ; save ListArray *listArray
	push       r10                    ; save return address

	mov        rdi, rdx               ; reallocarray(values, size, 8)
	mov        rsi, r8
	mov        edx, 0x08
	call       reallocarray WRT ..plt

	test       rax, rax               ; if (ptr == NULL)
	jz         .fatalError

	pop        r10                    ; retrieve return address
	pop        rdi                    ; retrieve ListArray *listArray
	pop        rsi                    ; retrieve void *element

.epilogue:
	mov        ecx, [rdi+8]           ; load listArray->length
	mov        [rdi], rax             ; store listArray->values
	mov        rdx, rax               ; rdx = newPtr
	jmp        r10                    ; jump to the return address

.fatalError:
	call       abort WRT ..plt

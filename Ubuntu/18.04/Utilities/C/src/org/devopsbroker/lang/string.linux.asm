;
; string.linux.asm - DevOpsBroker NASM file for string-related functionality
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
; This file implements the following x86-64 assembly language functions for the
; org.devopsbroker.lang.string.h header file:
;
;   o char *f6215943_copy(char *source, uint32_t length);
;   o char *f6215943_trim(char *string);
; -----------------------------------------------------------------------------
;

; ════════════════════════════ Include Directives ════════════════════════════


; ═══════════════════════════════ Preprocessor ═══════════════════════════════

; character values
%define TAB     0x09
%define SPACE   0x20

; ═════════════════════════════ Initialized Data ═════════════════════════════

section .data               ; DX directives

; ════════════════════════════ Uninitialized Data ════════════════════════════

section .bss                ; RESX directives

; ══════════════════════════════ Assembly Code ═══════════════════════════════

	section .text

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ External Resources ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

extern  malloc
extern  abort

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ f6215943_copy ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  f6215943_copy:function
f6215943_copy:
; Parameters:
;	rdi : char *source
;	rsi : uint32_t length
; Local Variables:
;	rdi : char *destination
;	rsi : char *source
;	edx : uint32_t length
;	ecx : count register for repeat instruction

.prologue:                            ; functions typically have a prologue
	test       esi, esi               ; if (length == 0)
	jz         .epilogue

.malloc:
	push       rdi                    ; save char *source
	push       rsi                    ; save uint32_t length
	sub        rsp, 8                 ; align stack frame before calling malloc()

	mov        rdi, rsi               ; malloc(length+1)
	inc        rdi
	call       malloc WRT ..plt

	test       rax, rax               ; if (ptr == NULL)
	je         .fatalError

	add        rsp, 8                 ; unalign stack frame after calling malloc()
	pop        rdx                    ; retrieve uint32_t length
	pop        rsi                    ; retrieve char *source

.copyString:
	mov        rdi, rax               ; rdi = char *destination
	cld                               ; clear direction flag in EFLAGS register

	cmp        edx, 0x08              ; if (length < 8)
	jb         .copyBytes

.copyEightBytes:
	mov        ecx, edx               ; calculate how many eight byte chunks to copy
	shr        ecx, 3                 ; ecx = length / 8
	mov        r8d, ecx
	shl        r8d, 3
	sub        edx, r8d               ; edx = length % 8

	rep movsq                         ; move ecx quadwords from char *source to char *destination

	test       edx, edx
	jz         .epilogue

.copyBytes:
	mov        ecx, edx
	rep movsb                         ; move ecx bytes from char *source to char *destination

.epilogue:
	mov        [rdi+1], byte 0x00     ; terminate char *destination
	ret                               ; pop return address from stack and jump there

.fatalError:
	call       abort WRT ..plt

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ f6215943_trim ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  f6215943_trim:function
f6215943_trim:
; Parameters:
;	rdi : char *string
; Local Variables:
;	rsi : 64-bit character buffer
;	dx  : dl = bufSize, dh = 8
;	rcx : last character position

.prologue:                            ; functions typically have a prologue
	prefetcht0 [rdi]                  ; prefetch the string into the CPU cache
	mov        rsi, [rdi]             ; put first eight characters into rsi
	mov        rax, rdi               ; rax = char *string
	mov        dx, 0x0808             ; dh = 8, bufSize = 8

.whileSpace:
	test       sil, sil               ; if (ch == '\0')
	jz         .emptyString

.isLeadingSpace:
	cmp        sil, SPACE             ; if (ch == ' ')
	je         .manageCharBufferOne

	cmp        sil, TAB               ; if (ch == '\t')
	jne        .findLastCharacter

.manageCharBufferOne:
	; get next character
	lea        r10, [rel .whileSpace]
	jmp short  getNextCharacter

.findLastCharacter:
	mov        rax, rdi               ; rax = current value of rdi
	mov        rcx, rdi               ; lastCharPos = current value of rdi

.whileString:
	test       sil, sil               ; if (ch == '\0')
	jz         .epilogue

.isTrailingSpace:
	cmp        sil, SPACE             ; if (ch == ' ')
	je         .manageCharBufferTwo

	cmp        sil, TAB               ; if (ch == '\t')
	je         .manageCharBufferTwo

	mov        rcx, rdi               ; lastCharPos = current value of rdi

.manageCharBufferTwo:
	; get next character
	lea        r10, [rel .whileString]
	jmp short  getNextCharacter

.epilogue:                            ; functions typically have an epilogue
	inc        rcx                    ; increment lastCharPos
	cmp        rcx, rdi               ; if (lastCharPos == rdi)
	je         .return

	mov        [rcx], byte 0x00       ; set lastCharPos to '\0'

.return:
	ret                               ; pop return address from stack and jump there

.emptyString:
	mov        rax, rdi               ; return current position of rdi
	ret                               ; pop return address from stack and jump there

; ═════════════════════════════ Private Routines ═════════════════════════════

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ getNextCharacter ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

getNextCharacter:
; Parameters:
;	rdi : char *ipAddress
;	rsi : 64-bit char buffer
;	dx  : dl = bufSize, dh = 8

	shr        rsi, 8                 ; shift to the next character
	dec        dl                     ; bufSize--
	inc        rdi                    ; string++

	test       dl, dl                 ; if (bufSize == 0)
	jnz        .epilogue

	mov        rsi, [rdi]             ; load next eight characters into rsi
	mov        dl, dh                 ; bufSize = 8

.epilogue:
	jmp        r10                    ; jump to the return address

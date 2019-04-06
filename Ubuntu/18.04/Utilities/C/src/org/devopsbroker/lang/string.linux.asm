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
;   o bool f6215943_isEqual(char *foo, char *bar);
;   o char *f6215943_search(char *pattern, char *text);
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

extern  b196167f_addAll

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

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ f6215943_isEqual ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  f6215943_isEqual:function
f6215943_isEqual:
; Parameters:
;	rdi : char *foo
;	rsi : char *bar
; Local Variables:
;	ecx : loop counter
;	r8  : 64-bit character buffer
;	r9  : 64-bit character buffer

.prologue:                            ; functions typically have a prologue
	xor        eax, eax               ; return value = false

	cmp        rdi, rsi               ; if (foo == bar)
	je         .returnTrue

	test       rdi, rdi               ; if (foo == NULL)
	jz         .returnFalse

	test       rsi, rsi               ; if (bar == NULL)
	jz         .returnFalse

.whileEqual:
	mov        r8, [rdi]              ; load eight characters into r8
	mov        r9, [rsi]              ; load eight characters into r9

	mov        ecx, 0x08              ; loop counter = 8
	add        rdi, rcx               ; foo += 8
	add        rsi, rcx               ; bar += 8

.firstChar:
	cmp        r8b, r9b               ; if (foo[i] != bar[i])
	jne        .returnFalse

	test       r8b, r8b               ; if (foo[i] == '\0')
	jz         .returnTrue
	dec        cl                     ; loop counter--

.nextChars:
	shr        r8, 8
	shr        r9, 8

	cmp        r8b, r9b               ; if (foo[i] != bar[i])
	jne        .returnFalse

	test       r8b, r8b               ; if (foo[i] == '\0')
	jz         .returnTrue

	dec        cl                     ; loop counter--
	jnz        .nextChars             ; if (cl > 0)
	jmp        .whileEqual

.returnTrue:
	inc        al                     ; return value = true

.returnFalse:
	ret                               ; pop return address from stack and jump there

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ f6215943_search ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  f6215943_search:function
f6215943_search:
; Parameters:
;	rdi : char *pattern
;	rsi : char *text
; Local Variables:
;	rdx : original char *pattern value
;	cx  : ch = pattern loop counter, cl = text loop counter
;	r8  : 64-bit character buffer
;	r9  : 64-bit character buffer

.prologue:                            ; functions typically have a prologue
	xor        eax, eax               ; return value = NULL
	mov        rdx, rdi               ; rdx = original char *pattern value

	test       rdi, rdi               ; if (pattern == NULL)
	jz         .returnNull
	prefetcht0 [rdi]                  ; prefetch the pattern string into the CPU cache

	test       rsi, rsi               ; if (text == NULL)
	jz         .returnNull
	prefetcht0 [rsi]                  ; prefetch the text string into the CPU cache

	mov        r8, [rdi]              ; load first eight characters of pattern into r8
	mov        r9, [rsi]              ; load first eight characters of text into r9
	mov        cx, 0x0808             ; loop counters = 8

.whileText:
	cmp        r8b, r9b               ; if (pattern[i] != text[i])
	jne        .wasMatchFound

	test       r8b, r8b               ; if (pattern[i] == '\0')
	jz         .returnMatch

	shr        r8, 8
	shr        r9, 8

	inc        rdi                    ; pattern++
	dec        ch                     ; pattern loop counter--
	jnz        .checkTextBuffer       ; if (pattern loop counter > 0)

.managePatternBuffer:
	mov        r8, [rdi]              ; load next eight characters of pattern into r8
	mov        ch, 0x08               ; pattern loop counter = 8

.checkTextBuffer:
	inc        rsi                    ; text++
	dec        cl                     ; text loop counter--
	jnz        .whileText             ; if (text loop counter > 0)

.manageTextBufferA:
	mov        r9, [rsi]              ; load next eight characters of text into r9
	mov        cl, 0x08               ; text loop counter = 8
	jmp        .whileText

.wasMatchFound:
	test       r8b, r8b               ; if (pattern[i] == '\0')
	jz         .returnMatch

	test       r9b, r9b               ; if (text[i] == '\0')
	jz         .returnNull

.searchAgain:
	mov        r8, [rdx]              ; load first eight characters of pattern into r8
	mov        rdi, rdx               ; rdi = original char *pattern value
	mov        ch, 0x08               ; pattern loop counter = 8

	shr        r9, 8
	inc        rsi                    ; text++
	dec        cl                     ; text loop counter--
	jnz        .whileText             ; if (cl > 0)

.manageTextBufferB:
	mov        r9, [rsi]              ; load next eight characters of text into r9
	mov        cl, 0x08               ; text loop counter = 8
	jmp        .whileText

.returnMatch:
	mov        rax, rsi               ; return value = current char *text value

.returnNull:
	ret                               ; pop return address from stack and jump there

; ~~~~~~~~~~~~~~~~~~~~~~~~~~ f6215943_splitWithChar ~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  f6215943_splitWithChar:function
f6215943_splitWithChar:
; Parameters:
;	rdi : char *string
;	rsi : char delimiter
;	rdx : ListArray *substrList
; Local Variables:
;	cl  : loop counter
;	r8  : 64-bit character buffer
;	r9d : number of matches

.prologue:                            ; functions typically have a prologue
	push       rdi                    ; save char *string

	test       rdi, rdi               ; if (string == NULL)
	jz         .epilogue
	prefetcht0 [rdi]                  ; prefetch the string into the CPU cache

	test       rsi, rsi               ; if (delimiter == '\0')
	jz         .epilogue

	xor        r9d, r9d               ; number of matches = 0
	mov        cl, 0x08               ; loop counter = 8

	mov        r8, [rdi]              ; load first eight characters of string into r8

.whileString:
	test       r8b, r8b               ; if (string[i] == '\0')
	jz         .wasMatchFound

	cmp        r8b, sil               ; if (string[i] == delimiter)
	je         .matchFound

	shr        r8, 8
	inc        rdi                    ; string++
	dec        cl                     ; loop counter--
	jnz        .whileString           ; if (loop counter > 0)

.manageStringBufferA:
	mov        r8, [rdi]              ; load next eight characters of string into r8
	mov        cl, 0x08               ; loop counter = 8
	jmp        .whileString

.matchFound:
	inc        rdi                    ; string++
	inc        r9d                    ; number of matches++
	push       rdi                    ; save next char *string

	shr        r8, 8
	dec        cl                     ; loop counter--
	jnz        .whileString           ; if (loop counter > 0)

.manageStringBufferB:
	mov        r8, [rdi]              ; load next eight characters of string into r8
	mov        cl, 0x08               ; loop counter = 8
	jmp        .whileString

.wasMatchFound:
	test       r9d, r9d               ; if (number of matches == 0)
	jz         .epilogue

	push       r9                     ; save number of matches
	mov        rdi, rdx               ; set ListArray *listArray
	mov        rsi, rsp               ; set void **elementArray
	mov        edx, r9d               ; set uint32_t numElements

	test       r9d, 0x01              ; if (number of matches is odd)
	jnz        .addAlignedElements

	; b196167f_addAll(ListArray *listArray, void **elementArray, uint32_t numElements);
.addUnalignedElements:
	sub        rsp, 8                 ; align stack frame before calling b196167f_addAll()
	call       b196167f_addAll
	add        rsp, 8                 ; unalign stack frame after calling b196167f_addAll()

	pop        r9
	lea        rsp, [rsp+8+r9*8]      ; unwind char *string values from stack
	ret                               ; pop return address from stack and jump there

.addAlignedElements:
	call       b196167f_addAll

	pop        r9
	lea        rsp, [rsp+8+r9*8]      ; unwind char *string values from stack
	ret                               ; pop return address from stack and jump there

.epilogue:                            ; functions typically have an epilogue
	add        rsp, 8                 ; unwind char *string value from stack
	ret                               ; pop return address from stack and jump there

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

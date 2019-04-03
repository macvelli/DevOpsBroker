;
; linebuffer.linux.asm - DevOpsBroker NASM file for text line-processing functionality
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
; org.devopsbroker.text.linebuffer.h header file:
;
;   o LineBuffer *c196bc72_createLineBuffer();
;   o void c196bc72_destroyLineBuffer(LineBuffer *lineBuffer);
;   o void c196bc72_initLineBuffer(LineBuffer *lineBuffer);
;   o String *c196bc72_getLine(LineBuffer *lineBuffer);
;   o void c196bc72_populateLineBuffer(LineBuffer *lineBuffer, int fd);
; -----------------------------------------------------------------------------
;

; ════════════════════════════ Include Directives ════════════════════════════


; ═══════════════════════════════ Preprocessor ═══════════════════════════════

; Constants
%define BUFFER_SIZE    0xfe8
%define END_OF_FILE    0
%define ERROR_CODE     -1
%define EXIT_FAILURE   1

; character values
%define NEWLINE   0x0A

; ═════════════════════════════ Initialized Data ═════════════════════════════

section .data               ; DX directives
	readErrorMsg:  db    "Cannot read from file", 0

; ════════════════════════════ Uninitialized Data ════════════════════════════

section .bss                ; RESX directives

; ══════════════════════════════ Assembly Code ═══════════════════════════════

	section .text

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ External Resources ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

extern  malloc
extern  free
extern  abort

extern  read
extern  perror
extern  exit

; ~~~~~~~~~~~~~~~~~~~~~~~~~ c196bc72_createLineBuffer ~~~~~~~~~~~~~~~~~~~~~~~~

	global  c196bc72_createLineBuffer:function
c196bc72_createLineBuffer:

.prologue:                            ; functions typically have a prologue
	sub        rsp, 8                 ; align stack frame before calling malloc()

.malloc:                              ; malloc(sizeof(LineBuffer))
	mov        edi, 0x1000
	call       malloc WRT ..plt

	test       rax, rax               ; if (ptr == NULL)
	jz         .fatalError
	add        rsp, 8                 ; unalign stack frame after calling malloc()

	xor        rdi, rdi               ; clear rdi register
	pxor       xmm0, xmm0             ; clear xmm0 register

.initLineBuffer:
	mov        [rax], edi             ; lineBuffer->buffer[0] = '\0'
	mov        [rax+4072], rdi        ; lineBuffer->length = 0 and lineBuffer->size = 0
	movdqa     [rax+4080], xmm0       ; memset(lineBuffer->line, 0, sizeof(String))

.epilogue:                            ; functions typically have an epilogue
	ret                               ; pop return address from stack and jump there

.fatalError:
	call       abort WRT ..plt

; ~~~~~~~~~~~~~~~~~~~~~~~~ c196bc72_destroyLineBuffer ~~~~~~~~~~~~~~~~~~~~~~~~

	global  c196bc72_destroyLineBuffer:function
c196bc72_destroyLineBuffer:
; Parameters:
;	rdi : LineBuffer *lineBuffer

.prologue:                            ; functions typically have a prologue
	sub        rsp, 8                 ; align stack frame before calling free()

.free:                                ; free(LineBuffer *lineBuffer)
	call       free WRT ..plt

.epilogue:                            ; functions typically have an epilogue
	add        rsp, 8                 ; unalign stack frame after calling free()
	ret                               ; pop return address from stack and jump there

; ~~~~~~~~~~~~~~~~~~~~~~~~~~ c196bc72_initLineBuffer ~~~~~~~~~~~~~~~~~~~~~~~~~

	global  c196bc72_initLineBuffer:function
c196bc72_initLineBuffer:
; Parameters:
;	rdi : LineBuffer *lineBuffer

.prologue:                            ; functions typically have a prologue
	xor        rax, rax               ; clear rax register
	pxor       xmm0, xmm0             ; clear xmm0 register

.initLineBuffer:
	mov        [rdi], eax             ; lineBuffer->buffer[0] = '\0'
	mov        [rdi+4072], rax        ; lineBuffer->length = 0 and lineBuffer->size = 0
	movdqa     [rdi+4080], xmm0       ; memset(lineBuffer->line, 0, sizeof(String))

.epilogue:                            ; functions typically have an epilogue
	ret                               ; pop return address from stack and jump there

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ c196bc72_getLine ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  c196bc72_getLine:function
c196bc72_getLine:
; Parameters:
;	rdi : LineBuffer *lineBuffer
; Local Variables:
;	rax : 64-bit char buffer
;	rsi : lineBuffer->buffer source address
;	dx  : rax buffer size
;	ecx : lineBuffer->line.length
;	r8d : lineBuffer->length
;	r9d : lineBuffer->size

.prologue:                            ; functions typically have a prologue
	mov        r8d, [rdi+4072]        ; r8d = lineBuffer->length
	mov        r9d, [rdi+4076]        ; r9d = lineBuffer->size
	mov        edx, 0x0808            ; dh = 8, bufSize = 8
	cld                               ; clear direction flag in EFLAGS register

	mov        rsi, rdi               ; rsi = lineBuffer->buffer source address
	add        rsi, r8                ; lineBuffer->buffer += lineBuffer->length

	cmp        r8d, r9d               ; if (lineBuffer->length == lineBuffer->size)
	je         .epilogue

	prefetcht0 [rsi]                  ; prefetch source address data into the CPU cache
	xor        ecx, ecx               ; lineBuffer->line.length = 0
	movq       xmm0, rsi              ; xmm0 = lineBuffer->buffer source address
	movd       xmm1, r8d              ; xmm1 = lineBuffer->length
	lodsq                             ; put first eight characters from [rsi] into rax

.findNewline:
	test       al, al                 ; if (ch == '\0')
	jz         .epilogue
	inc        r8d                    ; lineBuffer->length++

	cmp        al, NEWLINE            ; if (ch == '\n')
	je         .foundNewline

	cmp        r8d, r9d               ; if (lineBuffer->length == lineBuffer->size)
	je         .newLineNotFound

.getNextCharacter:
	shr        rax, 8                 ; shift to the next chc196bc72_populateLineBufferaracter
	dec        dl                     ; bufSize--
	inc        ecx                    ; lineBuffer->line.length++

	test       dl, dl                 ; if (bufSize != 0)
	jnz        .findNewline

	lodsq                             ; load next eight characters from [rsi] into rax
	mov        dl, dh                 ; bufSize = 8
	jmp        .findNewline

.foundNewline:
	movzx      rdx, dl                ; extend buffer size
	sub        rsi, rdx               ; adjust source address by buffer size
	mov        [rsi], byte 0x00       ; replace newline with null termination character

	lea        rax, [rdi+4080]        ; set return address to lineBuffer->line
	movq       rsi, xmm0              ; rsi = lineBuffer->buffer source address

	mov        [rax], rsi             ; lineBuffer->line.value = source address
	mov        [rax+8], ecx           ; lineBuffer->line.length = string length
	mov        [rdi+4072], r8d        ; lineBuffer->length = lineBuffer length

	ret                               ; pop return address from stack and jump there

.newLineNotFound:
	movd       r8d, xmm1              ; r8d = original lineBuffer->length value
	movq       rsi, xmm0              ; rsi = lineBuffer->buffer source address
	movq       xmm2, rdi              ; xmm2 = lineBuffer->buffer
	sub        r9d, r8d               ; lineBuffer->size -= lineBuffer->length
	mov        edx, r9d               ; edx = new lineBuffer->size

.copyBuffer:
	cmp        r9d, 0x08              ; if (lineBuffer->size < 8)
	jb         .copyBytes

.copyEightBytes:
	mov        ecx, r9d               ; calculate how many eight byte chunks to copy
	shr        ecx, 3                 ; ecx = length / 8
	mov        r8d, ecx
	shl        r8d, 3
	sub        r9d, r8d               ; r9d = length % 8

	rep movsq                         ; move ecx quadwords from lineBuffer->buffer source to lineBuffer->buffer destination

.copyBytes:
	mov        ecx, r9d
	rep movsb                         ; move ecx bytes from lineBuffer->buffer source to lineBuffer->buffer destination

	mov        [rdi], byte 0x00       ; terminate lineBuffer->buffer destination

.updateLineBuffer:
	movq       rdi, xmm2              ; rdi = original lineBuffer->buffer value
	mov        [rdi+4072], dword 0x00   ; lineBuffer->length = 0
	mov        [rdi+4076], edx          ; lineBuffer->size = lineBuffer->buffer length

.epilogue:                            ; functions typically have an epilogue
	xor        rax, rax               ; set return value to NULL
	ret                               ; pop return address from stack and jump there

; ~~~~~~~~~~~~~~~~~~~~~~~~ c196bc72_populateLineBuffer ~~~~~~~~~~~~~~~~~~~~~~~~

	global  c196bc72_populateLineBuffer:function
c196bc72_populateLineBuffer:
; Parameters:
;	rdi : LineBuffer *lineBuffer
;	esi : int fd
; Local Variables:
;	edx : size_t count

.prologue:                            ; functions typically have a prologue
	mov        ecx, [rdi+4076]        ; ecx = lineBuffer->size
	mov        edx, BUFFER_SIZE       ; count = 4072
	xchg       rdi, rsi               ; exchange input parameters

	test       ecx, ecx               ; if (lineBuffer->size == 0)
	jz         .unadjustedRead

.read:                                ; read(int fd, lineBuffer->buffer, size_t count)
	push       rsi                    ; save LineBuffer *lineBuffer
	sub        edx, ecx               ; count -= lineBuffer->size
	add        rsi, rcx               ; lineBuffer->buffer += lineBuffer->size
	call       read WRT ..plt

	cmp        rax, ERROR_CODE        ; if (returnValue == ERROR_CODE)
	je         .readError
	pop        rsi                    ; retrieve LineBuffer *lineBuffer

.epilogue:                            ; functions typically have an epilogue
	add        [rsi+4076], eax        ; lineBuffer->size += numBytes
	ret                               ; pop return address from stack and jump there

.unadjustedRead:                      ; read(int fd, lineBuffer->buffer, size_t count)
	sub        rsp, 8                 ; align stack frame before calling read()
	call       read WRT ..plt

	cmp        rax, ERROR_CODE        ; if (returnValue == ERROR_CODE)
	je         .readError
	add        rsp, 8                 ; unalign stack frame after calling read()

	add        [rsi+4076], eax        ; lineBuffer->size += numBytes
	ret                               ; pop return address from stack and jump there

.readError:                           ; perror(char *s)
	lea        rdi, [rel readErrorMsg]
	call       perror wrt ..plt

	mov        edi, EXIT_FAILURE      ; exit(int status)
	call       exit wrt ..plt

;
; file.linux.asm - DevOpsBroker NASM file for file-related functionality
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
; org.devopsbroker.io.file.h header file:
;
;   o void e2f74138_readString(char *pathName, char *buffer, uint32_t bufSize);
;   o uint32_t e2f74138_readUint32Hex(char *pathName);
; -----------------------------------------------------------------------------
;

; ════════════════════════════ Include Directives ════════════════════════════


; ═══════════════════════════════ Preprocessor ═══════════════════════════════

; File Access Modes
%define READ_ONLY    0x00
%define WRITE_ONLY   0x01
%define READ_WRITE   0x02

; character values
%define ZERO      0x30
%define NINE      0x39
%define LOWER_A   0x61
%define LOWER_F   0x66

; Constants
%define ERROR_CODE   -1

; ═════════════════════════════ Initialized Data ═════════════════════════════

section .data               ; DX directives

; ════════════════════════════ Uninitialized Data ════════════════════════════

section .bss                ; RESX directives

; ══════════════════════════════ Assembly Code ═══════════════════════════════

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~ e2f74138_readString ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  e2f74138_readString:function
	extern  open
	extern  read
	extern  close
	section .text
e2f74138_readString:
; Parameters:
;	rdi : char *pathName
;	rsi : char *buffer
;	rdx : uint32_t bufSize
; Local Variables:
;	ecx : conversion register
;	r8b : bufSize

.prologue:                            ; functions typically have a prologue
	prefetcht0 [rdi]                  ; prefetch pathName into the CPU cache
	sub        rsp, 8                 ; align stack frame before making function calls

.openFile:
	push       rsi                    ; save char *buffer
	push       rdx                    ; save uint32_t bufSize
	xor        rsi, rsi
	call       open WRT ..plt         ; open(pathname, O_RDONLY);

	test       eax, ERROR_CODE        ; if (fileDescriptor == -1)
	jne        .readFile

.invalidFilename:
	add        rsp, 24                ; re-align stack frame before returning
	xor        eax, eax               ; return value = 0
	ret

.readFile:
	pop        rdx                    ; retrieve uint32_t bufSize
	pop        rsi                    ; retrieve char *buffer
	mov        edi, eax               ; set edi to the fileDescriptor

	call       read WRT ..plt         ; read(fileDescriptor, buffer, bufSize);

	test       eax, ERROR_CODE        ; if (fileDescriptor == -1)
	jne        .closeFile

	xor        eax, eax               ; return value = 0

.closeFile:
	add        rsp, 8                 ; re-align stack frame before close
	push       rax                    ; save return value
	call       close WRT ..plt        ; close(fileDescriptor);

.epilogue:                            ; functions typically have an epilogue
	pop        rax                    ; retrieve return value
	ret                               ; pop return address from stack and jump there

; ~~~~~~~~~~~~~~~~~~~~~~~~~~ e2f74138_readUint32Hex ~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  e2f74138_readUint32Hex:function
	extern  open
	extern  read
	extern  close
	section .text
e2f74138_readUint32Hex:
; Parameters:
;	rdi : char *pathName
; Local Variables:
;	rsi : function argument register
;	rdx : function argument register
;	ecx : conversion register
;	r8b : bufSize

.prologue:                            ; functions typically have a prologue
	prefetcht0 [rdi]                  ; prefetch pathName into the CPU cache
	sub        rsp, 8                 ; align stack frame before making function calls

.openFile:
	xor        rsi, rsi
	call       open WRT ..plt         ; open(pathname, O_RDONLY);

	test       eax, ERROR_CODE        ; if (fileDescriptor == -1)
	jne        .readFile

.invalidFilename:
	add        rsp, 8                 ; re-align stack frame before returning
	ret

.readFile:
	xor        rdx, rdx
	sub        rsp, 16

	mov        edi, eax
	mov        rsi, rsp
	mov        dl, 16
	call       read WRT ..plt         ; read(fileDescriptor, buffer, bufSize);

	test       al, ERROR_CODE         ; if (fileDescriptor == -1)
	je         .closeFile

.parseHex:
	mov        rdx, [rsi]             ; put first eight characters into rdx
	xor        eax, eax               ; return value = 0
	xor        ecx, ecx               ; conversion register = 0

.whileLoop:
	test       dl, dl                 ; if (ch == '\0')
	jz         .closeFile

	cmp        dl, NINE               ; if (ch > '9')
	ja         .hexadecimal
	sub        dl, ZERO               ; if (ch >= '0')
	jae        .accumulateDigit

.invalidHexNumber:
	jmp        .closeFile

.hexadecimal:
	or         dl, 0x20               ; toLowerCase(ch)
	cmp        dl, LOWER_F            ; if (ch > 'f')
	ja         .invalidHexNumber
	sub        dl, LOWER_A            ; if (ch < 'a')
	jb         .invalidHexNumber

	add        dl, 0x0a               ; digit += 10

.accumulateDigit:
	mov        cl, dl                 ; value = (value * 16) + digit
	shl        eax, 4
	add        eax, ecx

.manageCharBuffer:
	shr        rdx, 8                 ; shift to the next character
	dec        r8b                    ; bufSize--
	inc        rsi                    ; readBufferPtr++

	test       r8b, r8b               ; if (bufSize == 0)
	jnz        .whileLoop

	mov        rdx, [rsi]             ; load next eight characters into rdx
	mov        r8b, 0x08              ; bufSize = 8
	jmp        .whileLoop

.closeFile:
	add        rsp, 24                ; re-align stack frame before close
	push       rax                    ; save return value
	call       close WRT ..plt        ; close(fileDescriptor);

.epilogue:                            ; functions typically have an epilogue
	pop        rax                    ; retrieve return value
	ret                               ; pop return address from stack and jump there

;
; commandline.linux.asm - DevOpsBroker NASM file for command line-related functionality
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
; org.devopsbroker.terminal.commandline.h header file:
;
;   o float d7ad7024_getFloat(CmdLineParam *cmdLineParam, char *paramName, int i);
;   o char *d7ad7024_getString(CmdLineParam *cmdLineParam, char *paramName, int i);
;   o uint32_t d7ad7024_getUint32(CmdLineParam *cmdLineParam, char *paramName, int i);
;   o uint64_t d7ad7024_getUint64(CmdLineParam *cmdLineParam, char *paramName, int i);
;   o bool d7ad7024_isEqual(CmdLineParam *cmdLineParam, char *value, int argIndex);
; -----------------------------------------------------------------------------
;

; ════════════════════════════ Include Directives ════════════════════════════


; ═══════════════════════════════ Preprocessor ═══════════════════════════════

; character values
%define ZERO        0x30
%define NINE        0x39

; Constants
%define EXIT_FAILURE   0x01

; float Values
%define NAN            0x7fc00000        ; NaN

; ═════════════════════════════ Initialized Data ═════════════════════════════

section .data               ; DX directives

; ════════════════════════════ Uninitialized Data ════════════════════════════

section .bss                ; RESX directives

; ══════════════════════════════ Assembly Code ═══════════════════════════════

	section .text

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ External Resources ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

extern  b08dcfcc_parseFloat
extern  c7c88e52_missingParam
extern  c7c88e52_invalidValue
extern  c7c88e52_printUsage
extern  exit

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ d7ad7024_getFloat ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  d7ad7024_getFloat:function
d7ad7024_getFloat:
; Parameters:
;	rdi : CmdLineParam *cmdLineParm
;	rsi : char *paramName
;	rdx : int i
; Local Variables:
;	ecx  : cmdLineParm->argc
;	r10  : saves argv[i] reference
;	r11  : saves CmdLineParam* reference

.prologue:                            ; functions typically have a prologue
	mov        ecx, [rdi + 16]        ; ecx = cmdLineParm->argc
	inc        edx                    ; ++i

	cmp        edx, ecx
	je         missingParameter

.parseFloat:
	mov        r11, rdi               ; save CmdLineParam* reference into r11
	mov        rdi, [rdi + 8]         ; rdi = cmdLineParm->argv
	mov        rdi, [rdi + 8*rdx]     ; load the argv[i] reference for parseFloat
	mov        r10, rdi               ; save argv[i] reference for later
	call       b08dcfcc_parseFloat    ; float f = b08dcfcc_parseFloat(cmdLineParm->argv[i]);

	movd       eax, xmm0              ; put lowest 32-bits from xmm0 into eax
	cmp        eax, NAN               ; if (f == NAN)
	je         invalidValue

.epilogue:                            ; functions typically have an epilogue
	ret                               ; pop return address from stack and jump there

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ d7ad7024_getString ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  d7ad7024_getString:function
d7ad7024_getString:
; Parameters:
;	rdi : CmdLineParam *cmdLineParm
;	rsi : char *paramName
;	rdx : int i

.prologue:                            ; functions typically have a prologue
	mov        ecx, [rdi + 16]        ; ecx = cmdLineParm->argc
	inc        edx                    ; ++i

	cmp        edx, ecx
	je         missingParameter

.epilogue:                            ; functions typically have an epilogue
	mov        rax, [rdi + 8]         ; rax = cmdLineParm->argv[i]
	mov        rax, [rax + 8*rdx]
	ret                               ; pop return address from stack and jump there

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ d7ad7024_getUint32 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  d7ad7024_getUint32:function
d7ad7024_getUint32:
; Parameters:
;	rdi : CmdLineParam *cmdLineParam
;	rsi : char *paramName
;	edx : int argIndex
; Local Variables:
;	ecx : cmdLineParam->argc
;	rcx : cmdLineParam->argv[i]
;	dx  : bufSize
;	r8  : 64-bit char buffer
;	r9d : data conversion register
;	r10 : cmdLineParam->argv[i] reference

.prologue:                            ; functions typically have a prologue
	mov        ecx, [rdi+16]          ; ecx = cmdLineParm->argc
	xor        eax, eax               ; function return value = 0

	cmp        edx, ecx
	je         missingParameter

.parseUint32:
	mov        rcx, [rdi+8]           ; rcx = cmdLineParam->argv[i]
	mov        rcx, [rcx + 8*rdx]
	mov        r10, rcx               ; save argv[i] reference for invalidValue

	mov        r8, [rcx]              ; load first eight characters into r8
	mov        dx, 0x0808             ; dh = 8, dl = 8
	xor        r9d, r9d               ; clear conversion register

	; Calculate the integer from the input string
.whileInteger:
	test       r8b, r8b               ; if (ch == '\0')
	jnz        .processDigit

.epilogue:                            ; functions typically have an epilogue
	ret                               ; pop return address from stack and jump there

.processDigit:
	cmp        r8b, NINE
	jg         invalidValue           ; Error if character greater than nine
	sub        r8b, ZERO
	jl         invalidValue           ; Error if character less than zero

	mov        r9b, r8b               ; value = (value * 10) + digit
	lea        eax, [eax+eax*4]
	lea        eax, [r9d+eax*2]

.manageCharBuffer:
	shr        r8, 8                  ; shift to the next character
	dec        dl                     ; bufSize--
	inc        rcx                    ; argv[i]++

	test       dl, dl                 ; if (bufSize == 0)
	jnz        .whileInteger

	mov        r8, [rcx]              ; load next eight characters into r8
	mov        dl, dh                 ; bufSize = 8
	jmp        .whileInteger

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ d7ad7024_getUint64 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  d7ad7024_getUint64:function
d7ad7024_getUint64:
; Parameters:
;	rdi : CmdLineParam *cmdLineParam
;	rsi : char *paramName
;	rdx : int i
; Local Variables:
;	ecx : cmdLineParam->argc
;	rcx : cmdLineParam->argv[i]
;	dx  : bufSize
;	r8  : 64-bit char buffer
;	r9  : data conversion register
;	r10 : cmdLineParam->argv[i] reference

.prologue:                            ; functions typically have a prologue
	mov        ecx, [rdi + 16]        ; ecx = cmdLineParm->argc
	inc        edx                    ; ++i
	xor        rax, rax               ; function return value = 0

	cmp        edx, ecx
	je         missingParameter

.parseUint64:
	mov        rcx, [rdi + 8]         ; rcx = cmdLineParam->argv[i]
	mov        rcx, [rcx + 8*rdx]
	mov        r10, rcx               ; save argv[i] reference for invalidValue

	mov        r8, [rcx]              ; load first eight characters into r8
	mov        dx, 0x0808             ; dh = 8, dl = 8
	xor        r9, r9                 ; clear conversion register

	; Calculate the integer from the input string
.whileInteger:
	test       r8b, r8b               ; if (ch == '\0')
	jnz        .processDigit

.epilogue:                            ; functions typically have an epilogue
	ret                               ; pop return address from stack and jump there

.processDigit:
	cmp        r8b, NINE
	jg         invalidValue           ; Error if character greater than nine
	sub        r8b, ZERO
	jl         invalidValue           ; Error if character less than zero

	mov        r9b, r8b               ; value = (value * 10) + digit
	lea        rax, [rax+rax*4]
	lea        rax, [r9+rax*2]

.manageCharBuffer:
	shr        r8, 8                  ; shift to the next character
	dec        dl                     ; bufSize--
	inc        rcx                    ; argv[i]++

	test       dl, dl                 ; if (bufSize == 0)
	jnz        .whileInteger

	mov        r8, [rcx]              ; load next eight characters into r8
	mov        dl, dh                 ; bufSize = 8
	jmp        .whileInteger

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ d7ad7024_isEqual ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  d7ad7024_isEqual:function
d7ad7024_isEqual:
; Parameters:
;	rdi : CmdLineParam *cmdLineParam
;	rsi : char *value
;	edx : int argIndex
; Local Variables:
;	ecx : loop counter
;	r8  : 64-bit character buffer
;	r9  : 64-bit character buffer

.prologue:                            ; functions typically have a prologue
	mov        rdi, [rdi+8]           ; rdi = cmdLineParam->argv[argIndex]
	mov        rdi, [rdi + 8*rdx]
	xor        eax, eax               ; return value = false

.whileEqual:
	mov        r8, [rdi]              ; load eight characters into rdx
	mov        r9, [rsi]              ; load eight characters into rcx

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

; ═════════════════════════════ Private Routines ═════════════════════════════

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ missingParameter ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

missingParameter:
; Parameters:
;	rdi : CmdLineParam *cmdLineParam
;	rsi : char *paramName

	; c7c88e52_missingParam(paramName);
	push       rdi                    ; save CmdLineParam reference on the stack
	mov        rdi, rsi               ; rdi = paramName
	call       c7c88e52_missingParam

	; c7c88e52_printUsage(cmdLineParm->usageMsg);
	pop        rdi                    ; retrieve CmdLineParam reference from the stack
	mov        rdi, [rdi]             ; rdi = cmdLineParm->usageMsg
	sub        rsp, 8                 ; Re-align stack frame before making call
	call       c7c88e52_printUsage

	; exit(EXIT_FAILURE);
	mov        rdi, EXIT_FAILURE
	call       exit WRT ..plt

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ invalidValue ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

invalidValue:
; Parameters:
;	rdi : CmdLineParam *cmdLineParam
;	rsi : char *paramName
;	r10 : cmdLineParam->argv[i]

	; c7c88e52_invalidValue(paramName, cmdLineParm->argv[i]);
	push       rdi                    ; save CmdLineParam reference on the stack
	mov        rdi, rsi               ; rdi = paramName
	mov        rsi, r10               ; rsi = cmdLineParam->argv[i]
	call       c7c88e52_invalidValue

	; c7c88e52_printUsage(cmdLineParm->usageMsg);
	pop        rdi                    ; retrieve CmdLineParam reference from the stack
	mov        rdi, [rdi]             ; rdi = cmdLineParm->usageMsg
	sub        rsp, 8                 ; Re-align stack frame before making call
	call       c7c88e52_printUsage

	; exit(EXIT_FAILURE);
	mov        rdi, EXIT_FAILURE
	call       exit WRT ..plt

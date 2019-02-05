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
; org.devopsbroker.lang.commandline.h header file:
;
;   o float d7ad7024_getFloat(CmdLineParam *cmdLineParm, char *paramName, int i);
; -----------------------------------------------------------------------------
;

; ════════════════════════════ Include Directives ════════════════════════════


; ═══════════════════════════════ Preprocessor ═══════════════════════════════

; Constants
%define EXIT_FAILURE   0x01

; float Values
%define NAN            0x7fc00000        ; NaN

; ═════════════════════════════ Initialized Data ═════════════════════════════

section .data               ; DX directives

; ════════════════════════════ Uninitialized Data ════════════════════════════

section .bss                ; RESX directives

; ══════════════════════════════ Assembly Code ═══════════════════════════════

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ d7ad7024_getFloat ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  d7ad7024_getFloat:function
	extern  b08dcfcc_parseFloat
	extern  c7c88e52_missingParam
	extern  c7c88e52_invalidValue
	extern  c7c88e52_printUsage
	extern  exit
	section .text
d7ad7024_getFloat:
; Parameters:
;	rdi : CmdLineParam *cmdLineParm
;	rsi : char *paramName
;	rdx : int i
; Local Variables:
;	r10  : saves argv[i] reference
;	r11  : saves CmdLineParam* reference

.prologue:                            ; functions typically have a prologue
	mov        ecx, [rdi + 16]        ; ecx = cmdLineParm->argc
	inc        edx                    ; ++i

.missingParameter:
	cmp        edx, ecx
	jne        .parseFloat

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

.parseFloat:
	mov        r11, rdi               ; save CmdLineParam* reference into r11
	mov        rdi, [rdi + 8]         ; rdi = cmdLineParm->argv
	mov        rdi, [rdi + 8*rdx]     ; load the argv[i] reference for parseFloat
	mov        r10, rdi               ; save argv[i] reference for later
	call       b08dcfcc_parseFloat    ; float f = b08dcfcc_parseFloat(cmdLineParm->argv[i]);

.invalidValue:
	movd       eax, xmm0              ; put lowest 32-bits from xmm0 into eax
	cmp        eax, NAN               ; if (f == NAN)
	jne        .epilogue

	; c7c88e52_invalidValue(paramName, cmdLineParm->argv[i]);
	mov        rdi, r11               ; retrieve CmdLineParam reference from r11
	push       rdi                    ; save CmdLineParam reference on the stack
	mov        rdi, rsi               ; rdi = paramName
	mov        rsi, r10               ; rsi = argv[i]
	call       c7c88e52_invalidValue

	; c7c88e52_printUsage(cmdLineParm->usageMsg);
	pop        rdi                    ; retrieve CmdLineParam reference from the stack
	mov        rdi, [rdi]             ; rdi = cmdLineParm->usageMsg
	sub        rsp, 8                 ; Re-align stack frame before making call
	call       c7c88e52_printUsage

	; exit(EXIT_FAILURE);
	mov        rdi, EXIT_FAILURE
	call       exit WRT ..plt

.epilogue:                            ; functions typically have an epilogue
	ret                               ; pop return address from stack and jump there

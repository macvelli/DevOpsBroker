;
; enum.linux.asm - DevOpsBroker NASM file for enum-related functionality
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
; Developed on Ubuntu 18.04.2 LTS running kernel.osrelease = 4.18.0-17
;
; This file implements the following x86-64 assembly language functions for the
; org.devopsbroker.lang.enum.h header file:
;
;   o char *c5033972_toStringEnum(char *enumStringList, int enumValue);
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

; ~~~~~~~~~~~~~~~~~~~~~~~~~~ c5033972_toStringEnum ~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  c5033972_toStringEnum:function
c5033972_toStringEnum:
; Parameters:
;	rdi : char *enumStringList
;	rsi : int enumValue

.prologue:                            ; functions typically have a prologue
	lea        rax, [rdi+rsi]         ; return value = enumStringList + offset

.epilogue:                            ; functions typically have an epilogue
	ret                               ; pop return address from stack and jump there

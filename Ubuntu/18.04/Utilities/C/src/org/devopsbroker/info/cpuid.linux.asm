;
; cpuid.linux.asm - DevOpsBroker NASM file for CPUID-related functionality
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
; org.devopsbroker.info.cpuid.h header file:
;
;   o void f618482d_getModelName(CPUID *cpuid);
;   o void f618482d_getProcessorInfo(CPUID *cpuid);
;   o void f618482d_getVendorID(CPUID *cpuid);
; -----------------------------------------------------------------------------
;

; ════════════════════════════ Include Directives ════════════════════════════


; ═══════════════════════════════ Preprocessor ═══════════════════════════════

; CPUID Leaf Codes
%define VENDOR_ID       0x00
%define GET_FEATURES    0x01
%define EXTEND_INFO     0x80000000
%define MODEL_NAME_1    0x80000002
%define MODEL_NAME_3    0x80000004
%define AMD_NUM_CORES   0x80000008

; Constants
%define IS_AMD            0x444d4163
%define HAS_HYPERTHREAD   0x10000000

%define ERROR_CODE   -1

; ═════════════════════════════ Initialized Data ═════════════════════════════

	section .data   align=8           ; DX directives
	align 8,db 0
threadSiblingsList:  db "/sys/devices/system/cpu/cpu0/topology/thread_siblings_list", 0

; ════════════════════════════ Uninitialized Data ════════════════════════════

	section .bss                      ; RESX directives

; ══════════════════════════════ Assembly Code ═══════════════════════════════

; ~~~~~~~~~~~~~~~~~~~~~~~~~ f618482d_getCoreTopology ~~~~~~~~~~~~~~~~~~~~~~~~~

;	global  f618482d_getCoreTopology:function
;	extern  open
;	extern  read
;	extern  close
;	section .text
;f618482d_getCoreTopology:
; Parameters:
;	rdi : CPUID *cpuid
; Local Variables:
;	eax : information category
;	ebx : additional feature information
;	edx : feature information bits 0-31
;	ecx : feature information bits 32-61
;
;.prologue:                            ; functions typically have a prologue
;	mov        eax, GET_FEATURES      ; retrieve feature information
;	push       rbx                    ; preserve rbx value
;
;.getNumLogicalProcs:
;	cpuid
;
;	shr        ebx, 16                ; extract numLogicalProcs
;	and        bx, 0x00ff
;
;	test       edx, HAS_HYPERTHREAD   ; if (hasHyperThreading == true)
;	jnz        .hyperthreading
;
;	mov        edx, ebx               ; numPhysicalCores = numLogicalProcs
;	jmp        .smtDisabled
;
;.hyperthreading:
;	prefetcht0 [rel threadSiblingsList]
;
;.openFile:
;	push       rbx                    ; save numLogicalProcs
;	push       rdi                    ; save CPUID *cpuid
;
;	mov        rdi, [rel threadSiblingsList]
;	xor        rsi, rsi
;	call       open WRT ..plt         ; open(pathname, O_RDONLY);
;
;	test       eax, ERROR_CODE        ; if (fileDescriptor == -1)
;	je         .invalidFilename
;
;.readFile:
;	sub        rsp, 16                ; char *buffer
;	mov        [rsp], dword 0x00
;
;	mov        edi, eax               ; edi = fileDescriptor
;	mov        rsi, rsp               ; rsi = stack pointer
;	mov        edx, 16                ; edx = 16
;	call       read WRT ..plt         ; read(fileDescriptor, buffer, bufSize);
;
;.closeFile:
;	call       close WRT ..plt        ; close(fileDescriptor);
;
;.checkSMTStatus:
;	mov        eax, [rsp]             ; put first four characters into eax
;	add        rsp, 16                ; destroy char *buffer
;	pop        rdi                    ; retrieve CPUID *cpuid
;	pop        rbx                    ; retrieve numLogicalProcs
;	mov        edx, ebx               ; numPhysicalCores = numLogicalProcs
;
;	test       ah, 0x2d               ; if (buffer[1] == '-')
;	jne        .smtDisabled
;
;	shr        edx, 1                 ; numPhysicalCores = numLogicalProcs / 2
;
;.smtDisabled:
;	shl        rdx, 32
;	or         rbx, rdx
;
;.epilogue:                            ; functions typically have an epilogue
;	mov        [rdi+88], rbx          ; set cpuid->numLogicalProcs and cpuid->numPhysicalCores
;	pop        rbx                    ; restore rbx value
;	ret                               ; pop return address from stack and jump there
;
;.invalidFilename:
;	pop        rdi                    ; retrieve CPUID *cpuid
;	pop        rbx                    ; retrieve numLogicalProcs
;
;	mov        edx, ebx               ; numPhysicalCores = numLogicalProcs
;	jmp        .smtDisabled

; ~~~~~~~~~~~~~~~~~~~~~~~~~~ f618482d_getModelName ~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  f618482d_getModelName:function
	section .text
f618482d_getModelName:
; Parameters:
;	rdi : CPUID *cpuid
; Local Variables:
;	eax : information category
;	ebx : character buffer
;	edx : character buffer
;	ecx : character buffer
;	rsi : preserve rbx value

.prologue:                            ; functions typically have a prologue
	mov        eax, EXTEND_INFO       ; retrieve highest implemented extended function

.checkMaxExtend:
	cpuid

	cmp        eax, MODEL_NAME_3      ; if (maxExtendedFunction >= MODEL_NAME_3)
	jae        .getModelName

	xor        eax, eax               ; cpu does not support model name
	mov        [rdi], eax
	ret

.getModelName:
	mov        rsi, rbx               ; preserve rbx value in rsi
	mov        eax, MODEL_NAME_1
	mov        r8d, MODEL_NAME_1

.whileLoop:
	cpuid

	shl        rbx, 32
	or         rax, rbx
	mov        [rdi], rax

	shl        rdx, 32
	or         rcx, rdx
	mov        [rdi+8], rcx

	cmp        r8d, MODEL_NAME_3
	je         .epilogue

	inc        r8d
	add        rdi, 16
	mov        eax, r8d
	jmp        .whileLoop

.epilogue:                            ; functions typically have an epilogue
	mov        rbx, rsi               ; restore rbx value from rsi
	ret                               ; pop return address from stack and jump there

; ~~~~~~~~~~~~~~~~~ f618482d_getProcessorInfo  (using SSE2) ~~~~~~~~~~~~~~~~~~

	global  f618482d_getProcessorInfo:function
	section .text
f618482d_getProcessorInfo:
; Parameters:
;	rdi : CPUID *cpuid
; Local Variables:
;	eax : information category
;	ebx : additional feature information
;	edx : feature information bits 0-31
;	ecx : feature information bits 32-61
;	rsi : preserve rbx value
;	r8  : conversion register
;	r9  : conversion register

.prologue:                            ; functions typically have a prologue
	mov        eax, GET_FEATURES      ; retrieve processor information and feature flags
	mov        rsi, rbx               ; preserve rbx value in rsi
	xor        r8, r8                 ; r8 = 0

.processorInfo:
	cpuid

	mov        r8w, ax                ; family ID
	shr        r8w, 8

	and        r8b, 0x0f
	cmp        r8b, 0x0f              ; if (familyId != 15)
	je         .steppingId

.extendedFamilyId:
	mov        r9d, eax
	shr        r9d, 20
	add        r8b, r9b

.steppingId:
	mov        [rdi+68], r8d
	mov        r9b, r8b

	mov        r8b, al                ; stepping ID
	and        r8b, 0x0f
	shl        r8, 32

	shr        al, 4                  ; model

	cmp        r9b, 0x0f              ; if (familyId == 6 || familyId == 15)
	je         .extendedModelId
	cmp        r9b, 0x06
	je         .extendedModelId
	jmp        .additionalInfo

.extendedModelId:
	mov        r9d, eax
	shr        r9d, 12
	and        r9b, 0xf0
	add        al, r9b

.additionalInfo:
	mov        r8b, al
	mov        [rdi+72], r8

	xor        rax, rax
	mov        ah, bh                 ; clflush size
	shl        rax, 24
	mov        al, bl                 ; brand index
	mov        [rdi+80], rax

	shr        ebx, 16                ; number of logical processors
	xor        bh, bh
	mov        [rdi+88], ebx

.featureFlags:
	xor        eax, eax
	mov        al, dl
	mov        ah, dl

	movd       xmm0, eax
	pshuflw    xmm0, xmm0, 0b

	mov        al, dh
	mov        ah, dh

	movd       xmm1, eax
	pshuflw    xmm1, xmm1, 0b
	movlhps    xmm0, xmm1

	mov        rax, 0x8040201008040201
	movq       xmm2, rax
	movlhps    xmm2, xmm2

	mov        rax, 0x0101010101010101
	movq       xmm3, rax
	movlhps    xmm3, xmm3

	pxor       xmm4, xmm4
	pand       xmm0, xmm2
	pcmpeqb    xmm0, xmm4
	pandn      xmm0, xmm3

	movdqa     [rdi+96], xmm0         ; cpuid->hasx87Fpu = xmm0

	shr        edx, 16
	mov        al, dl
	mov        ah, dl

	movd       xmm0, eax
	pshuflw    xmm0, xmm0, 0b

	mov        al, dh
	mov        ah, dh

	movd       xmm1, eax
	pshuflw    xmm1, xmm1, 0b
	movlhps    xmm0, xmm1

	pand       xmm0, xmm2
	pcmpeqb    xmm0, xmm4
	pandn      xmm0, xmm3

	movdqa     [rdi+112], xmm0         ; cpuid->hasPageAttrTable = xmm0

	mov        al, cl
	mov        ah, cl

	movd       xmm0, eax
	pshuflw    xmm0, xmm0, 0b

	mov        al, ch
	mov        ah, ch

	movd       xmm1, eax
	pshuflw    xmm1, xmm1, 0b
	movlhps    xmm0, xmm1

	pand       xmm0, xmm2
	pcmpeqb    xmm0, xmm4
	pandn      xmm0, xmm3

	movdqa     [rdi+128], xmm0         ; cpuid->hasSSE3 = xmm0

	shr        ecx, 16
	mov        al, cl
	mov        ah, cl

	movd       xmm0, eax
	pshuflw    xmm0, xmm0, 0b

	mov        al, ch
	mov        ah, ch

	movd       xmm1, eax
	pshuflw    xmm1, xmm1, 0b
	movlhps    xmm0, xmm1

	pand       xmm0, xmm2
	pcmpeqb    xmm0, xmm4
	pandn      xmm0, xmm3

	movdqa     [rdi+144], xmm0         ; cpuid->boolReserved3 = xmm0

.epilogue:                            ; functions typically have an epilogue
	mov        rbx, rsi               ; restore rbx value from rsi
	ret                               ; pop return address from stack and jump there

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~ f618482d_getVendorID ~~~~~~~~~~~~~~~~~~~~~~~~~~~

	global  f618482d_getVendorID:function
	section .text
f618482d_getVendorID:
; Parameters:
;	rdi : CPUID *cpuid
; Local Variables:
;	eax : information category
;	ebx : first four characters of vendor ID
;	edx : next four characters of vendor ID
;	ecx : last four characters of vendor ID
;	rsi : preserve rbx value

.prologue:                            ; functions typically have a prologue
	mov        eax, VENDOR_ID         ; retrieve Vendor ID
	mov        rsi, rbx               ; preserve rbx value in rsi
	xor        rcx, rcx               ; rcx = 0

.vendorId:
	cpuid

	shl        rdx, 32
	or         rbx, rdx

	mov        [rdi+48], rbx             ; populate cpuid->vendorId[] string
	mov        [rdi+56], rcx
	mov        [rdi+64], eax          ; cpuid->maxCpuIdLevel = eax

.epilogue:                            ; functions typically have an epilogue
	mov        rbx, rsi               ; restore rbx value from rsi
	ret                               ; pop return address from stack and jump there

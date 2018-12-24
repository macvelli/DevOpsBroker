	.file	"ipv4address.c"
	.text
	.globl	e1e7e8f5_toString_ipAddress
	.type	e1e7e8f5_toString_ipAddress, @function
e1e7e8f5_toString_ipAddress:
.LFB9:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -40(%rbp)
	movl	%esi, %eax
	movb	%al, -44(%rbp)
	movl	$20, %edi
	call	malloc@PLT
	movq	%rax, -8(%rbp)
	movq	-8(%rbp), %rax
	movq	%rax, -16(%rbp)
	movq	-40(%rbp), %rax
	movl	(%rax), %eax
	movl	%eax, -28(%rbp)
	movl	-28(%rbp), %eax
	shrl	$24, %eax
	movl	%eax, -24(%rbp)
	cmpl	$99, -24(%rbp)
	jbe	.L2
	movl	-24(%rbp), %ecx
	movl	$1374389535, %edx
	movl	%ecx, %eax
	mull	%edx
	movl	%edx, %eax
	shrl	$5, %eax
	imull	$100, %eax, %eax
	subl	%eax, %ecx
	movl	%ecx, %eax
	movl	%eax, -20(%rbp)
	movl	-24(%rbp), %eax
	movl	$1374389535, %edx
	mull	%edx
	movl	%edx, %eax
	shrl	$5, %eax
	movl	%eax, -24(%rbp)
	movl	-24(%rbp), %eax
	leal	48(%rax), %ecx
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	%ecx, %edx
	movb	%dl, (%rax)
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	-20(%rbp), %ecx
	leaq	f6215943_digitTens(%rip), %rdx
	movzbl	(%rcx,%rdx), %edx
	movb	%dl, (%rax)
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	-20(%rbp), %ecx
	leaq	f6215943_digitOnes(%rip), %rdx
	movzbl	(%rcx,%rdx), %edx
	movb	%dl, (%rax)
	jmp	.L3
.L2:
	cmpl	$9, -24(%rbp)
	jbe	.L4
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	-24(%rbp), %ecx
	leaq	f6215943_digitTens(%rip), %rdx
	movzbl	(%rcx,%rdx), %edx
	movb	%dl, (%rax)
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	-24(%rbp), %ecx
	leaq	f6215943_digitOnes(%rip), %rdx
	movzbl	(%rcx,%rdx), %edx
	movb	%dl, (%rax)
	jmp	.L3
.L4:
	movl	-24(%rbp), %eax
	leal	48(%rax), %ecx
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	%ecx, %edx
	movb	%dl, (%rax)
.L3:
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movb	$46, (%rax)
	movl	-28(%rbp), %eax
	shrl	$16, %eax
	andl	$255, %eax
	movl	%eax, -24(%rbp)
	cmpl	$99, -24(%rbp)
	jbe	.L5
	movl	-24(%rbp), %ecx
	movl	$1374389535, %edx
	movl	%ecx, %eax
	mull	%edx
	movl	%edx, %eax
	shrl	$5, %eax
	imull	$100, %eax, %eax
	subl	%eax, %ecx
	movl	%ecx, %eax
	movl	%eax, -20(%rbp)
	movl	-24(%rbp), %eax
	movl	$1374389535, %edx
	mull	%edx
	movl	%edx, %eax
	shrl	$5, %eax
	movl	%eax, -24(%rbp)
	movl	-24(%rbp), %eax
	leal	48(%rax), %ecx
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	%ecx, %edx
	movb	%dl, (%rax)
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	-20(%rbp), %ecx
	leaq	f6215943_digitTens(%rip), %rdx
	movzbl	(%rcx,%rdx), %edx
	movb	%dl, (%rax)
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	-20(%rbp), %ecx
	leaq	f6215943_digitOnes(%rip), %rdx
	movzbl	(%rcx,%rdx), %edx
	movb	%dl, (%rax)
	jmp	.L6
.L5:
	cmpl	$9, -24(%rbp)
	jbe	.L7
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	-24(%rbp), %ecx
	leaq	f6215943_digitTens(%rip), %rdx
	movzbl	(%rcx,%rdx), %edx
	movb	%dl, (%rax)
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	-24(%rbp), %ecx
	leaq	f6215943_digitOnes(%rip), %rdx
	movzbl	(%rcx,%rdx), %edx
	movb	%dl, (%rax)
	jmp	.L6
.L7:
	movl	-24(%rbp), %eax
	leal	48(%rax), %ecx
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	%ecx, %edx
	movb	%dl, (%rax)
.L6:
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movb	$46, (%rax)
	movl	-28(%rbp), %eax
	shrl	$8, %eax
	andl	$255, %eax
	movl	%eax, -24(%rbp)
	cmpl	$99, -24(%rbp)
	jbe	.L8
	movl	-24(%rbp), %ecx
	movl	$1374389535, %edx
	movl	%ecx, %eax
	mull	%edx
	movl	%edx, %eax
	shrl	$5, %eax
	imull	$100, %eax, %eax
	subl	%eax, %ecx
	movl	%ecx, %eax
	movl	%eax, -20(%rbp)
	movl	-24(%rbp), %eax
	movl	$1374389535, %edx
	mull	%edx
	movl	%edx, %eax
	shrl	$5, %eax
	movl	%eax, -24(%rbp)
	movl	-24(%rbp), %eax
	leal	48(%rax), %ecx
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	%ecx, %edx
	movb	%dl, (%rax)
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	-20(%rbp), %ecx
	leaq	f6215943_digitTens(%rip), %rdx
	movzbl	(%rcx,%rdx), %edx
	movb	%dl, (%rax)
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	-20(%rbp), %ecx
	leaq	f6215943_digitOnes(%rip), %rdx
	movzbl	(%rcx,%rdx), %edx
	movb	%dl, (%rax)
	jmp	.L9
.L8:
	cmpl	$9, -24(%rbp)
	jbe	.L10
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	-24(%rbp), %ecx
	leaq	f6215943_digitTens(%rip), %rdx
	movzbl	(%rcx,%rdx), %edx
	movb	%dl, (%rax)
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	-24(%rbp), %ecx
	leaq	f6215943_digitOnes(%rip), %rdx
	movzbl	(%rcx,%rdx), %edx
	movb	%dl, (%rax)
	jmp	.L9
.L10:
	movl	-24(%rbp), %eax
	leal	48(%rax), %ecx
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	%ecx, %edx
	movb	%dl, (%rax)
.L9:
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movb	$46, (%rax)
	movl	-28(%rbp), %eax
	movzbl	%al, %eax
	movl	%eax, -24(%rbp)
	cmpl	$99, -24(%rbp)
	jbe	.L11
	movl	-24(%rbp), %ecx
	movl	$1374389535, %edx
	movl	%ecx, %eax
	mull	%edx
	movl	%edx, %eax
	shrl	$5, %eax
	imull	$100, %eax, %eax
	subl	%eax, %ecx
	movl	%ecx, %eax
	movl	%eax, -20(%rbp)
	movl	-24(%rbp), %eax
	movl	$1374389535, %edx
	mull	%edx
	movl	%edx, %eax
	shrl	$5, %eax
	movl	%eax, -24(%rbp)
	movl	-24(%rbp), %eax
	leal	48(%rax), %ecx
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	%ecx, %edx
	movb	%dl, (%rax)
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	-20(%rbp), %ecx
	leaq	f6215943_digitTens(%rip), %rdx
	movzbl	(%rcx,%rdx), %edx
	movb	%dl, (%rax)
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	-20(%rbp), %ecx
	leaq	f6215943_digitOnes(%rip), %rdx
	movzbl	(%rcx,%rdx), %edx
	movb	%dl, (%rax)
	jmp	.L12
.L11:
	cmpl	$9, -24(%rbp)
	jbe	.L13
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	-24(%rbp), %ecx
	leaq	f6215943_digitTens(%rip), %rdx
	movzbl	(%rcx,%rdx), %edx
	movb	%dl, (%rax)
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	-24(%rbp), %ecx
	leaq	f6215943_digitOnes(%rip), %rdx
	movzbl	(%rcx,%rdx), %edx
	movb	%dl, (%rax)
	jmp	.L12
.L13:
	movl	-24(%rbp), %eax
	leal	48(%rax), %ecx
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	%ecx, %edx
	movb	%dl, (%rax)
.L12:
	movq	-40(%rbp), %rax
	movl	12(%rax), %eax
	movl	%eax, -24(%rbp)
	cmpb	$0, -44(%rbp)
	je	.L14
	cmpl	$0, -24(%rbp)
	je	.L14
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movb	$47, (%rax)
	cmpl	$9, -24(%rbp)
	jbe	.L15
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	-24(%rbp), %ecx
	leaq	f6215943_digitTens(%rip), %rdx
	movzbl	(%rcx,%rdx), %edx
	movb	%dl, (%rax)
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	-24(%rbp), %ecx
	leaq	f6215943_digitOnes(%rip), %rdx
	movzbl	(%rcx,%rdx), %edx
	movb	%dl, (%rax)
	jmp	.L14
.L15:
	movl	-24(%rbp), %eax
	leal	48(%rax), %ecx
	movq	-16(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -16(%rbp)
	movl	%ecx, %edx
	movb	%dl, (%rax)
.L14:
	movq	-16(%rbp), %rax
	movb	$0, (%rax)
	movq	-8(%rbp), %rax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE9:
	.size	e1e7e8f5_toString_ipAddress, .-e1e7e8f5_toString_ipAddress
	.ident	"GCC: (Ubuntu 7.3.0-27ubuntu1~18.04) 7.3.0"
	.section	.note.GNU-stack,"",@progbits

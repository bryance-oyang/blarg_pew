/*
 * The barebones ducky hello world.
 *
 * This is for fun only. If this breaks your computer, it is your fault,
 * no warranties of any kind, no implied warranties, blah blah ok
 */

/*
 * Note that memory segment registers (cs, ds, ss, es) refer to every 16
 * bytes, i.e. 0x0123 in these registers refers to 0x1230 in memory
 */

/*
 * When the processor starts, it executes whatever is in a special
 * default memory address. This is usually hardware-mapped to the BIOS.
 *
 * The first 512 bytes of a disk is the bootsector. The BIOS looks at
 * the last 2 bytes of the bootsector. These should be 0xaa55 to
 * indicate the disk is bootable.
 *
 * The BIOS loads the bootsector to 0x7c00 and the cpu starts executing
 * at 0x7c00
 *
 * The following 2 commands will create the entire bootsector (assuming
 * gcc/linux):
 *	as boot.s -c -o boot.o
 *	ld --oformat binary --Ttext 0x7c00 --entry=blarg -o boot boot.o
 *
 * The ld is necessary to make the output the correct format.
 *
 * "--oformat binary" specifies the output file should be pure binary
 * machine code, i.e. (no ELF nonsense)
 *
 * "--Ttext 0x7c00" specifies the absolute address for the .text section
 * to be 0x7c00 (because the bootsector is loaded there by the BIOS).
 * Jump labels' addresses will all be adjusted to account for this
 * offset. The linux kernel does not use this ld flag, and instead does
 * the following:
 *
 *	ljmp	$0x07c0, $start2
 * start2:
 *	movw	%cs, %ax
 *
 * and then copies %ax to %ss, %ds, %es. ljmp has the format ljmp [cs
 * register value], [ip register value]. Refer to arch/x86/boot/header.S
 * in linux source code
 *
 * "--entry=blarg" specifies that blarg is the entry point (like C
 * main())
 *
 * Now you have a 512 byte binary file containing the raw bootsector. Do
 * whatever you want with it (probably boot it?) Suggestion:
 *	dd if=boot of=/dev/u_know_the_drill
 *
 * See Makefile for how to ISO
 */

/* 16-bit assembly */
.code16
.text

/* .global makes blarg visible to the linker ld */
.global blarg
blarg:
	cli			# disable interrupts (clear bit)
	movw	$0x17c0, %ax	# must move register into %ss
	movw	%ax, %ss	# put stack segment there
	movw	$1024, %sp	# 1024 bytes stack
	sti			# enable interrupts (set bit)

	movw	$hehe, %di
	call	puts
done:
	hlt
	jmp	done

/*
 * puts: basically the same behavior as the usual C puts(), but it uses
 * the BIOS interrupt calls to call BIOS magic to control the screen,
 * rather than OS kernel write() syscall interrupt (we don't have an OS)
 */
puts:
	movb	(%di), %al
	testb	%al, %al	# assuming null terminated string
	jz	puts_end

	/* set up the interrupt args in the registers */
	movb	$0x0e, %ah	# tty write interrupt
	movb	$0x0a, %bl	# font color: sexy green, if possible
	movb	$0x00, %bh	# page number
	int	$0x10		# activate BIOS video interrupt

	inc	%di
	jmp	puts
puts_end:
	ret

hehe:
	/* asciz: the "z" indicates null-terminated string */
	.asciz "ducky says: hello, world!"

/*
 * The following will add 0xaa55 to the last 2 bytes of the bootsector
 * to indicate to the BIOS that this disk is bootable
 *
 * Either do ".org 510, 0" or ". = blarg + 510"
 */
.org 510, 0	# advance to 510, filling intermediate space with 0's
.short 0xaa55	# write two bytes, 0x55 and 0xaa, in that order (little endian)

/*
 * The barebones ducky hello world.
 *
 * This is for fun only. If this breaks your computer, it is your fault,
 * no warranties of any kind, no implied warranties, blah blah ok
 */

/*
 * When the processor starts, it executes whatever is in a special
 * default memory address. This is mapped to the BIOS.
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
 * as boot.s -c -o boot.o
 * ld --oformat binary --Ttext 0x7c00 -o boot
 *
 * The ld is necessary to make the output the correct format.
 * "--oformat binary" specifies the output file should be pure binary,
 * i.e. (no ELF nonsense)
 * "--Ttext 0x7c00" specifies the absolute address for the .text section
 * to be 0x7c00 (because the bootsector is loaded there by the BIOS)
 *
 * Now you have a 512
 */

/* 16-bit assembly */
.code16
.text

_start:
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
 * puts: basically the same function as the usual C puts(), but it uses
 * the BIOS interrupt calls to call BIOS magic to control the screen,
 * rather than OS kernel write() syscall interrupt (we don't have an OS)
 */
puts:
	movb	(%di), %al
	testb	%al, %al
	jz	puts_end

	movb	$0x0e, %ah	# tty write interrupt
	movb	$0x0a, %bl	# font color: sexy green, if possible
	movb	$0x00, %bh	# page number
	int	$0x10		# BIOS interrupt

	inc	%di
	jmp	puts
puts_end:
	ret

hehe:
	/* asciz: the "z" indicates null-terminated string */
	.asciz "hello, world!"

/*
 * The following will add 0xaa55 to the last 2 bytes of the bootsector
 * to indicate to the BIOS that this disk is bootable
 *
 * Either do ".org 510, 0" or ". = blarg + 510"
 */
.org 510, 0
.short 0xaa55

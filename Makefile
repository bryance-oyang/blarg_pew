all: boot.o
	ld --oformat binary --Ttext 0x7c00 -o boot.img boot.o
	chmod -x boot.img

iso: boot.o
	mkdir -p fs
	ld --oformat binary --Ttext 0x7c00 -o fs/boot boot.o
	chmod -x fs/boot
	genisoimage -b boot -no-emul-boot -o boot.iso fs

boot.o:
	as boot.s -c -o boot.o

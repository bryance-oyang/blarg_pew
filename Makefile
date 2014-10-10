all: raw iso

raw: boot

iso: boot.iso

boot: boot.o
	ld --oformat binary --Ttext 0x7c00 --entry=blarg -o boot boot.o
	chmod -x boot

boot.iso: boot.o
	mkdir -p fs
	ld --oformat binary --Ttext 0x7c00 --entry=blarg -o fs/boot boot.o
	chmod -x fs/boot
	genisoimage -J -r -b boot -c boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o boot.iso fs

boot.o: boot.s
	as boot.s -c -o boot.o

clean:
	-rm boot
	-rm boot.iso

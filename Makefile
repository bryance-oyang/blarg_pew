all: boot.img

iso: boot.iso

boot.img: boot.o
	ld --oformat binary --Ttext 0x7c00 --entry=blarg -o boot.img boot.o
	chmod -x boot.img

boot.iso: boot.o
	mkdir -p fs
	ld --oformat binary --Ttext 0x7c00 --entry=blarg -o fs/boot boot.o
	chmod -x fs/boot
	genisoimage -R -b boot -no-emul-boot -boot-load-size 4 -boot-info-table -o boot.iso fs

boot.o: boot.s
	as -nostdlib boot.s -c -o boot.o

clean:
	-rm boot.img
	-rm boot.iso

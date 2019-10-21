
IMGFILE=haribote.img
IPLFILE=ipl10.asm

all : $(IMGFILE)

ipl.bin : $(IPLFILE)
	nasm $^ -o $@ -l ipl.lst

asmhead.bin : asmhead.asm
	nasm $^ -o $@ -l asmhead.lst

bootpack.bin : bootpack.c
	gcc -march=i486 -m32 -fno-pic -nostdlib -T hrb.ld $^ -o $@

haribote.sys : asmhead.bin bootpack.bin
	cat $^ > $@

$(IMGFILE) : ipl.bin haribote.sys
	mformat -f 1440 -B ipl.bin -C -i $@ ::
	mcopy haribote.sys -i $@ ::
#	1440[KB] (= 512 * 2880 byte)
#	C: to install on MS-DOS file system

run : $(IMGFILE)
	qemu-system-i386 -fda $(IMGFILE)
# -fda: use 'file' as floppy disk 0/1 image

clean : 
	rm $(IMGFILE) \
	   ipl.bin ipl.lst \
	   asmhead.bin asnhead.lst \
	   bootpack.bin \
	   haribote.sys haribote.lst

IMGFILE=haribote.img
IPLFILE=ipl10.asm

all : $(IMGFILE)

ipl10.bin : $(IPLFILE)
	nasm $^ -o $@ -l $(@:.bin=.lst)

asmhead.bin : asmhead.asm
	nasm $^ -o $@ -l $(@:.bin=.lst)

bootpack.o : bootpack.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $^

nasmfunc.o : nasmfunc.asm
	nasm -f elf32 $^ -o $@ -l $(@:.o=.lst)

bootpack.bin : bootpack.o nasmfunc.o
	ld -m elf_i386 -e HariMain -o $@ -T hrb.ld $^
	# gcc -march=i486 -m32 -fno-pic -nostdlib -T hrb.ld $^ -o $@

haribote.sys : asmhead.bin bootpack.bin
	cat $^ > $@

$(IMGFILE) : ipl10.bin haribote.sys
	mformat -f 1440 -B ipl10.bin -C -i $@ ::
	mcopy haribote.sys -i $@ ::
#	1440[KB] (= 512 * 2880 byte)
#	C: to install on MS-DOS file system

run : $(IMGFILE)
	qemu-system-i386 -fda $(IMGFILE)
# -fda: use 'file' as floppy disk 0/1 image

clean : 
	rm $(IMGFILE) \
	   ipl10.bin ipl10.lst \
	   asmhead.bin asmhead.lst \
	   bootpack.o \
	   nasmfunc.o nasmfunc.lst \
	   bootpack.bin \
	   haribote.sys haribote.lst

#########

nimsrc :
	nim c \
	    --cpu:i386 \
	    --passC:-m32 \
	    --passC:-fno-pic \
	    --passC:-nostdlib \
	    --passL:-m32 \
	    --nimcache:./nimcache \
	    bootpack.nim

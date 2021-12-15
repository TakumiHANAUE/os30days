
IMGFILE=haribote.img
IPLFILE=ipl10.asm
GOLIBCPATH=./golibc
CSOURCES=$(wildcard *.c)
COBJS=$(CSOURCES:.c=.o)
OBJS=$(COBJS) nasmfunc.o

.PHONY : all
all : $(IMGFILE)

ipl10.bin : $(IPLFILE)
	nasm $^ -o $@ -l $(@:.bin=.lst)

asmhead.bin : asmhead.asm
	nasm $^ -o $@ -l $(@:.bin=.lst)

%.o : %.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -Wall

nasmfunc.o : nasmfunc.asm
	nasm -f elf32 $^ -o $@ -l $(@:.o=.lst)

bootpack.bin : $(OBJS) $(GOLIBCPATH)/libgolibc.a
	ld -m elf_i386 -e HariMain -o $@ -T hrb.ld $(OBJS) -static -L$(GOLIBCPATH) -lgolibc -Map bootpack.map

hlt.hrb : hlt.asm
	nasm $^ -o $@ -l $(@:.hrb=.lst)

haribote.sys : asmhead.bin bootpack.bin
	cat $^ > $@

$(IMGFILE) : ipl10.bin haribote.sys hlt.hrb
	mformat -f 1440 -B ipl10.bin -C -i $@ ::
	mcopy haribote.sys -i $@ ::
	mcopy ipl10.asm -i $@ ::
	mcopy Makefile -i $@ ::
	mcopy hlt.hrb -i $@ ::
#	1440[KB] (= 512 * 2880 byte)
#	C: to install on MS-DOS file system

.PHONY : run
run : $(IMGFILE)
	qemu-system-i386 -fda $(IMGFILE)
# -fda: use 'file' as floppy disk 0/1 image

.PHONY : clean
clean : 
	rm $(IMGFILE) \
	   ipl10.bin ipl10.lst \
	   asmhead.bin asmhead.lst \
	   $(OBJS) \
	   nasmfunc.lst \
	   bootpack.bin bootpack.map\
	   hlt.hrb hlt.lst \
	   haribote.sys
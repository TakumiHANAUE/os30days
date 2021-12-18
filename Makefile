
IMGFILE=haribote.img
IPLFILE=ipl10.asm
GOLIBCPATH=./golibc
CSOURCES=$(wildcard *.c)
COBJS=$(CSOURCES:.c=.o)
OBJS=$(COBJS) nasmfunc.o
APPDIR=app

.PHONY : all
all : $(IMGFILE)

# OS files

ipl10.bin : $(IPLFILE)
	nasm $^ -o $@ -l $(@:.bin=.lst)

asmhead.bin : asmhead.asm
	nasm $^ -o $@ -l $(@:.bin=.lst)

%.o : %.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -I$(GOLIBCPATH) -Wall

nasmfunc.o : nasmfunc.asm
	nasm -f elf32 $^ -o $@ -l $(@:.o=.lst)

bootpack.bin : $(OBJS) $(GOLIBCPATH)/libgolibc.a
	ld -m elf_i386 -e HariMain -o $@ -T hrb.ld $(OBJS) -static -L$(GOLIBCPATH) -lgolibc -Map bootpack.map

haribote.sys : asmhead.bin bootpack.bin
	cat $^ > $@

# Application
$(APPDIR)/.app : 
	make -C app

$(IMGFILE) : ipl10.bin haribote.sys $(APPDIR)/.app
	mformat -f 1440 -B ipl10.bin -C -i $@ ::
	mcopy haribote.sys -i $@ ::
	mcopy ipl10.asm -i $@ ::
	mcopy Makefile -i $@ ::
	mcopy $(APPDIR)/hello.hrb -i $@ ::
	mcopy $(APPDIR)/hello2.hrb -i $@ ::
	mcopy $(APPDIR)/a.hrb -i $@ ::
	mcopy $(APPDIR)/hello3.hrb -i $@ ::
	mcopy $(APPDIR)/hello4.hrb -i $@ ::
	mcopy $(APPDIR)/hello5.hrb -i $@ ::
	mcopy $(APPDIR)/winhelo.hrb -i $@ ::
	mcopy $(APPDIR)/winhelo2.hrb -i $@ ::
	mcopy $(APPDIR)/winhelo3.hrb -i $@ ::
	mcopy $(APPDIR)/star1.hrb -i $@ ::
	mcopy $(APPDIR)/stars.hrb -i $@ ::
	mcopy $(APPDIR)/stars2.hrb -i $@ ::
	mcopy $(APPDIR)/lines.hrb -i $@ ::
	mcopy $(APPDIR)/walk.hrb -i $@ ::
	mcopy $(APPDIR)/noodle.hrb -i $@ ::
#	1440[KB] (= 512 * 2880 byte)
#	C: to install on MS-DOS file system

.PHONY : run
run : $(IMGFILE)
	qemu-system-i386 -fda $(IMGFILE)
# -fda: use 'file' as floppy disk 0/1 image

.PHONY : clean
clean : 
	rm $(IMGFILE) \
	   ipl10.bin \
	   asmhead.bin \
	   $(OBJS) \
	   bootpack.bin bootpack.map\
	   *.lst \
	   haribote.sys

.PHONY : appclean
appclean : 
	make -C app clean

.PHONY : allclean
allclean :
	make clean
	make -C app clean

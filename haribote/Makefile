
IMGFILE=haribote.img
IPLFILE=ipl20.asm
GOLIBCPATH=../golibc
CSOURCES=$(wildcard *.c)
COBJS=$(CSOURCES:.c=.o)
OBJS=$(COBJS) nasmfunc.o
APPDIR=../app

.PHONY : all
all : $(IMGFILE)

# OS files

ipl20.bin : $(IPLFILE)
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
	make -C $(APPDIR)

$(IMGFILE) : ipl20.bin haribote.sys $(APPDIR)/.app
	mformat -f 1440 -B ipl20.bin -C -i $@ ::
	mcopy haribote.sys -i $@ ::
	mcopy ipl20.asm -i $@ ::
	mcopy Makefile -i $@ ::
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
	mcopy $(APPDIR)/beepdown.hrb -i $@ ::
	mcopy $(APPDIR)/color.hrb -i $@ ::
	mcopy $(APPDIR)/color2.hrb -i $@ ::
	mcopy $(APPDIR)/sosu.hrb -i $@ ::
	mcopy $(APPDIR)/sosu2.hrb -i $@ ::
	mcopy $(APPDIR)/sosu3.hrb -i $@ ::
	mcopy $(APPDIR)/typeipl.hrb -i $@ ::
	mcopy $(APPDIR)/type.hrb -i $@ ::
	mcopy $(APPDIR)/iroha.hrb -i $@ ::
	mcopy $(APPDIR)/chklang.hrb -i $@ ::
	mcopy ../euc.txt -i $@ ::
	mcopy ../nihongo/nihongo.fnt -i $@ ::
#	1440[KB] (= 512 * 2880 byte)
#	C: to install on MS-DOS file system

.PHONY : run
run : $(IMGFILE)
	qemu-system-i386 -fda $(IMGFILE)
# -fda: use 'file' as floppy disk 0/1 image

.PHONY : clean
clean : 
	$(shell [ -e $(OBJDIR) ] && rm $(IMGFILE))
	rm ipl20.bin \
	   asmhead.bin \
	   $(OBJS) \
	   bootpack.bin bootpack.map\
	   *.lst \
	   haribote.sys

.PHONY : appclean
appclean : 
	make -C $(APPDIR) clean

.PHONY : allclean
allclean :
	make clean
	make -C $(APPDIR) clean

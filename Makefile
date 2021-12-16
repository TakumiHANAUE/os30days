
IMGFILE=haribote.img
IPLFILE=ipl10.asm
GOLIBCPATH=./golibc
CSOURCES=$(wildcard *.c)
COBJS=$(CSOURCES:.c=.o)
OBJS=$(COBJS) nasmfunc.o
APPDIR=app
APPASMSOURCES=$(APPDIR)/hello.asm $(APPDIR)/hello2.asm
APPCSOURCES=$(wildcard $(APPDIR)/*.c)
HRBFILES=$(APPASMSOURCES:.asm=.hrb) $(APPCSOURCES:.c=.hrb)

.PHONY : all
all : $(IMGFILE)

# OS files

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

haribote.sys : asmhead.bin bootpack.bin
	cat $^ > $@

# Application

$(APPDIR)/hello.hrb : $(APPDIR)/hello.asm
	nasm $^ -o $@ -l $(@:.hrb=.lst)

$(APPDIR)/hello2.hrb : $(APPDIR)/hello2.asm
	nasm $^ -o $@ -l $(@:.hrb=.lst)

$(APPDIR)/a_nasm.o : $(APPDIR)/a_nasm.asm
	nasm -f elf32 $^ -o $@ -l $(@:.o=.lst)

$(APPDIR)/a.o : $(APPDIR)/a.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -Wall

$(APPDIR)/a.hrb : $(APPDIR)/a.o $(APPDIR)/a_nasm.o
	ld -m elf_i386 -e HariMain -o $@ -T $(APPDIR)/app.ld $^ -Map $(@:.hrb=.map)

$(APPDIR)/hello3.o : $(APPDIR)/hello3.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -Wall

$(APPDIR)/hello3.hrb : $(APPDIR)/hello3.o $(APPDIR)/a_nasm.o
	ld -m elf_i386 -e HariMain -o $@ -T $(APPDIR)/app.ld $^ -Map $(@:.hrb=.map)

$(APPDIR)/crack1.o : $(APPDIR)/crack1.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -Wall

$(APPDIR)/crack1.hrb : $(APPDIR)/crack1.o $(APPDIR)/a_nasm.o
	ld -m elf_i386 -e HariMain -o $@ -T $(APPDIR)/app.ld $^ -Map $(@:.hrb=.map)


# Generate Image file

$(IMGFILE) : ipl10.bin haribote.sys $(HRBFILES)
	mformat -f 1440 -B ipl10.bin -C -i $@ ::
	mcopy haribote.sys -i $@ ::
	mcopy ipl10.asm -i $@ ::
	mcopy Makefile -i $@ ::
	mcopy $(APPDIR)/hello.hrb -i $@ ::
	mcopy $(APPDIR)/hello2.hrb -i $@ ::
	mcopy $(APPDIR)/a.hrb -i $@ ::
	mcopy $(APPDIR)/hello3.hrb -i $@ ::
	mcopy $(APPDIR)/crack1.hrb -i $@ ::
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
	rm $(APPDIR)/*.o \
	   $(APPDIR)/*.lst \
	   $(APPDIR)/*.hrb \
	   $(APPDIR)/*.map

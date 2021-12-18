APPASMSOURCES=hello.asm hello2.asm hello5.asm
APPCSOURCES=$(wildcard *.c)
HRBFILES=$(APPASMSOURCES:.asm=.hrb) $(APPCSOURCES:.c=.hrb)
GOLIBCPATH=../golibc

.PHONY : all
all : $(HRBFILES)
	touch .app

hello.hrb : hello.asm
	nasm $^ -o $@ -l $(@:.hrb=.lst)

hello2.hrb : hello2.asm
	nasm $^ -o $@ -l $(@:.hrb=.lst)

a_nasm.o : a_nasm.asm
	nasm -f elf32 $^ -o $@ -l $(@:.o=.lst)

a.o : a.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -Wall

a.hrb : a.o a_nasm.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -Map $(@:.hrb=.map)

hello3.o : hello3.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -Wall

hello3.hrb : hello3.o a_nasm.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -Map $(@:.hrb=.map)

hello4.o : hello4.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -Wall

hello4.hrb : hello4.o a_nasm.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -Map $(@:.hrb=.map)

hello5.o : hello5.asm
	nasm -f elf32 $^ -o $@ -l $(@:.o=.lst)

hello5.hrb : hello5.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -Map $(@:.hrb=.map)

winhelo.o : winhelo.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -Wall

winhelo.hrb : winhelo.o a_nasm.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -Map $(@:.hrb=.map)

winhelo2.o : winhelo2.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -Wall

winhelo2.hrb : winhelo2.o a_nasm.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -Map $(@:.hrb=.map)

winhelo3.o : winhelo3.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -Wall

winhelo3.hrb : winhelo3.o a_nasm.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -Map $(@:.hrb=.map)

star1.o : star1.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -Wall

star1.hrb : star1.o a_nasm.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -Map $(@:.hrb=.map)

stars.o : stars.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -Wall

stars.hrb : stars.o a_nasm.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(GOLIBCPATH) -lgolibc -Map $(@:.hrb=.map)

.PHONY : clean
clean : 
	rm *.o \
	   *.lst \
	   *.hrb \
	   *.map \
	   .app

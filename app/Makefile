APPASMSOURCES=hello.asm hello2.asm hello5.asm crack7.asm
APPCSOURCES=$(wildcard *.c)
HRBFILES=$(APPASMSOURCES:.asm=.hrb) $(APPCSOURCES:.c=.hrb)
APPLIBPATH=../applib
GOLIBCPATH=../golibc

.PHONY : all
all : $(HRBFILES)
	touch .app

hello.hrb : hello.asm
	nasm $^ -o $@ -l $(@:.hrb=.lst)

hello2.hrb : hello2.asm
	nasm $^ -o $@ -l $(@:.hrb=.lst)

a.o : a.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -Wall

a.hrb : a.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(APPLIBPATH) -lapplib -Map $(@:.hrb=.map)

hello3.o : hello3.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -Wall

hello3.hrb : hello3.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(APPLIBPATH) -lapplib -Map $(@:.hrb=.map)

hello4.o : hello4.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -Wall

hello4.hrb : hello4.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(APPLIBPATH) -lapplib -Map $(@:.hrb=.map)

hello5.o : hello5.asm
	nasm -f elf32 $^ -o $@ -l $(@:.o=.lst)

hello5.hrb : hello5.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -Map $(@:.hrb=.map)

winhelo.o : winhelo.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -Wall

winhelo.hrb : winhelo.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(APPLIBPATH) -lapplib -Map $(@:.hrb=.map)

winhelo2.o : winhelo2.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -Wall

winhelo2.hrb : winhelo2.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(APPLIBPATH) -lapplib -Map $(@:.hrb=.map)

winhelo3.o : winhelo3.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -Wall

winhelo3.hrb : winhelo3.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(APPLIBPATH) -lapplib -Map $(@:.hrb=.map)

star1.o : star1.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -Wall

star1.hrb : star1.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(APPLIBPATH) -lapplib -Map $(@:.hrb=.map)

stars.o : stars.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -I$(GOLIBCPATH) -Wall

stars.hrb : stars.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(GOLIBCPATH) -lgolibc -L$(APPLIBPATH) -lapplib -Map $(@:.hrb=.map)

stars2.o : stars2.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -I$(GOLIBCPATH) -Wall

stars2.hrb : stars2.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(GOLIBCPATH) -lgolibc -L$(APPLIBPATH) -lapplib -Map $(@:.hrb=.map)

lines.o : lines.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -Wall

lines.hrb : lines.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(APPLIBPATH) -lapplib -Map $(@:.hrb=.map)

walk.o : walk.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -Wall

walk.hrb : walk.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(APPLIBPATH) -lapplib -Map $(@:.hrb=.map)

noodle.o : noodle.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -I$(GOLIBCPATH) -Wall

noodle.hrb : noodle.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(GOLIBCPATH) -lgolibc -L$(APPLIBPATH) -lapplib -Map $(@:.hrb=.map)

beepdown.o : beepdown.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -Wall

beepdown.hrb : beepdown.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(APPLIBPATH) -lapplib -Map $(@:.hrb=.map)

color.o : color.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -Wall

color.hrb : color.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(APPLIBPATH) -lapplib -Map $(@:.hrb=.map)

color2.o : color2.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -Wall

color2.hrb : color2.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(APPLIBPATH) -lapplib -Map $(@:.hrb=.map)

crack7.o : crack7.asm
	nasm -f elf32 $^ -o $@ -l $(@:.o=.lst)

crack7.hrb : crack7.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -Map $(@:.hrb=.map)

.PHONY : clean
clean : 
	rm *.o \
	   *.lst \
	   *.hrb \
	   *.map \
	   .app

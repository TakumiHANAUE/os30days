APPASMSOURCES=hello5.asm
APPCSOURCES=$(wildcard *.c)
HRBFILES=$(APPASMSOURCES:.asm=.hrb) $(APPCSOURCES:.c=.hrb)
APILIBPATH=../apilib
GOLIBCPATH=../golibc

.PHONY : all
all : $(HRBFILES)
	touch .app

a.o : a.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -I$(APILIBPATH) -Wall

a.hrb : a.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(APILIBPATH) -lapilib -Map $(@:.hrb=.map)

hello3.o : hello3.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -I$(APILIBPATH) -Wall

hello3.hrb : hello3.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(APILIBPATH) -lapilib -Map $(@:.hrb=.map)

hello4.o : hello4.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -I$(APILIBPATH) -Wall

hello4.hrb : hello4.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(APILIBPATH) -lapilib -Map $(@:.hrb=.map)

hello5.o : hello5.asm
	nasm -f elf32 $^ -o $@ -l $(@:.o=.lst)

hello5.hrb : hello5.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -Map $(@:.hrb=.map)

winhelo.o : winhelo.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -I$(APILIBPATH) -Wall

winhelo.hrb : winhelo.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(APILIBPATH) -lapilib -Map $(@:.hrb=.map)

winhelo2.o : winhelo2.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -I$(APILIBPATH) -Wall

winhelo2.hrb : winhelo2.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(APILIBPATH) -lapilib -Map $(@:.hrb=.map)

winhelo3.o : winhelo3.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -I$(APILIBPATH) -Wall

winhelo3.hrb : winhelo3.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(APILIBPATH) -lapilib -Map $(@:.hrb=.map)

star1.o : star1.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -I$(APILIBPATH) -Wall

star1.hrb : star1.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(APILIBPATH) -lapilib -Map $(@:.hrb=.map)

stars.o : stars.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -I$(GOLIBCPATH) -I$(APILIBPATH) -Wall

stars.hrb : stars.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(GOLIBCPATH) -lgolibc -L$(APILIBPATH) -lapilib -Map $(@:.hrb=.map)

stars2.o : stars2.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -I$(GOLIBCPATH) -I$(APILIBPATH) -Wall

stars2.hrb : stars2.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(GOLIBCPATH) -lgolibc -L$(APILIBPATH) -lapilib -Map $(@:.hrb=.map)

lines.o : lines.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -I$(APILIBPATH) -Wall

lines.hrb : lines.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(APILIBPATH) -lapilib -Map $(@:.hrb=.map)

walk.o : walk.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -I$(APILIBPATH) -Wall

walk.hrb : walk.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(APILIBPATH) -lapilib -Map $(@:.hrb=.map)

noodle.o : noodle.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -I$(GOLIBCPATH) -I$(APILIBPATH) -Wall

noodle.hrb : noodle.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(GOLIBCPATH) -lgolibc -L$(APILIBPATH) -lapilib -Map $(@:.hrb=.map)

beepdown.o : beepdown.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -I$(APILIBPATH) -Wall

beepdown.hrb : beepdown.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(APILIBPATH) -lapilib -Map $(@:.hrb=.map)

color.o : color.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -I$(APILIBPATH) -Wall

color.hrb : color.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(APILIBPATH) -lapilib -Map $(@:.hrb=.map)

color2.o : color2.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -I$(APILIBPATH) -Wall

color2.hrb : color2.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(APILIBPATH) -lapilib -Map $(@:.hrb=.map)

sosu.o : sosu.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -I$(GOLIBCPATH) -I$(APILIBPATH) -Wall

sosu.hrb : sosu.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(GOLIBCPATH) -lgolibc -L$(APILIBPATH) -lapilib -Map $(@:.hrb=.map)

sosu2.o : sosu2.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -I$(GOLIBCPATH) -I$(APILIBPATH) -Wall

sosu2.hrb : sosu2.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(GOLIBCPATH) -lgolibc -L$(APILIBPATH) -lapilib -Map $(@:.hrb=.map)

sosu3.o : sosu3.c
	gcc -c -m32 -fno-pic -nostdlib -o $@ $< -I$(GOLIBCPATH) -I$(APILIBPATH) -Wall

sosu3.hrb : sosu3.o
	ld -m elf_i386 -e HariMain -o $@ -T app.ld $^ -static -L$(GOLIBCPATH) -lgolibc -L$(APILIBPATH) -lapilib -Map $(@:.hrb=.map)

.PHONY : clean
clean : 
	rm *.o \
	   *.lst \
	   *.hrb \
	   *.map \
	   .app

APIASMSOURCES=$(wildcard *.asm)
APPLIBOBJECTS=$(APIASMSOURCES:.asm=.o)

.PHONY : all
all : $(APPLIBOBJECTS)
	touch .applib

%.o : %.asm
	nasm -f elf32 $^ -o $@ -l $(@:.o=.lst)

.PHONY : clean
clean : 
	rm *.o \
	   *.lst \
	   .applib
	
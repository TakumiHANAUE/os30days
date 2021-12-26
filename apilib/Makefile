TARGET=libapilib.a
APIASMSOURCES=$(wildcard *.asm)
APILIBOBJECTS=$(addprefix $(OBJDIR)/,$(APIASMSOURCES:.asm=.o))
OBJDIR=./obj

.PHONY : all
all : $(TARGET)

$(TARGET) : $(APILIBOBJECTS)
	ar rsv $@ $^

$(OBJDIR)/%.o : %.asm
	$(shell [ ! -d $(OBJDIR) ] && mkdir $(OBJDIR))
	nasm -f elf32 $^ -o $@ -l $(@:.o=.lst)

.PHONY : clean
clean : 
	rm -rf $(OBJDIR) $(TARGET)

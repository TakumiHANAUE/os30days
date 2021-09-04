TARGET	=	libgolibc.a
SRCDIR	=	./golibc
SOURCES	=	$(wildcard $(SRCDIR)/*.c)
OBJDIR	=	./obj
OBJS	=	$(subst $(SRCDIR),$(OBJDIR),$(SOURCES:.c=.o))

.PHONY : all
all: $(TARGET)

$(TARGET) : $(OBJS)
	ar rsv $@ $^

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	$(shell [ ! -d $(OBJDIR) ] && mkdir $(OBJDIR))
	gcc -c -m32 -fno-pic -nostdlib -I$(SRCDIR) -o $@ $<

.PHONY : patch
patch: $(SOURCES)
	sh ./patch.sh

.PHONY : clean
clean:
	rm -rf $(OBJDIR) $(TARGET)

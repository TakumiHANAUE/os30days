IMGFILE=haribote.img
SRCDIR=haribote

.PHONY : all
all : $(IMGFILE)

$(IMGFILE) : 
	make -C $(SRCDIR)
	mv $(SRCDIR)/$(IMGFILE) ./$(IMGFILE)

.PHONY : full
full :
	make -C golibc
	make -C apilib
	make -C app
	make all

.PHONY : clean
clean : 
	rm $(IMGFILE)
	make -C $(SRCDIR) clean

.PHONY : fullclean
fullclean :
	rm $(IMGFILE)
	make -C golibc clean
	make -C apilib clean
	make -C app clean
	make -C $(SRCDIR) clean

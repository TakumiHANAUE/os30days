IMGFILE=haribote.img
SRCDIR=haribote

.PHONY : all
all : $(IMGFILE)

$(IMGFILE) : 
	make -C haribote
	mv $(SRCDIR)/$(IMGFILE) ./$(IMGFILE)

.PHONY : clean
clean : 
	rm $(IMGFILE)
	make -C $(SRCDIR) clean

.PHONY : allclean
allclean :
	rm $(IMGFILE)
	make -C $(SRCDIR) allclean


IMGFILE=haribote.img

all : $(IMGFILE)

ipl.bin : ipl.asm
	nasm $^ -o $@ -l ipl.lst

haribote.sys : haribote.asm
	nasm $^ -o $@ -l haribote.lst

$(IMGFILE) : ipl.bin haribote.sys
	mformat -f 1440 -B ipl.bin -C -i $@ ::
	mcopy haribote.sys -i $@ ::
#	1440[KB] (= 512 * 2880 byte)
#	C: to install on MS-DOS file system

run : $(IMGFILE)
	qemu-system-i386 -fda $(IMGFILE)
# -fda: use 'file' as floppy disk 0/1 image

clean : 
	rm $(IMGFILE) ipl.bin ipl.lst haribote.sys haribote.lst haribote.name
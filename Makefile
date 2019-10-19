
IMGFILE=helloos.img

all : $(IMGFILE)

ipl.bin : ipl.asm
	nasm $^ -o $@ -l ipl.lst

$(IMGFILE) : ipl.bin
	dd if=$^ of=$@ bs=512 count=2880 conv=notrunc
# if: 入力ファイル
# of: 出力ファイル
# bs: 読み込み／書き出し単位[byte]
# count: 読み込み単位の何個分のサイズをコピーするか
#        512 * 2880 = 1474560 bytes
# conv: notrunc 出力ファイルを切り詰めない

run : $(IMGFILE)
	qemu-system-i386 -fda $(IMGFILE)
# -fda: use 'file' as floppy disk 0/1 image

clean : 
	rm $(IMGFILE) ipl.bin ipl.lst
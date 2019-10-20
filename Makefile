
IMGFILE=haribote.img

all : $(IMGFILE)

ipl.bin : ipl.asm
	nasm $^ -o $@ -l ipl.lst

haribote.sys : haribote.asm
	nasm $^ -o $@ -l haribote.lst

$(IMGFILE) : ipl.bin haribote.sys
	echo haribotesys > haribote.name
	dd if=/dev/zero of=$@ bs=512 count=2880
	dd if=ipl.bin of=$@ bs=512 count=1 conv=notrunc
	dd if=haribote.name of=$@ bs=512 count=1 seek=19 conv=notrunc
	dd if=haribote.sys of=$@ bs=512 count=1 seek=33 conv=notrunc
# if: 入力ファイル
# of: 出力ファイル
# bs: 読み込み／書き出し単位[byte]
# count: 読み込み単位の何個分のサイズをコピーするか
#        512 * 2880 = 1474560 bytes
# conv: notrunc 出力ファイルを切り詰めない
# seek: 指定ブロック数だけスキップ
#        512 * 19 = 0x2600, 512 * 33 = 0x4200

run : $(IMGFILE)
	qemu-system-i386 -fda $(IMGFILE)
# -fda: use 'file' as floppy disk 0/1 image

clean : 
	rm $(IMGFILE) ipl.bin ipl.lst haribote.sys haribote.lst haribote.name
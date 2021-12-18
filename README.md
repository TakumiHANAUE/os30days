# os30days

30 日でできる OS 自作入門

## 環境

- Ubuntu-20.04 on WSL2 on Windows10  
  img のビルドは Ubuntu-20.04 上で、img の起動は Windows10 から行う。

## 準備 (Ubuntu-20.04 on WSL2)

### 使用するソフト

- nasm

  - インストール
    ```
    $ sudo apt instal nasm
    ```
  - バージョン
    ```
    $ nasm --version
    NASM version 2.14.02
    ```

- mtools

  - インストール
    ```
    $ sudo apt instal mtools
    ```
  - バージョン
    ```
    $ mtools --version
    mtools (GNU mtools) 4.0.24
    configured with the following options: enable-xdf disable-vold disable-new-vold disable-debug enable-raw-term
    ```

- gcc
  - バージョン
    ```
    $ gcc --version
    gcc (Ubuntu 9.3.0-10ubuntu2) 9.3.0
    Copyright (C) 2019 Free Software Foundation, Inc.
    This is free software; see the source for copying conditions.  There is NO
    warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    ```

<!-- ### 環境変数

- ~/.bashrc
  Ubuntu 上で実行した画面を Windows に飛ばすための設定
  ```bash
  export DISPLAY=:0.0
  ``` -->

## 準備 (Windows10)

### インストール

- QEMU  
  エミュレーター。ビルドした img ファイルを実行するために使う。

<!-- - VcXsrv
   Ubuntu 上で実行した画面を Windows に飛ばして確認するために必要
  - 起動における設定値
    ```
    - Select display settings
        [x] Multiple windows
            Display number : -1
    - Select how to start clients
        [x] Start no client
    - Extra settings
        [x] Clipboard
            [x] Primary Selection
        [x] Native opengl
    ``` -->

- img 起動スクリプト  
  Ubuntu 上でビルドした img ファイルを QEMU を使って起動する bat ファイル。
  ```bat
  "C:\Program Files\qemu\qemu-system-i386.exe" -fda "\\wsl$\Ubuntu-20.04\PATH_TO_IMG\haribote.img"
  ```

## 参考にしたサイト

- [30 日でできる！OS 自作入門（記事一覧）[Ubuntu16.04/NASM]](https://qiita.com/pollenjp/items/b7e4392d945b8aa4ff98)

## 作業ログ

各節でやったことのメモ

### 一日目 : PC の仕組みからアセンブラ入門まで

#### とにかくやるのだぁ

- 値がすべて 0 の 1,474,560 byte のサイズを作る

  ```bash
  $ head -c 1474560 /dev/zero > helloos.img
  ```

- 書籍に従って 0 以外の値を編集する  
  VS Code の [Hex Editor](https://marketplace.visualstudio.com/items?itemName=ms-vscode.hexeditor) 拡張機能を使用した。
- コマンドプロンプトから以下コマンドを実施し、img ファイルを起動する。

  ```cmd
  > "C:\Program Files\qemu\qemu-system-i386.exe" \\wsl$\Ubuntu-20.04\PATH_TO_IMG_FILE\helloos.img
  ```

  - warning が出たけどひとまず無視
    ```
    WARNING: Image format was not specified for '\\wsl$\Ubuntu-20.04\home\takumi\tmp\os30days\helloos.img' and probing guessed raw.
       Automatically detecting the format is dangerous for raw images, write operations on block 0 will be restricted.
       Specify the 'raw' format explicitly to remove the restrictions.
    ```

#### 結局何をやったのだろうか？

メモなし。

#### アセンブラ初体験

- 著者作の nask ではなく一般的な nasm を使用する。
- 書籍記載の`helloos.nas`ではなく`helloos.asm`という名前で作る
- nasm コマンドで img ファイルを作る
  ```bash
  $ nasm helloos.asm -o helloos.img
  ```
  - warning が出たけどひとまず無視する
    ```bash
    helloos.asm:9: warning: uninitialized space declared in .text section: zeroing [-w+other]
    helloos.asm:17: warning: uninitialized space declared in .text section: zeroing [-w+other]
    helloos.asm:20: warning: uninitialized space declared in .text section: zeroing [-w+other]
    helloos.asm:22: warning: uninitialized space declared in .text section: zeroing [-w+other]
    ```

#### もうちょっと書き直してみる

- 書籍に従い `helloos.asm` を書き直す（`projects/01_day/helloos2/helloos.nas`を参照する）
- nasm コマンドでアセンブル
  ```bash
  $ nasm helloos.asm -o helloos.img
  ```
  - エラーとなる
    ```bash
    helloos.asm:41: error: attempt to reserve non-constant quantity of BSS space
    ```
    これは、nask と nasm の仕様差異によるものらしい。
    `RESB 0x1fe-$` は「現在位置から 0x1fe バイトまでを 0 で埋める」という指示だが、nasm で`$`は「式を含む行の先頭位置」を表し、`$$`は「現在のセクションの先頭位置」を表す。
    よって、`$-$$`は「現在のセクションの先頭からどのくらい進んでいるか」を意味する。
    <!-- いま`helloos.asm`はセクション1つだけなので、`$-$$`は「現在位置」を表すことになる（？） -->
    ちなみに`RESB`は*Reserve Byte*という意味
  - エラー箇所を nasm 仕様に合わせて修正する
    ```diff
    - RESB    0x1fe-$
    + RESB    0x1fe-($-$$)
    ```
- 再アセンブル

  ```bash
  $ nasm helloos.asm -o helloos.img
  ```

  エラーが消え、helloos.img が生成できた。  
  先と同じ warning が出たがひとまず気にしない。

  ```bash
  test.asm:24: warning: uninitialized space declared in .text section: zeroing [-w+other]
  test.asm:41: warning: uninitialized space declared in .text section: zeroing [-w+other]
  test.asm:48: warning: uninitialized space declared in .text section: zeroing [-w+other]
  test.asm:50: warning: uninitialized space declared in .text section: zeroing [-w+other]
  ```

【参考】

- [Ubuntu で OS 自作入門 1 日目](https://blog.shosato.jp/2019/09/12/hand-made-os-in-30-days-day-1/)
- [NASM Document](https://www.nasm.us/xdoc/2.15.05/html/nasmdoc3.html#section-3.5)

### 二日目 : アセンブラ学習と Makefile 入門

#### まずはテキストエディタの紹介

わたしは [VS Code](https://code.visualstudio.com/) を使っています。

#### さて開発再開

- 書籍に従って`helloos.asm` を修正する（`projects/02_day/helloos3/helloos.nas`を参照する）

#### ブートセクタだけを作るように整理

- 書籍に従って `ipl.asm` を作成する（`projects/02_day/helloos4/ipl.nas`を参照する）
- 以下コマンドで`ipl.asm`から`ipl.bin`と`ipl.lst`を生成する
  ```bash
  $ nasm ipl.asm -o ipl.bin -l ipl.lst
  ```
- 以下コマンドで img ファイルを生成する
  ```
  $ mformat -f 1440 -C -B ipl.bin -i helloos.img ::
  ```
  各オプションの意味は以下の通り。
  ```
  -f : ファイルサイズ (1440 KB)
  -C : MS-DOSファイルシステムのimageファイルを作成する
  -B : 使用するブートセクタ
  -i : イメージファイル
  :: : -i オプションを使うときに使うドライブ指定文字
  ```
  よくある mformat コマンドの使用例は、`$ mformat :a`で、「:a」部分は「a ドライブ」とを意味する。「-i」オプションを使う場合は、ドライブ指定文字として「:」を使うため、表記が「::」となる。

【参考】

- [『OS 自作入門』を読んでみた。（その 6） - いものやま。](https://yamaimo.hatenablog.jp/entry/2017/07/05/200000)
- [【 mformat 】 MS-DOS フォーマットを行う](https://xtech.nikkei.com/it/article/COLUMN/20060227/230828/)
- [Mtools 4.0.20: drive letters - GNU.org](https://www.gnu.org/software/mtools/manual/html_node/drive-letters.html)

#### 今後のために Makefile 導入

- 書籍を参考に Makefile を作成する

  ```makefile
  IMGFILE=helloos.img

  all : $(IMGFILE)

  ipl.bin : ipl.asm
    nasm $^ -o $@ -l ipl.lst

  $(IMGFILE) : ipl.bin
    mformat -f 1440 -C -B $^ -i $@ ::
    # -f : ファイルサイズ (1440 KB)
    # -C : MS-DOSファイルシステムのimageファイルを作成する
    # -B : 使用するブートセクタ
    # -i : イメージファイル
    # :: : -i オプションを使うときに使うドライブ指定文字

  # image ファイルの起動は Windows から行うため、Makefile に run は用意していない

  clean :
    rm $(IMGFILE) ipl.bin ipl.lst
  ```

### 三日目 : ３２ビットモード突入と C 言語導入

#### さあ本当の IPL を作ろう

- 書籍に従って `ipl.asm` を修正する（`projects/03_day/harib00a/ipl.nas`を参照する）
- 生成する image ファイルを `haribote.img` に変更（`Makefile`の修正）
  ```diff
  - IMGFILE=helloos.img
  + IMGFILE=haribote.img
  ```

#### エラーになったらやり直そう

- 書籍に従って `ipl.asm` を修正する（`projects/03_day/harib00b/ipl.nas`を参照する）

#### 18 セクタまで読んでみる

- 書籍に従って `ipl.asm` を修正する（`projects/03_day/harib00c/ipl.nas`を参照する）

#### 10 シリンダ分を読み込んでみる

- 書籍に従って `ipl.asm` を修正する（`projects/03_day/harib00d/ipl.nas`を参照する）

#### OS 本体を書き始めてみる

- 書籍に従って `haribote.asm` を修正する（`projects/03_day/harib00e/haribote.nas`を参照する）
- `haribote.asm` アセンブルして `haribote.sys` を生成する
  ```bash
  $ nasm haribote.asm -o haribote.sys -l haribote.lst
  ```
- `ipl.bin` をブートセクタ、`haribote.img` を生成する
  ```
  $ mformat -f 1440 -C -B ipl.bin -i haribote.img ::
  ```
- `haribote.sys` を `haribote.img` に書き込む
  ```
  $ mcopy haribote.sys -i harinbote.img ::
  ```
- `Makefile` を修正する

  ```diff
    IMGFILE=haribote.img

    all : $(IMGFILE)

    ipl.bin : ipl.asm
      nasm $^ -o $@ -l ipl.lst

  + haribote.sys : haribote.asm
  +   nasm $^ -o $@ -l haribote.lst

  - $(IMGFILE) : ipl.bin
  + $(IMGFILE) : ipl.bin haribote.sys
  -   mformat -f 1440 -C -B $^ -i $@ ::
  +   mformat -f 1440 -C -B ipl.bin -i $@ ::
      # -f : ファイルサイズ (1440 KB)
      # -C : MS-DOSファイルシステムのimageファイルを作成する
      # -B : 使用するブートセクタ
      # -i : イメージファイル
      # :: : -i オプションを使うときに使うドライブ指定文字
  +   mcopy haribote.sys -i $@ ::

    # image ファイルの起動は Windows から行うため、Makefile に run は用意していない

    clean :
  -   rm $(IMGFILE) ipl.bin ipl.lst
  +   rm $(IMGFILE) ipl.bin ipl.lst haribote.sys haribote.lst
  ```

【参考】

- [30 日でできる！OS 自作入門（３日目）[Ubuntu16.04/NASM]](https://qiita.com/pollenjp/items/8fcb9573cdf2dc6e2668)

#### ブートセクタから OS 本体を実行させてみる

- 書籍に従って `ipl.asm` を修正する（`projects/03_day/harib00f/ipl.nas`を参照する）
- 書籍に従って `haribote.asm` を修正する（`projects/03_day/harib00f/haribote.nas`を参照する）

#### OS 本体の動作を確認してみる

- 書籍に従って `haribote.asm` を修正する（`projects/03_day/harib00g/haribote.nas`を参照する）
- `ipl.asm` を `ipl10.asm` にリネームする
- 書籍に従って `ipl.asm` を修正する（`projects/03_day/harib00g/ipl10.nas`を参照する）
- `Makefile` を修正する  
  `ipl` の部分を `ipl10` に直しておく。

#### 32 ビットモードへの準備

- 書籍に従って `haribote.asm` を修正する（`projects/03_day/harib00h/haribote.nas`を参照する）

#### ついに C 言語導入へ

- `haribote.asm` を `asmhead.asm` にリネームする
- 書籍に従って `asmhead.asm` を修正する（`projects/03_day/harib00i/asmhead.nas`を参照する）
- `asmhead.asm` から `asmhead.bin` を生成する
  ```
  $ nasm asmhead.asm -o asmhead.bin -l asmhead.lst
  ```
- 書籍に従って `bootpack.c` を作成する（`projects/03_day/harib00i/bootpack.c`を参照する）
- `bootpack.c` を 機械語に変換する  
  `bootpack.c` を機械語のファイル `bootpack.bin` に変換するため、以下コマンドを使う。
  ```bash
  $ gcc -m32 -fno-pic -nostdlib -T hrb.ld bootpack.c -o bootpack.bin
  ```
  各オプションの意味は次の通り。
  ```
  -m32      : 32bit 環境向けにコンパイルする
  -fno-pic  : 位置に依存しないコードを生成しない（pic : position independent code）
  -nostdlib : リンク時に標準ライブラリを使わない
  -T hrb.ld : リンカスクリプト `hrb.ld` を使用する
  -o        : 出力ファイル
  ```
- `asmhead.bin` と `bootpack.bin` から `haribote.sys` を生成する

  ```
  $ cat asmhead.bin bootpack.bin > haribote.sys
  ```

- `Makefile` を修正する

  ```diff
    IMGFILE=haribote.img
    IPLFILE=ipl10.asm

    all : $(IMGFILE)

    ipl10.bin : $(IPLFILE)
      nasm $^ -o $@ -l ipl10.lst

  - haribote.sys : haribote.asm
  -   nasm $^ -o $@ -l haribote.lst
  + asmhead.bin : asmhead.asm
  +   nasm $^ -o $@ -l asmhead.lst
  +
  + bootpack.bin : bootpack.c
  +   gcc -m32 -fno-pic -nostdlib -T hrb.ld $^ -o $@
  +
  + haribote.sys : asmhead.bin bootpack.bin
  +   cat $^ > $@

    $(IMGFILE) : ipl10.bin haribote.sys
      mformat -f 1440 -B ipl10.bin -C -i $@ ::
      mcopy haribote.sys -i $@ ::
    #	1440[KB] (= 512 * 2880 byte)
    #	C: to install on MS-DOS file system

    # image ファイルの起動は Windows から行うため、Makefile に run は用意していない

    clean :
  -   rm $(IMGFILE) ipl10.bin ipl10.lst haribote.sys haribote.lst
  +   rm $(IMGFILE) \
  +     ipl10.bin ipl10.lst \
  +     asmhead.bin asmhead.lst \
  +     bootpack.bin \
  +     haribote.sys
  ```

【参考】

- [『30 日でできる！OS 自作入門』のメモ](https://vanya.jp.net/os/haribote.html#hrb)
- [30 日でできる！OS 自作入門（３日目）[Ubuntu16.04/NASM]](https://qiita.com/pollenjp/items/8fcb9573cdf2dc6e2668)

#### とにかく HLT したい (harib00j)

- 書籍に従って `nasmfunk.asm` を修正する（`projects/03_day/harib00j/naskfunk.nas`を参照する）  
  ただし nasm を使っているため、下記のように記述する。

  ```
  ; nasmfunc
  ; TAB=4

  BITS 32                          ; 32ビットモード用の機械語を作らせる

  ; オブジェクトファイルのための情報

  GLOBAL      io_hlt         ; このプログラムに含まれる関数名

  ; 以下は実際の関数

  SECTION .text

  io_hlt:                        ; void io_hlt(void)
      HLT
      RET
  ```

- `nasmfunc.asm` から オブジェクトファイル `nasmfunc.o` を生成する

  ```
  $ nasm -f elf32 nasmfunc.asm -o nasmfunc.o -l nasmfunc.lst
  ```

  各オプションの意味は次の通り。

  ```
  -f elf32 : 出力ファイルのフォーマットを指定する。"elf32" は「ELF32 (i386) オブジェクトファイルを指す。
  ```

- `bootpack.c` から `bootpack.o` を生成する
  ```
  $ gcc -c -m32 -fno-pic -nostdlib -o bootpack.o bootpack.c
  ```
- `bootpack.o` と `nasmfunc.o` リンク `bootpack.bin` を生成  
  ld コマンドを用いてリンクする。

  ```
  $ ld -m elf_i386 -e HariMain -o bootpack.bin -T hrb.ld bootpack.o nasmfunc.o
  ```

  各オプションの意味は次の通り。

  ```
  -m elf_i386 : elf_i386 形式を指定
  -e          : プログラムの実行開始位置であるエントリポイントの指定
  ```

- `Makefile` を修正する

  ```diff
    IMGFILE=haribote.img
    IPLFILE=ipl10.asm

    all : $(IMGFILE)

    ipl10.bin : $(IPLFILE)
      nasm $^ -o $@ -l ipl10.lst

    asmhead.bin : asmhead.asm
      nasm $^ -o $@ -l asmhead.lst

  - bootpack.bin : bootpack.c
  -   gcc -m32 -fno-pic -nostdlib -T hrb.ld $^ -o $@
  + bootpack.o : bootpack.c
  +   gcc -c -m32 -fno-pic -nostdlib -o $@ $^

  + nasmfunc.o : nasmfunc.asm
  +   nasm -f elf32 $^ -o $@ -l nasmfunc.lst)

  + bootpack.bin : bootpack.o nasmfunc.o
  +   ld -m elf_i386 -e HariMain -o $@ -T hrb.ld $^

    haribote.sys : asmhead.bin bootpack.bin
      cat $^ > $@

    $(IMGFILE) : ipl10.bin haribote.sys
      mformat -f 1440 -B ipl10.bin -C -i $@ ::
      mcopy haribote.sys -i $@ ::
    #	1440[KB] (= 512 * 2880 byte)
    #	C: to install on MS-DOS file system

    # image ファイルの起動は Windows から行うため、Makefile に run は用意していない

    clean :
      rm $(IMGFILE) \
  -     ipl10.bin ipl10.lst \
  -     asmhead.bin asmhead.lst \
  +     ipl10.bin ipl10.lst \
  +     asmhead.bin asmhead.lst \
  +     bootpack.o \
  +     nasmfunc.o nasmfunc.lst
        bootpack.bin \
        haribote.sys
  ```

【参考】

- [30 日でできる！OS 自作入門（３日目）[Ubuntu16.04/NASM]](https://qiita.com/pollenjp/items/8fcb9573cdf2dc6e2668)

### 四日目 : C 言語と画面表示の練習

#### C 言語からメモリに書き込みたい (harib01a)

- 書籍に従って `nasmfunk.asm` を修正する（`projects/04_day/harib01a/naskfunk.nas`を参照する）
- 書籍に従って `bootpack.c` を修正する（`projects/04_day/harib01a/bootpack.c`を参照する）  
  ただし、`io_hlt()`呼出しのループ処理を while 文に変更した。

#### しましま模様 (harib01b)

- 書籍に従って `bootpack.c` を修正する（`projects/04_day/harib01b/bootpack.c`を参照する）

#### ポインタに挑戦 (harib01c)

- 書籍に従って `bootpack.c` を修正する（`projects/04_day/harib01c/bootpack.c`を参照する）
- 書籍に従って `nasmfunk.asm` を修正する（`projects/04_day/harib01c/naskfunk.nas`を参照する）

#### ポインタの応用(1) (harib01d)

- 書籍に従って `bootpack.c` を修正する（`projects/04_day/harib01d/bootpack.c`を参照する）

#### ポインタの応用(2) (harib01e)

- 書籍に従って `bootpack.c` を修正する（`projects/04_day/harib01e/bootpack.c`を参照する）

#### 色番号設定 (harib01f)

- 書籍に従って `bootpack.c` を修正する（`projects/04_day/harib01f/bootpack.c`を参照する）
- 書籍に従って `nasmfunc.asm` を修正する（`projects/04_day/harib01f/naskfunk.nas`を参照する）

- エラー発生  
  make したところ ld コマンドでエラーが発生した。

  ```bash
  $ ld -m elf_i386 -e HariMain -o bootpack.bin -T hrb.ld bootpack.o nasmfunc.o
  ld: section .note.gnu.property LMA [00000000000001a0,00000000000001bb] overlaps section .data LMA [00000000000001a0,00000000000001cf]
  make: *** [Makefile:20: bootpack.bin] Error 1
  ```

  `.note.gnu.property` セクションと `.data` セクションの配置場所が重なっているということと思われる（LMA : Load Memory Address : プログラムをロードされるときに参照されるアドレス）。
  ここで `.note.gnu.property` とは何か確認してみる。

  ```
  $ objdump -s bootpack.o

  bootpack.o:     file format elf32-i386

  Contents of section .text:
  0000 f30f1efb 5589e583 ec18e8fc ffffffc7  ....U...........
  0010 45f00000 0a00c745 f4000000 00eb188b  E......E........
  0020 45f489c1 8b55f48b 45f001d0 83e10f89  E....U..E.......
  0030 ca881083 45f40181 7df4feff 00007edf  ....E...}.....~.
  0040 e8fcffff ffebf9f3 0f1efb55 89e583ec  ...........U....
  0050 0883ec04 68000000 006a0f6a 00e8fcff  ....h....j.j....
  0060 ffff83c4 1090c9c3 f30f1efb 5589e583  ............U...
  0070 ec18e8fc ffffff89 45f0e8fc ffffff83  ........E.......
  0080 ec08ff75 0868c803 0000e8fc ffffff83  ...u.h..........
  0090 c4108b45 088945f4 eb658b45 100fb600  ...E..E..e.E....
  00a0 c0e8020f b6c083ec 085068c9 030000e8  .........Ph.....
  00b0 fcffffff 83c4108b 451083c0 010fb600  ........E.......
  00c0 c0e8020f b6c083ec 085068c9 030000e8  .........Ph.....
  00d0 fcffffff 83c4108b 451083c0 020fb600  ........E.......
  00e0 c0e8020f b6c083ec 085068c9 030000e8  .........Ph.....
  00f0 fcffffff 83c41083 45100383 45f4018b  ........E...E...
  0100 45f43b45 0c7e9383 ec0cff75 f0e8fcff  E.;E.~.....u....
  0110 ffff83c4 1090c9c3                    ........
  Contents of section .data:
  0000 000000ff 000000ff 00ffff00 0000ffff  ................
  0010 00ff00ff ffffffff c6c6c684 00000084  ................
  0020 00848400 00008484 00840084 84848484  ................
  Contents of section .comment:
  0000 00474343 3a202855 62756e74 7520392e  .GCC: (Ubuntu 9.
  0010 332e302d 31307562 756e7475 32292039  3.0-10ubuntu2) 9
  0020 2e332e30 00                          .3.0.
  Contents of section .note.gnu.property:
  0000 04000000 0c000000 05000000 474e5500  ............GNU.
  0010 020000c0 04000000 03000000           ............
  Contents of section .eh_frame:
  0000 14000000 00000000 017a5200 017c0801  .........zR..|..
  0010 1b0c0404 88010000 18000000 1c000000  ................
  0020 00000000 47000000 00450e08 8502420d  ....G....E....B.
  0030 05000000 1c000000 38000000 47000000  ........8...G...
  0040 21000000 00450e08 8502420d 0559c50c  !....E....B..Y..
  0050 04040000 1c000000 58000000 68000000  ........X...h...
  0060 b0000000 00450e08 8502420d 0502a8c5  .....E....B.....
  0070 0c040400                             ....
  ```

  `.note.gnu.property` セクションは `bootpack.c` のコードと関係なさそうなので、gcc コマンドが `bootpack.o` 生成時に 自動で作ったセクションと思われる。
  実処理に影響ないと思うのでリンク対象から外すことにする。  
  （根本的な解決ではないと思うが、とりあえずこの方法を取って先に進む）

  - リンカスクリプト `hrb.ld` の修正  
    `.note.gnu.property` セクションをリンク対象から外すように修正する。
    ```diff
    - /DISCARD/ : { *(.eh_frame) }
    + /DISCARD/ : {
    +     *(.note.gnu.property)
    +     *(.eh_frame)
    + }
    ```
  - 再度 make する  
    無事、`haribote.img` が生成でき、色の変わった縞模様が表示できた。

【参考】

- [リンカスクリプトの書き方](http://blueeyes.sakura.ne.jp/2018/10/31/1676/)
- [objdump - オブジェクトファイルの情報を表示する](https://linuxcommand.net/objdump/)
- [size - コマンド (プログラム) の説明 - Linux コマンド集 一覧表](https://kazmax.zpp.jp/cmd/s/size.1.html)

#### 四角形を描く (harib01g)

- 書籍に従って `bootpack.c` を修正する（`projects/04_day/harib01g/bootpack.c`を参照する）

#### 今日の仕上げ (harib01h)

- 書籍に従って `bootpack.c` を修正する（`projects/04_day/harib01h/bootpack.c`を参照する）

### 五日目 : 構造体と文字表示と GDT/IDT 初期化

#### 起動情報の受け取り (harib02a)

- 書籍に従って `bootpack.c` を修正する（`projects/05_day/harib02a/bootpack.c`を参照する）

#### 構造体を使ってみる (harib02b)

- 書籍に従って `bootpack.c` を修正する（`projects/05_day/harib02b/bootpack.c`を参照する）

#### 矢印表記を使ってみる (harib02c)

- 書籍に従って `bootpack.c` を修正する（`projects/05_day/harib02c/bootpack.c`を参照する）

#### とにかく文字を出したい (harib02d)

- 書籍に従って `bootpack.c` を修正する（`projects/05_day/harib02d/bootpack.c`を参照する）

#### フォントを増やしたい (harib02e)

- 書籍に従って `bootpack.c` を修正する（`projects/05_day/harib02e/bootpack.c`を参照する）
- フォントデータ `hankaku.txt` を C 言語の 16 進数の配列に変換して `hankaku.c` として出力する  
  例えば、
  ```
  ..***... // 0011 1000
  .*...*.. // 0100 0100
  ```
  から、
  ```c
  char hankaku[2] = {
    0x38,
    0x44,
  };
  ```
  に変換する。  
  `hankaku.txt` から `hankaku.c` を生成するシェルスクリプト `convHankaku.sh` を作成した。
- `hankaku.c` をビルドに組み込むように `Makefile` を修正する

  ```diff
  + hankaku.o : hankaku.c
  +   gcc -c -m32 -fno-pic -nostdlib -o $@ $^

    nasmfunc.o : nasmfunc.asm
      nasm -f elf32 $^ -o $@ -l $(@:.o=.lst)

  - bootpack.bin : bootpack.o nasmfunc.o
  + bootpack.bin : bootpack.o hankaku.o nasmfunc.o
      ld -m elf_i386 -e HariMain -o $@ -T hrb.ld $^
  ```

  ```diff
    clean :
      rm $(IMGFILE) \
        ipl10.bin ipl10.lst \
        asmhead.bin asmhead.lst \
        bootpack.o \
  +     hankaku.o \
        nasmfunc.o nasmfunc.lst \
        bootpack.bin \
        haribote.sys
  ```

#### 文字列を書きたい (harib02f)

- 書籍に従って `bootpack.c` を修正する（`projects/05_day/harib02f/bootpack.c`を参照する）

#### 変数の値の表示 (harib02g)

- 書籍に従って `bootpack.c` を修正する（`projects/05_day/harib02g/bootpack.c`を参照する）
- ビルドをするが、sprintf が未定義とエラーが出る

  ```
  ld: bootpack.o: in function `HariMain':
  bootpack.c:(.text+0xcc): undefined reference to `sprintf'
  make: *** [Makefile:28: bootpack.bin] Error 1
  ```

  - sprintf のリンクを試みる（この方法ではダメだった）  
    ld コマンドでリンクするファイルに sprintf が定義されていないので、sprintf が定義されているライブラリを追記してみる。
    32bit 用のライブラリを使うために `gcc-multilib`をインストール。

    ```bash
    $ sudo apt-get install gcc-multilib
    ```

    そして、`Makefile` を以下のように修正。
    `/usr/lib32` の `libg.a` を使ってみる。

    ```diff
      bootpack.bin : bootpack.o hankaku.o nasmfunc.o
    -     ld -m elf_i386 -e HariMain -o $@ -T hrb.ld $^
    +     ld -m elf_i386 -e HariMain -o $@ -T hrb.ld $^ -static -L/usr/lib32 -lc
    ```

    make してみるが、大量のエラーが発生。
    <details>
    <summary>エラー詳細</summary>

    ```
    ld: section .text.__x86.get_pc_thunk.bx LMA [0000000000058e65,0000000000058e68] overlaps section .data LMA [0000000000058e65,0000000000075514]
    ld: /usr/lib32/libc.a(iofclose.o):(.data.rel.local.DW.ref.__gcc_personality_v0[DW.ref.__gcc_personality_v0]+0x0): undefined reference to `__gcc_personality_v0'
    ld: /usr/lib32/libc.a(iovsprintf.o): in function `_IO_str_chk_overflow':
    (.text+0xc): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(iovsprintf.o): in function `__vsprintf_internal':
    (.text+0x2f): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(genops.o): in function `save_for_backup':
    (.text+0xb): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(genops.o): in function `flush_cleanup':
    (.text+0x22c): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(genops.o): in function `_IO_un_link.part.0':
    (.text+0x309): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(genops.o):(.text+0x60d): more undefined references to `_GLOBAL_OFFSET_TABLE_' follow
    ld: /usr/lib32/libc.a(dl-misc.o): in function `_dl_strtoul':
    (.text+0x7f0): undefined reference to `__udivdi3'
    ld: /usr/lib32/libc.a(dl-tls.o): in function `allocate_dtv':
    (.text+0xc): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(dl-tls.o): in function `oom':
    (.text+0x48): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(dl-tls.o): in function `_dl_next_tls_modid':
    (.text+0x7b): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(dl-tls.o): in function `_dl_count_modids':
    (.text+0x18a): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(dl-tls.o): in function `_dl_get_tls_static_info':
    (.text+0x1fa): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(dl-tls.o):(.text+0x22f): more undefined references to `_GLOBAL_OFFSET_TABLE_' follow
    ld: /usr/lib32/libc.a(printf_fp.o): in function `__printf_fp_l':
    (.text+0x4c6): undefined reference to `__unordtf2'
    ld: (.text+0x52a): undefined reference to `__unordtf2'
    ld: (.text+0x575): undefined reference to `__letf2'
    ld: /usr/lib32/libc.a(printf_fp.o): in function `___printf_fp':
    (.text+0x2c1a): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(reg-printf.o): in function `__register_printf_specifier':
    (.text+0x12): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(printf_fphex.o): in function `__printf_fphex':
    (.text+0xc): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: (.text+0xfc): undefined reference to `__unordtf2'
    ld: (.text+0x15c): undefined reference to `__unordtf2'
    ld: (.text+0x1aa): undefined reference to `__letf2'
    ld: /usr/lib32/libc.a(reg-modifier.o): in function `__register_printf_modifier':
    (.text+0xf): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(reg-modifier.o): in function `__handle_registered_modifier_mb':
    (.text+0x1ca): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(reg-modifier.o): in function `__handle_registered_modifier_wc':
    (.text+0x2ba): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(reg-type.o): in function `__register_printf_type':
    (.text+0xe): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(vfwprintf-internal.o): in function `group_number':
    (.text+0x8d): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(vfwprintf-internal.o):(.text+0x1a1): more undefined references to `_GLOBAL_OFFSET_TABLE_' follow
    ld: /usr/lib32/libc.a(iofclose.o): in function `_IO_new_fclose.cold':
    (.text.unlikely+0x36): undefined reference to `_Unwind_Resume'
    ld: /usr/lib32/libc.a(iofflush.o): in function `_IO_fflush.cold':
    (.text.unlikely+0x35): undefined reference to `_Unwind_Resume'
    ld: /usr/lib32/libc.a(iofputs.o): in function `_IO_fputs.cold':
    (.text.unlikely+0x35): undefined reference to `_Unwind_Resume'
    ld: /usr/lib32/libc.a(iofwrite.o): in function `_IO_fwrite.cold':
    (.text.unlikely+0x34): undefined reference to `_Unwind_Resume'
    ld: /usr/lib32/libc.a(wfileops.o): in function `_IO_wfile_underflow.cold':
    (.text.unlikely+0x34): undefined reference to `_Unwind_Resume'
    ld: /usr/lib32/libc.a(fileops.o):(.text.unlikely+0x34): more undefined references to `_Unwind_Resume' follow
    ld: /usr/lib32/libc.a(strcasecmp_l-ssse3.o): in function `__strcasecmp_ssse3':
    (.text.ssse3+0xc): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(strcasecmp_l-ssse3.o): in function `__strcasecmp_l_ssse3':
    (.text.ssse3+0x52): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    takumi@takumi-daiv:~/work/os30days (master)$ make
    ld -m elf_i386 -e HariMain -o bootpack.bin -T hrb.ld bootpack.o hankaku.o nasmfunc.o -static -L/usr/lib32 -lc
    ld: section .text.__x86.get_pc_thunk.bx LMA [0000000000058e65,0000000000058e68] overlaps section .data LMA [0000000000058e65,0000000000075514]
    ld: /usr/lib32/libc.a(iofclose.o):(.data.rel.local.DW.ref.__gcc_personality_v0[DW.ref.__gcc_personality_v0]+0x0): undefined reference to `__gcc_personality_v0'
    ld: /usr/lib32/libc.a(iovsprintf.o): in function `_IO_str_chk_overflow':
    (.text+0xc): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(iovsprintf.o): in function `__vsprintf_internal':
    (.text+0x2f): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(genops.o): in function `save_for_backup':
    (.text+0xb): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(genops.o): in function `flush_cleanup':
    (.text+0x22c): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(genops.o): in function `_IO_un_link.part.0':
    (.text+0x309): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(genops.o):(.text+0x60d): more undefined references to `_GLOBAL_OFFSET_TABLE_' follow
    ld: /usr/lib32/libc.a(dl-misc.o): in function `_dl_strtoul':
    (.text+0x7f0): undefined reference to `__udivdi3'
    ld: /usr/lib32/libc.a(dl-tls.o): in function `allocate_dtv':
    (.text+0xc): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(dl-tls.o): in function `oom':
    (.text+0x48): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(dl-tls.o): in function `_dl_next_tls_modid':
    (.text+0x7b): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(dl-tls.o): in function `_dl_count_modids':
    (.text+0x18a): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(dl-tls.o): in function `_dl_get_tls_static_info':
    (.text+0x1fa): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(dl-tls.o):(.text+0x22f): more undefined references to `_GLOBAL_OFFSET_TABLE_' follow
    ld: /usr/lib32/libc.a(printf_fp.o): in function `__printf_fp_l':
    (.text+0x4c6): undefined reference to `__unordtf2'
    ld: (.text+0x52a): undefined reference to `__unordtf2'
    ld: (.text+0x575): undefined reference to `__letf2'
    ld: /usr/lib32/libc.a(printf_fp.o): in function `___printf_fp':
    (.text+0x2c1a): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(reg-printf.o): in function `__register_printf_specifier':
    (.text+0x12): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(printf_fphex.o): in function `__printf_fphex':
    (.text+0xc): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: (.text+0xfc): undefined reference to `__unordtf2'
    ld: (.text+0x15c): undefined reference to `__unordtf2'
    ld: (.text+0x1aa): undefined reference to `__letf2'
    ld: /usr/lib32/libc.a(reg-modifier.o): in function `__register_printf_modifier':
    (.text+0xf): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(reg-modifier.o): in function `__handle_registered_modifier_mb':
    (.text+0x1ca): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(reg-modifier.o): in function `__handle_registered_modifier_wc':
    (.text+0x2ba): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(reg-type.o): in function `__register_printf_type':
    (.text+0xe): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(vfwprintf-internal.o): in function `group_number':
    (.text+0x8d): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(vfwprintf-internal.o):(.text+0x1a1): more undefined references to `_GLOBAL_OFFSET_TABLE_' follow
    ld: /usr/lib32/libc.a(iofclose.o): in function `_IO_new_fclose.cold':
    (.text.unlikely+0x36): undefined reference to `_Unwind_Resume'
    ld: /usr/lib32/libc.a(iofflush.o): in function `_IO_fflush.cold':
    (.text.unlikely+0x35): undefined reference to `_Unwind_Resume'
    ld: /usr/lib32/libc.a(iofputs.o): in function `_IO_fputs.cold':
    (.text.unlikely+0x35): undefined reference to `_Unwind_Resume'
    ld: /usr/lib32/libc.a(iofwrite.o): in function `_IO_fwrite.cold':
    (.text.unlikely+0x34): undefined reference to `_Unwind_Resume'
    ld: /usr/lib32/libc.a(wfileops.o): in function `_IO_wfile_underflow.cold':
    (.text.unlikely+0x34): undefined reference to `_Unwind_Resume'
    ld: /usr/lib32/libc.a(fileops.o):(.text.unlikely+0x34): more undefined references to `_Unwind_Resume' follow
    ld: /usr/lib32/libc.a(strcasecmp_l-ssse3.o): in function `__strcasecmp_ssse3':
    (.text.ssse3+0xc): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(strcasecmp_l-ssse3.o): in function `__strcasecmp_l_ssse3':
    (.text.ssse3+0x52): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(strcasecmp_l-sse4.o): in function `__strcasecmp_sse4_2':
    (.text.sse4.2+0xc): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(strcasecmp_l-sse4.o): in function `__strcasecmp_l_sse4_2':
    (.text.sse4.2+0x52): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(strcspn-c.o): in function `__strcspn_sse42':
    (.text.sse4.2+0xf): undefined reference to `_GLOBAL_OFFSET_TABLE_'
    ld: /usr/lib32/libc.a(strspn-c.o):(.text.sse4.2+0x13): more undefined references to `_GLOBAL_OFFSET_TABLE_' follow
    make: *** [Makefile:28: bootpack.bin] Error 1
    ```

    </details>
    おそらく、コンパイル時に `-nostdlib` オプションを付けているために、標準の各種マクロ等々が未定義だと言っていると思われる。
    これら１つ１つを解決していくのはちょっと大変なので別の方法を考える。

  - sprintf のライブラリを作成する（この方法で上手くいった）  
    付属の CD-ROM に sprintf のソースコード一式があることがわかった。
    ならばこのソースコードから静的ライブラリを作り、リンクすれば良いはず。
    - ライブラリを作る用のサブディレクトリ `golibc` を作成
      ```
      $ mkdir golibc`
      ```
    - 静的ライブラリ `libgolibc.a` を作る  
      作り方は `golibc` ディレクトリ内の [README.md](./golibc/README.md) を参照のこと。

- `libgolibc.a` を使うように `Makefile` を修正
  ```diff
    IMGFILE=haribote.img
    IPLFILE=ipl10.asm
  + GOLIBCPATH=./golibc
  ```
  ```diff
  - bootpack.bin : bootpack.o hankaku.o nasmfunc.o
  -   ld -m elf_i386 -e HariMain -o $@ -T hrb.ld $^
  + bootpack.bin : bootpack.o hankaku.o nasmfunc.o $(GOLIBCPATH)/libgolibc.a
  +   ld -m elf_i386 -e HariMain -o $@ -T hrb.ld $^ -static -L$(GOLIBCPATH) -lgolibc
  ```
- `bootpack.c` を修正  
  標準ライブラリは使用していないので `#include <stdio.h>` を削除し、sprintf のプロトタイプ宣言を追記する。

  ```diff
  - #include <stdio.h>
  ```

  ```diff
    void putfonts8_asc(char *vram, int xsize, int x, int y, char c, unsigned char *s);

  + int sprintf(char *s, const char *format, ...);
  ```

- 再度ビルドする  
  ビルド成功し、書籍の通りの画面が表示された。

【参考】

- [5 日目 その 2](https://papamitra.hatenadiary.org/entry/20060528/1148785327)
- [はりぼて OS を NASM・GCC で動かす(Mac OSX)](https://tatsumack.hatenablog.com/entry/2017/03/24/225706)
- [C: 静的ライブラリと共有ライブラリについて](https://blog.amedama.jp/entry/2016/05/29/222739)

#### マウスカーソルも描いてみよう (harib02h)

- 書籍に従って `bootpack.c` を修正する（`projects/05_day/harib02h/bootpack.c`を参照する）

#### GDT と IDT を初期化しよう (harib02i)

- 書籍に従って `bootpack.c` を修正する（`projects/05_day/harib02i/bootpack.c`を参照する）
- 書籍に従って `nasmfunc.asm` を修正する（`projects/05_day/harib02i/naskfunc.nas`を参照する）

### 六日目 : 分割コンパイルと割り込み処理

#### ソースファイルの分割 (harib03a)

- 書籍に従って `bootpack.c` 分割し、`graphic.c` と `dsctbl.c` を作成する（`projects/06_day/harib02a/`を参照する）
- 分割したソースファイルをビルドするように `Makefile` を修正する。

#### Makefile 整理 (harib03b)

- 書籍を参考に`Makefile`を修正する  
  .c から .o を生成する命令をパターンルールを使って書き直した。

  ```diff
  - bootpack.o : bootpack.c
  -   gcc -c -m32 -fno-pic -nostdlib -o $@ $^
  -
  - graphic.o : graphic.c
  -   gcc -c -m32 -fno-pic -nostdlib -o $@ $^
  -
  - dsctbl.o : dsctbl.c
  -   gcc -c -m32 -fno-pic -nostdlib -o $@ $^
  -
  - hankaku.o : hankaku.c
  -   gcc -c -m32 -fno-pic -nostdlib -o $@ $^
  + %.o : %.c
  +   gcc -c -m32 -fno-pic -nostdlib -o $@ $<
  ```

#### ヘッダファイル整理 (harib03c)

- 書籍に従って `bootpack.h` を作成する（`projects/06_day/harib03c/bootpack.h`を参照する）
- 書籍に従って `bootpack.c` を修正する（`projects/06_day/harib03c/bootpack.c`を参照する）
- 書籍に従って `graphic.c` を修正する（`projects/06_day/harib03c/graphic.c`を参照する）
- 書籍に従って `dsctbl.c` を修正する（`projects/06_day/harib03c/dsctbl.c`を参照する）

#### やり残した説明

メモなし。

#### PIC 初期化 (harib03d)

- 書籍に従って `int.c` を作成する（`projects/06_day/harib03d/int.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/06_day/harib03d/bootpack.h`を参照する）
- 書籍に従って `bootpack.c` を修正する（`projects/06_day/harib03d/bootpack.c`を参照する）
- `int.c` をビルドできるように `Makefile` を修正する。

#### 割り込みハンドラ作成 (harib03e)

- 書籍に従って `int.c` を修正する（`projects/06_day/harib03e/int.c`を参照する）
- 書籍に従って `nasmfunc.asm` を修正する（`projects/06_day/harib03e/naskfunc.nas`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/06_day/harib03e/bootpack.h`を参照する）
- 書籍に従って `dsctbl.c` を修正する（`projects/06_day/harib03e/dsctbl.c`を参照する）
- 書籍に従って `bootpack.c` を修正する（`projects/06_day/harib03e/bootpack.c`を参照する）

### 七日目 : FIFO とマウス制御

#### キーコードを取得しよう (harib04a)

- 書籍に従って `int.c` を修正する（`projects/07_day/harib04a/int.c`を参照する）
- `bootpack.h` に `io_in8()` のプロトタイプ宣言を追記する。
- `golibc.h` を新規作成し、`sprintf()` のプロトタイプ宣言を記載する。
  - `bootpack.c` から `sprintf()` のプロトタイプ宣言を削除し、`golibc.h` の include 文を追記する。
  - `int.c` に `golibc.h` の include 文を追記する。

#### 割り込み処理は手早く (harib04b)

- 書籍に従って `int.c` を修正する（`projects/07_day/harib04b/int.c`を参照する）
- 書籍に従って `bootpack.c` を修正する（`projects/07_day/harib04b/bootpack.c`を参照する）
- `bootpack.h` を以下の通り修正する。
  - `io_stihlt()` のプロトタイプ宣言を追記する。
  - `struct KEYBUF` の定義を追記する。

#### FIFO バッファを作る (harib04c)

- 書籍に従って `int.c` を修正する（`projects/07_day/harib04c/int.c`を参照する）
- 書籍に従って `bootpack.c` を修正する（`projects/07_day/harib04c/bootpack.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/07_day/harib04c/bootpack.h`を参照する）

#### FIFO バッファを改良する (harib04d)

- 書籍に従って `int.c` を修正する（`projects/07_day/harib04d/int.c`を参照する）
- 書籍に従って `bootpack.c` を修正する（`projects/07_day/harib04d/bootpack.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/07_day/harib04d/bootpack.h`を参照する）

#### FIFO バッファを整理する (harib04e)

- 書籍に従って `fifo.c` を作成する（`projects/07_day/harib04e/fifo.c`を参照する）
- 書籍に従って `int.c` を修正する（`projects/07_day/harib04e/int.c`を参照する）
- 書籍に従って `bootpack.c` を修正する（`projects/07_day/harib04e/bootpack.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/07_day/harib04e/bootpack.h`を参照する）

#### さあマウスだ (harib04f)

- 書籍に従って `bootpack.c` を修正する（`projects/07_day/harib04e/bootpack.c`を参照する）

#### マウスからのデータ受信 (harib04g)

- 書籍に従って `int.c` を修正する（`projects/07_day/harib04g/int.c`を参照する）
- 書籍に従って `bootpack.c` を修正する（`projects/07_day/harib04g/bootpack.c`を参照する）

### 八日目 : マウス制御と 32 ビットモード切り替え

#### マウスの解読(1) (harib05a)

- 書籍に従って `bootpack.c` を修正する（`projects/08_day/harib05a/bootpack.c`を参照する）

#### ちょっと整理 (harib05b)

- 書籍に従って `bootpack.c` を修正する（`projects/08_day/harib05b/bootpack.c`を参照する）

#### マウスの解読(2) (harib05c)

- 書籍に従って `bootpack.c` を修正する（`projects/08_day/harib05c/bootpack.c`を参照する）

  ```c
  /* マウスの1バイト目を待っている段階 */
  if ( (dat & 0xc8) == 0x08 )
  ```

  `mouse_decode()`の 1 バイト目チェックをしているこの if 文は、
  1 バイト目が次の仕様となっていることに起因する。

  - 下位 4 ビット : クリックの情報を表し、取り得る値は 8 ～ F。  
    つまり 4 ビット目は常に 1 となっている。
  - 上位 4 ビット : 移動の情報を表し、取る得る値は 0 ～ 3。  
    つまり 7,8 ビット目は常に 0 となっている。

  よって、この if 文では、「7,8 ビット目は 0 である」かつ「4 ビット目が 1 である」ことをチェックしている。

- マイナス記号と数値の間に空白が入る  
  なぜかマイナス符号の位置が固定されていて、mdec.x, mdec.y が負のときに符号と数字の間に空白が入るのが気になる。  
  表示内容に問題はないのでとりあえず先に進む。

#### 動けマウス (harib05d)

- 書籍に従って `bootpack.c` を修正する（`projects/08_day/harib05d/bootpack.c`を参照する）

#### 32 ビットモードへの道

メモなし。

### 九日目 : メモリ管理

#### ソースの整理 (harib06a)

- 書籍に従って `bootpack.c` を修正する（`projects/09_day/harib06a/bootpack.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/09_day/harib06a/bootpack.h`を参照する）
- 書籍に従って `int.c` を修正する（`projects/09_day/harib06a/int.c`を参照する）
- 書籍に従って `keyboard.c` を作成する（`projects/09_day/harib06a/keyboard.c`を参照する）
- 書籍に従って `mouse.c` を作成する（`projects/09_day/harib06a/mouse.c`を参照する）

#### メモリ容量チェック(1) (harib06b)

- 書籍に従って `bootpack.c` を修正する（`projects/09_day/harib06b/bootpack.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/09_day/harib06b/bootpack.h`を参照する）
- 書籍に従って `nasmfunc.asm` を修正する（`projects/09_day/harib06b/naskfunc.nas`を参照する）
- haribote.img を実行した結果、書籍と異なり"memory 128MB" と表示された。  
  書籍によると"32MB"というのは qemu の設定のよるとのこと。
  [qemu コマンドのオプション](https://qemu-project.gitlab.io/qemu/system/invocation.html#hxtool-0) を見てみると、128MB がデフォルト値とわかった。
  ```
  -m [size=]megs[,slots=n,maxmem=size]
    Sets guest startup RAM size to megs megabytes. Default is 128 MiB.
    （以下略）
  ```
  img 起動スクリプトを以下の通り書き換えたところ、"32MB"と表示された。
  ```diff
  - "C:\Program Files\qemu\qemu-system-i386.exe" -fda "\\wsl$\Ubuntu-20.04\PATH_TO_IMG\haribote.img"
  + "C:\Program Files\qemu\qemu-system-i386.exe" -fda -m 32M \\wsl$\Ubuntu-20.04\PATH_TO_IMG\haribote.img"
  ```
  書籍の"32MB じゃなくて 3072MB だって？"になっていないが、書籍とは環境が異なるので気にしないでおく。

#### メモリ容量チェック(2) (harib06c)

- 書籍に従って `bootpack.c` を修正する（`projects/09_day/harib06c/bootpack.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/09_day/harib06c/bootpack.h`を参照する）
- 書籍に従って `nasmfunc.asm` を修正する（`projects/09_day/harib06c/naskfunc.nas`を参照する）

#### メモリ管理に挑戦 (harib06d)

- 書籍に従って `bootpack.c` を修正する（`projects/09_day/harib06d/bootpack.c`を参照する）  
  HariMain()中の 2 回 memman_free()している箇所は、それぞれ 0x9e000(632KB) と memtotal(32MB) - 0x400000(4MB) = 28MB 分の解放なので、合わせて 632KB + 28MB(=28,672KB) = 29,304KB となる。

### 十日目 : 重ね合わせ処理

#### メモリ管理の続き (harib07a)

- 書籍に従って `bootpack.c` を修正する（`projects/10_day/harib07a/bootpack.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/10_day/harib07a/bootpack.h`を参照する）
- 書籍に従って `memory.c` を作成する（`projects/10_day/harib07a/memory.c`を参照する）

#### 重ね合わせ処理 (harib07b)

- 書籍に従って `bootpack.c` を修正する（`projects/10_day/harib07b/bootpack.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/10_day/harib07b/bootpack.h`を参照する）
- 書籍に従って `sheet.c` を作成する（`projects/10_day/harib07b/sheet.c`を参照する）

#### 重ね合わせ処理の高速化(1) (harib07c)

- 書籍に従って `bootpack.c` を修正する（`projects/10_day/harib07c/bootpack.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/10_day/harib07c/bootpack.h`を参照する）
- 書籍に従って `sheet.c` を修正する（`projects/10_day/harib07c/sheet.c`を参照する）

#### 重ね合わせ処理の高速化(2) (harib07d)

- 書籍に従って `sheet.c` を修正する（`projects/10_day/harib07d/sheet.c`を参照する）

### 十一日目 : 重ね合わせ処理

#### もっとマウス (harib08a)

- 書籍に従って `bootpack.c` を修正する（`projects/11_day/harib08a/bootpack.c`を参照する）  
  （マウスが画面外に出ると誤動作する状態）

#### 画面外サポート (harib08b)

- 書籍に従って `sheet.c` を修正する（`projects/11_day/harib08b/sheet.c`を参照する）

#### shtctl の指定省略 (harib08c)

- 書籍に従って `bootpack.c` を修正する（`projects/11_day/harib08c/bootpack.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/11_day/harib08c/bootpack.h`を参照する）
- 書籍に従って `sheet.c` を修正する（`projects/11_day/harib08c/sheet.c`を参照する）

#### ウィンドウを出してみよう (harib08d)

- 書籍に従って `bootpack.c` を修正する（`projects/11_day/harib08d/bootpack.c`を参照する）

#### 少し遊んでみる (harib08e)

- 書籍に従って `bootpack.c` を修正する（`projects/11_day/harib08e/bootpack.c`を参照する）

#### 高速カウンタだぁ (harib08f)

- 書籍に従って `bootpack.c` を修正する（`projects/11_day/harib08f/bootpack.c`を参照する）

#### チラチラ解消(1) (harib08g)

- 書籍に従って `sheet.c` を修正する（`projects/11_day/harib08g/sheet.c`を参照する）
  - 書籍と実装差異があったので合わせて修正

#### チラチラ解消(2) (harib08h)

- 書籍に従って `bootpack.h` を修正する（`projects/11_day/harib08h/bootpack.h`を参照する）
- 書籍に従って `sheet.c` を修正する（`projects/11_day/harib08h/sheet.c`を参照する）

### 十二日目 : タイマ‐１

#### タイマを使おう (harib09a)

- 書籍に従って `timer.c` を作成する（`projects/12_day/harib09a/timer.c`を参照する）
- 書籍に従って `bootpack.c` を修正する（`projects/12_day/harib09a/bootpack.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/12_day/harib09a/bootpack.h`を参照する）
- 書籍に従って `dsctbl.c` を修正する（`projects/12_day/harib09a/dsctbl.c`を参照する）
- 書籍に従って `nasmfunc.asm` を修正する（`projects/12_day/harib09a/naskfunk.nas`を参照する）

#### 時間をはかってみよう (harib09b)

- 書籍に従って `timer.c` を修正する（`projects/12_day/harib09b/timer.c`を修正する）
- 書籍に従って `bootpack.c` を修正する（`projects/12_day/harib09b/bootpack.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/12_day/harib09b/bootpack.h`を参照する）

#### タイムアウト機能 (harib09c)

- 書籍に従って `timer.c` を修正する（`projects/12_day/harib09c/timer.c`を修正する）
- 書籍に従って `bootpack.c` を修正する（`projects/12_day/harib09c/bootpack.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/12_day/harib09c/bootpack.h`を参照する）

#### 複数のタイマを (harib09d)

- 書籍に従って `timer.c` を修正する（`projects/12_day/harib09d/timer.c`を修正する）
- 書籍に従って `bootpack.c` を修正する（`projects/12_day/harib09d/bootpack.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/12_day/harib09d/bootpack.h`を参照する）

#### 割り込み処理は短く(1) (harib09e)

- 書籍に従って `timer.c` を修正する（`projects/12_day/harib09e/timer.c`を修正する）

#### 割り込み処理は短く(2) (harib09f)

- 書籍に従って `timer.c` を修正する（`projects/12_day/harib09f/timer.c`を修正する）
- 書籍に従って `bootpack.h` を修正する（`projects/12_day/harib09f/bootpack.h`を参照する）

#### 割り込み処理は短く(3) (harib09g)

- 書籍に従って `timer.c` を修正する（`projects/12_day/harib09g/timer.c`を修正する）
- 書籍に従って `bootpack.h` を修正する（`projects/12_day/harib09g/bootpack.h`を参照する）

### 十三日目 : タイマ-２

#### 文字列表示を簡単に (harib10a)

- 書籍に従って `bootpack.c` を修正する（`projects/13_day/harib10a/bootpack.c`を参照する）

#### FIFO バッファを見直す(1) (harib10b)

- 書籍に従って `bootpack.c` を修正する（`projects/13_day/harib10b/bootpack.c`を参照する）

#### 性能を測定してみる (harib10c ～ harib10f)

- harib10c

  - 書籍に従って `bootpack.c` を修正する（`projects/13_day/harib10c/bootpack.c`を参照する）
  - `count++` に `sheet_refresh()` を追記する（引数は、ここに元々書かれていた`putfonts8_asc_sht()`の引数に従っている）  
    この処理を入れなかった場合に、OS の動作がすごく遅くなった
    （マウスがほとんど動かない、点滅カーソル・3 秒・10 秒の表示がされない など）  
    原因は分かっていないが、

    > IC/PIT もしくは CPU クロック数に原因があると推測

    と書かれている [ページ](https://github.com/zacfukuda/hariboteos#harib10charib11e) があった。

    ```diff
        while (1)
        {
            count++;
    +       /* ダミーのリフレッシュ処理 */
    +       sheet_refresh(sht_win, 40, 28, 40 + 10 * 8, 28 + 16);
            io_cli();
    ```

    - 測定結果(QEMU) : 平均値 211440  
      結構なばらつきがあるが、環境要因と思うため気にしない。

      | N 回目 | count 値 |
      | :----: | :------: |
      |   1    |  219636  |
      |   2    |  192873  |
      |   3    |  223634  |
      |   4    |  222305  |
      |   5    |  198756  |

- harib10d (harib10c + harib09d の timer.c と bootpack.h)

  - 測定結果(QEMU) : 平均値 213123

    | N 回目 | count 値 |
    | :----: | :------: |
    |   1    |  217481  |
    |   2    |  192920  |
    |   3    |  220429  |
    |   4    |  220199  |
    |   5    |  214589  |

- harib10e (harib10c + harib09e の timer.c と bootpack.h)

  - 測定結果(QEMU) : 平均値 220916

    | N 回目 | count 値 |
    | :----: | :------: |
    |   1    |  224573  |
    |   2    |  223295  |
    |   3    |  216160  |
    |   4    |  221558  |
    |   5    |  218998  |

- harib10f (harib10c + harib09f の timer.c と bootpack.h)

  - 測定結果(QEMU) : 平均値 199679

    | N 回目 | count 値 |
    | :----: | :------: |
    |   1    |  197998  |
    |   2    |  223111  |
    |   3    |  222290  |
    |   4    |  156962  |
    |   5    |  198037  |

QEMU 上で測定したためばらつきが大きく、性能が上がったとは言えない測定結果となった。

【参考】

- [30 日でできる!OS 自作入門 on macOS](https://github.com/zacfukuda/hariboteos)

#### FIFO バッファを見直す(2) (harib10g)

- 書籍に従って `bootpack.h` を修正する（`projects/13_day/harib10g/bootpack.h`を参照する）
- 書籍に従って `bootpack.c` を修正する（`projects/13_day/harib10g/bootpack.c`を参照する）
- 書籍に従って `fifo.c` を修正する（`projects/13_day/harib10g/fifo.c`を参照する）
- 書籍に従って `keyboard.c` を修正する（`projects/13_day/harib10g/keyboard.c`を参照する）
- 書籍に従って `mouse.c` を修正する（`projects/13_day/harib10g/mouse.c`を参照する）
- 書籍に従って `timer.c` を修正する（`projects/13_day/harib10g/timer.c`を参照する）

測定結果(QEMU) : 平均値 214835

| N 回目 | count 値 |
| :----: | :------: |
|   1    |  217260  |
|   2    |  219412  |
|   3    |  218822  |
|   4    |  200946  |
|   5    |  217737  |

#### 割り込み処理は短く(4) (harib10h)

- 書籍に従って `bootpack.h` を修正する（`projects/13_day/harib10h/bootpack.h`を参照する）
- 書籍に従って `timer.c` を修正する（`projects/13_day/harib10h/timer.c`を参照する）

#### 番兵を使ってプログラムを短くしてみる (harib10i)

- 書籍に従って `bootpack.h` を修正する（`projects/13_day/harib10i/bootpack.h`を参照する）
- 書籍に従って `timer.c` を修正する（`projects/13_day/harib10i/timer.c`を参照する）

### 十四日目 : 高解像度・キー入力

#### また性能を測定してみる (harib11a ～ harib11c)

割愛

#### 高解像度にしよう(1) (harib11d)

- 書籍に従って `asmhead.asm` を修正する（`projects/14_day/harib11d/asmhead.nas`を参照する）
  - グラフィックバッファの開始番地変更  
    グラフィックバッファの開始番地を `0xe0000000` としたら、画面が真っ黒になった。
    [「30 日でできる！ OS 自作入門」を Mac 向けに環境構築する](https://qiita.com/tatsumack/items/491e47c1a7f0d48fc762) を参考に
    開始番地を `0xfd000000` としたら、画面が表示された。  
    (640x480 のグラフィックを使うときのバッファの開始番地が書籍の環境と違ったのだろう・・・程度の理解。なぜ 0xfd000000 かは確認できていない。)

【参考】

- [「30 日でできる！ OS 自作入門」を Mac 向けに環境構築する](https://qiita.com/tatsumack/items/491e47c1a7f0d48fc762)
- [VESA - os-wiki](http://oswiki.osask.jp/?VESA)

#### 高解像度にしよう(2) (harib11e)

- 書籍に従って `asmhead.asm` を修正する（`projects/14_day/harib11e/asmhead.nas`を参照する）
  - グラフィックバッファの開始番地確認  
    `HariMain()`で `binfo-vram`の値を画面に出力したところ、`0xfd000000`となっていることが確認できた。

#### キー入力(1) (harib11f)

- 書籍に従って `bootpack.c` を修正する（`projects/14_day/harib11f/bootpack.c`を参照する）
- harib10c で入れていたダミーのリフレッシュ処理を削除する

#### キー入力(2) (harib11g)

- 書籍に従って `bootpack.c` を修正する（`projects/14_day/harib11g/bootpack.c`を参照する）  
  書籍に書いてある
  > 「@」等のキーを押すと「W」が表示されて・・・
  > の現象は起きなかった（「@」を押すと「@」が表示された）

#### おまけ(1) (harib11h)

- 書籍に従って `bootpack.c` を修正する（`projects/14_day/harib11h/bootpack.c`を参照する）

#### おまけ(2) (harib11i)

- 書籍に従って `bootpack.c` を修正する（`projects/14_day/harib11i/bootpack.c`を参照する）

### 十五日目 マルチタスク-1

#### タスクスイッチに挑戦 (harib12a)

- 書籍に従って `nasmfunc.asm` を修正する（`projects/15_day/harib12a/naskfunc.nas`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/15_day/harib12a/bootpack.h`を参照する）
- 書籍に従って `bootpack.c` を修正する（`projects/15_day/harib12a/bootpack.c`を参照する）

#### もっとタスクスイッチ (harib12b)

- 書籍に従って `nasmfunc.asm` を修正する（`projects/15_day/harib12b/naskfunc.nas`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/15_day/harib12b/bootpack.h`を参照する）
- 書籍に従って `bootpack.c` を修正する（`projects/15_day/harib12b/bootpack.c`を参照する）

#### 簡単なマルチタスクをやってみる(1) (harib12c)

- 書籍に従って `nasmfunc.asm` を修正する（`projects/15_day/harib12c/naskfunc.nas`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/15_day/harib12c/bootpack.h`を参照する）
- 書籍に従って `bootpack.c` を修正する（`projects/15_day/harib12c/bootpack.c`を参照する）

#### 簡単なマルチタスクをやってみる(2) (harib12d)

- 書籍に従って `bootpack.c` を修正する（`projects/15_day/harib12d/bootpack.c`を参照する）

#### スピードアップ (harib12e)

- 書籍に従って `bootpack.c` を修正する（`projects/15_day/harib12e/bootpack.c`を参照する）
  - `task_b_main()`にダミーのリフレッシュ処理を追加。
  ```c
  while(1)
  {
      count++;
      putfonts8_asc_sht(sht_back, 0, 144, COL8_FFFFFF, COL8_008484, " ", 1); /* ダミーのリフレッシュ処理 */
      io_cli();
      if (fifo32_status(&fifo) == 0)
      {
          io_sti();
      }
  ```
  `fifo32_status()` が 0 のときに `io_stihlt()` を呼ぶ場合は問題ないが、
  `io_sti()` だとカウンタ等が描画されなくなる。
  この場合は上記のようにダミーのリフレッシュ処理を入れることで解決。  
   （harib10c の減少と同じなのかな？）

#### スピード測定 (harib12f)

- 書籍に従って `bootpack.c` を修正する（`projects/15_day/harib12f/bootpack.c`を参照する）

#### もっとマルチタスク (harib12g)

- 書籍に従って `mtask.c` を新規作成する（`projects/15_day/harib12g/mtask.c`を参照する）
- 書籍に従って `timer.c` を修正する（`projects/15_day/harib12g/timer.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/15_day/harib12g/bootpack.h`を参照する）
- 書籍に従って `bootpack.c` を修正する（`projects/15_day/harib12g/bootpack.c`を参照する）

### 十六日目 マルチタスク-2

#### タスク管理の自動化 (harib13a)

- 書籍に従って `mtask.c` を修正する（`projects/16_day/harib13a/mtask.c`を参照する）
- 書籍に従って `timer.c` を修正する（`projects/16_day/harib13a/timer.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/16_day/harib13a/bootpack.h`を参照する）
- 書籍に従って `bootpack.c` を修正する（`projects/16_day/harib13a/bootpack.c`を参照する）

#### スリープしてみる (harib13b)

- 書籍に従って `bootpack.h` を修正する（`projects/16_day/harib13b/bootpack.h`を参照する）
- 書籍に従って `bootpack.c` を修正する（`projects/16_day/harib13b/bootpack.c`を参照する）
- 書籍に従って `mtask.c` を修正する（`projects/16_day/harib13b/mtask.c`を参照する）
- 書籍に従って `fifo.c` を修正する（`projects/16_day/harib13b/fifo.c`を参照する）

#### ウィンドウを増やそう (harib13c)

- 書籍に従って `bootpack.c` を修正する（`projects/16_day/harib13c/bootpack.c`を参照する）
- マウスの動きがカクカクして遅くなったが、 harib13e 修正されるようなのでここでは気にしない。  
  (harib10c での現象と同じものと思われる。)

#### 優先順位を付けよう(1) (harib13d)

- 書籍に従って `bootpack.h` を修正する（`projects/16_day/harib13d/bootpack.h`を参照する）
- 書籍に従って `bootpack.c` を修正する（`projects/16_day/harib13d/bootpack.c`を参照する）
- 書籍に従って `mtask.c` を修正する（`projects/16_day/harib13d/mtask.c`を参照する）
- 書籍に従って `fifo.c` を修正する（`projects/16_day/harib13d/fifo.c`を参照する）

#### 優先順位を付けよう(2) (harib13e)

- 書籍に従って `bootpack.h` を修正する（`projects/16_day/harib13e/bootpack.h`を参照する）
- 書籍に従って `bootpack.c` を修正する（`projects/16_day/harib13e/bootpack.c`を参照する）
- 書籍に従って `mtask.c` を修正する（`projects/16_day/harib13e/mtask.c`を参照する）
- 書籍に従って `fifo.c` を修正する（`projects/16_day/harib13e/fifo.c`を参照する）
- マウスの動きカクカクが解消されずだが、harib10c で参照した[ページ](https://github.com/zacfukuda/hariboteos#harib13charib13g)に
  言及されていた。  
  ダミーのリフレッシュとして task_b_main() の for 文で毎回、空白文字を描く処理を追加
  （カウンタ値はとても小さくなった）
  ```diff
     while(1)
     {
         count++;
  +      putfonts8_asc_sht(sht_win_b, 24, 28, COL8_000000, COL8_C6C6C6, " ", 1);
         io_cli();
  ```

【参考】

- [30 日でできる!OS 自作入門 on macOS](https://github.com/zacfukuda/hariboteos)

### 十七日目 コンソール

#### アイドルタスク (harib14a)

- 書籍に従って `mtask.c` を修正する（`projects/17_day/harib14a/mtask.c`を参照する）
- 書籍に従って `bootpack.c` を修正する（`projects/17_day/harib14a/bootpack.c`を参照する）

#### コンソールを作ろう (harib14b)

- 書籍に従って `bootpack.h` を修正する（`projects/17_day/harib14b/bootpack.h`を参照する）
- 書籍に従って `bootpack.c` を修正する（`projects/17_day/harib14b/bootpack.c`を参照する）

#### 入力切り替えをやってみる (harib14c)

- 書籍に従って `bootpack.c` を修正する（`projects/17_day/harib14c/bootpack.c`を参照する）

#### 文字入力をできるようにしてみる (harib14d)

- 書籍に従って `bootpack.h` を修正する（`projects/17_day/harib14d/bootpack.h`を参照する）
- 書籍に従って `bootpack.c` を修正する（`projects/17_day/harib14d/bootpack.c`を参照する）

#### 記号入力 (harib14e)

- 書籍に従って `bootpack.h` を修正する（`projects/17_day/harib14e/bootpack.h`を参照する）
- 書籍に従って `bootpack.c` を修正する（`projects/17_day/harib14e/bootpack.c`を参照する）
- 右 Shift キーが効いていないようだ。左 Shift キーでは記号が打てるが、右 Shift キーでは記号が打てない。
  右 Shift キー押下時の `fifo32_get(&fifo)` の値を確認したが、何も表示されなかった（右 Shift はデータが来ていない？）  
  （左 Shift で記号打てるのでいったん気にしない）

#### 大文字と小文字 (harib14f)

- 書籍に従って `bootpack.c` を修正する（`projects/17_day/harib14f/bootpack.c`を参照する）

#### Lock キー対応 (harib14g)

- 書籍に従って `bootpack.c` を修正する（`projects/17_day/harib14g/bootpack.c`を参照する）
- 使っている環境のせいなのか、CapsLock/NumLock/ScrollLock のキーコードが書籍の記載と一致していないため、
  プログラムは書いたものの正しく動作しているかわからない。

### 十八日目 dir コマンド

#### カーソルの点滅制御(1) (harib15a)

- 書籍に従って `bootpack.c` を修正する（`projects/18_day/harib15a/bootpack.c`を参照する）

#### カーソルの点滅制御(2) (harib15b)

- 書籍に従って `bootpack.c` を修正する（`projects/18_day/harib15b/bootpack.c`を参照する）

#### Enter キーに対応 (harib15c)

- 書籍に従って `bootpack.c` を修正する（`projects/18_day/harib15c/bootpack.c`を参照する）

#### スクロールにも対応 (harib15d)

- 書籍に従って `bootpack.c` を修正する（`projects/18_day/harib15d/bootpack.c`を参照する）

#### mem コマンド (harib15e)

- 書籍に従って `bootpack.c` を修正する（`projects/18_day/harib15e/bootpack.c`を参照する）

#### cls コマンド (harib15f)

- 書籍に従って `bootpack.c` を修正する（`projects/18_day/harib15f/bootpack.c`を参照する）
- `golibc.h` に `strcmp()` のプロトタイプ宣言を記載する。

#### dir コマンド (harib15g)

- 書籍に従って `bootpack.c` を修正する（`projects/18_day/harib15g/bootpack.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/18_day/harib15g/bootpack.h`を参照する）
- 書籍を参考に `Makefile` を修正する（`projects/18_day/harib15g/bootpack.c`を参考にする）  
  dir コマンドのファイル名出力のため、`haribote.img` に `ipl10.asm`, `Makefile` を含めるように修正。
  ```diff
    $(IMGFILE) : ipl10.bin haribote.sys
      mformat -f 1440 -B ipl10.bin -C -i $@ ::
      mcopy haribote.sys -i $@ ::
  +   mcopy ipl10.asm -i $@ ::
  +   mcopy Makefile -i $@ ::
  ```

### 十九日目 アプリケーション

#### type コマンド (harib16a)

- 書籍に従って `bootpack.c` を修正する（`projects/19_day/harib16a/bootpack.c`を参照する）

#### type コマンド改良 (harib16b)

- 書籍に従って `bootpack.c` を修正する（`projects/19_day/harib16b/bootpack.c`を参照する）
- `golibc.h` を修正する

  - `strncmp()` のプロトタイプ宣言を記載する。
  - `size_t` 型定義を使うために `stddef.h` を include する。

  ```diff
  + #include <stddef.h>

    int sprintf(char *s, const char *format, ...);
    int strcmp (const char *d, const char *s);
  + int strncmp (char *d, const char *s, size_t sz);
  ```

- ファイル出力後に 1 行ズラすように追加修正  
  出力ファイルの最終行に空行がない場合に、プロンプト表示がファイル最終行と同じ行に表示されるため。
  ```diff
            else
            {
                putfonts8_asc_sht(sheet, cursor_x, cursor_y, COL8_FFFFFF, COL8_000000, s, 1);
                cursor_x += 8;
                if (cursor_x == 8 + 240) /* 右端まで来たので改行 */
                {
                    cursor_x = 8;
                    cursor_y = cons_newline(cursor_y, sheet);
                }
            }
        }
  +     cursor_y = cons_newline(cursor_y, sheet); /* ファイルの出力が終わったらプロンプト表示の前に1行ずらす */
    }
    else
    {
        /* ファイルが見つからなかった場合 */
  ```

#### FAT に対応 (harib16c)

- 書籍に従って `bootpack.c` を修正する（`projects/19_day/harib16c/bootpack.c`を参照する）

#### ソースの整理 (harib16d)

- 書籍に従って `bootpack.c` を修正する（`projects/19_day/harib16d/bootpack.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/19_day/harib16d/bootpack.h`を参照する）
- 書籍に従って `window.c` を新規作成する（`projects/19_day/harib16d/window.c`を参照する）
- 書籍に従って `file.c` を新規作成する（`projects/19_day/harib16d/file.c`を参照する）
- 書籍に従って `console.c` を新規作成する（`projects/19_day/harib16d/console.c`を参照する）

#### ついに初アプリ (harib16e)

- 書籍に従って `console.c` を修正する（`projects/19_day/harib16e/console.c`を参照する）
- 書籍に従って `hlt.asm` を新規作成する（`projects/19_day/harib16d/hlt.nas`を参照する）
- `Makefile` を修正する

### 二十日目 API

#### プログラムの整理 (harib17a)

- 書籍に従って `console.c` を修正する（`projects/20_day/harib17a/console.c`を参照する）
- 書籍に従って `file.c` を修正する（`projects/20_day/harib17a/file.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/20_day/harib17a/bootpack.h`を参照する）

#### 一文字表示 API(1) (harib17b)

- 書籍に従って `hlt.asm` を修正する（`projects/20_day/harib17b/hlt.nas`を参照する）
- 書籍に従って `nasmfunc.asm` を修正する（`projects/20_day/harib17b/naskfunc.nas`を参照する）
- 書籍に従って `console.c` を修正する（`projects/20_day/harib17b/console.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/20_day/harib17b/bootpack.h`を参照する）

#### 一文字表示 API(2) (harib17c)

- 書籍に従って `hlt.asm` を修正する（`projects/20_day/harib17c/hlt.nas`を参照する）
- 書籍に従って `nasmfunc.asm` を修正する（`projects/20_day/harib17c/naskfunc.nas`を参照する）
- `Makefile`を修正する  
  `bootpack.bin` 生成時にマップファイルも生成するようにオプションを追加する。
  `hlt.asm` に書く asm_cons_putchar のアドレスは `bootpack.map` を見て確認する。
  ```diff
    bootpack.bin : $(OBJS) $(GOLIBCPATH)/libgolibc.a
  -   ld -m elf_i386 -e HariMain -o $@ -T hrb.ld $(OBJS) -static -L$(GOLIBCPATH) -lgolibc
  +   ld -m elf_i386 -e HariMain -o $@ -T hrb.ld $(OBJS) -static -L$(GOLIBCPATH) -lgolibc -Map bootpack.map
  ```

#### アプリケーションの終了 (harib17d)

- 書籍に従って `hlt.asm` を修正する（`projects/20_day/harib17d/hlt.nas`を参照する）
- 書籍に従って `nasmfunc.asm` を修正する（`projects/20_day/harib17d/naskfunc.nas`を参照する）
- 書籍に従って `console.c` を修正する（`projects/20_day/harib17d/console.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/20_day/harib17d/bootpack.h`を参照する）

#### OS のバージョンが変わっても変わらない API (harib17e)

- 書籍に従って `dsctbl.c` を修正する（`projects/20_day/harib17e/dsctbl.c`を参照する）
- 書籍に従って `hlt.asm` を修正する（`projects/20_day/harib17e/hlt.nas`を参照する）
- 書籍に従って `nasmfunc.asm` を修正する（`projects/20_day/harib17e/naskfunc.nas`を参照する）

#### アプリケーション名を自由に (harib17f)

- 書籍に従って `console.c` を修正する（`projects/20_day/harib17f/console.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/20_day/harib17f/bootpack.h`を参照する）
- 書籍に従って `hlt.asm` を `hello.asm` にリネームする  
  伴って、`Makefile` を修正する

#### レジスタに気をつけよう (harib17g)

- 書籍に従って `hello.asm` を修正する（`projects/20_day/harib17g/hello.nas`を参照する）
- 書籍に従って `nasmfunc.asm` を修正する（`projects/20_day/harib17g/naskfunc.nas`を参照する）

#### 文字列表示 API (harib17h)

- 書籍に従って `console.c` を修正する（`projects/20_day/harib17h/console.c`を参照する）
- 書籍に従って `dsctbl.c` を修正する（`projects/20_day/harib17h/dsctbl.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/20_day/harib17h/bootpack.h`を参照する）
- 書籍に従って `hello.asm` を修正する（`projects/20_day/harib17h/hello.nas`を参照する）
- 書籍に従って `nasmfunc.asm` を修正する（`projects/20_day/harib17h/naskfunc.nas`を参照する）
- 書籍に従って `hello2.asm` を新規作成する（`projects/20_day/harib17h/hello2.nas`を参照する）
- `Makefile` を修正する

### 二十一日目 OS を守ろう

#### 文字列表示 API を今度こそ (harib18a)

- 書籍に従って `console.c` を修正する（`projects/21_day/harib18a/console.c`を参照する）

#### アプリケーションを C 言語で作ってみたい (harib18b)

- 書籍に従って `console.c` を修正する（`projects/21_day/harib18b/console.c`を参照する）
- 書籍に従って `a_nasm.asm` を新規作成する（`projects/21_day/harib18b/a_nask.nas`を参照する）
- 書籍に従って `a.c` を新規作成する（`projects/21_day/harib18b/a.c`を参照する）
- 書籍に従って `hello3.c` を新規作成する（`projects/21_day/harib18b/hello3.c`を参照する）
- アプリケーション用のリンカスクリプト `app.ld` を作成する  
  [このページ](https://vanya.jp.net/os/haribote.html#hrb)の "アプリケーション用リンカスクリプト" を作成する。
  `app.ld` は ld コマンドで a.hrb, hello3.hrb を生成するときに使用する。
- アプリ関連のファイルを app ディレクトリ内に移動する
- `Makefile` を修正する

【参考】

- [30 日でできる!OS 自作入門 on macOS](https://github.com/zacfukuda/hariboteos)
- [『30 日でできる！OS 自作入門』のメモ](https://vanya.jp.net/os/haribote.html)

#### OS を守ろう(1) (harib18c)

- 書籍に従って `crack1.c` を新規作成する（`projects/21_day/harib18c/crack1.c`を参照する）
- `Makefile` を修正する

#### OS を守ろう(2) (harib18d)

- 書籍に従って `console.c` を修正する（`projects/21_day/harib18d/console.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/21_day/harib18d/bootpack.h`を参照する）
- 書籍に従って `nasmfunc.asm` を修正する（`projects/21_day/harib18d/naskfunc.nas`を参照する）  
  start_app の最後の POPAD を POPD と書き間違えていたことに気づかず、しばらくハマった（上手くいかない原因の 8 ～ 9 割が書き間違いだなあ）。
  書き間違えた状態で haribote.img を生成し、 各種コマンドを実行すると以下のような挙動になった。
  （退避したレジスタの値を正しく復元できていないはずだから、挙動が変になるのは納得）
  - hello コマンド : 画面の色が変化（ネガポジ反転みたいになる）
  - hello2 コマンド : ウィンドウ・コンソール内の表示が初期状態に戻りフリーズ
  - hello3 コマンド : ウィンドウ・コンソール内の表示が初期状態に戻りフリーズ
  - a コマンド : "A" と表示されるが、すぐにウィンドウ・コンソール内の表示が初期状態に戻りフリーズ
  - crack1 コマンド : ウィンドウ・コンソール内の表示が初期状態に戻りフリーズ

#### 例外をサポートしよう (harib18e)

- 書籍に従って `console.c` を修正する（`projects/21_day/harib18e/console.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/21_day/harib18e/bootpack.h`を参照する）
- 書籍に従って `dsctbl.c` を修正する（`projects/21_day/harib18e/dsctbl.c`を参照する）
- 書籍に従って `nasmfunc.asm` を修正する（`projects/21_day/harib18e/naskfunc.nas`を参照する）

#### OS を守ろう(3) (harib18f)

- 書籍に従って `crack2.c` を新規作成する（`projects/21_day/harib18f/crack2.c`を参照する）
- `Makefile` を修正する

#### OS を守ろう(4) (harib18g)

- 書籍に従って `console.c` を修正する（`projects/21_day/harib18g/console.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/21_day/harib18g/bootpack.h`を参照する）
- 書籍に従って `dsctbl.c` を修正する（`projects/21_day/harib18g/dsctbl.c`を参照する）
- 書籍に従って `nasmfunc.asm` を修正する（`projects/21_day/harib18g/naskfunc.nas`を参照する）
- 書籍に従って `a_nasm.asm` を修正する（`projects/21_day/harib18g/a_nask.nas`を参照する）
- 書籍に従って `hello.asm` を修正する（`projects/21_day/harib18g/hello.nas`を参照する）
- 書籍に従って `hello2.asm` を修正する（`projects/21_day/harib18g/hello2.nas`を参照する）
- 書籍に従って `a.c` を修正する（`projects/21_day/harib18g/a.c`を参照する）
- 書籍に従って `hello3.c` を修正する（`projects/21_day/harib18g/hello3.c`を参照する）
- 書籍に従って `crack1.c` を修正する（`projects/21_day/harib18g/crack1.c`を参照する）
- 書籍に従って `crack2.asm` を修正する（`projects/21_day/harib18g/hello2.nas`を参照する）

### 二十二日目 C 言語でアプリケーションを作ろう

#### OS を守ろう(5) (harib19a)

- 書籍に従って `console.c` を修正する（`projects/22_day/harib19a/console.c`を参照する）
- 書籍に従って `crack3.asm` を新規作成する（`projects/22_day/harib19a/crack3.nas`を参照する）
- 書籍に従って `crack4.asm` を新規作成する（`projects/22_day/harib19a/crack4.nas`を参照する）
- 書籍に従って `crack5.asm` を新規作成する（`projects/22_day/harib19a/crack5.nas`を参照する）
- 書籍に従って `crack6.asm` を新規作成する（`projects/22_day/harib19a/crack6.nas`を参照する）
- `Makefile` を修正する

#### バグ発見を手伝おう (harib19b)

- 書籍に従って `bootpack.h` を修正する（`projects/22_day/harib19b/bootpack.h`を参照する）
- 書籍に従って `console.c` を修正する（`projects/22_day/harib19b/console.c`を参照する）
- 書籍に従って `dsctbl.c` を修正する（`projects/22_day/harib19b/dsctbl.c`を参照する）
- 書籍に従って `nasmfunc.asm` を修正する（`projects/22_day/harib19b/naskfunc.nas`を参照する）
- 書籍に従って `bug1.c` を新規作成する（`projects/22_day/harib19b/bug1.c`を参照する）
- crack1 ～ crack6 のファイルを削除する
- `Makefile` を修正する

#### アプリの強制終了 (harib19c)

- 書籍に従って `bootpack.c` を修正する（`projects/22_day/harib19c/bootpack.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/22_day/harib19c/bootpack.h`を参照する）
- 書籍に従って `mtask.c` を修正する（`projects/22_day/harib19c/mtask.c`を参照する）
- 書籍に従って `nasmfunc.asm` を修正する（`projects/22_day/harib19c/naskfunc.nas`を参照する）
- 書籍に従って `bug2.c` を新規作成する（`projects/22_day/harib19c/bug2.c`を参照する）
- 書籍に従って `bug3.c` を新規作成する（`projects/22_day/harib19c/bug3.c`を参照する）
- `Makefile` を修正する

#### C 言語で文字列表示(1) (harib19d)

- 書籍に従って `console.c` を修正する（`projects/22_day/harib19d/console.c`を参照する）
- 書籍に従って `a_nasm.asm` を修正する（`projects/22_day/harib19d/a_nask.nas`を参照する）
- 書籍に従って `hello4.c` を新規作成する（`projects/22_day/harib19c/hello4.c`を参照する）
- `Makefile` を修正する

#### C 言語で文字列表示(2) (harib19e)

- 書籍に従って `console.c` を修正する（`projects/22_day/harib19e/console.c`を参照する）
- 書籍に従って `hello5.asm` を新規作成する（`projects/22_day/harib19e/hello5.nas`を参照する）
- `Makefile` を修正する

#### ウィンドウを出そう (harib19f)

- 書籍に従って `bootpack.c` を修正する（`projects/22_day/harib19f/bootpack.c`を参照する）
- 書籍に従って `console.c` を修正する（`projects/22_day/harib19f/console.c`を参照する）
- 書籍に従って `a_nasm.asm` を修正する（`projects/22_day/harib19f/a_nask.nas`を参照する）
- 書籍に従って `winhelo.c` を新規作成する（`projects/22_day/harib19f/winhelo.c`を参照する）

#### ウィンドウに文字や四角を描こう (harib19g)

- 書籍に従って `console.c` を修正する（`projects/22_day/harib19g/console.c`を参照する）
- 書籍に従って `a_nasm.asm` を修正する（`projects/22_day/harib19g/a_nask.nas`を参照する）
- 書籍に従って `winhelo2.c` を新規作成する（`projects/22_day/harib19g/winhelo2.c`を参照する）
- bug1 ～ bug3 のファイルを削除する
- `Makefile` を修正する

### 二十三日目 グラフィックいろいろ

#### malloc を作ろう (harib20a)

- 書籍に従って `console.c` を修正する（`projects/23_day/harib20a/console.c`を参照する）
- 書籍に従って `a_nasm.asm` を修正する（`projects/23_day/harib20a/a_nask.nas`を参照する）
- 書籍に従って `winhelo3.c` を新規作成する（`projects/23_day/harib20a/winhelo3.c`を参照する）
- `Makefile` を修正する

#### 点を描く (harib20b)

- 書籍に従って `console.c` を修正する（`projects/23_day/harib20b/console.c`を参照する）
- 書籍に従って `a_nasm.asm` を修正する（`projects/23_day/harib20b/a_nask.nas`を参照する）
- 書籍に従って `star1.c` を新規作成する（`projects/23_day/harib20b/star1.c`を参照する）
- 書籍に従って `stars.c` を新規作成する（`projects/23_day/harib20b/stars.c`を参照する）
- `golibc.a` に rand 関数を含めて再生成
- `Makefile` を修正する

#### ウィンドウのリフレッシュ(harib20c)

- 書籍に従って `console.c` を修正する（`projects/23_day/harib20c/console.c`を参照する）
- 書籍に従って `a_nasm.asm` を修正する（`projects/23_day/harib20c/a_nask.nas`を参照する）
- 書籍に従って `stars2.c` を新規作成する（`projects/23_day/harib20c/stars2.c`を参照する）
- `Makefile` を修正する

#### 線を引く (harib20d)

- 書籍に従って `console.c` を修正する（`projects/23_day/harib20d/console.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/23_day/harib20d/bootpack.h`を参照する）
- 書籍に従って `a_nasm.asm` を修正する（`projects/23_day/harib20d/a_nask.nas`を参照する）
- 書籍に従って `lines.c` を新規作成する（`projects/23_day/harib20d/lines.c`を参照する）
- `Makefile` を修正する

#### ウィンドウのクローズ (harib20e)

- 書籍に従って `console.c` を修正する（`projects/23_day/harib20e/console.c`を参照する）
- 書籍に従って `a_nasm.asm` を修正する（`projects/23_day/harib20e/a_nask.nas`を参照する）
- 書籍に従って `lines.c` を修正する（`projects/23_day/harib20e/lines.c`を参照する）

#### キー入力の API (harib20f)

- 書籍に従って `console.c` を修正する（`projects/23_day/harib20f/console.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/23_day/harib20f/bootpack.h`を参照する）
- 書籍に従って `a_nasm.asm` を修正する（`projects/23_day/harib20f/a_nask.nas`を参照する）
- 書籍に従って `lines.c` を修正する（`projects/23_day/harib20f/lines.c`を参照する）

#### キー入力で遊ぶ (harib20g)

- 書籍に従って `walk.c` を新規作成する（`projects/23_day/harib20dg/walk.c`を参照する）
- `Makefile` を修正する

#### 強制終了でウィンドウを閉じる (harib20h)

- 書籍に従って `sheet.c` を修正する（`projects/23_day/harib20g/sheet.c`を参照する）
- 書籍に従って `console.c` を修正する（`projects/23_day/harib20g/console.c`を参照する）
- 書籍に従って `bootpack.h` を修正する（`projects/23_day/harib20g/bootpack.h`を参照する）

### 二十四日目 ウィンドウ操作

#### ウィンドウの切り替え(1) (harib21a)

- 書籍に従って `bootpack.c` を修正する（`projects/23_day/harib21a/bootpack.c`を参照する）

#### ウィンドウの切り替え(2) (harib21b)

- 書籍に従って `bootpack.c` を修正する（`projects/23_day/harib21b/bootpack.c`を参照する）

#### ウィンドウの移動 (harib21c)

- 書籍に従って `bootpack.c` を修正する（`projects/23_day/harib21c/bootpack.c`を参照する）

#### ウィンドウをマウスで閉じる (harib21d)

#### アプリケーションウィンドウも入力切り替え (harib21e)

#### 入力ウィンドウをマウスで切り替える (harib21f)

#### タイマ API (harib21g)

#### タイマのキャンセル (harib21h)

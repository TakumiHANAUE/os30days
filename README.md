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

- 書籍に従って `int.c` を修正する（`projects/07_day/harib04a/int.c`を参照する）
- `bootpack.h` に `io_in8()` のプロトタイプ宣言を追記する。
- `golibc.h` を新規作成し、`sprintf()` のプロトタイプ宣言を記載する。
  - `bootpack.c` から `sprintf()` のプロトタイプ宣言を削除し、`golibc.h` の include 文を追記する。
  - `int.c` に `golibc.h` の include 文を追記する。

#### キーコードを取得しよう (harib04a)

#### 割り込み処理は手早く (harib04b)

- 書籍に従って `int.c` を修正する（`projects/07_day/harib04b/int.c`を参照する）
- 書籍に従って `bootpack.c` を修正する（`projects/07_day/harib04b/bootpack.c`を参照する）
- `bootpack.h` を以下の通り修正する。
  - `io_stihlt()` のプロトタイプ宣言を追記する。
  - `struct KEYBUF` の定義を追記する。

#### FIFO バッファを作る (harib04c)

#### FIFO バッファを改良する (harib04d)

#### FIFO バッファを整理する (harib04e)

#### さあマウスだ (harib04f)

#### マウスからのデータ受信 (harib04g)

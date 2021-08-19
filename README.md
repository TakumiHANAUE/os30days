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

### 一日目

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

### 二日目

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

### 三日目

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

### 四日目

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

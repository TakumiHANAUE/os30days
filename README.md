# os30days

30 日でできる OS 自作入門

## 環境

- Ubuntu-20.04 on WSL2 on Windows10  
  img のビルドは Ubuntu-20.04 上で、img の起動は Windows10 上で行う。

## 準備 (Ubuntu-20.04 on WSL2)

### インストール

- nasm

  ```
  $ sudo apt instal nasm
  ```

- mtools
  ```
  $ sudo apt instal mtools
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

## 参考サイト

## 作業ログ

### harib01b

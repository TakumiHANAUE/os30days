# 静的ライブラリ libgolibc.a を生成する

sprintf を使うため、CD-ROM 付属のソースファイルが静的ライブラリを作る。

## 手順

1.  書籍付属の CD-ROM に含まれる `omake/tolsrc/go_0023s/golibc` を、本ディレクトリに置く。  
    ディレクトリ構成は以下のようになる。
    ```
    os30days
    └── golibc
        ├── Makefile
        ├── README.md
        ├── patch.sh
        └── golibc # CD-ROMからコピーしてくる
    ```
1.  以下コマンドを実行する。
    ```bash
    $ make patch
    $ make
    ```
    `libglibc.a` が生成される。

**注記**  
CD-ROM 付属のソースファイルに含まれる rand 関数はコンパイルしていない。

【参考】

- [5 日目 その 2](https://papamitra.hatenadiary.org/entry/20060528/1148785327)
- [はりぼて OS を NASM・GCC で動かす(Mac OSX)](https://tatsumack.hatenablog.com/entry/2017/03/24/225706)

## `patch.sh` の概要

CD-ROM 付属のソースファイルをそのままコンパイルしたところ、以下の warning/error が出たため、本スクリプトでソースファイルを一部修正する。

- strchr.c
  - 発生した warning/error
    ```
    golibc/strchr.c: In function ‘strchr’:
    golibc/strchr.c:15:11: error: ‘NULL’ undeclared (first use in this function)
       15 |    return NULL;
          |           ^~~~
    golibc/strchr.c:7:1: note: ‘NULL’ is defined in header ‘<stddef.h>’; did you forget to ‘#include <stddef.h>’?
        6 | #include <stddef.h>
      +++ |+#include <stddef.h>
        7 |
    golibc/strchr.c:15:11: note: each undeclared identifier is reported only once for each function it appears in
       15 |    return NULL;
          |           ^~~~
    ```
  - 修正内容
    ```diff
      #include <stddef.h>
    + #include <stdio.h>
    ```
- stdarg.h
  - 発生した warning/error
    ```
    In file included from golibc/sprintf.c:3:
    golibc/sprintf.c: In function ‘sprintf’:
    ./golibc/stdarg.h:11:23: warning: implicit declaration of function ‘__builtin_stdarg_start’; did you mean ‘__builtin_va_start’? [-Wimplicit-function-declaration]
       11 | #define va_start(v,l) __builtin_stdarg_start((v),l)
          |                       ^~~~~~~~~~~~~~~~~~~~~~
    golibc/sprintf.c:11:2: note: in expansion of macro ‘va_start’
       11 |  va_start(ap, format);
          |  ^~~~~~~~
    ```
  - 修正内容
    ```diff
    - #define va_start(v,l)	__builtin_stdarg_start((v),l)
    + #define va_start(v,l)	__builtin_va_start((v),l)
    ```

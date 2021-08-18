; nasmfunc
; TAB=4

BITS 32                          ; 32ビットモード用の機械語を作らせる

; オブジェクトファイルのための情報

GLOBAL      io_hlt             ; このプログラムに含まれる関数名

; 以下は実際の関数

SECTION .text

io_hlt:                        ; void io_hlt(void)
    HLT
    RET

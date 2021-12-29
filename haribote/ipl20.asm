; haribote-os
; TAB=4

CYLS    EQU     20

    ORG     0x7c00              ;   このプログラムがどこに読み込まれるのか

; 以下は標準的なFAT12フォーマットフロッピーディスクのための記述

    JMP     entry
    DB      0x90
    DB      "HELLOIPL"
    DW      512
    DB      1
    DW      1
    DB      2
    DW      224
    DW      2880
    DB      0xf0
    DW      9
    DW      18
    DW      2
    DD      0
    DD      2880
    DB      0, 0, 0x29
    DD      0xffffffff
    DB      "HELLO-OS   "
    DB      "FAT12   "
    RESB    18

; プログラム本体

entry:
    MOV     AX, 0               ; レジスタ初期化
    MOV     SS, AX
    MOV     SP, 0x7c00
    MOV     DS, AX

; ディスクを読む

    MOV     AX, 0x0820
    MOV     ES, AX
    MOV     CH, 0               ; シリンダ0
    MOV     DH, 0               ; ヘッド0
    MOV     CL, 2               ; セクタ2
readloop:
    MOV     SI, 0               ; 失敗回数を数えるレジスタ
retry:
    MOV     AH, 0x02            ; ディスク読み込み
    MOV     AL, 1               ; 1セクタ
    MOV     BX, 0
    MOV     DL, 0x00            ; Aドライブ
    INT     0x13                ; ディスクBIOS呼び出し
    JNC     next
    ADD     SI, 1
    CMP     SI, 5
    JAE     error
    MOV     AH, 0x00
    MOV     DL, 0x00
    INT     0x13
    JMP     retry
next:
    MOV     AX, ES              ; アドレスを0x200進める
    ADD     AX, 0x0020
    MOV     ES, AX
    ADD     CL, 1
    CMP     CL, 18
    JBE     readloop            ; CL <= 18 だったらreadloopへ
    MOV     CL, 1
    ADD     DH, 1
    CMP     DH, 2
    JB      readloop            ; DH < 2 だったらreadloopへ
    MOV     DH, 0
    ADD     CH, 1
    CMP     CH, CYLS
    JB      readloop            ; CH < CYLS だったらreadloopへ

; 読み終わったのでharibote.sysを実行

    MOV     [0x0ff0], CH        ; IPLがどこまで読んだのかメモ
    JMP     0xc200

error:
    MOV     AX, 0
    MOV     ES, AX
    MOV     SI, msg

putloop:
    MOV     AL, [SI]
    ADD     SI, 1
    CMP     AL, 0
    JE      fin
    MOV     AH, 0x0e
    MOV     BX, 15              ; カラーコード
    INT     0x10
    JMP     putloop
fin:
    HLT
    JMP     fin
msg:
    DB      0x0a, 0x0a
    DB      "load error"
    DB      0x0a
    DB      0

    RESB    0x7dfe-($-$$)-0x7c00       ; 0x7dfeまでを0x00で埋める命令

    DB      0x55, 0xaa

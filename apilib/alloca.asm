BITS 32

    GLOBAL      alloca

SECTION .text

alloca:
    ADD     EAX, -4
    SUB     ESP, EAX
    JMP     DWORD [ESP+EAX]            ; RETの代わり

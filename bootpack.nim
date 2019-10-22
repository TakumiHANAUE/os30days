
proc io_hlt(): void =
    asm """
        HLT
        RET
    """

proc HariMain(): void = 
    while true:
        io_hlt()

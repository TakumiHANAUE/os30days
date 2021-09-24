/* キーボード関係 */

#include "bootpack.h"

struct FIFO8 keyinfo;

/* PS/2キーボードからの割り込み */
void inthandler21(int *esp)
{
    unsigned char data;
    io_out8(PIC0_OCW2, 0x61); /* IRQ-01受付完了をPICに通知 */
    data = io_in8(PORT_KEYDAT);
    fifo8_put(&keyinfo, data);
    return;
}

#define PORT_KEYSTA 0x0064
#define KEYSTA_SEND_NOTREADY 0x02
#define KEYCMD_WRITE_MODE 0x60
#define KBC_MODE 0x47

/* キーボードコントローラがデータ送信可能になるのを待つ */
void wait_KBC_sendready(void)
{
    while (1)
    {
        if ( (io_in8(PORT_KEYSTA) & KEYSTA_SEND_NOTREADY) == 0 )
        {
            break;
        }
    }
    return;
}

/* キーボードコントローラの初期化 */
void init_keyboard(void)
{
    wait_KBC_sendready();
    io_out8(PORT_KEYCMD, KEYCMD_WRITE_MODE);
    wait_KBC_sendready();
    io_out8(PORT_KEYDAT, KBC_MODE);
    return;
}

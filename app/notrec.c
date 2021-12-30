#include "apilib.h"

void HariMain(void)
{
    int win;
    char buf[150 * 70];
    win = api_openwin(buf, 150, 70, 100, "notrec");
    api_boxfilwin(win, 0, 50, 34, 69, 100);
    api_boxfilwin(win, 115, 50, 149, 69, 100);
    api_boxfilwin(win, 50, 30, 99, 49, 100);
    while (1)
    {
        if (api_getkey(1) == 0x0a)
        {
            break; /* Enterならbreak; */
        }
    }
    api_end();
}
#include "golibc.h"
#include "apilib.h"

void HariMain(void)
{
    char *buf;
    int win, i, x, y;
    api_initmalloc();
    buf = api_malloc(150 * 100);
    win = api_openwin(buf, 150, 100, -1, "stars");
    api_boxfilwin(win, 6, 26, 143, 93, 0 /* 黒 */);
    for (i = 0; i < 50; i++)
    {
        x = (rand() % 137) + 6;
        y = (rand() % 67) + 26;
        api_point(win, x, y, 3 /* 黄 */);
    }
    while (1)
    {
        if (api_getkey(1) == 0x0a)
        {
            break; /* Enterならbreak; */
        }
    }
    api_end();
}

#!/bin/bash

SRCDIR="./golibc"

### strchr.c ###
# stdio.h がインクルードされていないなら追記する
INCLUDE_STDIO="#include <stdio.h>"
grep "${INCLUDE_STDIO}" ${SRCDIR}/strchr.c > /dev/null
RET=$?
if [ ${RET} -eq 1 ]; then
    sed -i "/#include <stddef.h>/a ${INCLUDE_STDIO}" ${SRCDIR}/strchr.c
fi

### stdarg.h ###
sed -i 's/__builtin_stdarg_start/__builtin_va_start/g' ${SRCDIR}/stdarg.h

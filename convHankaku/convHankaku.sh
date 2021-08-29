#/bin/bash

INPUTFILE="hankaku.txt"
OUTPUTFILE="../hankaku.c"

if ! [ -e ${INPUTFILE} ]; then
    echo "No input file : ${INPUTFILE}"
    exit -1
fi
if [ -e ${OUTPUTFILE} ]; then
    echo "Remove ${OUTPUTFILE}"
    rm ${OUTPUTFILE}
fi

# hankaku.txt を 0 or 1 のみの表現に変換する
{
    cat ${INPUTFILE} | \
    # 先頭文字が"."または"*"の行だけ抽出
    grep -e "^\." -e "^\*" | \
    # "."を"0"に、"*"を"1"に変換
    sed -e 's/\./0/g' -e 's/\*/1/g'
} > tmp.txt

# hankaku.c 作成
echo "char hankaku[4096] = {" >> ${OUTPUTFILE}

i=0
while read line
do
    i=$(expr ${i} + 1)
    # インデント
    if [ $((i % 16)) -eq 1 ]; then
        echo -n "    "
    fi
    # 2進数として読み込み(ibase=2)10進数に変換して(obase=10)変数に格納
    decval=`echo "obase=10; ibase=2; ${line}" | bc`
    # 16進数表記で出力
    printf '0x%02x, ' ${decval}
    # 16個毎に改行する
    if [ $((i % 16)) -eq 0 ]; then
        echo ""
    fi
done < tmp.txt >> ${OUTPUTFILE}

echo "};" >> ${OUTPUTFILE}

rm tmp.txt

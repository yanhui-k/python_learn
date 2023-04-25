随便写的一些小工具



## noteexpress2endnote.py

想法：因为我习惯用noteexpress看文献，就用它插入文献也方便一些，但是老师用的是endnotes，他想看我的参考文献就很困难，所以做了这个小程序
用法：先用noteexpress插入文献，使用含有doi号的格式，将参考文献部分的文字复制到一个txt文件中，去掉空行和“参考文献”，使用小程序，在程序中改输入输出文件的路径，执行，将输出文件导入到endnotes里，选择ris，utf-8，导入，最后查找全文，更新文献，就能得到完整的记录了。
我已用开题报告为例，执行了一下，总共有50篇期刊文章，只有11篇没有更新到数据，应该是没有doi号，并且是从谷歌学术上下载的。
问题：目前只能对英文期刊文章进行处理，并且有些不能找到直接完整信息，后面需要手动的从谷歌学术上下载，没有接口，使用比较难。



## download_srr.sh

功能：用于下载SRR文件，用fastq_dump转化为fastq格式，并根据用户的需要将fastq文件重命名
![](https://cdn.nlark.com/yuque/0/2022/jpeg/29486135/1668328628336-068f9478-5589-4407-8f44-bcdcec4bb956.jpeg#averageHue=%23fbfbf8&id=szFY5&originHeight=878&originWidth=1251&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=)

执行方法：

```
download_srr.sh -c CORE -i TXT
# 或提交到服务器
download_srr.sh -c CORE -i TXT --cluster CLUSTER -q QUEUE -m HOST
```

例子：

```
download_srr.sh -c 2 -i rename.txt
download_srr.sh -c 2 -i rename.txt --cluster bsub -q Q104C512G_X4 -m yi02
#等待完成后使用以下代码进行重命名
cat rename.txt | awk '{system ("rename "$1" "$2" *")}'

#输入文件rename.txt的例子
SRR15311776    B+Myc1
SRR15311775    B+Myc5
SRR15311774    B+Myc7
SRR15311773    B-Myc4
SRR15311772    B-Myc5
SRR15311771    B-Myc7
SRR15311779    NoMyc3
SRR15311778    NoMyc4
SRR15311777    NoMyc7
```

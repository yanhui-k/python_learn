# -*- coding = utf-8 -*-
# @Time : 2021/12/31 15:57
# @Author : 严慧
# @File : from noteexpress to endnote.py
# @Software : PyCharm

'''
我用note express给论文文本插入文献，但是老师用的是endnotes，
所以我需要提供一个endnotes的文库,用endnotes重新插入参考文献
我的想法是插入文献后，将参考文献复制成txt文件，通过处理后，导入endnotes，更新和查找全文后得到完整的文库信息
'''

import re

#读参考文献的txt文本
file_path = "C:/Users/xxdn/Desktop/1.txt"
with open(file_path,"r") as f:
    file = f.readlines()

result1 = []
i = 0
doi = ""
result_out = ""
for item in file:
    result_list = re.split(r"\. ", item)
    if result_list[1][0] != "[" and result_list[1][-2] == "J":
        result_out = result_out + "TY  - JOUR\nTI  - " + str(result_list[1]) + "\n"
        if result_list[-1][:3] == "DOI":
            result_out = result_out + "DO  - " + str(result_list[-1][4:]) + "ER  - \n" + "\n"
        else:
            result_out = result_out + "ER  - \n" + "\n"

# for item in result1:
#     result_out = result_out + "TY  - JOUR\nTI  - " + str(item) + "\nER  - \n" + "\n"

file_out = "C:/Users/xxdn/Desktop/text.txt"
with open(file_out, "w") as f:
    f.write(result_out)


# Ubuntu解压zip中文乱码


在Ubuntu操作系统下，如果使用unzip解压zip压缩包文件会出现中文乱码的问题。解决方法是使用unar使得其能够根据系统的编码自动转换。
&lt;!--more--&gt;

# unzip 出现中文乱码

```bash
unzip doc.zip                                                                         [14:45:55]
Archive:  doc.zip
   creating: doc/
  inflating: doc/CATS╧╡═│┐═╗з╢╦▓▀┬╘╗╪▓т║═╜╗╥╫╣ж─▄╩╣╙├╦╡├ў.pdf
  inflating: doc/CATS╧╡═│┐ь╜▌╜╗╥╫.doc
 extracting: doc/CSV╬─╝■╔и╡е.csv
  inflating: doc/CSV╬─╝■╔и╡е╜╗╥╫╩╣╙├╦╡├ў.docx
  inflating: doc/CSV╬─╝■╔и╡е╕ё╩╜╦╡├ў.xls
  inflating: doc/s000001_S0_╒╦╗з╜и▓╓╖╢└¤.csv
  inflating: doc/╗∙╙┌java╡─CATS╧╡═│┐═╗з╢╦▓▀┬╘┐Є╝▄╩╣╙├╦╡├ў.pdf
  inflating: doc/╗∙╙┌python╡─CATS╧╡═│┐═╗з▓▀┬╘┐Є╝▄╩╣╙├╦╡├ў.pdf
  inflating: doc/╢р╞╖╓╓╠╫└√╧┬╡е╣д╛▀.pdf
  inflating: doc/╢р▓▀┬╘╫щ║╧╖╢└¤.csv
 extracting: doc/╢р▓▀┬╘╫╘╢п╘╦╨╨.csv
  inflating: doc/╔и╡е╜╗╥╫╩╣╙├╦╡├ў.docx
  inflating: doc/╓╣╙п╓╣╦Ё▓╬╩¤╖╢└¤.csv
  inflating: doc/╓╣╙п╓╣╦Ё▓╬╩¤╦╡├ў.xls
  inflating: doc/╒╟═г░х╕·┬Є╓╕┴ю╖╢└¤.csv
  inflating: doc/▓▀┬╘═и╙├╓╕┴ю╖╢└¤.csv
  inflating: doc/▓▀┬╘═и╙├╕ё╩╜╦╡├ў.xls
  inflating: doc/╦у╖и╜╗╥╫╡╝╚ы╬─╝■┼·┴┐┤┤╜и╩╡└¤╩╣╙├╦╡├ў.docx
  inflating: doc/╦у╖и╓╕┴ю.csv
  inflating: doc/║ь╥╞╫щ║╧╧┬╡е╡╝╚ы╬─╝■╦╡├ў.xls
  inflating: doc/╫щ║╧╧┬╡е╖╢└¤.csv
  inflating: doc/═°╕ё╜╗╥╫╓╕┴ю╖╢└¤.csv
  inflating: doc/═°╕ё╜╗╥╫╬─╝■╕ё╩╜╦╡├ў.xls
  inflating: doc/╒╦╗з╜и▓╓╕ё╩╜╦╡├ў.xls
  inflating: doc/═и╙├╓╕┴ю.csv
  inflating: doc/═и╙├▓▀┬╘╡╝╚ы╬─╝■┼·┴┐┤┤╜и╩╡└¤╩╣╙├╦╡├ў.docx
```

# 使用 unar 解决乱码问题

```bash
sudo apt install unar
unar doc.zip -e GBK
                                                                             [14:46:02]
doc.zip: Zip
  doc/  (dir)... OK.
  doc/CATS系统客户端策略回测和交易功能使用说明.pdf  (3570468 B)... OK.
  doc/CATS系统快捷交易.doc  (401920 B)... OK.
  doc/CSV文件扫单.csv  (39 B)... OK.
  doc/CSV文件扫单交易使用说明.docx  (42152 B)... OK.
  doc/CSV文件扫单格式说明.xls  (32768 B)... OK.
  doc/s000001_S0_账户建仓范例.csv  (342 B)... OK.
  doc/基于java的CATS系统客户端策略框架使用说明.pdf  (3490925 B)... OK.
  doc/基于python的CATS系统客户策略框架使用说明.pdf  (3765833 B)... OK.
  doc/多品种套利下单工具.pdf  (1362558 B)... OK.
  doc/多策略组合范例.csv  (262 B)... OK.
  doc/多策略自动运行.csv  (50 B)... OK.
  doc/扫单交易使用说明.docx  (44154 B)... OK.
  doc/止盈止损参数范例.csv  (498 B)... OK.
  doc/止盈止损参数说明.xls  (27136 B)... OK.
  doc/涨停板跟买指令范例.csv  (182 B)... OK.
  doc/策略通用指令范例.csv  (778 B)... OK.
  doc/策略通用格式说明.xls  (33280 B)... OK.
  doc/算法交易导入文件批量创建实例使用说明.docx  (18837 B)... OK.
  doc/算法指令.csv  (238 B)... OK.
  doc/红移组合下单导入文件说明.xls  (32768 B)... OK.
  doc/组合下单范例.csv  (396 B)... OK.
  doc/网格交易指令范例.csv  (74 B)... OK.
  doc/网格交易文件格式说明.xls  (33792 B)... OK.
  doc/账户建仓格式说明.xls  (25600 B)... OK.
  doc/通用指令.csv  (236 B)... OK.
  doc/通用策略导入文件批量创建实例使用说明.docx  (31795 B)... OK.
Successfully extracted to &#34;./doc&#34;.
```

其中，命令`-e`指定源文件编码格式，其中目标编码格式会根据系统的`locale`自动获取。

```bash
alias unarzh=&#39;unar -e GBK&#39;
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-11-25-ubuntu%E8%A7%A3%E5%8E%8Bzip%E4%B8%AD%E6%96%87%E4%B9%B1%E7%A0%81/  


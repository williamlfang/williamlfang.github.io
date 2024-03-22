# Linux 解压 zip 中文乱码




```bash
windows中压缩的zip包，如果含有中文，在linux下解压时会出现乱码，刚才就出现了这个问题。
搜得一个帖子， 解决了乱码问题。
帖子来源： http://www.ubuntuchina.com/viewthread.php?tid=7356     蓝色部分问引用。

ubuntu linux 压缩文件zip中文乱码问题在windows上压缩的文件，是以系统默认编码中文来压缩文件。由于zip文件中没有声明其编码，所以linux上的unzip一般以默认编码解压，中文文件名会出现乱码。
虽然2005年就有人把这报告为bug, 但是info-zip的官方网站没有把自动识别编码列入计划，可能他们不认为这是个问题。Sun对java中存在N年的zip编码问题，采用了同样的处理方式。

有2种方式解决问题：

1. 通过unzip行命令解压，指定字符集
unzip -O CP936 xxx.zip (用GBK, GB18030也可以)
有趣的是unzip的manual中并无这个选项的说明, unzip --help对这个参数有一行简单的说明。

2. 在环境变量中，指定unzip参数，总是以指定的字符集显示和解压文件
/etc/environment中加入2行
UNZIP=&#34;-O CP936&#34;
ZIPINFO=&#34;-O CP936&#34;

这样Gnome桌面的归档文件管理器(file-roller)可以正常使用unzip解压中文，但是file-roller本身并不能设置编码传递给unzip。

采用了上面的第一个方法，问题解决。

另一方法为采用java的jar命令解压zip包
JAR 解压      jar xvf file.name
```





---

> 作者: william  
> URL: http://localhost:1313/archives/2021-08-11-linux-%E8%A7%A3%E5%8E%8B-zip-%E4%B8%AD%E6%96%87%E4%B9%B1%E7%A0%81/  


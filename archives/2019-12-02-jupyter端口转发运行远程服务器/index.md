# Jupyter端口转发运行远程服务器


# 登录服务器

打开终端执行命令

```bash
lhg@lhg-Ubuntu:~$ rss@my
Last login: Mon Dec  2 10:18:29 2019 from 192.168.10.111
[rss@rss ~]$ cd python_hg/
[rss@rss python_hg]$ ll
total 24K
drwxrwxr-x.  3 rss rss  4.0K Nov 29 20:33 .
drwx------. 46 rss 1000 4.0K Dec  2 10:04 ..
drwxrwxr-x.  2 rss rss  4.0K Nov 29 20:05 .ipynb_checkpoints
-rw-rw-r--.  1 rss rss  4.5K Nov 29 20:33 Untitled1.ipynb
-rw-rw-r--.  1 rss rss   555 Nov  4 10:56 Untitled.ipynb
[rss@rss python_hg]$ bash ~/activate_conda.sh
```
&lt;!--more--&gt;

启动服务器的 `Jupyter Notebook` 进程

```bash
cd ~/python_hg/
jupyter notebook --generate-config
[rss@rss python_hg]$ nohup jupyter notebook --no-browser &amp;
[rss@rss python_hg]$ jupyter-notebook password     ## 输入密码
[rss@rss python_hg]$ jupyter notebook list
```

# 本地端口转发

在本地机器上执行

```bash
## 如果已经占用端口，执行命令
sudo fuser -k 8890/tcp

## 启动后台服务
nohup ssh -N -L 8890:localhost:8890 rss@121.46.13.125 -p 49170&amp;
```

打开浏览器即可访问 [http://localhost:8890](http://localhost:8890)。


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-12-02-jupyter%E7%AB%AF%E5%8F%A3%E8%BD%AC%E5%8F%91%E8%BF%90%E8%A1%8C%E8%BF%9C%E7%A8%8B%E6%9C%8D%E5%8A%A1%E5%99%A8/  


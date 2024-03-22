# git bare 项目




&lt;!--more--&gt;

# 正确做法

## colo

```bash
cd ~
mkdir tbt2snap.recover
cd tbt2snap.recover
git init --bare ./tbt2snap.recover.git

## bare 仓库不保存具体内容，需要我们通过设置 post-receive 来同步远程仓库内容
## 通过这个控制从 master pull 到哪个目录
./tbt2snap.recover.git
cd hooks
touch post-receive
chmod &#43;x post-receive
vim post-receive

#/bin/bash
GIT_WORK_TREE=/home/ops/tbt2snap.recover git checkout -f master
```

```bash
tree -L 2
.
├── clear.sh
├── README.md
├── release.sh
├── tbt2snap.recover.git
│   ├── branches
│   ├── config
│   ├── description
│   ├── HEAD
│   ├── hooks
│   ├── index
│   ├── info
│   ├── logs
│   ├── objects
│   └── refs
└── template
    ├── colo.conf
    ├── hub.conf
    ├── hub.csv
    ├── run.hub.sh
    ├── run.t2s2.sh
    ├── run.term.sh
    ├── t2s2.conf
    └── terms.csv

8 directories, 15 files

```

## local

```bash
## git 作为下一层仓库，通过 post-receive 控制同步内容
git remote add colo116 ssh://ops@192.168.1.177:61116/home/ops/tbt2snap.recover/tbt2snap.recover.git

git push colo116
```



## remote

```bash
mkdir tools.git
cd tools.git
ls -alh
git init --bare

cd hooks
touch post-receive
chmod &#43;x post-receive
vim post-receive

#/bin/bash
GIT_WORK_TREE=./ git checkout -f master

#while read oldrev newrev ref
#do
#    branch=´echo $ref | cut -d/ -f3´
#    GIT_WORK_TREE=../ git checkout -f $branch
#done
```

## local

```bash
git clone git@192.168.1.171:lfang/tools.git

cd tools
vim readme.md
git add readme.md
git commit -m &#39;add readme&#39;

git remote add colo110 ssh://192.168.1.177:61110/home/ops/tmp/tools.git
git push ssh://ops@192.168.1.177:61110/home/ops/tmp/tools.git
```

## remote

这样，我们在 `remote` 机器即可看到变动

```bash
git log

commit 7bf73f38fad70da7116842ee73dc4f02cc44c932
Author: “williamlfang” &lt;“william.lian.fang@gmail.com”&gt;
Date:   Fri May 19 15:25:34 2023 &#43;0800

    add readme
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2023-05-19-git-bare-%E9%A1%B9%E7%9B%AE/  


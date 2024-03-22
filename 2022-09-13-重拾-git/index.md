# 重拾 git




&lt;!--more--&gt;

重新学习 git。

# 安装

```bash

```

# 配置:config

git 要求给出开发人员的基本信息：

1. 名字
2. 邮件

这是为了更好的最终文件修改人。这个配置可以是全局、或者单独针对某个项目。

## global

```bash
git config --global user.name &#34;william&#34;
git config --global user.email &#34;william.x.x@gmail.com&#34;
```

# 使用

## 新建空项目:init

```bash
mkdri testing
cd testing
git init
Initialized empty Git repository in /tmp/testing/.git/

ls -alh
```

## 添加文件:add

```bash
git add readme.md

git add install.sh
```

## 提交修改:commit

```bash
git commit -m &#34;init project and add readme&#34;

[master (root-commit) f78741f] init project and add readme
 2 files changed, 2 insertions(&#43;)
 create mode 100644 install.sh
 create mode 100644 readme.md
```

## 查看当前状态:status

```bash
echo &#34;hello, world&#34; &gt;&gt; readme.md
echo &#34;this is new line&#34; &gt;&gt; readme.md

git status

On branch master
Changes not staged for commit:
  (use &#34;git add &lt;file&gt;...&#34; to update what will be committed)
  (use &#34;git checkout -- &lt;file&gt;...&#34; to discard changes in working directory)

        modified:   readme.md

no changes added to commit (use &#34;git add&#34; and/or &#34;git commit -a&#34;)
```

## 查看不同:diff

```bash
git diff readme.md

diff --git a/readme.md b/readme.md
index 63173a9..cea5572 100644
--- a/readme.md
&#43;&#43;&#43; b/readme.md
@@ -1 &#43;1,3 @@
 # git testing
&#43;hello, world
&#43;this is new line
```

## 查看日志:log

git 处理的是每一次修改的快照(snapshot)，为每一次的修改生成一次 log 条目，用于查看该次修改的日志说明。

```bash
git log

commit 3a0003085047a83783a7fff67b3904ccd2154ff0 (HEAD -&gt; master)
Author: “williamlfang” &lt;“william.lian.fang@gmail.com”&gt;
Date:   Sun Jul 24 09:05:39 2022 &#43;0800

    modify readme

commit f78741f31fe3f5600a8c003aa456744668a09da2
Author: “williamlfang” &lt;“william.lian.fang@gmail.com”&gt;
Date:   Sun Jul 24 08:58:23 2022 &#43;0800

    init project and add readme
```

## 回滚:reset

`HEAD` 表示当前版本号，可以使用 `HEAD^` 返回上一个版本，或者 `HEAD~n` 返回之前n个版本

```bash
## 上一个版本，也可以用 HEAD~n，其中n表示之前多少个log
git reset --hard HEAD^

HEAD is now at f78741f init project and add readme

git log

commit f78741f31fe3f5600a8c003aa456744668a09da2 (HEAD -&gt; master)
Author: “williamlfang” &lt;“william.lian.fang@gmail.com”&gt;
Date:   Sun Jul 24 08:58:23 2022 &#43;0800

    init project and add readme
```

当然，如果我们想恢复之前的第二个修改，在上面的 `git log` 我们知道这个版本的修改 `commit id`

```bash
commit 3a0003085047a83783a7fff67b3904ccd2154ff0 (HEAD -&gt; master)
Author: “williamlfang” &lt;“william.lian.fang@gmail.com”&gt;
Date:   Sun Jul 24 09:05:39 2022 &#43;0800

    modify readme
```

所以我们还是可以在不同的 `commit id` 来回跳转的

```bash
## 一般写前面几位就可以了，不需要整个 id
#git reset --hard 3a0003085047a83783a7fff67b3904ccd2154ff0
git reset --hard 3a0003

commit 3a0003085047a83783a7fff67b3904ccd2154ff0 (HEAD -&gt; master)
Author: “williamlfang” &lt;“william.lian.fang@gmail.com”&gt;
Date:   Sun Jul 24 09:05:39 2022 &#43;0800

    modify readme

commit f78741f31fe3f5600a8c003aa456744668a09da2
Author: “williamlfang” &lt;“william.lian.fang@gmail.com”&gt;
Date:   Sun Jul 24 08:58:23 2022 &#43;0800

    init project and add readme
```

我们看到，当前的版本又重新回到的最近的修改了。Git 的版本回退速度非常快，因为 Git 在内部有个指向当前版本的HEAD指针，当你回退版本的时候，Git 仅仅是把 HEAD 从指向对应的 `commit id`。

## 重看log:reflog

像上面那样，如果我们 `reset` 了 `HEAD`，结果把屏幕清除了，导致我们记不起之前的 `commit id`。该怎么办呢？其实 git 提供了对每次修改的记录查新，可以很方便的看到每次操作的历史记录

```bash
git reflog

3a00030 (HEAD -&gt; master) HEAD@{0}: reset: moving to 3a0003
f78741f HEAD@{1}: reset: moving to HEAD^
3a00030 (HEAD -&gt; master) HEAD@{2}: commit: modify readme
f78741f HEAD@{3}: commit (initial): init project and add readme
```

从上面的记录我们看到，`reset: moving to HEAD^` 是我们把 `HEAD` 往前回滚了一次，到了 `f78741f` ，这时候 `3a00030` 就是后面一条最新的版本，所以还是可以回滚到这个版本的

```bash
git reset --hard 3a0003
```

## 撤销修改:checkout

有时候，我们对于修改的文件，想要丢弃，恢复到原先的状态。这时候可以使用 `checkout`

### 在工作区未提交

如果我们的修改只是在工作区，则可以直接丢弃修改即可

```bash
git status .
On branch master
nothing to commit, working tree clean

echo &#34;add extra line&#34; &gt;&gt; readme.md

git status .
On branch master
Changes not staged for commit:
  (use &#34;git add &lt;file&gt;...&#34; to update what will be committed)
  (use &#34;git checkout -- &lt;file&gt;...&#34; to discard changes in working directory)

        modified:   readme.md

no changes added to commit (use &#34;git add&#34; and/or &#34;git commit -a&#34;)
```

从上面我们看出来，当前工作区有一个 `modified` 没有提交到缓存区 `Changes not staged for commit`。如果我们想放弃本次修改，可以直接使用命令 `checkout`

```bash
git checkout readme.md

git status

On branch master
nothing to commit, working tree clean
```

可以看到，本次修改已经被丢弃，当前分支是干净的。

### 已经 add 到缓存区

如果修改已经提交到了缓存区，我们可以用 `reset HEAD filename` 将缓存区(stage)退回到与当前分支一样的状态(`HEAD`)，然后在用 `checkout` 丢弃修改

```bash
echo &#34;add extra line&#34; &gt;&gt; readme.md

git add readme.md

git status .
On branch master
Changes to be committed:
  (use &#34;git reset HEAD &lt;file&gt;...&#34; to unstage)

        modified:   readme.md
```

看到上面的已经被 `add` 到了缓存区。那么，我们可以用 `reset HEAD &lt;file&gt;` 命令将其从缓存区放弃

```bash
## 先将其从缓存区放弃
git reset HEAD readme.md

## 然后在从工作区放弃
git checkout readme.md

## 现在查看状态已经是干净的了

git status
On branch master
nothing to commit, working tree clean
```

### 已经 commit 到分支

对于已经提交到分支的修改，我们可以用 `reset commit_id` 退回到上一个版本（这个 `commit_id` 指的是上一个版本号）。

```bash
echo &#34;add extra line3&#34; &gt;&gt; readme.md

git add readme.md
git commit -m &#34;add extra line3 into readme&#34;

git log
commit 18529d695e8e4ce797f7878135369a11ef658549 (HEAD -&gt; master)
Author: “williamlfang” &lt;“william.lian.fang@gmail.com”&gt;
Date:   Sun Jul 24 11:07:35 2022 &#43;0800

    add extra line3 in readme

commit 9205b630a3efd2b5c2ddd7ea732a53e5f0a3bd6e
Author: “williamlfang” &lt;“william.lian.fang@gmail.com”&gt;
Date:   Sun Jul 24 10:54:59 2022 &#43;0800

    add extra line in readme

commit 3a0003085047a83783a7fff67b3904ccd2154ff0
Author: “williamlfang” &lt;“william.lian.fang@gmail.com”&gt;
Date:   Sun Jul 24 09:05:39 2022 &#43;0800

    modify readme

commit f78741f31fe3f5600a8c003aa456744668a09da2
Author: “williamlfang” &lt;“william.lian.fang@gmail.com”&gt;
Date:   Sun Jul 24 08:58:23 2022 &#43;0800

    init project and add readme
```

我们发现本次修改已经在当前分支了，log 已经能查询本次修改。那么，我们可以退回上一次的修改，`commit_id` 对应是 `9205b630a3efd2b5c2ddd7ea732a53e5f0a3bd6e`

```bash
git reset --hard 9205b630a3efd2b5c2ddd7ea732a53e5f0a3bd6e

git log

commit 9205b630a3efd2b5c2ddd7ea732a53e5f0a3bd6e (HEAD -&gt; master)
Author: “williamlfang” &lt;“william.lian.fang@gmail.com”&gt;
Date:   Sun Jul 24 10:54:59 2022 &#43;0800

    add extra line in readme

commit 3a0003085047a83783a7fff67b3904ccd2154ff0
Author: “williamlfang” &lt;“william.lian.fang@gmail.com”&gt;
Date:   Sun Jul 24 09:05:39 2022 &#43;0800

    modify readme

commit f78741f31fe3f5600a8c003aa456744668a09da2
Author: “williamlfang” &lt;“william.lian.fang@gmail.com”&gt;
Date:   Sun Jul 24 08:58:23 2022 &#43;0800

    init project and add readme
```

现在已经没有 `line3` 的修改记录了。

&gt; 如果没有添加 –hard 这表示本次修改依然保留在工作区


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-09-13-%E9%87%8D%E6%8B%BE-git/  


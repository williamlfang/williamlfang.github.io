# pre commit: 自动美化代码




# Python

参考链接:

- [pre-commit: A framework for managing and maintaining multi-language pre-commit hooks.](https://github.com/pre-commit/pre-commit)

- [Automate Python workflow using pre-commits: black and flake8](https://ljvmiranda921.github.io/notebook/2018/06/21/precommits-using-black-and-flake8/)

```bash
## 安装
python -m pip install pre-commit
## 也可以直接下载安装
## curl https://pre-commit.com/install-local.py | python -

## 查看版本
pre-commit -V
pre-commit 2.6.0

## 在项目中生成配置文件
## 使用命令查看模板
# pre-commit sample-config

## 在 git 项目中安装
pre-commit install

## 配置文件
vim .pre-commit-config.yaml
```

&lt;!--more--&gt;

可以参考一下这个配置文件

```yaml
repos:
-   repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v2.3.0
    hooks:
    -   id: check-yaml
    -   id: end-of-file-fixer
    -   id: trailing-whitespace
-   repo: https://github.com/psf/black
    rev: 19.3b0
    hooks:
    -   id: black
-   repo: https://github.com/Lucas-C/pre-commit-hooks-bandit
    rev: v1.0.4
    hooks:
    -   id: python-bandit-vulnerability-check
        args: [-l, --recursive, -x, tests]
        files: .py$
-   repo: https://github.com/asottile/reorder_python_imports
    rev: v1.6.1
    hooks:
    -   id: reorder-python-imports
```

这样，我们在每次提交 `git commit` 之前，都会先经过一遍代码风格的检查

```bash
git add data/csv_reader.py
git commit -m &#34;test CsvTickData with ticks.dat&#34;

[WARNING] Unstaged files detected.
[INFO] Stashing unstaged files to /home/william/.cache/pre-commit/patch1597726472.
Check Yaml...........................................(no files to check)Skipped
Fix End of Files.........................................................Passed
Trim Trailing Whitespace.................................................Passed
black....................................................................Passed
bandit...................................................................Passed
Reorder python imports...................................................Passed
[INFO] Restored changes from /home/william/.cache/pre-commit/patch1597726472.
[ctpmd c7e7f4f] test CsvTickData with ticks.dat
 1 file changed, 39 insertions(&#43;), 23 deletions(-)
```

# C/C&#43;&#43;


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-08-18-pre-commit--%E8%87%AA%E5%8A%A8%E7%BE%8E%E5%8C%96%E4%BB%A3%E7%A0%81/  


# vim9 安装 YCM


vim9 配置 YCM 自动补全功能。

&lt;!--more--&gt;

```
cd ~/.vim/plugged
git clone https://github.com/ycm-core/YouCompleteMe.git
git submodule update --init --recursive

## 添加 ssl
vim ~/.vim/plugged/YouCompleteMe/third_party/ycmd/build.py
import ssl
ssl._create_default_https_context = ssl._create_unverified_context

python3 ./install.py --clang-completer --force-sudo  --verbose

## vim .vimrc
&#34; ycm 指定 ycm_extra_conf.py
let g:ycm_global_ycm_extra_conf =  ‘xxxxxx/.ycm_extra_conf.py’
后面的路径是 YCM 插件目录里的 .ycm_extra_conf.py 文件的位置
比如 &#39;~/.vim/plugged/YouCompleteMe/third_party/ycmd/.ycm_extra_conf.py&#39;
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-01-13-vim9-%E5%AE%89%E8%A3%85-ycm/  


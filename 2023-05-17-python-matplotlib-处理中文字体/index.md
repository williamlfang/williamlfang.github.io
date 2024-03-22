# python matplotlib 处理中文字体


处理 `matplotlib` 中文字体无法显示的问题

&lt;!--more--&gt;

## 下载需要的字体

```bash
## 先下载字体
git clone https://github.com/dolbydu/font.git

## 支持中文字体的在 unicode
cd unicode

tree -L 1
.
├── Adobe Fangsong Std.otf
├── Adobe Heiti Std.otf
├── Adobe Kaiti Std.otf
├── Adobe Song Std.otf
├── FangSong.ttf
├── FZYingBiXingShu-S16S.ttf
├── FZYingBiXingShu-S16T.ttf
├── Kaiti.ttf
├── Lisu.TTF
├── Microsoft Yahei Bold.ttf
├── Microsoft Yahei.ttf
├── SimHei.ttf
├── SimSun.ttc
├── STCaiyun.TTF
├── STFangsong.TTF
├── STHupo.TTF
├── STKaiti.TTF
├── STLiti.TTF
├── STSong.TTF
├── STXihei.TTF
├── STXingkai.TTF
├── STXinwei.TTF
├── STZhongsong.TTF
└── YouYuan.TTF

```

## 拷贝到 matplotlib 文件夹

```python
## 查看 matplotlib 路径
import matplotlib
matplotlib.matplotlib_fname()

&#39;/usr/local/python3/lib/python3.11/site-packages/matplotlib/mpl-data/matplotlibrc&#39;

## 字体文件位于上一层
cd /usr/local/python3/lib/python3.11/site-packages/matplotlib/mpl-data/fonts/ttf
```

现在，我们把刚才下载得到的字体拷贝在这个文件夹

```bash
cp ~/git/font/unicode/* /usr/local/python3/lib/python3.11/site-packages/matplotlib/mpl-data/fonts/ttf
```

然后，还需要更新 `matplotlib` 的字体缓存文件夹，否则还是无法更新字体

```python
import matplotlib
print(matplotlib.get_cachedir())

&#39;/root/.cache/matplotlib&#39;

## 删除字体缓存
rm -rf /root/.cache/matplotlib
```

这时候，重新启动 `python` 即可

```python
matplotlib.matplotlib_fname()
from matplotlib import font_manager
font_set = {f.name for f in font_manager.fontManager.ttflist}
for f in font_set:
    print(f)
```

现在，我们可以指定字体了

```python
plt.rcParams[&#34;font.sans-serif&#34;]=[&#34;Microsoft YaHei&#34;] #设置字体
plt.rcParams[&#34;axes.unicode_minus&#34;]=False #该语句解决图像中的“-”负号的乱码问题
```







---

> 作者: william  
> URL: https://williamlfang.github.io/2023-05-17-python-matplotlib-%E5%A4%84%E7%90%86%E4%B8%AD%E6%96%87%E5%AD%97%E4%BD%93/  


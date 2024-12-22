# Ubuntu 升级 ffmpeg


今天使用 `yt-dlp` 下载视频时，遇到一个报错

```bash
[youtube] Extracting URL: https://youtu.be/_dLLIjKz9MY
[youtube] _dLLIjKz9MY: Downloading webpage
...........................................
[Merger] Merging formats into &#34;Fear in Tech - Titus Winters - Keynote Meeting C&#43;&#43; 2024 [_dLLIjKz9MY].mp4&#34;
ERROR: Postprocessing:   Stream #1:0 -&gt; #0:1 (copy)
```

查找一遍，发现这个是因为 `yt-dlp` 与 `ffmpeg` 版本冲突导致的，导致`yt-dlp --merge-output-format mp4` 无法合成 `mp4` 格式。因此需要升级 `ffmpeg`。


&lt;!--more--&gt;

## 升级 yasm

```bash
## update yasm
wget https://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
tar -xvf yasm-1.3.0.tar.gz
cd yasm-1.3.0
./configure
make -j
make install
```

## 升级 ffmpeg

```bash
wget https://ffmpeg.org/releases/ffmpeg-7.0.1.tar.xz
tar -xvf ffmpeg-7.0.1.tar.xz
cd ffmpeg-7.0.1

./configure
make install
./ffmpeg --version

whereis ffmpeg
ll /usr/bin/ffmpeg

cp ffmpeg* ffprobe /usr/bin/
ffmpeg --version
```

## 成功下载

```bash
[youtube] Extracting URL: https://www.youtube.com/watch?v=nXcswVW0-Wk
[youtube] nXcswVW0-Wk: Downloading webpage
[youtube] nXcswVW0-Wk: Downloading ios player API JSON
[youtube] nXcswVW0-Wk: Downloading mweb player API JSON
[youtube] nXcswVW0-Wk: Downloading m3u8 information
[info] nXcswVW0-Wk: Downloading 1 format(s): 616&#43;251
[hlsnative] Downloading m3u8 manifest
[hlsnative] Total fragments: 655
[download] Destination: Herb Sutter - Peering forward  C&#43;&#43;’s next decade [nXcswVW0-Wk].f616.mp4
[download] 100% of  441.60MiB in 00:04:40 at 1.57MiB/s
[download] Destination: Herb Sutter - Peering forward  C&#43;&#43;’s next decade [nXcswVW0-Wk].f251.webm
[download] 100% of   53.14MiB in 00:00:05 at 10.23MiB/s
[Merger] Merging formats into &#34;Herb Sutter - Peering forward  C&#43;&#43;’s next decade [nXcswVW0-Wk].mp4&#34;
Deleting original file Herb Sutter - Peering forward  C&#43;&#43;’s next decade [nXcswVW0-Wk].f616.mp4 (pass -k to keep)
Deleting original file Herb Sutter - Peering forward  C&#43;&#43;’s next decade [nXcswVW0-Wk].f251.webm (pass -k to keep)
[Metadata] Adding metadata to &#34;Herb Sutter - Peering forward  C&#43;&#43;’s next decade [nXcswVW0-Wk].mp4&#34;

[1]  &#43; done       yt-dlp -f &#39;bv[height&lt;=1080]&#43;ba/b[height&lt;=1080]&#39; --embed-metadata  mp4 --proxy
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-12-22-ubuntu-%E5%8D%87%E7%BA%A7-ffmpeg/  


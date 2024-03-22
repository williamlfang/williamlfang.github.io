# autoclear 自动清理过期文件


自动清理超过一定时间的文件

&lt;!--more--&gt;

```bash
#!/usr/bin/env bash
mkdir -p $HOME/log
LOG_FILE=$HOME/log/$(date &#43;&#34;%Y%m%d.MyLog.log&#34;)
exec &amp;&gt; &gt;(tee -a &#34;$LOG_FILE&#34;)

is_init=false
msg () {
    echo -e &#34;------------------------------------------------------------------&#34;
    if [ !is_init ]; then
        is_init=true
        echo -e &#34;&gt;&gt; $(date &#43;&#39;%Y-%m-%d %H:%M:%S&#39;) &lt;&lt; &#39;$0&#39;&#34;
    fi

    echo -e &#34;&gt;&gt; $(date &#43;&#39;%Y-%m-%d %H:%M:%S&#39;) &lt;&lt; &#39;$1&#39;&#34;
    echo -e  &#34;-----------------------------------------------------------------&#34;
}

msg &#34;Run autoclear.sh&#34;

#datadir=$HOME/data
datadir=/data
xday=$(date -d &#34;-30 days&#34; &#43;&#34;%Y%m%d&#34;)

for f in `ls $datadir`;
do
    tmpdate=`date -r $datadir/$f &#34;&#43;%Y%m%d&#34;`

    if [[ $tmpdate &lt; $xday ]];
    then
        echo &#34;##==&gt; now rm $f ==&gt; [[ $tmpdate &lt; $xday ]]&#34;

        if [[ $f == *&#34;tar.bz2&#34;* ]];
        then
            rsync -avPzr $datadir/$f ops:/data/Xtp/FromZZ.SZ
        fi

        rm -rf $datadir/$f
    fi

done

msg &#34;Done!&#34;
```





---

> 作者: william  
> URL: https://williamlfang.github.io/2023-02-21-autoclear-%E8%87%AA%E5%8A%A8%E6%B8%85%E7%90%86%E8%BF%87%E6%9C%9F%E6%96%87%E4%BB%B6/  


# sqlite 源代码编译




&lt;!--more--&gt;

```bash
# 版本列表：https://www.sqlite.org/chronology.html
# 下载源码
wget --no-check-certificate https://www.sqlite.org/src/tarball/sqlite-3.39.3.tar.gz

# 编译
tar zxvf sqlite-3.39.3.tar.gz
cd sqlite-3.39.3

export CFLAGS=&#34;-DSQLITE_ENABLE_FTS3 \
    -DSQLITE_ENABLE_FTS3_PARENTHESIS \
    -DSQLITE_ENABLE_FTS4 \
    -DSQLITE_ENABLE_FTS5 \
    -DSQLITE_ENABLE_JSON1 \
    -DSQLITE_ENABLE_LOAD_EXTENSION \
    -DSQLITE_ENABLE_RTREE \
    -DSQLITE_ENABLE_STAT4 \
    -DSQLITE_ENABLE_UPDATE_DELETE_LIMIT \
    -DSQLITE_SOUNDEX \
    -DSQLITE_TEMP_STORE=3 \
    -DSQLITE_USE_URI \
    -O2 \
    -fPIC&#34;
export PREFIX=&#34;/usr/local&#34;
#LIBS=&#34;-lm&#34; ./configure --disable-tcl --enable-shared --enable-tempstore=always --prefix=&#34;$PREFIX&#34;
LIBS=&#34;-lm&#34; ./configure --enable-shared --enable-tempstore=always --prefix=&#34;$PREFIX&#34;

make &amp;&amp; make install

# 替换系统低版本 sqlite3
mv /usr/bin/sqlite3  /usr/bin/sqlite3_old
ln -s /usr/local/bin/sqlite3   /usr/bin/sqlite3
echo &#34;/usr/local/lib&#34; &gt; /etc/ld.so.conf.d/sqlite3.conf
ldconfig
sqlite3 -version
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2023-04-25-sqlite-%E6%BA%90%E4%BB%A3%E7%A0%81%E7%BC%96%E8%AF%91/  


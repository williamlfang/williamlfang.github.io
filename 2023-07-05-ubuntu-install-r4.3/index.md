# ubuntu install R4.3


由于换了一台戴尔 xps 工作机，需要重新安装 `R`。在此顺便记录一下过程。

&lt;!--more--&gt;

## apt-get

```bash
sudo apt-get install \
    gfortran \
    libcurl4-gnutls-dev \
    libreadline-dev \
    libbz2-dev \
    liblzma-dev \
    libpcre&#43;&#43;-dev \
    libpango1.0-dev

sudo apt-get install \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libmariadbclient-dev
```

## textlive

```bash
sudo apt-get install texlive
sudo apt-get install texlive-fonts-extra

wget http://mirrors.ctan.org/fonts/inconsolata.zip
unzip inconsolata.zip
cp -Rfp inconsolata/* /usr/share/texmf
mktexlsr
```

## install

```bash
export R_VERSION=R-4.3.1
cd /tmp &amp;&amp; \
    wget --no-check-certificate https://cran.r-project.org/src/base/R-4/${R_VERSION}.tar.gz &amp;&amp; \
    tar -xvf ${R_VERSION}.tar.gz &amp;&amp; \
    cd ${R_VERSION} &amp;&amp; \
    ./configure \
        --prefix=/usr/local/R-4/${R_VERSION} \
        --enable-memory-profiling \
        --enable-R-shlib \
        --with-blas \
        --with-lapack \
        --with-x=no &amp;&amp; \
    make &amp;&amp; sudo make install &amp;&amp; \
    ln -sfn /usr/local/R-4/${R_VERSION}/bin/R /usr/bin/R &amp;&amp; \
    ln -sfn /usr/local/R-4/${R_VERSION}/bin/Rscript /usr/bin/Rscript &amp;&amp; \
    rm -rf /tmp/${R_VERSION}*
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-07-05-ubuntu-install-r4.3/  


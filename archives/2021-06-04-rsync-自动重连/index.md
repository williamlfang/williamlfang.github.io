# rsync 自动重连


```bash
while true
do
    sleep 1
    #rsync --progress -avPz -r -e &#34;ssh -p60001&#34; tbt.colo101.$(date &#43;&#34;%Y%m&#34;)*.tar.bz2 ops@58.33.72.179:/data/Xtp/FromZZ.SH
    exitCode=$?

    ## -------------------------------------------------------------------------
    case $exitCode in
    10 | 23 | 30 | 35)
      echo &#34;$(date): rsync finished with a network related error: $exitCode&#34;
      ;;
    0)
      echo &#34;$(date): rsync finished without error&#34;
      break  # leave the while loop
      ;;
    *)  # all other cases
      echo &#34;$(date): rsync finished with an unexpected error: $exitCode&#34;
      ## break  # we don&#39;t know whether repeating it makes sense
      ;;
    esac
    ## -------------------------------------------------------------------------

done
```

&lt;!--more--&gt;


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-06-04-rsync-%E8%87%AA%E5%8A%A8%E9%87%8D%E8%BF%9E/  


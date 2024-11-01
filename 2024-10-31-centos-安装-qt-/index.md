# CentOS 安装 Qt 


```bash
yum -y groupinstall &#34;GNOME Desktop&#34;
yum -y groupinstall &#34;Development Tools&#34;
yum install -y libGL libGL-devel
yum install -y mesa-libGL-devel mesa-libGLU-devel freeglut-devel
yum install -y libxcb libxcb-devel libXrender libXrender-devel xcb-util-wm xcb-util-wm-devel xcb-util xcb-util-devel xcb-util-image xcb-util-image-devel xcb-util-keysyms xcb-util-keysyms-devel
```


&lt;!--more--&gt;



---

> 作者: william  
> URL: https://williamlfang.github.io/2024-10-31-centos-%E5%AE%89%E8%A3%85-qt-/  


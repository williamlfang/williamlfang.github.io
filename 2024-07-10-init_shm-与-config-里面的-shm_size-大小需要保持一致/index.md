# init_shm 与 config 里面的 shm_size 大小需要保持一致



今天遇到一个奇怪的现象：由于我们使用的 `init_shm` 清空共享内存数据，这个需要指定大小。由于初始化脚本事先不知道实际配置文件使用的 `shm_size`，导致两者的大小是不一样的。如此一来，`init_shm` 先是让操作系统分配了一个物理内存，然后使用的程序以配置文件的 `shm_size` 进行使用，导致内存越界了。

&lt;!--more--&gt;



---

> 作者: william  
> URL: https://williamlfang.github.io/2024-07-10-init_shm-%E4%B8%8E-config-%E9%87%8C%E9%9D%A2%E7%9A%84-shm_size-%E5%A4%A7%E5%B0%8F%E9%9C%80%E8%A6%81%E4%BF%9D%E6%8C%81%E4%B8%80%E8%87%B4/  


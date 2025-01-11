# glibc shm_open 一个坑



周末的时候，我们组对一台 `CentOS7` 的机器进行了升级，原因是需要部分软件要求至少是 `glibc2.18` 及以上版本。整个升级流程还算顺利，程序也都能正常运行

```bash
$ locate libc.so
/usr/lib64/libc.so
/usr/lib64/libc.so.6

$ strings /lib64/libc.so.6  |grep GLIBC    |grep 2.28
GLIBC_2.28
```

但是周一交易盘前，我们发现一个奇怪的现象：`shm` 相关的操作，对于 `/dev/shm` 根目录下面的共享内存操作是正常的，但是对于带有子目录，如 `/dev/shm/spdm/spdx_param`，会出现程序崩溃。然后我把这个现象跟领导沟通了一下，由他编译一个 `debug` 版本，进入 `gdb` 调试看看。

他确实发现，一旦遇到带有目录路径的 `shm_open` 就会出问题，返回的 `fd` 是 `-1`，这说明操作系统无法打开文件句柄。他经过一番 `ChatGPT` 之后，给出的结论是

{{&lt; center-quote &gt;}}
今天发现了一个情况，在某一台服务器上不能通过shmv命令来访问或者创建带字目录的共享内存文件，比如/dev/shm/abc/xyz，根源上是shm_open不接受&#34;abc/xyz&#34;作为参数，查了相关文档，发现这台机器虽然centos 版本不一样，但是对比发现比这个版本更老或者更新的其他版本是支持abc/xyz这样的共享内存文件名的，现在怀疑是glibc版本导致的，因为这台机器的glic版本相对高一些（2.28)，我们其他服务器绝大多数都是2.17，目前没有定位具体glic哪个版本什么样的改动导致了这个，但是POSIX规范确实要求传给shm_open的文件名除了第一个字符以为不能为/
{{&lt; /center-quote &gt;}}

当时全组震惊，这意味着我们的技术将被「锁死」在 `glibc2.18`，无法再继续升级；这也意味着后面有新的程序需要依赖 `glibc` 更高本版（比如 `npm`、`neovim`）将无法使用。

&lt;!--more--&gt;

# 探索 glibc 的改动

想到后面全公司的技术都将被「锁死」，这岂能容忍。于是我便想到查看 `glibc` 的源代码，看看是否有什么变动导致了无法 `shm_open` 一个子目录的文件句柄。这个算是体力活，到源代码搜索 `shm_open` 相关的代码即可。代码位于 `glibc-2.21/sysdeps/posix/shm_open.c`

通过对比，发现 `glibc.2.20` 与 `glibc.2.21` 在处理 `shm_open` 的时候，发生了一些变化

![glibc 源代码对比](./glibc.2.21.changed.png &#34;glibc 源代码对比&#34;)

## glibc.2.20

```c&#43;&#43;
#include &lt;unistd.h&gt;

#if ! _POSIX_MAPPED_FILES
#include &lt;rt/shm_open.c&gt;

#else

#include &lt;errno.h&gt;
#include &lt;sys/mman.h&gt;
#include &lt;fcntl.h&gt;
#include &lt;string.h&gt;
#include &lt;stdlib.h&gt;
#include &lt;paths.h&gt;

#define SHMDIR  (_PATH_DEV &#34;shm/&#34;)

/* Open shared memory object.  */
int
shm_open (const char *name, int oflag, mode_t mode)
{
  size_t namelen;
  char *fname;
  int fd;

  /* Construct the filename.  */
  while (name[0] == &#39;/&#39;)
    &#43;&#43;name;

  if (name[0] == &#39;\0&#39;)
    {
      /* The name &#34;/&#34; is not supported.  */
      __set_errno (EINVAL);
      return -1;
    }

  namelen = strlen (name);
  fname = (char *) __alloca (sizeof SHMDIR - 1 &#43; namelen &#43; 1);
  __mempcpy (__mempcpy (fname, SHMDIR, sizeof SHMDIR - 1),
         name, namelen &#43; 1);

  fd = open (name, oflag, mode);
  if (fd != -1)
    {
      /* We got a descriptor.  Now set the FD_CLOEXEC bit.  */
      int flags = fcntl (fd, F_GETFD, 0);

      if (__builtin_expect (flags, 0) != -1)
    {
      flags |= FD_CLOEXEC;
      flags = fcntl (fd, F_SETFD, flags);
    }

      if (flags == -1)
    {
      /* Something went wrong.  We cannot return the descriptor.  */
      int save_errno = errno;
      close (fd);
      fd = -1;
      __set_errno (save_errno);
    }
    }

  return fd;
}

#endif
```

## glibc.2.21

```c&#43;&#43;
#include &lt;unistd.h&gt;

#if ! _POSIX_MAPPED_FILES

# include &lt;rt/shm_open.c&gt;

#else

# include &lt;fcntl.h&gt;
# include &lt;shm-directory.h&gt;


/* Open shared memory object.  */
int
shm_open (const char *name, int oflag, mode_t mode)
{
  SHM_GET_NAME (EINVAL, -1, &#34;&#34;);

# ifdef O_NOFOLLOW
  oflag |= O_NOFOLLOW;
# endif
# ifdef O_CLOEXEC
  oflag |= O_CLOEXEC;
# endif
  int fd = open (shm_name, oflag, mode);
  if (fd == -1 &amp;&amp; __glibc_unlikely (errno == EISDIR))
    /* It might be better to fold this error with EINVAL since
       directory names are just another example for unsuitable shared
       object names and the standard does not mention EISDIR.  */
    __set_errno (EINVAL);

# ifndef O_CLOEXEC
  if (fd != -1)
    {
      /* We got a descriptor.  Now set the FD_CLOEXEC bit.  */
      int flags = fcntl (fd, F_GETFD, 0);

      if (__glibc_likely (flags != -1))
    {
      flags |= FD_CLOEXEC;
      flags = fcntl (fd, F_SETFD, flags);
    }

      if (flags == -1)
    {
      /* Something went wrong.  We cannot return the descriptor.  */
      int save_errno = errno;
      close (fd);
      fd = -1;
      __set_errno (save_errno);
    }
    }
# endif

  return fd;
}

#endif  /* _POSIX_MAPPED_FILES */
```

# shm-directory

从 `glibc.2.21` 开始，`gnu` 使用了一个宏语句 `SHM_GET_NAME`，我们继续进入这个宏看看究竟在做什么事情

```c&#43;&#43;
#define SHM_GET_NAME(errno_for_invalid, retval_for_invalid, prefix)           \
  size_t shm_dirlen;                                  \
  const char *shm_dir = __shm_directory (&amp;shm_dirlen);                \
  /* If we don&#39;t know what directory to use, there is nothing we can do.  */  \
  if (__glibc_unlikely (shm_dir == NULL))                     \
    {                                         \
      __set_errno (ENOSYS);                           \
      return retval_for_invalid;                          \
    }                                         \
  /* Construct the filename.  */                          \
  while (name[0] == &#39;/&#39;)                              \
    &#43;&#43;name;                                   \
  size_t namelen = strlen (name) &#43; 1;                         \
  /* Validate the filename.  */                           \
  if (namelen == 1 || namelen &gt;= NAME_MAX || strchr (name, &#39;/&#39;) != NULL)      \
    {                                         \
      __set_errno (errno_for_invalid);                        \
      return retval_for_invalid;                          \
    }                                         \
  char *shm_name = __alloca (shm_dirlen &#43; sizeof prefix - 1 &#43; namelen);       \
  __mempcpy (__mempcpy (__mempcpy (shm_name, shm_dir, shm_dirlen),        \
                        prefix, sizeof prefix - 1),               \
             name, namelen)
```

这里主要做的时候是

- 根据我们传递给 `shm_open` 的 `name`，将其组合成 `/dev/shm` 的路径，然后使用 `open` 打开。我们也可以发现，在 `linux` 的哲学：「一切皆文件」

- 对 `shm_name` 进行判断，这里面有
    1. 名字不能非看，且长度不能超过 `NAME_MAX`，这个定义在 `limits.h`，是 `255`o
    2. 使用函数 `strchr` 判断传递的名字是否有 `/`，即是否是一个**带有目录路径的文件名**

- 这里就是问题所在了，如果 `SHM_GET_NAME` 发现我们传递的名称是 `spdm/spdx_param`，就返回 `retval_for_invalid`，即 `-1`，这代表我们得到的 `fd` 是非正常，因此 `shm` 才会出现 `coredump` 的报错。

```c&#43;&#43;
/* Validate the filename.  */                             \
if (namelen == 1 || namelen &gt;= NAME_MAX || strchr (name, &#39;/&#39;) != NULL)      \
  {                                       \
    __set_errno (errno_for_invalid);                          \
    return retval_for_invalid;                        \
  }                                       \
```

于是，我们的想法是把这个判断去掉，允许系统打开 `/dev/shm/spdm/spdx_param`。然后重新编译 `glibc` 即可。

```c&#43;&#43;
/* Validate the filename.  */                             \
// 去掉对 包含路径的文件名的限制
if (namelen == 1 || namelen &gt;= NAME_MAX )      \
  {                                       \
    __set_errno (errno_for_invalid);                          \
    return retval_for_invalid;                        \
  }                                       \
```

如此一来，问题即得到解决了。

# Tips

- `glibc 2.17~2.28` 是可以兼容的，在 `CentOS7` 上可以升级兼容，但是更高版本的 `glibc` 可能会导致系统不兼容，一定要谨慎操作

# ref

- gnu glibc.2.28: https://ftp.gnu.org/gnu/glibc/glibc-2.28.tar.gz
- glibc.2.20: https://elixir.bootlin.com/glibc/glibc-2.20.90/source/sysdeps/posix/shm_open.c
- glibc.2.21: https://elixir.bootlin.com/glibc/glibc-2.21.90/source/sysdeps/posix/shm_open.c
- [GLIBC_2.18 configure 不支持make 4.xx](https://zhuanlan.zhihu.com/p/397911151)


---

> 作者: william  
> URL: https://williamlfang.github.io/2025-01-06-glibc-shm_open-%E4%B8%80%E4%B8%AA%E5%9D%91/  


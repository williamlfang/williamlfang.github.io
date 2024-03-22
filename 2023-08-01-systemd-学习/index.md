# systemd 学习


`Linux systemd` 学习总结

`simple` vs `oneshot`:

When you are deciding which service type to choose between simple and oneshot, here is some guidance:

- Does your service need to complete before any follow-up services run? Use oneshot.
- Do your follow-up services need to be running while this service does? Use simple.
- Is this a long-running service? Probably use simple.
- Do you need to run this service only at shutdown? Use oneshot.
- Do you need to have multiple separate commands to run? Use oneshot.

&lt;!--more--&gt;

# Ref

- [Simple vs Oneshot - Choosing a systemd Service Type](https://trstringer.com/simple-vs-oneshot-systemd-service/)


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-08-01-systemd-%E5%AD%A6%E4%B9%A0/  


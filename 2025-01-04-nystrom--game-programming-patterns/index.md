# Nystrom: Game Programming Patterns


Reading notes from **Robert Nystrom**&#39;s *Game Programming Patterns*.

&lt;!--more--&gt;

# Chap.1 Architecture, Performance, and Games

We have a few forces in play:

1. We want nice architecture so the code is easier to understand and over the lifetime of the project.
2. We want fast runtime Performance
3. We want to get today&#39;s features done quickly.

Summary:
1. Abstraction and decoupling make evolving your program faster and easier, but don&#39;t waster time doing them unless you&#39;re confident the code in question needs that flexibility.
2. Think about and design for performance throughout your development cycle, but put off the low-level, nitty-gritty optimizations that lock assumptions into your code until as late as possible.
3. Move quickly to explore your game&#39;s design space, but don&#39;t go so fast that you leave a mess behind you. You&#39;ll have to live with it, after all.
4. If you are going to ditch code, don&#39;t waster time making it pretty. Rock stars trash hotel rooms because they know they&#39;re going to check out the next day.
5. But, most of all, if you want to make something fun, have fun making it.

# Chap.2 Design Patterns Revisited

# Chap. Data Locality


{{&lt; admonition &gt;}}
But because of caching, the way you organize data directly impacts performance.
{{&lt; /admonition &gt;}}




---

> 作者: william  
> URL: https://williamlfang.github.io/2025-01-04-nystrom--game-programming-patterns/  


# Why R?


# 大神出品，必属精品

## 小小膜拜

这个文档记录了我在学习 [Hadley Wickham](http://had.co.nz/) 即将出版的新书，[Advanced R Programming](http://adv-r.had.co.nz/) 时的一些笔记与总结，以便将来复习查阅。

## 老司机谈经验

该书博大精深，结构严谨，涵盖面广泛，涉及几乎目前有关「R」的所有问题。从最基础的数据结构开始讲起，然后逐步渐进到如何编写针对问题的 `function`，再进阶到如何开发能够发布以供他人使用的 `package`。Wickham 本人就是在「R Community」团体中的传奇人物，开发了许多为人称道的宏包，如 `ggplot2`等。而本书真是作者在总结了近十年的 「R」软件开发后编写的一本巨著。仔细深入阅读此书必将受益匪浅，极大的提升我们使用与开发「R」的各项技能，真正从最底层去认识「R」这个当今最强大的数据处理、统计分析与图形可视化编程语言。

&lt;!-- more --&gt;

正如他自己所说的：

&gt; I have been programming in R for over 10 years, spending a lot of time trying to figure out how the language works. Not everyone has the luxury of spending years to understand a programming language, so this book is my attempt to help you to become an effective R programmer as quickly as possible. By reading this book, you will avoid the many mistakes that I made and the many dead ends that I got stuck in, and quickly navigate your way to useful tools and techniques. Although R has its frustrating quirks, I truly believe that at its heart lies an elegant and beautiful language, well tailored for data analysis and statistics. In this book, I&#39;ll do my best to reveal that language to you, helping you to understand powerful idioms that allow you to attack many types of problems.

-----

# Why 「R」

对于这个问题的回答，最简短的回答是

&gt; 多学一门编程语言总不会死吧？！！！

## 与计算机共舞

确实，在当今这个互联网与信息时代，我们的生活与工作与电脑紧密相连、形影不离，如果要想了解这个时代、这个世界，我们首先必须先了解那些控制与主宰了我们生活节奏的「电脑们」是如何「生活」的。进一步说，即那些操控了「电脑们」的**「程序」**是如何运行的。而所谓的「程序」，终归到底，是「程序语言」（Programming language）。前几年流行的一本「Hakers and Painters」就在序言开宗明义地说：

&gt; Everything around us is turning into computers. Your typewriter is gone, replaced by a computer. Your phone has turned into a computer. So has your camera. Soon your Tv will. Your car was not only designed on computers, but has more processing power in it than a room-sized mainframe did in 1970. Letters, encyclopedias, newspapers, and even your local store are being replaced by the Internet.

因此，我们要想了解世界，就必须先懂得这个世界在说什么（编程）「语言」。所谓「技多不压身」，多学习一门「编程语言」也促使我们从另外一个角度看世界，多一种批判的眼光，多一层思维的觉悟。何乐而不为？

## 请君入坑

当然，如果你是首次听说/接触「R」，对这个编程语言一点冲动的想法都没有，那我就需要找各种*理由*来劝说你「是时候该学习『R』了」，哪怕是对阅读统计报告的需要。

*注意*：真是下面的几条*Reasons*把我拉入了「R」介个广大的「神教」中，有幸或不幸，我也希望你来加入！

- 「R」是处理统计数据与图形可视化的「神器」，能够高效的完成各种数据分析，生成信息充实而页面精美的图形。一方面，我们可是直接使用现今已有的软件包（通过`install.packages(&#34;&#34;)`)，涵盖了从基本的统计分析方法，如计算均值，方差分析，到时下最前沿的统计方法，可用于处理有关统计建模、机器学习、大数据管理等问题;另一方面，如果发现现有的软件包不能满足或者不适合手头问题的解决，那么我们还可以自己动手开发。这个特性赋予了「R」强大的处理数据的能力。

- 「R」是一款**自由的开源软件体**。这意味着你有权限去获取、使用、修改甚至是发行任何版本的「R」程序。这一点对于使用`Windows`的用户可能不会意识到有多重要，因为在国内的环境中，我们从来都没有关心过一款软件的「版权」问题，心想着反正上网有大量的破解软件可供下载使用。可是对于一个合格的哪怕只是刚入门的「Geek」来说，我已经不能再忍受破解（=盗版=病毒）软件的荼毒。从网上某处下载的软件，总是神乎其神的在某个地方给你添加插件，修改管理者权限，安装不必要也不想要的软件。然后在某天开机之后，屏幕变黑，系统变坏，情绪变糟。

    后来我开始转移阵地到「Linux」，开始慢慢接触开源项目，才逐渐领会到开源软件带来的自由。比如，我可以从互联网以「正当理由」、「合理方式」获得所需的软件，并能够在尊重原开发者的情况下修改软件，生成「私人定制」，我甚至还可以将其发布到网上供他人使用。涉及到软件的自由是多层次的，其中最基本的一条就是，我可以修改、进一步开发以利解决问题。

    「R」就是这么一个软件，她给你所需，为你所用，助你之力。

     同时，「R」的开源特性也意味着这是一个免费的软件，我们可以以零成本的价格使用。这对于一枚「学生党」，有着「千情万钟」的诱惑（刨去破解软件）。

- 分散在世界各地的「R Community」为这个编程语言持续地注入新鲜的生命力，使之长久延续。我们可以到「CRAN」、[R-help mailing list](https://stat.ethz.ch/mailman/listinfo/r-help)、[StackOverflow](http://stackoverflow.com/questions/tagged/r)寻求帮助，也可以通过当地的「R user group」来咨询方案。不同与其他的编程语言，「R」的开源共享的属性让她得到世界各地用户的偏好，共同开发以保持其活力。我们无需担心哪一天自己辛苦学习与使用的编程语言/软件就撒手不干停止更新服务了。因此，学习「R」几乎是一个「零（违约）风险」的投资。

- 可重复（reproducable）研究指得是在现有的数据框架下，我们可以通过复制原来研究成果的代码来验证其准确性。这区别于更加广泛意义上的可复制（replecated）研究，即需要重新收集数据样本来复制结果。可重复研究允许我们在有限的经费预算约束下，极大可能的验证科学研究成果。

    「R」正是开发可重复研究的利器，提供了像`knitr`这样优秀的软件包，使得统计分析的任何一个过程都可以通过运行代码来检验研究成果。同时，我们还可以在文章正文中「植入」程序代码，直接计算结果（面向对象，object-oriented）、绘制图形（ggplot2）、编制表格（tabular，xtable）。这省去了传统的撰写文章的麻烦与琐碎。比如，原先我们可能是在「LaTex」中写入论述，等到了需要使用图形的地方，需要事先标明`\includegraphic{}`，然后通过查找对应的图片插入。这期间被各种「烦文缛节」、各种「黑暗技巧」搞得晕头转向、不知何处。最后搞不好还弄错了文字与图形的匹配。而这些统统在`knitr`中可以自动完成，我们需要的，就是顺着思维的路线一路走下去，该说人话的时候就写人话，该使用机器语言就直接健入代码产生需要的结果或者图形。真可谓

&gt; 「R」与「LaTex」齐飞，思想代码共一体。

- 此外，「R」还是一个*跨平台*的软件体，通吃「三界」：

    &#43; Windows系统可以直接点击`.exe`软件来安装;
    &#43; Linux系统使用命令安装：

           sudo apt-get install r-base r-base-dev

    &#43; Mac系统。（抱歉，我没有使用Mac，故此处不敢高声语。）


-----

# Why *Not* 「R」

对于这个问题，我真的不知该如何回答。如果说以上的几点理由还不够具有「杀伤力」，那在下也只能自愧功力不够、道行尚浅、修行有限。

## 小心套路

不过还好，大神来帮忙了：

&gt; Of course, R is not perfect. R&#39;s biggest challenge is that most R users are not programmers.

他给出的批评无非是「double-edged sword」，所谓凡是有利有弊、一正一邪。各位看官可以到大神的网上去找找不使用「R」的「牵强附会」的理由。在下无需多言，只不过再此累赘一下，也算是个人当初的体会。

## 出坑

「R」的学习曲线太陡峭、成本太高了。也就是说，对于一个初学者来说，「R」的代码几乎可以说是「摧枯拉朽」、「灭顶之灾」的。原因有二：

- **R** 掺杂了其他语言的使用，如**C**，**Python**。这旨在提高「R」的运行速度与计算能力，增强数据分析。不过这对「beginner」却造成了困扰。

 &gt; 我的建议是：既来之，则安之。一开始看不懂没关系，先试着挑-「好看」的来，然后再进一步深入学习。等到你真正需要扩展的时候，再去找些资料学习就可以了。

- **R** 对于编写程序没有过于严格的要求，是真正意义上的「注重结果」的编程语言。这直接造成了「恶劣影响」，导致许多的代码行都不大注重严谨，缺乏统一。看不懂别人的代码那是必须的，有时甚至都看不懂自己以前写的代码了。,,Ծ‸Ծ,,

 &gt; 推荐：多看多看多看！没见过猪跑也好歹有吃过猪肉。另外，可以看看一些「guide」，养成良好的编写程序的习惯，比如，大神的[建议](http://adv-r.had.co.nz/Style.html),以及[Google&#39;s R Style Guide](http://google-styleguide.googlecode.com/svn/trunk/Rguide.xml)



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2014-01-20-why-r/  


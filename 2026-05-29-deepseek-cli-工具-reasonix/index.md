# Deepseek cli 工具 Reasonix


&gt; 这篇博文本身就是 reasonix 自动完成的。

前两天在逛 GitHub 的时候，又看到 DeepSeek 生态里冒出来一个叫 [Reasonix](https://github.com/esengine/DeepSeek-Reasonix) 的项目。第一眼感觉就是又一个 AI coding agent 套壳，没什么稀奇的。但当我看完它的 README 和工程文档后，发现这事儿没那么简单——尤其有意思的是它的核心理念：**专为 DeepSeek 的前缀缓存（automatic prefix cache）设计**，所有行为都围绕这个来优化，把长会话的 token 成本压到最低。

要知道 DeepSeek 有一个很厉害的特性——自动前缀缓存。如果你的请求前缀跟上一次完全一样（byte-stable），这部分 tokens 就不重新算，只算新内容的计算成本。这意味着 cache hit 的价格可以低到 `¥0.02/M tokens`，而正常输入是 `¥1/M`，差了 50 倍。Reasonix 整个架构就是奔着这个去的——系统提示词、工具描述、记忆文档，全链路保持字节稳定，永远不会在会话中途偷偷修改前缀。

```bash
npm install -g reasonix
reasonix setup
export DEEPSEEK_API_KEY=sk-xxxxxxxxxxxxxxxx
reasonix chat
```

这是我自己的环境，当时从源码编译的

```bash
#需要设置 go 代理
export GOPROXY=https://goproxy.cn,direct
git pull
git pull origin main-v
make build
make cross

cd ./dist/
./reasonix-linux-amd64

alias rs=&#39;~/git/DeepSeek-Reasonix/dist/reasonix-linux-amd64&#39;

reasonix — a config- and plugin-driven coding agent (multi-model)

Usage:
  reasonix chat [--model NAME] [-c|--continue] [--resume]   interactive session (multi-turn; -c resumes the latest, --resume picks one)
  reasonix run  [--model NAME] [--max-steps N] [-c|--continue] [--resume PATH] &lt;task&gt;   run one task and exit
  reasonix serve [--model NAME] [--addr HOST:PORT]      serve the session over HTTP&#43;SSE (browser client at /)
  reasonix acp [--model NAME]                           serve Agent Client Protocol over stdio (also: reasonix --acp)
  reasonix setup [path]                                 interactive config wizard; writes reasonix.toml (&#43; .env)
  reasonix config auto-plan [off|on]                    configure automatic plan mode
  reasonix mcp &lt;add|remove|list&gt;                        manage MCP servers in reasonix.toml
  reasonix doctor [--json]                              print redacted local diagnostics
  reasonix version
  reasonix help

Examples:
  reasonix chat
  reasonix chat --continue
  reasonix run &#34;implement the TODOs in main.go&#34;
  reasonix run --model mimo-pro &#34;add unit tests for this function&#34;
  echo &#34;explain this code&#34; | reasonix run

Configuration:
  Resolution: flag &gt; ./reasonix.toml &gt; ~/.config/reasonix/config.toml &gt; built-in defaults
  Secrets come from the environment via api_key_env (e.g. DEEPSEEK_API_KEY).
  Run &#39;reasonix setup&#39; to scaffold a config; see docs/SPEC.md.

## 启动 server
reasonix serve
```

&lt;!--more--&gt;

# Reasonix 是什么

一句话：**Reasonix 是一个 DeepSeek 原生的 AI coding agent**。一个单静态 Go 二进制，不依赖 Node、Python 或任何运行时，通过 `reasonix.toml` 完全配置驱动。

它提供了三种前端界面：

- **TUI（Bubble Tea 终端界面）**—— 最常用的方式，`reasonix chat` 进入交互式对话
- **HTTP/SSE 服务器** —— `reasonix serve`，可以集成到其他工具中
- **Wails 桌面应用** —— 在 `desktop/` 目录下，`./dev` 启动开发模式

所有前端驱动同一个 `control.Controller`，逻辑完全一致，没有哪个前端需要重复实现轮询、取消、审批这些生命周期管理。

值得一提的是，Reasonix 1.0 是**从 TypeScript 到 Go 的完全重写**。0.x 的 TypeScript 版本已经转为 legacy，保留在 `v1` 分支。为什么重写？作者在文档里说得很清楚：要一个真正跨平台的、`CGO_ENABLED=0` 的静态二进制，不需要 npm 以外的任何依赖。Go 的标准库 &#43; 一个 TOML 解析库就是全部依赖，编译出来扔到任何 Linux 服务器上就能跑。

```sh
CGO_ENABLED=0 go build -ldflags &#34;-s -w -X main.version=$(git describe --tags --always)&#34; -o bin/reasonix ./cmd/reasonix
```

# 核心特性

## 配置驱动，无硬编码

这是最重要的一点。Provider、agent、启用的工具、插件，全部在 `reasonix.toml` 中声明。内核里没有 `switch model` 这种硬编码判断。

```toml
default_model = &#34;deepseek&#34;

[agent]
max_steps = 0
auto_plan = &#34;off&#34;

[[providers]]
name        = &#34;deepseek&#34;
kind        = &#34;openai&#34;
base_url    = &#34;https://api.deepseek.com&#34;
models      = [&#34;deepseek-v4-flash&#34;, &#34;deepseek-v4-pro&#34;]
default     = &#34;deepseek-v4-flash&#34;
api_key_env = &#34;DEEPSEEK_API_KEY&#34;
context_window = 1000000
price       = { cache_hit = 0.02, input = 1, output = 2, currency = &#34;¥&#34; }
effort      = &#34;high&#34;
```

**DeepSeek 和 MiMo 不是代码，而是配置实例**。两者都是 `kind = &#34;openai&#34;`，只是 `base_url`、`model`、`api_key_env` 不同。要加一个新的 OpenAI 兼容模型，编辑配置文件就够了，不用改一行代码。

看这个配置里的 `price`，DeepSeek 的 cache_hit 价格是 ¥0.02/M tokens，对比正常输入的 ¥1/M——差了 50 倍。这就是前缀缓存优化的价值所在。

## 多模型可组合

Reasonix 内置了 DeepSeek（flash/pro）和 MiMo（小米的大模型）作为预设。更重要的是它支持**双模型协同**：

```toml
[agent]
planner_model = &#34;mimo-pro&#34;    # 作为低频规划器
planner_max_steps = 12        # 暂停前允许的只读工具调用轮数
```

执行器（executor）和规划器（planner）各自运行在独立、缓存稳定的 session 中。Planner 只拿只读工具（读文件、搜索代码），先分析问题、生成计划，再交给执行器去实际写代码。两者的 `max_steps` 互不干扰。

Subagent 也有独立的模型配置：

```toml
[agent]
subagent_model = &#34;deepseek-pro&#34;
subagent_models = { review = &#34;deepseek-pro&#34;, security_review = &#34;deepseek-pro&#34; }
```

这样 `review`、`security_review` 这些子任务可以走不同的模型——比如重任务用 pro，轻任务用 flash 省钱。

## 插件驱动（MCP 客户端）

Reasonix 本身是一个 MCP 客户端。外部工具以子进程形式运行，通过 stdio JSON-RPC 或 HTTP（Streamable HTTP）通信。

```toml
[[plugins]]
name    = &#34;example&#34;
command = &#34;reasonix-plugin-example&#34;

[[plugins]]
name    = &#34;stripe&#34;
type    = &#34;http&#34;
url     = &#34;https://mcp.stripe.com&#34;
headers = { Authorization = &#34;Bearer ${STRIPE_KEY}&#34; }
```

如果你已经有 Claude Code 的 `.mcp.json`，直接放到项目根目录，Reasonix 会原样读取——它的 `mcpServers` 规范与 `[[plugins]]` 字段一一对应，两处来源合并加载，同名时以 `reasonix.toml` 为准。

MCP 的工具暴露为 `mcp__&lt;server&gt;__&lt;tool&gt;`，声明了 `readOnlyHint: true` 的工具会参与并行调度并走权限层的只读默认放行。服务器的 prompts 变成斜杠命令 `/mcp__&lt;server&gt;__&lt;prompt&gt;`，resources 通过 `@&lt;server&gt;:&lt;uri&gt;` 拉入。

内置工具（bash、read_file、write_file、edit_file、grep、glob、ls、web_fetch、todo_write 等）在编译期通过 `init()` 自注册，`main.go` 一行 blank import 拉入。新增一个内置工具 = 一个文件 &#43; 一行 import。

## 零摩擦分发

`CGO_ENABLED=0` 编译出单静态二进制，一条 `make cross` 交叉编译六个目标平台（darwin|linux|windows × amd64|arm64）。

```sh
npm i -g reasonix                  # 任意系统；自动拉取对应平台的原生二进制
brew install esengine/reasonix/reasonix   # macOS
```

Windows 构建还使用了 [SignPath 基金会](https://signpath.org/) 提供的免费代码签名证书，所以 Windows 上不会遇到&#34;不明来源程序&#34;的警告。

# 配置详解

`reasonix.example.toml` 是项目中最权威的配置参考（比 README 更全）。这里挑几个关键配置说说。

## Provider 配置

一个 provider 就是一个 vendor 端点（一个 `base_url` &#43; `api_key_env`），可以提供一个或多个模型：

```toml
[[providers]]
name     = &#34;deepseek&#34;
kind     = &#34;openai&#34;
base_url = &#34;https://api.deepseek.com&#34;
models   = [&#34;deepseek-v4-flash&#34;, &#34;deepseek-v4-pro&#34;]
default  = &#34;deepseek-v4-flash&#34;
api_key_env = &#34;DEEPSEEK_API_KEY&#34;
context_window = 1000000
effort   = &#34;high&#34;
```

用 `models = [...]` 列表可以让一个 vendor 暴露多个模型而无需重复声明 endpoint/key——切换模型复用同一个连接。`context_window` 和 `price` 是 per-provider 的，所以需要不同值的模型就保持独立的单 `model` 条目。

除了 `openai` 类型，还有一个 `anthropic` 类型，直接调用 Anthropic Messages API，不走 OpenAI shim：

```toml
[[providers]]
name           = &#34;claude&#34;
kind           = &#34;anthropic&#34;
model          = &#34;claude-opus-4-8&#34;
api_key_env    = &#34;ANTHROPIC_API_KEY&#34;
context_window = 1000000
thinking       = &#34;adaptive&#34;
effort         = &#34;high&#34;
```

## Agent 配置

```toml
[agent]
max_steps         = 0       # 执行器工具调用轮数；0 = 不限
planner_max_steps = 12      # 规划器只读调用轮数；0 = 不限
temperature       = 0.0
auto_plan         = &#34;off&#34;   # 计划模式
soft_compact_ratio  = 0.5   # 仅通知，保持缓存前缀不变
compact_ratio       = 0.8   # 达到这个比例时尝试压缩
compact_force_ratio = 0.9   # 强制压缩的水位线
```

这里的 `soft_compact_ratio` 和 `compact_ratio` 是**缓存优先（cache-first）压缩策略**的精髓。当 prompt 长度达到 `soft_compact_ratio`（50%）时，模型会收到一个&#34;你的上下文快满了&#34;的提示——但这**不会修改前缀**，所以前缀缓存依然有效。只有达到 `compact_ratio`（80%）才真正触发压缩，而此时压缩后的前缀仍然保持 byte-stable。

## 权限系统

权限按 `deny` &gt; `ask` &gt; `allow` &gt; fallback 逐次判断：

```toml
[permissions]
mode  = &#34;ask&#34;                                # 兜底策略
deny  = [&#34;Bash(rm -rf*)&#34;, &#34;Bash(git push*)&#34;] # 硬阻断
allow = [&#34;Bash(go test:*)&#34;]                  # 从不询问
```

注意这里的授权规则是**按命令模式匹配**，不是按按钮文案。`Bash(go test:*)` 匹配所有以 `go test` 开头的命令。`Edit(src/app.go)` 匹配对特定文件的编辑。chat 模式下每次 writer 调用前都会征求同意（1=本次允许，2=本会话允许此范围，3=总是允许并保存，4=拒绝），而 `reasonix run` 保持自主运行但仍然遵守 `deny`。

## 沙盒

权限是策略（哪些调用放行/询问），沙盒是强制执行：

```toml
[sandbox]
# workspace_root = &#34;&#34;          # 文件写工具限制在此目录；留空=当前目录
# allow_write    = [&#34;/tmp&#34;]    # 额外可写目录
```

文件写工具（`write_file`、`edit_file`、`multi_edit`）拒绝任何在 `workspace_root` 之外的路径，并且解析符号链接和 `..`，防止链接打洞越界。读不受限。macOS 上 bash 默认通过 Seatbelt 进沙盒——命令只能写允许的 root &#43; 临时目录和工具链缓存，由 `[sandbox] network` 控制是否可联网。

## Skill 系统

兼容 Claude Code 风格的 playbook 系统：

```toml
[skills]
paths = [&#34;~/my-skills&#34;, &#34;../shared/skills&#34;]
disabled_skills = [&#34;review&#34;]
```

Built-in skills（explore、research、review、security-review、test）开箱即用。用户自定义的放在 `.reasonix/commands/&lt;name&gt;.md`，调用即 `/name`。文件正文是 prompt 模板：

```markdown
---
description: Review the staged diff
argument-hint: [focus-area]
---
Review the staged diff. Focus on $ARGUMENTS, list bugs with file:line.
```

`$ARGUMENTS` 展开为全部空格分隔参数，`$1`…`$N` 为位置参数。

## CodeGraph 代码智能

Reasonix 内置了 CodeGraph——一个基于 tree-sitter &#43; SQLite 的代码符号/调用图工具。与其他 AI 编程工具不同，它**不需要 embedding 服务，没有额外的 API 成本**。

```toml
[codegraph]
enabled      = true
auto_install = true
```

CodeGraph 提供了 `codegraph_*` 系列工具（context、search、explore、trace、node、callers、callees、impact），整个索引就是本地 SQLite 数据库 &#43; tree-sitter AST 解析，纯本地运行，不消耗任何 token 或 API 调用。首次使用时自动拉取运行时，后台建索引，对会话启动速度影响极小。

# 双模型协同

这是 Reasonix 最独特的设计之一。大多数 AI coding agent 只有一个模型跑到底，但 Reasonix 允许你分配两个模型协作：

```toml
[agent]
planner_model = &#34;mimo-pro&#34;   # 低频规划器
planner_max_steps = 12       # 暂停前允许的只读工具调用轮数
```

Planner 会看到已加载的 `REASONIX.md` / `AGENTS.md` 记忆，拿到一小组只读研究工具（读文件、搜索代码），先分析项目结构、理解问题上下文，然后生成一份计划。执行器只看到写入类和流程类工具，按计划执行。

两者各走各的 session，各自的缓存前缀互不干扰。Planner 的低频调用（通常一次会话只调几次）可以配一个更贵的模型做深度分析，执行器用更快的模型做日常编码。

自动计划模式也很有意思：

```toml
[agent]
auto_plan = &#34;on&#34;
auto_plan_classifier = &#34;deepseek-flash&#34;
```

设置 `auto_plan = &#34;on&#34;` 后，看起来复杂的任务会自动进入 plan mode：Reasonix 先只读生成计划，待用户批准后才编辑文件或执行有副作用的命令。`auto_plan_classifier` 指定一个便宜的模型（如 deepseek-flash）用来做边界任务分类，只有分类失败时回退到启发式规则。

# 斜杠命令与 @ 引用

`reasonix chat` 里的斜杠命令在本地执行，不需要消耗模型调用：

```
/compact   — 压缩上下文
/new       — 开启干净的模型上下文（保留历史 transcript）
/rewind    — 回退到上一步
/tree      — 查看已保存的对话分支
/branch    — 从当前对话末端创建分支
/switch    — 切换到另一个分支
/model     — 切换模型
/effort    — 调整思考深度
/mcp       — 管理 MCP 服务器连接
/help      — 显示帮助
```

`@` 引用会在发送前解析成带标签的上下文块：

- `@path/to/file` — 注入本地文件内容
- `@dir` — 注入目录清单
- `@&lt;server&gt;:&lt;uri&gt;` — 注入 MCP 资源

敲 `/` 或 `@` 会弹出补全菜单——斜杠命令或逐层的文件导航（一次只列当前一层目录，可下钻进子目录），外加 MCP 资源。

# 架构赏析

如果只看功能列表，Reasonix 可能也就是又一个 AI coding agent。但它的架构设计体现了很深的工程思考。三层可扩展性，全部藏在按名解析的 registry 之后：

1. **Registry**：`Provider` 与 `Tool` 是接口；内核没有 `switch model`。注册中心根据名字查找实现。
2. **编译期内置**：provider（如 `provider/openai`）和 tool（如 `tool/builtin`）通过 `init()` 自注册，`main` 用 blank import 拉入。新增一个内置工具 = 一个文件 &#43; 一行 import。
3. **运行时插件**：配置里声明的可执行文件，通过 stdin/stdout 上的 JSON-RPC 2.0（MCP stdio 约定）通信，每个远程 tool 适配成 `Tool` 接口。

依赖方向是单向的：`cli → {agent, plugin, config} → {tool, provider}`。子包（`provider/openai`、`tool/builtin`）导入父包注册自己，父包从不导入子包。

再看项目结构（摘自 REASONIX.md 的架构图）：

```
cmd/reasonix/main.go         → cli.Run()          (入口点)
internal/
  boot/          Bootstrap: 读取配置、组装 provider/plugin/tool，
                 然后交给 control.Controller。
  control/       传输无关的 Controller。驱动 agent 主循环、
                 会话生命周期、审批、斜杠命令。
  agent/         Agent 主循环：turn 生命周期、tool 调度、
                 压缩、子 agent、多模型协调。
  provider/      Provider 抽象。具体实现通过 init() 自注册。
  tool/          Tool 注册中心 &#43; 执行框架。
  plugin/        MCP 插件生命周期：发现、stdio/HTTP 传输、延迟加载。
  permission/   allow/ask/deny 策略引擎。
  sandbox/      沙盒/强制。
  codegraph/    CodeGraph MCP 服务集成。
  skill/        Skill 系统。
  memory/       层级记忆文档 &#43; 自动记忆。
```

**缓存优先（cache-first）设计**是整个系统的北极星。系统提示词前缀（base prompt &#43; 工具描述 &#43; 记忆文档）在会话中必须保持 byte-stable，这样 DeepSeek 的服务端自动前缀缓存才能持续命中。怎么做到的？`control.Compose` 确保每次拼接出的前缀都不变。压缩策略中的 `soft_compact_ratio` 在低水位只给模型发提示而不截断前缀，高水位才替换前缀但替换后仍然保持稳定。

你可以感受到这个项目背后有清晰的工程哲学——作者在 [SPEC.md](https://github.com/esengine/DeepSeek-Reasonix/blob/main/docs/SPEC.md) 开头就写了：**&#34;Change the contract first, then the code.&#34;**

# 总结

Reasonix 打动我的不是它有多少功能（功能列表固然不错），而是它的设计目标非常清晰——**为 DeepSeek 的前缀缓存而生**。不是把 Claude Code 换个皮，不是 OpenAI 的套壳，而是围绕 DeepSeek 的特性从零构建。

它的 Go 重写也是有魄力的决定。TypeScript 版本已经有一批用户了，但为了&#34;CGO-free 单二进制 &#43; 零外部依赖&#34;这个承诺，毅然从零开始。结果就是：`npm install -g reasonix` 拉下来的是一个原生 Go 二进制，不需要 Node 运行时就能跑，扔到服务器上也是一个命令的事。

对我来说，Reasonix 最实用的场景是：

- **`reasonix run`** — 在 CI/CD 或终端里直接执行一次性任务，比如&#34;重构这个函数&#34;、&#34;补测试&#34;
- **`reasonix chat`** — 交互式编码，带着 `/` 和 `@` 补全的 TUI 体验很流畅
- **双模型协同** — Planner 用 pro 做代码分析，Executor 用 flash 快速执行，token 分配很合理
- **MCP 插件** — 已经接入了 Stripe API、文件系统等 MCP 服务

项目在 GitHub 的 [esengine/DeepSeek-Reasonix](https://github.com/esengine/DeepSeek-Reasonix)，有双语 README（中/英），Discord 社区也很活跃。如果你平时用 DeepSeek 比较多，或者想要一个真正 DeepSeek-native 的编程助手，Reasonix 值得一试。

---

**相关链接**

- [GitHub 仓库](https://github.com/esengine/DeepSeek-Reasonix)
- [reasonix.example.toml 配置参考](https://github.com/esengine/DeepSeek-Reasonix/blob/main/reasonix.example.toml)
- [工程规格文档 SPEC.md](https://github.com/esengine/DeepSeek-Reasonix/blob/main/docs/SPEC.md)
- [Discord 社区](https://discord.gg/XF78rEME2D)


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-05-29-deepseek-cli-%E5%B7%A5%E5%85%B7-reasonix/  


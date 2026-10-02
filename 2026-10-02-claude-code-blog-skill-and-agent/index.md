# A Claude Code skill and subagent that write posts for this blog


Most of my recent posts start the same way: I debug something in a Claude Code
session, then ask it to &#34;write this up&#34;. Without guidance the result is
generic: wrong front matter, a made-up category, marketing intros, and
sometimes output that was never actually printed. So I gave the repo two
small files that teach Claude Code how this blog works: a **skill**
(`blog-post`) and a **subagent** (`blog-writer`). This post is how they are
set up. It was written with the skill.

&lt;!--more--&gt;

## The setup

- Claude Code 2.1.287, run from the blog repo root
- Hugo v0.123.8 extended, theme FixIt, 298 posts in `content/posts/`
- Every post is a page bundle: `content/posts/&lt;YYYY-MM-DD&gt;-&lt;slug&gt;/index.md`
- `deploy.sh` builds with `--buildDrafts`, then `git add -A`, commits and
  pushes both the source and the `public/` GitHub Pages repo

Everything lives in the project&#39;s `.claude/` folder, so it travels with the
repo and only applies when Claude Code is started in this directory:

```text
.claude/
├── agents/
│   └── blog-writer.md
└── skills/
    └── blog-post/
        ├── SKILL.md
        ├── references/
        │   └── style-guide.md
        └── scripts/
            └── new-post.sh
```

## Skill vs. agent: who does what

The two pieces do different jobs:

| | skill (`blog-post`) | agent (`blog-writer`) |
|---|---|---|
| what it is | instructions &#43; files, loaded into the current session | a separate Claude with its own context and system prompt |
| when it runs | Claude decides from the `description`, or `/blog-post` | Claude delegates to it, or you ask for it by name |
| what it knows | the whole conversation so far | only what it is handed, plus the preloaded skill |
| tools | whatever the session has | restricted list in its front matter |

**The skill holds the knowledge; the agent is a sandboxed worker that uses
it.** In practice I mostly use the skill directly, right after a debugging
session, because the conversation already contains the real commands and
output. The agent is for when I want the writing done in a separate context
(it keeps the long post drafting out of the main session) or in the
background.

## Step 1: the skill

A skill is a folder under `.claude/skills/&lt;name&gt;/` with a `SKILL.md`. Only the
front matter is always visible to Claude; the body is loaded when the skill
is triggered, and the other files are read only when the body says so.

`.claude/skills/blog-post/SKILL.md` front matter:

```yaml
---
name: blog-post
description: Write a new post (or revise an existing one) for william&#39;s Hugo/FixIt blog in content/posts/, in the house style. Use whenever the user asks to write, draft, blog about, or &#34;turn this into a post&#34; — e.g. after a debugging session, an install/config walkthrough, or notes on a tool.
---
```

The `description` is what makes it trigger, so it lists the phrases I
actually use (&#34;write&#34;, &#34;draft&#34;, &#34;blog about&#34;, &#34;turn this into a post&#34;). The body is
a numbered workflow:

1. **Gather the material** from the conversation, shell history, configs and
   logs. Never invent output, benchmarks or versions; leave a `TODO` instead.
2. **Decide language, title, slug, category, tags**, with examples from real
   posts.
3. **Check for related posts** with `ls content/posts | grep -i &lt;keyword&gt;`
   and link them with `relref`. If the new post corrects an old one, add a
   dated `&gt; **Update YYYY-MM-DD:**` note to the old one.
4. **Scaffold** with the bundled script.
5. **Write the body**, then fill `summary:`.
6. **Verify** with a Hugo build.
7. **Report** the path and outline. Don&#39;t run `deploy.sh`, commit or push.

Plus a front matter table, so fields like `math` and `resources` only get
set when they are actually needed.

### The category rule came from real data

Step 2 says &#34;use an existing category, don&#39;t invent new ones&#34;. That rule
exists because of what years of hand-written front matter look like:

```bash
grep -h &#39;^categories:&#39; content/posts/*/index.md | sort | uniq -c
```

```text
    136 categories: []
      1 categories: [books]
      1 categories: [learning]
      5 categories: [Linux]
     16 categories: [programming]
      8 categories: [Programming]
      5 categories: [tool]
    112 categories: [tools]
      2 categories: [Tools]
      2 categories: [toolsj]
    ...
```

`tool`, `Tools`, `toolsj` and `tools` are all the same category. The skill
pins it to `Linux`, `tools` or `programming` and tells Claude to run that same
one-liner if unsure.

### The style guide

`references/style-guide.md` is the longest file. It is distilled from the
existing posts and names four exemplars to read when unsure about tone (the
two tmux lag posts, the Claude Desktop install guide, and a short Chinese
note). It covers:

- **Voice**: first person, short sentences, no &#34;In this comprehensive guide&#34;,
  no emoji, include dead ends, bold one key fact per section.
- **Structure** per post type: debugging posts (setup → steps → why → fix →
  results table → takeaways), how-to posts (error → why the obvious fix fails
  → steps → gotchas), short Chinese notes. Every post has a standalone
  opening and then `&lt;!--more--&gt;`, because that is the home page excerpt.
- **Code**: commands and their output in separate blocks, output in `text`
  blocks, real output only, trimmed with `...`.
- **Cross-references** with `relref`, and the FixIt shortcodes that exist.
- **Privacy**: scrub hostnames, tokens, company names before finishing.
- **Chinese posts**: spaces between Chinese and English, full-width
  punctuation, technical terms left in English.

Keeping this in a separate file matters: `SKILL.md` stays short, and the
guide is only read when a post is actually being written.

### The scaffolding script

`scripts/new-post.sh` writes the standard FixIt front matter, so Claude never
has to remember two dozen fields or get the timezone offset wrong:

```bash
.claude/skills/blog-post/scripts/new-post.sh &lt;slug&gt; &#34;&lt;title&gt;&#34; &lt;category&gt; &lt;tag1,tag2,...&gt;
```

A few details that matter:

- It finds the repo root with `git rev-parse --show-toplevel`, so it works
  from any directory.
- `date` and `lastmod` come from `date &#43;%Y-%m-%dT%H:%M:%S%:z`, i.e. the real
  local offset.
- It normalises the slug the same way my old `Rakefile` did: spaces and
  colons (including the full-width `：`) become dashes, so Chinese slugs work.
- `DRAFT=false` publishes, `DATE=YYYY-MM-DD` backdates, and it **refuses to
  overwrite an existing post**:

  ```bash
  if [ -e &#34;$file&#34; ]; then
      echo &#34;exists: $file&#34; &gt;&amp;2
      exit 1
  fi
  ```

This post was created with it:

```bash
.claude/skills/blog-post/scripts/new-post.sh claude-code-blog-skill-and-agent \
  &#34;A Claude Code skill and subagent that write posts for this blog&#34; \
  tools &#34;Claude,ClaudeCode,hugo,blog,skill,agent&#34;
```

```text
/home/william/git/myblog/content/posts/2026-10-02-claude-code-blog-skill-and-agent/index.md
```

Remember to `chmod &#43;x` the script, since Claude calls it directly.

## Step 2: the agent

A subagent is a single Markdown file under `.claude/agents/`. The front
matter configures it; the body is its system prompt.

`.claude/agents/blog-writer.md`:

```yaml
---
name: blog-writer
description: Writes or revises a post for william&#39;s Hugo blog (content/posts/) in the house style. Give it the topic plus the raw material — what was done, commands, outputs, errors, numbers, file paths — and the preferred language if any. Use proactively when the user asks to write up / blog about something.
tools: Read, Write, Edit, Bash, Grep, Glob, WebFetch
skills:
  - blog-post
---
```

Three fields do the work:

- **`description`** is written for the *main* Claude, which decides when to
  delegate. It says what to hand over: the topic and the raw material. This
  is important because **a subagent starts cold**; it does not see the
  conversation that produced the material.
- **`tools`** is an allowlist. No `Agent` (it can&#39;t spawn more agents), no
  web search, just enough to read, write and build.
- **`skills: [blog-post]`** preloads the skill, so the agent doesn&#39;t have to
  discover it. The agent and the skill share one source of truth: if I change
  the style guide, both paths pick it up.

The body is short, because the skill already holds the workflow:

```markdown
Follow the preloaded `blog-post` skill exactly: read its
`references/style-guide.md`, skim one or two of the exemplar posts it names
that match the post type, scaffold with its `scripts/new-post.sh`, write the
body, fill `summary:`, and verify with a `hugo` build.
```

followed by the rules that need repeating for an agent working alone:

- Use only facts from the material given or verifiable on this machine. If
  something is missing, write `TODO: &lt;what is needed&gt;` and report it.
- Don&#39;t run anything destructive to &#34;reproduce&#34; an issue.
- **Never run `deploy.sh`, `git commit` or `git push`.**
- Scrub secrets, internal hostnames and company names.

and a fixed report format: path, title, category/tags, a 3-line outline, any
TODOs, and any older post it added an update note to.

### Why &#34;never deploy&#34; is not optional

Look at `deploy.sh` again: it runs `hugo --buildDrafts=true` and then
`git add -A` and `git push` on both repos. So **`draft: true` does not keep
anything private**; it is a marker, not a gate. Anything in the working tree,
including a half-written post or a stray file, goes public the moment deploy
runs. The skill says so in its front matter table, and the agent has the rule
in its own prompt. Publishing stays my decision.

## Using it

Both are picked up automatically when Claude Code starts in the repo; no
settings change is needed. `/agents` lists the agent and the skill shows up
in the skill list.

After a debugging session, the skill path:

```text
&gt; write a blog post about what we just found
```

Claude matches the request to the skill&#39;s description, loads `SKILL.md`, and
follows the workflow with the real commands and output still in context.
`/blog-post` invokes it explicitly.

The agent path, when I want it out of the main context:

```text
&gt; use the blog-writer agent to write up the tmux fix; here is the material: ...
```

The main session passes the material along, the agent writes and builds the
post, and returns the report.

Then I review the diff, edit, and run `./deploy.sh` myself.

## Verifying

The skill&#39;s last step is a build into a throwaway directory:

```bash
hugo --buildDrafts --buildFuture --quiet -d /tmp/hugo-check 2&gt;&amp;1 | tail -20
```

No output means it built, and that every `relref` resolves; a broken
`relref` is a build error in Hugo, which makes this a cheap link checker.

## Takeaways

1. **Put the knowledge in a skill, and the isolation in an agent.** The
   agent&#39;s prompt is mostly &#34;follow the skill&#34;, so there is one place to edit.
2. **Write descriptions for the model that reads them.** The skill&#39;s
   description lists trigger phrases; the agent&#39;s tells the caller what
   material to hand over, because the agent can&#39;t see the conversation.
3. **Derive the style guide from your own posts**, not from general writing
   advice. Naming concrete exemplar posts did more than any list of rules.
4. **Move anything mechanical into a script.** Front matter, dates and slug
   normalisation are exactly where a model drifts; a 60-line shell script
   doesn&#39;t.
5. **Guard the irreversible step.** Here that is `deploy.sh`, which publishes
   everything including drafts. Both files forbid running it.

## References

- [Claude Code: Agent Skills](https://docs.claude.com/en/docs/claude-code/skills)
- [Claude Code: Subagents](https://docs.claude.com/en/docs/claude-code/sub-agents)
- [Hugo: `relref` shortcode](https://gohugo.io/content-management/shortcodes/#relref)
- [My earlier post on setting up this blog]({{&lt; relref &#34;使用hugo&#43;github搭建博客&#34; &gt;}})


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-10-02-claude-code-blog-skill-and-agent/  


# Logging a full pandas DataFrame from an f-string: rebuild it from the caller&#39;s source


A daily script of mine logs its intermediate DataFrames with
`log.crt(f&#34;&#34;&#34;...{tgt = }...&#34;&#34;&#34;)`. The log showed 10 of the 90 rows, with the
header stuck to the end of `tgt = `. Switching to `tgt.to_string()` printed every
row, but the header ended up two columns left of the data.

The fix I ended up with keeps the f-string as it is and adds one argument:
`log.crt(f&#34;...{tgt = }...&#34;, full=True)`. That looks impossible, because the
f-string is already built when the logger runs. The logger gets around it by
finding the f-string in the caller&#39;s source and evaluating it a second time.

&lt;!--more--&gt;

## The setup

- `log` comes from `wepy`, my utility package. It&#39;s a thin wrapper around
  [loguru](https://github.com/Delgan/loguru): `log.crt/err/wrn/inf/dbg`, an
  emoji per level, and a dedent step so triple-quoted messages can be indented
  along with the code.
- Python 3.11.4, pandas, IPython 9.5.
- The call that started it:

```python
log.crt(f&#34;&#34;&#34;
    {day = }
    {&#39;*&#39;*40}
    {tgt = }
    &#34;&#34;&#34;)
```

All outputs below come from a 90-row sample frame with neutral account names.

## Step 1: `{tgt = }` is just `repr(tgt)`

```text
CRITICAL | 💥
day = &#39;2026-10-15&#39;
****************************************
tgt =    Account           NetAmt
0   FUND_A 1,250,000.500000
1   FUND_B  -830,000.250000
2   FUND_C    47,000.000000
..     ...              ...
87  FUND_A 1,250,000.500000
88  FUND_B  -830,000.250000
89  FUND_C    47,000.000000

[90 rows x 2 columns]
```

There are two problems here, and neither comes from the logger:

- **pandas truncates the repr.** Above `display.max_rows` (60) it shows only
  `display.min_rows` (10).
- **`=` puts the header on the same line as `tgt = `**, so the header sits 6
  characters to the right of the rows.

## Step 2: `to_string()` printed every row, but the header moved

With a 3-row slice, `small = tgt.head(3)`, to keep the output short:

```python
log.crt(f&#34;&#34;&#34;
    {day = }
    tgt =
{small.to_string()}
    &#34;&#34;&#34;)
```

```text
CRITICAL | 💥
  day = &#39;2026-10-15&#39;
  tgt =
Account           NetAmt
0  FUND_A 1,250,000.500000
1  FUND_B  -830,000.250000
2  FUND_C    47,000.000000
```

Now `Account` starts at column 0 when it should start at column 2, and the
text lines kept 2 of their 4 spaces. This one is the logger&#39;s fault. Its dedent
step looks like this (simplified, comments translated):

```python
_RE_LINE_BODY = re.compile(r&#34;(\n\s&#43;)\S.*&#34;)

while True:
    # reduce every indented line to its indentation, keep the whitespace-only ones
    tmp = [k for k in _RE_LINE_BODY.sub(lambda m: m.group(1), msg).split(&#39;\n&#39;)
           if k and k.isspace()]
    if tmp:
        space = min(tmp)                       # the shortest indentation
        msg = msg.replace(f&#34;\n{space}&#34;, &#39;\n&#39;)  # strip it from every line
    if not msg.endswith(&#39;\n&#39;):
        return msg
    msg = msg[:-1]                             # trailing newline: strip again
```

**Lines that start at column 0 don&#39;t count toward the common indent.** A
DataFrame&#39;s rows start with the index at column 0. Its header starts with spaces
that pad over the index column. So the header&#39;s 2 spaces became the &#34;common
indent&#34;, and they were stripped from every line, including the header itself.
The `while` loop makes it worse: when the message ends in a newline, it strips a
second time.

I didn&#39;t change this algorithm. The second-pass flattening is asserted in the
logger&#39;s self-test, and other programs rely on it.

The call-site workaround is to indent the table to match the text and close the
quotes on the last line, so the second pass never runs:

```python
log.crt(f&#34;&#34;&#34;
    {day = }
    tgt =
{textwrap.indent(tgt.to_string(), &#39; &#39;*4)}&#34;&#34;&#34;)
```

It works, but nobody will remember to write it.

## Step 3: let the logger take the DataFrame itself

The logger can&#39;t tell which lines of a finished string came from a table. If it
gets the DataFrame object, though, it can print it without dedenting:

```python
def clean_msg(self, msg):
    if hasattr(msg, &#39;to_string&#39;):
        # DataFrame/Series: all rows, and no dedent (it would misalign the header)
        return &#39;\n&#39; &#43; msg.to_string()
    ...
```

I also made the level methods accept several parts. Text parts are dedented as
before, and DataFrames are left alone:

```python
log.crt(f&#34;&#34;&#34;
    {day = }
    tgt =&#34;&#34;&#34;, tgt, &#34;cfund =&#34;, cfund)
```

That gives a full, aligned table. But I still wanted to write `{tgt = }`.

## Step 4: a flag can&#39;t fix a string that&#39;s already built

My next idea was a `full=True` argument. It can&#39;t work on a plain f-string,
because **Python builds the f-string before calling the function**. By the time
`log.crt` runs, the truncated text is all it has.

A `lambda` delays the building:

```python
x = 1
s = f&#34;{x}&#34;           # built now
f = lambda: f&#34;{x}&#34;   # a recipe, built when called
x = 2
print(s, f())
```

```text
1 2
```

So `log.crt(lambda: f&#34;...{tgt = }...&#34;, full=True)` works. The logger swaps
`DataFrame.__repr__` for a full version, calls the lambda, and swaps the repr
back.

### Wrong turn: a global flag

Before the per-call argument I tried `log.full_df = True`, which patched
`DataFrame.__repr__` for the whole process. It worked, but it also changed every
`print(df)` in the program. I dropped it: the full repr should exist only while
the logger builds its message.

## Step 5: rebuild the f-string from the caller&#39;s source

The `lambda:` still bothered me. My first answer to &#34;can `full=True` turn the
f-string into a lambda for me?&#34; was no. The string is finished, and nothing in
it says it came from `{tgt = }`.

That was too quick. The logger can&#39;t recover anything from the string, but it
can find the f-string in the caller&#39;s source code and evaluate it again, the way
[icecream](https://github.com/gruns/icecream) prints the expression you passed
to `ic()`. On Python 3.11 that takes only the standard library:

- **`frame.f_lasti`** is the bytecode offset of the instruction the caller is
  running. While `log.crt` runs, that instruction is the `CALL`.
- **`code.co_positions()`**, added by
  [PEP 657](https://peps.python.org/pep-0657/), gives the exact source span of
  every instruction: start line, end line, start column, end column.
- **`linecache`** has the caller&#39;s source, including IPython cells.
- **`ast`** parses that source. The `Call` node with the same span is our call,
  and its `JoinedStr` arguments are the f-strings.

A standalone demo, `where.py`:

```python
import ast, linecache, sys

def who_called_me(*args):
    frame = sys._getframe(1)                       # the caller
    code = frame.f_code
    # (lineno, end_lineno, col, end_col) of the CALL instruction running right now
    pos = list(code.co_positions())[frame.f_lasti // 2]
    src = &#39;&#39;.join(linecache.getlines(code.co_filename, frame.f_globals))
    call = next(n for n in ast.walk(ast.parse(src)) if isinstance(n, ast.Call)
                and (n.lineno, n.end_lineno, n.col_offset, n.end_col_offset) == pos)
    print(pos)
    print(ast.unparse(call))

name = &#39;world&#39;
who_called_me(f&#34;hello {name}&#34;,
              42)
```

```text
(15, 16, 0, 17)
who_called_me(f&#39;hello {name}&#39;, 42)
```

From there, `compile(ast.Expression(fstring_node), ...)` and
`eval(code, frame.f_globals, frame.f_locals)` rebuild the f-string with the
caller&#39;s variables, with the full repr switched on.

### Making it safe to evaluate twice

Evaluating code a second time is the risky part, so I added three rules:

1. **Skip f-strings that contain a function call.** `{fm.get_tgt() = }` would
   run `get_tgt()` again, and mine changes state. Those arguments keep their
   original, truncated text. Names, attributes, subscripts and operators like
   `&#39;*&#39;*40` are fine.
2. **Check before trusting the match.** Rebuild the f-string once with the
   normal repr. If it doesn&#39;t equal the string the logger received, the match
   is wrong, for example because the file was edited while the program was
   running. In that case, keep the original.
3. **Any exception falls back to the original string.** Logging must never crash
   the program, and on Python older than 3.11 `co_positions` doesn&#39;t exist.

Rule 1 in action. The call runs once, and the output stays truncated:

```python
def get_tgt():
    print(&#34;get_tgt() called&#34;)
    return tgt
log.crt(f&#34;{get_tgt() = }&#34;, full=True)
```

```text
get_tgt() called
CRITICAL | 💥 get_tgt() =    Account           NetAmt
0   FUND_A 1,250,000.500000
..     ...              ...
```

### Keeping the table aligned through the dedent

The full repr still has to get through the dedent from step 2, and the header
should start on its own line instead of after `tgt = `. The replacement repr
fixes both:

```python
_DF_MARK = &#39;​&#39;   # zero-width space

def _df_repr(self):
    return &#39;\n&#39; &#43; &#39;\n&#39;.join(_DF_MARK &#43; k for k in self.to_string().split(&#39;\n&#39;))
```

- The leading `\n` moves the header off the `tgt = ` line.
- **A zero-width space isn&#39;t whitespace to Python.** `&#39;​&#39;.isspace()` is
  `False`, and regex `\s` doesn&#39;t match it. So every table line looks like a
  column-0 text line, and the dedent never touches its spaces. After the dedent,
  the logger deletes each `\n​`, so no invisible characters end up in the
  log file.

## The fix

The two helpers in `wepy/utils/logger.py`:

```python
def _fstring_args(frame, msgs):
    &#34;&#34;&#34;f-string arguments of the log call running in `frame` that are safe to
    re-evaluate: {argument index: compiled f-string}, or {} if anything is off.&#34;&#34;&#34;
    try:
        code = frame.f_code
        # 3.11&#43;: exact source span of the CALL instruction being executed
        pos = list(code.co_positions())[frame.f_lasti // 2]
        # IPython cell sources are in linecache too
        src = &#39;&#39;.join(linecache.getlines(code.co_filename, frame.f_globals))
        call = next(n for n in ast.walk(ast.parse(src)) if isinstance(n, ast.Call)
                    and (n.lineno, n.end_lineno, n.col_offset, n.end_col_offset) == pos)
        if len(call.args) != len(msgs):
            return {}
        out = {}
        for i, (arg, msg) in enumerate(zip(call.args, msgs)):
            # f-strings with a function call are not re-evaluated: it would run twice
            if not isinstance(arg, ast.JoinedStr) or any(isinstance(n, ast.Call) for n in ast.walk(arg)):
                continue
            expr = compile(ast.Expression(arg), code.co_filename, &#39;eval&#39;)
            # guard: with the normal repr it must reproduce the string we were given
            if eval(expr, frame.f_globals, frame.f_locals) == msg:
                out[i] = expr
        return out
    except Exception:
        # best effort only; never let logging crash the program
        return {}


def _render_full(frame, msgs):
    &#34;&#34;&#34;full=True: re-evaluate f-string arguments (and call lambda messages)
    with the full DataFrame repr, swapped in only while evaluating.&#34;&#34;&#34;
    import pandas as pd
    fstrings = _fstring_args(frame, msgs)
    orig = pd.DataFrame.__repr__
    pd.DataFrame.__repr__ = _df_repr
    try:
        return [eval(fstrings[i], frame.f_globals, frame.f_locals) if i in fstrings
                else m() if callable(m) else m
                for i, m in enumerate(msgs)]
    finally:
        pd.DataFrame.__repr__ = orig
```

And where they&#39;re wired in:

```python
def _log(self, level, icon, msgs, exception=False, full=False):
    if full:
        # depth 2: _log &lt;- crt/wrn/... &lt;- the caller&#39;s code
        msgs = _render_full(sys._getframe(2), msgs)
    elif any(callable(m) for m in msgs):
        msgs = [m() if callable(m) else m for m in msgs]
    text = icon &#43; &#39; &#39; &#43; self.clean_msg(msgs[0]) &#43; &#39;&#39;.join(
        &#39;\n&#39; &#43; self.clean_msg(m).lstrip(&#39;\n&#39;) for m in msgs[1:])
    if &#39;\n&#39; in text:
        text = _RE_WS_ONLY_LINE.sub(&#39;&#39;, text).replace(&#39;\n&#39; &#43; _DF_MARK, &#39;\n&#39;)
    self.logger.opt(depth=2, exception=exception).log(level, text)

def crt(self, *msg, full=False):
    self._log(&#34;CRITICAL&#34;, &#34;💥&#34;, msg, full=full)
```

A few details that matter:

- `sys._getframe(2)` has to be the caller&#39;s frame. `_log` is always two levels
  below it, the same depth loguru&#39;s `opt(depth=2)` already relies on.
- `frame.f_lasti // 2`: on 3.11, `co_positions()` yields one entry per 2-byte
  code unit, cache entries included, so the offset divided by 2 is the index.
- The `repr` swap sits in `try/finally`, and it covers only the evaluation. For
  that moment it&#39;s process-wide, so another thread printing a DataFrame at the
  same instant would get the full version too.

## Results

The original call, unchanged except for `full=True`:

```python
log.crt(f&#34;&#34;&#34;
    {day = }
    {&#39;*&#39;*40}
    {tgt = }
    &#34;&#34;&#34;, full=True)
```

```text
CRITICAL | 💥
day = &#39;2026-10-15&#39;
****************************************
tgt =
   Account           NetAmt
0   FUND_A 1,250,000.500000
1   FUND_B  -830,000.250000
2   FUND_C    47,000.000000
...
88  FUND_B  -830,000.250000
89  FUND_C    47,000.000000
```

| call | rows logged | header aligned |
|---|---|---|
| `f&#34;{tgt = }&#34;` | 10 of 90 | no, glued to `tgt = ` |
| `f&#34;{tgt.to_string()}&#34;` | 90 | no, shifted left |
| `&#34;tgt =&#34;, tgt` (multi-part) | 90 | yes |
| `lambda: f&#34;{tgt = }&#34;`, `full=True` | 90 | yes |
| `f&#34;{tgt = }&#34;`, `full=True` | **90** | **yes** |

Cost: `full=True` parses the caller&#39;s whole file on every call. For my
1,806-line script, that&#39;s **12.5 ms per call**. Calls without `full=True` don&#39;t
pay anything. The logger&#39;s self-test covers a multi-line f-string, a function&#39;s
local variables, an f-string with a call (which must run once), and the repr
being restored. I also ran the same call inside a real IPython shell
(`IPython.testing.globalipapp`), and all 90 rows came out.

## Bonus: picking up a reinstalled package in a running IPython

wepy installs as an egg, so every change meant a reinstall. To use the new
logger in an IPython session that was already open:

```python
import importlib, loguru, wepy.utils.logger, wepy.utils.init
loguru.logger.remove()                 # otherwise every line is logged twice
importlib.reload(wepy.utils.logger)    # the new Logger class
importlib.reload(wepy.utils.init)      # rebuilds `log` with it
from wepy.utils.init import *          # rebind `log` in the session
```

The order matters. Reloading only `init` rebuilds `log` with the old class.
`loguru.logger` is a process-wide singleton, and the reloaded `Logger` forgets
which handlers it already added, so without `remove()` it adds them again.

## Takeaways

1. **An f-string is finished before the function sees it.** No flag on the
   callee can change how it was built. You either delay it (`lambda:`) or
   rebuild it.
2. **A dedent and a table don&#39;t mix.** If a dedent skips column-0 lines when it
   computes the common indent, it will strip a DataFrame header&#39;s padding. Mark
   lines you want left alone with a character that isn&#39;t whitespace.
3. **Python 3.11 knows exactly which call is running.** With `f_lasti` and
   `co_positions()`, plus `linecache` and `ast`, you can get from a frame to
   the source of the call in about ten lines.
4. **Re-evaluating code is safe only without calls, and only after a check.**
   Skip anything that contains `ast.Call`, and confirm the rebuilt string
   matches the one you were given before trusting it.
5. **The proper fix is Python 3.14&#39;s template strings.** With
   [PEP 750](https://peps.python.org/pep-0750/), `log.crt(t&#34;{tgt = }&#34;)` passes
   the DataFrame object itself to the logger, with no source parsing. On 3.11,
   this is the closest I can get.

## References

- [PEP 657: fine-grained error locations](https://peps.python.org/pep-0657/), which added `co_positions()`
- [`codeobject.co_positions()`](https://docs.python.org/3/reference/datamodel.html#codeobject.co_positions)
- [PEP 750: template strings](https://peps.python.org/pep-0750/)
- [pandas options: `display.max_rows`, `display.min_rows`](https://pandas.pydata.org/docs/user_guide/options.html)
- [icecream](https://github.com/gruns/icecream) and [executing](https://github.com/alexmojaki/executing), which use the same source-lookup idea in a general form


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-10-15-log-full-dataframe-from-fstring/  


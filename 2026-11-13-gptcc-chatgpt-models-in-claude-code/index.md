# ChatGPT models in Claude Code: gptcc setup and troubleshooting


I wanted Claude Code&#39;s terminal interface and tools to run ChatGPT models. Installing `gptcc` was only the first step. I could select Sol in `/model` and still get an account-hold error before the request reached GPT.

The working setup uses a local authenticated gateway, ChatGPT OAuth, and Claude Code&#39;s custom model picker. It lists eight GPT models, makes **Default resolve to GPT-6.1 Sol with medium effort**, and displays Codex&#39;s five-hour and weekly usage beside the model. A real Claude Code session completed a file-read tool call in two turns.

&lt;!--more--&gt;

The featured image reproduces the live `/model` menu. The red boxes mark the Default model and medium effort. Terminal pictures in this post are rendered from captured output for readability, not photographs of a terminal window. [Open the full-size picker image](featured-image.png).

## The configuration I tested

This post records the setup on November 13, 2026. Package defaults, model availability, and Claude Code&#39;s configuration keys change. The installed code and the live requests mattered more than an older README example.

| Component | Observed value |
|---|---|
| Operating system | Linux |
| Node.js | `v24.20.0` |
| Claude Code | `2.1.316` |
| gptcc | `2.5.3` |
| Local gateway | `http://127.0.0.1:52532` |
| Default model | `gpt-6.1-sol` |
| Saved effort for Sol | `medium` |
| Upstream identity | Existing ChatGPT OAuth login |
| Verification | Claude Code invoked `Read` and returned the file contents |

[gptcc](https://github.com/joungminsung/gptcc) translates requests between Claude Code and GPT. It is a community project. Anthropic&#39;s [gateway documentation](https://code.claude.com/docs/en/llm-gateway) describes the gateway mechanism but explicitly does not support routing to non-Claude models. Treat this as a version-specific interoperability setup, not an official multi-provider feature or a guarantee of continued compatibility.

I previously wrote about [installing Claude Desktop on an older Ubuntu system]({{&lt; relref &#34;2026-09-22-claude-desktop-on-ubuntu-20.04&#34; &gt;}}). This post concerns the `claude` terminal application. The desktop application&#39;s connector behavior can differ.

## Understand the two credentials before changing settings

![Request flow from Claude Code to the authenticated loopback gptcc proxy and then to ChatGPT with separate OAuth credentials](request-flow.png &#34;The local gateway token and ChatGPT OAuth token serve different connections. Neither is an Anthropic subscription credential.&#34;)

There are two separate connections in the final configuration:

1. Claude Code authenticates to my local gptcc gateway. `ANTHROPIC_AUTH_TOKEN` is the client credential. The gateway checks it against `GPTCC_AUTH_TOKEN`.
2. gptcc authenticates to ChatGPT using the existing OAuth login in `~/.codex/auth.json`.

The two local gateway variables contain the **same randomly generated value**. They do not contain the ChatGPT access token. I did not copy OAuth tokens into Claude settings.

The gateway address chooses a destination. The gateway credential chooses the authentication route. Setting only `ANTHROPIC_BASE_URL` left Claude Code using my saved claude.ai login. That distinction explained the most confusing failure in this session.

## Install gptcc and use the native messages route

First check the installed tools:

```bash
node --version
claude --version
command -v node
command -v claude
```

Install gptcc if it is missing:

```bash
npm install -g gptcc
```

For the tested gptcc version, use the native messages route and explicitly name the GPT model:

```bash
env -u OPENAI_API_KEY GPTCC_NO_UPDATE=1 \
  gptcc setup --model gpt-6.1-sol --no-haiku-remap
```

This is the recommended starting command for this guide. During the investigation I initially used `--multi-slot`; the Bedrock transport that option enabled failed with this Claude Code version. I explain that error below.

If gptcc cannot reuse an existing ChatGPT login, complete its browser login. On a remote machine, its device-code option is available:

```bash
gptcc login --device
```

Use a ChatGPT account that can access the requested model. A model appearing in someone else&#39;s screenshot does not establish access for your account. In this session I obtained the model IDs and descriptions from the local Codex model list.

`GPTCC_NO_UPDATE=1` kept the package version stable while diagnosing it. It is not a model-routing setting. `env -u OPENAI_API_KEY` prevents this setup process from selecting gptcc&#39;s API-key path through an inherited environment variable.

## Apply the configuration without exposing credentials

The [configuration helper](configure-gptcc.py) merges the settings used in this guide. Download it together with [model-picker.json](model-picker.json) into the same directory, inspect both files, and run:

```bash
python3 configure-gptcc.py
```

The helper is for Linux and macOS. It locates the installed `node` and gptcc startup hook, backs up `~/.claude/settings.json`, generates a local gateway token, and writes the settings with mode `0600`. It preserves unrelated settings and hooks. Repeating it does not generate another token or another identical startup hook.

The helper changes model routing, the picker, the Sol effort setting, and connector loading. It does not sign in for you, install the optional status bar, or restart an already running proxy.

The relevant part of `~/.claude/settings.json` looks like this. The angle-bracket values below are placeholders, not usable credentials:

```json
{
	&#34;env&#34;: {
		&#34;ANTHROPIC_BASE_URL&#34;: &#34;http://127.0.0.1:52532&#34;,
		&#34;ANTHROPIC_AUTH_TOKEN&#34;: &#34;&lt;same-local-gateway-token&gt;&#34;,
		&#34;GPTCC_AUTH_TOKEN&#34;: &#34;&lt;same-local-gateway-token&gt;&#34;,
		&#34;OPENAI_API_KEY&#34;: &#34;&#34;,
		&#34;NODE_USE_ENV_PROXY&#34;: &#34;1&#34;,
		&#34;ANTHROPIC_DEFAULT_MODEL&#34;: &#34;gpt-6.1-sol&#34;,
		&#34;ANTHROPIC_CUSTOM_MODEL_OPTION&#34;: &#34;gpt-6.1-sol&#34;,
		&#34;ANTHROPIC_CUSTOM_MODEL_OPTION_NAME&#34;: &#34;GPT-6.1 Sol&#34;,
		&#34;ANTHROPIC_CUSTOM_MODEL_OPTION_SUPPORTED_CAPABILITIES&#34;: &#34;effort,thinking,adaptive_thinking&#34;,
		&#34;ANTHROPIC_DEFAULT_OPUS_MODEL&#34;: &#34;gpt-6-astra&#34;,
		&#34;ANTHROPIC_DEFAULT_SONNET_MODEL&#34;: &#34;gpt-6.1-sol&#34;,
		&#34;ANTHROPIC_DEFAULT_HAIKU_MODEL&#34;: &#34;gpt-6-luna&#34;
	},
	&#34;disableClaudeAiConnectors&#34;: true,
	&#34;modelSettings&#34;: {
		&#34;gpt-6.1-sol&#34;: {
			&#34;effortLevel&#34;: &#34;medium&#34;
		}
	}
}
```

This is an excerpt. The helper also installs the full picker and a correctly structured `SessionStart` hook. Merge settings rather than replacing the whole file with the excerpt.

If your network requires an HTTP proxy, keep your existing working `HTTPS_PROXY`, `HTTP_PROXY`, and `NO_PROXY` settings. `NODE_USE_ENV_PROXY=1` made the tested Node runtime honor them. Do not copy my network&#39;s proxy address. Keep `127.0.0.1` and `localhost` outside that upstream proxy route.

### Restart the proxy with the new environment

A running process keeps its original environment. Editing `OPENAI_API_KEY` or `GPTCC_AUTH_TOKEN` in a JSON file does not update the existing gptcc process.

Wait until other gptcc sessions are idle before restarting this shared local proxy. Then run:

```bash
curl --noproxy &#39;*&#39; --fail --show-error --silent \
  -X POST http://127.0.0.1:52532/shutdown
```

If no proxy is running, there is nothing to shut down. A connection-refused error in that case is different from a model or authentication failure.

Start the hook with the settings environment. This command does not print the credential:

```bash
python3 - &lt;&lt;&#39;PY&#39;
import json
import os
from pathlib import Path
import shutil
import subprocess

settings = json.loads((Path.home() / &#39;.claude/settings.json&#39;).read_text())
env = {**os.environ, **settings[&#39;env&#39;]}
env.pop(&#39;OPENAI_API_KEY&#39;, None)
package = Path(shutil.which(&#39;gptcc&#39;)).resolve().parent.parent
hook = package / &#39;plugin/hooks/start-proxy.mjs&#39;
assert hook.is_file(), hook
subprocess.run([shutil.which(&#39;node&#39;), str(hook)], env=env, check=True)
PY
```

After the detached process has started, check it:

```bash
curl --noproxy &#39;*&#39; --fail --show-error --silent \
  http://127.0.0.1:52532/health | python3 -m json.tool
```

The observed health response was:

```json
{
	&#34;status&#34;: &#34;ok&#34;,
	&#34;proxy&#34;: &#34;gptcc&#34;,
	&#34;version&#34;: &#34;2.5.3&#34;,
	&#34;features&#34;: {
		&#34;bedrockInvoke&#34;: true,
		&#34;apiKeyFallback&#34;: false,
		&#34;authRequired&#34;: true
	}
}
```

`apiKeyFallback: false` confirms that this process has not selected its API-key backend. `authRequired: true` confirms that the local proxy requires its own credential. `bedrockInvoke: true` advertises an available proxy endpoint; it does not mean Claude Code is using that transport.

Exit any older Claude session with `/exit`, then run `claude` again. The existing terminal session may still have the old environment.

## Add all eight GPT models to /model

The first attempt put Sol behind the Sonnet alias and Terra in the single custom slot. Sol could be the selected model without appearing as the explicit picker entry I expected.

For one model, `ANTHROPIC_CUSTOM_MODEL_OPTION` is enough. For the whole list, I used Claude Code&#39;s `modelPicker` setting. Its [documented lineup format](https://code.claude.com/docs/en/settings-reference#modelpicker) accepts rows with model IDs, labels, and descriptions.

The companion `model-picker.json` contains these verified local Codex IDs:

| Model ID | Label in my Codex list |
|---|---|
| `gpt-6.1-sol` | GPT-6.1-Sol |
| `gpt-6-astra` | GPT-6-Astra |
| `gpt-6.1-terra` | GPT-6.1 Terra |
| `gpt-6-sol` | GPT-6-Sol |
| `gpt-6-luna` | GPT-6-Luna |
| `gpt-5.6-sol` | GPT-5.6-Sol |
| `gpt-5.6-terra` | GPT-5.6-Terra |
| `gpt-5.6-luna` | GPT-5.6-Luna |

A display label is not a model ID. Preserve the dots and hyphens in the first column when sending a request.

The helper installs those rows in this structure:

```json
{
	&#34;modelPicker&#34;: {
		&#34;replaceBuiltInOptions&#34;: true,
		&#34;options&#34;: [
			{
				&#34;model&#34;: &#34;gpt-6.1-sol&#34;,
				&#34;label&#34;: &#34;GPT-6.1-Sol&#34;,
				&#34;description&#34;: &#34;Latest workhorse model for coding and everyday work.&#34;
			},
			{
				&#34;model&#34;: &#34;gpt-6-astra&#34;,
				&#34;label&#34;: &#34;GPT-6-Astra&#34;,
				&#34;description&#34;: &#34;Frontier intelligence for the most demanding work.&#34;
			}
		]
	}
}
```

That excerpt shows two rows; the downloadable file contains all eight. `replaceBuiltInOptions: true` removes the unrelated built-in lineup from this menu while retaining **Default**. It does not implement access control or remove a model from a provider.

Restart Claude Code, enter `/model`, and inspect the list. I verified all eight rows in the actual menu. I sent end-to-end requests through Sol, not through every model in the list.

## Make the selector&#39;s Default entry use Sol, medium

I initially solved the wrong part of this request. Setting:

```json
{
	&#34;model&#34;: &#34;gpt-6.1-sol&#34;
}
```

selected Sol at startup. It did not change what the selector&#39;s **Default (recommended)** row meant. That row still said:

```text
1. Default (recommended)  Use the default model (currently gpt-6-astra[1m])
```

The final configuration sets:

```json
{
	&#34;env&#34;: {
		&#34;ANTHROPIC_DEFAULT_MODEL&#34;: &#34;gpt-6.1-sol&#34;
	},
	&#34;modelSettings&#34;: {
		&#34;gpt-6.1-sol&#34;: {
			&#34;effortLevel&#34;: &#34;medium&#34;
		}
	}
}
```

I removed the top-level `model` override to let the default apply. I also briefly tried the literal JSON value `&#34;model&#34;: &#34;default&#34;`; in this installed build it appeared as a custom model named `default`. Selecting the real Default row in the UI removed that override and selected Sol correctly.

The verified picker text became:

```text
1. Default (recommended)  Use the default model (currently GPT-6.1-Sol)
                         Set by ANTHROPIC_DEFAULT_MODEL
```

The effort control showed `Medium effort`. A fresh launch then showed:

```text
GPT-6.1-Sol with medium effort
```

A later explicit choice saved with `/model` can override the startup selection. That does not change the target of the Default row. I verified the row itself rather than inferring its behavior from the startup header.

## What failed, and what fixed it

These were separate failures. A working proxy did not prove that Claude Code had selected the right identity, transport, or picker default.

### gptcc was installed, but Claude settings were missing

The first status check reported:

```text
Proxy:    running (port 52532)
Version:  2.5.3
Auth:     valid
Settings: URL=missing  Picker=missing
```

The process and OAuth login already existed. Claude&#39;s user settings still selected `opus`. Running setup restored routing settings, but I still had to select an available GPT model and configure gateway authentication.

To inspect the non-secret state:

```bash
GPTCC_NO_UPDATE=1 gptcc status
```

Do not paste the whole settings or OAuth file into a public issue. Print only the fields needed for the diagnosis.

### An inherited API key selected the wrong backend

The shell contained `OPENAI_API_KEY`. gptcc&#39;s health endpoint initially reported:

```json
{
	&#34;apiKeyFallback&#34;: true,
	&#34;authRequired&#34;: false
}
```

In the installed proxy, a nonempty API key selects the OpenAI API path. My goal was to use the existing ChatGPT login. I cleared the variable for the proxy process, added an empty override to Claude&#39;s environment, and restarted the proxy.

This changed `apiKeyFallback` to `false`. I did not delete the key from the user&#39;s shell profile or alter other tools that might use it.

The generic `API Usage Billing` text in Claude&#39;s header is not evidence of an OpenAI API charge. It describes Claude&#39;s gateway-authentication mode. I used the proxy&#39;s actual backend flag and request result to check which route was active.

### The proxy could not reach ChatGPT

The first GPT smoke test failed with:

```text
[upstream:codex] Codex fetch: fetch failed
```

The existing HTTP proxy was reachable, but this Node process had not enabled environment-proxy support. A read-only request with `node --use-env-proxy` reached the ChatGPT endpoint and received HTTP 401. That response proved network reachability, not successful authentication.

Starting gptcc with `NODE_USE_ENV_PROXY=1` fixed the connection in this environment. Preserve the normal loopback route to `127.0.0.1:52532`; only the upstream connection needs the external network proxy.

A `fetch failed` message alone does not prove a particular filtering mechanism. Check the proxy connection, DNS, and TLS before changing authentication.

### gptcc&#39;s bundled GPT-5.4 test used an unavailable model

Once networking worked, `gptcc hello` reached the backend and failed differently:

```text
The &#39;gpt-5.4&#39; model is not supported when using Codex with a ChatGPT account.
```

The tested gptcc package still hard-coded `gpt-5.4-auto` in its hello command, resolving to `gpt-5.4`. My local Codex model list contained the GPT-6 and GPT-5.6 IDs above. A request with `gpt-6.1-sol` succeeded.

This was an observed rejection for this account and backend at that time. It was not evidence that ChatGPT authentication was broken or that every account rejects that older model.

I left the npm package&#39;s source unchanged. For this version, I used the model-specific verification script below instead of treating its bundled hello command as authoritative.

### --multi-slot enabled a transport Claude Code rejected

The all-GPT picker option initially looked convenient:

```bash
gptcc setup --multi-slot
```

It enabled Bedrock mode. The actual Claude Code test then failed with:

```text
Bedrock streaming response has content-type &#34;text/event-stream&#34;;
expected &#34;application/vnd.amazon.eventstream&#34;.
```

The proxy&#39;s advertised Bedrock endpoint did not satisfy this client&#39;s streaming expectation. I removed these keys from the Claude environment:

```text
CLAUDE_CODE_USE_BEDROCK
CLAUDE_CODE_SKIP_BEDROCK_AUTH
ANTHROPIC_BEDROCK_BASE_URL
```

The native messages route plus `modelPicker` gave me the GPT list without that transport. I did not suppress the client&#39;s content-type check.

### The startup plugin was not actually registered

Setup reported a fallback installation under `~/.claude/plugins/gptcc`, but `claude plugin list` did not list gptcc as installed. The local validation command also reported that the bundled hook entries were ignored because they lacked the expected `hooks` array.

I used the installed startup helper directly from a user-level `SessionStart` hook. The required nesting is:

```json
{
	&#34;hooks&#34;: {
		&#34;SessionStart&#34;: [
			{
				&#34;hooks&#34;: [
					{
						&#34;type&#34;: &#34;command&#34;,
						&#34;command&#34;: &#34;&lt;absolute-command-for-the-gptcc-startup-helper&gt;&#34;,
						&#34;timeout&#34;: 10
					}
				]
			}
		]
	}
}
```

The configuration helper generates that command with the installed Node and package paths. The startup helper detaches the proxy process. Running only the shell launcher directly from the automation process did not leave a surviving proxy in my test; invoking the Node startup helper did.

The `gptcc doctor` command also initially reported that Claude was missing. It searched a few fixed paths and missed the executable under the Node installation. `command -v claude` found the real binary. For that diagnostic, pass its supported override:

```bash
CLAUDE_BINARY=&#34;$(command -v claude)&#34; GPTCC_NO_UPDATE=1 gptcc doctor
```

A warning from the package&#39;s plugin-registration check can still reflect the fallback arrangement. The direct hook and real request are the checks for the setup used here.

### Selecting Sol did not remove the account-hold error

This was the misleading failure:

```text
Your account is on hold and can&#39;t use Claude Code.
View details or appeal: https://claude.ai/restricted
```

At that point, a direct GPT request through gptcc already worked. The full Claude Code invocation still failed. The local proxy log showed no corresponding native GPT request from that attempt.

I first treated the hold as a complete blocker. That diagnosis was incomplete. Claude Code was still using the saved claude.ai subscription identity because I had supplied only the gateway URL.

The supported [gateway credential mechanism](https://code.claude.com/docs/en/llm-gateway-connect#conflicts-with-an-existing-login) supplied the missing part. I generated a credential for my own local proxy, set matching `ANTHROPIC_AUTH_TOKEN` and `GPTCC_AUTH_TOKEN` values, and restarted both processes. The proxy accepts that bearer credential and checks it locally. Its upstream request then uses the separate ChatGPT login.

The next full Claude Code test succeeded, including a tool call. **This did not remove or resolve the Anthropic account hold.** Anthropic account access still requires the provider&#39;s own resolution process. The working GPT session uses the separate gateway and ChatGPT credentials.

### Gateway authentication produced a connector banner

After the request worked, Claude printed:

```text
claude.ai connectors are disabled because ANTHROPIC_API_KEY or another
 auth source is set and takes precedence over your claude.ai login
```

Unsetting the gateway credential would have restored the earlier authentication problem. I explicitly disabled the unavailable connectors instead:

```json
{
	&#34;disableClaudeAiConnectors&#34;: true
}
```

A new Claude process no longer printed that banner, and Sol still responded. This setting controls the claude.ai connectors Claude Code fetches itself; it does not disable explicitly configured local MCP servers. See the [connector setting reference](https://code.claude.com/docs/en/settings-reference#disableclaudeaiconnectors).

## Add the Codex quota to the same status-bar row

I wanted the status bar to resemble my Codex configuration. Its selected fields were:

```toml
[tui]
status_line = [
	&#34;model-with-reasoning&#34;,
	&#34;current-dir&#34;,
	&#34;thread-name&#34;,
	&#34;approval-mode&#34;,
	&#34;context-used&#34;,
	&#34;five-hour-limit&#34;,
	&#34;used-tokens&#34;
]
status_line_use_colors = true
```

I kept the existing Powerlevel10k-style Claude bar, added the session name and reported token count, and fetched quota through Codex&#39;s `account/rateLimits/read` RPC. The [Codex app-server documentation](https://learn.chatgpt.com/docs/app-server) describes that read operation. It does not require a model inference request.

![Claude Code model, medium effort, five-hour usage, weekly usage, and reset times on one status-bar row](statusline.png &#34;Captured startup and status-line text. Percentages are quota consumed, not quota remaining. The reset times use this machine&#39;s local timezone. This capture is a point-in-time observation, not a fixed quota value.&#34;)

The final row included:

```text
GPT-6.1-Sol · medium | Codex 5h 73% ↻19:10 | 7d 11% ↻Fri 14:10 | tok 0
```

The screenshot reproduces the observed text with plain separators for readability. The live bar uses Powerline separators and colors.

### Keep account quota separate from session token counts

The status bar has two data sources:

| Field | Source and meaning |
|---|---|
| Model and effort | Claude&#39;s active model and session effort |
| Directory and session name | Claude&#39;s status-line input |
| Approval mode | Claude&#39;s existing footer, such as `auto mode on` |
| Context percentage | Claude&#39;s reported context estimate |
| `tok` | Claude&#39;s reported current-context input and output token total |
| `Codex 5h` | Consumed percentage of the account&#39;s five-hour Codex quota |
| `7d` | Consumed percentage of the account&#39;s weekly Codex quota |
| `↻` time | The corresponding reset timestamp in the local timezone |

These token figures are not Codex&#39;s separate conversation history and are not an account-wide lifetime total. gptcc 2.5.3 did not report complete input-token accounting in the requests I inspected. Claude&#39;s context estimate can therefore be incomplete. I did not invent missing input tokens or call that estimate exact.

The quota helper reads the `codex` bucket, checks that the windows are 300 and 10,080 minutes, and uses the returned percentages and reset epochs. It refreshes in a detached process at most once per minute. The status bar reads a local cache immediately. The helper also serializes refreshes so several Claude sessions do not launch duplicate requests.

A `~` after the window label means the last successful quota read is more than two minutes old. `--` means the window is unavailable or its reset time has passed. The helper does not turn an expired cached percentage into a fabricated zero.

Both windows and reset times stay on the **same row as the model and effort**. At narrower widths, the bar abbreviates effort and drops lower-priority details before quota. I checked 80-column and 140-column output. A terminal too narrow for the model and both quota windows cannot display all of them at once.

### Install the optional status bar

Download these files into the same working directory:

- [statusline-p10k.sh](statusline-p10k.sh)
- [codex-quota.py](codex-quota.py)
- [test-codex-status.py](test-codex-status.py)

The bar uses Bash, Python 3, `jq`, Git, and GNU `date`. The supplied version was tested on Linux. Its `date -d` reset formatting needs adjustment on macOS. A Nerd Font renders the directory and Powerline glyphs used by the existing style.

Back up an existing status script before replacing it:

```bash
mkdir -p ~/.claude/backups
if [ -f ~/.claude/statusline-p10k.sh ]; then
	cp -p ~/.claude/statusline-p10k.sh \
	  ~/.claude/backups/statusline-p10k.sh.before-codex-usage
fi
cp statusline-p10k.sh codex-quota.py test-codex-status.py ~/.claude/
python3 ~/.claude/codex-quota.py --refresh
python3 ~/.claude/test-codex-status.py
```

Merge this entry into `~/.claude/settings.json`:

```json
{
	&#34;statusLine&#34;: {
		&#34;type&#34;: &#34;command&#34;,
		&#34;command&#34;: &#34;bash ~/.claude/statusline-p10k.sh&#34;,
		&#34;padding&#34;: -2,
		&#34;refreshInterval&#34;: 5
	}
}
```

The five-second UI refresh reuses the cache. It does not make an account request every five seconds. The helper launches `codex app-server` for quota reads and removes an inherited `OPENAI_API_KEY` from that child process. It does not print or cache OAuth tokens.

The cache is `~/.cache/claude-codex-status/quota.json`, or the corresponding location under `XDG_CACHE_HOME`. If the account changes, remove that quota cache and refresh it before relying on the displayed percentages.

Claude&#39;s [status-line documentation](https://code.claude.com/docs/en/statusline) describes its JSON input and refresh behavior. The bar preserves the existing provider-specific Claude quota path when the active model is not GPT.

## Verify the whole session instead of only the proxy

![Successful gateway authentication checks and a two-turn Claude Code file-read test](verification.png &#34;Actual output from verify-gptcc.py. The test uses a temporary file and permits only the Read tool.&#34;)

A healthy `/health` endpoint proves that a process is listening. A direct GPT response proves that the bridge can reach that model. Neither proves that Claude Code is using the expected authentication route and can complete tool calls.

Download [verify-gptcc.py](verify-gptcc.py), inspect it, and run:

```bash
python3 verify-gptcc.py
```

The observed output was:

```text
PASS: local gateway requires authentication; API-key fallback is disabled.
PASS: unauthenticated model request returns HTTP 401.
Model: GPT-6.1 Sol
Reply: gptcc tool test passed
Turns: 2
PASS: full Claude Code session, Read tool, and connector-banner check.
```

The script creates a temporary file, starts a nonpersistent Claude Code session, and asks it to read that file. It checks the response, model usage entry, number of turns, authentication requirement, and absence of the connector banner. It does not test file writes, shell execution, compaction, images, or every GPT model.

The [saved verification output](verification.txt) is included with this post. The configuration helper also has an offline check:

```bash
python3 test-configure-gptcc.py
```

It checks that repeated configuration converges, preserves unrelated settings, keeps the paired token values equal, and installs eight model rows without a top-level model override.

## What to check after an upgrade

The parts most likely to drift are the model list, startup-hook registration, authentication environment, and streaming compatibility. After updating gptcc or Claude Code, check:

1. `gptcc status` still reports the intended URL and model.
2. `/health` still shows `apiKeyFallback: false` and `authRequired: true`.
3. The `/model` Default row still names Sol, with medium effort selected.
4. A real Claude Code tool call still succeeds.
5. The status bar still obtains quota from Codex rather than showing a stale cache as current.

Running `gptcc setup` again can rewrite routing settings and reintroduce package defaults. Save your working settings first. A backup now contains the local gateway credential, so protect backups as well as the active file.

To undo a change, restore the corresponding settings or status-script backup and restart the affected process. Do not delete `~/.codex/auth.json` as routine gptcc cleanup; the Codex CLI uses that login too.

All tokens and account identifiers are omitted from this post and its figures. The only IP address shown is the local loopback gateway. The eight picker rows were inspected, Sol completed the tool test, and quota was read successfully. Full behavior across all models remains outside this verification.

## References and companion files

- [gptcc upstream repository](https://github.com/joungminsung/gptcc)
- [Connect Claude Code to an LLM gateway](https://code.claude.com/docs/en/llm-gateway-connect)
- [Claude Code model configuration](https://code.claude.com/docs/en/model-config)
- [Claude Code settings reference](https://code.claude.com/docs/en/settings-reference)
- [Claude Code status lines](https://code.claude.com/docs/en/statusline)
- [Codex app-server protocol](https://learn.chatgpt.com/docs/app-server)
- [Configuration helper](configure-gptcc.py), [model list](model-picker.json), and [configuration check](test-configure-gptcc.py)
- [Status script](statusline-p10k.sh), [quota reader](codex-quota.py), and [status tests](test-codex-status.py)
- [End-to-end check](verify-gptcc.py) and [captured verification output](verification.txt)
- [Figure renderer](render-figures.py). Requires Pillow and the DejaVu fonts used in this capture.


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-11-13-gptcc-chatgpt-models-in-claude-code/  


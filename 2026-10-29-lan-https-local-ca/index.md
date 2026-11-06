# Screen capture on a LAN web app needs https, and macOS refuses a lazy self-signed certificate


My team&#39;s internal portal runs on plain http on the LAN, at `http://192.168.1.82:8888`. I wanted its
note editor to grab a screenshot of another window straight from the browser, Flameshot-style, with
`getDisplayMedia()`. On that address the API isn&#39;t there at all: **browsers only offer screen capture
in a secure context, and an http page on a LAN IP is not one.**

The fix is https next to http, with a certificate signed by a small local CA that each computer trusts
once. My first attempt, the usual one-line self-signed `openssl req -x509`, made the wrong kind of
certificate: a CA certificate with no `serverAuth` usage, which Apple&#39;s rules reject.

&lt;!--more--&gt;

## The wall: no secure context, no `getDisplayMedia`

MDN is blunt about both conditions on
[`getDisplayMedia()`](https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getDisplayMedia):

```text
Secure context: This feature is available only in secure contexts (HTTPS) ...
Transient user activation is required.
```

And [secure contexts](https://developer.mozilla.org/en-US/docs/Web/Security/Secure_Contexts) are
https, `127.0.0.0/8`, `::1` and `localhost`. A LAN IP over http matches none of them. That is also why
the feature worked when I tested on `127.0.0.1` and did nothing on the real address: **loopback counts
as secure, the LAN IP doesn&#39;t.**

I checked the http case from a headless Chrome (more on how below). `isSecureContext` was false and
`navigator.mediaDevices?.getDisplayMedia` was missing:

```text
PASS http page by name is not a secure context, no getDisplayMedia
```

Other ways around it, and why I didn&#39;t take them:

- Chrome&#39;s `--unsafely-treat-insecure-origin-as-secure=http://192.168.1.82:8888` flag works, but every
  colleague would have to set it in every browser.
- An SSH tunnel to `localhost` works for me and nobody else.

So: serve https.

## https beside http in Tornado

The portal is one Tornado process. I kept http on its port, untouched. Scripts and bookmarks use it,
so there&#39;s no redirect and no HSTS. Three new options, off by default:

`local.conf` (this machine):

```python
ssl_port = 8889
certfile = &#34;/home/william/git/SnailPortal2/run/tls.crt&#34;
keyfile = &#34;/home/william/git/SnailPortal2/run/tls.key&#34;
```

The usual 8443 was already taken here by something else:

```bash
ss -ltn | grep &#34;:8443 &#34;
```

```text
LISTEN  0        4096             0.0.0.0:8443           0.0.0.0:*
LISTEN  0        4096                [::]:8443              [::]:*
```

`snailportal/__main__.py` builds the TLS context once, before anything else starts, so a bad file stops
startup with the reason instead of failing on the first request:

```python
def tls_context(certfile: str, keyfile: str) -&gt; ssl.SSLContext:
    &#34;&#34;&#34;The https listener&#39;s TLS context; exits with the reason when a file is missing or bad.&#34;&#34;&#34;
    if not (certfile and keyfile):
        raise SystemExit(&#34;--ssl_port needs --certfile and --keyfile&#34;)
    ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    try:
        ctx.load_cert_chain(certfile, keyfile)
    except OSError as e:  # ssl.SSLError too
        raise SystemExit(f&#34;--ssl_port: cannot load {certfile} / {keyfile}: {e}&#34;) from None
    return ctx
```

and listens twice with the same app:

```python
app.listen(options.port, address=options.address)
if tls:
    app.listen(options.ssl_port, address=options.address, ssl_options=tls)
```

```text
SnailPortal listening on http://192.168.1.82:8888
SnailPortal listening on https://192.168.1.82:8889
```

Nothing else on the server changed. The cookies have no `secure` flag, so they work on both. The
page&#39;s WebSocket already picked its scheme from the page:

```js
const proto = location.protocol === &#34;https:&#34; ? &#34;wss&#34; : &#34;ws&#34;;
```

## First try: the one-line self-signed certificate

This is the line everyone copies, with the IP in `subjectAltName` because Chrome ignores the common
name:

```bash
openssl req -x509 -newkey rsa:2048 -nodes -days 825 -keyout run/tls.key -out run/tls.crt \
    -subj &#34;/CN=snailportal&#34; -addext &#34;subjectAltName=IP:192.168.1.82,DNS:localhost,IP:127.0.0.1&#34;
```

It serves, and any browser shows the &#34;not private&#34; warning as expected:

```text
subject=CN = snailportal
Verify return code: 18 (self-signed certificate)
```

Then I looked at what it actually is:

```bash
openssl x509 -in run/tls.crt -noout -text | grep -A1 -E &#34;Basic Constraints|Key Usage|Extended Key|Subject Alternative&#34;
```

```text
            X509v3 Basic Constraints: critical
                CA:TRUE
            X509v3 Subject Alternative Name:
                IP Address:192.168.1.82, DNS:localhost, IP Address:127.0.0.1
```

**`req -x509` with the default config makes a CA certificate**, and there is no key usage or extended
key usage at all. Apple&#39;s
[Requirements for trusted certificates in iOS 13 and macOS 10.15](https://support.apple.com/en-us/103769)
say a TLS server certificate must have the `id-kp-serverAuth` extended key usage, must be valid for
825 days or fewer, and must carry the name in `subjectAltName`, and that &#34;connections to TLS servers
violating these new requirements will fail&#34;. I didn&#39;t get to watch it fail on a Mac, but a
certificate that breaks a documented rule isn&#39;t worth shipping to find out.

## A local CA that can only vouch for this address

What [mkcert](https://github.com/FiloSottile/mkcert) does, in a dozen lines of openssl. A CA made once,
and a server certificate it signs, the right shape for a server. Computers trust the CA once. The server
certificate can be renewed as often as needed without anyone importing anything again.

`scripts/tls-cert.sh`:

```bash
#!/usr/bin/env bash
# The https listener&#39;s certificate (ssl_port, certfile, keyfile in local.conf): a small local
# certificate authority, made once, signs a certificate for the portal&#39;s LAN address. Trust the CA
# once per computer and the https address opens without a warning; it can vouch only for these
# addresses (nameConstraints), so trusting it can&#39;t be abused for other sites.
#
#   scripts/tls-cert.sh 192.168.1.82   # run/tls-ca.crt (&#43; .key, kept when present), run/tls.crt &#43; run/tls.key
set -euo pipefail

IP=&#34;${1:?usage: scripts/tls-cert.sh &lt;LAN IP of the portal&gt;}&#34;
RUN=&#34;$(cd &#34;$(dirname &#34;${BASH_SOURCE[0]}&#34;)/..&#34; &amp;&amp; pwd)/run&#34;
mkdir -p &#34;$RUN&#34;
umask 077 # the keys readable by this user only

if [[ ! -f &#34;$RUN/tls-ca.key&#34; ]]; then
    openssl req -x509 -newkey rsa:2048 -nodes -days 3650 -subj &#34;/CN=SnailPortal local CA&#34; \
        -keyout &#34;$RUN/tls-ca.key&#34; -out &#34;$RUN/tls-ca.crt&#34; \
        -addext &#34;keyUsage=critical,keyCertSign,cRLSign&#34; \
        -addext &#34;nameConstraints=permitted;IP:$IP/255.255.255.255,permitted;IP:127.0.0.1/255.255.255.255,permitted;DNS:localhost&#34;
fi
# macOS refuses a server certificate without serverAuth, or valid for over 825 days.
openssl req -newkey rsa:2048 -nodes -subj &#34;/CN=$IP&#34; -keyout &#34;$RUN/tls.key&#34; -out &#34;$RUN/tls.csr&#34;
openssl x509 -req -in &#34;$RUN/tls.csr&#34; -CA &#34;$RUN/tls-ca.crt&#34; -CAkey &#34;$RUN/tls-ca.key&#34; -CAcreateserial -days 825 \
    -out &#34;$RUN/tls.crt&#34; -extfile &lt;(printf &#39;%s\n&#39; &#34;basicConstraints=critical,CA:FALSE&#34; \
        &#34;keyUsage=critical,digitalSignature,keyEncipherment&#34; &#34;extendedKeyUsage=serverAuth&#34; \
        &#34;subjectAltName=IP:$IP,DNS:localhost,IP:127.0.0.1&#34;)
rm -f &#34;$RUN/tls.csr&#34;
chmod 644 &#34;$RUN/tls-ca.crt&#34; &#34;$RUN/tls.crt&#34;
openssl verify -CAfile &#34;$RUN/tls-ca.crt&#34; &#34;$RUN/tls.crt&#34;
echo &#34;Trust $RUN/tls-ca.crt on each computer, then restart the portal.&#34;
```

```bash
scripts/tls-cert.sh 192.168.1.82
```

```text
Certificate request self-signature ok
subject=CN = 192.168.1.82
/home/william/git/SnailPortal2/run/tls.crt: OK
Trust /home/william/git/SnailPortal2/run/tls-ca.crt on each computer, then restart the portal.
```

Same `grep` on the new server certificate: it now has what Apple asks for.

```text
            Not After : Jan 31 12:46:43 2029 GMT
        Subject: CN = 192.168.1.82
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Extended Key Usage:
                TLS Web Server Authentication
            X509v3 Subject Alternative Name:
                IP Address:192.168.1.82, DNS:localhost, IP Address:127.0.0.1
```

And the CA is fenced in:

```text
            X509v3 Basic Constraints: critical
                CA:TRUE
            X509v3 Key Usage: critical
                Certificate Sign, CRL Sign
            X509v3 Name Constraints:
                Permitted:
                  IP:192.168.1.82/255.255.255.255
                  IP:127.0.0.1/255.255.255.255
                  ...
```

A few details that matter:

- **`nameConstraints` is the reason this is safe to hand out.** Asking colleagues to trust a root CA
  normally means trusting its key for every site on the internet. This one can only sign for
  `192.168.1.82`, `127.0.0.1` and `localhost`, so even a stolen `tls-ca.key` can&#39;t forge a bank&#39;s
  certificate on a client that enforces the constraint.
- I left `nameConstraints` non-critical. A client that understands it enforces it either way; marking
  it critical only makes a client that doesn&#39;t understand it reject the whole CA.
- The CA lives ten years. The server certificate gets 825 days, the macOS limit. Rerunning the script
  keeps the CA and replaces only the server certificate.
- `umask 077` makes both keys `-rw-------`. Only the two `.crt` files are opened up to 644. `run/` is
  git-ignored.

## Check it the way a browser will

`curl` with the CA as its only trust root verifies the chain, the IP against `subjectAltName` and the
CA&#39;s name constraints. That is what a browser does once the CA is trusted:

```bash
curl -s --noproxy &#39;*&#39; --cacert run/tls-ca.crt https://192.168.1.82:8889/api/health
```

```text
{&#34;status&#34;: &#34;ok&#34;, &#34;version&#34;: &#34;0.1.0&#34;}
```

Without it, against the system store, it refuses (exit 60 is &#34;peer certificate cannot be
authenticated&#34;):

```bash
curl -s --noproxy &#39;*&#39; -o /dev/null https://192.168.1.82:8889/api/health; echo $?
```

```text
60
```

(`--noproxy &#39;*&#39;` because this machine has a proxy in its environment that answers LAN addresses with a
503.)

## Trust the CA once per computer

Copy `run/tls-ca.crt` to the computer (it&#39;s public; only the `.key` files are secret), then:

- **macOS** (Chrome and Safari): double-click the file to add it to Keychain Access, open &#34;SnailPortal
  local CA&#34;, Trust, set &#34;When using this certificate&#34; to **Always Trust**, close and enter your password.
- **Windows** (Chrome, Edge): double-click, Install Certificate, Current User, place it in
  **Trusted Root Certification Authorities**.
- **Firefox** (its own store, on every OS): Settings, Privacy &amp; Security, Certificates, View
  Certificates, Authorities, Import, tick &#34;Trust this CA to identify websites&#34;.
- **Chrome on Linux**: Settings, Privacy and security, Security, Manage certificates, Authorities,
  Import, tick &#34;Trust for identifying websites&#34;.

Restart the browser. To make sure the file that arrived is the one you made, compare fingerprints:

```bash
openssl x509 -in run/tls-ca.crt -noout -fingerprint -sha256
```

## The browser side

With a secure context, the capture itself is short. Two things are easy to get wrong.

**Call it inside the click.** `getDisplayMedia()` needs transient user activation, so the editor&#39;s
Screenshot button opens the dialog and calls capture in the same click handler, before any `await`
that could outlive the gesture. The browser&#39;s window/screen picker comes up straight away.

**Wait for a real frame.** A window capture&#39;s first frame can still be blank when `play()` resolves:

```js
stream = await navigator.mediaDevices.getDisplayMedia({ video: true, audio: false, selfBrowserSurface: &#34;exclude&#34;, surfaceSwitching: &#34;exclude&#34; });
const video = document.createElement(&#34;video&#34;);
video.muted = true;
video.srcObject = stream;
await video.play();
// A window&#39;s first frame can be blank: wait for one to be presented (0.5 s at most).
await new Promise((ok) =&gt; { video.requestVideoFrameCallback?.(ok); setTimeout(ok, 500); });
if (opened) show(await createImageBitmap(video)); // dropped if the dialog closed meanwhile
// ...and in finally: stream.getTracks().forEach((t) =&gt; t.stop());
```

`selfBrowserSurface: &#34;exclude&#34;` keeps the portal&#39;s own tab out of the picker. Stopping every track
right after the grab ends the share, so the capture lasts only as long as one frame takes.

On the http address the dialog can&#39;t capture, so it says why and links to the same page on https
(`https://&lt;host&gt;:&lt;ssl_port&gt;&lt;path&gt;`), opened in a new tab so an unsaved note stays where it is.

One cost of the https address: **an `http://` picture or embedded page inside a note is mixed content
there and won&#39;t load.** The http address still shows it.

## Testing it headless

Three Chrome tricks made this testable without a desktop:

```bash
google-chrome --headless=new --remote-debugging-port=&lt;port&gt; --user-data-dir=&lt;scratch dir&gt; \
    --no-first-run --no-proxy-server \
    --ignore-certificate-errors \
    --use-fake-ui-for-media-stream --use-fake-device-for-media-stream \
    --host-resolver-rules=&#34;MAP snailtest.internal 127.0.0.1&#34;
```

- `--use-fake-ui-for-media-stream --use-fake-device-for-media-stream` answer the picker and hand back
  Chrome&#39;s fake 800×600 video. A real tab or screen source doesn&#39;t start headless
  (`NotReadableError: Could not start video source`), so this tests the code path, not a real window.
- **`127.0.0.1` is a secure context**, so a test portal on loopback can never show the http behaviour.
  `--host-resolver-rules` gives it a name that isn&#39;t loopback: `http://snailtest.internal:8898` is
  plain http and insecure, while still reaching the local test server.
- My first run hung on that name: Chrome sent `snailtest.internal` to the proxy in the environment,
  which had never heard of it. `--no-proxy-server` fixed it.

```text
Error: timed out waiting for document.readyState === &#34;complete&#34; &amp;&amp; (!!document.querySelector(&#34;#username&#34;) || !!document.querySelector(&#34;#dn-add&#34;))
```

With those, against a test instance on http 8898 and https 8453:

```text
PASS https page is a secure context with getDisplayMedia
PASS live WebSocket connects over wss
PASS one click on Screenshot opens the annotator with a captured frame: [800,600]
PASS header capture-again button shown
PASS capture again takes a new frame
PASS a box drawn on the capture
PASS Insert uploads and puts a figure in the details
PASS the picture is served as a PNG over https
PASS http page by name is not a secure context, no getDisplayMedia
PASS empty state links to the https address with this path: {&#34;shown&#34;:true,&#34;href&#34;:&#34;https://snailtest.internal:8453/&#34;}
PASS no capture buttons on http
PASS no page errors: []
12/12 passed
```

What this doesn&#39;t cover: a capture of a real window, importing the CA on a real Mac, and whether port
8889 gets through to other machines on the LAN.

## Takeaways

1. **`getDisplayMedia()` needs a secure context.** https, or loopback. A LAN IP over http is neither,
   which is why &#34;it works on localhost&#34; means nothing here.
2. **Add https; keep http.** A second `listen()` with an `SSLContext`, no redirect. WebSockets that
   follow `location.protocol` need no change.
3. **The one-line `openssl req -x509` makes a CA certificate.** A server certificate wants
   `CA:FALSE`, `extendedKeyUsage=serverAuth`, the name in `subjectAltName`, and 825 days or fewer for
   Apple.
4. **Use a local CA with `nameConstraints`.** Trust it once per computer, renew the server certificate
   freely, and nobody is trusting a key that could sign for other sites.
5. **Test the insecure branch through a hostname.** `127.0.0.1` is secure by definition;
   `--host-resolver-rules` gives you an insecure name for the same server.

## References

- [MDN: `MediaDevices.getDisplayMedia()`](https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getDisplayMedia)
- [MDN: Secure contexts](https://developer.mozilla.org/en-US/docs/Web/Security/Secure_Contexts)
- [Apple: Requirements for trusted certificates in iOS 13 and macOS 10.15](https://support.apple.com/en-us/103769)


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-10-29-lan-https-local-ca/  


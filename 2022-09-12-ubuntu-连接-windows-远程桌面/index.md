# Ubuntu 连接 Windows 远程桌面


在 `Ubuntu` 机器连接远程 `Windows` 虚拟机

&lt;!--more--&gt;

## 安装 FreeRDP

```bash
sudo apt-get install -y freerdp2-x11

xfreerdp --help

FreeRDP - A Free Remote Desktop Protocol Implementation
See www.freerdp.com for more information

Usage: xfreerdp [file] [options] [/v:&lt;server&gt;[:port]]

Syntax:
    /flag (enables flag)
    /option:&lt;value&gt; (specifies option with value)
    &#43;toggle -toggle (enables or disables toggle, where &#39;/&#39; is a synonym of &#39;&#43;&#39;)

    /a:&lt;addin&gt;[,&lt;options&gt;]            Addin
    /action-script:&lt;file-name&gt;        Action script
    /admin                            Admin (or console) session
    &#43;aero                             Enable desktop composition
    /app:&lt;path&gt; or ||&lt;alias&gt;          Remote application program
    /app-cmd:&lt;parameters&gt;             Remote application command-line parameters
    /app-file:&lt;file-name&gt;             File to open with remote application
    /app-guid:&lt;app-guid&gt;              Remote application GUID
    /app-icon:&lt;icon-path&gt;             Remote application icon for user interface
    /app-name:&lt;app-name&gt;              Remote application name for user interface
    /app-workdir:&lt;workspace path&gt;     Remote application workspace path
    /assistance:&lt;password&gt;            Remote assistance password
    /auto-request-control             Automatically request remote assistance
                                      input control
    &#43;async-channels                   Enable Asynchronous channels
                                      (experimental)
    &#43;async-input                      Enable Asynchronous input
    &#43;async-update                     Enable Asynchronous update
    /audio-mode:&lt;mode&gt;                Audio output mode
    &#43;auth-only                        Enable Authenticate only
    -authentication                   Disable Authentication (experimental)
    &#43;auto-reconnect                   Enable Automatic reconnection
    /auto-reconnect-max-retries:&lt;retries&gt;
                                      Automatic reconnection maximum retries, 0
                                      for unlimited [0,1000]
    &#43;bitmap-cache                     Enable bitmap cache
    /bpp:&lt;depth&gt;                      Session bpp (color depth)
    /buildconfig                      Print the build configuration
    /cert:[deny,ignore,name:&lt;name&gt;,tofu,fingerprint:&lt;hash&gt;:&lt;hash as hex&gt;
          [,fingerprint:&lt;hash&gt;:&lt;another hash&gt;]]
                                      Certificate accept options. Use with care!
                                      * deny         ... Automatically abort
                                      connection if the certificate does not
                                      match, no user interaction.           *
                                      ignore       ... Ignore the certificate
                                      checks altogether (overrules all other
                                      options)                           * name
                                             ... Use the alternate &lt;name&gt;
                                      instead of the certificate subject to
                                      match locally stored certificates * tofu
                                            ... Accept certificate
                                      unconditionally on first connect and deny
                                      on subsequent connections if the
                                      certificate does not match * fingerprints
                                      ... A list of certificate hashes that are
                                      accepted unconditionally for a connection
    /cert-deny                        [deprecated, use /cert:deny] Automatically
                                      abort connection for any certificate that
                                      can not be validated.
    /cert-ignore                      [deprecated, use /cert:ignore] Ignore
                                      certificate
    /cert-name:&lt;name&gt;                 [deprecated, use /cert:name:&lt;name&gt;]
                                      Certificate name
    /cert-tofu                        [deprecated, use /cert:tofu] Automatically
                                      accept certificate on first connect
    /client-build-number:&lt;number&gt;     Client Build Number sent to server
                                      (influences smartcard behaviour, see
                                      [MS-RDPESC])
    /client-hostname:&lt;name&gt;           Client Hostname to send to server
    -clipboard                        Disable Redirect clipboard
    /codec-cache:[rfx|nsc|jpeg]       Bitmap codec cache
    -compression                      Disable compression
    /compression-level:&lt;level&gt;        Compression level (0,1,2)
    &#43;credentials-delegation           Enable credentials delegation
    /d:&lt;domain&gt;                       Domain
    -decorations                      Disable Window decorations
    /disp                             Display control
    /drive:&lt;name&gt;,&lt;path&gt;              Redirect directory &lt;path&gt; as named share
                                      &lt;name&gt;. Hotplug support is enabled with
                                      /drive:hotplug,*. This argument provides
                                      the same function as &#34;Drives that I plug
                                      in later&#34; option in MSTSC.
    &#43;drives                           Enable Redirect all mount points as shares
    /dvc:&lt;channel&gt;[,&lt;options&gt;]        Dynamic virtual channel
    /dynamic-resolution               Send resolution updates when the window is
                                      resized
    /echo                             Echo channel
    -encryption                       Disable Encryption (experimental)
    /encryption-methods:[40,][56,][128,][FIPS]
                                      RDP standard security encryption methods
    /f                                Fullscreen mode (&lt;Ctrl&gt;&#43;&lt;Alt&gt;&#43;&lt;Enter&gt;
                                      toggles fullscreen)
    -fast-path                        Disable fast-path input/output
    &#43;fipsmode                         Enable FIPS mode
    /floatbar[:sticky:[on|off],default:[visible|hidden],show:
               [always|fullscreen||window]]
                                      floatbar is disabled by default (when
                                      enabled defaults to sticky in fullscreen
                                      mode)
    -fonts                            Disable smooth fonts (ClearType)
    /frame-ack:&lt;number&gt;               Number of frame acknowledgement
    /from-stdin[:force]               Read credentials from stdin. With &lt;force&gt;
                                      the prompt is done before connection,
                                      otherwise on server request.
    /g:&lt;gateway&gt;[:&lt;port&gt;]             Gateway Hostname
    /gateway-usage-method:[direct|detect]
                                      Gateway usage method
    /gd:&lt;domain&gt;                      Gateway domain
    /gdi:sw|hw                        GDI rendering
    /geometry                         Geometry tracking channel
    &#43;gestures                         Enable Consume multitouch input locally
    /gfx[:RFX]                        RDP8 graphics pipeline
    &#43;gfx-progressive                  Enable RDP8 graphics pipeline using progressive
                                      codec
    &#43;gfx-small-cache                  Enable RDP8 graphics pipeline using small cache
                                      mode
    &#43;gfx-thin-client                  Enable RDP8 graphics pipeline using thin client
                                      mode
    &#43;glyph-cache                      Enable Glyph cache (experimental)
    /gp:&lt;password&gt;                    Gateway password
    -grab-keyboard                    Disable Grab keyboard
    /gt:[rpc|http|auto]               Gateway transport type
    /gu:[[&lt;domain&gt;\]&lt;user&gt;|&lt;user&gt;[@&lt;domain&gt;]]
                                      Gateway username
    /gat:&lt;access token&gt;               Gateway Access Token
    /h:&lt;height&gt;                       Height
    -heartbeat                        Disable Support heartbeat PDUs
    /help                             Print help
    &#43;home-drive                       Enable Redirect user home as share
    /ipv6                             Prefer IPv6 AAA record over IPv4 A record
    /jpeg                             JPEG codec support
    /jpeg-quality:&lt;percentage&gt;        JPEG quality
    /kbd:0x&lt;id&gt; or &lt;name&gt;             Keyboard layout
    /kbd-lang:0x&lt;id&gt;                  Keyboard active language identifier
    /kbd-fn-key:&lt;value&gt;               Function key value
    /kbd-list                         List keyboard layouts
    /kbd-lang-list                    List keyboard languages
    /kbd-subtype:&lt;id&gt;                 Keyboard subtype
    /kbd-type:&lt;id&gt;                    Keyboard type
    /load-balance-info:&lt;info-string&gt;  Load balance info
    /log-filters:&lt;tag&gt;:&lt;level&gt;[,&lt;tag&gt;:&lt;level&gt;[,...]]
                                      Set logger filters, see wLog(7) for
                                      details
    /log-level:[OFF|FATAL|ERROR|WARN|INFO|DEBUG|TRACE]
                                      Set the default log level, see wLog(7) for
                                      details
    /max-fast-path-size:&lt;size&gt;        Specify maximum fast-path update size
    /max-loop-time:&lt;time&gt;             Specify maximum time in milliseconds spend
                                      treating packets
    &#43;menu-anims                       Enable menu animations
    /microphone[:[sys:&lt;sys&gt;,][dev:&lt;dev&gt;,][format:&lt;format&gt;,][rate:&lt;rate&gt;,]
                 [channel:&lt;channel&gt;]] Audio input (microphone)
    /monitor-list                     List detected monitors
    /monitors:&lt;id&gt;[,&lt;id&gt;[,...]]       Select monitors to use
    -mouse-motion                     Disable Send mouse motion
    /multimon[:force]                 Use multiple monitors
    &#43;multitouch                       Enable Redirect multitouch input
    &#43;multitransport                   Enable Support multitransport protocol
    -nego                             Disable protocol security negotiation
    /network:[modem|broadband|broadband-low|broadband-high|wan|lan|auto]
                                      Network connection type
    /nsc                              NSCodec support
    &#43;offscreen-cache                  Enable offscreen bitmap cache
    /orientation:[0|90|180|270]       Orientation of display in degrees
    &#43;old-license                      Enable Use the old license workflow (no CAL and
                                      hwId set to 0)
    /p:&lt;password&gt;                     Password
    /parallel[:&lt;name&gt;[,&lt;path&gt;]]       Redirect parallel device
    /parent-window:&lt;window-id&gt;        Parent window id
    &#43;password-is-pin                  Enable Use smart card authentication with
                                      password as smart card PIN
    /pcb:&lt;blob&gt;                       Preconnection Blob
    /pcid:&lt;id&gt;                        Preconnection Id
    /pheight:&lt;height&gt;                 Physical height of display (in
                                      millimeters)
    /play-rfx:&lt;pcap-file&gt;             Replay rfx pcap file
    /port:&lt;number&gt;                    Server port
    -suppress-output                  Disable suppress output when minimized
    &#43;print-reconnect-cookie           Enable Print base64 reconnect cookie after
                                      connecting
    /printer[:&lt;name&gt;[,&lt;driver&gt;]]      Redirect printer device
    /proxy:[&lt;proto&gt;://][&lt;user&gt;:&lt;password&gt;@]&lt;host&gt;:&lt;port&gt;
                                      Proxy settings: override env. var (see
                                      also environment variable below). Protocol
                                      &#34;socks5&#34; should be given explicitly where
                                      &#34;http&#34; is default.
    /pth:&lt;password-hash&gt;              Pass the hash (restricted admin mode)
    /pwidth:&lt;width&gt;                   Physical width of display (in millimeters)
    /rdp2tcp:&lt;executable path[:arg...]&gt;
                                      TCP redirection
    /reconnect-cookie:&lt;base64-cookie&gt; Pass base64 reconnect cookie to the
                                      connection
    /redirect-prefer:&lt;FQDN|IP|NETBIOS&gt;,[...]
                                      Override the preferred redirection order
    /relax-order-checks               Do not check if a RDP order was announced
                                      during capability exchange, only use when
                                      connecting to a buggy server
    /restricted-admin                 Restricted admin mode
    /rfx                              RemoteFX
    /rfx-mode:[image|video]           RemoteFX mode
    /scale:[100|140|180]              Scaling factor of the display
    /scale-desktop:&lt;percentage&gt;       Scaling factor for desktop applications
                                      (value between 100 and 500)
    /scale-device:100|140|180         Scaling factor for app store applications
    /sec:[rdp|tls|nla|ext]            Force specific protocol security
    &#43;sec-ext                          Enable NLA extended protocol security
    -sec-nla                          Disable NLA protocol security
    -sec-rdp                          Disable RDP protocol security
    -sec-tls                          Disable TLS protocol security
    /serial[:&lt;name&gt;[,&lt;path&gt;[,&lt;driver&gt;[,permissive]]]]
                                      Redirect serial device
    /shell:&lt;shell&gt;                    Alternate shell
    /shell-dir:&lt;dir&gt;                  Shell working directory
    /size:&lt;width&gt;x&lt;height&gt; or &lt;percent&gt;%[wh]
                                      Screen size
    /smart-sizing[:&lt;width&gt;x&lt;height&gt;]  Scale remote desktop to window size
    /smartcard[:&lt;str&gt;[,&lt;str&gt;...]]     Redirect the smartcard devices containing
                                      any of the &lt;str&gt; in their names.
    /smartcard-logon                  Activates Smartcard Logon authentication.
                                      (EXPERIMENTAL: NLA not supported)
    /sound[:[sys:&lt;sys&gt;,][dev:&lt;dev&gt;,][format:&lt;format&gt;,][rate:&lt;rate&gt;,]
            [channel:&lt;channel&gt;,][latency:&lt;latency&gt;,][quality:&lt;quality&gt;]]
                                      Audio output (sound)
    /span                             Span screen over multiple monitors
    /spn-class:&lt;service-class&gt;        SPN authentication service class
    /ssh-agent                        SSH Agent forwarding channel
    /t:&lt;title&gt;                        Window title
    -themes                           Disable themes
    /timeout:&lt;time in ms&gt;             Advanced setting for high latency links:
                                      Adjust connection timeout, use if you
                                      encounter timeout failures with your
                                      connection
    /tls-ciphers:[netmon|ma|ciphers]  Allowed TLS ciphers
    /tls-seclevel:&lt;level&gt;             TLS security level - defaults to 1
    -toggle-fullscreen                Disable Alt&#43;Ctrl&#43;Enter to toggle
                                      fullscreen
    /tune:&lt;setting:value&gt;,&lt;setting:value&gt;
                                      [experimental] directly manipulate freerdp
                                      settings, use with extreme caution!
    /tune-list                        Print options allowed for /tune
    /u:[[&lt;domain&gt;\]&lt;user&gt;|&lt;user&gt;[@&lt;domain&gt;]]
                                      Username
    &#43;unmap-buttons                    Enable Let server see real physical pointer
                                      button
    /usb:[dbg,][id:&lt;vid&gt;:&lt;pid&gt;#...,][addr:&lt;bus&gt;:&lt;addr&gt;#...,][auto]
                                      Redirect USB device
    /v:&lt;server&gt;[:port]                Server hostname
    /vc:&lt;channel&gt;[,&lt;options&gt;]         Static virtual channel
    /version                          Print version
    /video                            Video optimized remoting channel
    /vmconnect[:&lt;vmid&gt;]               Hyper-V console (use port 2179, disable
                                      negotiation)
    /w:&lt;width&gt;                        Width
    -wallpaper                        Disable wallpaper
    &#43;window-drag                      Enable full window drag
    /window-position:&lt;xpos&gt;x&lt;ypos&gt;    window position
    /wm-class:&lt;class-name&gt;            Set the WM_CLASS hint for the window
                                      instance
    /workarea                         Use available work area

Examples:
    xfreerdp connection.rdp /p:Pwd123! /f
    xfreerdp /u:CONTOSO\JohnDoe /p:Pwd123! /v:rdp.contoso.com
    xfreerdp /u:JohnDoe /p:Pwd123! /w:1366 /h:768 /v:192.168.1.100:4489
    xfreerdp /u:JohnDoe /p:Pwd123! /vmconnect:C824F53E-95D2-46C6-9A18-23A5BB403532 /v:192.168.1.100
```

## 使用

```bash
xfreerdp /w:1920 /h:1080 /u:&#34;Administrator&#34; /p:xxxxxxxxx /v:10.32.233.100:3389
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2022-09-12-ubuntu-%E8%BF%9E%E6%8E%A5-windows-%E8%BF%9C%E7%A8%8B%E6%A1%8C%E9%9D%A2/  


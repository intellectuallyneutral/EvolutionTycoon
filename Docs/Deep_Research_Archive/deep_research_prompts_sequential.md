# Sequential Deep Research Prompts

Here are the 4 distinct, sequential prompts based on the master prompt. Run them one at a time, feeding the findings from the previous run into the next.

## Prompt 1: Protocol & Architecture
```text
I need an exhaustive technical deep dive into the architecture and communication protocols of Roblox Studio local sync plugins—specifically Rojo (versions 7.4.x and 7.7.0) and Argon 2 (2.0.23). 

Both CLI servers start correctly on Windows (localhost:8000 / 34872) and return 200 OK to standard HTTP requests (curl/PowerShell). However, when the Roblox Studio plugins attempt to connect, the TCP connection is established (FIN_WAIT_2 / ESTABLISHED), but the HTTP/WebSocket request layer times out on the Studio side. The server never logs receiving the API request. Rojo 7.7.0 specifically crashes with a Rust panic: `called Option::unwrap() on a None value in src/web/interface.rs line 45` upon successful WebSocket upgrade.

Please research:
1. The exact handshake sequence and protocol used by Rojo's Studio plugin to communicate with the Rojo CLI server (HTTP vs WebSocket, specific endpoints used).
2. What protocol changes occurred between Rojo 7.4.x and 7.7.0 (especially regarding the WebSocket migration).
3. The exact handshake sequence and protocol used by Argon 2's Studio plugin with its CLI server.
4. Known bugs, limitations, or protocol incompatibilities of Rojo 7.4.1/7.7.0 and Argon 2.0.23 specifically on Windows.

Provide all relevant GitHub issues, PRs, and official documentation links.
```

## Prompt 2: Roblox Studio HttpService & Plugin Networking
```text
Building on our understanding of the Rojo/Argon protocols, I need deep research into Roblox Studio's internal networking, specifically how `HttpService` and plugins handle localhost/loopback connections.

We know the sync plugins use HTTP/WebSocket to talk to localhost servers, but requests from the plugins are timing out while identical requests from PowerShell succeed. 

Please research:
1. How does Roblox Studio's HttpService internally process requests to localhost/127.0.0.1 made by plugins? Does it use a proxy, intercept, or modify them?
2. Are there any known engine bugs, limitations, or restrictions regarding Studio plugins making long-polling or WebSocket requests to localhost?
3. Does the Microsoft Store (UWP/GDK) version of Roblox Studio have different networking isolation, AppContainer restrictions, or loopback exemptions compared to the standard desktop installer?
4. Are there any specific FFlags (Fast Flags) that affect HttpService timeout behavior, WebSocket capabilities, or localhost restrictions for plugins?

Cite Roblox DevForum posts, engine bug reports, and release notes from 2024-2026.
```

## Prompt 3: Windows-Specific Networking Interference
```text
Given the protocols used by the sync plugins and Roblox Studio's HttpService behavior, I need to investigate potential interference from the Windows 11 network stack.

The TCP handshake succeeds, but the application-layer payload (HTTP/WebSocket) is either dropped, buffered indefinitely, or blocked, causing Studio to time out. 

Please research:
1. Can Bitdefender Total Security (specifically the `bdntwrk.exe` WFP driver) silently intercept, buffer, or drop HTTP/WebSocket payloads on established localhost TCP connections, even when the firewall is "disabled" in the UI? 
2. Are there known issues with Windows Developer Mode, ReFS Dev Drives (where the project is hosted), and localhost socket communication?
3. Could Windows Defender Application Guard, SmartScreen, or Windows Filtering Platform (WFP) isolate or block loopback traffic from UWP-adjacent applications (like the MS Store version of Roblox Studio)?
4. Does IPv6 (::1) vs IPv4 (127.0.0.1) resolution in Windows 11 cause silent handshake failures with Rust-based Tokio/Hyper web servers?

Find documentation, Microsoft Learn articles, and GitHub issues detailing similar local development environment blocks on Windows.
```

## Prompt 4: Community Solutions & Definitive Fix
```text
Synthesizing the protocol architecture, Studio HttpService quirks, and Windows network interference, I need to find the definitive community solutions for this specific failure state.

Users of Rojo and Argon on Windows frequently encounter "timeout on connect" or silent failures despite the server running correctly. 

Please research:
1. What exact workarounds, registry edits, firewall rules, or FFlag configurations have the Roblox developer community successfully used to fix "HTTP request timed out" errors for Rojo and Argon?
2. Are there alternative file-syncing tools or methods that bypass the HttpService network limitation entirely (e.g., file-system watchers directly injecting into Studio)?
3. What is the most robust, battle-tested setup for local development (specific Rojo version + specific Studio installer type + specific Windows config) as of 2025/2026?

Provide a step-by-step, verified setup procedure to guarantee a stable connection, citing successful resolutions from the DevForum, GitHub issues, and community discords.
```

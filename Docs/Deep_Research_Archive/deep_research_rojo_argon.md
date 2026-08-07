# Deep Research Prompt: Roblox Studio Local Sync Tool Connectivity (Rojo & Argon)

```
I need an exhaustive technical research synthesis on getting Roblox Studio's local code-sync plugins (Rojo and Argon) reliably connected to their CLI servers on Windows. I have been unable to establish a stable connection despite days of debugging. I need to understand the full architecture, all known failure modes, and every possible fix.

## My Exact Environment
- Windows 11 (Samsung Galaxy Book), Developer Mode enabled, LongPathsEnabled=1
- Roblox Studio installed via Microsoft Store (but runs from AppData\Local\Roblox\Versions\)
- Bitdefender Total Security installed (bdntwrk.exe network filter active)
- Dev Drive (P:\) using ReFS filesystem — project lives at P:\Projects\EvolutionTycoon
- Tools managed via Rokit toolchain manager (~\.rokit\bin\)
- Argon CLI 2.0.23 (argon-rbx) and Rojo 7.4.1 / 7.7.0 tested

## The Core Problem
Both Rojo and Argon servers start correctly and respond to HTTP requests from PowerShell/curl on localhost. However, when the Roblox Studio plugin attempts to connect:
- TCP connections ARE established (confirmed via netstat — Studio PID shows ESTABLISHED to the server PID)
- But the HTTP request layer times out — the server never logs receiving any API request from Studio
- The plugin displays "HTTP request timed out" after ~10-30 seconds
- This happens with both Argon and Rojo, on ports 8000, 34872, and random high ports
- This happens with localhost, 127.0.0.1, and the LAN IP (172.16.0.2)
- This happens with Bitdefender firewall enabled AND disabled
- Rojo 7.7.0 specifically crashes with: `called Option::unwrap() on a None value in src/web/interface.rs line 45` when a WebSocket upgrade to /api/socket/0 succeeds

## What I Need Researched

### 1. Rojo Architecture & Protocol
- Exactly how does the Rojo Studio plugin communicate with the Rojo CLI server? (HTTP? WebSocket? Both? What endpoints, what sequence?)
- What changed between Rojo 7.4.x and 7.7.0 in the server/plugin protocol? (specifically the WebSocket migration)
- What is the exact handshake sequence? (plugin hits /api/rojo first, then what?)
- Is the plugin version embedded in rojo.exe's `plugin install` command always protocol-compatible with that server version?
- What are Rojo 7.4.1's known bugs and limitations on Windows?
- Is there a Rojo version known to be the most stable on Windows with the Microsoft Store version of Studio?

### 2. Argon 2 Architecture & Protocol  
- How does Argon 2's Studio plugin communicate with the Argon CLI server?
- What endpoints does it use? Is it pure HTTP or does it use WebSocket?
- What version combinations of argon CLI + argon plugin are known to work?
- Are there known issues with Argon 2.0.23 on Windows?
- What is the relationship between the argon VS Code extension server and the CLI server?

### 3. Roblox Studio HttpService & Plugin Networking
- How does Roblox Studio's HttpService work internally for plugins making localhost requests?
- Are there known limitations, restrictions, or bugs with Studio plugins making HTTP requests to localhost/127.0.0.1?
- Does Studio's HttpService have any special behavior for loopback addresses vs LAN IPs?
- Does Studio use a proxy or go through any internal network layer that could intercept/modify requests?
- Are there FFlags (Fast Flags) that affect HttpService behavior for plugins?
- Does the Microsoft Store / GDK version of Roblox Studio have different networking behavior than the standalone installer?
- Is there an AppContainer / UWP network isolation issue even though Studio runs from AppData\Local?
- What is Studio's actual HTTP timeout value for plugin requests, and can it be changed?

### 4. Windows-Specific Networking Issues
- Can Bitdefender's bdntwrk.exe WFP (Windows Filtering Platform) driver intercept and silently drop HTTP payloads on established TCP connections to localhost?
- Are there known issues with ReFS Dev Drives and network operations?
- Could Windows Defender Application Guard or SmartScreen affect localhost connections from UWP-adjacent apps?
- Are there registry settings or group policies that could block Roblox Studio from making localhost HTTP requests?
- Could IPv6 vs IPv4 resolution of "localhost" cause silent failures?

### 5. Community Solutions & Workarounds
- What solutions have the Roblox developer community found for "timeout on connect" errors with Rojo and Argon?
- Are there alternative sync tools that avoid the HttpService limitation entirely?
- Is there a way to use Rojo/Argon via file-based sync instead of HTTP?
- What do the Rojo and Argon GitHub issues say about Windows connectivity problems?
- Are there any Roblox engine bugs filed about HttpService localhost failures?

### 6. Definitive Setup Guide
- Provide a step-by-step, verified setup procedure for getting Rojo working on Windows 11 with the Microsoft Store version of Roblox Studio
- Include all prerequisite checks, firewall rules, FFlags, and version compatibility requirements
- Include a diagnostic checklist for when the connection fails

Please cite all sources with URLs. Prioritize information from GitHub issues, official documentation, and DevForum posts from 2024-2026.
```

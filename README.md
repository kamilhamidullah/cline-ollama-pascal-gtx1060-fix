# Cline + Ollama + Qwen 2.5 Coder on Windows 11 / 10
## Pascal Architecture (NVIDIA GTX 1060 6GB / Low VRAM) Stability & Setup Guide

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ollama](https://img.shields.io/badge/Ollama-0.40.16+-blue.svg)](https://ollama.com/)
[![Cline](https://img.shields.io/badge/Cline-4.1.26--WireResponse--Capture-purple.svg)](https://github.com/cline/cline)
[![Tested On](https://img.shields.io/badge/GPU-GTX%201060%206GB%20(Pascal%20cc%206.1)-green.svg)](https://www.nvidia.com/)

> **Why this repository exists:**  
> Running local LLMs like `qwen2.5-coder:7b` with **Cline (VS Code)** and **Ollama** on 6GB VRAM GPUs (especially NVIDIA Pascal generation, such as the GTX 1060) under Windows can be an absolute minefield of silent crashes, 32 repeated `@` characters hallucination loops, system freezes, CUDA runtime toolchain mismatches, and drive capacity exhaustion.
> 
> This repository provides the **complete root-cause diagnostic post-mortem**, the **patched, ready-to-use VSIX extension**, and **1-click installation and startup scripts** so you can run Cline + Qwen smoothly without days of trial, error, and frustration.

---

## Table of Contents
1. [The Hard-Won Findings: Root Cause Diagnostics](#the-hard-won-findings-root-cause-diagnostics)
   - [Bug 1: The Infamous 32 Consecutive '@' Characters Loop](#1-the-infamous-32-consecutive--characters-loop)
   - [Bug 2: NVIDIA GTX 1060 (Pascal cc 6.1) Driver & CUDA Skipping](#2-nvidia-gtx-1060-pascal-cc-61-driver--cuda-skipping)
   - [Bug 3: llama-server Crash (0xc0000409) & Socket Reset (UND_ERR_SOCKET)](#3-llama-server-crash-0xc0000409--socket-reset-und_err_socket)
   - [Bug 4: The C: Drive Starvation & Virtual Memory Lockup](#4-the-c-drive-starvation--virtual-memory-lockup)
2. [Hardware & Software Prerequisites](#hardware--software-prerequisites)
   - [Official Download Links](#official-download-links)
3. [Quick Start: 1-Click Installation](#quick-start-1-click-installation)
4. [Optimal Settings for 6GB VRAM (GTX 1060)](#optimal-settings-for-6gb-vram-gtx-1060)
5. [Architecture & Secondary Drive (D:) Isolation](#architecture--secondary-drive-d-isolation)
6. [Included Artifacts](#included-artifacts)
7. [Disclaimer & License](#disclaimer--license)

---

## The Hard-Won Findings: Root Cause Diagnostics

### 1. The Infamous 32 Consecutive '@' Characters Loop

#### The Symptom:
When prompting Qwen 2.5 Coder in Cline, the generation abruptly terminates with:
```text
32 consecutive '@' characters at the start of the response
```
Subsequent requests fail immediately or display hundreds of `@` symbols.

#### The Root Cause Uncovered:
1. **Tool-Declaration Conflict:** Cline's core prompt injects 6 native workspace tools and explicitly commands the model: `"IMPORTANT: Always include tool calls in your response"`. If the user submits a strict conversational prompt (e.g. *"Only print the text 'LOCAL_OLLAMA_OK'. Do not execute any tool"*), smaller 7B models get into an internal attention conflict between Cline's system prompt and the user's negative constraint.
2. **Special Tool Token Emission:** In confusion, Qwen 2.5 Coder starts emitting tool-envelope delimiter tokens (`@` or `<tool_call>`).
3. **Chat History Poisoning (The Deadliest Trap):** When Cline halts upon encountering 32 `@` characters, it erroneously saves the stream chunk containing `@` characters into the **assistant message history** within the task JSON.
4. When the user retries or replies, Cline re-sends the previous conversation history containing 200+ `@` characters back to Qwen! Qwen sees a repetition pattern in its own history, hallucinating 300+ more `@` characters.
5. **The Fix:**
   - Never send conflicting prompts forbidding tool calls while using standard Cline mode.
   - Start fresh tasks instead of continuing a corrupted conversation poisoned with `@` tokens.
   - The included patched VSIX captures raw model wire responses to `Captures/` so you can verify the exact payload sent by Ollama before any processing.

---

### 2. NVIDIA GTX 1060 (Pascal cc 6.1) Driver & CUDA Skipping

#### The Symptom:
Ollama logs show:
```text
skipping CUDA device "NVIDIA GeForce GTX 1060 6GB" (compute capability 6.1 not in architectures)
```
Users assume the GPU is unsupported and abandon GPU acceleration.

#### The Root Cause & Solution:
- Ollama ships with multiple CUDA runner builds: `cuda_v13` and `cuda_v12`.
- `cuda_v13` drops support for Compute Capability 6.1 (Pascal). However, Ollama automatically falls back to `cuda_v12`, which **fully supports Compute Capability 6.1 (sm_61)**.
- **Recommended Driver:** Use **NVIDIA Driver 572.70** or later (Game Ready or Studio Driver). Older 4xx/51x series drivers cause `PTX was compiled with an unsupported toolchain` errors.

---

### 3. llama-server Crash (0xc0000409) & Socket Reset (UND_ERR_SOCKET)

#### The Symptom:
Cline disconnects with `SocketError: other side closed` or Ollama logs `llama-server exited with code 0xc0000409`.

#### The Root Cause:
- Cline defaults to `num_ctx: 32768` (32K tokens).
- For a 7B Q4_K_M model (~4.36 GB), a 32K context KV-cache consumes ~2.1 GB of VRAM.
- On a 6GB card with Windows Desktop Window Manager (DWM) taking 0.8–1.2 GB VRAM, 4.36 GB model + 2.1 GB KV-cache **exceeds total VRAM**, forcing offloading into system RAM and Windows pagefile.
- When massive prompt batches are processed under low disk space, memory allocation fails fatally with `0xc0000409` (STATUS_STACK_BUFFER_OVERRUN / Illegal Memory Access).
- **The Fix:** Set Context Window to **4096** or **8192** in Cline settings for 6GB GPUs.

---

### 4. The C: Drive Starvation & Virtual Memory Lockup

#### The Phenomenon:
Windows system drives (C:) with less than 2–3 GB free space will experience catastrophic lockups when running local LLMs.
- Windows pagefile (`pagefile.sys`) dynamically expands during model offload.
- If C: space drops below 500 MB, Windows disk I/O stalls, killing the Ollama socket and freezing the OS.
- **The Fix:** **100% Secondary Drive (D:) Isolation**. Ollama models (`D:\Ollama\Models`), VS Code extensions (`D:\Cline-Development\Isolated-Profile`), and workspace projects must be placed on secondary storage.

---

## Hardware & Software Prerequisites

| Component | Minimum Required | Tested / Recommended Setup |
| :--- | :--- | :--- |
| **Operating System** | Windows 10 x64 (21H2+) | Windows 11 x64 |
| **GPU** | NVIDIA GTX 1060 6GB (Pascal cc 6.1) | GTX 1060 6GB / GTX 1660 / RTX 2060 |
| **RAM** | 16 GB DDR4 | 16 GB+ DDR4 |
| **Free Storage** | 20 GB free on secondary drive (D: or E:) | C: > 10 GB free for Windows paging |
| **NVIDIA Driver** | >= 570.xx | **572.70+** (Studio / Game Ready) |
| **Ollama** | 0.40.16+ | 0.40.16+ |
| **Node.js** | v20.x or v22.x LTS | v22.23.5 |
| **VS Code** | 1.90.0+ | Latest Stable |

### Official Download Links & Critical Version Pinning

> [!WARNING]
> **LINK ROT & STRICT VERSION COMPATIBILITY ADVISORY:**  
> Web URLs change and vendor download links may break or die over time. More importantly, **DO NOT BLINDLY INSTALL ARBITRARY OR LATEST RELEASES**. Newer NVIDIA drivers or future Ollama runner builds may deprecate Compute Capability 6.1 (Pascal) or introduce breaking API changes.  
> Whenever possible, locate and preserve the **exact verified installer packages** listed below:

| Tool / Package | Exact Tested Version | Tested Filename / Identifier | Why This Exact Version? |
| :--- | :--- | :--- | :--- |
| **NVIDIA Driver** | **572.70** (or 570.xx+) | `572.70-desktop-win10-win11-64bit-international-dch-whql.exe` | Older 4xx/51x drivers throw PTX toolchain errors; future drivers may drop Pascal. |
| **Git for Windows** | **2.56.0.4** (or 2.47+) | `Git-2.56.0.4-64-bit.exe` | Stable baseline for submodules & git credentials. |
| **Bun Runtime** | **1.4.4** (x64 baseline) | `bun-windows-x64-baseline.zip` | Required by Cline build toolchains; standard Node/npm locks. |
| **Ollama** | **0.40.16** | `OllamaSetup.exe` (v0.40.16) | Confirmed to bundle `cuda_v12` with sm_61 compiled in. |
| **Model Weights** | **Qwen 2.5 Coder 7B** | `qwen2.5-coder:7b` (Q4_K_M ~4.36GB) | Fits fully into 6GB VRAM at 4096 context. |
| **Patched Extension**| **Cline 4.1.26** | `Cline-4.1.26-WireResponse-Capture.vsix` | Built-in wire capture & test-verified (213/213 passed). |

- **NVIDIA Driver Download:** [Official NVIDIA Link (Driver 280050)](https://www.nvidia.com/en-us/drivers/details/280050/) (Fallback: search for desktop Pascal GTX 1060 Windows 10/11 64-bit v572.70).
- **Git for Windows:** [Official Git SCM](https://git-scm.com/download/win)
- **Bun Runtime:** [Official Bun Releases](https://bun.sh/)
- **Ollama for Windows:** [Official Ollama Releases](https://ollama.com/download)

---

## Quick Start: 1-Click Installation & Safe Removal

This repository includes a pre-compiled, fully tested VSIX:  
`bin/Cline-4.1.26-WireResponse-Capture.vsix` (SHA-256: `df3fda614a5b9211f03a4d962904be2d927724a0c3b5d36dc504af5b5ad6e834`)

### Installation: Run `install.bat`
Run `install.bat` (Double-click or run from command prompt):
```cmd
install.bat
```
This script automatically:
- Checks if VS Code (`code`) is available.
- Installs the pre-built VSIX into your VS Code extension directory.
- Prepares your launchers and configuration.

### Safe Uninstallation: Run `uninstall.bat`
To cleanly uninstall the extension and remove shortcuts without touching your projects or AI models:
```cmd
uninstall.bat
```
> [!NOTE]
> **Data Protection Guarantee:** The uninstaller **NEVER** touches or deletes your downloaded AI models in `D:\Ollama\Models` or your personal workspace code files. It only removes the Cline extension and desktop shortcuts.

### Step 2: Start Ollama on Secondary Drive
Run `start-ollama.bat`:
```cmd
start-ollama.bat
```
This sets `OLLAMA_MODELS=D:\Ollama\Models` so model weights never consume your C: drive space, and launches Ollama.

### Step 3: Pull Qwen 2.5 Coder
In any terminal:
```cmd
ollama pull qwen2.5-coder:7b
```

### Step 4: Configure Cline UI
In VS Code -> Cline settings:
- **API Provider:** `Ollama`
- **Base URL:** `http://127.0.0.1:11434`
- **Model ID:** `qwen2.5-coder:7b`
- **Context Window:** Set to `8192` (or `4096` for maximum speed)

---

## Optimal Settings for 6GB VRAM (GTX 1060)

| Setting | Recommended Value | Why? |
| :--- | :--- | :--- |
| **Context Window** | `4096` - `8192` | 32K context exhausts 6GB VRAM and causes 0xc0000409 crash |
| **Batch Size (`num_batch`)** | `512` or `256` | Prevents VRAM spikes during prompt ingestion |
| **Micro-batch (`num_ubatch`)** | `512` or `256` | Balances memory throughput on Pascal GPUs |
| **Flash Attention** | `Disabled / Auto` | Flash attention on Pascal cc 6.1 can trigger illegal memory access |
| **GPU Layers** | All 29 layers offloaded | `qwen2.5-coder:7b` Q4_K_M fits completely in 6GB at 4K context |

---

## Architecture & Secondary Drive (D:) Isolation

```text
D:\ (Secondary Storage)
 ├── Ollama\
 │    └── Models\                <-- Model weights stored here (~4.5 GB)
 ├── Programs\
 │    └── Microsoft VS Code\     <-- Portable/Isolated VS Code installation
 └── Cline-Development\
      ├── Captures\              <-- Wire response captures for debugging
      └── Isolated-Profile\      <-- Extensions & user data kept off C:
```

---

## Included Artifacts

- **`bin/Cline-4.1.26-WireResponse-Capture.vsix`**: Pre-built extension with wire-response capture and test verification (213/213 unit tests passed).
- **`install.bat`**: Automatic installer.
- **`start-ollama.bat`**: Secondary-drive Ollama daemon starter.
- **`start-cline.bat`**: Isolated profile launcher.
- **`scripts/download-prerequisites.ps1`**: Helper script to fetch official Git, Bun, and Ollama tools.
- **`patches/`**: Complete source diffs of the wire capture subsystem and test harnesses.

---

## Disclaimer & License

### AI-Assisted Development Notice
This software and its documentation were developed using artificial intelligence systems and automated testing pipelines. While all tests have passed (213/213 unit tests clean), users are advised to test in non-production environments first and maintain regular backups of important workspaces.

### License
Released under the [MIT License](LICENSE).
Cline is an open-source project created by the Cline team. This repository provides community patches and deployment recipes for low-VRAM Windows environments.

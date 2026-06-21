<div align="center">

# 🏡 HomeSweetHome-Mgr

### *Home is where your workflow lives.*

[![Linux](https://img.shields.io/badge/Linux-UEFI%20boot-c4683f?style=for-the-badge&logo=linux&logoColor=white)](#)
[![Shell](https://img.shields.io/badge/Shell-Bash-6e8068?style=for-the-badge&logo=gnubash&logoColor=white)](#)
[![systemd](https://img.shields.io/badge/systemd-automation-c89a3a?style=for-the-badge&logo=linux&logoColor=white)](#)
[![Termux](https://img.shields.io/badge/Termux-Android%20controller-5b7a99?style=for-the-badge&logo=android&logoColor=white)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-8a8070?style=for-the-badge)](./LICENSE)

</div>

HomeSweetHome-Mgr is a small piece of personal infrastructure that does one job well: it makes sure that no matter how your machine boots, you can always find your way back to the environment where you actually get things done.

---

## 🛋️ Philosophy

Every system needs a place it returns to by default — a safe, stable, familiar starting point. For most dual-boot setups, that place is Windows. It's the fallback, the known quantity, the thing that "just works" for everyday tasks, drivers, and compatibility.

But the *home* you actually live in — the place where your tools, your shell, your workflow, and your headspace all come together — might be somewhere else entirely.

HomeSweetHome-Mgr exists to bridge that gap.

It doesn't fight Windows for the default boot slot. It doesn't ask you to take risks with your firmware settings. Instead, it quietly makes sure that your preferred Linux environment is always one boot away — accessible, predictable, and never more than a command or a tap on your phone away.

> Windows is the house you keep in good repair.
> Linux is the room you actually live in.

---

## 🌱 Why This Project Exists

Dual-booting Windows and Linux usually means choosing between two uncomfortable options:

- **Set Linux as the default boot entry**, and risk Windows updates silently rewriting your bootloader, or accidentally booting into the "wrong" OS on a shared or family machine.
- **Keep Windows as default and manually intervene every time**, mashing a boot-menu key, hoping you catch the timing, hoping nothing changes.

Neither of these feels like *home*. They feel like friction.

HomeSweetHome-Mgr was built to remove that friction without removing the safety net. Windows stays exactly where it should be — the dependable default. Linux becomes a deliberate, one-time-per-boot choice, set up automatically and reliably using the firmware's own `BootNext` mechanism.

The result is a system that behaves the way *you* want it to, every single time, without asking you to compromise on stability.

---

## ✨ Core Features

- **Automated UEFI BootNext configuration** — Linux is queued as the next boot target using `efibootmgr`, without ever touching the permanent boot order.
- **Windows stays the safe default** — if nothing intervenes, the machine boots exactly as it always has.
- **Boot banner & notifications** — a lightweight signal lets you know when a Linux boot has been successfully queued.
- **systemd-driven automation** — the whole flow runs hands-free once configured, triggered by the events you choose.
- **Remote control from an old Android phone** — a repurposed device running Termux becomes a pocket-sized remote for your home infrastructure.
- **Wake-on-LAN support** — wake the machine up before you even sit down at your desk.
- **Configuration-driven, not hardcoded** — all machine-specific values live in `secrets.conf`, kept out of version control.
- **Designed to grow** — built as the foundation for a larger orchestration layer (see [Future FRIDAY Integration](#-future-friday-integration)).

---

## 🚪 The rooms of the house

| | Component | What it does |
|---|---|---|
| 🔌 | **`efimgr.sh`** | Sets `BootNext`, queues Linux for the next boot |
| 🔔 | **`banner.sh`** | Confirms the boot is ready — the porch light |
| 🔁 | **systemd services** | Runs everything hands-free, on schedule or trigger |
| 📱 | **Termux controller** | A repurposed Android phone, your pocket remote |
| 📡 | **Wake-on-LAN** | Wakes the machine before you sit down |
| ⚙️ | **`secrets.conf`** | Keeps your personal setup out of version control |

---

## 🌆 A typical evening home

```
📱 Tap on phone  →  📡 Wake-on-LAN  →  🔌 BootNext set  →  🐧 Boots into Linux
```

---

## 🏗️ Architecture Overview

```
                         ┌─────────────────────────────┐
                         │        Old Android Phone    │
                         │     (Termux Controller)     │
                         │                             │
                         │  • Sends Wake-on-LAN packet │
                         │  • Triggers remote commands │
                         └───────────────┬─────────────┘
                                         │
                                         │  Wake-on-LAN / SSH
                                         ▼
                         ┌───────────────────────────────┐
                         │        Home Machine           │
                         │   (Linux + Windows dual-boot) │
                         │                               │
                         │   ┌─────────────────────┐     │
                         │   │     efimgr.sh       │     │
                         │   │  sets UEFI BootNext │     │
                         │   └──────────┬──────────┘     │
                         │              │                │
                         │   ┌──────────▼───────────┐    │
                         │   │     banner.sh        │    │
                         │   │  confirms boot queued│    │
                         │   └──────────┬───────────┘    │
                         │              │                │
                         │   ┌──────────▼─────────────┐  │
                         │   │  systemd services      │  │
                         │   │  automate the workflow │  │
                         │   └────────────────────────┘  │
                         └───────────────┬───────────────┘
                                         │
                                         ▼
                         ┌─────────────────────────────┐
                         │      UEFI Firmware          │
                         │                             │
                         │  Default → Windows (safe)   │
                         │  BootNext → Linux (one-time)│
                         └─────────────────────────────┘
```

In words: a small trigger (manual, scheduled, or remote) tells `efimgr.sh` to queue Linux as the next boot. `banner.sh` confirms it happened. systemd makes sure this all runs reliably without you having to remember a single command. And if you're not even home yet, your phone can kick the whole thing off remotely.

---

## 📁 Repository Structure

```
HomeSweetHome-Mgr/
├── efimgr.sh                 # Core EFI BootNext manager
├── banner.sh                 # Boot confirmation / notification banner
├── secrets.conf.example      # Template for machine-specific configuration
├── systemd/
│   ├── homesweethome.service # Main automation service
│   └── homesweethome.timer   # Optional scheduled trigger
├── termux/
│   ├── wol_trigger.sh        # Wake-on-LAN sender script
│   └── remote_control.sh     # Remote command dispatcher
├── docs/
│   └── architecture.md       # Extended technical notes
├── LICENSE
└── README.md
```

---

## 🧩 Components Explained

### `efimgr.sh`
The heart of the project. This script talks directly to the system firmware through `efibootmgr` and sets the `BootNext` variable to point at your Linux boot entry. `BootNext` is a one-shot instruction — it applies to the *very next* boot only, and then the firmware quietly reverts to its normal default. No permanent changes, no risk of an update silently undoing your setup.

### `banner.sh`
A small but meaningful piece of the experience. Once `efimgr.sh` has done its job, `banner.sh` gives you a clear, human-readable confirmation that the next boot is queued for Linux. It's the equivalent of a porch light turning on — a simple signal that everything's ready for you.

### systemd services
Two small units do the heavy lifting of automation:
- A **service** that runs the EFI configuration logic on demand.
- A **timer** (optional) that can trigger the flow on a schedule, or in response to other system events.

Together they mean you don't have to remember to run anything by hand. The system takes care of itself.

### Termux controller
An old Android phone, repurposed as a lightweight remote control. Running Termux, it can send a Wake-on-LAN packet to bring your machine out of sleep, and dispatch remote commands to trigger the boot configuration — all from your pocket. It's proof that "home infrastructure" doesn't need to be expensive or elaborate to be genuinely useful.

### Configuration files (`secrets.conf`)
All machine-specific details — MAC addresses, boot entry identifiers, hostnames, and other local values — live in a single `secrets.conf` file, kept out of version control via `.gitignore`. This keeps the public project clean, portable, and safe to share, while your personal setup stays private.

---

## ⚙️ How It Works

1. A trigger occurs — you run a command manually, a systemd timer fires, or your Termux controller sends a remote signal.
2. `efimgr.sh` reads your configuration and sets the UEFI `BootNext` variable to your Linux boot entry.
3. `banner.sh` confirms the change, so you know it worked before you walk away or reboot.
4. On the next restart, firmware honors `BootNext` exactly once and boots into Linux.
5. After that single boot, the firmware quietly returns to its normal default — Windows — ready to repeat the cycle whenever you need it.

No permanent boot order changes. No guesswork. No racing a boot-menu countdown.

---

## 🧭 Design Principles

- **Windows stays the primary `BootOrder` entry.** It's the operating system every other piece of software, every driver, and every Windows Update expects to find as default. Leaving it there means HomeSweetHome-Mgr never fights the system — it works *with* it.
- **`BootNext` over permanent changes.** `BootNext` is a one-time, self-clearing instruction built directly into the UEFI spec. Using it instead of rewriting `BootOrder` means there's nothing to "undo" if something goes wrong — the firmware resets itself automatically.
- **Fast Startup and NTFS interoperability matter.** Windows' Fast Startup feature can leave the NTFS file system in a "hibernated" state that Linux can't always mount safely. HomeSweetHome-Mgr is built with this in mind, encouraging configurations where Fast Startup is disabled or carefully managed, so shared drives stay healthy and accessible from both systems.
- **Configuration over hardcoding.** Every personal detail lives in `secrets.conf`, not in the scripts themselves. The project should be reusable by anyone, on any machine, without exposing anyone's private setup.
- **Small, composable scripts.** Each component does one thing. That makes the whole system easier to read, trust, and extend.

---

## 📍 Current Status

<div align="center">

![Core pieces](https://img.shields.io/badge/core%20pieces%20shipped-5-6e8068?style=flat-square)
![Phones repurposed](https://img.shields.io/badge/phones%20repurposed-1-5b7a99?style=flat-square)
![Missed boots](https://img.shields.io/badge/missed%20boots-0-c4683f?style=flat-square)

</div>

HomeSweetHome-Mgr is **actively used and actively evolving**. The core boot orchestration flow — `efimgr.sh`, `banner.sh`, and the systemd automation — is stable and in daily use. The Termux controller and Wake-on-LAN flow are functional and being refined for reliability across different network conditions.

This is real infrastructure for a real homelab, not a proof of concept.

---

## 🗺️ Roadmap

- [x] Core `efimgr.sh` BootNext automation
- [x] `banner.sh` boot confirmation
- [x] systemd service for hands-free automation
- [x] Termux-based Wake-on-LAN trigger
- [x] Configuration-driven setup via `secrets.conf`
- [ ] Web-based status dashboard for boot state
- [ ] Push notifications to phone on successful boot queue
- [ ] Multi-machine support (manage more than one home device)
- [ ] Encrypted remote command channel
- [ ] Logging and history of boot events
- [ ] Full integration into the FRIDAY orchestration layer

---

## 🤖 Future FRIDAY Integration

HomeSweetHome-Mgr is intentionally scoped — it solves the boot orchestration problem, and solves it well, without trying to be everything at once. But it's also designed as a foundational layer for something larger.

**FRIDAY** is the planned next chapter: a broader home orchestration architecture that will tie together boot management, remote control, automation, and monitoring into a single coherent system. Where HomeSweetHome-Mgr handles "get me into the right environment," FRIDAY will expand that into "manage the home environment as a whole" — coordinating multiple devices, richer automation, and a more conversational layer of control.

Think of HomeSweetHome-Mgr as the front door. FRIDAY is the house being built around it.

---

## 🔒 Security Notes

- `secrets.conf` contains machine-specific and potentially sensitive values (MAC addresses, hostnames, boot identifiers). It is excluded from version control by default — never commit your real configuration file.
- Wake-on-LAN traffic is inherently broadcast-based; this project assumes it runs on a trusted local network, not an open or public one.
- Remote control commands from the Termux controller should be restricted to your local network or routed through a secured connection (e.g. SSH, VPN, or Tailscale) if accessed remotely.
- `efibootmgr` requires elevated privileges to modify firmware variables. Scripts are written to touch only `BootNext`, never `BootOrder`, minimizing the blast radius of any misconfiguration.

If you find a security concern, please open an issue or reach out directly rather than filing a public report with exploit details.

---

## 🤝 Contributing

This project started as a personal solution to a personal problem, but it's built to be useful beyond one homelab. Contributions, suggestions, and homelab war stories are all welcome.

- Found a bug? Open an issue with details about your distro, firmware, and boot setup.
- Have an idea that fits the project's philosophy? Open a discussion before a big PR — let's make sure it fits the home before we start renovating.
- Small fixes and documentation improvements are always appreciated.

---

## 📄 License

This project is released under the [MIT License](./LICENSE). Use it, fork it, adapt it to your own home.

---

## 🌙 Closing

At the end of a long day, there's a particular kind of relief in walking through a door that opens exactly the way you expect it to — lights where you left them, everything in its place, nothing to configure or second-guess.

That's what HomeSweetHome-Mgr is trying to give back to a boot sequence: the quiet, reliable feeling of coming home.

<div align="center">

> *Windows keeps the porch light on.*
> *Linux is still the room where the work happens.*

**And now, getting there is as simple as it should have been all along.**

🏡

</div>
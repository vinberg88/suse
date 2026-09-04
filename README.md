# 🦎 openSUSE Desktop Lab for WSL

Easy way to install OpenSUSE TUMBELWEED. Open Powershell and copy and paste this.

wsl --distribution openSUSE-Tumbleweed --user OpenSUSE

Easy way to install OpenSUSE Leap. Open Powershell and copy and paste this.

wsl --distribution openSUSE-Leap-16.0 --user OpenSUSE_leap

![openSUSE](https://img.shields.io/badge/openSUSE-Tumbleweed-73BA25?style=for-the-badge&logo=opensuse&logoColor=white)
![openSUSE Leap](https://img.shields.io/badge/openSUSE-Leap%2016-173F4F?style=for-the-badge&logo=opensuse&logoColor=white)
![WSL2](https://img.shields.io/badge/WSL-2-0078D4?style=for-the-badge&logo=windows11&logoColor=white)
![Windows 11](https://img.shields.io/badge/Windows-11-0078D4?style=for-the-badge&logo=windows11&logoColor=white)

> **Run openSUSE your way on Windows.**  
> This repository is a practical desktop lab for running **openSUSE Tumbleweed** and **openSUSE Leap** inside **WSL2**, with desktop environments such as **KDE Plasma, GNOME, Xfce, LXQt, Budgie and Deepin**.

The goal is simple: start with a clean openSUSE WSL installation, choose the desktop you want, and turn it into a useful Linux desktop environment without replacing Windows.

---



## ✨ What this project is about

WSL is normally used from a terminal, but it can do much more.

This project explores how far we can take a normal openSUSE WSL installation with:

- 🖥️ Full Linux desktop environments
- 🦎 openSUSE Tumbleweed and Leap
- 🪟 Windows 11 + WSL2
- 🔊 WSLg audio integration
- 🎨 X11 sessions through **X410**
- 🚀 Native WSLg applications where possible
- ⚙️ systemd and user services
- 🧪 Experimental desktop combinations
- 🛠️ Reusable launch scripts and troubleshooting tools

> This is a community project and is **not an official openSUSE, SUSE or Microsoft project**.

---

# 🦎 Choose your openSUSE

| | openSUSE Tumbleweed | openSUSE Leap |
|---|---|---|
| Release model | 🔄 Rolling release | 🧱 Stable release |
| Packages | Very current | More conservative |
| Desktop testing | ⭐ Excellent playground | ✅ Stable base |
| KDE / GNOME | Very current | Stable versions |
| Best for | Desktop experiments, newest software | Predictable workstation setup |
| Update command | `sudo zypper dup` | `sudo zypper update` |

### Tumbleweed

**Tumbleweed** is the rolling-release edition of openSUSE. It is an excellent choice when you want recent kernels, desktop environments, Mesa, KDE Plasma, GNOME and development tools.

```bash
sudo zypper refresh
sudo zypper dup
```

### Leap

**Leap** is the more stable openSUSE platform. It is a good choice when you prefer a predictable system and do not need every desktop package on the newest possible version.

```bash
sudo zypper refresh
sudo zypper update
```

---

# 🚀 Install openSUSE in WSL

First make sure WSL itself is installed and updated.

```powershell
wsl --update
wsl --status
```

List the openSUSE distributions currently available to WSL:

```powershell
wsl --list --online
```

Then install the openSUSE edition shown on your system:

```powershell
wsl --install -d <DistroName>
```

Example workflow:

```powershell
wsl --list --online
wsl --install -d <openSUSE-name-from-the-list>
wsl -l -v
```

> The exact WSL distribution name can change between releases. Using `wsl --list --online` avoids hard-coding an old Store name.

---

# ⚙️ Check WSL2 and systemd

Inside openSUSE:

```bash
cat /etc/os-release
uname -r
ps -p 1 -o pid,comm,args
systemctl is-system-running
```

A healthy systemd-enabled WSL installation should show `systemd` as PID 1.

If systemd is not enabled, create or edit `/etc/wsl.conf`:

```ini
[boot]
systemd=true
```

Then from PowerShell:

```powershell
wsl --shutdown
```

Start openSUSE again and verify:

```bash
ps -p 1 -o comm=
systemctl --failed
```

---

# 🖥️ Desktop environments

## 💎 KDE Plasma

![KDE Plasma](https://img.shields.io/badge/KDE-Plasma%206-1D99F3?style=flat-square&logo=kde&logoColor=white)
![Recommended](https://img.shields.io/badge/WSL-Recommended-success?style=flat-square)

KDE Plasma is one of the best desktop choices for an openSUSE WSL workstation. It is highly configurable and works especially well when using an external X server such as X410.

### Install

```bash
sudo zypper refresh
sudo zypper install patterns-kde-kde_plasma
```

Useful commands after installation:

```bash
command -v startplasma-x11
command -v startplasma-wayland
command -v kwin_x11
```

### X11 / X410 launch idea

```bash
export DISPLAY=$(awk '/^nameserver / {print $2; exit}' /etc/resolv.conf):0.0
export PULSE_SERVER=unix:/mnt/wslg/PulseServer
export XDG_SESSION_TYPE=x11

dbus-run-session -- startplasma-x11
```

> **Tip:** KDE Plasma + X410 is one of the main combinations tested in this project.

---

## 🟣 GNOME

![GNOME](https://img.shields.io/badge/GNOME-Desktop-4A86CF?style=flat-square&logo=gnome&logoColor=white)
![WSL](https://img.shields.io/badge/WSL-Testing-blue?style=flat-square)

GNOME provides a clean, modern workstation experience and is another interesting target for WSL desktop experiments.

### Install

```bash
sudo zypper refresh
sudo zypper install patterns-gnome-gnome
```

Check available GNOME sessions:

```bash
ls /usr/share/xsessions 2>/dev/null
ls /usr/share/wayland-sessions 2>/dev/null
```

Possible manual session start:

```bash
dbus-run-session -- gnome-session
```

GNOME can be more sensitive than lighter desktops to D-Bus, systemd user sessions, Wayland and graphics configuration, so expect some experimentation under WSL.

---

## 🐭 Xfce

![Xfce](https://img.shields.io/badge/Xfce-Lightweight-2284F2?style=flat-square)
![WSL](https://img.shields.io/badge/WSL-Great%20Choice-success?style=flat-square)

Xfce is a very good WSL desktop because it is lightweight, mature and works well with classic X11.

### Install

```bash
sudo zypper refresh
sudo zypper install patterns-xfce-xfce
```

### Start

```bash
dbus-run-session -- startxfce4
```

For X410:

```bash
export DISPLAY=$(awk '/^nameserver / {print $2; exit}' /etc/resolv.conf):0.0
export PULSE_SERVER=unix:/mnt/wslg/PulseServer

dbus-run-session -- startxfce4
```

---

## 🪶 LXQt

![LXQt](https://img.shields.io/badge/LXQt-Lightweight-0192D3?style=flat-square)
![Qt](https://img.shields.io/badge/Qt-Desktop-41CD52?style=flat-square&logo=qt&logoColor=white)

LXQt is a lightweight Qt-based desktop and is a strong option if you want something smaller than a full KDE Plasma installation.

### Install

```bash
sudo zypper refresh
sudo zypper install patterns-lxqt-lxqt
```

### Start

```bash
dbus-run-session -- startlxqt
```

---

## 🟦 Budgie

![Budgie](https://img.shields.io/badge/Budgie-Experimental-orange?style=flat-square)

Budgie is available for openSUSE, but repository support differs between Tumbleweed and Leap. Tumbleweed currently has the stronger package availability.

Before installing, check what your release provides:

```bash
zypper search -s budgie-desktop
zypper search -s patterns-budgie
```

On a system where the packages are available:

```bash
sudo zypper install budgie-desktop
```

Treat Budgie as an **experimental WSL desktop** until the complete session, panel and background stack has been tested for your openSUSE release.

---

## 🌊 Deepin Desktop Environment

![Deepin](https://img.shields.io/badge/Deepin-DDE-Experimental-orange?style=flat-square)

Deepin is one of the most interesting desktops to experiment with, but it is also one of the least predictable options on current openSUSE releases.

Package availability can depend on the release and community repositories.

Start by checking the repositories instead of blindly adding third-party packages:

```bash
zypper search -s deepin
zypper search -s dde
```

> Deepin should currently be considered a **community / experimental target**, especially on newer Leap releases.

This repository can later contain a dedicated Deepin installation and launcher once a clean package set is validated.

---

# 📊 Desktop status

The table below is deliberately conservative. A desktop is only promoted to **Verified** after a repeatable WSL installation and launch procedure has been tested.

| Desktop | Tumbleweed | Leap | WSL profile |
|---|---:|---:|---|
| 💎 KDE Plasma | 🟢 Primary | 🟢 Primary | Full desktop / X11 / X410 |
| 🟣 GNOME | 🟡 Testing | 🟡 Testing | Full desktop / WSLg / X11 experiments |
| 🐭 Xfce | 🟢 Recommended | 🟢 Recommended | Lightweight X11 desktop |
| 🪶 LXQt | 🟢 Recommended | 🟢 Recommended | Lightweight Qt desktop |
| 🟦 Budgie | 🟡 Experimental | 🟠 Repository dependent | Desktop experiment |
| 🌊 Deepin DDE | 🟠 Experimental | 🔴 Unsupported / community | Research target |

**Legend:** 🟢 strong candidate · 🟡 testing · 🟠 experimental · 🔴 currently not a normal supported path

---

# 🪟 WSLg vs X410

There are two useful ways to display Linux GUI applications from WSL.

## WSLg

WSLg is integrated into modern WSL and Windows 11. For normal Linux GUI applications it is usually the easiest option.

Check the environment:

```bash
printf 'DISPLAY=%s\n' "$DISPLAY"
printf 'WAYLAND_DISPLAY=%s\n' "$WAYLAND_DISPLAY"
printf 'PULSE_SERVER=%s\n' "$PULSE_SERVER"
ls -la /mnt/wslg 2>/dev/null
```

## X410

X410 is useful when experimenting with complete X11 desktop sessions.

A common WSL2 display setup is:

```bash
export DISPLAY=$(awk '/^nameserver / {print $2; exit}' /etc/resolv.conf):0.0
```

Check that the X server answers:

```bash
xdpyinfo >/dev/null && echo "X server: OK"
```

Use WSLg's PulseAudio socket for sound while the desktop itself is displayed through X410:

```bash
export PULSE_SERVER=unix:/mnt/wslg/PulseServer
```

This hybrid setup is especially useful for desktop testing.

---

# 🧰 Recommended WSL desktop tools

Install a useful troubleshooting baseline:

```bash
sudo zypper install \
  dbus-1 \
  xauth \
  xhost \
  xrandr \
  xset \
  xprop \
  xwininfo \
  Mesa-demo-x
```

Package names can vary slightly between openSUSE releases. If one is not found:

```bash
zypper search <package-name>
```

---

# 🔎 Useful diagnostics

### Distribution

```bash
cat /etc/os-release
```

### WSL kernel

```bash
uname -a
```

### systemd

```bash
ps -p 1 -o pid,comm,args
systemctl is-system-running
systemctl --failed --no-pager -l
```

### User session

```bash
systemctl --user is-system-running
systemctl --user --failed --no-pager -l
```

### D-Bus

```bash
echo "$DBUS_SESSION_BUS_ADDRESS"
busctl --user status 2>/dev/null
```

### Graphics

```bash
echo "$DISPLAY"
echo "$WAYLAND_DISPLAY"
xdpyinfo 2>/dev/null | head
```

### Audio

```bash
echo "$PULSE_SERVER"
ls -l /mnt/wslg/PulseServer 2>/dev/null
```

---

# 🧪 A clean desktop test workflow

When testing a new desktop, use a repeatable workflow:

```text
1. Install a clean openSUSE WSL instance
2. Update the distribution
3. Verify systemd
4. Install only one desktop environment
5. Verify D-Bus and user systemd
6. Configure WSLg or X410
7. Start the desktop manually
8. Record missing services/packages
9. Build a clean launcher script
10. Re-test from a fresh WSL installation
```

That makes it much easier to separate real desktop bugs from leftovers caused by previously installed desktop environments.

---

# 🧹 Do not mix everything at once

Installing KDE, GNOME, Xfce, Budgie and Deepin into the same WSL instance may pull in overlapping services, portals, polkit agents, file managers, settings daemons and session components.

For serious testing, use a separate WSL instance per desktop.

Check installed distributions from PowerShell:

```powershell
wsl -l -v
```

You can export a clean base before experimenting:

```powershell
wsl --export <DistroName> opensuse-clean.tar
```

And restore it under a new test name:

```powershell
wsl --import SUSE-KDE C:\WSL\SUSE-KDE .\opensuse-clean.tar --version 2
```

This makes desktop testing much faster.

---

# 🗺️ Project roadmap

Planned additions to this repository:

- [ ] KDE Plasma installer for Tumbleweed
- [ ] KDE Plasma installer for Leap
- [ ] `kde-x410` launcher
- [ ] GNOME installer and launcher
- [ ] Xfce installer and launcher
- [ ] LXQt installer and launcher
- [ ] Budgie WSL test profile
- [ ] Deepin DDE research profile
- [ ] Automatic WSL / WSLg / X410 detection
- [ ] Audio detection through `/mnt/wslg/PulseServer`
- [ ] `suse-wsl doctor` diagnostic command
- [ ] Screenshots of verified desktops
- [ ] Known issues section for each desktop

---

# 💡 Philosophy

This repository is not trying to make WSL behave exactly like a traditional Linux PC.

Instead, the idea is to use the strengths of both systems:

**Windows 11** provides the host, GPU integration, applications and hardware support.  
**WSL2** provides a real Linux environment.  
**openSUSE** provides an excellent Linux package ecosystem.  
**KDE, GNOME, Xfce, LXQt and other desktops** provide the graphical experience.

The result is a flexible Linux desktop laboratory running directly inside Windows. 🚀

---

# 🔗 Useful links

- [openSUSE](https://www.opensuse.org/)
- [openSUSE Tumbleweed](https://get.opensuse.org/tumbleweed/)
- [openSUSE Leap](https://get.opensuse.org/leap/)
- [openSUSE Software](https://software.opensuse.org/)
- [Windows Subsystem for Linux](https://learn.microsoft.com/windows/wsl/)
- [WSLg](https://github.com/microsoft/wslg)
- [X410](https://x410.dev/)

---

# 🤝 Contributing

Testing is welcome.

If you find a desktop combination that works well under WSL, document:

- openSUSE edition
- desktop version
- installation command
- launch command
- WSLg or X410
- audio status
- known issues

That information can then be turned into a repeatable installer or launcher.

---

# ⚠️ Disclaimer

This repository contains community experiments for running Linux desktop environments under Windows Subsystem for Linux.

openSUSE and the openSUSE logo are trademarks of SUSE LLC or their respective owners. Microsoft, Windows and WSL are trademarks of Microsoft Corporation. Other desktop names and logos belong to their respective projects.

No affiliation or endorsement is implied.

---

## 🦎 openSUSE + WSL2 + your desktop of choice

**Tumbleweed when you want the newest stack.**  
**Leap when you want a stable base.**  
**KDE, GNOME, Xfce, LXQt and more when a terminal is not enough.**

Made for testing, learning and building better Linux desktop experiences on WSL.

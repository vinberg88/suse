#!/usr/bin/env bash
set -euo pipefail

VERSION="0.1.0"
TARGET="/usr/local/bin/kde6-x410"

echo
echo "=================================================="
echo " openSUSE Tumbleweed KDE Plasma 6 / X410 Installer"
echo " Version: ${VERSION}"
echo "=================================================="
echo

if ! grep -qi "opensuse" /etc/os-release 2>/dev/null; then
    echo "[WARNING] This installer is intended for openSUSE."
fi

if ! grep -qi microsoft /proc/version 2>/dev/null; then
    echo "[WARNING] WSL was not detected."
fi

echo "[1/4] Refreshing repositories..."
sudo zypper --non-interactive refresh

echo
echo "[2/4] Installing KDE/X11 dependencies..."
sudo zypper --non-interactive install \
    plasma6-workspace \
    plasma6-session \
    kwin6-x11 \
    xset \
    xsetroot \
    xrandr \
    xdpyinfo \
    dbus-1

echo
echo "[3/4] Installing kde6-x410 launcher..."

tmpfile="$(mktemp)"
trap 'rm -f "$tmpfile"' EXIT

cat > "$tmpfile" <<'LAUNCHER'
#!/usr/bin/env bash
set -u

VERSION="0.1.0"
STATE_DIR="$HOME/.local/state/kde6-x410"
LOG_FILE="$STATE_DIR/session.log"
PID_FILE="$STATE_DIR/session.pid"

mkdir -p "$STATE_DIR"

detect_display() {
    local gateway=""

    gateway="$(ip route 2>/dev/null | awk '/default/ {print $3; exit}')"

    if [[ -z "$gateway" ]]; then
        gateway="$(awk '/nameserver/ {print $2; exit}' /etc/resolv.conf 2>/dev/null)"
    fi

    if [[ -n "$gateway" ]]; then
        echo "${gateway}:0.0"
    else
        echo ""
    fi
}

setup_environment() {
    local detected_display

    detected_display="$(detect_display)"

    if [[ -n "$detected_display" ]]; then
        export DISPLAY="$detected_display"
    fi

    # Force the Plasma session and applications onto X410/X11.
    unset WAYLAND_DISPLAY
    unset WAYLAND_SOCKET

    export XDG_SESSION_TYPE=x11
    export KDE_SESSION_VERSION=6
    export KDE_FULL_SESSION=true
    export QT_QPA_PLATFORM=xcb
    export GDK_BACKEND=x11
    export SDL_VIDEODRIVER=x11
    export CLUTTER_BACKEND=x11

    # Keep WSLg PulseAudio for sound.
    if [[ -S /mnt/wslg/PulseServer ]]; then
        export PULSE_SERVER="unix:/mnt/wslg/PulseServer"
    fi

    if [[ -z "${XDG_RUNTIME_DIR:-}" ]]; then
        export XDG_RUNTIME_DIR="/run/user/$(id -u)"
    fi
}

check_x410() {
    if [[ -z "${DISPLAY:-}" ]]; then
        echo "[ERROR] DISPLAY is not configured."
        return 1
    fi

    if xdpyinfo -display "$DISPLAY" >/dev/null 2>&1; then
        echo "[OK] X410 responds on DISPLAY=$DISPLAY"
        return 0
    fi

    echo "[ERROR] X410 does not respond on DISPLAY=$DISPLAY"
    echo "Make sure X410 is running in Windows and allows WSL connections."
    return 1
}

doctor() {
    setup_environment

    echo
    echo "   openSUSE Tumbleweed KDE6 X410 $VERSION"
    echo "=================================================="

    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "Distribution:            ${PRETTY_NAME:-unknown}"
    fi

    echo "Kernel:                  $(uname -r)"

    if grep -qi microsoft /proc/version 2>/dev/null; then
        echo "WSL:                     yes"
    else
        echo "WSL:                     no"
    fi

    echo "X410 DISPLAY:            ${DISPLAY:-not configured}"

    if command -v startplasma-x11 >/dev/null 2>&1; then
        echo "startplasma-x11:         $(command -v startplasma-x11)"
    else
        echo "startplasma-x11:         missing"
    fi

    if command -v kwin_x11 >/dev/null 2>&1; then
        echo "kwin_x11:                $(command -v kwin_x11)"
    else
        echo "kwin_x11:                missing"
    fi

    if command -v plasmashell >/dev/null 2>&1; then
        echo "plasmashell:             $(command -v plasmashell)"
    else
        echo "plasmashell:             missing"
    fi

    local user_systemd
    user_systemd="$(systemctl --user is-system-running 2>/dev/null || true)"
    echo "User systemd:            ${user_systemd:-unavailable}"

    if [[ -S /mnt/wslg/PulseServer ]]; then
        echo "WSLg audio socket:       yes"
    else
        echo "WSLg audio socket:       no"
    fi

    if pgrep -x plasmashell >/dev/null 2>&1; then
        echo "Plasma session:          RUNNING"
    else
        echo "Plasma session:          stopped"
    fi

    echo

    if check_x410 >/dev/null 2>&1 \
       && command -v startplasma-x11 >/dev/null 2>&1 \
       && command -v plasmashell >/dev/null 2>&1; then
        echo "Status:                  READY"
        echo
        echo "[OK] KDE Plasma 6 / X410 environment looks ready."
    else
        echo "Status:                  NOT READY"
        echo
        echo "[WARNING] One or more required components are missing."
    fi

    echo
}

start_session() {
    setup_environment

    if ! check_x410; then
        exit 1
    fi

    if ! command -v startplasma-x11 >/dev/null 2>&1; then
        echo "[ERROR] startplasma-x11 was not found."
        exit 1
    fi

    # Do not let stale Plasma processes interfere with a new X410 session.
    pkill -x plasmashell 2>/dev/null || true
    pkill -x kwin_x11 2>/dev/null || true

    sleep 1
    rm -f "$PID_FILE"

    echo
    echo "[openSUSE KDE6 X410] Starting KDE Plasma 6 X11..."
    echo "[openSUSE KDE6 X410] DISPLAY=$DISPLAY"
    echo "[openSUSE KDE6 X410] Log: $LOG_FILE"
    echo

    nohup dbus-run-session -- \
        env \
        DISPLAY="$DISPLAY" \
        XDG_SESSION_TYPE=x11 \
        QT_QPA_PLATFORM=xcb \
        GDK_BACKEND=x11 \
        KDE_SESSION_VERSION=6 \
        KDE_FULL_SESSION=true \
        PULSE_SERVER="${PULSE_SERVER:-}" \
        startplasma-x11 \
        >"$LOG_FILE" 2>&1 &

    echo $! > "$PID_FILE"

    sleep 6

    if pgrep -x plasmashell >/dev/null 2>&1; then
        echo "[OK] KDE Plasma 6 is running on X410."
        echo
        return 0
    fi

    echo "[ERROR] Plasma did not appear to start correctly."
    echo
    echo "Last log lines:"
    echo "--------------------------------------------------"
    tail -n 40 "$LOG_FILE" 2>/dev/null || true
    echo "--------------------------------------------------"
    return 1
}

stop_session() {
    echo "[openSUSE KDE6 X410] Stopping Plasma..."

    pkill -x plasmashell 2>/dev/null || true
    pkill -x kwin_x11 2>/dev/null || true
    pkill -f '[s]tartplasma-x11' 2>/dev/null || true

    if [[ -f "$PID_FILE" ]]; then
        kill "$(cat "$PID_FILE")" 2>/dev/null || true
        rm -f "$PID_FILE"
    fi

    echo "[OK] Plasma session stopped."
}

status_session() {
    setup_environment

    echo
    echo "openSUSE KDE6 X410 $VERSION"
    echo "DISPLAY:                 ${DISPLAY:-not configured}"

    if pgrep -x plasmashell >/dev/null 2>&1; then
        echo "Plasma session:          RUNNING"
    else
        echo "Plasma session:          stopped"
    fi
    echo
}

case "${1:-}" in
    start)
        start_session
        ;;
    stop)
        stop_session
        ;;
    restart)
        stop_session
        sleep 2
        start_session
        ;;
    doctor)
        doctor
        ;;
    status)
        status_session
        ;;
    version)
        echo "openSUSE KDE6 X410 $VERSION"
        ;;
    *)
        echo
        echo "openSUSE Tumbleweed KDE6 X410 $VERSION"
        echo
        echo "Usage:"
        echo "  kde6-x410 doctor"
        echo "  kde6-x410 start"
        echo "  kde6-x410 stop"
        echo "  kde6-x410 restart"
        echo "  kde6-x410 status"
        echo "  kde6-x410 version"
        echo
        ;;
esac
LAUNCHER

sudo install -m 0755 "$tmpfile" "$TARGET"

echo
echo "[4/4] Installation complete."
echo
echo "Installed:"
echo "  $TARGET"
echo
echo "Start X410 in Windows first, then run:"
echo
echo "  kde6-x410 doctor"
echo "  kde6-x410 start"
echo
echo "Other commands:"
echo "  kde6-x410 status"
echo "  kde6-x410 stop"
echo "  kde6-x410 restart"
echo
echo "[OK] openSUSE Tumbleweed KDE6 X410 ${VERSION} installed."
echo

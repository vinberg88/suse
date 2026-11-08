param(
    [string]$Distro = 'openSUSE-Leap-16.1',
    [switch]$CheckOnly
)

$ErrorActionPreference = 'Stop'
$distro = $Distro

try {
    $x410 = (Get-Command x410.exe -ErrorAction Stop).Source
    & wsl.exe -d $distro -- sh -c 'command -v startplasma-x11 >/dev/null && command -v xset >/dev/null'
    if ($LASTEXITCODE -ne 0) { throw 'KDE Plasma or the WSL distribution is unavailable.' }

    if ($CheckOnly) {
        Write-Host "Ready: $distro, KDE Plasma and X410 were found."
        exit 0
    }

    Write-Host 'Switching X410 to Desktop mode...'
    Start-Process -FilePath $x410 -ArgumentList '/desktop' | Out-Null
    Start-Sleep -Seconds 3

    Write-Host 'Starting KDE Plasma. Keep this window open while using the desktop.'
    $linuxScript = @'
set -eu
host_ip=$(awk '/^nameserver[[:space:]]/ { print $2; exit }' /etc/resolv.conf)
if [ -z "$host_ip" ]; then
    echo 'Could not find the Windows host address.' >&2
    exit 1
fi
export DISPLAY="$host_ip:0.0"
export XDG_SESSION_TYPE=x11
unset WAYLAND_DISPLAY

# An old Plasma session cannot stay connected after X410 changes mode.
pkill -TERM -x startplasma-x11 2>/dev/null || true
pkill -TERM -x kwin_x11 2>/dev/null || true
pkill -TERM -x plasmashell 2>/dev/null || true
sleep 2

ready=0
for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if xset -display "$DISPLAY" q >/dev/null 2>&1; then
        ready=1
        break
    fi
    sleep 1
done
if [ "$ready" -ne 1 ]; then
    echo 'X410 did not accept the display connection.' >&2
    exit 1
fi

exec startplasma-x11
'@
    $helper = Join-Path $env:TEMP 'codex-start-kde-opensuse.sh'
    try {
        [System.IO.File]::WriteAllText($helper, ($linuxScript -replace "`r`n", "`n"), (New-Object System.Text.UTF8Encoding($false)))
        $linuxPath = & wsl.exe -d $distro -- wslpath -u ($helper -replace '\\', '/')
        if ($LASTEXITCODE -ne 0 -or -not $linuxPath) { throw 'Could not locate the KDE launcher from WSL.' }
        $linuxPath = $linuxPath.Trim()
        & wsl.exe -d $distro -- bash $linuxPath
        if ($LASTEXITCODE -ne 0) { throw "KDE exited with code $LASTEXITCODE." }
    }
    finally {
        Remove-Item -LiteralPath $helper -ErrorAction SilentlyContinue
    }
}
catch {
    Write-Error $_
    exit 1
}

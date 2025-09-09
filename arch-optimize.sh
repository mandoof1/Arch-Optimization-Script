#!/bin/bash
# Arch Linux Optimization Script
# Run as root (sudo ./arch-optimize.sh)

set -e

echo "[*] Updating system..."
pacman -Syu --noconfirm

echo "[*] Enabling parallel downloads..."
sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 5/' /etc/pacman.conf
grep -q "ILoveCandy" /etc/pacman.conf || echo "ILoveCandy" >> /etc/pacman.conf

echo "[*] Installing optimization tools..."
pacman -S --noconfirm reflector zram-generator htop iotop btop

echo "[*] Optimizing mirrors..."
reflector --country 'AE','DE','US' --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

echo "[*] Configuring ZRAM..."
cat > /etc/systemd/zram-generator.conf <<EOF
[zram0]
zram-size = ram/2
compression-algorithm = zstd
EOF
systemctl daemon-reexec

echo "[*] Enabling fstrim for SSDs..."
systemctl enable --now fstrim.timer

echo "[*] Enabling systemd-oomd..."
systemctl enable --now systemd-oomd

echo "[*] Reducing swappiness..."
echo "vm.swappiness=10" > /etc/sysctl.d/99-sysctl.conf

echo "[*] Cleaning package cache..."
paccache -r
pacman -Rns --noconfirm $(pacman -Qdtq || true)

echo "[*] Limiting journal logs to 200M..."
journalctl --vacuum-size=200M
sed -i '/SystemMaxUse/d' /etc/systemd/journald.conf
echo "SystemMaxUse=200M" >> /etc/systemd/journald.conf
systemctl restart systemd-journald

echo "[*] Installing Linux-Zen kernel for better desktop performance..."
pacman -S --noconfirm linux-zen linux-zen-headers

echo "[*] Done! Reboot recommended."

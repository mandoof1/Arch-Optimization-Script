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

echo "[*] Optimizing GRUB bootloader..."
# Backup original config
cp /etc/default/grub /etc/default/grub.bak

# Apply tweaks
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub
sed -i 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=menu/' /etc/default/grub
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3 nowatchdog"/' /etc/default/grub

# Add background if exists
if [ -f /boot/grub/mywallpaper.png ]; then
    sed -i '/^GRUB_BACKGROUND/d' /etc/default/grub
    echo 'GRUB_BACKGROUND="/boot/grub/mywallpaper.png"' >> /etc/default/grub
fi

# Generate high-res font
mkdir -p /boot/grub/fonts
grub-mkfont -o /boot/grub/fonts/DejaVuSansMono32.pf2 /usr/share/fonts/TTF/DejaVuSansMono.ttf || true
echo 'GRUB_FONT="/boot/grub/fonts/DejaVuSansMono32.pf2"' >> /etc/default/grub

# Regenerate grub config
grub-mkconfig -o /boot/grub/grub.cfg

echo "[*] Done! Reboot recommended."

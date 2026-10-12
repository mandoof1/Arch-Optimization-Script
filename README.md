# Arch Optimize 🚀

A lightweight script to **optimize Arch Linux** for better performance, faster package management, improved desktop responsiveness, and a faster + cleaner GRUB boot menu.  

This script applies common tweaks automatically so you don’t need to configure everything manually.  

---

## ✨ Features
- Faster **pacman** with parallel downloads  
- Automatically selects the **fastest mirrors** with Reflector  
- **ZRAM** (compressed swap in RAM) for smoother multitasking  
- **SSD optimization** with weekly TRIM  
- Enables **systemd-oomd** to prevent system freezes  
- Reduces **swappiness** (use RAM more, swap less)  
- Cleans up unused packages and old package cache  
- Limits **systemd journal logs** to 200 MB  
- Installs the **Linux-Zen kernel** for better desktop performance  
- Includes monitoring tools: `htop`, `iotop`, `btop`  
- **GRUB optimizations**:
  - Faster boot (timeout reduced to 1 second)  
  - Cleaner boot messages (`quiet splash`)  
  - High-resolution GRUB fonts  
  - Optional custom background (`/boot/grub/mywallpaper.png`)  

---

## ⚡ Installation
Clone the repo and run the script:

```bash
git clone https://github.com/mandoof1/Arch-Optimization-Script.git
cd Arch-Optimization-Script
chmod +x arch-optimize.sh
sudo ./arch-optimize.sh

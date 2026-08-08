> [!WARNING]
> **This repository is configured for personal use.** It's public solely so I can easily clone it from any device. It contains personal parameters that belong to me — replace them with your own before using. Also make sure to replace `hardware-configuration.nix` with one generated on your hardware. The instructions below assume that I am the one installing the system.

# Installation

1. Clone repository:
   ```fish
   git clone https://github.com/Lunobe/Nixos-Configuration ~/Nixos-Configuration
   ```

2. Replace system configuration:
   ```fish
   sudo cp -r ~/Nixos-Configuration/* /etc/nixos/
   rm -rf ~/Nixos-Configuration
   ```

3. Setup Btrfs subvolumes for snapshots:
   ```fish
   sudo mkdir -p /mnt/btrfs-root
   sudo mount -o subvolid=5 /dev/disk/by-uuid/<YOUR-BTRFS-UUID> /mnt/btrfs-root
   ```
   > Replace `<YOUR-BTRFS-UUID>` with your Btrfs partition UUID. Find it with: `lsblk -f`

   ```fish
   sudo rmdir /.snapshots /home/.snapshots 2>/dev/null || true

   sudo btrfs subvolume create /mnt/btrfs-root/@snapshots
   sudo btrfs subvolume create /mnt/btrfs-root/@home-snapshots

   sudo umount /mnt/btrfs-root
   sudo rmdir /mnt/btrfs-root
   ```

4. Build configuration and set password:
   ```fish
   sudo nixos-rebuild switch --flake /etc/nixos#nixos --extra-experimental-features "nix-command flakes"
   sudo passwd lunobe
   reboot
   ```

5. Initialize Git repository and connect to GitHub:
   ```fish
   cd /etc/nixos
   sudo git init
   sudo git add .
   sudo git -c user.name="Lunobe" -c user.email="257240031+Lunobe@users.noreply.github.com" commit -m "initial"
   git remote add origin git@github.com:Lunobe/Nixos-Configuration.git
   ```
   > Add your SSH public key (`~/.ssh/id_ed25519.pub`) to GitHub before pushing:
   > **GitHub → Settings → SSH and GPG keys → New SSH key**

   ```fish
   git -c safe.directory=/etc/nixos push -u origin main
   ```

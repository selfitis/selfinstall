# SelfInstall

SelfInstall is a lightweight containerization utility designed for Arch Linux (and Garuda Linux) environments. It allows users to create an isolated Debian chroot container (`debootstrap`) to install, run, and manage Debian-native software without altering host system dependencies or polluting system libraries.

## Features

- **Isolated Debian Environment**: Runs Debian packages inside a clean chroot jail.
- **Host User Mirroring**: Automatically mirrors host user credentials and permissions to prevent access restrictions.
- **GUI Application Support**: Enables X11 and Wayland display forwarding, allowing graphical applications to execute smoothly.
- **Desktop Integration**: Easily generates `.desktop` shortcuts to launch Debian applications directly from the application menu.
- **Clean Architecture**: Avoids mounting volatile runtime directories to prevent host system deadlocks or FUSE portal conflicts.

---

## Directory Structure

| Path / File | Type | Description |
| :--- | :--- | :--- |
| `install.sh` | Shell Script | Setup script that initializes the Debian rootfs via `debootstrap` and configures the environment. |
| `selfinstall` | Executable Script | Main CLI tool to manage packages, run commands, and generate shortcuts. |
| `/debian-koku` | System Directory | Root filesystem directory created on the host to house the Debian base environment. |

---

## Installation

1. Clone or download the repository to your local system.
2. Grant execution permissions to the setup script:
   ```bash
   chmod +x install.sh

```

3. Run the installer with elevated privileges:
```bash
sudo ./install.sh

```



---

## Command Reference

The primary binary `selfinstall` takes three parameters: target distribution, action command, and target package name.

```bash
selfinstall <arch|debian> <command> [package_name]

```

### Available Commands

| Option | Argument | Description | Example |
| --- | --- | --- | --- |
| `-S` | `<package>` | Installs the specified package inside the selected target environment. | `selfinstall debian -S mousepad` |
| `-R` | `<package>` | Purges the specified package and cleans unused dependencies. | `selfinstall debian -R mousepad` |
| `--open` | `<command>` | Executes the given application or command inside the target environment. | `selfinstall debian --open mousepad` |
| `--link` | `<package>` | Creates a `.desktop` launcher in `~/.local/share/applications`. | `selfinstall debian --link mousepad` |

---

## Troubleshooting & Maintenance

### Unmounting Environment

If you need to manually inspect or unmount the Debian filesystem without rebooting, run the following commands in order:

| Action | Command |
| --- | --- |
| Force Unmount Subtree | `sudo umount -f -R /debian-koku 2>/dev/null` |
| Remove Chroot Filesystem | `sudo rm -rf /debian-koku` |

---

## License

Distributed under the GNU Affero General Public License v3.0 (AGPLv3). See `LICENSE` for more information.

```

```

---
name: Bug report
about: Something isn't working as expected
title: ''
labels: bug
assignees: ''
---

**Describe the bug**
A clear and concise description of what went wrong.

**Command run**
The exact command you ran:
```sh
zflash flash ...
```

**Expected behavior**
What you expected to happen.

**Actual behavior**
What actually happened. Please include the full terminal output:
```
paste output here
```

**Environment**
- OS: [e.g. Ubuntu 24.04, Arch Linux, NixOS 24.05]
- Kernel: [e.g. 6.8.0] (`uname -r`)
- zflash version: [e.g. 0.1.0] (`zflash --version`)
- Zig version: [e.g. 0.14.0] (`zig version`)

**ISO and target device**
- ISO file: [e.g. nixos-minimal-24.05-x86_64-linux.iso]
- Target device: [e.g. /dev/sdb, 32GB USB stick]
- Drive detected by `zflash list`? [yes / no]

**Additional context**
Any other relevant details — hardware quirks, filesystem state, whether you ran as root, etc.

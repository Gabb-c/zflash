# zflash ⚡

> **⚠️ Work in progress — zflash is under active development and not yet ready for production use. Expect breaking changes, missing features, and rough edges. Contributions and feedback are very welcome.**

A fast, safe CLI tool for flashing OS images to USB drives — built in Zig.

`zflash` is a friendlier alternative to `dd` for writing bootable ISO images to USB drives. It validates your image before writing, guards against accidentally overwriting system drives, reports progress in real time, and verifies the write when done.

---

## Features

- **Device safety** — detects and blocks writes to mounted system drives
- **ISO validation** — checks magic bytes and file size before touching your drive
- **Progress reporting** — real-time speed, bytes written, and ETA
- **Write verification** — SHA256 read-back check after flashing
- **Single binary** — no runtime dependencies, just download and run
- **Cross-platform** *(planned)* — Linux now, macOS and Windows coming

---

## Installation

### From source

You'll need [Zig](https://ziglang.org/download/) `0.14.0` or later.

```sh
git clone https://github.com/Gabb-c/zflash
cd zflash
zig build
```

The binary will be at `zig-out/bin/zflash`.

### Pre-built binaries

> Pre-built binaries are not yet available. They will be published as GitHub releases once the project reaches a stable state.

---

## Usage

```sh
# List available USB devices
zflash list

# Flash an image
zflash flash nixos.iso /dev/sdb

# Flash and skip the verification step
zflash flash --no-verify nixos.iso /dev/sdb

# Dry run — show what would happen without writing anything
zflash flash --dry-run nixos.iso /dev/sdb
```

> **Note:** Writing to a block device requires elevated privileges. You may need to run `zflash` with `sudo`.

---

## Roadmap

zflash is being built incrementally. Here's where things stand:

- [ ] Project structure and build setup
- [ ] Device discovery (Linux `/sys/block`)
- [ ] ISO validation (magic bytes, size check)
- [ ] Safety guard (block system drives)
- [ ] Chunked write loop with progress bar
- [ ] SHA256 write verification
- [ ] macOS support (IOKit)
- [ ] Pre-built binary releases
- [ ] Windows support

---

## Platform support

| Platform | Status |
|----------|--------|
| Linux    | 🚧 In progress |
| macOS    | 🔜 Planned |
| Windows  | 🔜 Planned |

---

## Contributing

zflash is a learning project built in Zig, and contributions of all kinds are welcome — whether that's bug reports, feature ideas, code, or documentation improvements.

If you're new to Zig yourself and want to contribute while learning, this is a good project for that. The codebase is intentionally kept readable and well-commented.

**To get started:**

1. Fork the repo and clone it locally
2. Check the [open issues](https://github.com/Gabb-c/zflash/issues) for something to work on
3. Open a pull request with your changes

Please open an issue before starting work on a large feature, so we can discuss the approach first.

---

## Why Zig?

Zig is a great fit for this kind of tool — low-level I/O, no garbage collector, excellent C interop for platform APIs, and a single self-contained binary as output. This project also serves as a real-world Zig learning exercise, so the code prioritizes clarity alongside correctness.

---

## License

MIT — see [LICENSE](LICENSE) for details.

//! zflash — flash bootable USB drives from the terminal.
//!
//! This is the library root. Each module is responsible for one concern:
//!   - discovery:  enumerate block devices via /sys/block
//!   - validation: check ISO magic bytes and file size
//!   - safety:     guard against writing to system drives
//!   - writer:     chunked read/write loop with progress reporting
//!   - verify:     SHA256 read-back check after flashing

pub const discovery = @import("discovery.zig");
// pub const validation = @import("validation.zig");
// pub const safety     = @import("safety.zig");
// pub const writer     = @import("writer.zig");
// pub const verify     = @import("verify.zig");

test {
    _ = discovery;
    // _ = @import("std").testing.refAllDecls(@This());
}

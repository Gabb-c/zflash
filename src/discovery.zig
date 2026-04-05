//! Device discovery via /sys/block (Linux).
//!
//! Enumerates block devices, filters to removable drives only,
//! and returns their name, size, and path under /dev.

const std = @import("std");

/// A discovered block device candidate for flashing.
pub const Device = struct {
    /// Kernel name, e.g. "sdb"
    name: []const u8,
    /// Full path under /dev, e.g. "/dev/sdb"
    path: []const u8,
    /// Size in bytes, read from /sys/block/<name>/size (sectors * 512)
    size_bytes: u64,

    pub fn deinit(self: Device, allocator: std.mem.Allocator) void {
        allocator.free(self.name);
        allocator.free(self.path);
    }

    /// Returns a human-readable size string, e.g. "7.5 GB".
    /// Caller owns the returned slice.
    pub fn formatSize(self: Device, allocator: std.mem.Allocator) ![]const u8 {
        const gb = @as(f64, @floatFromInt(self.size_bytes)) / (1024 * 1024 * 1024);
        const mb = @as(f64, @floatFromInt(self.size_bytes)) / (1024 * 1024);

        if (gb >= 1.0) {
            return std.fmt.allocPrint(allocator, "{d:.1} GB", .{gb});
        } else {
            return std.fmt.allocPrint(allocator, "{d:.1} MB", .{mb});
        }
    }
};

/// Scans /sys/block and returns all removable block devices.
/// Caller owns the returned slice and must call freeDevices().
pub fn listDevices(allocator: std.mem.Allocator) ![]Device {
    var devices: std.ArrayListUnmanaged(Device) = .empty;
    errdefer {
        for (devices.items) |d| d.deinit(allocator);
        devices.deinit(allocator);
    }

    var sys_block = try std.fs.openDirAbsolute("/sys/block", .{ .iterate = true });
    defer sys_block.close();

    var iter = sys_block.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind != .sym_link and entry.kind != .directory) continue;

        const removable = try isRemovable(entry.name);
        if (!removable) continue;

        const size = try readSizeBytes(entry.name);
        if (size == 0) continue;

        const name = try allocator.dupe(u8, entry.name);
        errdefer allocator.free(name);

        const path = try std.fmt.allocPrint(allocator, "/dev/{s}", .{entry.name});
        errdefer allocator.free(path);

        try devices.append(allocator, .{
            .name = name,
            .path = path,
            .size_bytes = size,
        });
    }

    return devices.toOwnedSlice(allocator);
}

/// Frees a slice returned by listDevices().
pub fn freeDevices(allocator: std.mem.Allocator, devices: []Device) void {
    for (devices) |d| d.deinit(allocator);
    allocator.free(devices);
}

/// Reads /sys/block/<name>/removable and returns true if the value is "1".
fn isRemovable(name: []const u8) !bool {
    var path_buf: [128]u8 = undefined;
    const path = try std.fmt.bufPrint(&path_buf, "/sys/block/{s}/removable", .{name});

    const file = std.fs.openFileAbsolute(path, .{}) catch |err| switch (err) {
        error.FileNotFound => return false,
        else => return err,
    };
    defer file.close();

    var buf: [4]u8 = undefined;
    const n = try file.read(&buf);
    const value = std.mem.trim(u8, buf[0..n], "\n ");

    return std.mem.eql(u8, value, "1");
}

/// Reads /sys/block/<name>/size (number of 512-byte sectors)
/// and returns total size in bytes.
fn readSizeBytes(name: []const u8) !u64 {
    var path_buf: [128]u8 = undefined;
    const path = try std.fmt.bufPrint(&path_buf, "/sys/block/{s}/size", .{name});

    const file = std.fs.openFileAbsolute(path, .{}) catch |err| switch (err) {
        error.FileNotFound => return 0,
        else => return err,
    };
    defer file.close();

    var buf: [32]u8 = undefined;
    const n = try file.read(&buf);
    const value = std.mem.trim(u8, buf[0..n], "\n ");

    const sectors = try std.fmt.parseInt(u64, value, 10);
    return sectors * 512;
}

// ----------------------------------------------------------------------------
// Tests
// ----------------------------------------------------------------------------

test "formatSize GB" {
    const allocator = std.testing.allocator;
    const dev = Device{
        .name = "sdb",
        .path = "/dev/sdb",
        .size_bytes = 8 * 1024 * 1024 * 1024, // 8 GB
    };
    const s = try dev.formatSize(allocator);
    defer allocator.free(s);
    try std.testing.expectEqualStrings("8.0 GB", s);
}

test "formatSize MB" {
    const allocator = std.testing.allocator;
    const dev = Device{
        .name = "sdb",
        .path = "/dev/sdb",
        .size_bytes = 512 * 1024 * 1024, // 512 MB
    };
    const s = try dev.formatSize(allocator);
    defer allocator.free(s);
    try std.testing.expectEqualStrings("512.0 MB", s);
}

test "formatSize stays in MB just under 1 GB" {
    const allocator = std.testing.allocator;
    const dev = Device{
        .name = "sdb",
        .path = "/dev/sdb",
        .size_bytes = 900 * 1024 * 1024,
    };
    const s = try dev.formatSize(allocator);
    defer allocator.free(s);
    try std.testing.expectEqualStrings("900.0 MB", s);
}

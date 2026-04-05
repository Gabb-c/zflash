const std = @import("std");

const usage =
    \\Usage: zflash <command> [options]
    \\
    \\Commands:
    \\  list                     List available USB devices
    \\  flash <image> <device>   Flash an image to a device
    \\
    \\Options:
    \\  --no-verify   Skip SHA256 verification after flashing
    \\  --dry-run     Show what would happen without writing anything
    \\  --version     Print version and exit
    \\  --help        Print this help and exit
    \\
    \\Examples:
    \\  zflash list
    \\  zflash flash nixos.iso /dev/sdb
    \\  zflash flash --dry-run nixos.iso /dev/sdb
    \\
;

const stdout = std.fs.File.stdout();
const stderr = std.fs.File.stderr();

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        try printUsage();
        std.process.exit(1);
    }

    const subcommand = args[1];

    if (std.mem.eql(u8, subcommand, "--help") or std.mem.eql(u8, subcommand, "-h")) {
        try printUsage();
        return;
    }

    if (std.mem.eql(u8, subcommand, "--version")) {
        try stdout.writeAll("zflash 0.0.0\n");
        return;
    }

    if (std.mem.eql(u8, subcommand, "list")) {
        try cmdList(allocator, args[2..]);
        return;
    }

    if (std.mem.eql(u8, subcommand, "flash")) {
        try cmdFlash(allocator, args[2..]);
        return;
    }

    var buf: [256]u8 = undefined;
    const msg = try std.fmt.bufPrint(&buf, "error: unknown command '{s}'\n\n", .{subcommand});
    try stderr.writeAll(msg);
    try printUsage();
    std.process.exit(1);
}

fn cmdList(allocator: std.mem.Allocator, args: []const []const u8) !void {
    _ = args;
    const discovery = @import("zflash").discovery;

    const devices = try discovery.listDevices(allocator);
    defer discovery.freeDevices(allocator, devices);

    if (devices.len == 0) {
        try stdout.writeAll("no removable devices found\n");
        return;
    }

    try stdout.writeAll("available devices:\n\n");
    for (devices) |dev| {
        const size = try dev.formatSize(allocator);
        defer allocator.free(size);
        var buf: [256]u8 = undefined;
        const line = try std.fmt.bufPrint(
            &buf,
            "  {s:<12}  {s}\n",
            .{ dev.path, size },
        );
        try stdout.writeAll(line);
    }
}

fn cmdFlash(allocator: std.mem.Allocator, args: []const []const u8) !void {
    _ = allocator;

    var dry_run = false;
    var no_verify = false;
    var image_path: ?[]const u8 = null;
    var device_path: ?[]const u8 = null;

    for (args) |arg| {
        if (std.mem.eql(u8, arg, "--dry-run")) {
            dry_run = true;
        } else if (std.mem.eql(u8, arg, "--no-verify")) {
            no_verify = true;
        } else if (image_path == null) {
            image_path = arg;
        } else if (device_path == null) {
            device_path = arg;
        } else {
            var buf: [256]u8 = undefined;
            const msg = try std.fmt.bufPrint(&buf, "error: unexpected argument '{s}'\n", .{arg});
            try stderr.writeAll(msg);
            std.process.exit(1);
        }
    }

    if (image_path == null or device_path == null) {
        try stderr.writeAll("error: flash requires <image> and <device>\n\n");
        try printUsage();
        std.process.exit(1);
    }

    if (dry_run) {
        var buf: [512]u8 = undefined;
        const msg = try std.fmt.bufPrint(&buf, "dry run: would flash '{s}' to '{s}'\n", .{ image_path.?, device_path.? });
        try stdout.writeAll(msg);
        return;
    }

    // TODO: call zflash.validation.validate(image_path)
    // TODO: call zflash.safety.check(device_path)
    // TODO: call zflash.writer.flash(image_path, device_path, .{ .verify = !no_verify })
    var buf: [512]u8 = undefined;
    const msg = try std.fmt.bufPrint(&buf, "(writer not yet implemented) image={s} device={s} verify={}\n", .{
        image_path.?,
        device_path.?,
        !no_verify,
    });
    try stdout.writeAll(msg);
}

fn printUsage() !void {
    try stderr.writeAll(usage);
}

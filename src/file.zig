const std = @import("std");
const hasher = @import("./hasher.zig");
const json = @import("./json.zig");

pub fn write_data(alloc: std.mem.Allocator, init: std.process.Init, key: [32]u8, nonce: [12]u8) !void {
    const file = try std.Io.Dir.cwd().readFileAlloc(init.io, ".env", alloc, .unlimited);

    defer alloc.free(file);

    const encrypted = try hasher.encrypt(alloc, file, key, nonce);

    defer alloc.free(encrypted);

    const fmted = try std.fmt.allocPrint(alloc, "{x}", .{encrypted});

    defer alloc.free(fmted);

    const data = json.Info{ .data = fmted };

    var out = std.Io.Writer.Allocating.init(alloc);

    defer out.deinit();

    var stringifier = std.json.Stringify{
        .writer = &out.writer,
        .options = .{ .whitespace = .indent_2 },
    };

    try stringifier.write(data);

    const new_file = try std.Io.Dir.cwd().createFile(init.io, "./.env.local", .{ .read = true });

    defer new_file.close(init.io);

    _ = try new_file.writeStreaming(init.io, "", &.{out.writer.buffered()}, 1);
}

pub fn read_data(alloc: std.mem.Allocator, init: std.process.Init, key: [32]u8, nonce: [12]u8) ![]const u8 {
    const info = try json.parse_info(alloc, init);

    std.debug.print("{s} \n", .{info.data});

    var buffer: [64]u8 = undefined;

    const bytes = try std.fmt.hexToBytes(&buffer, info.data);

    return try hasher.decrypt(alloc, bytes, key, nonce);
}

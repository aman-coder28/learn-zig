const std = @import("std");
const hasher = @import("./hasher.zig");
const json = @import("./json.zig");

pub fn write_data(alloc: std.mem.Allocator, init: std.Io, key: [32]u8, nonce: [12]u8) !void {
    const file = try std.Io.Dir.cwd().readFileAlloc(init, ".env", alloc, .unlimited);

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

    const new_file = try std.Io.Dir.cwd().createFile(init, "./.env.local", .{ .read = true });

    defer new_file.close(init);

    _ = try new_file.writeStreaming(init, "", &.{out.writer.buffered()}, 1);
}

pub fn read_data(alloc: std.mem.Allocator, init: std.Io, key: [32]u8, nonce: [12]u8) ![]const u8 {
    const info = try json.parse_info(alloc, init);

    defer info.deinit();

    std.debug.print("{s} \n", .{info.value.data});

    const raw_len = info.value.data.len / 2;

    const buffer = try alloc.alloc(u8, raw_len);
    defer alloc.free(buffer);

    const bytes = try std.fmt.hexToBytes(buffer, info.value.data);

    return try hasher.decrypt(alloc, bytes, key, nonce);
}

const std = @import("std");
const hasher = @import("./hasher.zig");
const json = @import("./json.zig");

pub fn read_file(alloc: std.mem.Allocator, io: std.Io, file_name: []const u8) ![]const u8 {
    return try std.Io.Dir.cwd().readFileAlloc(io, file_name, alloc, .unlimited);
}

pub fn isJson(allocator: std.mem.Allocator, text: []const u8) !bool {
    const is_json = try json.parse_info(allocator, text);

    defer is_json.deinit();

    return is_json.value.data.len > 0;
}

pub fn write_data(alloc: std.mem.Allocator, init: std.Io, password: []const u8, file_name: []const u8) !void {
    const file = try std.Io.Dir.cwd().readFileAlloc(init, file_name, alloc, .unlimited);

    defer alloc.free(file);

    const encrypted = try hasher.encryptWithPassword(alloc, init, file, password);

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

    const new_file = try std.Io.Dir.cwd().createFile(init, file_name, .{ .read = true });

    defer new_file.close(init);

    _ = try new_file.writeStreaming(init, "", &.{out.writer.buffered()}, 1);
}

pub fn read_data(alloc: std.mem.Allocator, init: std.Io, password: []const u8, file_name: []const u8) ![]const u8 {
    const content = try read_file(alloc, init, file_name);
    defer alloc.free(content);

    const info = try json.parse_info(alloc, content);

    defer info.deinit();

    const raw_len = info.value.data.len / 2;

    const buffer = try alloc.alloc(u8, raw_len);
    defer alloc.free(buffer);

    const bytes = try std.fmt.hexToBytes(buffer, info.value.data);

    return try hasher.decryptWithPassword(alloc, init, bytes, password);
}

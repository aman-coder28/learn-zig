const std = @import("std");
const file = @import("./file.zig");
const heap = std.heap;

pub fn main(init: std.process.Init) !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer {
        _ = gpa.deinit();
    }
    const allocator = gpa.allocator();

    const file_name = try get_args(allocator, init);

    const content = try file.read_file(allocator, init.io, file_name);
    defer allocator.free(content);

    const is_json = file.isJson(allocator, content) catch false;

    var buf: [64]u8 = undefined;

    const password = try readline(init.io, &buf, "Enter Your Password: \n");

    if (is_json) {
        const result = try file.read_data(allocator, init.io, password, file_name);
        defer allocator.free(result);

        var stdout_buf: [512]u8 = undefined;
        var stdout_writer = std.Io.File.stdout().writer(init.io, &stdout_buf);
        const stdout = &stdout_writer.interface;

        try stdout.writeAll(result);
        try stdout.flush();
    } else {
        std.debug.print("{s} data will be encrypted now.", .{file_name});

        _ = try file.write_data(allocator, init.io, password, file_name);
    }
}

fn get_args(allocator: std.mem.Allocator, init: std.process.Init) ![]const u8 {
    var args_iter = try init.minimal.args.iterateAllocator(allocator);
    defer args_iter.deinit();

    const remaining = args_iter.inner.remaining;

    if (remaining.len >= 2) {
        return std.mem.span(remaining[1]);
    } else {
        return ".env";
    }
}

fn readline(init: std.Io, buf: []u8, text: []const u8) ![]const u8 {
    std.debug.print("{s}", .{text});

    var stdin_reader = std.Io.File.stdin().reader(init, buf);
    const reader = &stdin_reader.interface;

    const line = try reader.takeDelimiter('\n') orelse unreachable;

    return std.mem.trim(u8, line, "\r");
}

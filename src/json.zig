const std = @import("std");

pub const Info = struct { data: []const u8 };

pub fn parse_info(alloc: std.mem.Allocator, init: std.Io) !std.json.Parsed(Info) {
    const file = try std.Io.Dir.cwd().readFileAlloc(init, "./.env.local", alloc, .unlimited);

    defer alloc.free(file);

    return try std.json.parseFromSlice(Info, alloc, file, .{
        .ignore_unknown_fields = true,
        .allocate = .alloc_always,
    });
}

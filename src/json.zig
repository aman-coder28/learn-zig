const std = @import("std");

pub const Info = struct { data: []const u8 };

pub fn parse_info(alloc: std.mem.Allocator, init: std.Io, file_name: []const u8) !std.json.Parsed(Info) {
    const file = try std.Io.Dir.cwd().readFileAlloc(init, file_name, alloc, .unlimited);

    defer alloc.free(file);

    return try std.json.parseFromSlice(Info, alloc, file, .{
        .ignore_unknown_fields = true,
        .allocate = .alloc_always,
    });
}

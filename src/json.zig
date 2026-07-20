const std = @import("std");

pub const Info = struct { data: []const u8 };

pub fn parse_info(alloc: std.mem.Allocator, text: []const u8) !std.json.Parsed(Info) {
    return try std.json.parseFromSlice(Info, alloc, text, .{
        .ignore_unknown_fields = true,
        .allocate = .alloc_always,
    });
}

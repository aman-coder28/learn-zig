const std = @import("std");

pub const Info = struct { data: []const u8 };

pub fn parse_info(alloc: std.mem.Allocator, init: std.process.Init) !Info {
    const file = try std.Io.Dir.cwd().readFileAlloc(init.io, "./.env.local", alloc, .unlimited);

    const parsed = try std.json.parseFromSlice(Info, alloc, file, .{
        .ignore_unknown_fields = true,
    });

    return parsed.value;
}

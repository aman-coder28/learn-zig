const std = @import("std");

pub fn cap(word: []const u8, allocator: std.mem.Allocator) ![]u8 {
    const first = word[0];
    const others = word[1..];

    const upper = try std.ascii.allocUpperString(allocator, &.{first});
    const result = try std.mem.join(allocator, "", &[2][]const u8{ upper, others });

    defer allocator.free(upper);

    return result;
}

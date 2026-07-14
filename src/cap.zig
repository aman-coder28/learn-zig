const std = @import("std");

pub fn cap(word: []const u8, allocator: std.mem.Allocator) ![]u8 {
    const first = word[0];
    const others = word[1..];

    const upper = try std.ascii.allocUpperString(allocator, &.{first});
    const result = try std.mem.join(allocator, "", &[2][]const u8{ upper, others });

    defer allocator.free(upper);

    return result;
}

pub fn capper(word: []const u8, allocator: std.mem.Allocator) ![]const u8 {
    var w = std.mem.splitScalar(u8, word, ' ');
    var parts: std.ArrayList([]const u8) = .empty;
    defer parts.deinit(allocator);

    while (w.next()) |part| {
        const c = try cap(part, allocator);

        try parts.append(allocator, c);
    }

    defer for (parts.items) |p| allocator.free(p);

    return try std.mem.join(allocator, " ", parts.items);
}

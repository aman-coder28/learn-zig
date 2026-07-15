const std = @import("std");
const cap = @import("cap.zig");
const hasher = @import("hasher.zig");
const print = std.debug.print;
const heap = std.heap;

pub fn main() !void {
    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const text = "hi, hello world?";
    const key = "aa55b3794e674ccf8a3758021c3d7284";

    const encrypted = try hasher.encrypt(
        allocator,
        text,
        @constCast(key).*,
        @constCast("8af80924f4ab").*,
    );

    print("{x} \n", .{encrypted});

    print("{s} \n", .{try hasher.decrypt(
        allocator,
        encrypted,
        @constCast(key).*,
        @constCast("8af80924f4ab").*,
    )});
}

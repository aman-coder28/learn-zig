const std = @import("std");
const calc = @import("calc.zig").calc;
const cap = @import("cap.zig");
const print = std.debug.print;
const heap = std.heap;

// init: std.process.Init
pub fn main() !void {
    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();

    // calc(init);

    const allocator = arena.allocator();
    const text = "hello world";

    print("{s}", .{try cap.capper(text, allocator)});
}

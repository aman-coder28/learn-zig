const std = @import("std");
const calc = @import("calc.zig").calc;
const cap = @import("cap.zig");
const print = std.debug.print;
const heap = std.heap;

// input: std.process.Init
pub fn main() !void {
    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();

    // calc(input);

    const allocator = arena.allocator();
    const text = "hello";

    print("{s}", .{try cap.cap(text, allocator)});
}

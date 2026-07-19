const std = @import("std");
const heap = std.heap;

pub fn main(init: std.process.Init) !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer {
        _ = gpa.deinit();
    }

    const allocator = gpa.allocator();

    var args_iter = try init.minimal.args.iterateAllocator(allocator);
    defer args_iter.deinit();

    const remaining = args_iter.inner.remaining;

    if (remaining.len >= 2) {
        std.debug.print("{s}", .{remaining[1]});
    } else {
        std.debug.print("{s}", .{remaining[0]});
    }
}

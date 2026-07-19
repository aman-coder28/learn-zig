const std = @import("std");
const heap = std.heap;

pub fn main(init: std.process.Init) !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer {
        _ = gpa.deinit();
    }
    const allocator = gpa.allocator();

    const file = try get_args(allocator, init);

    // defer allocator.free(file);

    std.debug.print("{s}", .{file});
}

fn get_args(allocator: std.mem.Allocator, init: std.process.Init) ![]const u8 {
    var args_iter = try init.minimal.args.iterateAllocator(allocator);
    defer args_iter.deinit();

    const remaining = args_iter.inner.remaining;

    if (remaining.len >= 2) {
        return std.mem.span(remaining[1]);
    } else {
        return ".env";
    }
}

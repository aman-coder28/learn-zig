const std = @import("std");
const cap = @import("cap.zig");
const hasher = @import("hasher.zig");
const file = @import("file.zig");
const print = std.debug.print;
const heap = std.heap;

pub fn main(init: std.process.Init) !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer {
        _ = gpa.deinit();
    }

    const allocator = gpa.allocator();

    // _ = try file.write_data(
    //     allocator,
    //     init,
    //     @constCast(key).*,
    //     @constCast("8af80924f4ab").*,
    // );

    // const data = try file.read_data(
    //     allocator,
    //     init,
    //     @constCast(key).*,
    //     @constCast("8af80924f4ab").*,
    // );

    // defer allocator.free(data);

    const encrypted = try hasher.encryptWithPassword(
        allocator,
        init,
        "text",
        "password",
    );

    defer allocator.free(encrypted);

    const decrypted = try hasher.decryptWithPassword(
        allocator,
        init,
        encrypted,
        "password",
    );

    defer allocator.free(decrypted);

    print("{x} \n{s} \n", .{ encrypted, decrypted });
}

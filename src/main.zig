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

    const key = "aa55b3794e674ccf8a3758021c3d7284";

    // const encrypted = try hasher.encrypt(
    //     allocator,
    //     text,
    //     @constCast(key).*,
    //     @constCast("8af80924f4ab").*,
    // );

    // print("{x} \n", .{encrypted});

    // print("{s} \n", .{try hasher.decrypt(
    //     allocator,
    //     encrypted,
    //     @constCast(key).*,
    //     @constCast("8af80924f4ab").*,
    // )});

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

    const encrypted = try hasher.encrypt(
        allocator,
        init,
        "password",
        @constCast(key).*,
    );

    defer allocator.free(encrypted);

    const decrypted = try hasher.decrypt(
        allocator,
        encrypted,
        @constCast(key).*,
    );

    defer allocator.free(decrypted);

    print("{s} \n", .{decrypted});
}

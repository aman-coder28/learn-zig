const std = @import("std");
const hasher = @import("./hasher.zig");
const testing = std.testing;
const io = std.testing.io;

test "basic divide functionality" {
    const encrypted = try hasher.encryptWithPassword(
        testing.allocator,
        io,
        "text",
        "password",
    );

    const decrypted = try hasher.decryptWithPassword(
        testing.allocator,
        io,
        encrypted,
        "password",
    );
    defer {
        _ = testing.allocator.free(encrypted);
        _ = testing.allocator.free(decrypted);
    }

    try std.testing.expectEqualStrings(
        decrypted,
        "text",
    );
}

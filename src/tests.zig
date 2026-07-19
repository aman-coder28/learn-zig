const std = @import("std");
const hasher = @import("./hasher.zig");
const allocator = std.testing.allocator;
const io = std.testing.io;

test "encryption and decryption" {
    const encrypted = try hasher.encryptWithPassword(
        allocator,
        io,
        "text",
        "password",
    );

    const cipher = "3324082eed31be2863d96c4abd9754606bd3023c1ecec4b870ba20448c9896b2d1cf2033617b93fe4cdaa110ef4a28da";

    const buffer = try allocator.alloc(u8, cipher.len);
    defer allocator.free(buffer);

    const bytes = try std.fmt.hexToBytes(buffer, cipher);

    const decrypted = try hasher.decryptWithPassword(
        allocator,
        io,
        bytes,
        "password",
    );

    defer {
        _ = allocator.free(encrypted);
        _ = allocator.free(decrypted);
    }

    try std.testing.expectEqualStrings(
        decrypted,
        "text",
    );
}

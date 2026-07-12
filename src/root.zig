const std = @import("std");

pub fn divide(x: f32, y: f32) !f32 {
    if (y == 0) {
        return error.NoDivisionByZero;
    } else if (x == 0) {
        return error.XCantBeZero;
    }

    return x / y;
}

test "basic divide functionality" {
    try std.testing.expect(try divide(5, 2) == 2.5);
    try std.testing.expect(divide(0, 2) catch 1 == 1);
}

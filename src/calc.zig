const std = @import("std");
const divide = @import("root.zig").divide;
const print = std.debug.print;

pub fn calc(input: std.Io) void {
    var buf: [64]u8 = undefined;

    const first = readline_to_float(input, &buf, "Enter the first Number: ") catch 0;

    const opr_line = readline(input, &buf, "Enter an Operator: ") catch " ";
    const opr: u8 = if (opr_line.len > 0) opr_line[0] else ' ';

    const second = readline_to_float(input, &buf, "Enter the second Number: ") catch 0;

    calculate(first, opr, second);
}

fn calculate(
    first: f32,
    opr: u8,
    second: f32,
) void {
    switch (opr) {
        '+' => calc_print(first, opr, second, first + second),
        '-' => calc_print(first, opr, second, first - second),
        'x' => calc_print(first, opr, second, first * second),
        '/' => calc_print(first, opr, second, divide(first, second) catch |err| switch (err) {
            error.NoDivisionByZero => 0.0,
            error.XCantBeZero => 1.0,
        }),
        else => print("\n please enter a valid operator (+, -, x, /). \n", .{}),
    }
}

fn calc_print(first: f32, opr: u8, second: f32, res: f32) void {
    print("\n{d} {c} {d} = {d} \n", .{ first, opr, second, res });
}

fn readline(init: std.Io, buf: []u8, text: []const u8) ![]const u8 {
    print("{s}", .{text});
    var stdin_reader = std.Io.File.stdin().reader(init, buf);
    const reader = &stdin_reader.interface;

    const line = try reader.takeDelimiter('\n') orelse unreachable;

    return std.mem.trim(u8, line, "\r");
}

fn readline_to_float(init: std.Io, buf: []u8, text: []const u8) !f32 {
    const line = readline(init, buf, text) catch "";

    return std.fmt.parseFloat(f32, line) catch 0;
}

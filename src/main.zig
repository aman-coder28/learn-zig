const std = @import("std");
const calc = @import("calc.zig").calc;

const print = std.debug.print;

pub fn main(input: std.process.Init) !void {
    calc(input);
}

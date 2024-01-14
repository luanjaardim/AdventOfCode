const std = @import("std");

pub fn main() !void {
    const mul = 252533;
    const sla = 20151125;
    std.debug.print("{}\n", .{sla * mul});
}

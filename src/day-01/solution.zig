const std = @import("std");
const builtin = @import("builtin");

fn part1(input: []const u8, allocator: std.mem.Allocator) !u32 {
    var loc_ids_1 = std.ArrayList(u32).init(allocator);
    var loc_ids_2 = std.ArrayList(u32).init(allocator);
    defer loc_ids_1.deinit();
    defer loc_ids_2.deinit();

    var line_it = std.mem.tokenize(u8, input, "\r\n");
    while (line_it.next()) |line| {
        var iter = std.mem.tokenize(u8, line, " ");
        const col1 = try std.fmt.parseInt(u32, iter.next().?, 10);
        const col2 = try std.fmt.parseInt(u32, iter.next().?, 10);
        try loc_ids_1.append(col1);
        try loc_ids_2.append(col2);
    }

    const sort_func = std.sort.asc(u32);
    std.mem.sort(u32, loc_ids_1.items, {}, sort_func);
    std.mem.sort(u32, loc_ids_2.items, {}, sort_func);

    var total_diff: u32 = 0;
    for (loc_ids_1.items, loc_ids_2.items) |num1, num2| {
        total_diff += @max(num1, num2) - @min(num1, num2);
    }

    return total_diff;
}

fn part2(input: []const u8, allocator: std.mem.Allocator) !u32 {
    var loc_ids_1 = std.ArrayList(u32).init(allocator);
    var loc_ids_2 = std.ArrayList(u32).init(allocator);
    defer loc_ids_1.deinit();
    defer loc_ids_2.deinit();

    var line_it = std.mem.tokenize(u8, input, "\r\n");
    while (line_it.next()) |line| {
        var iter = std.mem.tokenize(u8, line, " ");
        const col1 = try std.fmt.parseInt(u32, iter.next().?, 10);
        const col2 = try std.fmt.parseInt(u32, iter.next().?, 10);
        try loc_ids_1.append(col1);
        try loc_ids_2.append(col2);
    }

    var map = std.AutoHashMap(u32, u32).init(allocator);
    defer map.deinit();

    for (loc_ids_2.items) |item| {
        if (map.get(item)) |cnt| {
            try map.put(item, cnt + 1);
        } else {
            try map.put(item, 1);
        }
    }

    var similarity: u32 = 0;
    for (loc_ids_1.items) |num| {
        if (map.get(num)) |cnt| {
            similarity += num * cnt;
        }
    }

    return similarity;
}

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Hello World!\n", .{});

    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();
    var br = std.io.bufferedReader(file.reader());
    const reader = br.reader();
    const input = try reader.readAllAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(input);

    var timer = try std.time.Timer.start();
    const part1_output = try part1(input, allocator);
    const part1_elapsed_ns = timer.read();

    try stdout.print("Part 1: {}\n", .{part1_output});
    try stdout.print("time elapsed: {}us\n", .{part1_elapsed_ns / std.time.ns_per_us});

    timer.reset();
    const part2_output = try part2(input, allocator);
    const part2_elapsed_ns = timer.read();
    try stdout.print("Part 2: {}\n", .{part2_output});
    try stdout.print("time elapsed: {}us\n", .{part2_elapsed_ns / std.time.ns_per_us});

    try bw.flush();
}

test "01_example" {
    const input =
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
    ;
    try std.testing.expectEqual(11, try part1(input, std.testing.allocator));
}

test "02_example" {
    const input =
        \\ 3   4
        \\ 4   3
        \\ 2   5
        \\ 1   3
        \\ 3   9
        \\ 3   3
    ;
    try std.testing.expectEqual(31, try part2(input, std.testing.allocator));
}

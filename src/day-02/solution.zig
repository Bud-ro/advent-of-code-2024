const std = @import("std");
const builtin = @import("builtin");

fn is_safe(items: []u32) bool {
    var safe_ascending = true;
    var safe_descending = true;
    var pair_it = std.mem.window(u32, items, 2, 1);
    while (pair_it.next()) |pair| {
        const diff = @max(pair[0], pair[1]) - @min(pair[0], pair[1]);
        if (!(pair[0] < pair[1] and diff <= 3)) {
            safe_ascending = false;
        }
        if (!(pair[0] > pair[1] and diff <= 3)) {
            safe_descending = false;
        }

        if (!safe_ascending and !safe_descending) {
            return false;
        }
    }

    return true;
}

fn part1(input: []const u8, allocator: std.mem.Allocator) !u32 {
    var levels = std.ArrayList(u32).init(allocator);
    defer levels.deinit();

    var safe_cnt: u32 = 0;

    var line_it = std.mem.tokenize(u8, input, "\r\n");
    while (line_it.next()) |line| {
        levels.clearRetainingCapacity();
        var level_iter = std.mem.tokenize(u8, line, " ");
        while (level_iter.next()) |level| {
            try levels.append(try std.fmt.parseInt(u32, level, 10));
        }

        if (is_safe(levels.items)) {
            safe_cnt += 1;
        }
    }

    return safe_cnt;
}

fn part2(input: []const u8, allocator: std.mem.Allocator) !u32 {
    var levels = std.ArrayList(u32).init(allocator);
    defer levels.deinit();

    var safe_cnt: u32 = 0;

    var line_it = std.mem.tokenize(u8, input, "\r\n");
    blk: while (line_it.next()) |line| {
        levels.clearRetainingCapacity();
        var level_iter = std.mem.tokenize(u8, line, " ");
        while (level_iter.next()) |level| {
            try levels.append(try std.fmt.parseInt(u32, level, 10));
        }

        // Generate Permutations
        var permutation = std.ArrayList(u32).init(allocator);
        defer permutation.deinit();

        for (0..levels.items.len) |ignore_idx| {
            permutation.clearRetainingCapacity();
            for (levels.items, 0..) |item, i| {
                if (i != ignore_idx) {
                    try permutation.append(item);
                }
            }

            if (is_safe(permutation.items)) {
                safe_cnt += 1;
                continue :blk;
            }
        }
    }

    return safe_cnt;
}

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

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
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
    ;
    try std.testing.expectEqual(2, try part1(input, std.testing.allocator));
}

test "02_example" {
    const input =
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
    ;
    try std.testing.expectEqual(4, try part2(input, std.testing.allocator));
}

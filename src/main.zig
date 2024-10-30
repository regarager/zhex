const std = @import("std");

pub fn main() !void {
    const print = std.debug.print;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        print("Usage: zhex <file>\n", .{});
        std.process.exit(0);
    }

    const filename = args[1];

    const file = std.fs.cwd().openFile(filename, .{}) catch |err| {
        print("An error occurred while opening {s}: {}\n", .{ filename, err });
        std.process.exit(1);
    };

    var buf: [1 << 16]u8 = undefined;
    const bufsize = file.readAll(&buf) catch |err| {
        print("An error occurred while opening {s}: {}\n", .{ filename, err });
        std.process.exit(1);
    };

    const rowWidth = 0x10;
    const rows = bufsize / rowWidth;
    for (0..rows) |row| {
        print("{x:08} | ", .{row * rowWidth});
        for (0..rowWidth) |i| {
            print("{x:02} ", .{buf[row * rowWidth + i]});
        }

        print("| ", .{});

        for (0..rowWidth) |i| {
            const char = buf[row * rowWidth + i];

            if (char > 0x1f and char < 0x7f) {
                print("{c}", .{char});
            } else {
                print(".", .{});
            }
        }

        print("\n", .{});
    }

    const lastRow = bufsize % 16;

    if (lastRow > 0) {
        print("{x:08} | ", .{rows * 16});
        for (0..lastRow) |i| {
            print("{x:02} ", .{buf[rows * 16 + i]});
        }
        print("\n", .{});
    }
}

const std = @import("std");
const Io = std.Io;

const bitboard = @import("bitboard");
const BitBoard = bitboard.BitBoard;

pub fn main(init: std.process.Init) !void {
    // Prints to stderr, unbuffered, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // This is appropriate for anything that lives as long as the process.
    const arena: std.mem.Allocator = init.arena.allocator();

    // Accessing command line arguments:
    const args = try init.minimal.args.toSlice(arena);
    for (args) |arg| {
        std.log.info("arg: {s}", .{arg});
    }

    // In order to do I/O operations need an `Io` instance.
    const io = init.io;

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    var bit_board: BitBoard = .empty;
    // bit_board.setSquare(.d4);
    bit_board.setSquare(.c5);
    bit_board.setSquare(.e5);

    bit_board.setSquare(.c6);
    bit_board.setSquare(.d6);
    bit_board.setSquare(.e6);

    bit_board.setSquare(.e4);
    bit_board.setSquare(.d4);
    bit_board.setSquare(.c4);

    try bit_board.print(stdout_writer);

    try stdout_writer.flush(); // Don't forget to flush!
}

// ===========================================================================
//
//  Bitboard chess engine
//
// ===========================================================================

const std = @import("std");
const Io = std.Io;

/// board squares
pub const board_squares = enum {
    // rank 8
    a8,
    b8,
    c8,
    d8,
    e8,
    f8,
    g8,
    h8,
    // rank 7
    a7,
    b7,
    c7,
    d7,
    e7,
    f7,
    g7,
    h7,
    // rank 6
    a6,
    b6,
    c6,
    d6,
    e6,
    f6,
    g6,
    h6,
    // rank 5
    a5,
    b5,
    c5,
    d5,
    e5,
    f5,
    g5,
    h5,
    // rank 4
    a4,
    b4,
    c4,
    d4,
    e4,
    f4,
    g4,
    h4,
    // rank 3
    a3,
    b3,
    c3,
    d3,
    e3,
    f3,
    g3,
    h3,
    // rank 2
    a2,
    b2,
    c2,
    d2,
    e2,
    f2,
    g2,
    h2,
    // rank 1
    a1,
    b1,
    c1,
    d1,
    e1,
    f1,
    g1,
    h1,
};

/// bitboard data type
pub const BitBoard = std.bit_set.StaticBitSet(64);

/// PLACEHOLDER
pub fn print_bitboard(bitboard: BitBoard, writer: *Io.Writer) Io.Writer.Error!void {
    for (0..8) |file| {
        try writer.print("\n  {} ", .{8 - file});
        for (0..8) |rank| {
            const square = file * 8 + rank;
            try writer.print(" {}", .{if (bitboard.isSet(square)) @as(u8, 1) else @as(u8, 0)});
        }
    }
    try writer.print("\n\n     a b c d e f g h", .{});
    try writer.print("\n\n     BitBoard: {}\n\n", .{bitboard.mask});
}

// ===========================================================================
//
//  Attacks
//
// ===========================================================================

/// sides to move (colors)
pub const sides = enum {
    white,
    black,
};

/// PLACEHOLDER
pub const not_a_file: BitBoard = .{ .mask = 0 };

/// PLACEHOLDER
pub const not_h_file: BitBoard = .{ .mask = 0 };

/// PLACEHOLDER
pub const not_hg_file: BitBoard = .{ .mask = 0 };

/// PLACEHOLDER
pub const not_ab_file: BitBoard = .{ .mask = 0 };

/// pawn attacks table [side][square]
///
/// PLACEHOLDER
pub var pawn_attacks: [2][64]BitBoard = @splat(@splat(BitBoard.empty));

/// PLACEHOLDER
pub fn mask_pawn_attacks(side: sides, square: u6) BitBoard {
    _ = side;
    _ = square;
    @panic("mask_pawn_attacks: not implemented yet");
}

/// PLACEHOLDER
pub fn init_leapers_attacks() void {
    @panic("init_leapers_attacks: not implemented yet");
}

// ===========================================================================
//
//  Tests
//
// ===========================================================================

/// Test only: renders a bitboard through `print_bitboard` into `buffer` and
/// returns the bytes that were written to it.
fn rendered(bitboard: BitBoard, buffer: []u8) ![]u8 {
    var writer: Io.Writer = .fixed(buffer);
    try print_bitboard(bitboard, &writer);
    return writer.buffered();
}

test "board_squares: the 64 squares are numbered from a8 to h1" {
    // rank 8
    try std.testing.expectEqual(@as(u6, 0), @intFromEnum(board_squares.a8));
    try std.testing.expectEqual(@as(u6, 1), @intFromEnum(board_squares.b8));
    try std.testing.expectEqual(@as(u6, 2), @intFromEnum(board_squares.c8));
    try std.testing.expectEqual(@as(u6, 3), @intFromEnum(board_squares.d8));
    try std.testing.expectEqual(@as(u6, 4), @intFromEnum(board_squares.e8));
    try std.testing.expectEqual(@as(u6, 5), @intFromEnum(board_squares.f8));
    try std.testing.expectEqual(@as(u6, 6), @intFromEnum(board_squares.g8));
    try std.testing.expectEqual(@as(u6, 7), @intFromEnum(board_squares.h8));

    // rank 7
    try std.testing.expectEqual(@as(u6, 8), @intFromEnum(board_squares.a7));
    try std.testing.expectEqual(@as(u6, 15), @intFromEnum(board_squares.h7));

    // some squares in the middle of the board
    try std.testing.expectEqual(@as(u6, 28), @intFromEnum(board_squares.e5));
    try std.testing.expectEqual(@as(u6, 32), @intFromEnum(board_squares.a4));
    try std.testing.expectEqual(@as(u6, 35), @intFromEnum(board_squares.d4));
    try std.testing.expectEqual(@as(u6, 36), @intFromEnum(board_squares.e4));
    try std.testing.expectEqual(@as(u6, 42), @intFromEnum(board_squares.c3));
    try std.testing.expectEqual(@as(u6, 49), @intFromEnum(board_squares.b2));
    try std.testing.expectEqual(@as(u6, 53), @intFromEnum(board_squares.f2));

    // rank 1
    try std.testing.expectEqual(@as(u6, 56), @intFromEnum(board_squares.a1));
    try std.testing.expectEqual(@as(u6, 60), @intFromEnum(board_squares.e1));
    try std.testing.expectEqual(@as(u6, 62), @intFromEnum(board_squares.g1));
    try std.testing.expectEqual(@as(u6, 63), @intFromEnum(board_squares.h1));
}

test "board_squares: every square of the board is declared exactly once" {
    const fields = @typeInfo(board_squares).@"enum".fields;
    try std.testing.expectEqual(@as(usize, 64), fields.len);

    var seen = [_]bool{false} ** 64;
    inline for (fields) |field| {
        const square: usize = @intCast(field.value);
        try std.testing.expect(square < 64);
        try std.testing.expect(!seen[square]);
        seen[square] = true;
    }
    for (seen) |was_declared| try std.testing.expect(was_declared);
}

test "set_bit: sets one bit of an empty bitboard" {
    var empty_board = BitBoard.empty;

    empty_board.set(0);
    try std.testing.expectEqual(@as(u64, 0x0000_0000_0000_0001), empty_board.mask); // a8
    empty_board = BitBoard.empty;
    empty_board.set(7);
    try std.testing.expectEqual(@as(u64, 0x0000_0000_0000_0080), empty_board.mask); // h8
    empty_board = BitBoard.empty;
    empty_board.set(8);
    try std.testing.expectEqual(@as(u64, 0x0000_0000_0000_0100), empty_board.mask); // a7
    empty_board = BitBoard.empty;
    empty_board.set(32);
    try std.testing.expectEqual(@as(u64, 0x0000_0001_0000_0000), empty_board.mask); // a4
    empty_board = BitBoard.empty;
    empty_board.set(35);
    try std.testing.expectEqual(@as(u64, 0x0000_0008_0000_0000), empty_board.mask); // d4
    empty_board = BitBoard.empty;
    empty_board.set(36);
    try std.testing.expectEqual(@as(u64, 0x0000_0010_0000_0000), empty_board.mask); // e4
    empty_board = BitBoard.empty;
    empty_board.set(42);
    try std.testing.expectEqual(@as(u64, 0x0000_0400_0000_0000), empty_board.mask); // c3
    empty_board = BitBoard.empty;
    empty_board.set(53);
    try std.testing.expectEqual(@as(u64, 0x0020_0000_0000_0000), empty_board.mask); // f2
    empty_board = BitBoard.empty;
    empty_board.set(56);
    try std.testing.expectEqual(@as(u64, 0x0100_0000_0000_0000), empty_board.mask); // a1
    empty_board = BitBoard.empty;
    empty_board.set(60);
    try std.testing.expectEqual(@as(u64, 0x1000_0000_0000_0000), empty_board.mask); // e1
    empty_board = BitBoard.empty;
    empty_board.set(62);
    try std.testing.expectEqual(@as(u64, 0x4000_0000_0000_0000), empty_board.mask); // g1
    empty_board = BitBoard.empty;
    empty_board.set(63);
    try std.testing.expectEqual(@as(u64, 0x8000_0000_0000_0000), empty_board.mask); // h1
}

test "set_bit: keeps every bit that was already set" {
    var empty_board = BitBoard.empty;
    empty_board.mask = 0x0020_0400_0000_0000;
    empty_board.set(36);
    try std.testing.expectEqual(
        @as(u64, 0x0020_0410_0000_0000),
        empty_board.mask,
    ); // e4 added to a bitboard already holding c3 & f2

    empty_board.mask = 0xFFFF_FFFF_FFFF_FFFF;
    empty_board.set(36);
    try std.testing.expectEqual(
        @as(u64, 0xFFFF_FFFF_FFFF_FFFF),
        empty_board.mask,
    ); // e4 added to a full bitboard
}

test "set_bit: setting the same square twice does not change the bitboard" {
    const e4: u6 = @intFromEnum(board_squares.e4);

    var e4_board = BitBoard.empty;
    e4_board.set(e4);
    var e4_twice = e4_board;
    e4_twice.set(e4);
    try std.testing.expectEqual(e4_board, e4_twice);
    try std.testing.expectEqual(0x0000_0010_0000_0000, e4_twice.mask);
}

test "get_bit: tells whether the bit of a square is set" {
    // e4, c3 and f2
    var bitboard = BitBoard.empty;
    bitboard.mask = 0x0020_0410_0000_0000;

    try std.testing.expect(bitboard.isSet(@intFromEnum(board_squares.e4)));
    try std.testing.expect(bitboard.isSet(@intFromEnum(board_squares.c3)));
    try std.testing.expect(bitboard.isSet(@intFromEnum(board_squares.f2)));

    try std.testing.expect(!bitboard.isSet(@intFromEnum(board_squares.a8)));
    try std.testing.expect(!bitboard.isSet(@intFromEnum(board_squares.h8)));
    try std.testing.expect(!bitboard.isSet(@intFromEnum(board_squares.e5)));
    try std.testing.expect(!bitboard.isSet(@intFromEnum(board_squares.d4)));
    try std.testing.expect(!bitboard.isSet(@intFromEnum(board_squares.a1)));
    try std.testing.expect(!bitboard.isSet(@intFromEnum(board_squares.e1)));
    try std.testing.expect(!bitboard.isSet(@intFromEnum(board_squares.h1)));

    const empty_board = BitBoard.empty;
    // no bit of an empty bitboard is set
    for (0..64) |square| {
        try std.testing.expect(!empty_board.isSet(@intCast(square)));
    }
}

test "get_bit: every bit of a full bitboard is set" {
    const full_board = BitBoard.full;
    for (0..64) |square| {
        try std.testing.expect(full_board.isSet(@intCast(square)));
    }
}

test "get_bit: a bitboard holding e4, c3 and f2 has exactly 3 bits set" {
    var bitboard = BitBoard.empty;
    bitboard.mask = 0x0020_0410_0000_0000;

    var set_bits: usize = 0;
    for (0..64) |square| {
        if (bitboard.isSet(@intCast(square))) set_bits += 1;
    }
    try std.testing.expectEqual(@as(usize, 3), set_bits);
}

test "pop_bit: resets a bit that was set" {
    var bitboard = BitBoard.empty;
    bitboard.mask = 0x0020_0410_0000_0000;
    bitboard.unset(36);
    try std.testing.expectEqual(
        @as(u64, 0x0020_0400_0000_0000),
        bitboard.mask,
    ); // e4 popped from a bitboard holding e4, c3 & f2

    bitboard.mask = 0x0000_0000_0000_0001;
    bitboard.unset(0);
    try std.testing.expectEqual(@as(u64, 0x0000_0000_0000_0000), bitboard.mask); // a8

    bitboard.mask = 0x8000_0000_0000_0000;
    bitboard.unset(63);
    try std.testing.expectEqual(@as(u64, 0x0000_0000_0000_0000), bitboard.mask); // h1

    // popping every set bit leaves an empty bitboard
    bitboard.mask = 0x0020_0410_0000_0000;
    bitboard.unset(36);
    bitboard.unset(42);
    bitboard.unset(53);
    try std.testing.expectEqual(@as(u64, 0), bitboard.mask);
}

test "pop_bit: leaves the bitboard untouched when the bit is not set" {
    var bitboard = BitBoard.empty;
    const bitboard_fixed = 0x0020_0400_0000_0000; // c3 & f2
    bitboard.mask = bitboard_fixed;

    bitboard.unset(0);
    try std.testing.expectEqual(bitboard_fixed, bitboard.mask); // a8
    bitboard.unset(36);
    try std.testing.expectEqual(bitboard_fixed, bitboard.mask); // e4, already popped
    bitboard.unset(63);
    try std.testing.expectEqual(bitboard_fixed, bitboard.mask); // h1
    var empty_board = BitBoard.empty;
    empty_board.unset(0);
    try std.testing.expectEqual(@as(u64, 0), empty_board.mask);
}

test "pop_bit: popping the same square twice does not bring the bit back" {
    const e4: u6 = @intFromEnum(board_squares.e4);
    var bitboard = BitBoard.empty;
    bitboard.set(e4);

    bitboard.unset(36);
    try std.testing.expectEqual(0, bitboard.mask);
    bitboard.unset(36);
    try std.testing.expectEqual(0, bitboard.mask);
    bitboard.unset(36);
    try std.testing.expectEqual(0, bitboard.mask);
}

test "print_bitboard: prints an empty bitboard" {
    const expected =
        "\n" ++
        "  8  0 0 0 0 0 0 0 0\n" ++
        "  7  0 0 0 0 0 0 0 0\n" ++
        "  6  0 0 0 0 0 0 0 0\n" ++
        "  5  0 0 0 0 0 0 0 0\n" ++
        "  4  0 0 0 0 0 0 0 0\n" ++
        "  3  0 0 0 0 0 0 0 0\n" ++
        "  2  0 0 0 0 0 0 0 0\n" ++
        "  1  0 0 0 0 0 0 0 0\n" ++
        "\n" ++
        "     a b c d e f g h\n" ++
        "\n" ++
        "     BitBoard: 0\n" ++
        "\n";

    var buffer: [2048]u8 = undefined;
    const actual = try rendered(BitBoard.empty, &buffer);
    try std.testing.expectEqualStrings(expected, actual);
}

test "print_bitboard: prints the bits of e4, c3 and f2" {
    const expected =
        "\n" ++
        "  8  0 0 0 0 0 0 0 0\n" ++
        "  7  0 0 0 0 0 0 0 0\n" ++
        "  6  0 0 0 0 0 0 0 0\n" ++
        "  5  0 0 0 0 0 0 0 0\n" ++
        "  4  0 0 0 0 1 0 0 0\n" ++
        "  3  0 0 1 0 0 0 0 0\n" ++
        "  2  0 0 0 0 0 1 0 0\n" ++
        "  1  0 0 0 0 0 0 0 0\n" ++
        "\n" ++
        "     a b c d e f g h\n" ++
        "\n" ++
        "     BitBoard: 9011666020728832\n" ++
        "\n";

    var buffer: [2048]u8 = undefined;
    var board = BitBoard.empty;
    board.mask = 0x0020_0410_0000_0000;
    const actual = try rendered(board, &buffer);
    try std.testing.expectEqualStrings(expected, actual);
}

test "print_bitboard: prints the bitboard left after popping e4" {
    const expected =
        "\n" ++
        "  8  0 0 0 0 0 0 0 0\n" ++
        "  7  0 0 0 0 0 0 0 0\n" ++
        "  6  0 0 0 0 0 0 0 0\n" ++
        "  5  0 0 0 0 0 0 0 0\n" ++
        "  4  0 0 0 0 0 0 0 0\n" ++
        "  3  0 0 1 0 0 0 0 0\n" ++
        "  2  0 0 0 0 0 1 0 0\n" ++
        "  1  0 0 0 0 0 0 0 0\n" ++
        "\n" ++
        "     a b c d e f g h\n" ++
        "\n" ++
        "     BitBoard: 9011597301252096\n" ++
        "\n";

    var buffer: [2048]u8 = undefined;
    var board = BitBoard.empty;
    board.mask = 0x0020_0400_0000_0000;
    const actual = try rendered(board, &buffer);
    try std.testing.expectEqualStrings(expected, actual);
}

test "print_bitboard: prints a full bitboard" {
    const expected =
        "\n" ++
        "  8  1 1 1 1 1 1 1 1\n" ++
        "  7  1 1 1 1 1 1 1 1\n" ++
        "  6  1 1 1 1 1 1 1 1\n" ++
        "  5  1 1 1 1 1 1 1 1\n" ++
        "  4  1 1 1 1 1 1 1 1\n" ++
        "  3  1 1 1 1 1 1 1 1\n" ++
        "  2  1 1 1 1 1 1 1 1\n" ++
        "  1  1 1 1 1 1 1 1 1\n" ++
        "\n" ++
        "     a b c d e f g h\n" ++
        "\n" ++
        "     BitBoard: 18446744073709551615\n" ++
        "\n";

    var buffer: [2048]u8 = undefined;
    const board = BitBoard.full;
    const actual = try rendered(board, &buffer);
    try std.testing.expectEqualStrings(expected, actual);
}

test "print_bitboard: prints a single bit on a8 and on h1" {
    const expected =
        "\n" ++
        "  8  1 0 0 0 0 0 0 0\n" ++
        "  7  0 0 0 0 0 0 0 0\n" ++
        "  6  0 0 0 0 0 0 0 0\n" ++
        "  5  0 0 0 0 0 0 0 0\n" ++
        "  4  0 0 0 0 0 0 0 0\n" ++
        "  3  0 0 0 0 0 0 0 0\n" ++
        "  2  0 0 0 0 0 0 0 0\n" ++
        "  1  0 0 0 0 0 0 0 1\n" ++
        "\n" ++
        "     a b c d e f g h\n" ++
        "\n" ++
        "     BitBoard: 9223372036854775809\n" ++
        "\n";

    var buffer: [2048]u8 = undefined;
    var board = BitBoard.empty;
    board.mask = 0x8000_0000_0000_0001;
    const actual = try rendered(board, &buffer);
    try std.testing.expectEqualStrings(expected, actual);
}

test "the main driver sequence: set e4, c3 & f2, print, pop e4, print" {
    const after_set =
        "\n" ++
        "  8  0 0 0 0 0 0 0 0\n" ++
        "  7  0 0 0 0 0 0 0 0\n" ++
        "  6  0 0 0 0 0 0 0 0\n" ++
        "  5  0 0 0 0 0 0 0 0\n" ++
        "  4  0 0 0 0 1 0 0 0\n" ++
        "  3  0 0 1 0 0 0 0 0\n" ++
        "  2  0 0 0 0 0 1 0 0\n" ++
        "  1  0 0 0 0 0 0 0 0\n" ++
        "\n" ++
        "     a b c d e f g h\n" ++
        "\n" ++
        "     BitBoard: 9011666020728832\n" ++
        "\n";

    const after_pop =
        "\n" ++
        "  8  0 0 0 0 0 0 0 0\n" ++
        "  7  0 0 0 0 0 0 0 0\n" ++
        "  6  0 0 0 0 0 0 0 0\n" ++
        "  5  0 0 0 0 0 0 0 0\n" ++
        "  4  0 0 0 0 0 0 0 0\n" ++
        "  3  0 0 1 0 0 0 0 0\n" ++
        "  2  0 0 0 0 0 1 0 0\n" ++
        "  1  0 0 0 0 0 0 0 0\n" ++
        "\n" ++
        "     a b c d e f g h\n" ++
        "\n" ++
        "     BitBoard: 9011597301252096\n" ++
        "\n";

    // setting some bits
    var bitboard = BitBoard.empty;
    bitboard.set(@intFromEnum(board_squares.e4));
    bitboard.set(@intFromEnum(board_squares.c3));
    bitboard.set(@intFromEnum(board_squares.f2));

    // print bitboard
    var buffer: [2048]u8 = undefined;
    var writer: Io.Writer = .fixed(&buffer);
    try print_bitboard(bitboard, &writer);

    // reset bit
    bitboard.unset(@intFromEnum(board_squares.e4));

    // print bitboard
    try print_bitboard(bitboard, &writer);

    try std.testing.expectEqualStrings(after_set ++ after_pop, writer.buffered());
}

// ===========================================================================
//
//  Tests: pre-calculated pawn attacks
//
// ===========================================================================

/// Test only: the pre-calculated pawn attack map of every square, indexed by
/// side first and square second, exactly as `pawn_attacks` is meant to hold it.
const expected_pawn_attacks = [2][64]u64{
    // white pawns, a8 .. h8, a7 .. h7, ... a1 .. h1
    .{
        0x0000_0000_0000_0000, 0x0000_0000_0000_0000, 0x0000_0000_0000_0000, 0x0000_0000_0000_0000, 0x0000_0000_0000_0000, 0x0000_0000_0000_0000, 0x0000_0000_0000_0000, 0x0000_0000_0000_0000,
        0x0000_0000_0000_0002, 0x0000_0000_0000_0005, 0x0000_0000_0000_000A, 0x0000_0000_0000_0014, 0x0000_0000_0000_0028, 0x0000_0000_0000_0050, 0x0000_0000_0000_00A0, 0x0000_0000_0000_0040,
        0x0000_0000_0000_0200, 0x0000_0000_0000_0500, 0x0000_0000_0000_0A00, 0x0000_0000_0000_1400, 0x0000_0000_0000_2800, 0x0000_0000_0000_5000, 0x0000_0000_0000_A000, 0x0000_0000_0000_4000,
        0x0000_0000_0002_0000, 0x0000_0000_0005_0000, 0x0000_0000_000A_0000, 0x0000_0000_0014_0000, 0x0000_0000_0028_0000, 0x0000_0000_0050_0000, 0x0000_0000_00A0_0000, 0x0000_0000_0040_0000,
        0x0000_0000_0200_0000, 0x0000_0000_0500_0000, 0x0000_0000_0A00_0000, 0x0000_0000_1400_0000, 0x0000_0000_2800_0000, 0x0000_0000_5000_0000, 0x0000_0000_A000_0000, 0x0000_0000_4000_0000,
        0x0000_0002_0000_0000, 0x0000_0005_0000_0000, 0x0000_000A_0000_0000, 0x0000_0014_0000_0000, 0x0000_0028_0000_0000, 0x0000_0050_0000_0000, 0x0000_00A0_0000_0000, 0x0000_0040_0000_0000,
        0x0000_0200_0000_0000, 0x0000_0500_0000_0000, 0x0000_0A00_0000_0000, 0x0000_1400_0000_0000, 0x0000_2800_0000_0000, 0x0000_5000_0000_0000, 0x0000_A000_0000_0000, 0x0000_4000_0000_0000,
        0x0002_0000_0000_0000, 0x0005_0000_0000_0000, 0x000A_0000_0000_0000, 0x0014_0000_0000_0000, 0x0028_0000_0000_0000, 0x0050_0000_0000_0000, 0x00A0_0000_0000_0000, 0x0040_0000_0000_0000,
    },
    // black pawns, a8 .. h8, a7 .. h7, ... a1 .. h1
    .{
        0x0000_0000_0000_0200, 0x0000_0000_0000_0500, 0x0000_0000_0000_0A00, 0x0000_0000_0000_1400, 0x0000_0000_0000_2800, 0x0000_0000_0000_5000, 0x0000_0000_0000_A000, 0x0000_0000_0000_4000,
        0x0000_0000_0002_0000, 0x0000_0000_0005_0000, 0x0000_0000_000A_0000, 0x0000_0000_0014_0000, 0x0000_0000_0028_0000, 0x0000_0000_0050_0000, 0x0000_0000_00A0_0000, 0x0000_0000_0040_0000,
        0x0000_0000_0200_0000, 0x0000_0000_0500_0000, 0x0000_0000_0A00_0000, 0x0000_0000_1400_0000, 0x0000_0000_2800_0000, 0x0000_0000_5000_0000, 0x0000_0000_A000_0000, 0x0000_0000_4000_0000,
        0x0000_0002_0000_0000, 0x0000_0005_0000_0000, 0x0000_000A_0000_0000, 0x0000_0014_0000_0000, 0x0000_0028_0000_0000, 0x0000_0050_0000_0000, 0x0000_00A0_0000_0000, 0x0000_0040_0000_0000,
        0x0000_0200_0000_0000, 0x0000_0500_0000_0000, 0x0000_0A00_0000_0000, 0x0000_1400_0000_0000, 0x0000_2800_0000_0000, 0x0000_5000_0000_0000, 0x0000_A000_0000_0000, 0x0000_4000_0000_0000,
        0x0002_0000_0000_0000, 0x0005_0000_0000_0000, 0x000A_0000_0000_0000, 0x0014_0000_0000_0000, 0x0028_0000_0000_0000, 0x0050_0000_0000_0000, 0x00A0_0000_0000_0000, 0x0040_0000_0000_0000,
        0x0200_0000_0000_0000, 0x0500_0000_0000_0000, 0x0A00_0000_0000_0000, 0x1400_0000_0000_0000, 0x2800_0000_0000_0000, 0x5000_0000_0000_0000, 0xA000_0000_0000_0000, 0x4000_0000_0000_0000,
        0x0000_0000_0000_0000, 0x0000_0000_0000_0000, 0x0000_0000_0000_0000, 0x0000_0000_0000_0000, 0x0000_0000_0000_0000, 0x0000_0000_0000_0000, 0x0000_0000_0000_0000, 0x0000_0000_0000_0000,
    },
};

test "sides: white and black are the only two sides to move" {
    try std.testing.expectEqual(@as(u6, 0), @intFromEnum(sides.white));
    try std.testing.expectEqual(@as(u6, 1), @intFromEnum(sides.black));

    try std.testing.expectEqual(@as(usize, 2), @typeInfo(sides).@"enum".fields.len);
}

test "file constants: a constant keeps every bit of the board outside its file" {
    for (0..64) |square| {
        const file: usize = square % 8;

        try std.testing.expectEqual(file != 0, not_a_file.isSet(@intCast(square)));
        try std.testing.expectEqual(file != 7, not_h_file.isSet(@intCast(square)));
        try std.testing.expectEqual(file < 6, not_hg_file.isSet(@intCast(square)));
        try std.testing.expectEqual(file > 1, not_ab_file.isSet(@intCast(square)));
    }
}

test "file constants: not_a_file, not_h_file, not_hg_file and not_ab_file are 4 different boards" {
    const constants = [_]BitBoard{ not_a_file, not_h_file, not_hg_file, not_ab_file };

    for (constants, 0..) |constant, index| {
        try std.testing.expect(constant.mask != BitBoard.empty.mask);
        try std.testing.expect(constant.mask != BitBoard.full.mask);

        // the very same byte is repeated on each one of the 8 ranks of the board
        var rank: u64 = constant.mask;
        const byte: u8 = @truncate(rank);
        for (0..8) |_| {
            try std.testing.expectEqual(byte, @as(u8, @truncate(rank)));
            rank >>= 8;
        }

        for (constants, 0..) |candidate, candidate_index| {
            if (index == candidate_index) continue;
            try std.testing.expect(constant.mask != candidate.mask);
        }
    }
}

test "print_bitboard: prints not_a_file" {
    const expected =
        "\n" ++
        "  8  0 1 1 1 1 1 1 1\n" ++
        "  7  0 1 1 1 1 1 1 1\n" ++
        "  6  0 1 1 1 1 1 1 1\n" ++
        "  5  0 1 1 1 1 1 1 1\n" ++
        "  4  0 1 1 1 1 1 1 1\n" ++
        "  3  0 1 1 1 1 1 1 1\n" ++
        "  2  0 1 1 1 1 1 1 1\n" ++
        "  1  0 1 1 1 1 1 1 1\n" ++
        "\n" ++
        "     a b c d e f g h\n" ++
        "\n" ++
        "     BitBoard: 18374403900871474942\n" ++
        "\n";

    var buffer: [2048]u8 = undefined;
    const actual = try rendered(not_a_file, &buffer);
    try std.testing.expectEqualStrings(expected, actual);
}

test "print_bitboard: prints not_h_file" {
    const expected =
        "\n" ++
        "  8  1 1 1 1 1 1 1 0\n" ++
        "  7  1 1 1 1 1 1 1 0\n" ++
        "  6  1 1 1 1 1 1 1 0\n" ++
        "  5  1 1 1 1 1 1 1 0\n" ++
        "  4  1 1 1 1 1 1 1 0\n" ++
        "  3  1 1 1 1 1 1 1 0\n" ++
        "  2  1 1 1 1 1 1 1 0\n" ++
        "  1  1 1 1 1 1 1 1 0\n" ++
        "\n" ++
        "     a b c d e f g h\n" ++
        "\n" ++
        "     BitBoard: 9187201950435737471\n" ++
        "\n";

    var buffer: [2048]u8 = undefined;
    const actual = try rendered(not_h_file, &buffer);
    try std.testing.expectEqualStrings(expected, actual);
}

test "print_bitboard: prints not_hg_file" {
    const expected =
        "\n" ++
        "  8  1 1 1 1 1 1 0 0\n" ++
        "  7  1 1 1 1 1 1 0 0\n" ++
        "  6  1 1 1 1 1 1 0 0\n" ++
        "  5  1 1 1 1 1 1 0 0\n" ++
        "  4  1 1 1 1 1 1 0 0\n" ++
        "  3  1 1 1 1 1 1 0 0\n" ++
        "  2  1 1 1 1 1 1 0 0\n" ++
        "  1  1 1 1 1 1 1 0 0\n" ++
        "\n" ++
        "     a b c d e f g h\n" ++
        "\n" ++
        "     BitBoard: 4557430888798830399\n" ++
        "\n";

    var buffer: [2048]u8 = undefined;
    const actual = try rendered(not_hg_file, &buffer);
    try std.testing.expectEqualStrings(expected, actual);
}

test "print_bitboard: prints not_ab_file" {
    const expected =
        "\n" ++
        "  8  0 0 1 1 1 1 1 1\n" ++
        "  7  0 0 1 1 1 1 1 1\n" ++
        "  6  0 0 1 1 1 1 1 1\n" ++
        "  5  0 0 1 1 1 1 1 1\n" ++
        "  4  0 0 1 1 1 1 1 1\n" ++
        "  3  0 0 1 1 1 1 1 1\n" ++
        "  2  0 0 1 1 1 1 1 1\n" ++
        "  1  0 0 1 1 1 1 1 1\n" ++
        "\n" ++
        "     a b c d e f g h\n" ++
        "\n" ++
        "     BitBoard: 18229723555195321596\n" ++
        "\n";

    var buffer: [2048]u8 = undefined;
    const actual = try rendered(not_ab_file, &buffer);
    try std.testing.expectEqualStrings(expected, actual);
}

test "mask_pawn_attacks: a white pawn attacks the 2 squares diagonally in front of it" {
    try std.testing.expectEqual(
        @as(u64, 0x0000_0000_2800_0000), // d5 and f5
        mask_pawn_attacks(sides.white, @intFromEnum(board_squares.e4)).mask,
    );
    try std.testing.expectEqual(
        @as(u64, 0x0000_0000_0500_0000), // a5 and c5
        mask_pawn_attacks(sides.white, @intFromEnum(board_squares.b4)).mask,
    );
    try std.testing.expectEqual(
        @as(u64, 0x0000_0000_0A00_0000), // b5 and d5
        mask_pawn_attacks(sides.white, @intFromEnum(board_squares.c4)).mask,
    );
    try std.testing.expectEqual(
        @as(u64, 0x0028_0000_0000_0000), // d2 and f2
        mask_pawn_attacks(sides.white, @intFromEnum(board_squares.e1)).mask,
    );
}

test "mask_pawn_attacks: a white pawn on the a file has only 1 attack, on the b file" {
    try std.testing.expectEqual(
        @as(u64, 0x0000_0000_0200_0000), // b5
        mask_pawn_attacks(sides.white, @intFromEnum(board_squares.a4)).mask,
    );
    try std.testing.expectEqual(
        @as(u64, 0x0000_0000_0000_0002), // b8
        mask_pawn_attacks(sides.white, @intFromEnum(board_squares.a7)).mask,
    );
}

test "mask_pawn_attacks: a white pawn on the h file has only 1 attack, on the g file" {
    try std.testing.expectEqual(
        @as(u64, 0x0000_0000_4000_0000), // g5
        mask_pawn_attacks(sides.white, @intFromEnum(board_squares.h4)).mask,
    );
    try std.testing.expectEqual(
        @as(u64, 0x0000_0000_0000_0040), // g8
        mask_pawn_attacks(sides.white, @intFromEnum(board_squares.h7)).mask,
    );
}

test "mask_pawn_attacks: a white pawn on the 8th rank attacks nothing, there is no rank 9" {
    for (0..8) |square| {
        try std.testing.expectEqual(
            @as(u64, 0),
            mask_pawn_attacks(sides.white, @intCast(square)).mask,
        );
    }
}

test "mask_pawn_attacks: a black pawn attacks the 2 squares diagonally behind it" {
    try std.testing.expectEqual(
        @as(u64, 0x0000_2800_0000_0000), // d3 and f3
        mask_pawn_attacks(sides.black, @intFromEnum(board_squares.e4)).mask,
    );
    try std.testing.expectEqual(
        @as(u64, 0x0000_0500_0000_0000), // a3 and c3
        mask_pawn_attacks(sides.black, @intFromEnum(board_squares.b4)).mask,
    );
    try std.testing.expectEqual(
        @as(u64, 0x0000_0028_0000_0000), // d4 and f4
        mask_pawn_attacks(sides.black, @intFromEnum(board_squares.e5)).mask,
    );
}

test "mask_pawn_attacks: a black pawn on the a file has only 1 attack, on the b file" {
    try std.testing.expectEqual(
        @as(u64, 0x0000_0200_0000_0000), // b3
        mask_pawn_attacks(sides.black, @intFromEnum(board_squares.a4)).mask,
    );
    try std.testing.expectEqual(
        @as(u64, 0x0200_0000_0000_0000), // b1
        mask_pawn_attacks(sides.black, @intFromEnum(board_squares.a2)).mask,
    );
}

test "mask_pawn_attacks: a black pawn on the h file has only 1 attack, on the g file" {
    try std.testing.expectEqual(
        @as(u64, 0x0000_4000_0000_0000), // g3
        mask_pawn_attacks(sides.black, @intFromEnum(board_squares.h4)).mask,
    );
    try std.testing.expectEqual(
        @as(u64, 0x4000_0000_0000_0000), // g1
        mask_pawn_attacks(sides.black, @intFromEnum(board_squares.h2)).mask,
    );
}

test "mask_pawn_attacks: a black pawn on the 1st rank attacks nothing, there is no rank 0" {
    for (56..64) |square| {
        try std.testing.expectEqual(
            @as(u64, 0),
            mask_pawn_attacks(sides.black, @intCast(square)).mask,
        );
    }
}

test "mask_pawn_attacks: never attacks off the board and never attacks straight ahead" {
    for (0..2) |side_index| {
        const side: sides = @enumFromInt(side_index);

        for (0..64) |square| {
            const attacks = mask_pawn_attacks(side, @intCast(square));
            const file: i32 = @intCast(square % 8);
            const row: i32 = @intCast(square / 8);
            const towards: i32 = if (side == .white) -1 else 1;

            var attacked_squares: usize = 0;
            for (0..64) |target| {
                if (!attacks.isSet(@intCast(target))) continue;
                attacked_squares += 1;

                const target_file: i32 = @intCast(target % 8);
                const target_row: i32 = @intCast(target / 8);

                // an attack is exactly 1 file over ...
                try std.testing.expect(@abs(target_file - file) == 1);
                // ... and 1 rank in the direction the side of the pawn looks at
                try std.testing.expectEqual(towards, target_row - row);
            }

            // a pawn captures on 2 diagonals at most, and never on its own 2
            // ranks, which is where the table is empty for a whole rank
            try std.testing.expect(attacked_squares <= 2);
        }
    }
}

test "mask_pawn_attacks: every square of both sides matches the pre-calculated table" {
    for (0..2) |side_index| {
        const side: sides = @enumFromInt(side_index);

        for (0..64) |square| {
            const attacks = mask_pawn_attacks(side, @intCast(square));
            if (attacks.mask == expected_pawn_attacks[side_index][square]) continue;

            std.debug.print(
                "unexpected attacks of the {s} pawn standing on {s}\n",
                .{ @tagName(side), @tagName(@as(board_squares, @enumFromInt(square))) },
            );
            return error.TestUnexpectedResult;
        }
    }
}

test "init_leapers_attacks: fills all 128 entries of the table" {
    init_leapers_attacks();

    for (0..2) |side_index| {
        for (0..64) |square| {
            if (pawn_attacks[side_index][square].mask == expected_pawn_attacks[side_index][square]) continue;

            std.debug.print(
                "unexpected entry for the {s} pawn standing on {s}\n",
                .{ @tagName(@as(sides, @enumFromInt(side_index))), @tagName(@as(board_squares, @enumFromInt(square))) },
            );
            return error.TestUnexpectedResult;
        }
    }
}

test "init_leapers_attacks: the table holds what mask_pawn_attacks returns for every square" {
    init_leapers_attacks();

    for (0..2) |side_index| {
        const side: sides = @enumFromInt(side_index);

        for (0..64) |square| {
            try std.testing.expectEqual(
                mask_pawn_attacks(side, @intCast(square)),
                pawn_attacks[side_index][square],
            );
        }
    }
}

test "init_leapers_attacks: overwrites whatever the table was holding before" {
    for (0..2) |side_index| {
        for (0..64) |square| pawn_attacks[side_index][square] = BitBoard.full;
    }

    init_leapers_attacks();

    for (0..2) |side_index| {
        for (0..64) |square| {
            try std.testing.expectEqual(
                expected_pawn_attacks[side_index][square],
                pawn_attacks[side_index][square].mask,
            );
        }
    }
}

test "init_leapers_attacks: initializing twice leaves the very same table" {
    init_leapers_attacks();

    const once = pawn_attacks;
    init_leapers_attacks();

    for (0..2) |side_index| {
        for (0..64) |square| {
            try std.testing.expectEqual(
                once[side_index][square].mask,
                pawn_attacks[side_index][square].mask,
            );
        }
    }
}

test "pawn_attacks: the first index is the side and the second one is the square" {
    init_leapers_attacks();

    const white = @intFromEnum(sides.white);
    const black = @intFromEnum(sides.black);

    // the same square is attacked in 2 different ways, one per side
    try std.testing.expect(
        pawn_attacks[white][@intFromEnum(board_squares.e4)].mask !=
            pawn_attacks[black][@intFromEnum(board_squares.e4)].mask,
    );

    // and the 2 sides never look the same way
    try std.testing.expectEqual(
        @as(u64, 0),
        pawn_attacks[white][@intFromEnum(board_squares.e8)].mask,
    );
    try std.testing.expectEqual(
        @as(u64, 0),
        pawn_attacks[black][@intFromEnum(board_squares.e1)].mask,
    );
}

test "the main driver sequence: init the tables, then print every square, white first" {
    init_leapers_attacks();

    var buffer: [64 * 1024]u8 = undefined;
    var writer: Io.Writer = .fixed(&buffer);
    for (0..2) |side_index| {
        for (0..64) |square| {
            try print_bitboard(pawn_attacks[side_index][square], &writer);
        }
    }
    const printed = writer.buffered();

    // the driver prints one bitboard per side, per square
    try std.testing.expectEqual(@as(usize, 128), std.mem.count(u8, printed, "     BitBoard: "));

    // and they come out in table order: white a8 .. white h1, then black a8 .. black h1
    var rest = printed;
    for (0..128) |index| {
        const marker = "     BitBoard: ";
        const at = std.mem.indexOf(u8, rest, marker) orelse return error.TestUnexpectedResult;
        const number = rest[at + marker.len ..];
        const end = std.mem.indexOfScalar(u8, number, '\n') orelse return error.TestUnexpectedResult;

        try std.testing.expectEqual(
            expected_pawn_attacks[index / 64][index % 64],
            try std.fmt.parseInt(u64, number[0..end], 10),
        );
        rest = number[end..];
    }
}

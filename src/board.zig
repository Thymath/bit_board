const std = @import("std");
const Io = std.Io;
const assert = std.debug.assert;

pub const BoardSquares = enum {
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

/// Options for configuring an iterator over a bit set
pub const IteratorOptions = struct {
    /// determines which bits should be visited
    kind: Type = .set,
    /// determines the order in which bit indices should be visited
    direction: Direction = .forward,

    pub const Type = enum {
        /// visit indexes of set bits
        set,
        /// visit indexes of unset bits
        unset,
    };

    pub const Direction = enum {
        /// visit indices in ascending order
        forward,
        /// visit indices in descending order.
        /// Note that this may be slightly more expensive than forward iteration.
        reverse,
    };
};

const Self = @This();

// TODO: Make this a comptime field once those are fixed
/// The number of items in this bit set
pub const bit_length: usize = 64;

/// The integer type used to represent a mask in this bit set
pub const MaskInt = @Int(.unsigned, 64);

/// The integer type used to shift a mask in this bit set
pub const ShiftInt = std.math.Log2Int(MaskInt);

/// The bit mask, as a single integer
mask: MaskInt,

/// A bit set with no elements present.
pub const empty: Self = .{ .mask = 0 };

/// A bit set with all elements present.
pub const full: Self = .{ .mask = ~@as(MaskInt, 0) };

/// Returns the number of bits in this bit set
pub inline fn capacity(self: Self) usize {
    _ = self;
    return bit_length;
}

/// Returns true if the bit at the specified index
/// is present in the set, false otherwise.
pub fn isSet(self: Self, index: usize) bool {
    assert(index < bit_length);
    return (self.mask & maskBit(index)) != 0;
}

/// Returns the total number of set bits in this bit set.
pub fn count(self: Self) usize {
    return @popCount(self.mask);
}

/// Changes the value of the specified bit of the bit
/// set to match the passed boolean.
pub fn setValue(self: *Self, index: usize, value: bool) void {
    assert(index < bit_length);
    if (MaskInt == u0) return;
    const bit = maskBit(index);
    const new_bit = bit & std.math.boolMask(MaskInt, value);
    self.mask = (self.mask & ~bit) | new_bit;
}

/// Adds a specific bit to the bit set
pub fn set(self: *Self, index: usize) void {
    assert(index < bit_length);
    self.mask |= maskBit(index);
}

/// A range of indices within a bitset.
pub const Range = struct {
    /// The index of the first bit of interest.
    start: usize,
    /// The index immediately after the last bit of interest.
    end: usize,
};

/// Changes the value of all bits in the specified range to
/// match the passed boolean.
pub fn setRangeValue(self: *Self, range: Range, value: bool) void {
    assert(range.end <= bit_length);
    assert(range.start <= range.end);
    if (range.start == range.end) return;
    if (MaskInt == u0) return;

    const start_bit = @as(ShiftInt, @intCast(range.start));

    var mask = std.math.boolMask(MaskInt, true) << start_bit;
    if (range.end != bit_length) {
        const end_bit = @as(ShiftInt, @intCast(range.end));
        mask &= std.math.boolMask(MaskInt, true) >> @as(ShiftInt, @truncate(@as(usize, @bitSizeOf(MaskInt)) - @as(usize, end_bit)));
    }
    self.mask &= ~mask;

    mask = std.math.boolMask(MaskInt, value) << start_bit;
    if (range.end != bit_length) {
        const end_bit = @as(ShiftInt, @intCast(range.end));
        mask &= std.math.boolMask(MaskInt, value) >> @as(ShiftInt, @truncate(@as(usize, @bitSizeOf(MaskInt)) - @as(usize, end_bit)));
    }
    self.mask |= mask;
}

/// Removes a specific bit from the bit set
pub fn unset(self: *Self, index: usize) void {
    assert(index < bit_length);
    // Workaround for #7953
    if (MaskInt == u0) return;
    self.mask &= ~maskBit(index);
}

/// Flips a specific bit in the bit set
pub fn toggle(self: *Self, index: usize) void {
    assert(index < bit_length);
    self.mask ^= maskBit(index);
}

/// Flips all bits in this bit set which are present
/// in the toggles bit set.
pub fn toggleSet(self: *Self, toggles: Self) void {
    self.mask ^= toggles.mask;
}

/// Flips every bit in the bit set.
pub fn toggleAll(self: *Self) void {
    self.mask = ~self.mask;
}

/// Set all bits to 0.
pub fn unsetAll(self: *Self) void {
    self.mask = 0;
}

/// Set all bits to 1.
pub fn setAll(self: *Self) void {
    self.mask = ~@as(MaskInt, 0);
}

/// Performs a union of two bit sets, and stores the
/// result in the first one.  Bits in the result are
/// set if the corresponding bits were set in either input.
pub fn setUnion(self: *Self, other: Self) void {
    self.mask |= other.mask;
}

/// Performs an intersection of two bit sets, and stores
/// the result in the first one.  Bits in the result are
/// set if the corresponding bits were set in both inputs.
pub fn setIntersection(self: *Self, other: Self) void {
    self.mask &= other.mask;
}

/// Finds the index of the first set bit.
/// If no bits are set, returns null.
pub fn findFirstSet(self: Self) ?usize {
    const mask = self.mask;
    if (mask == 0) return null;
    return @ctz(mask);
}

/// Finds the index of the last set bit.
/// If no bits are set, returns null.
pub fn findLastSet(self: Self) ?usize {
    const mask = self.mask;
    if (mask == 0) return null;
    return bit_length - @clz(mask) - 1;
}

/// Finds the index of the first set bit, and unsets it.
/// If no bits are set, returns null.
pub fn toggleFirstSet(self: *Self) ?usize {
    const mask = self.mask;
    if (mask == 0) return null;
    const index = @ctz(mask);
    self.mask = mask & (mask - 1);
    return index;
}

/// Returns true iff every corresponding bit in both
/// bit sets are the same.
pub fn eql(self: Self, other: Self) bool {
    return bit_length == 0 or self.mask == other.mask;
}

/// Returns true iff the first bit set is the subset
/// of the second one.
pub fn subsetOf(self: Self, other: Self) bool {
    return self.intersectWith(other).eql(self);
}

/// Returns true iff the first bit set is the superset
/// of the second one.
pub fn supersetOf(self: Self, other: Self) bool {
    return other.subsetOf(self);
}

/// Returns the complement bit sets. Bits in the result
/// are set if the corresponding bits were not set.
pub fn complement(self: Self) Self {
    var result = self;
    result.toggleAll();
    return result;
}

/// Returns the union of two bit sets. Bits in the
/// result are set if the corresponding bits were set
/// in either input.
pub fn unionWith(self: Self, other: Self) Self {
    var result = self;
    result.setUnion(other);
    return result;
}

/// Returns the intersection of two bit sets. Bits in
/// the result are set if the corresponding bits were
/// set in both inputs.
pub fn intersectWith(self: Self, other: Self) Self {
    var result = self;
    result.setIntersection(other);
    return result;
}

/// Returns the xor of two bit sets. Bits in the
/// result are set if the corresponding bits were
/// not the same in both inputs.
pub fn xorWith(self: Self, other: Self) Self {
    var result = self;
    result.toggleSet(other);
    return result;
}

/// Returns the difference of two bit sets. Bits in
/// the result are set if set in the first but not
/// set in the second set.
pub fn differenceWith(self: Self, other: Self) Self {
    var result = self;
    result.setIntersection(other.complement());
    return result;
}

/// Iterates through the items in the set, according to the options.
/// The default options (.{}) will iterate indices of set bits in
/// ascending order.  Modifications to the underlying bit set may
/// or may not be observed by the iterator.
pub fn iterator(self: *const Self, comptime options: IteratorOptions) Iterator(options) {
    return .{
        .bits_remain = switch (options.kind) {
            .set => self.mask,
            .unset => ~self.mask,
        },
    };
}

pub fn Iterator(comptime options: IteratorOptions) type {
    return SingleWordIterator(options.direction);
}

fn SingleWordIterator(comptime direction: IteratorOptions.Direction) type {
    return struct {
        const IterSelf = @This();
        // all bits which have not yet been iterated over
        bits_remain: MaskInt,

        /// Returns the index of the next unvisited set bit
        /// in the bit set, in ascending order.
        pub fn next(self: *IterSelf) ?usize {
            if (self.bits_remain == 0) return null;

            switch (direction) {
                .forward => {
                    const next_index = @ctz(self.bits_remain);
                    self.bits_remain &= self.bits_remain - 1;
                    return next_index;
                },
                .reverse => {
                    const leading_zeroes = @clz(self.bits_remain);
                    const top_bit = (@bitSizeOf(MaskInt) - 1) - leading_zeroes;
                    self.bits_remain &= (@as(MaskInt, 1) << @as(ShiftInt, @intCast(top_bit))) - 1;
                    return top_bit;
                },
            }
        }
    };
}

fn maskBit(index: usize) MaskInt {
    if (MaskInt == u0) return 0;
    return @as(MaskInt, 1) << @as(ShiftInt, @intCast(index));
}
fn boolMaskBit(index: usize, value: bool) MaskInt {
    if (MaskInt == u0) return 0;
    return @as(MaskInt, @intFromBool(value)) << @as(ShiftInt, @intCast(index));
}

pub fn print(bitboard: Self, writer: *Io.Writer) Io.Writer.Error!void {
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

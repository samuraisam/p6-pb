use v6;

#= Low level binary PB reader

module PB::Binary::Reader;

use PB::Binary::WireTypes;


# SECURITY: Depends on the behavior of Blob.[] returning 0 for out of bounds
#           access (which e.g. makes read-varint self-terminate if it runs
#           off the end of the blob).


class X::PB::Binary::Invalid is Exception {
    has $.offset;
    has $.reason;

    method message {
        "Saw $.reason at offset $.offset; this doesn't look like a version 2 protocol buffer."
    }
}


#= Convert combined field key to (field tag number, wire type)
sub decode-field-key(int $key) is pure is export {
    ($key +> 3, $key +& 7)
}


#= Decode a zigzag-encoded signed number
sub decode-zigzag(int $zigzag --> int) is pure is export {
    ($zigzag +> 1) +^ -($zigzag +& 1)
}


#= Read a varint from a buffer at a given offset, updating the offset
sub read-varint(blob8 $buffer, Int $offset is rw --> uint) is export {
    my Int $value = 0;
    my int $shift = 0;
    my int $high-bit;

    repeat while $high-bit {
        my $byte  = $buffer[$offset++];
        $high-bit = $byte +& 128;
        $value   += $byte +& 127 +< $shift;
        $shift    = $shift + 7;
    }

    $value;
}


#= Read a 32-bit (wire type 5) value from a buffer at a given offset, updating the offset
sub read-fixed32(blob8 $buffer, Int $offset is rw --> uint32) is export {
      $buffer[$offset++]
    + $buffer[$offset++] +<  8
    + $buffer[$offset++] +< 16
    + $buffer[$offset++] +< 24
}


#= Read a 64-bit (wire type 1) value from a buffer at a given offset, updating the offset
sub read-fixed64(blob8 $buffer, Int $offset is rw --> uint64) is export {
      $buffer[$offset++]
    + $buffer[$offset++] +<  8
    + $buffer[$offset++] +< 16
    + $buffer[$offset++] +< 24
    + $buffer[$offset++] +< 32
    + $buffer[$offset++] +< 40
    + $buffer[$offset++] +< 48
    + $buffer[$offset++] +< 56
}


#= Read a kv pair from a buffer at a given offset, updating the offset
sub read-pair(blob8 $buffer, Int $offset is rw) is export {
    my $orig-offset = $offset;
    my ($field-tag, $wire-type)
        = decode-field-key(read-varint($buffer, $offset));

    my $value = do given $wire-type {
        # Just plain values: varint, 64-bit, 32-bit
        when WireType::VARINT   { read-varint( $buffer, $offset) }
        when WireType::FIXED_64 { read-fixed64($buffer, $offset) }
        when WireType::FIXED_32 { read-fixed32($buffer, $offset) }

        # Length-delimited
        when WireType::LENGTH_DELIMITED {
            my $length = read-varint($buffer, $offset);
            ($offset, $length);
        }

        # XXXX: Groups (unsupported, deprecated by Google)
        when WireType::START_GROUP | WireType::END_GROUP {
            die "XXXX: Can't handle groups (wire type $_)"
        }

        default  {
            fail X::PB::Binary::Invalid.new(:offset($orig-offset),
                :reason("wire type $_ for field tag $field-tag"))
        }
    }

    ($field-tag, $wire-type, $value);
}
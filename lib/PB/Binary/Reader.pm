use v6;

#= Low level binary PB reader

module PB::Binary::Reader;


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


#= Read a varint from a buffer at a given offset, updating the offset
sub read-varint($buffer, $offset is rw) is export {
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
sub read-fixed32($buffer, $offset is rw) is export {
      $buffer[$offset++]
    + $buffer[$offset++] +<  8
    + $buffer[$offset++] +< 16
    + $buffer[$offset++] +< 24
}


#= Read a 64-bit (wire type 1) value from a buffer at a given offset, updating the offset
sub read-fixed64($buffer, $offset is rw) is export {
      $buffer[$offset++]
    + $buffer[$offset++] +<  8
    + $buffer[$offset++] +< 16
    + $buffer[$offset++] +< 24
    + $buffer[$offset++] +< 32
    + $buffer[$offset++] +< 40
    + $buffer[$offset++] +< 48
    + $buffer[$offset++] +< 56
}


#= Convert varint field key to (field tag number, wire type)
sub decode-field-key($key) is export {
    ($key +> 3, $key +& 7)
}


#= Decode a zigzag-encoded signed number
sub decode-zigzag($zigzag) is export {
    ($zigzag +> 1) +^ -($zigzag +& 1)
}


# Read a kv pair from a buffer at a given offset, updating the offset
sub read-pair($buffer, $offset is rw) is export {
    my $orig-offset = $offset;
    my ($field-tag, $wire-type)
        = decode-field-key(read-varint($buffer, $offset));

    my $value = do given $wire-type {
        # Just plain values: varint, 64-bit, 32-bit
        when 0   { read-varint($buffer, $offset) }
        when 1   { read-fixed64($buffer, $offset) }
        when 5   { read-fixed32($buffer, $offset) }

        # Length-delimited
        when 2   {
            my $length = read-varint($buffer, $offset);
            ($offset, $length);
        }

        # XXXX: Groups (unsupported, deprecated by Google)
        when 3|4 { die "XXXX: Can't handle groups (wire type $_)" }

        default  {
            fail X::PB::Binary::Invalid.new(:offset($orig-offset),
                :reason("wire type $_ for field tag $field-tag"))
        }
    }

    ($field-tag, $wire-type, $value);
}

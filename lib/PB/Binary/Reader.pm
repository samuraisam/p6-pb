use v6;

module PB::Binary::Reader;

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
        # Just a plain varint
        when 0       { read-varint($buffer, $offset) }

        # Length-delimited
        when 2       {
            my $length = read-varint($buffer, $offset);
            ($offset, $length);
        }

        when 1|3|4|5 { die "XXXX: Can't handle wire type $_" }
        default      {
            fail X::PB::Binary::Invalid.new(:offset($orig-offset),
                :reason("wire type $_ for field tag $field-tag"))
        }
    }

    ($field-tag, $wire-type, $value);
}

use v6;

#= Low level binary PB writer

module PB::Binary::Writer;


#= Binary wire types
enum WireType is export <
    WIRE_TYPE_VARINT
    WIRE_TYPE_64_BIT
    WIRE_TYPE_LENGTH_DELIMITED
    WIRE_TYPE_START_GROUP
    WIRE_TYPE_END_GROUP
    WIRE_TYPE_32_BIT
    >;


#= Convert (field tag number, wire type) to a single field key
sub encode-field-key(int $field-tag, int $wire-type --> int) is pure is export {
    $field-tag +< 3 +| $wire-type
}


#= Encode a zigzag-encoded signed number
sub encode-zigzag(int $value --> int) is pure is export {
    ($value +< 1) +^ ($value +> 63)
}


#= Write a varint into a buffer at a given offset, updating the offset
sub write-varint(buf8 $buffer, Int $offset is rw, int $value) is export {
    my $buf := nqp::decont($buffer);
    repeat while $value {
        my int $byte = $value +& 127;
        # XXXX: What about negative $value?
        $value = $value +>   7;
        $byte  = $byte  +| 128 if $value;
        nqp::bindpos_i($buf, $offset++, $byte);
    }
}


#= Write a 32-bit (wire type 5) value into a buffer at a given offset, updating the offset
sub write-fixed32(buf8 $buffer, Int $offset is rw, int $value) is export {
    my $buf := nqp::decont($buffer);
    nqp::bindpos_i($buf, $offset++, $value       +& 255);
    nqp::bindpos_i($buf, $offset++, $value +>  8 +& 255);
    nqp::bindpos_i($buf, $offset++, $value +> 16 +& 255);
    nqp::bindpos_i($buf, $offset++, $value +> 24 +& 255);
}


#= Write a 32-bit (wire type 1) value into a buffer at a given offset, updating the offset
sub write-fixed64(buf8 $buffer, Int $offset is rw, int $value) is export {
    my $buf := nqp::decont($buffer);
    nqp::bindpos_i($buf, $offset++, $value       +& 255);
    nqp::bindpos_i($buf, $offset++, $value +>  8 +& 255);
    nqp::bindpos_i($buf, $offset++, $value +> 16 +& 255);
    nqp::bindpos_i($buf, $offset++, $value +> 24 +& 255);
    nqp::bindpos_i($buf, $offset++, $value +> 32 +& 255);
    nqp::bindpos_i($buf, $offset++, $value +> 40 +& 255);
    nqp::bindpos_i($buf, $offset++, $value +> 48 +& 255);
    nqp::bindpos_i($buf, $offset++, $value +> 56 +& 255);
}


#= Write a blob8 into a buffer at a given offset, updating the offset
sub write-blob8(buf8 $buffer, Int $offset is rw, blob8 $blob8) is export {
    my $buf  := nqp::decont($buffer);
    my $blob := nqp::decont($blob8);
    my int $buflen  = nqp::elems($buf);
    my int $bloblen = nqp::elems($blob);

    nqp::setelems($buf, $offset + $bloblen)
           if $buflen < $offset + $bloblen;

    my int $s = 0;
    my int $d = $offset;
    while $s < $bloblen {
        nqp::bindpos_i($buf, $d, nqp::atpos_i($blob, $s));
        $s = $s + 1;
        $d = $d + 1;
    }

    $offset = $d;
}


#= Write a field tag, wire type, and value to a buffer at a given offset, updating the offset
sub write-pair(buf8 $buffer, Int $offset is rw, int $field-tag, int $wire-type,
               Any $value) is export {
    write-varint($buffer, $offset, encode-field-key($field-tag, $wire-type));

    given $wire-type {
        # Just plain values: varint, 32-bit, 64-bit
        when WIRE_TYPE_VARINT { write-varint( $buffer, $offset, $value) }
        when WIRE_TYPE_32_BIT { write-fixed32($buffer, $offset, $value) }
        when WIRE_TYPE_64_BIT { write-fixed64($buffer, $offset, $value) }

        # Length-delimited
        when WIRE_TYPE_LENGTH_DELIMITED {
            write-varint($buffer, $offset, $value.elems);
            if $value ~~ blob8 {
                write-blob8($buffer, $offset, $value);
            }
            else {
                die "XXXX: Not handling length-delimited (wire type $_) for values of type {$value.WHAT} yet";
            }
        }

        # XXXX: Groups (unsupported, deprecated by Google)
        when WIRE_TYPE_START_GROUP|WIRE_TYPE_END_GROUP {
            die "XXXX: Can't handle groups (wire type $_)";
        }

        default { die "Invalid wire type $_" }
    }
}

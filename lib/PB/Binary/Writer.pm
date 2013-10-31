use v6;

#= Low level binary PB writer

module PB::Binary::Writer;


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


#= Write a field tag, wire type, and value to a buffer at a given offset, updating the offset
sub write-pair(buf8 $buffer, Int $offset is rw, int $field-tag, int $wire-type,
               Any $value) is export {
    die "Invalid wire type $wire-type" unless 0 <= $wire-type <= 5;
    write-varint($buffer, $offset, encode-field-key($field-tag, $wire-type));

    given $wire-type {
        # Just plain values: varint, 64-bit, 32-bit
        when 0   { write-varint( $buffer, $offset, $value) }
        when 1   { write-fixed64($buffer, $offset, $value) }
        when 5   { write-fixed32($buffer, $offset, $value) }

        # Length-delimited
        when 2   {
            die "XXXX: Not handling length-delimited yet (wire type 2)";
            write-varint($buffer, $offset, $value.elems);
        }

        # XXXX: Groups (unsupported, deprecated by Google)
        when 3|4 { die "XXXX: Can't handle groups (wire type $_)" }
    }
}

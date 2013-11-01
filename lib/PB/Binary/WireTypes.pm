use v6;

#= Low level binary PB wire types

module PB::Binary::WireTypes;


#= Binary wire types
enum WireType is export <
    VARINT
    FIXED_64
    LENGTH_DELIMITED
    START_GROUP
    END_GROUP
    FIXED_32
    >;

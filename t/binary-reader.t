use v6;

use Test;
use PB::Binary::Reader;


# DECODING TESTS

# Tests for decode-field-key()
sub test-decode-field-key($key, $expected-tag, $expected-type) {
    my ($tag, $type) = decode-field-key($key);
    is $tag,  $expected-tag,  "decode-field-key($key) decodes tag properly";
    is $type, $expected-type, "decode-field-key($key) decodes type properly";
}

for (0, 1, 2, 3, 200, 60_000, 20_000_000) X ^8 -> $tag, $type {
    test-decode-field-key($tag +< 3 + $type, $tag, $type);
}

# Tests for decode-zigzag()
my @zigzag-pairs = <
    0     0
    1    -1
    2     1
    3    -2
    4     2
    5    -3
    6     3
    7    -4
    8     4
    4294967294     2147483647
    4294967295    -2147483648
>;

for @zigzag-pairs.list -> $coded, $decoded {
    is decode-zigzag(+$coded), +$decoded, "decode-zigzag($coded) works";
}


# BUFFER-READING TESTS

# Trivial buffer (first example in Google's encoding docs)
my $trivial = blob8.new(0x08, 0x96, 0x01);
my $offset  = 0;
my $key     = read-varint($trivial, $offset);
is $key,    8, '1-byte varint at offset 0 read correctly';
is $offset, 1, '... and offset was updated correctly';

my $value = read-varint($trivial, $offset);
is $value, 150, '2-byte varint at offset 1 read correctly';
is $offset,  3, '... and offset was updated correctly';

$offset = 0;
my $pb-pair = read-pair($trivial, $offset);
is $pb-pair[0],   1, 'Field tag 1 properly decoded';
is $pb-pair[1],   0, 'Wire type 0 properly decoded';
is $pb-pair[2], 150, 'Field value 150 properly decoded';
is $offset,       3, '... and offset was updated correctly';


# Tell prove that we've completed testing normally
done;

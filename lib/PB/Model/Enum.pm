use PB::Model::Option;

class PB::Model::EnumField {
    has Str $.name;
    has Int $.value;

    method new(Str :$name!, Int :$value!) {
        self.bless(*, name => $name, value => $value);
    }
}

multi infix:<eq>(PB::Model::EnumField $a, PB::Model::EnumField $b) is export {
    # say "{$a.name}={$b.name} {$a.value}={$b.value}";
    ($a.name eq $b.name) && ($a.value == $b.value);
}

class PB::Model::Enum {
    has Str $.name;
    has Array[PB::Model::Option] @.options;
    has Array[PB::Model::EnumField] @.fields;

    method new(Str :$name!, :@options?, :@fields?) { # todo: put type qualifiers on these params, when it works in rakudo again
        die "name is required to be a string of non-zero length" unless $name.chars;
        self.bless(*, name => $name, options => @options, fields => @fields);
    }
}

sub array-attrs-eq(Str $field!, $a!, $b!) {
    my @aval = $a."$field"();
    my @bval = $b."$field"();
    (@aval == @bval) && [&&](@aval Zeq @bval);
}

multi infix:<eq>(PB::Model::Enum $a, PB::Model::Enum $b) is export {
    [&&]
        array-attrs-eq(<options>, $a, $b),
        array-attrs-eq(<fields>, $a, $b),
        ($a.name eq $b.name);
}
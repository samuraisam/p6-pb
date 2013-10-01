use PB::Model::Option;

class PB::Model::EnumField {
    has Str $.name;
    has Int $.value;
    has PB::Model::Option @.options;

    method new(Str :$name!, Int :$value!, :@options?) {
        self.bless(name => $name, value => $value, options => @options);
    }
}

multi infix:<eq>(PB::Model::EnumField $a, PB::Model::EnumField $b) is export {
    # say "{$a.name eq $b.name} {$a.value == $b.value} {array-attrs-eq(<options>, $a, $b)}";
    # ($a.name eq $b.name) && ($a.value == $b.value);
    [&&]
        array-attrs-eq(<options>, $a, $b),
        ($a.name eq $b.name),
        ($a.value == $b.value);
}

class PB::Model::Enum {
    has Str $.name;
    has PB::Model::Option @.options;
    has PB::Model::EnumField @.fields;

    method new(Str :$name!, :@options?, :@fields?) { # todo: put type qualifiers on these params, when it works in rakudo again
        die "name is required to be a string of non-zero length" unless $name.chars;
        self.bless(name => $name, options => @options, fields => @fields);
    }
}

sub array-attrs-eq(Str $field!, $a!, $b!) {
    my @aval = $a."$field"();
    my @bval = $b."$field"();
    # say 'a val ', @aval.perl;
    # say 'b val ', @bval.perl;
    (@aval == @bval) && [&&](@aval Zeq @bval);
}

multi infix:<eq>(PB::Model::Enum $a, PB::Model::Enum $b) is export {
    [&&]
        array-attrs-eq(<options>, $a, $b),
        array-attrs-eq(<fields>, $a, $b),
        ($a.name eq $b.name);
}
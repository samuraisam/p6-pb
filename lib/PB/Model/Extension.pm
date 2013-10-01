use PB::Model::Field;

# todo: find a better way to do this than copy-pasta
sub array-attrs-eq(Str $field!, $a!, $b!) {
    my @aval = $a."$field"();
    my @bval = $b."$field"();
    (@aval == @bval) && [&&](@aval Zeq @bval);
}

class PB::Model::Extension {
    has Str $.name; # original message name
    has Array[PB::Model::Field] @.fields;

    method new(Str :$name!, :@fields?) {
        die "name must be a string of non-zero length" unless $name.chars;
        self.bless(:name($name), :fields(@fields));
    }
}

multi infix:<eq>(PB::Model::Extension $a, PB::Model::Extension $b) is export {
    array-attrs-eq(<fields>, $a, $b) && $a.name eq $b.name;
}

class PB::Model::ExtensionField {
    # the maximum extension number
    our Int constant MAX = 536_870_911;

    has Int $.start;
    has Int $.end;

    method new (Int :$start!, Int :$end?) {
        self.bless(:start($start), :end($end));
    }
}

multi infix:<eq>(PB::Model::ExtensionField $a, PB::Model::ExtensionField $b) is export {
    $a.start == $b.start && ((!$a.end && !$b.end) || $a.end == $b.end);
}
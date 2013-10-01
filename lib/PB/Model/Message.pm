use PB::Model::Field;
use PB::Model::Enum;
use PB::Model::Extension;

class PB::Model::Message {
    has Str $.name;
    has Array[PB::Model::Field] @.fields;
    has Array[PB::Model::Enum] @.enums;
    has Array[PB::Model::Message] @.messages;
    has Array[PB::Model::ExtensionField] @.extensions;

    method new(Str :$name!, :@fields?, :@enums?, :@messages?, :@extensions?) {
        if !$name.chars {
            die "name must be a string of non-zero length";
        }
        self.bless(name => $name, fields => @fields, enums => @enums, 
                      messages => @messages, extensions => @extensions);
    }

    method gist() {
        "<Message fields=[{join ', ', @.fields>>.gist}]>";
    }
}

sub array-attrs-eq(Str $field!, $a!, $b!) {
    my @aval = $a."$field"();
    my @bval = $b."$field"();
    (@aval == @bval) && [&&](@aval Zeq @bval);
}

multi infix:<eq>(PB::Model::Message $a, PB::Model::Message $b) is export {
    [&&]
        array-attrs-eq(<fields>, $a, $b),
        array-attrs-eq(<enums>, $a, $b),
        array-attrs-eq(<messages>, $a, $b),
        array-attrs-eq(<extensions>, $a, $b),
        ($a.name eq $b.name);
}



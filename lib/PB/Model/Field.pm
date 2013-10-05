use PB::Model::Option;

class PB::Model::Field {
    has Str $.label;
    has Str $.type;
    has Str $.name;
    has Int $.number;
    has PB::Model::Option @.options;

    method new(Str :$label!, Str :$type!, Str :$name!, Int :$number!, :@options) {
        if !$label.chars || !$type.chars || !$name.chars {
            die "label, type, and name must all be a string with non-zero length";
        }
        self.bless(:$name, :$label, :$type, :$number, :@options);
    }

    method gist() {
        "<Field {$.name}={$.number} opts=[{@.options>>.gist}]>"
    }
}

multi infix:<eq>(PB::Model::Field $a, PB::Model::Field $b) is export {
    my @aopts = ($a.options // []);
    my @bopts = ($b.options // []);
    # say 'field eq: ', ($a.label eq $b.label),
    #          ($a.type eq $b.type),
    #          ($a.name eq $b.name),
    #          ($a.number eq $b.number),
    #          # ($a.options // []) eqv ($b.options // []);
    #          [&&](@aopts Zeq @bopts),
    #          (@aopts == @bopts).perl;
    return 
        [&&] ($a.label eq $b.label),
             ($a.type eq $b.type),
             ($a.name eq $b.name),
             ($a.number eq $b.number),
             # ($a.options // []) eqv ($b.options // []); # <-- should this work instead of the below? it doesn't call the custom eq
             [&&](@aopts Zeq @bopts),
             (@aopts == @bopts);
}
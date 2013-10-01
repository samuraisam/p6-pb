use PB::Model::SubMessage;

class PB::Model::Option {
    has Str $.name;
    has $.constant;
    has PB::Model::SubMessage $.sub-message;
    
    method new(Str :$name!, :$constant?, PB::Model::SubMessage :$sub-message?) {
        if !$name.chars {
            die "name must not be zero length";
        }
        if (!$constant.defined && !$sub-message.defined) || ($constant.defined && $sub-message.defined) {
            die "either constant OR sub-message must be provided"; 
        }
        self.bless(name => $name, constant => $constant, sub-message => $sub-message);
    }

    method gist() {
        "<Option {$.name}={$.constant.defined ?? $.constant !! 'Any'}>"
    }
}

multi infix:<eq>(PB::Model::Option $a, PB::Model::Option $b) is export {
    # say "$a = $b";
    return
        [&&] ($a.name eq $b.name),
             ($a.constant // Nil) eq ($b.constant // Nil),
             ($a.sub-message // Nil) eq ($b.sub-message // Nil);
}

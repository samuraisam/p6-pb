use PB::Model::Field;

class PB::Model::Message {
    has Str $.name;
    has Array[PB::Model::Field] @.fields;

    method new(Str :$name!, :@fields?) {
        if !$name.chars {
            die "name must be a string of non-zero length";
        }
        self.bless(*, name => $name, fields => @fields);
    }

    method gist() {
        "<Message fields=[{join ', ', @.fields>>.gist}]>";
    }
}

multi infix:<eq>(PB::Model::Message $a, PB::Model::Message $b) is export {
    my @afields = ($a.fields // []);
    my @bfields = ($b.fields // []);
    # say 'msg eq: ', ((@afields == @bfields), [&&](@afields Zeq @bfields)).perl;
    return
        [&&] ((@afields == @bfields), # compare length
              [&&](@afields Zeq @bfields)); # compare contents
}
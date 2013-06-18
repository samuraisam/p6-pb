use PB::Grammar;

class PB::Option {

}

class PB::Field {
    has Str $.label;
    has Str $.type;
    has Str $.identifier;
    has Int $.field-num;
    has Array[PB::Option] @.options;

    method gist() {
        "<Field {$.identifier}={$.field-num} {@.options}>"
    }
}

class PB::Message {
    has Array[PB::Field] @.fields;

    method gist() {
        "<Message fields=[{join ', ', @.fields>>.gist}]>";
    }
}

class PB::Package { 
    has Str $.name;
    has Array[PB::Message] @.messages;

    method gist() {
        "<Package {$.name} messages=[{join ', ', @.messages>>.gist}]>"
    }
}

class PB::Actions {
    method TOP($/) {
        make $<proto>.ast;
    }

    method proto($/) {
        make PB::Package.new(
            name => $<pkg>[0]<dotted-ident>.Str,
            messages => $<message>>>.ast
        );
    }

    method message($/) {
        make PB::Message.new(
            fields => $<message-body><field>>>.ast
        );
    }

    method field($/) {
        my $opts;
        if $<field-opts> {
            $opts = $<field-opts>.ast;
        } else {
            $opts = [];
        }
        make PB::Field.new(
            label => $<label>.Str, 
            type => $<type>.Str,
            identifier => $<ident>.Str,
            field-num => $<field-num>.Num.Int,
            options => $opts
        );
    }

    method field-opts($/) {
        make $<opt-body>>>.ast;
    }

    method field-opt($/) {
        make $<opt-body>.ast;
    }

    method opt-body($/) {
        my $o = make PB::Option.new();
        say 'o ', $o;
        $o;
    }
}

my $actions = PB::Actions.new;
my $src = '
package omg.nowai;

message yawai {
    required int32 lolwut = 1 [default="snarf", butt=LOL_NOWAI];
    optional string snu = 2;
}
';
# say 'parse: ', PB::Grammar.parse($src);
say 'act: ', PB::Grammar.parse($src, :actions($actions)).ast;

# ==> use of uninitialized value of type Any in string context  in block  at lib/PB/Actions.pm:23

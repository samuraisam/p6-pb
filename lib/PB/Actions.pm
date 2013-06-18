use PB::Grammar;

class PB::SubMsg {

}

class PB::Option {
    has Str $.name;
    has $.constant;
    has PB::SubMsg $.sub-message;
    
    method gist() {
        "<Option {$.name}={$.constant || 'Any'}>"
    }
}

class PB::Field {
    has Str $.label;
    has Str $.type;
    has Str $.identifier;
    has Int $.field-num;
    has Array[PB::Option] @.options;

    method gist() {
        "<Field {$.identifier}={$.field-num} {@.options>>.gist}>"
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
        make PB::Field.new(
            label => $<label>.Str, 
            type => $<type>.Str,
            identifier => $<ident>.Str,
            field-num => $<field-num>.Num.Int,
            options => $<field-opts> ?? $<field-opts>.ast !! []
        );
    }

    method field-opts($/) {
        make $<opt-body>>>.ast;
    }

    method field-opt($/) {
        make $<opt-body>.ast;
    }

    method opt-body($/) {
        make PB::Option.new(
            name => $<opt-name>.Str,
            constant => $<constant> ?? $<constant>.ast !! Any
        );
    }

    ## string constants -------------------------------------------------------

    method constant:sym<str>($/) {
        make $<str-lit>.ast;
    }

    method str-lit:sym<single-quoted>($/) {
        make $<str-contents-single>>>.flat>>.ast.join;
    }

    method str-lit:sym<double-quoted>($/) {
        make $<str-contents-double>>>.flat>>.ast.join;
    }

    method str-contents-single($/) {
        if $<str-escape> {
            make $<str-escape>.ast;
        } else {
            make ~$/;
        }
    }

    method str-contents-double($/) {
        if $<str-escape> {
            make $<str-escape>.ast;
        } else {
            make ~$/;
        }
    }

    method str-escape:sym<hex>($/) {
        make chr(:16($<xdigit>.join));
    }

    method str-escape:sym<oct>($/) {
        make chr(:8($<digit>.join));
    }

    method str-escape:sym<char>($/) {
        my %h = {
            'n' => "\n",
            '\\' => "\\",
            # TODO: others...
        };
        make %h{~$<char>};
    }

    # integer constants -------------------------------------------------------
}

my $actions = PB::Actions.new;
my $src = '
package omg.nowai;

message yawai {
    required int32 lolwut = 1 [default="snarf \x14b poop \n", butt=LOL_NOWAI, shart=\'fart\'];
    optional string snu = 2 [default=1];
}
';
# say 'parse: ', PB::Grammar.parse($src);
say 'act: ', PB::Grammar.parse($src, :actions($actions)).ast;

# ==> use of uninitialized value of type Any in string context  in block  at lib/PB/Actions.pm:23

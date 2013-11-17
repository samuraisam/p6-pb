use Metamodel::Perlable;

use PB;
use PB::Grammar;
use PB::Actions;
use PB::Message;
use PB::Model::Package;
use PB::Model::Message;

my Str constant ANON_NAME = '<anon>';

class PB::Model::Generator {
    has $.ast;
    has Str $.prefix;

    method all-classes {
        gather for $.ast -> $tlo { $.gen-class($tlo) }
    }

    method gen-class-name($obj) {
        # say 'prefix: ', $.prefix ~ $obj.name;
        $obj.name || ANON_NAME;
    }

    multi method gen-class(PB::Model::Package $pkg) {
        my $name  := $.gen-class-name($pkg);
        my $class := Metamodel::PerlableClassHOW.new_type(:$name);
        $class.HOW.add_parent($class, Any);

        $class.^compose;
        say $class.^perl;
        take $name, $class;
        
        $.gen-class($_) for $pkg.messages;
    }

    multi method gen-class(PB::Model::Message $msg) {
        my enum  PB::RepeatClass < REQUIRED OPTIONAL REPEATED >;
        my class PB::Attribute is Attribute
            does Metamodel::PerlableAttribute {

            has Str             $.pb_type   is rw;
            has Str             $.pb_name   is rw;
            has Int             $.pb_number is rw;
            has PB::RepeatClass $.pb_repeat is rw;

            method traits_perl() {
                my $traits = callsame;
                $traits ~= " is pb_type($.pb_type.perl())" if $.pb_type;
                $traits ~= " is pb_name($.pb_name.perl())" if $.pb_name;
                $traits ~= " is pb_number($.pb_number)"
                    if $.pb_number.defined;
                $traits ~= " is pb_repeat($.pb_repeat)"
                    if $.pb_repeat.defined;
                $traits;
            }
        }

        my class PB::MessageClassHOW is Metamodel::PerlableClassHOW {
            has @.ordered-fields;

            method compose(|) {
                my $class = callsame;

                @!ordered-fields :=
                    self.attributes($class).grep(*.has_accessor).sort(*.pb_number);

                $class;
            }
        }

        my $name  := $.gen-class-name($msg);
        my $class := PB::MessageClassHOW.new_type(:$name);
        $class.HOW.add_parent($class, PB::Message);

        for $msg.fields -> $field {
            my $pb_type = $field.type;
            my $type = do given $pb_type {
                when 'bool'           { Bool }
                when 'float'|'double' { Num  }
                when 'int32'|'uint32'|'sint32'|'fixed32'|'sfixed32'
                    |'int64'|'uint64'|'sint64'|'fixed64'|'sfixed64'
                                      { Int  }
                when 'string'         { Str  }
                when 'bytes'          { buf8 }
                default               { Any  }
            };

            my $repeat = do given $field.label {
                when 'required' { REQUIRED }
                when 'optional' { OPTIONAL }
                when 'repeated' { REPEATED }
            }

            my $attr = PB::Attribute.new(:name('$!' ~ $field.name), :$type,
                                         :package($class), :has_accessor);
            $attr.pb_type   = $pb_type;
            $attr.pb_name   = $field.name;
            $attr.pb_number = $field.number;
            $attr.pb_repeat = $repeat;
            $attr.set_rw;
            $class.^add_attribute($attr);
        }
        $class.^compose;
        say $class.^perl;
        take $name, $class;
    }
}

# args = $filename!, $class-prefix?
our sub EXPORT(*@args) {
    # parse file and generate the AST
    my $desc = slurp @args[0];
    my $actions := PB::Actions.new();
    my $ast := PB::Grammar.parse($desc, :$actions).ast;
    die "failed to parse {@args[0]}" unless $ast;

    # create a new class for everything in the ast
    my $gen = PB::Model::Generator.new(:$ast, :prefix(@args[1] // ''));

    # export these symbols
    %(gather for $gen.all-classes -> $name, $class {
        take '&' ~ $name => sub { $class } unless $name eq ANON_NAME;
    });
}

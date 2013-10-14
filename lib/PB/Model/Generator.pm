use PB;
use PB::Grammar;
use PB::Actions;
use PB::Model::Package;

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
        my $name := $.gen-class-name($pkg);
        my $type := Metamodel::ClassHOW.new_type(:$name);

        $type.HOW.compose($type);
        
        take $name, $type;
        
        $.gen-class($_) for $pkg.messages;
    }

    multi method gen-class(PB::Model::Message $msg) {
        my $name := $.gen-class-name($msg);
        my $type := Metamodel::ClassHOW.new_type(:$name);
        $type.HOW.compose($type);
        take $name, $type;
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
    %(gather for $gen.all-classes -> $name, $type { 
        take '&' ~ $name => sub { $type } unless $name eq ANON_NAME;
    });
}

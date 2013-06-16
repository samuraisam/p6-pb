use Test;
use File::Spec;
use PB::Grammar;

# to automate the testing of this grammar
sub g_ok (Str $testme, Str $desc?) { ok PB::Grammar.parse($testme), $desc; }
sub g_nok (Str $testme, Str $desc?) { nok PB::Grammar.parse($testme), $desc; }

g_nok 'package .omgnowai;',                 'package name should not start with a dot';
g_ok 'package omgnowai;',                   'package name parses correctly';
g_nok 'package omgnowai',                   'package must have a semicolon at the end';
g_nok 'package omgnowai.yawai.;',           'package must not end with a dot';
g_ok 'package omgyawai.nowai.yawai.nowai;', 'package with dotted identifier';

g_nok 'option = lolwut;',                   'confused option should puke';
g_nok 'option wutlol;',                     'option w/o a value ';
g_ok 'option wutlol = "STRING LITERAL";',   'string literal option';
g_ok 'option wutlol = 0x4cb;',              'hex literal option';
g_ok 'option wutlol = 1;',                  'decimal literal option';
g_ok 'option wutlol = IDENT_CONSTANT;',     'ident constant';

g_ok 'import "urmom.proto";', 'import w/ string lit';
g_nok 'import fart;', 'import w/ anything besides string lit';
g_ok "import 'fart.proto';", 'import w/ single quote string lit';

g_nok 'message{}', 'message w/o ident';
g_ok 'message a{required int32 a=3[a=B];}', 'message w/ field compact';
g_ok 'message a{};', 'allow message w/ semicolon on the end';

g_ok 'message x{required group Lol=4{};};', 'group w/ semi colon at the end';
g_nok 'message x{optional group lol=4{}}', 'group name must start with caps';

g_nok 'message a{required int a=6;}', 'field w/ bad type';
g_nok 'message a{required a=4;}', 'field w/ no type';
g_nok 'message a{required int32 x 3 [a=B];}', 'field w/o equals sign for num';
g_nok 'message a{required int32=3[a=B];}', 'field w/o identifier';
g_ok 'message a{required int32 x=3[a=B,c="D",x="Y"];}', 'field w/ multiple opts';
g_ok 'message//nowai
a{}//yawai', 'message w/ wierd comments';

ok PB::Grammar.parse('
    package com.niceword;
    option nice_thing = "face";
    import "allunicorns.proto";
    message not_ass {
        required double happy = 4;
        optional bool mild = 5;
        extensions 100 to 199, 500 to max;
        extensions 1 to max;

        option fancy = BLOOM;

        optional group Result = 8 {
            required string lolwut = 2 [default="yawai"];
        }

        enum Flower {
            BLOOM = 1;
            DIE = 5;
        }

        extend .lololol {}
        extend LOLOL.wut.nowai {
            required string yawai = 399 [my_opt = "\0xbc \n\n it happens"]    ;
        }

    }

    enum Trolololol {SHING=3;SHINE =4     ;}

    extend .not_ass {
        required int32 lolwut = 100;
        repeated group Ass = 101 {}
    }

    service things_that_do_stuff { rpc things (.stuff)returns (Trolololol);rpc wobble(lolwut)returns(noshing);}
'), "test a big complex mofo";

if run('which', 'svn') == 0 {
    say 'svn is installed... checking for protobuf repo';
    my $absdir = $?FILE.path.absolute.directory;
    my $pbdir = File::Spec.os.join: '', $absdir, 'data/protobuf-read-only';
    if !grep 'protobuf-read-only', dir $absdir {
        run 'svn', 'checkout', 'http://protobuf.googlecode.com/svn/trunk/', $pbdir;
    } else {
        run 'svn', 'update', $pbdir;
    }
    my $srcdir = File::Spec.os.join: '', $pbdir, 'src/google/protobuf';
    my @files = dir $srcdir, :test(/proto$/);
    for @files -> $path {
        g_ok(slurp(open $path), "parse $path");
    }
} else {
    say 'svn is not installed... skipping official protobuf tests';
}

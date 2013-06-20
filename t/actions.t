use Test;
use PB::Grammar;
use PB::Actions;
use PB::Model::Field;
use PB::Model::Message;
use PB::Model::Option;

sub gr_ok($text, $rule, $expected, $desc?) { 
    my $actions = PB::Actions.new;
    my $result = PB::Grammar.parse($text, rule => $rule, actions => $actions).ast;
    # say '';
    # say ' expected: ', $expected.gist;
    # say '';
    # say '   result: ', $result.gist;
    # say '';
    ok $result eq $expected, $desc;
}

# string constants ------------------------------------------------------------

gr_ok '"hello"', <str-lit>, "hello", "str-lit basic";
gr_ok '"hello \xc3"', <str-lit>, "hello \xc3", "str-lit unicode escape";
gr_ok "'\\176'", <str-lit>, "~", 'str-lit oct escape, single-quote';
gr_ok "'\\n'", <str-lit>, "\n", 'str-lit newline escape';
gr_ok '"\\\\"', <str-lit>, '\\', 'str-lit double backslash escape';
# TODO: test the other backslash char escapes

# number constants ------------------------------------------------------------

gr_ok "1", <constant>, 1, 'int-lit basic decimal';
gr_ok "0xf4", <constant>, 244, 'int-lit basic hex';
gr_ok "070", <constant>, 56, 'int-lit basic oct';
gr_ok "1.0", <constant>, 1.0, 'constant float';
gr_ok "1.0e40", <constant>, 1.0e40, 'constant exponential float';
gr_ok ".01", <constant>, 0.01, 'constant float w/o leading zero';
gr_ok 'false', <constant>, False, 'constant false';
gr_ok 'true', <constant>, True, 'constant true';
gr_ok 'inf', <constant>, Inf, 'constant positive Inf';
gr_ok '+inf', <constant>, Inf, 'constant positive Inf with sign';
gr_ok '-inf', <constant>, -Inf, 'constant negative Inf with sign';
gr_ok 'nan', <constant>, NaN, 'constant nan';

# PB::Model::Option constructor and such ---------------------------------------------

nok (try PB::Model::Option.new(name => 'x')), 'construct option w/o constant or sub message';
ok PB::Model::Option.new(name => 'y', constant => 1.0e4), 'construct option w/ constant';
ok PB::Model::Option.new(name => 'y', constant => 0), 'construct option w/ falsey constant';
nok (try PB::Model::Option.new(name => 'x', sub-message => PB::SubMesg.new(), constant=> 'x')), 'dont construct option with both constant and sub message';
# todo: construct / equality tests for options with sub messages
ok PB::Model::Option.new(name => 'x', constant => 'a') eq PB::Model::Option.new(name => 'x', constant => 'a'), 'option equal';
nok PB::Model::Option.new(name => 'x', constant => 'a') eq PB::Model::Option.new(name => 'y', constant => 'a'), 'option not equal';
ok PB::Model::Option.new(name => 'x', constant => 'y') eq PB::Model::Option.new(name => 'x', constant => 'y'), 'option w/ constant equal';
nok PB::Model::Option.new(name => 'x', constant => 0) eq PB::Model::Option.new(name => 'x', constant => 1), 'option w/ constant equal';
nok (try PB::Model::Option.new(:name(''), :constant(''))), 'option with empty string name';

# Option ----------------------------------------------------------------------

gr_ok 'option x = 1;', <option>, PB::Model::Option.new(name => 'x', constant => 1), 'option int const';
gr_ok 'option x = 1.0;', <option>, PB::Model::Option.new(name => 'x', constant => 1.0), 'option float const';
gr_ok 'option x = 0xf4;', <option>, PB::Model::Option.new(name => 'x', constant => 244), 'option hex const';
gr_ok 'option x = 070;', <option>, PB::Model::Option.new(name => 'x', constant => 56), 'option opt const';
gr_ok 'option x = -.2e5;', <option>, PB::Model::Option.new(name => 'x', constant => -.2e5), 'option float exponent';
gr_ok 'option x = false;', <option>, PB::Model::Option.new(name => 'x', constant => False), 'option false';
gr_ok 'option x = true;', <option>, PB::Model::Option.new(name => 'x', constant => True), 'option true';
gr_ok 'option x = inf;', <option>, PB::Model::Option.new(name => 'x', constant => Inf), 'option inf';
gr_ok 'option x = -inf;', <option>, PB::Model::Option.new(name => 'x', constant => -Inf), 'option -inf';
gr_ok 'option x = nan;', <option>, PB::Model::Option.new(name => 'x', constant => NaN), 'option NaN';

# PB::Model::Field constructor and such ----------------------------------------------

nok (try PB::Model::Field.new()), 'empty field constructor';
nok (try PB::Model::Field.new(name=>'name')), 'field constructor w/o label, type or number';
nok (try PB::Model::Field.new(name=>'name', label=>'required')), 'field constructor w/o type or number';
nok (try PB::Model::Field.new(name=>'name', label=>'required', type=>'int32')), 'field constructor w/o number';
ok PB::Model::Field.new(name=>'name', label=>'required', type=>'int32', number=>1), 'valid field constructor';
ok PB::Model::Field.new(name=>'name', label=>'required', type=>'int32', number=>1, 
    options=>[PB::Model::Option.new(name=>'x', constant=>'x')]), 'field constructor with options';
nok (try PB::Model::Field.new(:name(''), :label(''), :type(''), :number(1))), 'field constructor with empty values';

# equality
my $field = PB::Model::Field.new(name=>'name', label=>'required', type=>'int32', number=>1);
my $field2 = PB::Model::Field.new(name=>'name', label=>'required', type=>'int32', number=>1);
my $fopt = PB::Model::Option.new(name=>'default', constant=>0);
my $fopt2 = PB::Model::Option.new(name=>'default', constant=>0);
ok [&&]([$fopt] Zeq [$fopt2]), 'option equality sanity test';

ok $field eq $field, 'field equality to self';
ok $field eq $field2, 'basic field equality';
nok $field eq $field2.clone(number=>2), 'field non-equality with different numbers';
nok $field eq $field2.clone(name=>'othername'), 'field non-equality with different names';
nok $field eq $field2.clone(label=>'optional'), 'field non-equality with different labels';
nok $field eq $field2.clone(:options($fopt)), 'field non-equality one with and one without options';
ok $field.clone(:options($fopt)) eq $field2.clone(:options($fopt2)), 'field equality with same options';
nok $field.clone(:options($fopt.clone(constant=>1))) eq $field2.clone(:options($fopt2)), 'field non-equality with different options';

# PB::Model::Message constructor and equality ----------------------------------------

my $mfield = PB::Model::Field.new(name=>'fieldname', label=>'required', type=>'int32', number=>1);
ok PB::Model::Message.new(:name<a>, :fields()), 'message w/ no fields';
ok PB::Model::Message.new(:name<a>, :fields([$mfield])), 'message w/ a field';
nok (try PB::Model::Message.new(:name(''))), 'message requires a name';

my $msg = PB::Model::Message.new(:name<a>, :fields[$mfield]);
my $msg2 = PB::Model::Message.new(:name<a>, :fields[$mfield]);
my $msg3 = PB::Model::Message.new(:name<a>, :fields[$mfield.clone(:name<otherfieldname>)]);

ok $msg eq $msg2, 'message equality';
nok $msg eq $msg3, 'message inequality';
ok PB::Model::Message.new(:name<a>) eq PB::Model::Message.new(:name<a>), 'empty message equality';

# message field ---------------------------------------------------------------

sub msgfield($name, *%args) { PB::Model::Message.new(name=>$name, fields=>[PB::Model::Field.new(|%args)]) }

gr_ok 'message n{required int32 x=1;}', <message>, 
    msgfield('n', label=>'required', type=>'int32', name=>'x', number=>1), 'basic message field';
gr_ok 'message n{
        optional string mylabel = 1 [default="farting"];
        optional float mylabel2 = 2;
        }', 
    <message>,
    PB::Model::Message.new(name=>'n', fields=>[
        PB::Model::Field.new(label=>'optional', type=>'string', name=>'mylabel', number=>1, 
            options=>[PB::Model::Option.new(name=>'default', constant=>"farting")]),
        PB::Model::Field.new(label=>'optional', type=>'float', name=>'mylabel2', number=>2)
    ]),
    'message w/ multiple fields, one with an option';

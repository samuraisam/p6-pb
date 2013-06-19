use Test;
use PB::Grammar;
use PB::Actions;

sub gr_ok($text, $rule, $expected, $desc?) { 
    my $actions = PB::Actions.new;
    my $result = PB::Grammar.parse($text, rule => $rule, actions => $actions).ast;
    # say ' expected: ', $expected.perl;
    # say '   result: ', $result.perl;
    ok $result eq $expected, $desc;
}

gr_ok '"hello"', <str-lit>, "hello", "str-lit basic";
gr_ok '"hello \xc3"', <str-lit>, "hello \xc3", "str-lit unicode escape";
gr_ok "'\\176'", <str-lit>, "~", 'str-lit oct escape, single-quote';
gr_ok "'\\n'", <str-lit>, "\n", 'str-lit newline escape';
gr_ok '"\\\\"', <str-lit>, '\\', 'str-lit double backslash escape';
# TODO: test the other backslash char escapes

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

gr_ok 'option x = 1;', <option>, PB::Option.new(name => 'x', constant => 1), 'option int const';
gr_ok 'option x = 1.0;', <option>, PB::Option.new(name => 'x', constant => 1.0), 'option float const';
gr_ok 'option x = 0xf4;', <option>, PB::Option.new(name => 'x', constant => 244), 'option hex const';
gr_ok 'option x = 070;', <option>, PB::Option.new(name => 'x', constant => 56), 'option opt const';
gr_ok 'option x = -.2e5;', <option>, PB::Option.new(name => 'x', constant => -.2e5), 'option float exponent';
gr_ok 'option x = false;', <option>, PB::Option.new(name => 'x', constant => False), 'option false';
gr_ok 'option x = true;', <option>, PB::Option.new(name => 'x', constant => True), 'option true';
gr_ok 'option x = inf;', <option>, PB::Option.new(name => 'x', constant => Inf), 'option inf';
gr_ok 'option x = -inf;', <option>, PB::Option.new(name => 'x', constant => -Inf), 'option -inf';
gr_ok 'option x = nan;', <option>, PB::Option.new(name => 'x', constant => NaN), 'option NaN';
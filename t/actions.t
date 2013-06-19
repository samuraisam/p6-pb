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
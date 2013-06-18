use Test;
use PB::Grammar;
use PB::Actions;

sub gr_ok($text, $rule, $expected, $desc?) { 
    my $actions = PB::Actions.new;
    my $result = PB::Grammar.parse($text, rule => $rule, actions => $actions).ast;
    say ' expected: ', $expected.perl;
    say '   result: ', $result.perl;
    ok $result eq $expected, $desc;
}

gr_ok '"hello"', <str-lit>, "hello", "str-lit basic";
gr_ok '"hello \xc3"', <str-lit>, "hello \xc3", "str-lit unicode escape";
gr_ok "'\\176'", <str-lit>, "~", 'str-lit oct escape, single-quote';
gr_ok "'\\n'", <str-lit>, "\n", 'str-lit newline escape';
gr_ok '"\\\\"', <str-lit>, '\\', 'str-lit double backslash escape';
# TODO: test the other backslash char escapes
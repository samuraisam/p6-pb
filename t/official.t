use Test;
use File::Spec;
use PB::Grammar;

# to automate the testing of this grammar
sub g_ok (Str $testme, Str $desc?) { ok PB::Grammar.parse($testme), $desc; }

# download the unit test files from the offical google repo and test our grammar against them
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
        g_ok(slurp(open $path), "parse {$path}");
    }
} else {
    say 'svn is not installed... skipping official protobuf tests';
}

#!/usr/bin/perl -w
use strict;

use Test::More;
my $tests;
plan tests => $tests;
use File::Tools;

{
    my $full_path = File::Tools::catfile("a",  "b", "c");
    is File::Tools::basename($full_path), "c", "catfile and basename";
    is File::Tools::dirname($full_path), File::Tools::catfile("a", "b"), "catfile, dirname, catfile";

    BEGIN { $tests += 2; }
}

{
    my $data = File::Tools::slurp "t/data/file1";
    open my $fh1, "<", "t/data/file1" or die;
    my $expected = join "", <$fh1>;
    is $data, $expected, "slurp of one file works";

    my $data2 = File::Tools::slurp "t/data/file1", "t/data/file2";
    open my $fh2, "<", "t/data/file2" or die;
    my $expected2 = $expected . join "", <$fh2>;
    is $data2, $expected2, "slurp of two files works";

    my $warn;
    local $SIG{__WARN__} = sub {$warn = shift};
    my $data3 = File::Tools::slurp "t/data/file1", "t/data/nosuch", "t/data/file2";
    is $data3, $expected2, "slurp of two files (and one missing) works";
    is $warn, "Could not open 't/data/nosuch'\n", "warning received correctly";

    BEGIN { $tests += 4; }
}

{
    my $cwd1 = File::Tools::cwd;
    my $pushd = File::Tools::pushd("t");
    my $cwd2 = File::Tools::cwd;
    is $cwd2, "$cwd1/t", "pushd changes to the new directory";
    is $pushd, "$cwd1/t", "pushd returns the new directory";

    my $popd = File::Tools::popd;
    my $cwd3 = File::Tools::cwd;
    is $popd, $cwd1, "popd returns the original directory";
    is $cwd3, $cwd1, "popd changes to the original directory";

    BEGIN { $tests += 4; }
}

{
    File::Tools::copy($0, "$0.tmp") or die "Could not copy $0 to $0.tmp";
    is File::Tools::compare($0, "$0.tmp"), 0, "filed copied is the same";

    open my $fh, ">>", "$0.tmp" or die "Cannot open $0.tmp: $!";
    print {$fh} "\n";
    close $fh;
    is File::Tools::compare($0, "$0.tmp"), 1, "filed copied is the same";
   
    BEGIN { $tests += 2; }
}


# chmod
# copy
# date
# fileparse
# find
# move
# mail
# rmtree

#!perl

use 5.010;
use strict;
use warnings;

use TableData::Object qw(table);
use Test::Exception;
use Test::More 0.98;

my $td = table([{a=>1},{a=>3,b=>30},{a=>2,b=>20,c=>200}]);
ok($td->isa("TableData::Object::aohos"), "isa");

is_deeply($td->cols_by_name, {a=>0, b=>1, c=>2}, "cols_by_name");
is_deeply($td->cols_by_idx, ['a','b','c'], "cols_by_idx");
is($td->row_count, 3, "row_count");
is($td->col_count, 3, "col_count");

subtest col_exists => sub {
    ok( $td->col_exists("a"));
    ok( $td->col_exists("b"));
    ok(!$td->col_exists("d"));
};

subtest col_name => sub {
    is_deeply($td->col_name(0), "a");
    is_deeply($td->col_name("b"), "b");
    is_deeply($td->col_name("d"), undef);
    is_deeply($td->col_name(3), undef);
};

subtest col_idx => sub {
    is_deeply($td->col_idx(0), 0);
    is_deeply($td->col_idx("b"), 1);
    is_deeply($td->col_idx("d"), undef);
    is_deeply($td->col_idx(3), undef);
};

subtest rows_as_aoaos => sub {
    is_deeply($td->rows_as_aoaos, [[1,undef,undef],[3,30,undef],[2,20,200]]);
};

subtest rows_as_aohos => sub {
    is_deeply($td->rows_as_aohos, [{a=>1},{a=>3,b=>30},{a=>2,b=>20,c=>200}]);
};

subtest select => sub {
    my $td2;

    dies_ok { $td->select_as_aoaos(["foo"]) } "unknown column -> dies";

    $td2 = $td->select_as_aoaos();
    is_deeply($td2->rows_as_aoaos, [[1,undef,undef],[3,30,undef],[2,20,200]]);

    $td2 = $td->select_as_aoaos(["a","b","a"]);
    is_deeply($td2->rows_as_aoaos, [[1,undef,1],[3,30,3],[2,20,2]]);

    $td2 = $td->select_as_aohos(["a","b","a"]);
    is_deeply($td2->rows_as_aohos, [{a=>1,b=>undef,a_2=>1},{a=>3,b=>30,a_2=>3},{a=>2,b=>20,a_2=>2}]);

    # filter & sort
    dies_ok { $td->select_as_aoaos([], undef, ["foo"]) } "unknown sort column -> dies";
    $td2 = $td->select_as_aoaos(["c"],
                                sub { my ($td, $row) = @_; $row->{a} > 1 },
                                ["a"]);
    is_deeply($td2->rows_as_aoaos, [[200],[undef]]);
};

subtest const_col_names => sub {
    my $td = table([{a=>1, b=>2}, {a=>2,b=>2,c=>3}, {a=>2,b=>2,c=>3}]);
    is_deeply($td->const_col_names, ["b"]);
};

DONE_TESTING:
done_testing;

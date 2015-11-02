#!perl

use 5.010;
use strict;
use warnings;

use TableData::Object qw(table);
use Test::Exception;
use Test::More 0.98;

my $td = table({a=>1, b=>2, c=>3});
ok($td->isa("TableData::Object::hash"), "isa");

is_deeply($td->cols_by_name, {key=>0, value=>1}, "cols_by_name");
is_deeply($td->cols_by_idx, ['key', 'value'], "cols_by_idx");
is($td->row_count, 3, "row_count");
is($td->col_count, 2, "col_count");

subtest col_exists => sub {
    ok( $td->col_exists("key"));
    ok( $td->col_exists("value"));
    ok(!$td->col_exists("foo"));
};

subtest col_name => sub {
    is_deeply($td->col_name(0), "key");
    is_deeply($td->col_name("key"), "key");
    is_deeply($td->col_name(1), "value");
    is_deeply($td->col_name("foo"), undef);
};

subtest col_idx => sub {
    is_deeply($td->col_idx(0), 0);
    is_deeply($td->col_idx("key"), 0);
    is_deeply($td->col_idx("value"), 1);
    is_deeply($td->col_idx("foo"), undef);
};

subtest rows_as_aoaos => sub {
    is_deeply($td->rows_as_aoaos, [["a",1],["b",2],["c",3]]);
};

subtest rows_as_aohos => sub {
    is_deeply($td->rows_as_aohos, [{key=>"a",value=>1},{key=>"b",value=>2},{key=>"c",value=>3}]);
};

subtest select => sub {
    my $td2;

    dies_ok { $td->select_as_aoaos(["foo"]) } "unknown column -> dies";

    $td2 = $td->select_as_aoaos(["value", "value"]);
    is_deeply($td2->rows_as_aoaos, [[1,1],[2,2],[3,3]]);

    $td2 = $td->select_as_aohos(["value", "value"]);
    is_deeply($td2->rows_as_aohos, [{value=>1,value_2=>1},{value=>2,value_2=>2},{value=>3,value_2=>3}]);

    # filter & sort
    dies_ok { $td->select_as_aoaos([], undef, ["foo"]) } "unknown sort column -> dies";
    $td2 = $td->select_as_aoaos(["value", "key"],
                                sub { my ($td, $row) = @_; $row->{value} % 2 },
                                ["-key"]);
    is_deeply($td2->rows_as_aoaos, [[3,"c"],[1,"a"]]);
};

DONE_TESTING:
done_testing;

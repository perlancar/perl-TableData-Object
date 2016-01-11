#!perl

use 5.010;
use strict;
use warnings;

use TableData::Object qw(table);
use Test::Exception;
use Test::More 0.98;

my $td = table([[1,2],[5,6],[3,4]]);
ok($td->isa("TableData::Object::aoaos"), "isa");

is_deeply($td->cols_by_name, {column0=>0, column1=>1}, "cols_by_name");
is_deeply($td->cols_by_idx, ['column0','column1'], "cols_by_idx");
is($td->row_count, 3, "row_count");
is($td->col_count, 2, "col_count");

my $tds = table([[1,2],[5,6],[3,4]],
                {fields=>{satu=>{schema=>"int",pos=>0},
                          dua=>{schema=>"float",pos=>1}}});
subtest "with spec" => sub {
    is_deeply($tds->cols_by_name, {satu=>0, dua=>1}, "cols_by_name");
    is_deeply($tds->cols_by_idx, ['satu','dua'], "cols_by_idx");
};

subtest col_exists => sub {
    ok( $td->col_exists("column0"));
    ok( $td->col_exists("column1"));
    ok(!$td->col_exists("column2"));
};

subtest col_name => sub {
    is_deeply($td->col_name(0), "column0");
    is_deeply($td->col_name("column1"), "column1");
    is_deeply($td->col_name("column2"), undef);
};

subtest col_idx => sub {
    is_deeply($td->col_idx(0), 0);
    is_deeply($td->col_idx("column1"), 1);
    is_deeply($td->col_idx("column2"), undef);
};

subtest rows_as_aoaos => sub {
    is_deeply($td->rows_as_aoaos, [[1,2],[5,6],[3,4]]);
};

subtest rows_as_aohos => sub {
    is_deeply($td->rows_as_aohos, [{column0=>1,column1=>2},{column0=>5,column1=>6},{column0=>3,column1=>4}]);
};

subtest select => sub {
    my $td2;

    dies_ok { $td->select_as_aoaos(["foo"]) } "unknown column -> dies";

    $td2 = $td->select_as_aoaos();
    is_deeply($td2->rows_as_aoaos, [[1,2],[5,6],[3,4]]);

    $td2 = $td->select_as_aoaos(["column1","column0","column1"]);
    is_deeply($td2->rows_as_aoaos, [[2,1,2],[6,5,6],[4,3,4]]);

    $td2 = $td->select_as_aohos(["column1","column0","column1"]);
    is_deeply($td2->rows_as_aohos, [{column1=>2, column0=>1, column1_2=>2},{column1=>6, column0=>5, column1_2=>6},{column1=>4, column0=>3, column1_2=>4}]);

    # filter & sort
    dies_ok { $td->select_as_aoaos([], undef, ["foo"]) } "unknown sort column -> dies";
    $td2 = $td->select_as_aoaos(["column1"],
                                sub { my ($td, $row) = @_; $row->{column0} > 1 },
                                ["-column1"]);
    is_deeply($td2->rows_as_aoaos, [[6],[4]]);
};

{
    my $td = table([[1,2],[2,2,3],[2,2,3]]);
    subtest const_col_names => sub {
        is_deeply($td->const_col_names, ["column1"]);
    };
    subtest const_col_idxs => sub {
        is_deeply($td->const_col_idxs, [1]);
    };
}

DONE_TESTING:
done_testing;

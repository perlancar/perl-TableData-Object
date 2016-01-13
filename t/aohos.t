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

subtest uniq_col_names => sub {
    is_deeply([TableData::Object::aohos->new([])->uniq_col_names], []);
    is_deeply([table([
        {a=>1, b=>1,       d=>undef},
        {a=>2, b=>2, c=>2, d=>1},
        {a=>3, b=>2, c=>3, d=>2},
    ])->uniq_col_names], ['a']);
};

subtest const_col_names => sub {
    is_deeply([TableData::Object::aohos->new([])->const_col_names], []);
    is_deeply([table([
        {a=>2, b=>1,       d=>undef},
        {a=>2, b=>2, c=>2, d=>undef},
        {a=>2, b=>2, c=>3, d=>undef},
    ])->const_col_names], ['a','d']);
};

subtest del_col => sub {
    my $td = table(
        [{column0=>1,column1=>2,column2=>3},
         {column0=>4,column1=>5,column2=>6},
         {column0=>7,column1=>8,column2=>9},],
        {
            fields => {
                column0 => {pos=>0},
                column1 => {pos=>1},
                column2 => {pos=>2},
            },
        },
    );

    is_deeply($td->del_col('foo'), undef);

    is_deeply($td->del_col('column0'), 'column0');
    is_deeply($td->cols_by_name, {column1=>0, column2=>1});
    is_deeply($td->cols_by_idx, ['column1','column2']);
    is_deeply($td->{spec}{fields}, {column1=>{pos=>0}, column2=>{pos=>1}});
    is_deeply($td->{data}, [{column1=>2,column2=>3},{column1=>5,column2=>6},{column1=>8,column2=>9},],);

    is_deeply($td->del_col(1), 'column2');
    is_deeply($td->cols_by_name, {column1=>0});
    is_deeply($td->cols_by_idx, ['column1']);
    is_deeply($td->{spec}{fields}, {column1=>{pos=>0}});
    is_deeply($td->{data}, [{column1=>2},{column1=>5},{column1=>8},],);

    is_deeply($td->del_col(0), 'column1');
    is_deeply($td->cols_by_name, {});
    is_deeply($td->cols_by_idx, []);
    is_deeply($td->{spec}{fields}, {});
    is_deeply($td->{data}, [{},{},{}]);
};

subtest rename_col => sub {
    my $td = table(
        [{column0=>1,column1=>2,column2=>3},
         {column0=>4,column1=>5,column2=>6},
         {column0=>7,column1=>8,column2=>9},],
        {
            fields => {
                column0 => {pos=>0},
                column1 => {pos=>1},
                column2 => {pos=>2},
            },
        },
    );

    dies_ok { $td->rename_col('foo', 'bar') }
        "rename unknown column -> dies";

    dies_ok { $td->rename_col('column0', '12') }
        "new column name must not be a number";

    lives_ok { $td->rename_col('column0', 'column0') }
        "rename column to itself -> no-op";

    $td->rename_col('column0', 'column9');
    is_deeply($td->cols_by_name, {column9=>0, column1=>1, column2=>2});
    is_deeply($td->cols_by_idx, ['column9', 'column1','column2']);
    is_deeply($td->{spec}{fields}, {column9=>{pos=>0}, column1=>{pos=>1}, column2=>{pos=>2}});
    is_deeply($td->{data}, [{column9=>1,column1=>2,column2=>3},
                            {column9=>4,column1=>5,column2=>6},
                            {column9=>7,column1=>8,column2=>9}]);
};

subtest switch_cols => sub {
    my $td = table(
        [{column0=>1,column1=>2,column2=>3},
         {column0=>4,column1=>5,column2=>6},
         {column0=>7,column1=>8,column2=>9},],
        {
            fields => {
                column0 => {pos=>0},
                column1 => {pos=>1},
                column2 => {pos=>2},
            },
        },
    );

    dies_ok { $td->switch_cols('foo', 'column1') }
        "switch unknown column 1 -> dies";
    dies_ok { $td->switch_cols('column1', 'foo') }
        "switch unknown column 2 -> dies";

    lives_ok { $td->switch_cols('column0', '0') }
        "switch the same column -> no-op";

    $td->switch_cols('column0', 'column2');
    is_deeply($td->cols_by_name, {column2=>0, column1=>1, column0=>2});
    is_deeply($td->cols_by_idx, ['column2', 'column1','column0']);
    is_deeply($td->{spec}{fields}, {column2=>{pos=>0}, column1=>{pos=>1}, column0=>{pos=>2}});
    is_deeply($td->{data}, [{column2=>1,column1=>2,column0=>3},
                            {column2=>4,column1=>5,column0=>6},
                            {column2=>7,column1=>8,column0=>9}]);
};

DONE_TESTING:
done_testing;

#!perl

use 5.010;
use strict;
use warnings;

use TableData::Object qw(table);
use Test::Exception;
use Test::More 0.98;

dies_ok { table() } "unknown form 1";
dies_ok { table(1) } "unknown form 2";

subtest aos => sub {
    my $td = table([10, 11, 12]);

    ok($td->isa("TableData::Object::aos"), "class");
    is_deeply($td->columns, ["data"], "default columns");

    dies_ok { $td->columns(["num","num2"]) }
        "new columns must have same number of columns";
    $td->columns(["num"]);
    is_deeply($td->columns, ["num"], "set columns");

    is_deeply($td->rows_as_array, [[10],[11],[12]], "rows_as_array");
    is_deeply($td->as_aoaos     , [[10],[11],[12]], "as_aoaos");
    is_deeply($td->rows_as_hash , [{num=>10},{num=>11},{num=>12}], "rows_as_hash");
    is_deeply($td->as_aohos     , [{num=>10},{num=>11},{num=>12}], "as_aohos");

    is_deeply($td->column_data("num"), [10,11,12], "column_data");
    dies_ok { $td->column_data("data") } "column_data() on unknown column dies";
};

my $tspec = {
    fields => {
        name   => {pos=>0, },
        salary => {pos=>1, },
    },
    pk => "name",
};

subtest aoaos => sub {
    my $td = table([["andi",3000],["budi",4000],["citra",2500]]);

    ok($td->isa("TableData::Object::aoaos"), "class");
    is_deeply($td->columns, ["column0","column1"], "default columns");

    dies_ok { $td->columns(["nom"]) }
        "new columns must have same number of columns";
    $td->columns(["name","salary"]);
    is_deeply($td->columns, ["name","salary"], "set columns");

    is_deeply($td->rows_as_array, [["andi",3000],["budi",4000],["citra",2500]], "rows_as_array");
    is_deeply($td->as_aoaos     , [["andi",3000],["budi",4000],["citra",2500]], "as_aoaos");
    is_deeply($td->rows_as_hash , [{name=>"andi",salary=>3000},{name=>"budi",salary=>4000},{name=>"citra",salary=>2500}], "rows_as_hash");
    is_deeply($td->as_aohos     , [{name=>"andi",salary=>3000},{name=>"budi",salary=>4000},{name=>"citra",salary=>2500}], "as_aohos");

    is_deeply($td->column_data("salary"), [3000,4000,2500], "column_data");
    dies_ok { $td->column_data("x") } "column_data() on unknown column dies";
};

subtest "aoaos with spec" => sub {
    my $td = table([["andi",3000],["budi",4000],["citra",2500]], $tspec);

    is_deeply($td->columns, ["name","salary"], "default columns");
};

subtest aohos => sub {
    my $td = table([{name=>"andi",salary=>3000},
                    {name=>"budi",salary=>4000,note=>"test"},
                    {name=>"citra",salary=>2500}]);

    ok($td->isa("TableData::Object::aohos"), "class");
    is_deeply($td->columns, ["name","note","salary"], "default columns");

    # TODO: set columns not yet implemented

    is_deeply($td->rows_as_array, [["andi",undef,3000],["budi","test",4000],["citra",undef,2500]], "rows_as_array");
    is_deeply($td->as_aoaos     , [["andi",undef,3000],["budi","test",4000],["citra",undef,2500]], "rows_as_array");
    is_deeply($td->rows_as_hash , [{name=>"andi",salary=>3000},{name=>"budi",salary=>4000,note=>"test"},{name=>"citra",salary=>2500}], "rows_as_hash");
    is_deeply($td->as_aohos     , [{name=>"andi",salary=>3000},{name=>"budi",salary=>4000,note=>"test"},{name=>"citra",salary=>2500}], "as_aohos");

    is_deeply($td->column_data("salary"), [3000,4000,2500], "column_data");
    dies_ok { $td->column_data("x") } "column_data() on unknown column dies";
};

subtest "aohos with spec" => sub {
    my $td = table([{name=>"andi",salary=>3000},
                    {name=>"budi",salary=>4000,note=>"test"},
                    {name=>"citra",salary=>2500}], $tspec);

    is_deeply($td->columns, ["name","salary"], "default columns");
    is_deeply($td->rows_as_array, [["andi",3000],["budi",4000],["citra",2500]], "rows_as_array");
};

DONE_TESTING:
done_testing;

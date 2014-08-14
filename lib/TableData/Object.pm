package TableData::Object;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use experimental 'smartmatch';

use Data::Check::Structure qw(is_aos is_aoaos is_aohos);

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(table);

sub table { __PACKAGE__->new(@_) }

sub new {
    my ($class, $data, $spec) = @_;
    if (!defined($data)) {
        die "Please specify table data";
    } elsif (is_aos($data, {max=>10})) {
        TableData::Object::aos->new($data);
    } elsif (is_aoaos($data, {max=>10})) {
        TableData::Object::aoaos->new($data, $spec);
    }elsif (is_aohos($data, {max=>10})) {
        TableData::Object::aohos->new($data, $spec);
    } else {
        die "Unknown table data form, please supply array of scalar, ".
            "array of array of scalar, or array of hash of scalar";
    }
}

sub as_aoaos { shift->rows_as_array(@_) }

sub as_aohos { shift->rows_as_hash(@_) }

sub columns {
    my ($self, $val) = @_;
    if ($val) {
        die "Number of columns must stay the same"
            unless @$val == @{$self->{columns}};
        my $oldval = $self->{columns};
        $self->{columns} = $val;
        return $oldval;
    }
    $self->{columns};
}

sub _columns_from_spec {
    my ($self, $spec) = @_;
    my @cols;
    my $ff = $spec->{fields};
    for my $fn (keys %$ff) {
        my $f = $ff->{$fn};
        $cols[ $f->{pos} ] = $fn;
    }
    \@cols;
}

package
    TableData::Object::aos;
our @ISA = qw(TableData::Object);

sub new {
    my ($class, $data) = @_;
    bless {columns=>["data"], data=>$data}, $class;
}

sub rows_as_array {
    my $self = shift;
    [ map {[$_]} @{$self->{data}} ];
}

sub rows_as_hash {
    my $self = shift;
    my $cols = $self->{columns};
    [ map {{$cols->[0] => $_}} @{$self->{data}} ];
}


package
    TableData::Object::aoaos;
our @ISA = qw(TableData::Object);

sub new {
    my ($class, $data, $spec) = @_;
    my $self = bless {}, $class;

    my $cols;
    if ($spec) {
        $cols = $self->_columns_from_spec($spec);
    } else {
        $cols = [map {"column$_"} 0..@{$data->[0]}-1];
    }
    $self->{columns} = $cols;
    $self->{data} = $data;
    $self;
}

sub rows_as_array { shift->{data} }

sub rows_as_hash {
    my $self = shift;
    my $cols = $self->{columns};
    my @res;
    for my $row (@{ $self->{data} }) {
        my $hos = { map { $cols->[$_] => $row->[$_] } 0..@$cols-1 };
        push @res, $hos;
    }
    \@res;
}


package
    TableData::Object::aohos;
our @ISA = qw(TableData::Object);

sub new {
    my ($class, $data, $spec) = @_;
    my $self = bless {}, $class;

    my $cols;
    if ($spec) {
        $cols = $self->_columns_from_spec($spec);
    } else {
        my %cols0;
        for my $row (@$data) {
            $cols0{$_}++ for keys %$row;
        }
        $cols = [sort keys %cols0];
    }
    $self->{columns} = $cols;
    $self->{data} = $data;
    $self;
}

sub columns {
    my ($self, $val) = @_;
    if ($val) {
        die "Setting columns for aohos not yet implemented";
    }
    $self->{columns};
}

sub rows_as_array {
    my $self = shift;
    my $cols = $self->{columns};
    my @res;
    for my $row (@{ $self->{data} }) {
        my $aos = [ map { $row->{$_} } @$cols ];
        push @res, $aos;
    }
    \@res;
}

sub rows_as_hash { shift->{data} }

1;
# ABSTRACT: Manipulate table data

=head1 SYNOPSIS

 use TableData::Object qw(table);

 $td = TableData::Object->new([1, 2, 3, 4]);  # from array of scalars
 $td = TableData::Object->new([[1,2],[2,3]]); # from array of arrays of scalars
 $td = TableData::Object->new([{name=>"Andi"}, {name=>"Budi", gender=>"m"}]);
                                              # from array of hashes of scalars
 $td = TableData::Object->new(4); # die, can only accept in the above form

 # shortcut to construct object
 $td = table(...);

 # for the examples below, this object is assumed
 $td = TableData::Object->new([["Andi",3000], ["Budi",4000], ["Cinta",2500]]);

 # retrieve names of columns
 $cols = $td->columns; # -> ["column0", "column1"]

 # set names of columns
 $td->columns(["name", "salary"]);

 # retrieve rows data, each row as arrays
 $rows = $td->rows_as_array; # -> (["Andi",3000], ["Budi",4000], ["Cinta",2500])

 # retrieve rows data, each row as hash
 $rows = $td->rows_as_hash; # -> ({name=>"Andi",salary=>3000}, {name=>"Budi",salary=>4000}, {name=>"Cinta",salary=>2500})

 # retrieve a specific row
 $row = $td->row_as_array(2); # -> ["Cinta",2500]
 $row = $td->row_as_hash(1); # -> [{name=>"Budi",salary=>4000}]

 # convert to specific forms
 $data = $td->as_aoaos;
 $data = $td->as_aohos;

 # XXX add row

 # XXX add column

 # XXX delete row(s)

 # XXX delete column(s)

 # XXX rename column

 # XXX reorder column


=head1 DESCRIPTION

This module provides a class to manipulate table data. Table data can be in the
form of array of scalars (aos), array of arrays of scalars (aoaos), or array of
hashes of scalars (aohos). There are methods to get/set the columns/rows,
convert to the other forms, etc.

Aos data is assumed to be a single-column table with column named C<data> (but
this can be renamed). Aoaos data is assumed to have columns named C<column0>,
C<column1>, and so on (but this can be changed). Aohos data is assumed to have
columns according to the hash keys (sorted alphabetically) and column names
cannot be changed.


=head1 FUNCTIONS

=head2 table($data[, $spec]) => obj

Exportable. Shortcut for constructor.


=head1 METHODS

=head2 new($data[, $spec]) => obj

Constructor.

C<$spec> is optional and should be table specification hash according
L<TableDef>.

=head2 columns([ $cols ]) => array

Get or set columns.

=head2 rows_as_array => array of array of scalar

=head2 rows_as_hash => array of hash of scalar

=head2 row_as_array($index) => array of scalar

=head2 row_as_hash($index) => hash of scalar

=head2 as_aoaos() => array of array of scalar

=head2 as_aohos() => array of hash of scalar


=head1 TODO


=head1 SEE ALSO

L<TableDef>

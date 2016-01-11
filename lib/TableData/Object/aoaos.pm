package TableData::Object::aoaos;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use parent 'TableData::Object::Base';

sub new {
    my ($class, $data, $spec) = @_;
    my $self = bless {
        data     => $data,
        spec     => $spec,
    }, $class;
    if ($spec) {
        $self->{cols_by_idx}  = [];
        my $ff = $spec->{fields};
        for (keys %$ff) {
            $self->{cols_by_idx}[ $ff->{$_}{pos} ] = $_;
        }
        $self->{cols_by_name} = {
            map { $_ => $ff->{$_}{pos} }
                keys %$ff
        };
    } else {
        if (@$data) {
            my $ncols = @{ $data->[0] };
            $self->{cols_by_idx}  = [ map {"column$_"} 0 .. $ncols-1 ];
            $self->{cols_by_name} = { map {("column$_" => $_)} 0..$ncols-1 };
        } else {
            $self->{cols_by_idx}  = [];
            $self->{cols_by_name} = {};
        }
    }
    $self;
}

sub row_count {
    my $self = shift;
    scalar @{ $self->{data} };
}

sub rows_as_aoaos {
    my $self = shift;
    $self->{data};
}

sub rows_as_aohos {
    my $self = shift;
    my $data = $self->{data};

    my $cols = $self->{cols_by_idx};
    my $rows = [];
    for my $aos (@{$self->{data}}) {
        my $row = {};
        for my $i (0..$#{$cols}) {
            $row->{$cols->[$i]} = $aos->[$i];
        }
        push @$rows, $row;
    }
    $rows;
}

sub _const_col {
    my ($self, $which) = @_;

    my $res = [];
  COL:
    for my $colname (keys %{$self->{cols_by_name}}) {
        my $colidx = $self->{cols_by_name}{$colname};
        my $i = -1;
        my $val;
        for my $row (@{$self->{data}}) {
            next COL unless $#{$row} >= $colidx;
            $i++;
            if ($i == 0) {
                $val = $row->[$colidx];
            } else {
                next COL unless
                    (!defined($val) && !defined($row->[$colidx])) ||
                    ( defined($val) &&  defined($row->[$colidx]) && $val eq $row->[$colidx]);
            }
        }
        if ($which eq 'name') {
            push @$res, $colname;
        } else {
            push @$res, $colidx;
        }
    }

    if ($which eq 'name') {
        return [sort {$a cmp $b} @$res];
    } else {
        return [sort {$a <=> $b} @$res];
    }
}

sub const_col_names {
    my $self = shift;
    $self->_const_col('name');
}

sub const_col_idxs {
    my $self = shift;
    $self->_const_col('idx');
}

1;
# ABSTRACT: Manipulate array of arrays-of-scalars via table object

=for Pod::Coverage .+

=head1 SYNOPSIS

To create:

 use TableData::Object qw(table);

 my $td = table([[1,2,3], [4,5,6]]);

or:

 use TableData::Object::aoaos;

 my $td = TableData::Object::aoaos->new([[1,2,3], [4,5,6]]);

To manipulate:

 $td->cols_by_name; # {column0=>0, column1=>1, column2=>2}
 $td->cols_by_idx;  # ['column0', 'column1', 'column2']


=head1 DESCRIPTION

This class lets you manipulate an array of arrays-of-scalars as a table object.
The table will have column names C<column0>, C<column1>, and so on. The first
array-of-scalars will determine the number of columns.


=head1 METHODS

See L<TableData::Object::Base>. Additional methods include:

=head2 const_col_names => arrayref

Return names of columns that exist in all arrays with the same value. Example:

 # data: [[1,2], [2,2,3], [1,2,3]]
 $td->const_col_names; # ['column1'], 'column0' has a different value in 2nd array, 'column2' doesn't exist in all rows

=head2 const_col_idxs => arrayref

Just like C<const_col_names> except that it will return column indexes instead
of names:

 # data: [[1,2], [2,2,3], [1,2,3]]
 $td->const_col_idxs; # [1]

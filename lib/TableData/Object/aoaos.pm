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

sub uniq_col_names {
    my ($self, $which) = @_;

    my @res;
  COL:
    for my $colname (sort keys %{$self->{cols_by_name}}) {
        my $colidx = $self->{cols_by_name}{$colname};
        my %mem;
        for my $row (@{$self->{data}}) {
            next COL unless $#{$row} >= $colidx;
            next COL unless defined $row->[$colidx];
            next COL if $mem{ $row->[$colidx] }++;
        }
        push @res, $colname;
    }

    @res;
}

sub const_col_names {
    my ($self, $which) = @_;

    my @res;
  COL:
    for my $colname (sort keys %{$self->{cols_by_name}}) {
        my $colidx = $self->{cols_by_name}{$colname};
        my $i = -1;
        my $val;
        my $val_undef;
        for my $row (@{$self->{data}}) {
            next COL unless $#{$row} >= $colidx;
            $i++;
            if ($i == 0) {
                $val = $row->[$colidx];
                $val_undef = 1 unless defined $val;
            } else {
                if ($val_undef) {
                    next COL if defined;
                } else {
                    next COL unless defined $row->[$colidx];
                    next COL unless $val eq $row->[$colidx];
                }
            }
        }
        push @res, $colname;
    }

    @res;
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

See L<TableData::Object::Base>.

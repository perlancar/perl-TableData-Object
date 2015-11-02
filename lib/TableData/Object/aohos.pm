package TableData::Object::aohos;

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
        my %cols;
        for my $row (@$data) {
            $cols{$_}++ for keys %$row;
        }
        my $i = 0;
        $self->{cols_by_name} = {};
        $self->{cols_by_idx}  = [];
        for my $k (sort keys %cols) {
            $self->{cols_by_name}{$k} = $i;
            $self->{cols_by_idx}[$i] = $k;
            $i++;
        }
    }
    $self;
}

sub row_count {
    my $self = shift;
    scalar @{ $self->{data} };
}

sub sort_rows {
    my ($self, @sortcols) = @_;
    return $self unless @sortcols;

    my $data = $self->{data};

    my @aohos = sort {
        for my $sortcol (@sortcols) {
            my ($reverse, $col) = $sortcol =~ /\A(-?)(.+)/;
            my $name = $self->col_name($col);
            die "Unknown sort column '$col'" unless defined($name);
            my $cmp = ($reverse ? -1:1) *
                (($a->{$name} // '') cmp ($b->{$name} // ''));
            return $cmp if $cmp;
        }
        0;
    } @$data;

    __PACKAGE__->new(\@aohos, $self->{spec});
}

sub rows_as_aoaos {
    my $self = shift;
    my $data = $self->{data};

    my $cols = $self->{cols_by_idx};
    my $rows = [];
    for my $hos (@{$self->{data}}) {
        my $row = [];
        for my $i (0..$#{$cols}) {
            $row->[$i] = $hos->{$cols->[$i]};
        }
        push @$rows, $row;
    }
    $rows;
}

sub rows_as_aohos {
    my $self = shift;
    $self->{data};
}

1;
# ABSTRACT: Manipulate array of hashes-of-scalars via table object

=for Pod::Coverage .+

=head1 SYNOPSIS

To create:

 use TableData::Object qw(table);

 my $td = table([{foo=>10, bar=>10}, {bar=>20, baz=>20}]);

or:

 use TableData::Object::aohos;

 my $td = TableData::Object::aohos->new([{foo=>10, bar=>10}, {bar=>20, baz=>20}]);

To manipulate:

 $td->cols_by_name; # {foo=>0, bar=>1, baz=>2}
 $td->cols_by_idx;  # ['foo', 'bar', 'baz']


=head1 DESCRIPTION

This class lets you manipulate an array of hashes-of-scalars as a table object.
The table will have columns from all the hashes' keys.


=head1 METHODS

See L<TableData::Object::Base>.

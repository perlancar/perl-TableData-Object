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

1;
# ABSTRACT: Manipulate array of (hashes of scalars) via table object

=for Pod::Coverage .+

package TableData::Object::hash;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use parent 'TableData::Object::Base';

sub new {
    my ($class, $data) = @_;

    bless {
        data         => $data,
        cols_by_name => {key=>0, value=>1},
        cols_by_idx  => ["key", "value"],
    }, $class;
}

sub row_count {
    my $self = shift;
    scalar keys %{ $self->{data} };
}

sub sort_rows {
    my ($self, @sortcols) = @_;
    return $self unless @sortcols;

    my $data = $self->{data};

    my @aoaos = sort {
        for my $sortcol (@sortcols) {
            say "D1";
            my ($reverse, $col) = $sortcol =~ /\A(-?)(.+)/;
            my $idx = $self->col_idx($col);
            die "Unknown sort column '$col'" unless defined($idx);
            my $cmp = ($reverse ? -1:1) * ($a->[$idx] cmp $b->[$idx]);
            return $cmp if $cmp;
        }
        0;
    } map {[$_, $data->{$_}]} keys %$data;

    require TableData::Object::aoaos;
    TableData::Object::aoaos->new(
        data => \@aoaos,
        spec => {
            fields => {
                key   => {pos=>0},
                value => {pos=>1},
            },
            pk => 'key',
        },
    );
}


1;
# ABSTRACT: Manipulate hash via table object

=for Pod::Coverage .+

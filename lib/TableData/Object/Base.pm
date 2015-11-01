package TableData::Object::Base;

# DATE
# VERSION

use 5.010;
use strict;
use warnings;

use Scalar::Util::Numeric qw(isint isfloat);

sub __list_is_num {
    for (@_) {
        return 0 if defined($_) && !isint($_) && !isfloat($_);
    }
    return 1;
}

sub cols_by_name {
    my $self = shift;
    $self->{cols_by_name};
}

sub cols_by_idx {
    my $self = shift;
    $self->{cols_by_idx};
}

sub col_exists {
    my ($self, $name_or_idx) = @_;
    if ($name_or_idx =~ /\A[0-9][1-9]*\z/) {
        return $name_or_idx <= @{ $self->{cols_by_idx} };
    } else {
        return exists $self->{cols_by_name}{$name_or_idx};
    }
}

sub col_name {
    my ($self, $name_or_idx) = @_;
    if ($name_or_idx =~ /\A[0-9][1-9]*\z/) {
        return $self->{cols_by_idx}[$name_or_idx];
    } else {
        return exists($self->{cols_by_name}{$name_or_idx}) ?
            $name_or_idx : undef;
    }
}

sub col_idx {
    my ($self, $name_or_idx) = @_;
    if ($name_or_idx =~ /\A[0-9][1-9]*\z/) {
        return $name_or_idx < @{ $self->{cols_by_idx} } ? $name_or_idx : undef;
    } else {
        return $self->{cols_by_name}{$name_or_idx};
    }
}

sub col_count {
    my $self = shift;
    scalar @{ $self->{cols_by_idx} };
}

sub _select {
    my ($self, $cols, $func_filter_row) = @_;

    my $spec = {fields=>{}};
    my $i = 0;
    for (@$cols) {
        $spec->{fields}{$_} = {pos=>$i};
        $i++;
    }
    my $data = [];

    for my $row0 (@{ $self->rows }) {
        #next unless $func_filter_row->($row);
    }
}

1;
# ABSTRACT: Base class for TableData::Object::*

=head1 METHODS

=head2 new($data[ , $spec]) => obj

Constructor. C<$spec> is optional, a specification hash as described by
L<TableDef>.

=head2 $td->cols_by_name => hash

=head2 $td->cols_by_idx => array

=head2 $td->row_count() => int

Return the number of rows.

=head2 $td->col_count() => int

Return the number of columns.

=head2 $td->sort_rows(@sortcols) => obj

Return a new table object with rows sorted according to C<@sortcols>, where
C<@sortcols> is a list of column names (e.g.: C<foo>) with optional dash prefix
(e.g. C<-foo>) to signify descending order.

Example:

 # sort employees from oldest to youngest, then by name
 $td->sort_rows("-age", "name")

=head2 $td->rows() => array

Return an array(ref) of rows. In C<::hash>, will return C<< [ [key,val], ... ]
>>, and in other forms will return the raw C<data>.

=head2 $td->col_exists($name_or_idx) => bool

Check whether a column exists. Column can be referred to using its name or
index/position (0, 1, ...).

=head2 $td->col_name($idx) => str

Return the name of column referred to by its index/position. Undef if column is
unknown.

=head2 $td->col_idx($name) => int

Return the index/position of column referred to by its name. Undef if column is
unknown.

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
    my ($self, $_as, $cols, $func_filter_row) = @_;

    my $spec = {fields=>{}};
    my $i = 0;
    my %seen_cols;
    for my $col0 (@$cols) {
        die "Column '$col0' does not exist" unless $self->col_exists($col0);

        my $col = $col0;
        my $j = 1;
        while ($seen_cols{$col}) {
            $j++;
            $col = "${col0}_$j";
        }
        $seen_cols{$col} = 1;

        $spec->{fields}{$col} = {
            %{$self->{spec}{fields}{$col0} // {}},
            pos=>$i,
        };
        $i++;
    }
    my $data = [];

    for my $row0 (@{ $self->rows_as_aohos }) {
        next unless !$func_filter_row || $func_filter_row->($self, $row0);

        # select columns
        my $row;
        if ($_as eq 'aoaos') {
            $row = [];
            for my $i (0..$#{$cols}) {
                $row->[$i] = $row0->{$cols->[$i]};
            }
        } else {
            $row = {};
            for my $i (0..$#{$cols}) {
                $row->{$cols->[$i]} = $row0->{$cols->[$i]};
            }
        }

        push @$data, $row;
    }

    if ($_as eq 'aoaos') {
        require TableData::Object::aoaos;
        return TableData::Object::aoaos->new($data, $spec);
    } else {
        require TableData::Object::aohos;
        return TableData::Object::aohos->new($data, $spec);
    }
}

sub select_as_aoaos {
    my ($self, $cols, $func_filter_row) = @_;
    $self->_select('aoaos', $cols, $func_filter_row);
}

sub select_as_aohos {
    my ($self, $cols, $func_filter_row) = @_;
    $self->_select('aohos', $cols, $func_filter_row);
}

1;
# ABSTRACT: Base class for TableData::Object::*

=head1 METHODS

=head2 new($data[ , $spec]) => obj

Constructor. C<$spec> is optional, a specification hash as described by
L<TableDef>.

=head2 $td->cols_by_name => hash

Return the columns as a hash with name as keys and index as values.

Example:

 {name=>0, gender=>1, age=>2}

=head2 $td->cols_by_idx => array

Return the columns as an array where the element will correspond to the column's
position.

Example:

 ["name", "gender", "age"]

=head2 $td->row_count() => int

Return the number of rows.

See also: C<col_count()>.

=head2 $td->col_count() => int

Return the number of columns.

See also: C<row_count()>.

=head2 $td->col_exists($name_or_idx) => bool

Check whether a column exists. Column can be referred to using its name or
index/position (0, 1, ...).

=head2 $td->col_name($idx) => str

Return the name of column referred to by its index/position. Undef if column is
unknown.

See also: C<col_idx()>.

=head2 $td->col_idx($name) => int

Return the index/position of column referred to by its name. Undef if column is
unknown.

See also: C<col_name()>.

=head2 $td->sort_rows(@sortcols) => obj

Return a new table object with rows sorted according to C<@sortcols>, where
C<@sortcols> is a list of column names (e.g.: C<foo>) with optional dash prefix
(e.g. C<-foo>) to signify descending order.

Example:

 # sort employees from oldest to youngest, then by name
 $td->sort_rows("-age", "name")

If you have a C<::hash> or C<::aos> object, an C<::aoaos> object will be
returned instead. Otherwise, object of the same type will be returned.

=head2 $td->rows_as_aoaos() => aoaos

Return rows as array of array-of-scalars.

See also: C<rows_as_aohos()>.

=head2 $td->rows_as_aohos() => aohos

Return rows as array of hash-of-scalars.

See also: C<rows_as_aoaos()>.

=head2 $td->select_as_aoaos($cols[ , $func_filter_row ]) => aoaos

Like C<rows_as_aoaos()>, but allow selecting columns and filtering rows.
C<$func_filter_row> is a coderef that will be passed C<< ($td, $row_as_hos) >>
and should return true/false depending on whether the row should be included in
the resultset.

See also: C<select_as_aohos()>.

=head2 $td->rows_as_aohos($cols[ , $func_filter_row ]) => aohos

Like C<rows_as_aohos()>, but allow selecting columns and filtering rows.
C<$func_filter_row> is a coderef that will be passed C<< ($td, $row_as_hos) >>
and should return true/false depending on whether the row should be included in
the resultset.

See also: C<select_as_aoaos()>.

package TableData::Object::aos;

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
        cols_by_name => {elem=>0},
        cols_by_idx  => ["elem"],
    }, $class;
}

sub row_count {
    my $self = shift;
    scalar @{ $self->{data} };
}

sub rows {
    my $self = shift;
    $self->{data};
}

sub rows_as_aoaos {
    my $self = shift;
    [map {[$_]} @{ $self->{data} }];
}

sub rows_as_aohos {
    my $self = shift;
    [map {{elem=>$_}} @{ $self->{data} }];
}

sub uniq_col_names {
    my $self = shift;
    my %mem;
    for (@{$self->{data}}) {
        return () unless defined;
        return () if $mem{$_}++;
    }
    ('elem');
}

sub const_col_names {
    my $self = shift;

    my $i = -1;
    my $val;
    my $val_undef;
    for (@{$self->{data}}) {
        $i++;
        if ($i == 0) {
            $val = $_;
            $val_undef = 1 unless defined $val;
        } else {
            if ($val_undef) {
                return () if defined;
            } else {
                return () unless defined;
                return () unless $val eq $_;
            }
        }
    }
    ('elem');
}

sub del_col {
    die "Cannot delete column in aos table";
}

sub rename_col {
    die "Cannot rename column in aos table";
}

sub switch_cols {
    die "Cannot switch column in aos table";
}

sub add_col {
    die "Cannot add_col in aos table";
}

sub set_col_val {
    my ($self, $name_or_idx, $value_sub) = @_;

    my $col_name = $self->col_name($name_or_idx);
    my $col_idx  = $self->col_idx($name_or_idx);

    die "Column '$name_or_idx' does not exist" unless defined $col_name;

    my $hash = $self->{data};
    for my $i (0..$#{ $self->{data} }) {
        $self->{data}[$i] = $value_sub->(
            table    => $self,
            row_idx  => $i,
            col_name => $col_name,
            col_idx  => $col_idx,
            value    => $self->{data}[$i],
        );
    }
}

1;
# ABSTRACT: Manipulate array of scalars via table object

=for Pod::Coverage .*

=head1 SYNOPSIS

To create:

 use TableData::Object qw(table);

 my $td = table([1,2,3]);

or:

 use TableData::Object::aos;

 my $td = TableData::Object::aos->new([1,2,3]);


=head1 DESCRIPTION

This class lets you manipulate an array of scalars as a table object. The table
will have a single column named C<elem>.


=head1 METHODS

See L<TableData::Object::Base>.

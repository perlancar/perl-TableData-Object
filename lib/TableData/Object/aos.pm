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

sub sort_rows {
    my ($self, @sortcols) = @_;
    return $self unless @sortcols;

    my $data = $self->{data};

    my @aos = sort {
        for my $sortcol (@sortcols) {
            my ($reverse, $col) = $sortcol =~ /\A(-?)(.+)/;
            my $idx = $self->col_idx($col);
            die "Unknown sort column '$col'" unless defined($idx);
            my $cmp = ($reverse ? -1:1) * ($a cmp $b);
            return $cmp if $cmp;
        }
        0;
    } @$data;

    __PACKAGE__->new(\@aos);
}

sub rows_as_aoaos {
    my $self = shift;
    [map {[$_]} @{ $self->{data} }];
}

sub rows_as_aohos {
    my $self = shift;
    [map {{elem=>$_}} @{ $self->{data} }];
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

To manipulate:

 $td->cols_by_name; # {elem=>0}
 $td->cols_by_idx;  # ['elem']


=head1 DESCRIPTION

This class lets you manipulate an array of scalars as a table object. The table
will have a single column named C<elem>.


=head1 METHODS

See L<TableData::Object::Base>.

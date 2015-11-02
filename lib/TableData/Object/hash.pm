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

sub rows_as_aoaos {
    my $self = shift;
    my $data = $self->{data};
    [map {[$_, $data->{$_}]} sort keys %$data];
}

sub rows_as_aohos {
    my $self = shift;
    my $data = $self->{data};
    [map {{key=>$_, value=>$data->{$_}}} sort keys %$data];
}

1;
# ABSTRACT: Manipulate hash via table object

=for Pod::Coverage .+

=head1 SYNOPSIS

To create:

 use TableData::Object qw(table);

 my $td = table({foo=>10, bar=>20, baz=>30});

or:

 use TableData::Object::hash;

 my $td = TableData::Object::hash->new({foo=>10, bar=>20, baz=>30});

To manipulate:

 $td->cols_by_name; # {key=>0, value=>1}
 $td->cols_by_idx;  # ['key', 'value']


=head1 DESCRIPTION

This class lets you manipulate a hash as a table object. The table will have two
columns named C<key> (containing hash keys) and C<value> (containing hash
values).


=head1 METHODS

See L<TableData::Object::Base>.

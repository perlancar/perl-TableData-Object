package Data::TableData::Object;

use 5.010001;
use strict;
use warnings;

use Data::Check::Structure qw(is_aos is_aoaos is_aohos);
use Exporter qw(import);
use Scalar::Util qw(blessed);

# AUTHORITY
# DATE
# DIST
# VERSION

our @EXPORT_OK = qw(table);

sub table { __PACKAGE__->new(@_) }

sub new {
    my ($class, $data, $spec) = @_;
    if (!defined($data)) {
        die "Please specify table data";
    } elsif (blessed($data) && $data->isa("Data::TableData::Object::Base")) {
        return $data;
    } elsif (ref($data) eq 'HASH') {
        require Data::TableData::Object::hash;
        Data::TableData::Object::hash->new($data);
    } elsif (is_aoaos($data)) {
        require Data::TableData::Object::aoaos;
        Data::TableData::Object::aoaos->new($data, $spec);
    } elsif (is_aohos($data)) {
        require Data::TableData::Object::aohos;
        Data::TableData::Object::aohos->new($data, $spec);
    } elsif (ref($data) eq 'ARRAY') {
        require Data::TableData::Object::aos;
        Data::TableData::Object::aos->new($data);
    } else {
        die "Unknown table data form, please supply array of scalar, ".
            "array of array-of-scalar, or array of hash-of-scalar";
    }
}

1;
# ABSTRACT: Manipulate table-like data structure via table object

=for Pod::Coverage ^$

=head1 DESCRIPTION

This module provides a common interface to manipulate a few kinds of data
structures that are "table-like": aoaos (array of array-of-scalars), aohos
(array of hash-of-scalars), aos (array of scalars, viewed as a single-column
table), and hash (viewed as two-column table with the columns being "key" and
"value').

The interface (see L<Data::TableData::Object::Base>) allows you to list columns,
add/delete columns, retrieve rows, convert to aoaos or aohos, etc.


=head1 FUNCTIONS

=head2 table

Usage:

 my $obj = table($data[ , $spec ]); # => obj

Shortcut for C<< Data::TableData::Object->new(...) >>.


=head1 METHODS

=head2 new

Usage:

 my $obj = Data::TableData::Object->new($data[ , $spec ]); # => obj

Detect the structure of C<$data> and create the appropriate
C<Data::TableData::Object::FORM> object. Note: if C<$data> is already a table
data object ("isa Data::TableData::Object::Base"), then C<$data> will be
returned as-is instead of creating a new object.


=head1 SEE ALSO

L<Data::TableData::Object::Base> for list of available methods.

L<Data::TableData::Object::aos>

L<Data::TableData::Object::aoaos>

L<Data::TableData::Object::aohos>

L<Data::TableData::Object::hash>

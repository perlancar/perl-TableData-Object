package Data::TableData::Object;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict;
use warnings;

use Data::Check::Structure qw(is_aos is_aoaos is_aohos);

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(table);

sub table { __PACKAGE__->new(@_) }

sub new {
    my ($class, $data, $spec) = @_;
    if (!defined($data)) {
        die "Please specify table data";
    } elsif (ref($data) eq 'HASH') {
        require TableData::Object::hash;
        TableData::Object::hash->new($data);
    } elsif (is_aoaos($data)) {
        require TableData::Object::aoaos;
        TableData::Object::aoaos->new($data, $spec);
    } elsif (is_aohos($data)) {
        require TableData::Object::aohos;
        TableData::Object::aohos->new($data, $spec);
    } elsif (ref($data) eq 'ARRAY') {
        require TableData::Object::aos;
        TableData::Object::aos->new($data);
    } else {
        die "Unknown table data form, please supply array of scalar, ".
            "array of array-of-scalar, or array of hash-of-scalar";
    }
}

1;
# ABSTRACT: Manipulate data structure via table object

=for Pod::Coverage ^$

=head1 FUNCTIONS

=head2 table($data[ , $spec ]) => obj

Shortcut for C<< Data::TableData::Object->new(...) >>.


=head1 METHODS

=head2 new($data[ , $spec ]) => obj

Detect the structure of C<$data> and create the appropriate
C<TableData::Object::FORM> object.


=head1 SEE ALSO

L<Data::TableData::Object::Base> for list of available methods.

L<Data::TableData::Object::aos>

L<Data::TableData::Object::aoaos>

L<Data::TableData::Object::aohos>

L<Data::TableData::Object::hash>

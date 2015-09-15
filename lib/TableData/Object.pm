package TableData::Object;

# DATE
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
        TableData::Object::hash->new($data);
    } elsif (is_aos($data, {max=>10})) {
        TableData::Object::aos->new($data);
    } elsif (is_aoaos($data, {max=>10})) {
        TableData::Object::aoaos->new($data, $spec);
    }elsif (is_aohos($data, {max=>10})) {
        TableData::Object::aohos->new($data, $spec);
    } else {
        die "Unknown table data form, please supply array of scalar, ".
            "array of array of scalar, or array of hash of scalar";
    }
}

1;
# ABSTRACT: Manipulate data structure via table object

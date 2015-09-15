package TableData::Object::Common;

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

1;
# ABSTRACT: Base class for TableData::Object::*

=for Pod::Coverage .+

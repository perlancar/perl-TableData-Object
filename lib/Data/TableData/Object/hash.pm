package Data::TableData::Object::hash;

use 5.010001;
use strict;
use warnings;

use parent 'Data::TableData::Object::Base';

# AUTHORITY
# DATE
# DIST
# VERSION

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

sub rows {
    my $self = shift;
    my $data = $self->{data};
    [sort keys %$data];
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

sub uniq_col_names {
    my $self = shift;

    my @res = ('key'); # by definition, hash key is unique
    my %mem;
    for (values %{$self->{data}}) {
        return @res unless defined;
        return @res if $mem{$_}++;
    }
    push @res, 'value';
    @res;
}

sub const_col_names {
    my $self = shift;

    # by definition, hash key is not constant
    my $i = -1;
    my $val;
    my $val_undef;
    for (values %{$self->{data}}) {
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
    ('value');
}

sub switch_cols {
    die "Cannot switch column in hash table";
}

sub add_col {
    die "Cannot add_col in hash table";
}

sub set_col_val {
    my ($self, $name_or_idx, $value_sub) = @_;

    my $col_name = $self->col_name($name_or_idx);
    my $col_idx  = $self->col_idx($name_or_idx);

    die "Column '$name_or_idx' does not exist" unless defined $col_name;

    my $hash = $self->{data};
    if ($col_name eq 'key') {
        my $row_idx = -1;
        for my $key (sort keys %$hash) {
            $row_idx++;
            my $new_key = $value_sub->(
                table    => $self,
                row_idx  => $row_idx,
                row_name => $key,
                col_name => $col_name,
                col_idx  => $col_idx,
                value    => $hash->{$key},
            );
            $hash->{$new_key} = delete $hash->{$key}
                unless $key eq $new_key;
        }
    } else {
        my $row_idx = -1;
        for my $key (sort keys %$hash) {
            $row_idx++;
            $hash->{$key} = $value_sub->(
                table    => $self,
                row_idx  => $row_idx,
                row_name => $key,
                col_name => $col_name,
                col_idx  => $col_idx,
                value    => $hash->{$key},
            );
        }
    }
}

1;
# ABSTRACT: Manipulate hash via table object

=for Pod::Coverage .+

=head1 SYNOPSIS

To create:

 use Data::TableData::Object qw(table);

 my $td = table({foo=>10, bar=>20, baz=>30});

or:

 use Data::TableData::Object::hash;

 my $td = Data::TableData::Object::hash->new({foo=>10, bar=>20, baz=>30});


=head1 DESCRIPTION

This class lets you manipulate a hash as a table object. The table will have two
columns named C<key> (containing hash keys) and C<value> (containing hash
values).


=head1 METHODS

See L<Data::TableData::Object::Base>.

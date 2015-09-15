package TableData::Object::aoaos;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use parent 'TableData::Object::Common';

sub new {
    my ($class, $data, $spec) = @_;
    my $self = bless {
        data     => $data,
        spec     => $spec,
    }, $class;
    if ($spec) {
        $self->{cols_by_idx}  = [];
        my $ff = $spec->{fields};
        for (keys %$ff) {
            $self->{cols_by_idx}[ $ff->{$_}{pos} ] = $_;
        }
        $self->{cols_by_name} = {
            map { $_ => $ff->{$_}{pos} }
                keys %$ff
        };
    } else {
        if (@$data) {
            my $ncols = @{ $data->[0] };
            $self->{cols_by_idx}  = [ map {"column$_"} 0 .. $ncols-1 ];
            $self->{cols_by_name} = { map {("column$_" => $_)} 0..$ncols-1 };
        } else {
            $self->{cols_by_idx}  = [];
            $self->{cols_by_name} = {};
        }
    }
    $self;
}

sub row_count {
    my $self = shift;
    scalar @{ $self->{data} };
}

sub sort_rows {
    my ($self, @sortcols) = @_;
    return $self unless @sortcols;

    my $data = $self->{data};

    my @aoaos = sort {
        for my $sortcol (@sortcols) {
            my ($reverse, $col) = $sortcol =~ /\A(-?)(.+)/;
            my $idx = $self->col_idx($col);
            die "Unknown sort column '$col'" unless defined($idx);
            my $cmp = ($reverse ? -1:1) * ($a->[$idx] cmp $b->[$idx]);
            return $cmp if $cmp;
        }
        0;
    } @$data;

    __PACKAGE__->new(\@aoaos, $self->{spec});
}

1;
# ABSTRACT: Manipulate array of scalars via table object
__END__

sub rows_as_array { shift->{data} }

sub rows_as_hash {
    my $self = shift;
    my $cols = $self->{columns};
    my @res;
    for my $row (@{ $self->{data} }) {
        my $hos = { map { $cols->[$_] => $row->[$_] } 0..@$cols-1 };
        push @res, $hos;
    }
    \@res;
}

sub column_data {
    my ($self, $name) = @_;
    my $idx = List::MoreUtils::firstidx(sub { $_ eq $name },
                                        @{ $self->{columns} });
    die "Unknown column '$name'" unless $idx >= 0;
    [ map { $_->[$idx] } @{ $self->{data} } ];
}

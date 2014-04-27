#
# This file is part of Dist-Zilla-Stash-Store-Git
#
# This software is Copyright (c) 2014 by Chris Weyl.
#
# This is free software, licensed under:
#
#   The GNU Lesser General Public License, Version 2.1, February 1999
#
package Dist::Zilla::Stash::Store::Git;
BEGIN {
  $Dist::Zilla::Stash::Store::Git::AUTHORITY = 'cpan:RSRCHBOY';
}
# git description: cb62a97
$Dist::Zilla::Stash::Store::Git::VERSION = '0.000001'; # TRIAL

# ABSTRACT: A common place to store and interface with git

use Moose;
use namespace::autoclean;
use MooseX::AttributeShortcuts;

use autobox::Core;
use version;

use Git::Wrapper;
use Version::Next;
use Hash::Merge::Simple 'merge';

with 'Dist::Zilla::Role::Store';

# TODO Additonal plugin roles:
#
# Dist::Zilla::Role::GitStore::ConfigProvider
# Dist::Zilla::Role::GitStore::ConfigConsumer
# Dist::Zilla::Role::GitStore::Consumer

around stash_from_config => sub {
    my ($orig, $class) = (shift, shift);
    my ($name, $args, $section) = @_;

    $args = { _zilla => delete $args->{_zilla}, static_config => $args };
    return $class->$orig($name, $args, $section);
};

sub default_config {
    my $self = shift @_;

    return {
        'version.regexp' => '^v(.+)$',
        'version.first'  => '0.001',
    };
}

has static_config => (
    traits  => [ 'Hash' ],
    is      => 'lazy',
    isa     => 'HashRef',
    builder => sub { { } },
    handles => {
        has_static_config     => 'count',
        has_no_static_config  => 'is_empty', # XXX ?
        has_static_config_for => 'exists',
        # ...
    },
);

has config => (
    traits  => [ 'Hash' ],
    is      => 'lazy',
    isa     => 'HashRef',
    clearer => -1,

    handles => {
        has_config     => 'count',
        has_no_config  => 'is_empty',
        has_config_for => 'exists',
        get_config_for => 'get',
        # ...

        # stopgaps...
        has_version_regexp => [ exists => 'version.regexp' ],
        version_regexp     => [ get    => 'version.regexp' ],
        has_first_version  => [ exists => 'version.first'  ],
        first_version      => [ get    => 'version.first'  ],
    },

    builder => sub {
        my $self = shift @_;

        ### pull in configuration from plugins...

        ### pull in static config...

        ### ...and the default config...

        ### merge it all..
        my $config = merge $self->default_config, $self->static_config; # XXX $self->plugin_config

        return $config;
    },
);

    #'Dist::Zilla::Role::Git::Repo',

# XXX ?
has _repo => (
    is              => 'lazy',
    isa_instance_of => 'Git::Wrapper',
    builder         => sub { Git::Wrapper->new(shift->repo_root) },
);

# FIXME
has repo_root => (is => 'lazy', builder => sub { '.' });

# XXX
#has version_regexp => (is => 'rwp', isa=>'Str', lazy => 1, predicate => 1, builder => sub { '^v(.+)$' });
#has first_version  => (is => 'rwp', isa=>'Str', lazy => 1, predicate => 1, default => sub { '0.001' });

has tags => (
    is      => 'lazy',
    isa     => 'ArrayRef[Str]',
    # For win32, natch
    builder => sub { local $/ = "\n"; [ shift->_repo->tag ] },
);

has previous_versions => (

    traits  => ['Array'],
    is      => 'lazy',
    isa     => 'ArrayRef[Str]',

    handles => {

        has_previous_versions => 'count',
        #previous_versions     => 'elements',
        earliest_version      => [ get =>  0 ],
        last_version          => [ get => -1 ],
    },

    builder => sub {
        my $self = shift @_;

        my $regexp = $self->version_regexp;
        my @tags = map { /$regexp/ ? $1 : () } $self->tags->flatten;

        # find tagged versions; sort least to greatest
        my @versions =
            sort { version->parse($a) <=> version->parse($b) }
            grep { eval { version->parse($_) }  }
            @tags;

        return [ @versions ];
    },
);

# -- role implementation

# XXX should this be here as default logic?  or should we require that a
# plugin supply this information to us?

sub _XXX_default_next_version {
    my $self = shift @_;

    # override (or maybe needed to initialize)
    return $ENV{V}
        if defined $ENV{V};

    return $self->first_version
        unless $self->has_previous_versions;

    my $last_ver = $self->last_version;
    my $new_ver  = Version::Next::next_version($last_ver);
    $self->log("Bumping version from $last_ver to $new_ver");

    return "$new_ver";
}


__PACKAGE__->meta->make_immutable;
!!42;

__END__

=pod

=encoding UTF-8

=for :stopwords Chris Weyl

=head1 NAME

Dist::Zilla::Stash::Store::Git - A common place to store and interface with git

=head1 VERSION

This document describes version 0.000001 of Dist::Zilla::Stash::Store::Git - released April 27, 2014 as part of Dist-Zilla-Stash-Store-Git.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SOURCE

The development version is on github at L<http://https://github.com/RsrchBoy/dist-zilla-stash-store-git>
and may be cloned from L<git://https://github.com/RsrchBoy/dist-zilla-stash-store-git.git>

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/RsrchBoy/dist-zilla-stash-store-git/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Chris Weyl <cweyl@alumni.drew.edu>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by Chris Weyl.

This is free software, licensed under:

  The GNU Lesser General Public License, Version 2.1, February 1999

=cut

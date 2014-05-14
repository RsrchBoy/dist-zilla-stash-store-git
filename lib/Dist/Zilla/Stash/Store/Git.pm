package Dist::Zilla::Stash::Store::Git;

# ABSTRACT: A common place to store and interface with git

use Moose;
use namespace::autoclean;
use MooseX::AttributeShortcuts;
use MooseX::RelatedClasses;

use autobox::Core;
use version;

use Git::Wrapper;
use Version::Next;
use Hash::Merge::Simple 'merge';

with 'Dist::Zilla::Role::Store';

=method stash_from_config()

This method wraps L<Dist::Zilla::Role::Stash/stash_from_config> to capture our
L<Dist::Zilla> instance and funnel all our stash configuration options into
the L</store_config> attribute.

=cut

around stash_from_config => sub {
    my ($orig, $class) = (shift, shift);
    my ($name, $args, $section) = @_;

    $args = { _zilla => delete $args->{_zilla}, store_config => $args };
    return $class->$orig($name, $args, $section);
};

=method default_config

This method provides a HashRef of all the default settings we know about.  At the moment,
this is:

    version.regexp => '^v(.+)$'
    version.first  => '0.001'

You should never need to mess with this -- note that L</store_config> (values
passed to the store via configuration) and L</dynamic_config> (values returned
by the plugins performing the
L<Dist::Zilla::Role::GitStore::ConfigProvider|GitStore::ConfigProvider role>),
respectively, override this.

=cut

sub default_config {
    my $self = shift @_;

    return {
        'version.regexp' => '^v(.+)$',
        'version.first'  => '0.001',
        'version.next'   => $self->_default_next_version,
    };
}

=attr dynamic_config

This attribute contains all the configuration information provided to the
store by the plugins performing the
L<Dist::Zilla::Role::GitStore::ConfigProvider|GitStore::ConfigProvider role>.
Any values specified herein override those in the L</default_config>, and
anything set by the store configuration (aka L</store_config>) similarly
overrides anything here.

=method dynamic_config

This is a read-only accessor to the L</dynamic_config> attribute.

=method has_dynamic_config

True if we have been provided any configuration by plugins.

This is a read-only accessor to the L</dynamic_config> attribute.

=method has_dynamic_config_for

True if plugin configuration has been provided for a given key, e.g.

    do { ... } if $store->has_dynamic_config_for('version.first');

This is a read-only accessor to the L</dynamic_config> attribute.

=cut

has dynamic_config => (
    traits  => [ 'Hash' ],
    is      => 'lazy',
    isa     => 'HashRef',
    builder => sub { { } },
    handles => {
        has_dynamic_config     => 'count',
        has_no_dynamic_config  => 'is_empty', # XXX ?
        has_dynamic_config_for => 'exists',
        # ...
    },
);

=attr store_config

This attribute contains all the information passed to the store via the
store's configuration, e.g. in the distribution's C<dist.ini>.  Any values
specified herein override those in the L</default_config>, and anything
returned by a plugin (aka L</dynamic_config>) similarly overrides anything
here.

This is a read-only accessor to the L</store_config> attribute.

=method store_config

A read-only accessor to the store_config attribute.

This is a read-only accessor to the L</store_config> attribute.

=method has_store_config

True if we have been provided any static configuration.

This is a read-only accessor to the L</store_config> attribute.

=method has_store_config_for

True if static configuration has been provided for a given key, e.g.

    do { ... } if $store->has_store_config_for('version.first');

This is a read-only accessor to the L</store_config> attribute.

=cut

has store_config => (
    traits  => [ 'Hash' ],
    is      => 'lazy',
    isa     => 'HashRef',
    builder => sub { { } },
    handles => {
        has_store_config     => 'count',
        has_no_store_config  => 'is_empty', # XXX ?
        has_store_config_for => 'exists',
        # ...
    },
);

=attr config

This attribute contains a HashRef of all the known configuration values, from
all sources (default, stash and plugins aka dynamic).  It merges the
L</dynamic_config> into L</store_config>, and that result into
L</default_config>, each time giving the hash being merged precedence.

If you're looking for "The Right Place to Find Configuration Values", this is
it. :)

=method config()

A read-only accessor returning the config HashRef.

This is a read-only accessor to the L</config> attribute.

=method has_config

True if we have any configuration stored; false if not.

This is a read-only accessor to the L</config> attribute.

=method has_no_config

The inverse of L</has_config>.

This is a read-only accessor to the L</config> attribute.

=method has_config_for($key)

Returns true if we have configuration information for a given key.

This is a read-only accessor to the L</config> attribute.

=method get_config_for($key)

Returns the value we have for a given key; returns C<undef> if we have no
configuration information for that key.

This is a read-only accessor to the L</config> attribute.

=cut

has config => (
    traits  => [ 'Hash' ],
    is      => 'lazy',
    isa     => 'HashRef',
    clearer => -1, # private

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

        ### merge all our different config sources..
        my $config = merge
            $self->default_config,
            $self->dynamic_config,
            $self->store_config,
            ;

        return $config;
    },
);

=attr repo_wrapper

Contains a lazily-constructed L<Git::Wrapper> instance for our repository.

=method repo_wrapper()

This is a read-only accessor to the L</repo_wrapper> attribute.

=cut

related_class 'Git::Wrapper';

has repo_wrapper => (
    is              => 'lazy',
    isa_instance_of => 'Git::Wrapper',
    builder         => sub { $_[0]->git__wrapper_class->new($_[0]->repo_root) },
);

=attr repo_raw

Contains a lazily-constructed L<Git::Raw::Repository> instance for our
repository.

=method repo_raw()

This is a read-only accessor to the L</repo_raw> attribute.

=cut

related_class 'Git::Raw::Repository';

has repo_raw => (
    is              => 'lazy',
    isa_instance_of => 'Git::Raw::Repository',
    builder         => sub { $_[0]->git__raw__repository_class->open($_[0]->repo_root) },
);

=attr repo_root

Stores the repository root; by default this is the current directory.

=method repo_root

Returns the path to the repository root; this may be a relative path.

This is a read-only accessor to the L</repo_root> attribute.

=cut

has repo_root => (is => 'lazy', builder => sub { '.' });

=attr tags

An ArrayRef of all existing tags in the repository.

=method tags()

A read-only accessor to the L</tags> attribute.

=cut

has tags => (
    is      => 'lazy',
    isa     => 'ArrayRef[Str]',
    # For win32, natch
    builder => sub { local $/ = "\n"; [ shift->repo_wrapper->tag ] },
);

=attr previous_versions

A sorted ArrayRef of all previous versions of this distribution, as derived
from the repository tags filtered through the regular expression given in the
C<version.regexp>.

=method previous_versions()

A read-only accessor to the L</previous_versions> attribute.

=method has_previous_versions

True if this distribution has any previous versions; that is, if any git tags
match the version regular expression.

This is a read-only accessor to the L</previous_versions> attribute.

=method earliest_version

Returns the earliest version known; C<undef> if no such version exists.

This is a read-only accessor to the L</previous_versions> attribute.

=method latest_version

Returns the latest version known; C<undef> if no such version exists.

This is a read-only accessor to the L</previous_versions> attribute.

=cut

has previous_versions => (

    traits  => ['Array'],
    is      => 'lazy',
    isa     => 'ArrayRef[Str]',

    handles => {

        has_previous_versions => 'count',
        earliest_version      => [ get =>  0 ],
        latest_version        => [ get => -1 ],
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

sub _default_next_version {
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

=for :stopwords versioning

=head1 SYNOPSIS

=head1 DESCRIPTION

This is a L<Dist::Zilla Store|Dist::Zilla::Role::Store> providing a common place to
store, fetch and share configuration information as to your distribution's git repository,
as well as your own preferences (e.g. git tag versioning scheme).

=head1 ATCHUNG!

B<This is VERY EARLY CODE UNDER ACTIVE DEVELOPMENT!  It's being used by L<this
author's plugin bundle|Dist::Zilla::PluginBundle::RSRCHBOY>, and as such is
being released as a non-TRIAL / non-development (e.g. x.xxx_01) release to
make that easier.  The interface is likely to change.  Stability (as it is)
should be expected when this section is removed and the version >= 0.001 (aka
0.001000).

Contributions, issues and the like are welcome and encouraged.

=head1 SEE ALSO

Dist::Zilla::Role::Store
Dist::Zilla::Role::Stash

=cut

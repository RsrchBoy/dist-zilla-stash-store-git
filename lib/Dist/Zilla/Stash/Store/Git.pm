package Dist::Zilla::Stash::Store::Git;

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

=method default_config

This method provides a HashRef of all the default settings we know about.  At the moment,
this is:

    version.regexp => '^v(.+)$'
    version.first  => '0.001'

You should never need to mess with this -- note that L</static_config> (values
passed to the store via configuration) and L</plugin_config> (values returned
by the plugins performing the
L<Dist::Zilla::Role::GitStore::ConfigProvider|GitStore::ConfigProvider role>),
respectively, override this.

=cut

sub default_config {
    my $self = shift @_;

    return {
        'version.regexp' => '^v(.+)$',
        'version.first'  => '0.001',
    };
}

=attr plugin_config

This attribute contains all the configuration information provided to the
store by the plugins performing the
L<Dist::Zilla::Role::GitStore::ConfigProvider|GitStore::ConfigProvider role>.
Any values specified herein override those in the L</default_config>, and
anything set by the store configuration (aka L</store_config>) similarly
overrides anything here.

=method plugin_config

A read-only accessor to the plugin_config attribute.

=method has_plugin_config

True if we have been provided any plugin configuration.

=method has_plugin_config_for

True if plugin configuration has been provided for a given key, e.g.

    do { ... } if $store->has_plugin_config_for('version.first');

=cut

has plugin_config => (
    traits  => [ 'Hash' ],
    is      => 'lazy',
    isa     => 'HashRef',
    builder => sub { { } },
    handles => {
        has_plugin_config     => 'count',
        has_no_plugin_config  => 'is_empty', # XXX ?
        has_plugin_config_for => 'exists',
        # ...
    },
);

=attr static_config

This attribute contains all the information passed to the store via the
store's configuration, e.g. in the distribution's C<dist.ini>.  Any values
specified herein override those in the L</default_config>, and anything
returned by a plugin (aka L</plugin_config>) similarly overrides anything
here.

=method static_config

A read-only accessor to the static_config attribute.

=method has_static_config

True if we have been provided any static configuration.

=method has_static_config_for

True if static configuration has been provided for a given key, e.g.

    do { ... } if $store->has_static_config_for('version.first');

=cut

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

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SEE ALSO

=cut

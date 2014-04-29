package Dist::Zilla::Role::GitStore::Consumer;

# ABSTRACT: Something that makes use of %Store::Git

use Moose::Role;
use namespace::autoclean;
use MooseX::AttributeShortcuts;

# TODO not quite yet...
#with 'Dist::Zilla::Role::RegisterStash';

has _git_store => (
    is              => 'lazy',
    isa_instance_of => 'Dist::Zilla::Stash::Store::Git',
    builder         => sub { shift->zilla->stash_named('%Store::Git') },
);

!!42;
__END__

=head1 SYNOPSIS

    with 'Dist::Zilla::Role::GitStore::Consumer';

    # ...and elsewhere...
    $self->_git_store->...

=head1 DESCRIPTION

This role should be consumed by something (typically a plugin) that uses the
L<%Store::Git stash|Dist::Zilla::Stash::Store::Git>.

Note that this role does not indicate that B<configuration information> is
being consumed; simply that the consumer uses the store in some way (e.g.
looking up all tags, querying the repository log, etc).

=head1 SEE ALSO

=cut

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

=head1 DESCRIPTION

=head1 SEE ALSO

=cut

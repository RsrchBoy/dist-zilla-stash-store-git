package Dist::Zilla::Role::GitStore::ConfigConsumer;

# ABSTRACT: Something that uses config info from %Store::Git

use Moose::Role;
use namespace::autoclean;
use MooseX::AttributeShortcuts;

with 'Dist::Zilla::Role::GitStore::Consumer';

=required_method gitstore_config_required

Should return an array of the keys we expect the L<%Store::Git
stash|Dist::Zilla::Stash::Store::Git> to be able to provide us with values
for.

=cut

requires 'gitstore_config_required';

!!42;
__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

This role should be consumed by something (typically a plugin) that consumes configuration
information provided by L<%Store::Git|Dist::Zilla::Stash::Store::Git>.

=head1 SEE ALSO

=cut

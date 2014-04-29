package Dist::Zilla::Role::GitStore::ConfigProvider;

# ABSTRACT: Something that provides config info to %Store::Git

use Moose::Role;
use namespace::autoclean;
use MooseX::AttributeShortcuts;

=required_method gitstore_config_provided

This required method must return a HashRef of key, value configuration pairs.

=cut

requires 'gitstore_config_provided';

!!42;
__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

This role should be consumed by anything (typically a plugin) that B<provides>
information to the L<%Store::Git stash|Dist::Zilla::Stash::Store::Git>.

Note that this role does not indicate that the store is being used in any way,
simply that the plugin makes available some configuration information that the
stash itself may consume when populating L<Dist::Zilla::Stash::Store::Git/dynamic_config>.

=head1 SEE ALSO

=cut

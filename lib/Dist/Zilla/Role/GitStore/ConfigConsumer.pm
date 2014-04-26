package Dist::Zilla::Role::GitStore::ConfigConsumer;

# ABSTRACT: Something that uses config info from %Store::Git

use Moose::Role;
use namespace::autoclean;
use MooseX::AttributeShortcuts;

with 'Dist::Zilla::Role::GitStore::Consumer';

requires 'gitstore_config_required';

!!42;
__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SEE ALSO

=cut

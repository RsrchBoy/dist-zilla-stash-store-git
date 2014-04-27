#
# This file is part of Dist-Zilla-Stash-Store-Git
#
# This software is Copyright (c) 2014 by Chris Weyl.
#
# This is free software, licensed under:
#
#   The GNU Lesser General Public License, Version 2.1, February 1999
#
package Dist::Zilla::Role::GitStore::ConfigProvider;
BEGIN {
  $Dist::Zilla::Role::GitStore::ConfigProvider::AUTHORITY = 'cpan:RSRCHBOY';
}
$Dist::Zilla::Role::GitStore::ConfigProvider::VERSION = '0.000001'; # TRIAL
# ABSTRACT: Something that provides config info to %Store::Git

use Moose::Role;
use namespace::autoclean;
use MooseX::AttributeShortcuts;

requires 'gitstore_config_provided';

!!42;

__END__

=pod

=encoding UTF-8

=for :stopwords Chris Weyl

=head1 NAME

Dist::Zilla::Role::GitStore::ConfigProvider - Something that provides config info to %Store::Git

=head1 VERSION

This document describes version 0.000001 of Dist::Zilla::Role::GitStore::ConfigProvider - released April 27, 2014 as part of Dist-Zilla-Stash-Store-Git.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SEE ALSO

Please see those modules/websites for more information related to this module.

=over 4

=item *

L<Dist::Zilla::Stash::Store::Git|Dist::Zilla::Stash::Store::Git>

=back

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

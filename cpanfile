requires "Dist::Zilla::Role::RegisterStash" => "0";
requires "Dist::Zilla::Role::Store" => "0";
requires "Git::Wrapper" => "0";
requires "Hash::Merge::Simple" => "0";
requires "Moose" => "0";
requires "Moose::Role" => "0";
requires "MooseX::AttributeShortcuts" => "0";
requires "Version::Next" => "0";
requires "aliased" => "0";
requires "autobox::Core" => "0";
requires "namespace::autoclean" => "0";
requires "perl" => "5.006";
requires "version" => "0";

on 'test' => sub {
  requires "File::Spec" => "0";
  requires "IO::Handle" => "0";
  requires "IPC::Open3" => "0";
  requires "Test::CheckDeps" => "0.010";
  requires "Test::More" => "0.94";
  requires "perl" => "5.006";
  requires "strict" => "0";
  requires "warnings" => "0";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "6.30";
};

on 'develop' => sub {
  requires "Test::More" => "0";
  requires "Test::NoTabs" => "0";
  requires "Test::Pod" => "1.41";
  requires "version" => "0.9901";
};

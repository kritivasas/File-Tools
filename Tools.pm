# This module was written in 1996 by Aaron Sherman and contributed to
# the public domain. Please leave the documentation intact as a
# curtesy to the author.

package File::Tools;

require Exporter;
use File::Recurse;
use File::Copy qw(copy copydir cp);

@ISA=qw(Exporter);
@EXPORT=qw(recurse copy copydir);
@EXPORT_OK=qw(recurse copy copydir cp);

$File::Tools::VERSION = '2.0';
sub VERSION {
    return $File::Tools::VERSION;
}


1;

__END__

=head1 NAME

File::Tools - This module is a wrapper for the various File moudles.

=head1 SYNOPSIS

  use File::Tools;
  copy("x", *STDOUT);
  recurse { print } "/etc";

=head1 DESCRIPTION

Provides the routines that are defined in File::Recurse and File::Copy.

Other modules will be added at a later date, but File::Tools will
always encapsulate them.

=head1 SEE ALSO

L<File::Copy> and L<File::Recurse>

=head1 AUTHOR

Written in 1996 by Aaron Sherman

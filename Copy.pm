# File/Copy.pm. Written in 1994 by Aaron Sherman <ajs@ajs.com>. This
# source code has been placed in the public domain by the author.
# Please be kind and preserve the documentation.
#

package File::Copy;

require Exporter;
use Carp;
use File::Recurse;

@ISA=qw(Exporter);
@EXPORT=qw(copy copydir);
@EXPORT_OK=qw(copy copydir cp);

$File::Copy::VERSION = '2.0';
$File::Copy::Too_Big = 1024 * 1024 * 2;

sub VERSION {
    # Version of File::Copy
    return $File::Copy::VERSION;
}

sub copy {
    croak("Usage: copy( file1, file2 [, buffersize]) ")
      unless(@_ == 2 || @_ == 3);

    my $from = shift;
    my $to = shift;
    my $closefrom=0;
    my $closeto=0;
    my ($size, $status, $r, $buf);
    local(*FROM, *TO);

    if (ref(\$from) eq 'GLOB') {
	*FROM = $from;
    } elsif (defined ref $from and
	     (ref($from) eq 'GLOB' || ref($from) eq 'FileHandle')) {
	*FROM = *$from;
    } else {
	$from =~ s/\/+$//; $from = '/' if length($from) == 0;
	return copydir($from,$to) if -d $from;
	open(FROM,"<$from")||goto(fail_open1);
	$closefrom = 1;
    }

    if (ref(\$to) eq 'GLOB') {
	*TO = $to;
    } elsif (defined ref $to and
	     (ref($to) eq 'GLOB' || ref($to) eq 'FileHandle')) {
	*TO = *$to;
    } else {
	$to =~ s/\/+$//; $to = '/' if length($to) == 0;
	if (-d $to) {
	    if (!ref $from && ref \$from ne 'GLOB') {
		my $basename = $from;
		$basename =~ s/^.*\///;
		$to = "$to/$basename";
		# XXX - what happens if THIS is a directory?
		#       open *should* trap that, but this may not be reliable
	    } else {
		croak("Cannot copy filehandles into directories");
	    }
	}
	open(TO,">$to")||goto(fail_open2);
	$closeto=1;
    }

    if (@_) {
	$size = shift(@_) + 0;
	croak("Bad buffer size for copy: $size\n") unless ($size > 0);
    } else {
	$size = -s FROM;
	$size = 1024 if ($size < 512);
	$size = $File::Copy::Too_Big if ($size > $File::Copy::Too_Big);
    }

    $buf = '';
    while(defined($r = read(FROM,$buf,$size)) && $r > 0) {
	if (syswrite (TO,$buf,$r) != $r) {
	    goto fail_inner;    
	}
    }
    goto fail_inner unless(defined($r));
    close(TO) || goto fail_open2 if $closeto;
    close(FROM) || goto fail_open1 if $closefrom;
    return 1;
    
    # All of these contortions try to preserve error messages...
  fail_inner:
    if ($closeto) {
	$status = $!;
	$! = 0;
	close TO;
	$! = $status unless $!;
    }
  fail_open2:
    if ($closefrom) {
	$status = $!;
	$! = 0;
	close FROM;
	$! = $status unless $!;
    }
  fail_open1:
    return 0;
}
*cp = \&copy;

$File::Copy::basedir = '';
$File::Copy::todir = '';

sub copydir ($$) {
    my $dir = shift;
    my $to = shift;
    if (ref $to || ref \$to eq 'GLOB') {
	croak("Cannot copy directories to filehandles");
    }
    croak("$dir is not a directory") if (!-d $dir);
    if (-d $to) {
	my $basename = $dir;
	$basename =~ s/^.*\///;
	$to = "$to/$basename";
    } elsif (-f _) {
	croak("Cannot copy directory to file: $to");
    }
    -d($to)||mkdir($to,0777)||croak("Cannot create directory: $to");
    return !recurse(\&docopy,$dir,[$dir,$to]);
}

sub docopy {
    my $file = shift;
    my $context = shift;
    my $basedir = $context->[0];
    my $todir = $context->[1];
    my $to = $file;
    $to=~s/^$basedir\/*//;
    $to = "$todir/$to";
    if (-f $file) {
	if (!copy($file,$to)) {
	    carp("$to: $!");
        }
    } elsif (-d $file) {
	-d($to)||mkdir($to,0777)||(carp("$to: $!"),return(-1));
    } else {
	carp("$to: Cannot create special files... yet");
    }
    return 0;
}

1;

__END__

=head1 NAME

File::Copy - Copy files or filehandles

=head1 USAGE

  	use File::Copy;

	copy("file1","file2");
  	copy("Copy.pm",\*STDOUT);'

  	use POSIX;
	use File::Copy cp;

	$n=FileHandle->new("/dev/null","r");
	cp($n,"x");'

=head1 DESCRIPTION

The Copy module provides two functions (copy and copydir)

=head2 copy

The copy function takes two
parameters: a file to copy from and a file to copy to. Either
argument may be a string, a FileHandle reference or a FileHandle
glob. Obviously, if the first argument is a filehandle of some
sort, it will be read from, and if it is a file I<name> it will
be opened for reading. Likewise, the second argument will be
written to (and created if need be). If the first argument is
the name of a directory, this function simply calls copydir.

An optional third parameter can be used to specify the buffer
size used for copying. This is the number of bytes from the
first file, that wil be held in memory at any given time, before
being written to the second file. The default buffer size depends
upon the file, but will generally be the whole file (up to 2Mb), or
1k for filehandles that do not reference files (eg. sockets).

You may use the syntax C<use File::Copy "cp"> to get at the
"cp" alias for this function. The syntax is I<exactly> the same.

Return value:

Returns 1 on success, 0 on failure. $! will be set if an error was
encountered.

=head2 copydir

copydir takes two directory names. If the second directory does
not exist, it will be created. If it does exist, a directory will
be created in it to copy to. Copydir copies every file and directory
from the source directory (first parameter) to the destination
directory (second parameter). The structure of the source directory
will be preserved, and warnings will be issued if a particular file
or directory cannot be accessed or created.

Return value:

copydir returns true on success and false on failure, though failure
to copy a single file or directory from the source tree may still
result in "success". The return value simply indicates whether or not
I<anything> was done.

=head1 SEE ALSO

L<File::Tools>

=head1 AUTHOR

File::Copy was written by Aaron Sherman <ajs@ajs.com> in 1995.

=cut

use ExtUtils::MakeMaker;
WriteMakefile(NAME => 'File::Tools',
	      SKIP => [qw(xs_c xs_o c_o dynamic static)],
	      VERSION => '2.0');

sub MY::postamble {
	"\n\# Avoid make problems:\nstatic::\n\ndynamic::\n\n";
}

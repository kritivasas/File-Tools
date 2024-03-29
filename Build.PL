use strict;
use warnings;
use Module::Build;

use 5.006;

my $builder = Module::Build->new(
    module_name         => 'File::Tools',
    license             => 'perl',
dist_abstract => "UNIX tools implemented as Perl Modules and made available to other platforms as well",
    create_makefile_pl  => 'traditional',
    create_readme       => 1,
    requires            => {
        'File::Basename'            => '0',
        'File::Copy'                => '0',
        'Cwd'                       => '0',
        'POSIX'                     => '0',
        'File::Find'                => '0',
        'File::Path'                => '0',
        'File::Temp'                => '0',
        'perl'                      => '5.006',
    },
    build_requires      => {
        'Test::More'                => '0.47',
        'Test::NoWarnings'          => '0',
    },
);

$builder->create_build_script();

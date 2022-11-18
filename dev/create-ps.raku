#!/usr/bin/env raku

use Proc::Easier;

if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <config file> [options...]

    Uses data in the formatted config file to assemble the components
    of a PostScript page (of the selected paper size) which is then
    converted into PDF.

    HERE
    exit;
}

#### subroutines ####
sub read-template {
}

sub write-resources() {
    # 
}

sub ps2pdf($ps) {
    my $cmd = "ps2pdf $ps";
    cmd $pdf;
}




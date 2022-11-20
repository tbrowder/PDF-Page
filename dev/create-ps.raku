#!/usr/bin/env raku

use Proc::Easier;
use Text::Utils :ALL;

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
sub create-template(:$ifil!, :$ofil, :$debug) {
    # a one-time pass to create a usable template from the poster
    # amalgamated PS doc
    my $fh = open $ofil, :w;
    for $ifil.IO.lines -> $line is copy {
        # skip show lines
    }
}

sub read-template($fnam, :$debug) {
}

sub write-resources() {
    # 
}

sub ps2pdf($ps) is export {
    my $cmd = "ps2pdf $ps";
    my $res = cmd $cmd;
}




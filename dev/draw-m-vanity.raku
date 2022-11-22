#!/usr/bin/env raku

use Font::AFM;
use Proc::Easier;
use Text::Utils :ALL;
use JSON::Fast;

my $tmpl  = "tmpls/house-numbers.ps.tmpl";
my @lines = $tmpl.IO.lines;
my @part1;
my @part2;
my $p1 = True;
for @lines -> $line {
    # check split marker
    if $p1 and $line.contains("SPLIT") {
        $p1 = False;
        next;
    }
    if $p1 {
        # lines go into part 1
        @part1.push: $line;
    }
    else {
        # lines go into part 2
        @part2.push: $line;
    }
}

my %fonts;
=begin comment
my @fonts = <
    Helvetica Helvetica-Bold Helvetica-Oblique Helvetica-BoldOblique
    Times-Roman Times-Bold Times-Italic
    Times-BoldItalic
>;
=end comment
my @fonts = <
    Times-Roman
>;

my $debug = 0;
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go

    Draws elevation view of Missy's vanity from inside looking
    at the outside wall.

    HERE
    exit;
}

for @fonts -> $font-name {
    say "Font $font-name" if $debug;
    my $afm = Font::AFM.new: :name($font-name);
    %fonts{$font-name} = $afm;
}

# one set of files for each font
my %ps-fils;
for %fonts.keys.sort -> $font-name {

    my $afm = %fonts{$font-name};
    say "Font: {$afm.FontName}";
    my %bbox = $afm.BBox;
    my @font-bbox = $afm.FontBBox;

    my $odir = "ps-out";
    my $stem = "Missys-vanity";
    my $psfil = "$odir/$stem.ps";
    %ps-fils{$stem} = $psfil;

    # create the output file
    my $fh = open $psfil, :w;

    # write part 1
    $fh.say($_) for @part1;

    # write the specific info for the file
    #   the title info under the bottom line
    $fh.say: "/Times-Roman 14 selectfont -5 i2p -4 i2p 18 add moveto";
    #$fh.say: "(Font: $font-name; number height: $in in.) 2 puttext";

    #   the 114 in the selected font and size
    my $string = "114";

    $fh.say: "0 0 moveto ($string) 0 puttext";

    # write part 2
    $fh.say($_) for @part2;

    # close the file
    $fh.close;
}

# convert ps to pdf
my $pdfdir = "pdf-out";
for %ps-fils.kv -> $stem, $psfil {
    my $pdf = "$pdfdir/$stem.pdf";
    my $args = "ps2pdf $psfil $pdf";
    cmd $args;
    say "See pdf file '$pdf'";
}

#=finish

#### subroutines ####
sub create-template(:$ifil!, :$ofil, :$debug) {
    # a one-time pass to create a usable template from the poster
    # amalgamated PS doc
    my $fh = open $ofil, :w;
    for $ifil.IO.lines -> $line is copy {
        # skip show lines
    }
}

sub show-kerned-string(
    $fh,             # a handle to an opened PostScript file
    Num $x, Num $y,  # current point
    Font::AFM :$afm!, 
    :$string!,
    :$size!,
    :$debug,
    ) is export {

    # kerning
    my ($kerned, $width) = $afm.kern($string, $size);
    while $kerned.elems {
        my $e = $kerned.shift;
        if $e ~~Str {
            # if it's a Str, show it
            $fh.print: " ($e) show";
        }
        else {
            # otherwise, convert to a Num and rmoveto
            $e .= Num;
            $fh.print: " 0 $e rmoveto";
        }
    }
    # end the line
    $fh.say();
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

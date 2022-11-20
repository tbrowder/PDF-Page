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
    Times-BoldItalic
>;

my $debug = 0;
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go

    Prints '114' on a single page in various fonts and heights
    for assessing house numbers to buy for 114 Shoreline Drive

    HERE
    exit;
}

my @inches = 3.5, 4, 4.5, 5, 5.5, 6;

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

    # one set for each number height
    my $odir = "ps-out";
    for @inches -> $in {
        #my $title = "ps-out/Numbers-{$font-name}-{$in}-inch.ps";
        my $stem = "Numbers-{$font-name}-{$in}-inch";
        my $psfil = "$odir/$stem.ps";
        %ps-fils{$stem} = $psfil;

        # individual character bounding boxes
        my ($llx-one, $lly-one, $urx-one, $ury-one) = %bbox<one>;
        my ($llx-four, $lly-four, $urx-four, $ury-four) = %bbox<four>;
        # heights:
        my $sCh1 = $ury-one  - $lly-one;
        my $sCh4 = $ury-four - $lly-four;
        # average
        my $sCh = 0.5 * ($sCh1 + $sCh4);

        # scale so height is in inches
        # the font bbox is 1000 x 1000

        =begin comment
           let sCh = scaled char height in 1000x1000 box which represents the font size scaled to 1000
               sFh = 1000 scaled font height
           let Ch  = char height in the instantiated font
           let Fh  = font size that defines the instantiated font
           then
               Ch = sCh/1000 * fh
           to define a desired Ch in a given instantiated font
               Fh = Ch * 1000/sCh
        =end comment

        my $Ch = $in * 72; # must convert to PS points
        my $Fh = $Ch * 1000.0 / $sCh;

        # create the output file
        my $fh = open $psfil, :w;

        # write part 1
        $fh.say($_) for @part1;

        # write the specific info for the file
        #   the title info under the bottom line
        $fh.say: "/Times-Roman 14 selectfont -5 i2p -4 i2p 18 add moveto";
        $fh.say: "(Font: $font-name; number height: $in in.) 2 puttext";

        #   the 114 in the selected font and size
        my $string = "114";
        #my $string = "AV1C";
        #my %glyphs = from-json "font-data/glyphs.json".IO.slurp;


        $fh.say: "/$font-name $Fh selectfont";
        if 1 {
            # no kerning
            $fh.say: "0 0 moveto ($string) 0 puttext";
        }
        else {
            # kerning
            my ($kerned, $width) = $afm.kern($string, $Fh);
            my $hwidth = 0.5 * $width;
            $fh.say: "-$hwidth 0 moveto";
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
            $fh.say();
        }

        # write part 2
        $fh.say($_) for @part2;

        # close the file
        $fh.close;
    }
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

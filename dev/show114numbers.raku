#!/usr/bin/env raku

use Font::AFM;
use Proc::Easier;
use Text::Utils :ALL;

my $tmpl  = "house-numbers.ps.tmpl";
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
my @fonts = <Helvetica Helvetica-Bold Helvetica-Oblique Helvetica-BoldOblique 
            Times-Roman Times-Bold Times-Italic Times-BoldItalic>;

my $debug = 0;
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go

    Prints '114' on a single page in various fonts and heights
    for assessing numbers to buy for 114 Shoreline Drive

    HERE
    exit;
}

my @inches = 3, 3.5, 4, 4.5, 5, 5.5, 6;

for @fonts -> $font-name {
    say "Font $font-name" if $debug;
    my $afm = Font::AFM.new: :name($font-name);
    %fonts{$font-name} = $afm;
}

# one set of files for each font
for %fonts.keys.sort -> $font-name {
    my $title = "Numbers-{$font-name}";

    my $afm = %fonts{$font-name};
    say "Font: {$afm.FontName}";
    my %bbox = $afm.BBox;

    # one set for each height
    for @inches -> $in {
        $title ~= "-{$in}-inch.ps";

        # individual character bounding boxes
        my ($llx-one, $lly-one, $urx-one, $ury-one) = %bbox<one>;
        my ($llx-four, $lly-four, $urx-four, $ury-four) = %bbox<four>;
        # heights:
        my $h1 = $ury-one  - $lly-one;
        my $h4 = $ury-four - $lly-four;
        # average
        my $h = 0.5 * ($h1 + $h4);

        # scale so height is in inches
        # the font bbox is 1000 x 1000

        =begin comment
           let x = char height in 1000x1000 box which represents the font size scaled to 1000
           let f = font size, then f x sf = 1000
           so sf = 1000 / f
        =end comment

        my $xhp = $h/1000.0 * 12;
        # to scale it up
        # X/ 

        my $height =  ($in * 72)/1000.0;

        # create the output file
        my $fh = open $title, :w;

        # write part 1
        $fh.say($_) for @part1;

        # write the specific info for the file
        #   the title info over the top line
        $fh.say: "/Times-Roman 14 selectfont 0 18 moveto (Font: $font-name; height: $in in.) 0 puttext";

        #   the 114 in the selected font and size
        $fh.say: "/$font-name $height selectfont";
        $fh.say: "0 0 moveto (114) 0 puttext";

        # write part 2
        $fh.say($_) for @part2;

        # close the file
        $fh.close;
    }

}

=finish

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
    my $res = cmd $pdf;
}

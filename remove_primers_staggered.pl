#! /usr/bin/perl -w
#
#	Use this program to make tab files for FileMaker
#

	die "Usage: fasta prefix\n" unless (@ARGV);
	
	chomp (@ARGV);
	($file, $prefix) = (@ARGV);
die "Please follow command line options\n" unless ($prefix);
chomp ($prefix);

$/ = ">";
open (IN, "<$file") or die "Can't open $file\n";
open (FA, ">${prefix}.fa") or die "Can't open ${prefix}.fa\n";
open (FAIL, ">${prefix}.fail") or die "Can't open ${prefix}.fail\n";
while ($line1 = <IN>){	
    chomp ($line1);
    next unless ($line1);
    $sequence = ();
    (@pieces) = split ("\n", $line1);
    ($info) = shift (@pieces);
    ($sequence) = join ("", @pieces);
    $sequence =~tr/\n//d;
    ($begin, $fprimer, $seq, $rprimer, $end)=$sequence=~/^(.*)(GTGCCAGC.GCCGCG....)(.+)(....GA.ACCC..GTAGTCC)(.*)$/;
    if ($seq){
	print FA ">$info\n$seq\n";
    } else {
	print FAIL ">$info\n$sequence\n";
    }
}

close (IN);

	

#! /usr/bin/perl -w
#
#

	die "Use this program to take the qiime split_libraries_fastq.py fasta and make a matrix
-trans and cutoff are required, comboreps file is optional

-trans is generated from fasta2unique_table4.pl
-cutoff is the number of times a sequence must be present in the dataset to be kept
-comboreps is a tab file with two colums, the first the actual library name in the .trans file and the second the merged library name. This allows replicates to be merged at a later point in the data than the initial naming process.

Usage: trans cutoff comboreps > Redirect\n" unless (@ARGV);
	($file1, $cutoff, $combofile) = (@ARGV);
	die "Please follow command line args\n" unless ($file1);
chomp ($file1);
chomp ($cutoff);
chomp ($combofile) if ($combofile);

if ($combofile){
    open (IN, "<${combofile}") or die "Can't open ${combofile}\n";
    while ($line=<IN>){
	chomp ($line);
	next unless ($line);
	($oldhead, $newhead)=split ("\t", $line);
	$changehash{$oldhead}=$newhead;
    }
    close (IN);
}

open (IN, "<${file1}") or die "Can't open ${file1}\n";
while ($line=<IN>){
    chomp ($line);
    next unless ($line);
    #remove if it was removed at any step of the process
    next if ($line=~/remove/);
    ($name, $OTU)=split ("\t", $line);
    if ($name=~/^.+_[0-9]+ /){
	($lib)=$name=~/^(.+?)_[0-9]+ /;
	if ($combofile){
	    if ($changehash{$lib}){
		$newlib=$changehash{$lib};
	    } else {
		die "OTU2lib_count_trans1_3.pl error: missing the translated lib name for $lib\n";
	    }
	} else {
	    $newlib=$lib;
	}
	$alllib{$newlib}++;
	$OTUhash{$OTU}{$newlib}++;
	$cutoffhash{$OTU}++;
    } elsif ($name=~/^.+_[0-9]+$/){
	($lib)=$name=~/^(.+?)_[0-9]+$/;
        if ($combofile){
            if ($changehash{$lib}){
                $newlib=$changehash{$lib};
            } else {
                die "OTU2lib_count_trans1_3.pl error: missing the translated lib name for $lib\n";
            }
        } else {
            $newlib=$lib;
        }
	$alllib{$newlib}++;
        $OTUhash{$OTU}{$newlib}++;
        $cutoffhash{$OTU}++;
    } else {
	die "Don't recognize the lib in the name $name\n";
    }
}
close (IN);

foreach $OTU (sort keys %OTUhash){
    print "OTU";
    foreach $lib (sort keys %alllib){
	print "\t$lib";
    }
    print "\n";
    last;
}

foreach $OTU (sort keys %OTUhash){
    next unless ($cutoffhash{$OTU}>=$cutoff);
    print "$OTU";
    foreach $lib (sort keys %alllib){
	if ($OTUhash{$OTU}{$lib}){
	    print "\t$OTUhash{$OTU}{$lib}";
	} else {
	    print "\t0";
	}
    }
    print "\n";
}

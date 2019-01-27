#!/usr/bin/perl
use strict; use warnings;
undef my @keys;
open IN, "keywords.txt";
while(<IN>){ chomp; push @keys, $_; } close IN;
undef my @scroll;
open IN, "scrolls/cassius_dio_roman_history.txt";
while(<IN>){ chomp; push @scroll, $_; } close IN; 
my $scroll = join " ",@scroll;
$scroll =~ s/[0-9]//g;
$scroll =~ s/\[//g; $scroll =~ s/\]//g; 
$scroll =~ s/\=//g; $scroll =~ s/--/ /g;
$scroll =~ s/-//g; $scroll =~ s/Sidenote//g;
$scroll =~ s/://g; $scroll =~ s/FRAG\.//g;
$scroll =~ s/\(//g; $scroll =~ s/\)//g;
$scroll =~ s/BOISSEVAIN//g; $scroll =~ s/BOOK//g;
$scroll =~ s/_//g; $scroll =~ s/\^//g; 
$scroll =~ s/A\.D\.//g; $scroll =~ s/B\.C\.//g; $scroll =~ s/a\.u\.//g; 
$scroll =~ s/\*//g; $scroll =~ s/Footnote//g;  
my $ind = 0;
my @text = split /(?<=[a-z]\.)/, $scroll; undef my %done;
foreach my $sentence (@text){
	my $s = $sentence;
	foreach my $kw (@keys){ 
		if($s =~ / $kw/i) {
			$s =~ s/^[":;,.]//; $s =~ s/ ?//; $s=~ s/ $//;
			$s =~ s/   //g; $s =~ s/ \.//g; 
			do { $s =~ s/^[":;,. ]//g; } until ($s !~ /^[";:,. ]/); 
			next if(exists $done{$s});
			if (length($s) > 240){ 
				undef my @tweets;
				my @t = split / /, $s;
				my $t = shift @t;
				do{
					if(length($t)+length($t[0]) > 125){ 
						push @tweets, $t; 
						$t = shift @t; 
					} else { my $tt = shift @t; $t=$t." ".$tt; } 
				} until(scalar(@t)==0);
				push @tweets, $t;
				my $last = pop @tweets; 
				if(length($last)+length($tweets[-1]) < 239) { my $tt = pop @tweets; push @tweets, "$last $tt"; }
				else { push @tweets, $last;} 
				foreach my $tweet (@tweets) { print "$ind\t$tweet\n"; }
				$done{$s}++; $ind++; 
			} 
			else { print "$ind\t$s\n"; $done{$s}++; $ind++; }	
		} 
	}
}

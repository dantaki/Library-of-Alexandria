#!/usr/bin/perl
use strict; use warnings;
undef my @keys;
open IN, "$ARGV[0]";
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
undef my @subkw;
my @mask = qw/the in on top of a because to one two three four five six seven
eight nine ten up down west east north south all open close closed left right
over out full new old with de after before at when day what how who and or yet
but my thing things for from good bad john lower made make only paul show soon
we will auf frank man met rose side start silva is be are/;
undef my %mask; 
foreach (@mask) { $mask{$_}++; }
foreach my $kw (@keys){ 
	my $og = $kw; 
	$kw =~ s/^\#//; 
	my @kw = split /(?=[A-Z ])/, $kw; 
	foreach my $subkw (@kw){ 
		do { $subkw =~ s/^ //; } until ($subkw !~ /^ /);
		next if ($subkw =~ /[A-Za-z]\./);
		next if(exists $mask{lc($subkw)});
		next if(length($subkw)==1 || $subkw eq "");
		push @subkw, "$subkw\t$og"; 
	}
}
my $ind = 0;
my @text = split /(?<=[a-z]\.)/, $scroll; undef my %done;
my $tot = scalar(@subkw);
my $ofh = $ARGV[0];
$ofh =~ s/\.txt/\.tweets\.txt/;
open OUT, ">$ofh";
warn ">>> $tot remain <<<\n";
foreach my $kwd (@subkw){
	warn ">>> $tot remain <<<\n" if($tot % 100==0); $tot--; 
	my ($subkw,$og) = split /\t/, $kwd;
	my $match=0; 
	my $tog = $og; $tog =~ s/^\#//; 
	$match=1 if($tog eq $subkw);
	my $hash = 0; $hash = 1 if($og =~ /^\#/);
	foreach my $sentence (@text){
		my $s = $sentence;
		if($s =~ /\ $subkw /){
			$s =~ s/^[":;,.]//; $s =~ s/ ?//; $s=~ s/ $//;
			$s =~ s/   //g; $s =~ s/ \.//g; 
			do { $s =~ s/^[":;,. ]//g; } until ($s !~ /^[";:,. ]/); 
			if($match==0){
				$s = $s." $og" if ($hash==1); 
				my $sg = $og; $sg =~ s/ //g;
				$s = $s." \#$sg" if($hash==0);
			} else { $s =~ s/$subkw/\#$subkw/; } 
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
				if(length($last)+length($tweets[-1]) < 239) { my $tt = pop @tweets; push @tweets, "$tt $last"; }
				else { push @tweets, $last;} 
				foreach my $tweet (@tweets) { print OUT "$ind\t$og\t$tweet\n"; }
				$done{$s}++; $ind++; 
			} 
			else { print OUT "$ind\t$og\t$s\n"; $done{$s}++; $ind++; }	
		}
	}
}

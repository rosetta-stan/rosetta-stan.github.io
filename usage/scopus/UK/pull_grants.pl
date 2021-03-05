use strict;
use warnings;
my $counter = 1;
my $signal_found = 0;
my %accum;
my %entry_accum;



my %db;
my %org;
open (FILE1, "<pruned_projects.csv") || die $!;

# FundingOrgName,ProjectReference,EndDate,AwardPounds,GTRProjectUrl,ProjectId,FundingOrgId
#MRC,G0601170,31/08/2010,366454,https://gtr.ukri.org:443/projects?ref=G0601170,B1A8CB35-4D76-4B2E-874E-14B40CB344B9,C008C651-F5B0-4859-A334-5F574AB6B57C

while(<FILE1>) {
    my @entries = split(/,/);
    #print("$entries[1],$entries[3]\n");
    $db{$entries[1]}=$entries[3]; 
    $org{$entries[1]}=$entries[0];
}

close(FILE1);

sub commify { #add thousands commas
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    return scalar reverse $text;
}

my $no_funding_found_article_count;

while(<>) {
    if (m/^new_entry_/) { #multi-line csv, added 'new_entry_' to first column to keep count of which entry.
	++$counter;
	print("\nWorking on row: $counter\n");
	my $signal_found = 0;
	my $funding_found = 0;
	
	#wrap up what we learned from the last entry
	foreach my $grant (keys %entry_accum){ #entry_accum is the article level grants found, 
	    if (defined($db{$grant})) { 
		$funding_found = 1; #see if we have funding for any of the found grants
	    }
	}
	if (!$funding_found) {
	    ++$no_funding_found_article_count; #increment count of papers without identified funding
	}
	%entry_accum = (); #reset accum for new data. 
    }
    while(m#((\w\w/)?\w([\d\w]){6}(/\d)?)#g) { #pattern that identifies entries like EP/J002887/1
	my $match = $1;
	if (defined($entry_accum{$match})) { #skip repeats for this document
	    next;
	}
	if (length($match) == 12) { #length check needed because top pattern overgenerates
	    ++$accum{$match};
	    print("\t$match\n");
	    ++$entry_accum{$match};
	    $signal_found = 1;	    
	}
	elsif(!$signal_found && $match =~ /\d/ && $match =~/[A-Z]/) {  #looking for cap letters and digits
	    ++$accum{$match};
	    ++$entry_accum{$match};
	    print("\t$match\n");
	}
    }
}

my $total = 0;
my $total_count;
my $total_lt_1pt5million;
my $total_lt_1pt5million_count;
my $total_lt_2million;
my $total_lt_2million_count;
my $total_lt_2pt5million;
my $total_lt_2pt5million_count;

my %org_stats;
    

print("\n", scalar(keys %accum) . " entries in accum\n");
print("ProjectReference, Article Count, award amount\n");

foreach my $key (keys %accum) { #grants are counted only once
    if (defined($db{$key})) {
	print("$key: $accum{$key} £".commify($db{$key})."\n");
	$total += $db{$key};
	++$total_count;
	if ($db{$key} < 1500000) {
	    $total_lt_1pt5million += $db{$key};
	    ++$total_lt_1pt5million_count;
	}
	if ($db{$key} < 2000000) {
	    $total_lt_2million += $db{$key};
	    ++$total_lt_2million_count;
	}
	if ($db{$key} < 2500000) {
	    $total_lt_2pt5million += $db{$key};
	    ++$total_lt_2pt5million_count;
	    ++$org_stats{$org{$key}}{'counter'};
	    $org_stats{$org{$key}}{'funding'} += $db{$key};
	}
    }
    else {
	print("$key: $accum{$key} ??\n"); #print that funds were not found for candidate grant number
    }
}



printf("%d possible grants were found with UKRI funding acknowledgement in %d research papers that mentioned a Stan ecosystem component.\n\n", scalar keys %accum, $counter);
print(qq{The query is: FUND-SPONSOR ( "Arts and Humanities Research Council" )  OR  FUND-SPONSOR ( "Economic and Social Research Council" )  OR  FUND-SPONSOR ( "Engineering and Physical Sciences Research Council" )  OR  FUND-SPONSOR ( "Natural Environment Research Council" )  OR  FUND-SPONSOR ( "Medical Research Council" )  OR  FUND-SPONSOR ( "Research England" )  OR  FUND-SPONSOR ( "Science and Technology Facilities Council" )  OR  FUND-SPONSOR ( "UK Research and Innovation" )  OR  FUND-SPONSOR ( "Biotechnology and Biological Sciences Research Council" )  OR  FUND-SPONSOR ( "Engineering and Physical Sciences Research Council" )  OR  FUND-SPONSOR ( "Research Councils UK" )  AND  ALL ( ( brms  AND  bürkner )  OR  ( gelman  AND  hoffman  AND  stan )  OR  mc-stan.org  OR  rstanarm  OR  pystan  OR  ( rstan  AND NOT  mit ) )\n\n});

printf("%d research papers did not have recoverable grant information despite being classified as having recieved UKRI funding as determined by scopus.com\n",$no_funding_found_article_count);
printf("Of the possible grants, %d had recoverable project/grant ids.\n",$total_count);
printf("Total expenditures for %d grants = £%s \ntotal < 1.5 million for %d grants = £%s\ntotal < 2 million for %d grants = £%s\ntotal < 2.5 million for %d grants = £%s\n",
       $total_count, commify($total), 
       $total_lt_1pt5million_count, commify($total_lt_1pt5million),
       $total_lt_2million_count, commify($total_lt_2million),
       $total_lt_2pt5million_count, commify($total_lt_2pt5million));

print("Institute \tcount funding_total for grants < £2.5 million\n");
foreach my $org (keys %org_stats) {
    printf("%s\t\t%d\t£%s\n", $org, $org_stats{$org}{'counter'}, commify($org_stats{$org}{'funding'}));
}

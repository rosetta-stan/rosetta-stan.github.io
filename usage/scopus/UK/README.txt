This code attemtps to assess the amount of UKRI (UK Research and Innovation) funding acknowledged in research articles that also mention Stan ecosystem components. Script output is in 'output.txt'. 

To run the code, uncompress 'pruned_projects.csv.tgz' and execute:
>perl pull_grants.pl scopusUKRI264_cleaned.csv

Data sources are:

Scopus.com provided the search that linked UKRI funding wit Stan ecosystem queriies with an casually determined precision of 95% for ecosystem mentions. Recall is unknown as is the performance of Scopus.com's identification of who funded the research article. The query used was:

FUND-SPONSOR ( "Arts and Humanities Research Council" )  OR  FUND-SPONSOR ( "Economic and Social Research Council" )  OR  FUND-SPONSOR ( "Engineering and Physical Sciences Research Council" )  OR  FUND-SPONSOR ( "Natural Environment Research Council" )  OR  FUND-SPONSOR ( "Medical Research Council" )  OR  FUND-SPONSOR ( "Research England" )  OR  FUND-SPONSOR ( "Science and Technology Facilities Council" )  OR  FUND-SPONSOR ( "UK Research and Innovation" )  OR  FUND-SPONSOR ( "Biotechnology and Biological Sciences Research Council" )  OR  FUND-SPONSOR ( "Engineering and Physical Sciences Research Council" )  OR  FUND-SPONSOR ( "Research Councils UK" )  AND  ALL ( ( brms  AND  bürkner )  OR  ( gelman  AND  hoffman  AND  stan )  OR  mc-stan.org  OR  rstanarm  OR  pystan  OR  ( rstan  AND NOT  mit ) )

The interface has the opiton of downloading the results to a csv file which was used to create 'scopusUKRI264_cleaned.csv' which is a modified version of that file with the first column having 'new_entry_' at the beginning of each row. The .csv file has newlines so that convention made it easier to keep track of when the next row had been started. All intermediate columns were removed except those listing the grant and funding information and saved as a tab seperated file.

The funding database is 'pruned_projects.csv' which was originally downloaded from https://gtr.ukri.org/search/project with the search term '*' and then selecting the 'csv' button to download what appears to be the entire data set. That csv file was further simplified to contain the headings:

FundingOrgName,ProjectReference,EndDate,AwardPounds,GTRProjectUrl,ProjectId,FundingOrgId

The first line is:

MRC,G0601170,31/08/2010,366454,https://gtr.ukri.org:443/projects?ref=G0601170,B1A8CB35-4D76-4B2E-874E-14B40CB344B9,C008C651-F5B0-4859-A334-5F574AB6B57C

The relevant columns for this work are 'FundingOrgName', 'ProjectReference' and 'AwardPounds'.


The Perl script goes through Scopus.com results, attempts to extract the ProjectReference. Once all candidate references are collected the script then looks up ProjectReference and records the funding amount if possible. Various kinds of reporting are conducted with system output in output.txt.

About 1/3 of the articles appear to be UKRI funded but they either lack a ProjectReference or some other issue occurs. They are not included as a result.

Note that there are summary statistics for grants less than a certain amount, e.g. 1.5 million pounds. This is to eliminate large grants that fund entire university programs and as such inflate total value. The output.txt reports the value of each ProjectReference or ? if none was found. 


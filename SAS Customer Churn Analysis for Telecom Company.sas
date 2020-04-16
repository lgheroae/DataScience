/*Advanced SAS - Mini project. Telecom company.*/

*home computer path;
libname p 'C:\Users\Laura\Documents\DSA\SAS\Mini Project';

*school computer path;
*libname p 'C:\Users\lgheroae\Documents\Laura Gheroae\SAS_2\Project';


/*read .txt file into SAS file*/


/*VERSION 1*/
/* : allows to specify informat at the time of input, and the columns are already in the right order */
data p.wireless;
	infile 'C:\Users\Laura\Documents\DSA\SAS\Mini Project\SAS_Telecom_Customers.txt' dsd dlm='|' firstobs=2;
	input AcctNo : $13. ActDt : mmddyy10. DeactDt : mmddyy10. DeactReason : $4. GoodCredit RatePlan DealerType : $2. Age Province : $2. Sales : dollar8.;
	format ActDt DeactDt date7.;
run;
proc print data=p.wireless (obs=10) noobs; 
run;


/*VERSION 2*/
data p.wireless;
	infile 'C:\Users\Laura\Documents\DSA\SAS\Mini Project\New_Wireless_Pipe.txt' dsd dlm='|' firstobs=2;
	informat AcctNo $13. ActDt DeactDt mmddyy10. DeactReason $4. DealerType $2. Province $2. Sales dollar8.;
	input AcctNo $ ActDt DeactDt DeactReason $ GoodCredit RatePlan DealerType $ Age Province $ Sales;
	format ActDt DeactDt date7.;
run;
/*change column order and print 10 observations*/
data p.wireless;
	informat AcctNo ActDt DeactDt DeactReason GoodCredit RatePlan DealerType Age Province Sales;
	set p.wireless;
run;
proc print data=p.wireless (obs=10) noobs; 
run;




/*	--------------------------------------------------------------
	--------------------------------------------------------------
1.1  Explore and describe the dataset briefly. For example, is the acctno unique? What
is the number of accounts activated and deactivated? When is the earliest and
latest activation/deactivation dates available? And so on….
	--------------------------------------------------------------
	-------------------------------------------------------------- */

/*exploratory analysis*/
proc contents data=p.wireless; run;
proc means data=p.wireless maxdec=0; run;
proc means data=p.wireless n min max maxdec=0; run;
proc univariate data=p.wireless;
	var sales;
	histogram sales /normal;
run;

/*check for duplicate AcctNo*/
proc sql;
	select 	count(AcctNo) 							as TotalAccts, 
			count(distinct AcctNo) 					as DistinctAccts, 
			count(AcctNo)-count(distinct AcctNo) 	as DuplicateAccts 
	from p.wireless;	
quit;
/* Result: 0 duplicates.
TotalAccts DistinctAccts DuplicateAccts 
102255 102255 0 
*/

/*if there were duplicates, we could use the dataset wireless1 (eliminating duplicates is a sensitive issue)*/
proc sort data=p.wireless out=p.wireless1 nodupkey dupout=p.w_dups;
	by AcctNo;
run;

/*add a derived column for account status*/
data p.wireless2;
	set p.wireless;
	length AcctStatus $6;
	if 		DeactDt = . then AcctStatus = 'Active';
	else if ActDt  ^= . then AcctStatus = 'Closed';
	else 					 AcctStatus = '';
run;

/*number of accounts active and deactive, with deactivation reason*/
proc freq data=p.wireless2;
	tables DeactReason*AcctStatus /norow nocol nocum missing; /*do not show row percentage, col percentage, cumulative values, include missing values*/
	title "Active vs. Closed Accounts";
	title2 "(with Deactivation Reason)";
	footnote "*Active Accounts have no deactivation reason.";
run;
title; title2; footnote; 


/*earliest and latest activation/deactivation date*/
proc means data=p.wireless maxdec=0 min max noprint; 
	var ActDt DeactDt;
	output out=p.daterange 	min(ActDt)		= ActDt_b
							max(ActDt)		= ActDt_e
							min(DeactDt)	= DeactDt_b
							max(DeactDt)	= DeactDt_e
							;
run;
proc print data=p.daterange (drop = _Type_ _Freq_) noobs;
	title "Activation/Deactivation Date Range";
run;
title;
/*
Activation/Deactivation Date Range 
ActDt_b ActDt_e DeactDt_b DeactDt_e 
20JAN99 20JAN01 25JAN99 20JAN01 
*/

/*age range*/
proc means data=p.wireless maxdec=0 min max;
	var Age;
	Title "Age Range";
run;
title;
/*
Analysis Variable : Age  
Minimum Maximum 
1 110 
*/

/*VERSION 1 simple statistics*/
/*accounts by province*/
proc tabulate data=p.wireless;
	class Province /missing;
	table Province="" ALL="Total", N="Count" COLPCTN="%" /box="Province";
	title "Number of Accounts by Province";
run;
title;
/*
Province Count % 
    5907 5.78 
AB 10277 10.05 
BC 22040 21.55 
NS 11529 11.27 
ON 42500 41.56 
QC 10002 9.78 
Total 102255 100.00 
*/

/*same simple statistics for DeactReason, RatePlan, DealerType*/
proc tabulate data=p.wireless;
	class DeactReason;
	table DeactReason=" " ALL="Total", N="Count" COLPCTN="%" /box="DeactReason";
	title "Deactivation Reason";
run;
title;
proc tabulate data=p.wireless;
	class RatePlan /missing;
	table RatePlan=" " ALL="Total", N="Count" COLPCTN="%" /box="RatePlan";
	title "Rate Plans";
run;
title;
proc tabulate data=p.wireless;
	class DealerType /missing;
	table DealerType=" " ALL="Total", N="Count" COLPCTN="%" /box="DealerType";
	title "Dealer Types";
run;
title;


/*VERSION 2 simple statistics*/
proc freq data=p.wireless2;
	tables Province DeactReason RatePlan DealerType /norow nocol nocum;
run;


/*a few simple charts*/
ods graphics on;
goptions reset=all;
proc gchart data=p.wireless;
	title "Accounts by Province";
	pie Province /value=outside percent=inside slice=outside;

	title "Deactivation Reason";
	hbar DeactReason;

	title "Rate Plan";
	hbar RatePlan /discrete;

	title "Dealer Type";
	hbar DealerType;
run;
title;
ods graphics off;


/*	--------------------------------------------------------------
	--------------------------------------------------------------
1.2  What is the age and province distributions of active and deactivated customers?
Use dashboards to present and illustrate.
	--------------------------------------------------------------
	-------------------------------------------------------------- */


proc format;
	value agegrp 	.			= '           '
					0 - 20		= '20 or under'
					21 - 40 	= '21 - 40    '
					41 - 60 	= '41 - 60    '
					61 - high 	= '61+        ';

	value salesgrp 	.			= '              '
					0 - 100		= '$100 or less  '
					101 - 500 	= '$101 - $500   ' /*$100.01 for 2 decimals*/
					500 - 800 	= '$501 - $800   '
					800 - high 	= '$800 and above';
run;

/*Age distribution of Active and Closed Accounts, by Province*/
/*VERSION 1*/
proc freq data=p.wireless2;
	table Province*Age*AcctStatus /norow nocol nopercent nocum missing;
	title "Age distribution of Active and Closed Accounts, by Province";
	format Age agegrp.;
run;
title;
/* Result: 6 tables, 1 for each province. */

/*VERSION 2, with exporting to Excel. 1 table.*/
ods listing close;
ods noresults;
ods html
	path = 'C:\Users\Laura\Documents\DSA\SAS\Mini Project'
	file = 'Age_by_Prov.xls';
proc tabulate data=p.wireless2 format=comma12. noseps;
	class Province AcctStatus Age /missing;
	table Province="" * (Age="" ALL = "Province Total") ALL="Grand Total", 
			AcctStatus*N="" ALL="Total"*N="" /box="Province & Age Group";
	format Age agegrp.;
	title "Age distribution of Active and Closed Accounts, by Province";
run;
title;
ods html close;
ods results;
ods listing;

/*2 dashboards for Active and Closed Accounts, respectively, by Province and Age Group*/
ods graphics on;
goptions reset=all;
proc sgplot data=p.wireless2(where=(AcctStatus='Active')) ;
	hbar Province /group=Age grouporder=descending groupdisplay=cluster missing datalabel datalabelfitpolicy=none;
	format Age agegrp.;
	title "Active Accounts by Province and Age Group";
run;
title;
ods graphics off;

ods graphics on;
goptions reset=all;
proc sgplot data=p.wireless2(where=(AcctStatus='Closed')) ;
	hbar Province /group=Age grouporder=descending groupdisplay=cluster missing datalabel datalabelfitpolicy=none nofill;
	format Age agegrp.;
	title "Closed Accounts by Province and Age Group";
run;
title;
ods graphics off;


proc univariate data=p.wireless;
	var sales;
	histogram sales /vscale=count;
run;



ods graphics on;
goptions reset=all;
proc sgplot data=p.wireless2 ;
	*vbar Province /group=Age grouporder=descending groupdisplay=cluster missing datalabel datalabelfitpolicy=none nofill;
	vbar Sales_sum/group=Sales;
	*format Age agegrp.;
	*title "Closed Accounts by Province and Age Group";
run;
title;
ods graphics off;




proc means data=p.wireless2 nway;
class sales;
var sales;
output out=temp n=Sales_N;
run;

data temp;
	set temp (keep=Sales Sales_N);
	Sales_Amt = Sales*Sales_N;
run;


proc format
	value salesfmt 		. = ''
						0-50='0-50'
						51-100='51-100'
						101-150='101-150'
						151-200='151-200'
						201-250='201-250'
						251-300='251-300'
						301-350='301-350'
						351-400='351-400'
						401-450='401-450'
						451-500='451-500'
						501-550='501-550'
						551-600='551-600'
						601-650='601-650'
						651-700='651-700'
						701-750='701-750'
						751-800='751-800'
						801-850='801-850'
						851-900='851-900'
						901-950='901-950'
						951-1000='951-1000'
						1001-1050='1001-1050'
						1051-1100='1051-1100'
						1101-1150='1101-1150'
						1151-1200='1151-1200';
run;

ods graphics on;
goptions reset=all;
proc sgplot data=temp;
vbar Sales_Amt /group=Sales groupdisplay=cluster;
format Sales salesfmt.;
run;
title;
ods graphics off;


proc univariate data=temp;
	var sales sales_amt;
	histogram sales/normal;
	histogram sales_amt/normal;
run;





/*Additionally, another useful insight: Sales and Account Status distribution by Province and Dealer Type*/
ods listing close;
ods noresults;
ods html
	path = 'C:\Users\Laura\Documents\DSA\SAS\Mini Project'
	file = 'Sales_AcctSt_by_Prov_DealerType.xls';
proc tabulate data=p.wireless2 noseps;
	class Province DealerType AcctStatus /missing; 
	var Sales;
	table Province="" * (DealerType="" ALL="Province Total") ALL="Grand Total", 
			Sales*f=dollar12.*SUM="" AcctStatus * (N="Count"*f=comma12. ROWPCTN="%") ALL="Total"*N=""*f=comma12. /box="Province & Dealer Type";
	title "Sales and Account Status distribution by Province and Dealer Type";
run;
title;
ods html close;
ods results;
ods listing;



/*	--------------------------------------------------------------
	--------------------------------------------------------------
1.3 Segment the customers based on age, province and sales amount:
Sales segment: < $100, $100---500, $500-$800, $800 and above.
Age segments: < 20, 21-40, 41-60, 60 and above.
Create analysis report by using the attached Excel template.
	--------------------------------------------------------------
	-------------------------------------------------------------- */

/*segments defined prior in proc format*/

/*VERSION 1 - one Excel file*/
ods listing close;
ods noresults;
ods html
	path = 'C:\Users\Laura\Documents\DSA\SAS\Mini Project'
	file = 'AcctSales_by_Age_Prov.xls';
proc tabulate data=p.wireless2 noseps;
	class AcctStatus Province Age Sales /missing;
	table 
			AcctStatus /*page*/
			,
			Province="" ALL="Grand Total" /*rows*/
			, 
			Age="" * (Sales="Number of Accounts"*N=""*f=comma12. ALL="Total"*N=""*f=comma12.) ALL="Grand Total"*N=""*f=comma12. /*cols*/
			/rts=40 box="Province";
	format Age agegrp. Sales salesgrp.;
	title "Sales by Age and Province";
run;
title;
ods html close;
ods results;
ods listing;


/*VERSION 2 - two Excel output files, for Active and Closed accounts, respectively*/
ods listing close;
ods noresults;
ods html
	path = 'C:\Users\Laura\Documents\DSA\SAS\Mini Project'
	file = 'ActiveAccts_Sales_by_Age_Prov.xls';
proc tabulate data=p.wireless2(where=(AcctStatus='Active')) noseps;
	class Province Age Sales /missing;
	table Province="" ALL="Grand Total", 
			Age="" * (Sales="Number of Accounts"*N=""*f=comma12. ALL="Total"*N=""*f=comma12.) ALL="Grand Total"*N=""*f=comma12. 
			/rts=40 box="Province";
	format Age agegrp. Sales salesgrp.;
	title "Account Status = Active";
run;
title;
ods html close;
ods results;
ods listing;


ods listing close;
ods noresults;
ods html
	path = 'C:\Users\Laura\Documents\DSA\SAS\Mini Project'
	file = 'ClosedAccts_Sales_by_Age_Prov.xls';
proc tabulate data=p.wireless2(where=(AcctStatus='Closed')) noseps;
	class Province Age Sales /missing;
	table Province="" ALL="Grand Total", 
			Age="" * (Sales="Number of Accounts"*N=""*f=comma12. ALL="Total"*N=""*f=comma12.) ALL="Grand Total"*N=""*f=comma12. 
			/rts=40 box="Province";
	format Age agegrp. Sales salesgrp.;
	title "Account Status = Closed";
run;
title;
ods html close;
ods results;
ods listing;



/*	--------------------------------------------------------------
	--------------------------------------------------------------
    Statistical Analysis
	1.4.1. Calculate the tenure in days for each account and give its simple statistics.
	--------------------------------------------------------------
	-------------------------------------------------------------- */

proc sql;
	select ActDt_e from p.daterange;
quit;
/*ActDt_e 
20JAN01*/

/*add a derived column for Tenure(in days)*/
/*this algorithm uses the least number of comparisons*/
data p.wireless2;
	set p.wireless2;
	if 		DeactDt = . then Tenure = intck('day', ActDt, "20JAN01"D);
	else if ActDt  ^= . then Tenure = intck('day',ActDt, DeactDt);
	else 					 Tenure = .;
	Tenure = Tenure*1;
run;

proc means data=p.wireless2 maxdec=0 n nmiss mean median min max;
	class AcctStatus;
	var Tenure; 
run;

/*export to Excel*/
ods listing close;
ods noresults;
ods excel file ='C:\Users\Laura\Documents\DSA\SAS\Mini Project\TenureFrequency.xlsx';
proc freq data=p.wireless2;
	table Tenure*AcctStatus /nopercent norow nocol missing;
run;
ods excel close;
ods results;
ods listing;



/*	--------------------------------------------------------------
	--------------------------------------------------------------
	1.4.2. Calculate the number of accounts deactivated for each month.
	--------------------------------------------------------------
	-------------------------------------------------------------- */
data p.wireless2;
	set p.wireless2;
	*if DeactDt ^= . then DeactDt_yymm = compbl(year(DeactDt) || '- ' || month(DeactDt));
	if DeactDt ^= . then DeactDt_yymm = year(DeactDt)*100 + month(DeactDt);
run;
proc print data=p.wireless2 (obs=20); 
run;

proc tabulate data=p.wireless2(where=(AcctStatus='Closed')) noseps;
	class DeactDt_yymm /missing;
	table DeactDt_yymm="" ALL="Total", ALL="Total"*N="" /box="Deactivation Year-Month";
	title "Accounts Deactived by Month";
run;
title;


ods graphics on;
goptions reset=all;
proc sgplot data=p.wireless2(where=(AcctStatus='Closed')) ;
	vbar DeactDt_yymm /missing;
	title "Deactivation Date by Month";
run;
title;
ods graphics off;


/*	--------------------------------------------------------------
	--------------------------------------------------------------
	1.4.3. Segment the account, first by account status “Active” and “Deactivated”, then by
Tenure: < 30 days, 31---60 days, 61 days--- one year, over one year. Report the
number of accounts of percent of all for each segment.
	--------------------------------------------------------------
	-------------------------------------------------------------- */

proc format;
	value tenurefmt .			= '              '
					0 - 30 	 	= '0 - 30 days   '
					31 - 60  	= '31 - 60 days  '
					61 - 365 	= '61 days - 1 yr'
					366 - high 	= '1 yr +        ';
run;

proc tabulate data=p.wireless2 noseps;
	class AcctStatus Tenure /missing;
	table AcctStatus="" ALL="Total"*f=comma12., Tenure=""*N=""*f=comma12. ALL="Total"*N=""*f=comma12.;
	format Tenure tenurefmt.;
	title "Number of Accounts by Account Status and Tenure";
run;
title;

proc tabulate data=p.wireless2 noseps format=comma12.;
	class AcctStatus Tenure /missing;
	table AcctStatus=""*(N="Count" COLPCTN="%col") ALL="Total", Tenure="" ALL="Total";
	format Tenure tenurefmt.;
	title "Number of Accounts by Account Status and Tenure";
	title2 "(with column percentages)";
run;
title;
title2;

proc tabulate data=p.wireless2 noseps format=comma12.;
	class AcctStatus Tenure /missing;
	table AcctStatus="" ALL="Total", Tenure=""*(N="Count" ROWPCTN="%row") ALL="Total";
	format Tenure tenurefmt.;
	title "Number of Accounts by Account Status and Tenure";
	title2 "(with row percentages)";
run;
title;
title2;

/*	--------------------------------------------------------------
	--------------------------------------------------------------
	1.4.4. Test the general association between the tenure segments and “Good Credit”
“RatePlan ” and “DealerType.”
	--------------------------------------------------------------
	-------------------------------------------------------------- */

/*VERSION 1*/
proc tabulate data=p.wireless2 (where=(AcctStatus='Closed')) format=comma12. noseps;
	class Tenure GoodCredit RatePlan DealerType /missing;
	table 	(GoodCredit ALL="Total by Credit") 
			(RatePlan ALL="Total by Rate Plan")
			(DealerType ALL="Total by Dealer Type")
			, 
			Tenure*N="" ALL="Total"*N="";
	format Tenure tenurefmt.;
	title "Tenure by Credit, Rate Plan and Dealer Type";
	title2 "(Closed Accounts only)";
run;
title;
title2;


proc tabulate data=p.wireless2 (where=(AcctStatus='Closed')) format=comma12. noseps;
	class Tenure GoodCredit RatePlan DealerType /missing;
	table 	GoodCredit="" RatePlan="" DealerType="", 
			Tenure*N="" ALL="Total"*N="" /box="Good Credit, Rate Plan & Dealer Type";
	format Tenure tenurefmt.;
	title "Tenure by Credit, Rate Plan and Dealer Type";
	title2 "(Closed Accounts only)";
run;
title;
title2;


/*VERSION 2 - PROC FREQ with ChiSq   Preferred*/
proc freq data=p.wireless2 (where=(AcctStatus='Closed'));
	table GoodCredit*Tenure /norow nocol nocum missing chisq;
	format Tenure tenurefmt.;
	title "Tenure by Good Credit";
	title2 "(Closed Accounts only)";
run;
title;
title2;
/*Statistics for Table of GoodCredit by Tenure 
Statistic DF Value Prob 
Chi-Square 3 370.0813 <.0001 
Likelihood Ratio Chi-Square 3 378.4591 <.0001 
Mantel-Haenszel Chi-Square 1 3.2689 0.0706 
Phi Coefficient   0.1373   
Contingency Coefficient   0.1360   
Cramer's V   0.1373   
*/

proc freq data=p.wireless2 (where=(AcctStatus='Closed'));
	table RatePlan*Tenure /norow nocol nocum missing chisq;
	format Tenure tenurefmt.;
	title "Tenure by Rate Plan";
	title2 "(Closed Accounts only)";
run;
title;
title2;
/*Statistics for Table of RatePlan by Tenure 
Statistic DF Value Prob 
Chi-Square 6 74.8372 <.0001 
Likelihood Ratio Chi-Square 6 78.8238 <.0001 
Mantel-Haenszel Chi-Square 1 6.9335 0.0085 
Phi Coefficient   0.0617   
Contingency Coefficient   0.0616   
Cramer's V   0.0437   
*/


proc freq data=p.wireless2 (where=(AcctStatus='Closed'));
	table DealerType*Tenure /norow nocol nocum missing chisq;
	format Tenure tenurefmt.;
	title "Tenure by Dealer Type";
	title2 "(Closed Accounts only)";
run;
title;
title2;
/*Statistics for Table of DealerType by Tenure 
Statistic DF Value Prob 
Chi-Square 9 214.6843 <.0001 
Likelihood Ratio Chi-Square 9 204.0402 <.0001 
Mantel-Haenszel Chi-Square 1 53.9021 <.0001 
Phi Coefficient   0.1046   
Contingency Coefficient   0.1040   
Cramer's V   0.0604   
*/



/*	--------------------------------------------------------------
	--------------------------------------------------------------
	1.4.5. Is there any association between the account status and the tenure segments?
Could you find out a better tenure segmentation strategy that is more associated
with the account status?
	--------------------------------------------------------------
	-------------------------------------------------------------- */

proc freq data=p.wireless2;
	table AcctStatus*Tenure /norow nocol nocum missing chisq;
	format Tenure tenurefmt.;
	title "Tenure by Account Status";
run;
title;
/* Statistics for Table of AcctStatus by Tenure

                  Statistic                     DF       Value      Prob
                  Chi-Square                     3   4340.7439    <.0001
                  Likelihood Ratio Chi-Square    3   4505.0740    <.0001
                  Mantel-Haenszel Chi-Square     1   3452.8248    <.0001
                  Phi Coefficient                       0.2060
                  Contingency Coefficient               0.2018
                  Cramer's V                            0.2060

                                   Sample Size = 102255
*/

/*trying a different tenure segmentation*/
proc format;
	value tenurefmt2_  .			= '              '
					0 - 30 	 	= '0 - 30 days   '
					31 - 60  	= '31 - 60 days  '
					61 - 90 	= '61 - 90 days  '
					91 - 180 	= '3 - 6 months  '
					181 - 270 	= '6 - 9 months  '
					271 - 365	= '9 months - 1yr'
					366 - high 	= '1yr +         ';
run;

proc tabulate data=p.wireless2 noseps;
	class AcctStatus Tenure /missing;
	table AcctStatus="" ALL="Total"*f=comma12., Tenure=""*N=""*f=comma12. ALL="Total"*N=""*f=comma12.;
	format Tenure tenurefmt2_.;
	title "Number of Accounts by Account Status and Tenure";
run;
title;

/*re-run with the new segmentation*/
proc freq data=p.wireless2;
	table AcctStatus*Tenure /norow nocol nocum missing chisq;
	format Tenure tenurefmt2_.;
	title "Tenure by Account Status";
run;
title;


proc format;
	value tenurefmt3_  .			= '              '
					0 - 30 	 	= '0 - 30 days   '
					31 - 60  	= '31 - 60 days  '
					61 - 90 	= '61 - 90 days  '
					91 - 120 	= '3 - 4 months  '
					121 - 150 	= '4 - 5 months  '
					151 - 180 	= '5 - 6 months  '
					181 - 270 	= '6 - 9 months  '
					271 - 365	= '9 months - 1yr'
					366 - high 	= '1yr +         ';
run;

proc tabulate data=p.wireless2 noseps;
	class AcctStatus Tenure /missing;
	table AcctStatus="" ALL="Total"*f=comma12., Tenure=""*N=""*f=comma12. ALL="Total"*N=""*f=comma12.;
	format Tenure tenurefmt3_.;
	title "Number of Accounts by Account Status and Tenure";
run;
title;

/*re-run with the new segmentation*/
proc freq data=p.wireless2;
	table AcctStatus*Tenure /norow nocol nocum missing chisq;
	format Tenure tenurefmt3_.;
	title "Tenure by Account Status";
run;
title;

proc tabulate data=p.wireless2;
	class AcctStatus Tenure /missing;
	format Tenure tenurefmt3_.;
	table AcctStatus*(N="Number of Accounts" COLPCTN="%col") ALL, Tenure ALL;
	title "Tenure by Account Status";
run;
title;

proc tabulate data=p.wireless2;
	class AcctStatus Tenure /missing;
	format Tenure tenurefmt3_.;
	table AcctStatus ALL, Tenure*(N="Number of Accounts" ROWPCTN="%row") ALL;
	title "Tenure by Account Status";
run;
title;


proc tabulate data=p.wireless2 noseps;
	class AcctStatus Tenure /missing;
	format Tenure tenurefmt3_.;
	table AcctStatus*COLPCTN="%col", Tenure;
	title "Tenure by Account Status";
	footnote "Column percentages.";
run;
title;
footnote;

proc tabulate data=p.wireless2;
	class AcctStatus Tenure /missing;
	format Tenure tenurefmt3_.;
	table AcctStatus ALL, Tenure*ROWPCTN="%row" ALL;
	title "Tenure by Account Status";
	footnote "Row percentages.";
run;
title;



/*	--------------------------------------------------------------
	--------------------------------------------------------------
	1.4.6. Does Sales amount differ among different account status, GoodCredit, and
customer age segments?
	--------------------------------------------------------------
	-------------------------------------------------------------- */

proc means data=p.wireless2;
  class AcctStatus /missing;
  var Sales;
run;

proc means data=p.wireless2;
  class GoodCredit /missing;
  var Sales;
run;

proc means data=p.wireless2;
  class Age /missing;
  var Sales;
  format Age agegrp.;
run;

proc tabulate data=p.wireless2 noseps;
	class AcctStatus GoodCredit Age /missing;
	var Sales;
	format Age agegrp.;
	table AcctStatus*GoodCredit*Age ALL="Total", Sales*f=comma12. ALL="Total"*f=comma12.;
	title "Sales by Account Status, Good Credit and Age";
run;
title;




proc means data=p.wireless2 median maxdec=0;
  class AcctStatus /missing;
  var Sales;
run;

proc means data=p.wireless2 median maxdec=0;
  class GoodCredit /missing;
  var Sales;
run;

proc means data=p.wireless2 median maxdec=0;
  class Age /missing;
  var Sales;
  format Age agegrp.;
run;












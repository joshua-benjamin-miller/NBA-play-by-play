*Because I did not have time to code the data perfectly
*I treat players who changed teams as different players


clear
use FreeThrow.dta,replace
sort tgameid
by season,sort:summarize uniquegid
keep if outof==3 //keep only triples
sort year month day playerteam tgameid timeremaining linenumber 

egen sid=group(playerteam)
*gen uid=gid*10000+sid*10+season
sort season gid playerteam
egen uid=group(uniquegid playerteam)

sort year month day playerteam tgameid timeremaining linenumber 

cap drop fg_last2
sort sid uid linenumber
by sid:gen fg_last2=(make[_n-1]+make[_n-2])/2 if number==3

keep if fg_last2!=.

collapse make, by(playerteam sid fg_last2)


xtset sid
xtreg make fg_last2, fe 

*What about a paired t-test 0% vs. 100% on last 2

preserve 
	drop if fg_last2==.5
	sort sid
	by sid:egen numbersobs=count(make)
	keep if numbersobs==2
	sort sid fg_last2
	by sid:gen fg_2=make[2]
	by sid:gen fg_0=make[1]
	ttest fg_2=fg_0 if fg_last2==0
restore

*What about a paired t-test 50% vs. 100% on last 2


preserve 
	drop if fg_last2==0

	sort sid
	by sid:egen numbersobs=count(make)
	keep if numbersobs==2
	sort sid fg_last2
	by sid:gen fg_2=make[2]
	by sid:gen fg_1=make[1]
	ttest fg_2=fg_1 if fg_last2==.5

restore



save FT_3shot.dta,replace

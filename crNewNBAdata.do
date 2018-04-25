*insheet using Test.txt, tab
*From the website http://basketballvalue.com/


*make
*nshot
*Nshots

clear

global files "playbyplay20052006" 
global files "$files playbyplay20062007"
global files "$files playbyplay20072008"
global files "$files playbyplay20082009"
global files "$files playbyplay20092010"
global files "$files playbyplay20102011"
global files "$files playbyplay20112012"

foreach file of global files{
clear
noi: di "Season " "`file'"
insheet using "`file'.txt", tab


*Drop Data that are not Free Throws
drop if regexm(entry,"Free Throw")==0
*Drop data that are single technical free throws
drop if regexm(entry,"Free Throw Technical")==1

*FREE THROW FLAGRANT, we don't want to distinguish that, so lets delete it.
replace entry=regexr(entry,"Free Throw Flagrant","Free Throw")
*count
*good about 25 Free Throws per team

*select just the substring [A-Z]+
gen team=regexs(1) if  regexm(entry,"^\[([A-Z]+)" )

*Make sure to grab names with apostrophe's
gen player=regexs(1) if regexm(entry,"^\[.*\] (.+) F")

*Extract the Total attempts
gen totalattempted=regexs(1) if regexm(entry,"Free Throw.+ of ([123])")
*Extract the attempt number
gen attempt=regexs(1) if regexm(entry,"Free Throw ([123])")
*determin if is it a make
gen make=(regexm(entry,"Missed|missed")==0)



generate totalattempts=real(totalattempted)
generate attempt2=real(attempt)
drop totalattempted attempt
rename attempt2 attempt



gen date=regexs(1) if regexm(gameid,"([0-9]+)([A-Z]+)")

gen matchup=regexs(2) if regexm(gameid,"([0-9]+)([A-Z]+)")



save "`file'.dta", replace

}

clear


foreach file of global files{
 append using `file'
}
drop entry
rename gameid tgameid

rename attempt number
rename totalattempts outof

order tgameid linenumber timeremaining team player number outof make


*gen date=regexs(1) if regexm(tgameid,"([0-9]+)([A-Z]+)")
*gen matchup=regexs(2) if regexm(tgameid,"([0-9]+)([A-Z]+)")
gen tyear=regexs(0) if regexm(date,"^[0-9][0-9][0-9][0-9]")
gen tmonth=regexs(1) if regexm(date,"([0-9][0-9])[0-9][0-9]$")
gen tday=regexs(0) if regexm(date,"[0-9][0-9]$")
gen tminutesign=regexs(1) if regexm(timeremaining,"^(.*):(.*):(.*)")
gen tminute=regexs(2) if regexm(timeremaining,"^(.*):(.*):(.*)")
gen minute=real(tminute)
replace minute=-minute if tminutesign=="-00"
gen q1 = minute>=36
gen q2=(minute<36&minute>=24)
gen q3=(minute<24&minute>=12)
gen q4=(minute<12) //includes overtime (negative

gen year=real(tyear)
gen month=real(tmonth)
gen day=real(tday)
drop tyear tmonth tday date tminute tminutesign
gen season=(year==2005 | year==2006&month<6) ///
		+2*(year==2006&month>6 | year==2007&month<6) ///
		+3*(year==2007&month>6 | year==2008&month<6) ///
		+4*(year==2008&month>6 | year==2009&month<6) ///
		+5*(year==2009&month>6 | year==2010&month<6) ///
		+6*(year==2010&month>6 | year==2011&month<6) ///
		+7*(year==2011&month>6 | year==2012&month<6)


	
gen smonth=(month==11)+2*(month==12)+3*(month==1)+4*(month==2) ///
	+5*(month==3)+6*(month==4)

egen uniquegid=group(tgameid)
order season smonth uniquegid tgameid linenumber timeremaining team player number outof make

gen gid=.
replace gid=uniquegid-1230 if season==2
replace gid=uniquegid-2*1230 if season==3
replace gid=uniquegid-3*1230 if season==4
replace gid=uniquegid-4*1230+12 if season==5 //12 games are missing from 4th season season
replace gid=uniquegid-5*1230+12+5 if season==6 //missing games from season (4,5) = (12,5)
replace gid=uniquegid-6*1230+12+5+1 if season==7 //missing games from season (4,5,6) = (12,5,1)
sort season gid


gen firstHalf=(gid<615)
gen playerteam=player+team


save rawbasketballvalue.dta,replace
by season,sort:summarize uniquegid
keep if outof==2 //keep only pairs
sort playerteam tgameid timeremaining linenumber 
gen make1st=.
by playerteam tgameid timeremaining :replace make1st=make[1] if _n==2


drop if make1st==. //*keep only the 2nd Attempt
gen miss1st=1-make1st
by season playerteam, sort: egen obsmake1st=total(make1st)
by season playerteam, sort: egen obsmiss1st=total(miss1st)

egen sid=group(playerteam)
*gen uid=gid*10000+sid*10+season
sort season gid playerteam
egen uid=group(uniquegid playerteam)

save NBA_basketballvalue.dta,replace


*insheet using Test.txt, tab
*From the website http://basketballvalue.com/


*make
*nshot
*Nshots

clear

cd data

global files "playbyplay20052006" 
global files "$files playbyplay20062007"
global files "$files playbyplay20072008"
global files "$files playbyplay20082009"
global files "$files playbyplay20092010"
global files "$files playbyplay20102011"
global files "$files playbyplay20112012"


*Append files together into one files
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


save FreeThrow.dta,replace

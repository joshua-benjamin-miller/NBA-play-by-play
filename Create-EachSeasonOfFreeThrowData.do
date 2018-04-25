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


*Record all free throw data
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

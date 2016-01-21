Title/Theme: Empirical Study on the Removal of self-admitted technical debt

1- choose projects 
2- checkout different versions
3- Parse code using srcML to match comments and code
4- Identify self-admitted technical debt in code comments.
5- Map back to original self-admitted technical debt-introducing commit, using git blame (or other commands, e.g., pickaxe)
6- Look forward to see if the comment no longer exists

RQ1 - How much of self-admitted technical debt gets removed ? [repeat]
(consistency of code and comment co-change) 

RQ2 - How long does it take to remove technical debt in case of self-removal?
Determine number of versions and time it takes to remove TD

RQ3 - Who removes it ? -- non-self-removal?
-- can one observe difference in self-removal rate/speed between different kinds of technical debt?
same dev that introduced it or another dev. 
experience/role of the person who removes it

RQ4 - Why these TD's are removed and why some of them does not get removed ?
look into the commit (messages) and issue trackers to see the reason? - corrective , non functional, feature addition ... 
use topic modeling to see if we can get any specific patterns


Milestones:
Nov. 14 - Nov. 30 - collect data from some projects and process it to determine self-admitted technical debt-introducing commits
Dec. 1 - Dec. 15 - RQs 1 -3
Dec. 15 - Dec. 20 - RQ 4
Jan. 5 - Jan. 15 writeup
Jan. 15 - Jan 22. polish

This is an ambitious schedule, but we will try our best to hit MSR.

Can self-admitted technical debt be found in in commit messages , issue trackers and  mailing lists ?
-- for commit messages you have already said "yes", right?
-- @issue trackers: some GitHub issue trackers use tags that might help. elasticsearch is using these tags quite extensively
-- I wonder whether "won't fix" resolution is somehow related to technical debt; probably not necessarily so since the undesired behaviour might be still observable? In CSMR 2011 we have also seen that GCC developers have Ticket-waiting and Ticket-suspended in their Bugzilla [1]
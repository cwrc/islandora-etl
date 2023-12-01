(:
HTest if the BAseX dataset is up-to-date with the source data  
* return the last modified date and the PID fto generate a comparison against the audit file 
* to transform the json audit file: jq  -r '.objects[] | [.pid,.timestamp] | @csv' audit.json then remove double quots and sort
:)

for $r in /metadata
return 
  string-join(($r/@pid/data(), $r/@modified/data()),',')
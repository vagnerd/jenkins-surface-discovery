#!/bin/bash
###
## NAME:         build-report.sh
## AUTHOR:       vagnerd <vagner.rodrigues@gmail.com>
## DESCRIPTION:  Script for building security report 
##

. ./scripts/jsd.sh r_check_envs

OUTPUT_REPORT="report-$1.html"

## HEADER REPORT
#
cat html-template/header.html > $OUTPUT_REPORT

## HOSTS/PORTS REPORT
#
echo '
<font size="2">
<div class="container" id="hosts">
<h3>Surface hosts and ports discovered</h3>
      <br>
      <table class="table table-bordered table-striped">
        <colgroup>
          <col class="col-md-4">
          <col class="col-md-7">
        </colgroup>
	<tbody>
	<tr><th>Host</th><th>TCP Port</th></tr>' >> $OUTPUT_REPORT
cat $JSD_PATH/reports/$1/scan-hosts.txt | sort -n | sed 's/\:/ /g' | awk '{ print "<tr><th>" $1 "</th><td>" $2 "</td></tr>" }' >> $OUTPUT_REPORT
echo '
        </tbody>
      </table>
    </div>
  </section>
  </div>
' >> $OUTPUT_REPORT

## HTTP ENUMERATION REPORT
#
echo '
<font size="2">
<div class="container" id="httpx">
<h3>Surface HTTP services discovered</h3>
      <br>
      <table class="table table-bordered table-striped">
        <colgroup>
          <col class="col-md-4">
          <col class="col-md-7">
        </colgroup>
        <tbody>
        <tr><th>Host</th><th>HTTP Response</th></tr>' >> $OUTPUT_REPORT

cat $JSD_PATH/reports/$1/httpx-inspect.txt | sort -n | awk '{ print "<tr><th><a href=\"" $1 "\">" $1 "</th><td>"; $1=""; print $0 "</td></tr>" }' >> $OUTPUT_REPORT
echo '
        </tbody>
      </table>
    </div>
  </section>
  </div>
' >> $OUTPUT_REPORT

## NUCLEI XSS REPORTS
#
echo '
<font size="2">
<div class="container" id="xss">
<h3>Surface XSS/SQLi vulnerability scan</h3>
      <br>
      <table class="table table-bordered table-striped">
        <colgroup>
          <col class="col-md-14">
          <col class="col-md-17">
        </colgroup>
        <tbody>
        <tr><th>Vulnerability</th><th>Severity</th><th>URL</th></tr>' >> $OUTPUT_REPORT

cat $JSD_PATH/reports/$1/xss.txt | sort -n | awk '{ print "<tr><th>" $1 "</th><td>" $3 " </td><td>" $4 "</td></tr>" }' >> $OUTPUT_REPORT
echo '
        </tbody>
      </table>
    </div>
  </div>
' >> $OUTPUT_REPORT

## NUCLEI REPORTS
#
echo '
<font size="2">
<div class="container" id="nuclei">
<h3>Surface Vulnerability scan</h3></div>' >> $OUTPUT_REPORT

for HOSTFILE in `ls $JSD_PATH/reports/$1/nuclei/`; do
  XHOST=`echo $HOSTFILE | sed 's/\_/\:/g' | sed 's/\.txt//g'`
  echo '
      <br>
      <div class="container">
      <h4>'$XHOST'</h4>
      <table class="table table-bordered table-striped">
        <colgroup>
          <col class="col-md-14">
          <col class="col-md-17">
        </colgroup>
        <tbody>' >> $OUTPUT_REPORT
  echo "<tr><th>URL</th><th>Vulnerability</th><th>Severity</th><th>Description</th></tr>" >> $OUTPUT_REPORT 
  cat $JSD_PATH/reports/$1/nuclei/$HOSTFILE | awk '{ print "<tr><th><a href=\"" $4 "\">" $4 "</a></th><td>" $1 " </td><td>" $3 "</td><td>" $0 "</td></tr>" }' >> $OUTPUT_REPORT
  echo '
        </tbody>
      </table>
    </div>
  </div>
' >> $OUTPUT_REPORT
done
	
## FFUF REPORTS
#
echo '
<font size="2">
<div class="container" id="ffuf">
<h3>Surface Fuzzing scan</h3></div>' >> $OUTPUT_REPORT

for FFUFFILE in `ls $JSD_PATH/reports/$1/ffuf/`; do
  XHOST=`echo $FFUFFILE | sed 's/\_/\:/g' | sed 's/\.txt//g'`
  echo '
      <br>
      <div class="container">
      <h4>'$XHOST'</h4>
      <table class="table table-bordered table-striped">
        <colgroup>
          <col class="col-md-14">
          <col class="col-md-17">
        </colgroup>
        <tbody>' >> $OUTPUT_REPORT
  echo "<tr><th>$XHOST</th></tr>" >> $OUTPUT_REPORT
  cat $JSD_PATH/reports/$1/ffuf/$FFUFFILE | grep $1 | cut -d\, -f3 | sort -n | uniq | egrep -v redirectlocation | awk '{ print "<tr><th><xmp>" $1 "</xmp></th></tr>" }' >> $OUTPUT_REPORT
  echo '
        </tbody>
      </table>
    </div>
  </div>
' >> $OUTPUT_REPORT
done

## FOOTER
#
echo '
<!-- Author: Vagnerd Fernandes - vagner.rodrigues@gmail.com -->
</body>
</html>' >> $OUTPUT_REPORT

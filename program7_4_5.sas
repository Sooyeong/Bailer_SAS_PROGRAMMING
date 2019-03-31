/* Program 7.3
              MODULE 5, Video 4 -------------------------------------------------- */
/*
   Exploring SAS character functions 
     - will use these functions to process web page data
NOTE:  bulletin - http://bulletin.miamioh.edu/courses-instruction/sta/
       has a different structure for course listing
Sooyeong's comment:
I tried with the course list from Stat department first and verified its reusability with Finance deartment's case.
*/



data test;
  input coursetags $ 1-150;
  datalines;
<p class="courseblocktitle"><strong>STA 125.  Introduction to Business Statistics.  (3)</strong></p>
<p class="courseblocktitle"><strong>STA 147.  First Year Seminar in Mathematics and Statistics.  (1)</strong></p>
<p class="courseblocktitle"><strong>STA 177.  Independent Studies.  (0-5)</strong></p>
<p class="courseblocktitle"><strong>STA 261.  Statistics.  (4) (MPF, MPT)</strong></p>
<p class="courseblocktitle"><strong>STA 301.  Applied Statistics.  (3) (MPT)</strong></p>
run;

proc print data=test;
run; 

data test2;
  set test;
  index_htm = index(coursetags, '<strong>');   * end of stuff before STA xxx;
  firstOff = substr(coursetags, index_htm+12);  * get rid of front stuff;
  coursenum = substr(firstOff,1,index(firstOff," ")-2);
  coursedescr = substr(firstOff, 6, index(firstOff,"(")-9); *Q- Why -9 Maybe recognize them as words??;
  mystery=index(firstOff,"(");
  hours = substr(firstOff, index(firstOff,"(")+1, 
                           index(firstOff,')')-index(firstOff,'(')-1);
run;

ods rtf file="&dir\&subdir\ch7-fig7.xx.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
proc print data=test2;
run;
ods rtf close;

/* Program 7.4
  - MODULE 5, Video 6 -------------------------------------------------- */
  REF:   http://support.sas.com/resources/papers/proceedings11/062-2011.pdf
/* 
LRECL = 32767 <- max record length (default 256)
        changes helps to avoid truncating lines
*/
/* *filename source URL "%STR(http://bulletin.miamioh.edu/courses-instruction/sta/)"         DEBUG;
  

* %STR not strictly necessary here but provides a wrapper to text that may have special characters;
*/
filename source URL "%STR(http://bulletin.miamioh.edu/courses-instruction/sta/)" DEBUG;
* %STR not strictly necessary here but provides a wrapper to text that may have special characters;


data statbull;
  format webpage $1000.;   * long enough to hold most HTML code lines;
  infile source lrecl=32767 DELIMITER=">"; * read source from web page;
  input webpage $char500. @@;
run;

proc print data=statbull;
run;

data statbull2;
  set statbull;
  if index(webpage,'STA') NE 0 then output;  * select lines with STA, elimates lots of tags;
run;
proc print data=statbull2;
run;

data statbull3;
  set statbull2;
  if index(webpage,'</strong') NE 0 then output; * narrow down to only courses - lines with /strong;
run;
proc print data=statbull3;
run;

data statbull4;
  set statbull3;
  index_num=index(webpage,'STA');
  course_num_plus = substr(webpage,index_num+5);  * removes 'STA ' from each line;
  course_num = substr(course_num_plus,1,index(course_num_plus,'.')-1);

  * clean up 4xx/5xx;
  if index(course_num, "/") then
     course_num = substr(course_num, 1, 4) || substr(course_num, 10,3);

  course_descrip_plus = substr(course_num_plus,index(course_num_plus,'.')+1);
  coursedescr = substr(course_descrip_plus, 1, index(course_descrip_plus,".")-1);
  hours = substr(course_descrip_plus, 
                           index(course_descrip_plus,"(")+1, 
                           index(course_descrip_plus,')')-index(course_descrip_plus,'(')-1);
run;
proc print data=statbull4;
run;

proc print data=statbull4 noobs label;
  var course_num coursedescr hours;;
run;
data statbull5;
  set statbull4;
  * Adding an indicator for grduate level class;
  if (substr(course_num,1,1)="6") then graduate_course='Y';
  else if (substr(course_num,4,1)="/") then graduate_course='Y';
  else graduate_course='N';
	
  * Get the maximum credit hours for the classes;
  * reverse function might be useful to get the maximum credit hours;
  max_index=index(hours,'maximum');
  dash_index=index(hours,'-');
  if max_index ne "0" then max_capacity = substr(hours, max_index+8, 2);
  else  max_capacity='N/A';

  if max_index ne "0" then hour=substr(hours,1, max_index-3);
  else hour=hours;

  * Categorize the level of courses;
  if (substr(course_num,1,1)="1") then level="1xx"; *In the original code there was no section for 1xx level. I added it here.;
  else if (substr(course_num,1,1)="2") then level="2xx";
  else if (substr(course_num,1,1)="3") then level="3xx";
  else if (substr(course_num,1,1)="4") then level="4xx/5xx";
  else level="6xx";



run;


proc print data=statbull5 noobs label;
	var course_num coursedescr hour graduate_course max_capacity;
run;

proc freq data=statbull5;
  title "Number of stat courses at each level";
  table level / nocum ;
run;



*** Let's try farmer school's finance department case;

/* Program 7.4
  - MODULE 5, Video 6 -------------------------------------------------- */
  REF:   http://support.sas.com/resources/papers/proceedings11/062-2011.pdf
/* 
LRECL = 32767 <- max record length (default 256)
        changes helps to avoid truncating lines
*/
/* *filename source URL "%STR(http://bulletin.miamioh.edu/courses-instruction/sta/)"         DEBUG;
  

* %STR not strictly necessary here but provides a wrapper to text that may have special characters;
*/
filename source URL "%STR(http://bulletin.miamioh.edu/courses-instruction/fin/)" DEBUG;
* %STR not strictly necessary here but provides a wrapper to text that may have special characters;


data finbull;
  format webpage $1000.;   * long enough to hold most HTML code lines;
  infile source lrecl=32767 DELIMITER=">"; * read source from web page;
  input webpage $char500. @@;
run;

proc print data=finbull;
run;

data finbull2;
  set finbull;
  if index(webpage,'FIN') NE 0 then output;  * change the course char from STA to FIN;
run;
proc print data=finbull2;
run;

data finbull3;
  set finbull2;
  if index(webpage,'</strong') NE 0 then output; * narrow down to only courses - lines with /strong;
run;
proc print data=finbull3;
run;

data finbull4;
  set finbull3;
  index_num=index(webpage,'FIN');
  course_num_plus = substr(webpage,index_num+5);  * removes 'FIN ' from each line;
  course_num = substr(course_num_plus,1,index(course_num_plus,'.')-1);

  * clean up 4xx/5xx;
  if index(course_num, "/") then
     course_num = substr(course_num, 1, 4) || substr(course_num, 10,3);

  course_descrip_plus = substr(course_num_plus,index(course_num_plus,'.')+1);
  coursedescr = substr(course_descrip_plus, 1, index(course_descrip_plus,".")-1);
  hours = substr(course_descrip_plus, 
                           index(course_descrip_plus,"(")+1, 
                           index(course_descrip_plus,')')-index(course_descrip_plus,'(')-1);
run;
proc print data=finbull4;
run;

proc print data=finbull4 noobs label;
  var course_num coursedescr hours;
run;

data finbull5;
  set finbull4;
  * Adding an indicator for grduate level class;
  if (substr(course_num,1,1)="6") then graduate_course='Y';
  else if (substr(course_num,4,1)="/") then graduate_course='Y';
  else graduate_course='N';
	
  * Get the maximum credit hours for the classes;
  * reverse function might be useful to get the maximum credit hours;
  max_index=index(hours,'maximum');
  dash_index=index(hours,'-');
  if max_index ne "0" then max_capacity = substr(hours, max_index+8, 2);
  else  max_capacity='N/A';

  if max_index ne "0" then hour=substr(hours,1, max_index-3);
  else hour=hours;

  * Categorize the level of courses;
  if (substr(course_num,1,1)="1") then level="1xx"; *In the original code there was no section for 1xx level. I added it here.;
  else if (substr(course_num,1,1)="2") then level="2xx";
  else if (substr(course_num,1,1)="3") then level="3xx";
  else if (substr(course_num,1,1)="4") then level="4xx/5xx";
  else level="6xx";
run;

proc print data=finbull5 noobs label;
	var course_num coursedescr hour graduate_course max_capacity;
run;


proc freq data=finbull5;
  title "Number of fin courses at each level";
  table level / nocum ;
run;

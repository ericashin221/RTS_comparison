Scripts to run RTS tools 

This research includes empirical study on running 4 RTS tools, 
STARTS, Ekstazi, HyRTS, and Clover. The order of the script running matters. 
The order is the below from 2 to N. 
======================================================================

Scripts overview  

1. clean.sh 

    Remove all the directories and files created by scripts

2. download.sh
 
    Create directories for each tools and one directory to download 
    5 opensource subjects, up to 200 revisions each if available. 
    The script recursively reads repositories.txt file as order of 
    SUBJECT_NAME GIT_URL BASE_REV. Find all the revision tags from the 
    given base_rev tag to the most latest commit tag, and write those 
    tag numbers into revisions.txt. Read from the tag revisions.txt.

3. runTools.sh  

    Run runStarts, runEkstazi, runHyRTS, runClover, and runOriginal scripts. 
    Integrate tool plugin to pom.xml and recursively read and run subjects
    and revisions downloaded by the script download.sh. Put logs into txt 
    file and move the generated log files under TOOL/SUBJECT/REV directory.  

4. extractTest_CollectBuild.sh

    Extract the name of test cases and end-to-end time from each log file. 
    This script also identifies whether the build has failure or not.  

5. extractChangesUsingStarts.sh & collectChanges.sh

    Identify which test cases should be selected and re-ran by RTS tools. 
    This is conducted based on the changed files from revisions i to i+1. 
    The results is saved in the logging file. This information is used to 
    compute safety and precision of RTS tools. 

6. calcSafetyPrecision.sh
 
    Compute safety and precision of RTS tools. This is based on the test case 
    selected by each tool and the test cases that should be selected. 
    This script automatically run java files in calcSafeyPrecision folder. 

7. collectReduction.sh 
    
    Compute time reduction and test suite reduction of RTS tools. 

8. pitRTSTOOLS.sh 

    Run mutation testing with each RTS tools. 

9. extractPitResult.sh 
     
    Extract mutation testing result with each RTS tools. 

=========================================================================

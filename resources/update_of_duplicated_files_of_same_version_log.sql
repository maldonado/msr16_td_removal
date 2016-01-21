# Files that appears containing multiple version_removed_authors and has more than one file. 

Last version seem 
# Files kept
398   | /Users/evermal/git/msr16_td_interest/tags/ant_tags/53.ANT_171_B1/src/src/tests/junit/org/apache/tools/ant/taskdefs/optional/junit/JUnitTestRunnerTest.java
1173  | /Users/evermal/git/msr16_td_interest/tags/ant_tags/53.ANT_171_B1/src/src/main/org/apache/tools/ant/UnknownElement.java
1285  | /Users/evermal/git/msr16_td_interest/tags/ant_tags/55.ANT_171/src/src/main/org/apache/tools/ant/DirectoryScanner.java
1811  | /Users/evermal/git/msr16_td_interest/tags/ant_tags/53.ANT_171_B1/src/src/main/org/apache/tools/ant/taskdefs/CopyPath.java
2013  | /Users/evermal/git/msr16_td_interest/tags/ant_tags/53.ANT_171_B1/src/src/main/org/apache/tools/ant/taskdefs/Jar.java
2545  | /Users/evermal/git/msr16_td_interest/tags/ant_tags/53.ANT_171_B1/src/src/main/org/apache/tools/ant/taskdefs/Javadoc.java
79309 | /Users/evermal/git/msr16_td_interest/tags/jruby_tags/106.1.7.22/src/core/src/main/java/org/jruby/ir/operands/StringLiteral.java

# updated as removed 
398   | /Users/evermal/git/msr16_td_interest/tags/ant_tags/53.ANT_171_B1/src/ANT_17_BRANCH/src/tests/junit/org/apache/tools/ant/taskdefs/optional/junit/JUnitTestRunnerTest.java
1173  | /Users/evermal/git/msr16_td_interest/tags/ant_tags/53.ANT_171_B1/src/ANT_17_BRANCH/src/main/org/apache/tools/ant/UnknownElement.java
1811  | /Users/evermal/git/msr16_td_interest/tags/ant_tags/53.ANT_171_B1/src/ANT_17_BRANCH/src/main/org/apache/tools/ant/taskdefs/CopyPath.java
2013  | /Users/evermal/git/msr16_td_interest/tags/ant_tags/53.ANT_171_B1/src/ANT_17_BRANCH/src/main/org/apache/tools/ant/taskdefs/Jar.java
2545  | /Users/evermal/git/msr16_td_interest/tags/ant_tags/53.ANT_171_B1/src/ANT_17_BRANCH/src/main/org/apache/tools/ant/taskdefs/Javadoc.java
1285  | /Users/evermal/git/msr16_td_interest/tags/ant_tags/55.ANT_171/src/proposal/sandbox/selectors/src/main/org/apache/tools/ant/DirectoryScanner.java
79309 | /Users/evermal/git/msr16_td_interest/tags/jruby_tags/106.1.7.22/src/core/src/main/java/org/jruby/ast/java_signature/StringLiteral.java

# UPDATES
update file_directory_per_version set matched_analyzed_file_directory = 'removed' where repository_directory in ('ANT_17_BRANCH/src/tests/junit/org/apache/tools/ant/taskdefs/optional/junit/JUnitTestRunnerTest.java','ANT_17_BRANCH/src/main/org/apache/tools/ant/UnknownElement.java','ANT_17_BRANCH/src/main/org/apache/tools/ant/taskdefs/CopyPath.java','ANT_17_BRANCH/src/main/org/apache/tools/ant/taskdefs/Jar.java','ANT_17_BRANCH/src/main/org/apache/tools/ant/taskdefs/Javadoc.java')
update file_directory_per_version set matched_analyzed_file_directory = 'removed' where file_directory like '%ANT_171/src/proposal/sandbox/selectors/src/main/org/apache/tools/ant/DirectoryScanner.java'
update file_directory_per_version set matched_analyzed_file_directory = 'removed' where file_directory like '%106.1.7.22/src/core/src/main/java/org/jruby/ast/java_signature/StringLiteral.java'

Removed version 

# counting how many duplicated files there are
select file_directory from file_directory_per_version where project_name = 'apache-ant' and version_order = '54' and file_name = 'JUnitTestRunnerTest.java';
select file_directory from file_directory_per_version where project_name = 'apache-ant' and version_order = '54' and file_name = 'UnknownElement.java';
select file_directory from file_directory_per_version where project_name = 'apache-ant' and version_order = '54' and file_name = 'DirectoryScanner.java';
select file_directory from file_directory_per_version where project_name = 'apache-ant' and version_order = '54' and file_name = 'CopyPath.java';
select file_directory from file_directory_per_version where project_name = 'apache-ant' and version_order = '54' and file_name = 'Jar.java';
select file_directory from file_directory_per_version where project_name = 'apache-ant' and version_order = '54' and file_name = 'Javadoc.java';
select file_directory from file_directory_per_version where project_name = 'jruby'     and version_order = '107' and file_name = 'StringLiteral.java';

# directory of files kept
/Users/evermal/git/msr16_td_interest/tags/ant_tags/54.ANT_170_B1/src/src/testcases/org/apache/tools/ant/taskdefs/optional/junit/JUnitTestRunnerTest.java
/Users/evermal/git/msr16_td_interest/tags/ant_tags/54.ANT_170_B1/src/src/main/org/apache/tools/ant/UnknownElement.java
/Users/evermal/git/msr16_td_interest/tags/ant_tags/54.ANT_170_B1/src/src/main/org/apache/tools/ant/DirectoryScanner.java
/Users/evermal/git/msr16_td_interest/tags/ant_tags/54.ANT_170_B1/src/src/main/org/apache/tools/ant/taskdefs/CopyPath.java
/Users/evermal/git/msr16_td_interest/tags/ant_tags/54.ANT_170_B1/src/src/main/org/apache/tools/ant/taskdefs/Jar.java
/Users/evermal/git/msr16_td_interest/tags/ant_tags/54.ANT_170_B1/src/src/main/org/apache/tools/ant/taskdefs/Javadoc.java
/Users/evermal/git/msr16_td_interest/tags/jruby_tags/107.9.0.1.0/src/core/src/main/java/org/jruby/ir/operands/StringLiteral.java


# directory of files removed
/Users/evermal/git/msr16_td_interest/tags/ant_tags/54.ANT_170_B1/src/trunk/src/tests/junit/org/apache/tools/ant/taskdefs/optional/junit/JUnitTestRunnerTest.java
/Users/evermal/git/msr16_td_interest/tags/ant_tags/54.ANT_170_B1/src/trunk/src/main/org/apache/tools/ant/UnknownElement.java
/Users/evermal/git/msr16_td_interest/tags/ant_tags/54.ANT_170_B1/src/trunk/proposal/sandbox/selectors/src/main/org/apache/tools/ant/DirectoryScanner.java
/Users/evermal/git/msr16_td_interest/tags/ant_tags/54.ANT_170_B1/src/trunk/src/main/org/apache/tools/ant/DirectoryScanner.java
/Users/evermal/git/msr16_td_interest/tags/ant_tags/54.ANT_170_B1/src/trunk/src/main/org/apache/tools/ant/taskdefs/CopyPath.java
/Users/evermal/git/msr16_td_interest/tags/ant_tags/54.ANT_170_B1/src/trunk/src/main/org/apache/tools/ant/taskdefs/Jar.java
/Users/evermal/git/msr16_td_interest/tags/ant_tags/54.ANT_170_B1/src/trunk/src/main/org/apache/tools/ant/taskdefs/Javadoc.java
/Users/evermal/git/msr16_td_interest/tags/ant_tags/54.ANT_170_B1/src/proposal/sandbox/selectors/src/main/org/apache/tools/ant/DirectoryScanner.java
/Users/evermal/git/msr16_td_interest/tags/jruby_tags/107.9.0.1.0/src/core/src/main/java/org/jruby/ast/java_signature/StringLiteral.java

# UPDATE 
begin;
update file_directory_per_version set matched_analyzed_file_directory = 'removed' where file_directory in ('/Users/evermal/git/msr16_td_interest/tags/ant_tags/54.ANT_170_B1/src/trunk/src/tests/junit/org/apache/tools/ant/taskdefs/optional/junit/JUnitTestRunnerTest.java','/Users/evermal/git/msr16_td_interest/tags/ant_tags/54.ANT_170_B1/src/trunk/src/main/org/apache/tools/ant/UnknownElement.java','/Users/evermal/git/msr16_td_interest/tags/ant_tags/54.ANT_170_B1/src/trunk/proposal/sandbox/selectors/src/main/org/apache/tools/ant/DirectoryScanner.java','/Users/evermal/git/msr16_td_interest/tags/ant_tags/54.ANT_170_B1/src/trunk/src/main/org/apache/tools/ant/DirectoryScanner.java','/Users/evermal/git/msr16_td_interest/tags/ant_tags/54.ANT_170_B1/src/trunk/src/main/org/apache/tools/ant/taskdefs/CopyPath.java','/Users/evermal/git/msr16_td_interest/tags/ant_tags/54.ANT_170_B1/src/trunk/src/main/org/apache/tools/ant/taskdefs/Jar.java','/Users/evermal/git/msr16_td_interest/tags/ant_tags/54.ANT_170_B1/src/trunk/src/main/org/apache/tools/ant/taskdefs/Javadoc.java','/Users/evermal/git/msr16_td_interest/tags/ant_tags/54.ANT_170_B1/src/proposal/sandbox/selectors/src/main/org/apache/tools/ant/DirectoryScanner.java','/Users/evermal/git/msr16_td_interest/tags/jruby_tags/107.9.0.1.0/src/core/src/main/java/org/jruby/ast/java_signature/StringLiteral.java');
commit;
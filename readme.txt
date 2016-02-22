01- clone the git repositories obtained on openhub. (www.openhub.net)
    *ant         - https://github.com/apache/ant.git
    *jmeter      - https://github.com/apache/jmeter.git
    *jruby       - https://github.com/jruby/jruby.git
    hibernate   - git://github.com/hibernate/hibernate-orm.git 
    eclipse-emf - https://git.eclipse.org/r/p/emf/org.eclipse.emf 
    squirrel    - git://git.code.sf.net/p/squirrel-sql/git 

02- extract all tags from each repository.
    - copy script 01_git_tag_extractor.py into the cloned repositories
    - execute the script

03- create technical_debt_summary entries.
    - create table technical_debt_sumary 
    - insert registries in the table
    (script available in "create_technical_debt_summary.sql")

04- create tags_information entries.
    - create table tags_information
    - copy script 02_populate_tags_information.py into the cloned repositories
    - execute script

05- create file_directory_version entries.
    - create table file_directory_per_version
    *- execute script 03_populate_file_directory_version
    *- execute script 04_clean_file_directory_data
    *- execute script 05_clean_file_directory_data
    (*) solve problem in this dataset. 
        for groups of two keep the oldest commit. 
            try heuristic first. 
        solve manually the others.


06- search the td comment version added and removed 
    - execute script 06_search_version_added.py
    - execute script 07_search_version_removed.py



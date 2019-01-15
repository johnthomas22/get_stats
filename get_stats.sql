/*
Name    : get_stats.sql
Type    : PL/SQL package
Purpose :
Display changes in values to session statistics. Useful in diagnosing performance issues in queries.
Accompanying script show_mystats,sql can be created from the block at the end of this file.
Author  : John Thomas
Date    : December 2003
Prerequisites:
grant select on v_$statname to public;
grant select on v_$mystat to public;
grant select on v_$statname to &&owner;
grant select on v_$mystat to &&owner;
grant select on v_$sesstat to &&owner;
*/
DEFINE owner="utils"

ACCEPT passwd HIDE PROMPT "Enter password for &&owner: "

CREATE USER &&owner IDENTIFIED BY &&passwd;

GRANT CREATE PROCEDURE TO &&owner;

SET ECHO ON

@@get_stats.pks
@@get_stats.pkb

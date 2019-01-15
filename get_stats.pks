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

SET SERVEROUTPUT ON
SET ECHO ON

DROP  PUBLIC SYNONYM get_stats;

CREATE PUBLIC SYNONYM get_stats FOR &&owner..get_stats;

CREATE TYPE &&owner..stat_t AS OBJECT 
(
name VARCHAR2(100), 
value NUMBER(22,3)
);
/

CREATE OR REPLACE TYPE &&owner..stats_coll AS TABLE OF &&owner..stat_t;
/

CREATE OR REPLACE
PACKAGE &&owner..get_stats
IS
FUNCTION delta RETURN stats_coll PIPELINED;
PROCEDURE display_stats;
PROCEDURE display_delta;
PROCEDURE initialise;
PROCEDURE initialise(
    p_sid NUMBER);
END get_stats;
/


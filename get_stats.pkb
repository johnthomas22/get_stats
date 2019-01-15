/*
Name    : get_stats.sql
Type    : PL/SQL package
Purpose :
Display changes in values to session statistics. Useful in diagnosing performance issues in queries.
Accompanying script show_mystats,sql can be created from the block at the end of this file.
Author  : John Thomas
Date    : December 2003
GRANT SELECT ON v_$statname TO PUBLIC;
GRANT SELECT ON v_$mystat TO PUBLIC;
Prerequisites:
*/
SET SERVEROUTPUT ON
SET ECHO ON

GRANT SELECT ON v_$session TO &&owner;
GRANT SELECT ON v_$statname TO &&owner;
GRANT SELECT ON v_$mystat TO &&owner;
GRANT SELECT ON v_$sesstat TO &&owner;


CREATE OR REPLACE
PACKAGE BODY                             &&owner..get_stats
IS
   TYPE stat_t IS TABLE OF NUMBER INDEX BY VARCHAR2(100);
   TYPE statname_t IS TABLE OF VARCHAR2(40) INDEX BY BINARY_INTEGER;
   v_stats stat_t;
   v_statnames statname_t;
   v_sid V$session.SID%TYPE;

   PROCEDURE initialise IS
      v_sid v$session.sid%TYPE;
   BEGIN 
      SELECT sid
      INTO v_sid
      FROM v$mystat
      WHERE ROWNUM < 2;
      initialise (v_sid);
   END initialise;

   PROCEDURE initialise (p_sid NUMBER) IS 
   BEGIN 
      v_sid := p_sid;
      FOR i IN (
          SELECT s.value, n.name
          FROM v$sesstat s, v$statname n
          WHERE s.statistic# = n.statistic#
          AND s.sid          = p_sid
               ) LOOP
         v_stats(i.name) := i.value;
         DBMS_OUTPUT.PUT_LINE('Initial ' || i.name || ' value: ' || v_stats(i.name));
      END LOOP;

END initialise;

FUNCTION get_statvalue(
    p_statname VARCHAR2,
    p_sid    NUMBER)
  RETURN NUMBER
IS
    v_value NUMBER;
  CURSOR scur (p_sid INTEGER, p_statname VARCHAR2) 
  IS
    SELECT s.value 
    FROM v$sesstat s, v$statname n
    WHERE s.statistic# = n.statistic#
    AND s.sid          = p_sid
    AND n.name = p_statname;

BEGIN
  OPEN scur (v_sid, p_statname);
  
  FETCH scur INTO v_value;
    --DBMS_OUTPUT.PUT_LINE('v_value: ' || v_value);
  CLOSE scur;
  RETURN v_value;
END get_statvalue;

FUNCTION delta  RETURN stats_coll PIPELINED IS

  i VARCHAR2(100);
  v_delta NUMBER;
  v_value NUMBER;
  v_stat &&owner..stat_t;
BEGIN
DBMS_OUTPUT.PUT_LINE('* * * * Changes in session ' || v_sid || ' * * * * ');
  v_stat := &&owner..stat_t('* * * * Changes in session ' || v_sid || ' * * * * ', NULL);
          PIPE ROW (v_stat);
  i      := v_stats.FIRST;
  WHILE i IS NOT NULL
  LOOP
    v_value := get_statvalue(i, v_sid);
    v_delta := v_value - (v_stats(i));
    IF v_delta != 0 THEN 
          v_stat := &&owner..stat_t(i, v_delta);
          PIPE ROW (v_stat);
    END IF;
    v_stats(i) := v_value;
    i          := v_stats.NEXT(i);

  END LOOP;
    RETURN;
END delta;
PROCEDURE display_stats
IS
  i PLS_INTEGER;
BEGIN
  i      := v_statnames.FIRST;
  WHILE i<= v_statnames.LAST
  LOOP
    v_stats(i) := get_statvalue(i, v_sid);
    i          := v_statnames.NEXT(i);
  END LOOP;
  i      := v_statnames.FIRST;
  WHILE i<= v_statnames.LAST
  LOOP
    DBMS_OUTPUT.PUT_LINE(RPAD(v_statnames(i) || ' original', 40) || ' = ' || v_stats(i));
    i := v_statnames.NEXT(i);
  END LOOP;
END display_stats;
PROCEDURE display_delta
IS
  i VARCHAR2(100);
  v_delta BINARY_INTEGER;
  v_value NUMBER(22,10);
BEGIN
DBMS_OUTPUT.PUT_LINE('* * * * Changes in session ' || v_sid || ' * * * * ');
  i      := v_stats.FIRST;
  WHILE i IS NOT NULL
  LOOP
    v_value := get_statvalue(i, v_sid);
    v_delta := v_value - (v_stats(i));
    IF v_delta != 0 THEN 
       DBMS_OUTPUT.PUT_LINE(RPAD(i || ' change', 40) || ' = ' || v_delta);
    END IF;
    v_stats(i) := v_value;
    i          := v_stats.NEXT(i);
    
  END LOOP;
END display_delta;
--'db block gets', 'consistent gets', 'physical reads')

END get_stats;
/

SHOW ERROR 

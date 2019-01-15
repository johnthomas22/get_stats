/*
Name    : get_stats.sql
Type    : PL/SQL package
Purpose :
Display changes in values to session statistics. Useful in diagnosing performance issues in queries.
Accompanying script show_mystats,sql can be created from the block at the end of this file.
Author  : John Thomas
Date    : December 2003
*/

SET SERVEROUTPUT ON
SET ECHO ON

GRANT EXECUTE ON get_stats TO PUBLIC;
CREATE PUBLIC SYNONYM get_stats FOR &&owner..get_stats;

BEGIN
    get_stats.initialise (&sid);
END;
/

/*
SELECT job_title, max_salary, first_name, last_name
FROM hr.jobs j JOIN hr.employees e
ON j.job_id = e.job_id
*/

BEGIN
    get_stats.display_stats (&sid);
END;
/


BEGIN
    get_stats.display_delta ;
END;
/

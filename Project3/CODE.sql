/************** Project 3 *********************
 * Hreiðar Ólafur Arnarsson - hreidara14@ru.is
 * Maciej Sierzputowski - maciej15@ru.is       
 **********************************************/
 
/* Task 1 */
CREATE VIEW AllAccountRecords
AS
SELECT A.aid, A.pid, A.adate, A.abalance, A.aover, R.rid, R.rdate, R.rtype, R.ramount, R.rbalance
FROM accounts A
LEFT JOIN accountrecords R
ON A.aid = R.aid;

/* Task 2 */
CREATE VIEW DebtorStatus
AS
SELECT A.pid, P.pname, SUM(A.abalance) AS abalance, SUM(A.aover) AS aover
FROM accounts A
JOIN people P
ON A.pid = P.pid
WHERE A.abalance < 0
GROUP BY A.pid, P.pname
ORDER BY A.pid;

/* Task 3 */
create or replace view FinancialStatus (PID, pName, total, unpaid)
as
select P.PID, P.pName, B.total, U.unpaid
from People P
	join (		-- this finds all accounts and joins it with people table (fullfills 1+ accounts)
		select pid, sum(abalance) as total
		from accounts
		group by pid
		) B on B.pid = P.pid
	left join (	-- use left join because some people have accounts and no unpaid bills
		select pid, sum(bamount) as unpaid
		from bills
		where bispaid = false
		group by pid
		) U on U.pid = P.pid
;

/* Task 4 */

/* Task 5 */

/* Task 6 */

/* Task 7 */

/* Task 8 */

/* Task 9 */

/* Task 10 */

/* Task 3 
 * Create view FinancialStatus. Shows for each person that has one or more accounts:
 * - the PID and pName of the person
 * - the total amount they have on all their accounts
 * - the total amount of all unpaid bills
 * ATH. Frumskilyrði er að viðkomandi eigi einn eða fleiri accounts.
 * Svo sýna total á öllum accounts og total á öllum unpaid bills
 */
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

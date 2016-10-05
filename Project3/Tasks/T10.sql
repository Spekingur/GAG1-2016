/* Task 10 
 * Function LoanMoney takes in three parameters - iAID, iAmount and iDueDate.
 * The procedure should give the account a loan of iAmount and also create a bill with the same iAmount and due date
 * of iDueDate. No return value.
 */

create or replace function LoanMoney (
	IN iAID int,
	IN iAmount int,
	IN iDueDate date)
returns void
as
$$
declare
	billPID int;
begin
	/* We check if iAmount is greater than zero since it does not make sense to 
	 * loan an amount of money of zero or less 
	 */
	if iAmount = 0 then
		raise exception 'Can not loan zero amount of money!';
	
	elsif iAmount < 0 then
		raise exception 'Can not loan negative amount of money!';
	
	elsif iAmount > 0 then
		insert into AccountRecords (AID, rDate, rType, rAmount)		-- no insert of balance since we assume that trigger from #5 will add it up for us
		values (iAID, current_date, 'L', iAmount);

		billPID := (select PID from Accounts where AID = iAID);		-- getting the PID for the account in question so we know who get the bill
	
		insert into Bills (PID, bDueDate, bAmount, bIsPaid)		-- trigger from #4 should check if this insert is okay
		values (billPID, iDueDate, iAmount, false);
	end if;
end;
$$
language 'plpgsql';

/* Task 9 
 * Function Transfer, takes in three parameters - iToAID, iFromAID and iAmount.
 * Transfer given amount between the two given accounts in a single transaction.
 * If the amount is not available in the iFromAID account then the operation should be aborted, should happen
 * via trigger from #5. No return value.
 */

 create or replace function Transfer (
	IN iToAID int,
	IN iFromAID int,
	IN iAmount int)
returns void
as
$$
begin
	if iAmount = 0 then		-- making sure you don't transfer zero money
		raise exception 'Can not transfer no money';
	elsif iAmount < 0 then		-- making sure you don't transfer minus money (a reverse transfer)
		raise exception 'Can not transfer minus money';
	elsif iAmount > 0 then
		/* Should be no need to make other checks since trigger from #5 should take care of checking if
		   iAmount is more than exists on given iFromAID account. */
		insert into AccountRecords (AID, rDate, rType, rAmount)		-- We don't insert balance because trigger #5 finds the balance and inserts it
		values 
		(iFromAID, current_date, 'T', -iAmount),			-- iFromAID, transfer iAmount from account
		(iToAID, current_date, 'T', iAmount);			-- iToAID, transfer iAmount to account
	end if;
end;
$$
language 'plpgsql';

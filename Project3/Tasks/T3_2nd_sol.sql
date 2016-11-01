select P.PID, P.pName, O.total, O.unpaid
from People P
join (
    select B.PID as actPID, U.PID as billPID, B.total as total, U.unpaid as unpaid
    from (select pid, sum(aBalance) as total
        from Accounts
        group by pid) B
        full outer join (select pid, sum(bAmount) as unpaid
            from Bills
            where bIsPaid = false
            group by pid) U on U.PID = B.PID) O on O.actPID = P.PID or O.billPID = P.PID;

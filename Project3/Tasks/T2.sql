CREATE VIEW DebtorStatus
AS
SELECT A.pid, P.pname, SUM(A.abalance) AS abalance, SUM(A.aover) AS aover
FROM accounts A
JOIN people P
ON A.pid = P.pid
WHERE A.abalance < 0
GROUP BY A.pid, P.pname
ORDER BY A.pid

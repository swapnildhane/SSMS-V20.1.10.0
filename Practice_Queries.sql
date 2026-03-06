use Practice_Tets

--second highest salary

select top 1 * from 
(select Salary as MaxSalary,DENSE_RANK() over (order by salary desc) as rnk from Employee ) t
where t.rnk = 2

select max(salary) as MaxSalary from employee 
where Salary < (select max(salary) from employee);

select salary as MaxSalary from employee
order by salary desc
offset 1 row fetch next 1 row only


-- Find employee earning same salary 

select e.EmpName,e.Salary from employee e 
join ( 
select salary from Employee 
group by salary
having count(*) > 1 ) d on d.Salary = e.Salary

select salary, count(*) as SameSalaryCount from Employee 
group by Salary
having count(*) > 1

-- Find duplicate employee based on empName + Dept 

select e.EmpName,e.Dept from Employee e
group by e.EmpName,e.Dept
having count(*) > 1

-- Delete duplicate records keep one
with DulicateRecord as
(
select EmpId,count(*) over (partition by dept order by empid desc) as rnk
from Employee 

)
select * from DulicateRecord
-- delete * from duplicateRecord where rnk > 1 

--employees who earn more than their manager

select * from Employee d
left join Employee e on e.ManagerId = d.EmpId 
where d.Salary > e.Salary 

-- heighest salary department wise
select * from
(
select dept,Salary,ROW_NUMBER() over (partition by dept order by salary desc) as rnk from employee
group by dept,salary
) d
where rnk = 1

select Dept, max(salary) from Employee
group by dept

select EmpName,e.Dept,d.salary as MaxSalary from Employee e
join (
select Dept, max(salary) as salary from Employee
group by dept ) d on d.Dept = e.Dept and d.salary = e.Salary
--

-- employee joined in same year
select f.EmpName,d.Years from Employee f 
join (
select year(joindate) as Years from Employee e
group by year(joindate)
having count(*) > 1 ) d on d.years = year(f.JoinDate)

--employee without manager 
select * from Employee e
where e.ManagerId is null

--dept with maximum employees
select top 1 Dept,Count(*) as EmpCount from Employee 
group by Dept 
having count(*) > 1 
order by EmpCount desc

-- Running total of salary 
select EmpName,salary, sum(salary) over (order by empId) as RunningSalary from Employee

--employee with same join date
select EmpName,e.JoinDate from Employee e
join ( 
select JoinDate from Employee 
group by JoinDate
having count(*) > 1 ) d on d.JoinDate = e.joindate 

-- top 2 salaries per department 
select * from (
select Dept,salary,ROW_NUMBER() over (partition by dept order by salary desc) as rnk from Employee) e
where e.rnk <= 2

--employee hired in last two years

select * from Employee
where JoinDate <= dateadd(Y,-2,getdate())

--employee earning less than department avg
with DeptAvg as (
select avg(salary) as AvgSalary,Dept from Employee 
group by dept
)
select * from Employee e
left join DeptAvg d on d.Dept = e.Dept
where e.Salary < d.AvgSalary
		--improved version
select * from (
select *,avg(salary) over (partition by dept ) as AvrSalary from Employee ) t
where Salary < AvrSalary 

--employee reporting to same manager 
with SameManager as (
select ManagerId from Employee e
where ManagerId is not null
group by ManagerId 
having count(*) > 1
)
select * from Employee e 
join SameManager m on m.ManagerId = e.ManagerId
		--imporved version 
		select * from Employee
		where ManagerId in (
		select ManagerId from Employee
		where ManagerId is not null
		group by ManagerId 
		having count(*) > 1
		)


--- duplicate salaries but with employee name
with DplctSal as (
select Salary from Employee
group by salary		
having count(*) > 1
)
select EmpName,e.Salary from Employee e
join DplctSal d on d.Salary = e.Salary 


		-- improved version
select * from (
select *,count(*) over (partition by salary) cnt from Employee
) t 
where t.cnt > 1 


--highest paid employee overall
select top 1 EmpName,Salary from Employee e
order by Salary desc

           --- imporve verion
select * from Employee 
where Salary = ( select max(salary) from Employee) 

-- Total amount per account 
SELECT a.AccountId, a.CustomerName,
       SUM(CASE WHEN t.TranType = 'Credit' THEN t.Amount ELSE -t.Amount END) AS NetAmount
FROM Account a
JOIN Transactions t ON a.AccountId = t.AccountId
GROUP BY a.AccountId, a.CustomerName;


--Customer with branch name 
select CustomerName,BranchName from Branch b
inner join Customer c on c.BranchId = b.BranchId

--total balance per branch
select b.BranchName,sum(a.balance) as Balance from Branch b
inner join Customer c on c.BranchId = b.BranchId
inner join Account_01 a on a.CustomerId = c.CustomerId
group by b.BranchName

--customer having more than one transaction
select CustomerName,Count(*) as TotalTransactions from Customer c
inner join Account_01 a on a.CustomerId = c.CustomerId
inner join Transactions_01 t on t.AccountId = a.AccountId
group by CustomerName
having count(*) > 1

--duplicate transaction ( Amount + Date )
select Amount,TranDate from Transactions_01
group by Amount,TranDate
having count(*) > 1

--latest transaction per account 
with cte as (
select *, ROW_NUMBER() over (partition by accountId order by trandate desc) rnk from Transactions_01
) 
select * from cte 
where rnk = 1

--running balance per account 
select AccountId,TranDate,amount,
sum(case when TranType='Credit' then Amount else -Amount end) over (partition by AccountId order by trandate desc)
as Balance
from Transactions_01


--account where debit> credit 

with cte as (
select AccountId,sum(case when TranType='Credit' then Amount else 0 end) as TotalCredt,
sum(case when TranType='Debit' then Amount else 0 end) as TotalDebit
from Transactions_01 
group by AccountId
)
select * from cte 
where totaldebit > TotalCredt

--branch with heighest debit amount 

select BranchName,max(t.Amount) as TotalDebit from Branch b
inner join Customer c on c.BranchId = b.BranchId
inner join Account_01 a on a.CustomerId = a.CustomerId
inner join Transactions t on t.AccountId = a.AccountId
where t.TranType='Debit' 
group by BranchName
order by TotalDebit desc

-- 
SELECT AccountId,
       month(TranDate) AS Month,
       SUM(Amount) AS MonthlyTotal,
       SUM(SUM(Amount)) OVER (PARTITION BY AccountId ORDER BY month(TranDate)) AS RunningTotal
FROM Transactions
GROUP BY AccountId, month(TranDate);


--table accounts and Transactions_02

--find all customer with saving account
select * 
from Accounts 
where AccountType = 'Savings'

--show the total balance accross all the amount 
select sum(balance) as TotalBalance 
from Accounts

--find the customer with hieghest balance 
select top 1 CustomerName,balance 
from accounts 
order by balance desc 

select CustomerName,Balance from (
select CustomerName,Balance,DENSE_RANK() over (order by balance desc) as rnk from Accounts ) t
where t.rnk = 1

--how many accounts in each branch 
select Branch, count(*) as AccountCount from Accounts
group by Branch

-- customer with less than 20000 balance 
select CustomerName from Accounts
where Balance < 20000


select * from Accounts
select * from Transactions_02

--all customer with current account 
select CustomerName from Accounts
where AccountType = 'Current'

--average balance of saving accounts
select avg(balance) as AverageBalance from accounts
where AccountType = 'Savings'

--all account of mumbai branch
select * from Accounts
where Branch = 'Mumbai'

--total deposits of fixed deposit 
select Sum(balance) as FD from Accounts
where AccountType = 'Fixed Deposit'

--no. of customer per account
select AccountID,Count(*) as NoOfCustomer from Accounts
group by AccountID

--all transactions with customer
select * from Transactions_02 t
join Accounts a on a.AccountID = t.AccountID


--customer who made debit transaction 
select * from Accounts a 
join Transactions_02 t on t.AccountID = a.AccountID
where TxnType = 'debit'

-- find customer with balance greater than average balance 
select CustomerName,balance from Accounts a 
where Balance > (select avg(balance) from Accounts )

--customer who made transaction above 10k
select CustomerName 
from Accounts a
join Transactions_02 t on t.AccountID = a.AccountID
where t.Amount > 10000
			--Sub query
select CustomerName 
from Accounts where AccountID in (select AccountID from Transactions_02 where Amount > 10000)

--show top 3 customer by balance 
select CustomerName,Balance from (
select CustomerName,Balance,Row_number() over (order by balance desc) as rnk from Accounts ) t
where rnk <= 3

select CustomerName,Balance 
from Accounts 
order by Balance desc
offset 0 row fetch next 3 row only 

-- branch with maximum total balance 
select top 1 branch,sum(balance) as TotalBalance from Accounts
group by branch
order by TotalBalance desc

--net transaction amount per customer 
select CustomerName,sum(case when t.TxnType = 'Credit' then amount else -Amount end) as NetAmoutn from Accounts a
join Transactions_02 t on t.AccountID = a.AccountID
group by CustomerName


--rank customer with balance withing each branch
select CustomerName,Balance,Branch,Rank() over (partition by Branch order by balance desc) as rnk from Accounts

--Find cumulative transaction amount per cutomer 
select a.CustomerName,t.TxnDate,t.Amount,
sum(t.amount) over (partition by t.accountId order by t.txndate desc ) as Runningamount 
from Accounts a
join Transactions_02 t on t.AccountID = a.AccountID

--classify account as high value if balance > 50,000
select 
CustomerName,Balance,
case when Balance > 50000 then 'High Value' else 'Regular' end as Claissify
from Accounts 


--find transaction made in feb 2026 
select * from  Transactions_02 
where month(txndate) = 2 and year(txndate) = 2026

--find customer with no transaction 
select * from Accounts 
where AccountID not in (select t.AccountID from Transactions_02 t 
inner join Accounts a on a.AccountID = t.AccountID) 

--casting 
select cast(balance as decimal(18,1)) as Balance from accounts

--substring 
select SUBSTRING(customername,1,5) as NickName from Accounts

--round off amount 
select round(balance,2) as RoundAmount from Accounts --not working 

--replace
select replace(balance,'.','') as Replacedata from Accounts




	





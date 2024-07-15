--db
create database analysis

use analysis

--loaded the data by database->task>import flatfile
select top 5 * from Employee_Salaries

select count(*) as no_of_records from Employee_Salaries

select round(sum(Salary),2) as total_salary from Employee_Salaries

--salary discrepancies analysis across each departments

select distinct(Department) from Employee_Salaries

with dept_sal as (
select Department,sum(salary) as dept_revenue from Employee_Salaries group by Department)
select top 10 * from dept_sal order by dept_revenue desc

--hueing by flsa_status
select FLSA_Status,count(*) as Count , sum(salary) as salary from Employee_Salaries group by FLSA_Status

--department wise segregating department division by maximum salary
with dd as (
select  department,Department_Division,count(*) as Count , sum(salary) as salary from Employee_Salaries group by department,Department_Division )
select Department,max(salary) as max into #temp from dd group by department

select * from #temp
with dd as (
select  department,Department_Division,count(*) as Count , sum(salary) as salary from Employee_Salaries group by department,Department_Division )
select d.department,d.Department_Division,d.Count ,d.salary from dd d
join #temp t on d.salary=t.max

select top 5 * from employee_salaries
--cte starts
--calculating no of outliers in each departments along with co efficient of variation
with 
prereq as(
select department,round(avg(salary),2) as average,round(STDEV(salary),2) as standard_deviation,round(stdev(salary)/avg(salary),2) as Co_variation from Employee_Salaries group by department
), final as(
select r.department,average,standard_deviation,Co_variation,(t.salary-r.average)/r.standard_deviation as z_score from prereq r
join Employee_Salaries t on r.department =t.department)
-- in Z normal distribution data points lies outside the boundaries (-1.96,+1.96) are considered as outlier at 5% significance level ! 
select department,round(avg(co_variation),2)*100 as coefficient_variation,sum(
case 
when z_score >1.96 or z_score<-1.96 then 1
else 0
end)
as isOutlier into #final_temp from final group by department

--cte ends

--TOP 5 Salary discrepencies across each departments by Count of Ouliers...
select top 5 * from #final_temp order by isOutlier desc
--TOP 5 Salary discrepencies across each departments by Co-efficient of variation which measures how salaries were spread across deprtments...

select top 5 * from #final_temp order by coefficient_variation desc

--PAR dept has more salary differences comparing to others having higher outlier count and more co efficient of variation score




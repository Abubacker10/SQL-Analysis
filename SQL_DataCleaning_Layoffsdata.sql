
--Data Cleaning

--1.Removing Duplicates
--2.Standardizing the Variables
--3.Dealing with Null Values
--4.Removing unwanted cols

--1)..



select * from layoffs;

--copying
select * into layoffs1 from layoffs

--looking cols
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'layoffs1'

with delcte as(
select *,row_number() over (partition by company,
location,
industry,
total_laid_off,
percentage_laid_off,
date,
stage,
country,
funds_raised_millions order by company) as row_number from layoffs1
)
--deleting duplicates
delete from delcte where row_number>1;

select count(*) as no_unique from (select distinct * from layoffs1) as wod

--2.) standardize
select distinct(country) from layoffs1 order by country


--let's write function for cleaning..
create function cleantext(@input varchar(50))
returns varchar(50)
as
begin 
declare @output varchar(50)
set @output = @input
set @output = replace(@output,'#','')
set @output = replace(@output,'&','')
set @output = replace(@output,'.','')
set @output = LTRIM(RTRIM(@output));

    return @output;
end;

select distinct(dbo.cleantext(country)) from layoffs1

update layoffs1 set country = dbo.cleantext(country)

select distinct(industry) from layoffs1 order by industry
--crypto industry has some errs

select distinct(industry) from layoffs1 where industry like 'Crypto%'

update layoffs1 set industry = 'Crypto' where industry like 'Crypto%';

select distinct(location) from layoffs1 order by location

select convert(date,date,101) from layoffs1

select * from layoffs1 where industry is NULL

select * from layoffs1 where company = 'Airbnb'

--to join & update the exiting industry information

select * from layoffs1 l
inner join layoffs1 o on l.company=o.company where o.industry is not NULL and l.industry is null

update l1
set l1.industry = l2.industry
from layoffs1 l1
join layoffs1 l2 on l1.company = l2.company
where l1.industry IS NULL AND l2.industry IS NOT NULL

--done



select * from layoffs1 where percentage_laid_off  is null  and total_laid_off is null  

--droping null values
--we can do eda if any (percentage_laid_off ,total_laid_off) has a Value
select count(*) from layoffs1 where percentage_laid_off  is null and total_laid_off is null  

delete from layoffs1 where percentage_laid_off  is null and total_laid_off is null

select top 10 * from layoffs1

--end.

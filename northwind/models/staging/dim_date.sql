with recursive date_range as (
    select date '1996-01-01' as date
    union all
    select date + 1
    from date_range
    where date + 1 <= current_date
)

, holidays as (
    select date '2024-01-01' as holiday_date,
    'New Year (US)' as holiday_name

    union all
    
    select date '2024-07-04',
    'Independence Day'
    
    union all
    
    select date '2024-12-25',
    'Christmas (UK)'

)

select 
    row_number() over (order by date) as date_id,
    date,
    extract(year from date) as year,
    extract(month from date) as month,
    extract(day from date) as day,
    extract(quarter from date) as quarter,
    case when holiday_date is not null then 1 else 0 end as is_holiday
from date_range
left join holidays on date_range.date = holidays.holiday_date
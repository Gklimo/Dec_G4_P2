# Dec_G4_P2
Data Engineering Project 2


#### Questions to be answered
What are the total product sales by year, quarter, and month, seasonality?
Which products are the top sellers?
What is the average order size and value?
Which customers are top buyers?
How do sales vary by region or territory?
Which employees generate the most sales?
What is the average number of orders handled by each employee?
What is the average time from order placement to shipment?
What is the average shipping time by shipper and destination?


### Custom config already inside the northwind


# Dec_G4_P2

Data Engineering Project 2

# Installation

Clone northwind repository from https://github.com/pthom/northwind_psql

# Run docker-compose

Run docker-compose up

# Run psql client:

docker-compose exec db psql -U postgres -d northwind

# Connect PgAdmin

Access to PgAdmin at the url: http://localhost:5050

Add a new server in PgAdmin:

General Tab:

Name = db

Connection Tab:

Host name: db

Username: postgres

Password: postgres

Then, select database "northwind".

Postgress ? PGadmin opnieuw

https://github.com/Data-Engineer-Camp/2023-12-bootcamp/tree/main/00-pre-work/3-install-postgresql

Instructions

Do I have to connect docker with postgres/pgadmin? Or how to do that? 

Install version 15 or 14?

What with postgres app? It didn’t show up

https://github.com/Data-Engineer-Camp/2023-12-bootcamp/blob/main/06-snowflake-dbt/3/01-evr-dbt-setup/solved/warehouse/profiles.yml

1) new docker

conda activate py-etl                                                                                                        

docker run -p 5433:5432 -e POSTGRES_PASSWORD=postgres -v my-postgres:/var/lib/postgresql/data --name my-postgres -d postgres:14

2) new airbyte

`git clone --depth=1 https://github.com/airbytehq/airbyte.git`

```

# navigate to the airbyte directory

cd airbyte

# start airbyte

./run-ab-platform.sh

```

3) Installing database locally in postgres 

https://github.com/pthom/northwind_psql/blob/master/northwind.sql

4) create connection with postgres in airbyte using cdc 

https://github.com/Data-Engineer-Camp/2023-12-bootcamp/tree/main/05-airbyte/1/04-evr-cdc-sync/instruction

docker exec -it 9ea4f1691b39 /bin/bash

docker-compose exec /bin/bash

cd /var/lib/postgresql/data

cat postgresql.conf

```

echo '# Replication

wal_level = logical

max_wal_senders = 1

max_replication_slots = 1

' >> postgresql.conf

```



#### Connect to docker before running sql commands:

## Docker commands:


docker-compose exec db psql -U postgres -d northwind


### Sql commands to run 

ALTER USER postgres REPLICATION;

SELECT pg_create_logical_replication_slot('airbyte_slot', 'pgoutput');

ALTER TABLE categories REPLICA IDENTITY DEFAULT;

ALTER TABLE customer_customer_demo REPLICA IDENTITY DEFAULT;

ALTER TABLE customer_demographics REPLICA IDENTITY DEFAULT;

ALTER TABLE customers REPLICA IDENTITY DEFAULT;

ALTER TABLE employee_territories REPLICA IDENTITY DEFAULT;

ALTER TABLE employees REPLICA IDENTITY DEFAULT;

ALTER TABLE order_details REPLICA IDENTITY DEFAULT;

ALTER TABLE orders REPLICA IDENTITY DEFAULT;

ALTER TABLE products REPLICA IDENTITY DEFAULT;ALTER TABLE region REPLICA IDENTITY DEFAULT;

ALTER TABLE shippers REPLICA IDENTITY DEFAULT;

ALTER TABLE suppliers REPLICA IDENTITY DEFAULT;

ALTER TABLE territories REPLICA IDENTITY DEFAULT;

ALTER TABLE us_states REPLICA IDENTITY DEFAULT;

CREATE PUBLICATION airbyte_publication FOR TABLE categories,customer_customer_demo,customer_demographics,customers,employee_territories,employees,order_details,orders,products,region,shippers,suppliers,territories,us_states;

############## 

Host: host.docker.internal
Port: 55432 , from the nortwind port
Database : northwind
username : postgres
password : postgres
Replication Slot : airbyte_slot
Publication: airbyte_publication


### To check if the CDC was implemented, run this in the docker container made by docker compose up

###################################
SELECT * FROM pg_publication;


SELECT * FROM pg_replication_slots;


################### Facts and Dimensions
### Fact Table - Sales Facts

**FactSales**
- `SalesID` (PK)
- `OrderID` (FK to DimOrder)
- `ProductID` (FK to DimProduct)
- `EmployeeID` (FK to DimEmployee)
- `CustomerID` (FK to DimCustomer)
- `ShipperID` (FK to DimShipper)
- `OrderDateKey` (FK to DimDate)
- `QuantityOrdered`
- `UnitPrice`
- `Discount`
- `TotalPrice` (calculated as `QuantityOrdered` * `UnitPrice` * (1 - `Discount`))
- `Freight`

This fact table will allow for the calculation of total product sales by time periods and other aggregations necessary for your analysis.

### Dimension Tables

**DimDate** (SCD Type 2)
- `DateKey` (PK)
- `Date`
- `Year`
- `Quarter`
- `Month`
- `Day`
- `Week`
- `Season`
- `IsCurrent` (flag to identify the current record for SCD Type 2)

**DimProduct** (SCD Type 2)
- `ProductKey` (PK)
- `ProductID`
- `ProductName`
- `SupplierID`
- `CategoryID`
- `QuantityPerUnit`
- `UnitPrice`
- `UnitsInStock`
- `UnitsOnOrder`
- `ReorderLevel`
- `Discontinued`
- `EffectiveDate`
- `EndDate`
- `IsCurrent`

**DimCustomer** (SCD Type 2)
- `CustomerKey` (PK)
- `CustomerID`
- `CompanyName`
- `ContactName`
- `ContactTitle`
- `Address`
- `City`
- `Region`
- `PostalCode`
- `Country`
- `Phone`
- `Fax`
- `EffectiveDate`
- `EndDate`
- `IsCurrent`

**DimEmployee**
- `EmployeeKey` (PK)
- `EmployeeID`
- `LastName`
- `FirstName`
- `Title`
- `TitleOfCourtesy`
- `BirthDate`
- `HireDate`
- `Address`
- `City`
- `Region`
- `PostalCode`
- `Country`
- `HomePhone`
- `Extension`
- `Photo`
- `Notes`
- `ReportsTo`

![image](https://github.com/Gklimo/Dec_G4_P2/assets/84771383/bf660418-949c-4d48-bffe-a07a5f21d172)


# Dec_G4_P2
Data Engineering Project 2

Presentation: https://docs.google.com/presentation/d/1-SHfCdRcbhU8BWSx0WzQUuK0KAm3HxcBE9l7FtbH4f0/edit#slide=id.g2bf6abc1ace_1_59
#### Questions to be answered


- What are the total product sales by year, quarter, and month, seasonality?
- Which products are the top sellers?
- What is the average order size and value?
- Which customers are top buyers?
- How do sales vary by region or territory?
- Which employees generate the most sales?
- What is the average number of orders handled by each employee?
- What is the average time from order placement to shipment?
- What is the average shipping time by shipper and destination?


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

############## Set up airbyte source from Postgres

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



# DBT & Snowflake
establish a connection with Airbyte to your Snowflake database (instructions to follow)
run command `dbt deps` to download and install packages into your dbt project
run command `dbt build` to create tables in your Snowflake database

################### Facts and Dimensions Documentation
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

![image](https://github.com/Gklimo/Dec_G4_P2/assets/84771383/aae31783-7838-408c-b34e-37a3a9bd10a2)

Airbyte Connection Setup Guide:

This guide provides detailed instructions on setting up an EC2 instance for Airbyte, configuring security settings, and installing Docker and Airbyte.
Prerequisites

    AWS account
    Basic understanding of EC2, Docker, and Airbyte

Step 1: Create an EC2 Instance

    Launch an EC2 Instance:
        Choose the t2.medium instance type.
        Allocate 10 GB of storage.
        Select AWS Linux as the machine image.

    Create and Assign a Role:
        Create a new IAM role that grants access to EC2SSHKEY.
        Attach this role to your EC2 instance.

    Configure Security Group:
        Add an SSH rule (TCP port 22) to allow SSH connections from your local machine.
        Add a Custom TCP rule (TCP port 8000) to allow connections to Airbyte.

Step 2: Connect to Your Instance

    Navigate to the Connections section of your EC2 instance.
    Follow the provided SSH instructions to connect from your local machine.

Step 3: Install Docker

Run the following commands on your EC2 instance to install Docker and fix potential issues related to docker compose up:

```
sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker $USER
DOCKER_CONFIG=/usr/local/lib/docker
mkdir -p $DOCKER_CONFIG/cli-plugins
sudo curl -SL https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
sudo chmod o+w /usr/local/lib/docker/cli-plugins
sudo chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
docker compose version
sudo usermod -aG docker $USER

```
Step 4: Install Airbyte

Execute these commands to download and run Airbyte:

```
mkdir airbyte && cd airbyte
wget https://raw.githubusercontent.com/airbytehq/airbyte/master/run-ab-platform.sh
chmod +x run-ab-platform.sh
sudo ./run-ab-platform.sh -b

```
After the installation, you should be able to start Airbyte with:


```
sudo ./run-ab-platform.sh -b

```

Step 5: Access Airbyte

    Retrieve the IPv4 Public IP of your instance from the EC2 dashboard.
    Access Airbyte by navigating to http://<Your-IPv4-Public-IP>:8000/ in your web browser.

Default Credentials

    Username: airbyte
    Password: password


Airbyte Postgres CDC setup:
<img width="593" alt="firefox_hyHMWUgK4x" src="https://github.com/Gklimo/Dec_G4_P2/assets/145110891/148445c3-b8e3-40cf-ac7f-570bdadd5f8e">

Airbyte connector with postgres cdc
<img width="960" alt="firefox_z590R0rJLS" src="https://github.com/Gklimo/Dec_G4_P2/assets/145110891/6f2a8d21-72bb-4d60-bf82-0f7147a8ce3d">

Airbyte syncing through curl in ec2, from postgres to snowflake
<img width="436" alt="Code_QkiMePD5HQ" src="https://github.com/Gklimo/Dec_G4_P2/assets/145110891/e5ce8135-02e8-4d9d-880f-b476035c0983">

Task Running in Fargate cluster, through EC2 instance:


In aws: 
<img width="836" alt="firefox_EsqTmWasid" src="https://github.com/Gklimo/Dec_G4_P2/assets/145110891/2561be6f-7e1f-4a3c-a3c5-e3b816fbd152">



Pipeline (command line) running airbyte
<img width="733" alt="Code_iYLVHfVyhf" src="https://github.com/Gklimo/Dec_G4_P2/assets/145110891/aac4d59c-70d5-4a4e-9de0-755396fb4141">

Airbyte showing the sync:
<img width="960" alt="firefox_73rccZgxUD" src="https://github.com/Gklimo/Dec_G4_P2/assets/145110891/1d84ee77-7315-49a0-8c84-badeab04f09d">

Airbyte + Fargate task:
<img width="315" alt="bA05tdPbTC" src="https://github.com/Gklimo/Dec_G4_P2/assets/145110891/fb07e874-9a75-4c4f-8779-362773e0d07e">



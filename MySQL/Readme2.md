MySQL Project Guide: Docker-Based Deployment, SQL Setup, Python Access, and dbt Integration

This guide focuses on building and running a MySQL environment entirely in Docker — from container setup to Python access and dbt transformation.

1. Run MySQL with Docker

📦 Create the container (with local-infile enabled)

First, create a config file MySQL/my.cnf:

[mysqld]
local-infile=1

Then run the Docker container:

docker rm -f mysql-app

docker run --name mysql-app \
  -e MYSQL_ROOT_PASSWORD=dbpassword \
  -v $PWD:/repo \
  -v $PWD/MySQL/my.cnf:/etc/mysql/conf.d/my.cnf \
  -p 3306:3306 \
  -d mysql:8

This mounts your repo inside the container as /repo and makes MySQL accessible on port 3306.

2. Execute SQL Scripts Inside the Container

📁 Copy and run SQL files

a. Create database + tables

docker cp schema/create_tables.sql mysql-app:/tmp/create_tables.sql
docker exec -it mysql-app mysql -u root -p --local-infile=1 -e "SOURCE /tmp/create_tables.sql"

b. Create users

docker cp MySQL/users.sql mysql-app:/tmp/users.sql
docker exec -it mysql-app mysql -u root -p --local-infile=1 -e "SOURCE /tmp/users.sql"

c. Load CSV data

First, copy your file:

docker cp data/users.csv mysql-app:/repo/data/users.csv

Then copy the SQL and execute it:

docker cp MySQL/loadLocalFile.sql mysql-app:/tmp/loadLocalFile.sql
docker exec -it mysql-app mysql -u root -p --local-infile=1 -e "SOURCE /tmp/loadLocalFile.sql"

📝 Example: loadLocalFile.sql

USE social_app;
LOAD DATA LOCAL INFILE '/repo/data/users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

3. Connect with Python

Install connector (if needed)

pip install mysql-connector-python

Example script

import mysql.connector

conn = mysql.connector.connect(
    host='127.0.0.1',
    port=3306,
    user='appuser',
    password='securepassword',
    database='social_app'
)
cursor = conn.cursor()
cursor.execute("SELECT * FROM users")
for row in cursor.fetchall():
    print(row)
conn.close()

4. Use dbt with MySQL

📦 Step 1: Install dbt for MySQL

pip install dbt-mysql

📁 Step 2: Initialize your dbt project

We recommend initializing dbt inside your MySQL folder to keep each subject isolated:

cd MySQL
dbt init dbt

Create or edit your profiles.yml file manually inside your home directory (~/.dbt/profiles.yml). This file is not part of the repo:

dbt:
  target: dev
  outputs:
    dev:
      type: mysql
      server: 127.0.0.1
      port: 3306
      user: appuser
      password: securepassword
      schema: social_app
      threads: 1

⚙️ Step 3: Configure dbt_project.yml

Inside MySQL/dbt/dbt_project.yml, make sure it includes the following:

dbt_project.yml
name: dbt
version: '1.0'
profile: dbt

config-version: 2

source-paths: ["models"]
analysis-paths: ["analysis"]
test-paths: ["tests"]
data-paths: ["data"]
macro-paths: ["macros"]
target-path: "target"
clean-targets: ["target", "dbt_modules"]

This connects the dbt project named dbt to the dbt profile block in ~/.dbt/profiles.yml.

You can now begin creating models inside the models/ folder.

🧱 Step 4: Create a model

Inside models/first_model.sql:

SELECT username, email FROM users WHERE email LIKE '%@gmail.com';

Then run:

dbt run

5. Recommended Folder Structure

After these changes, the recommended structure is:

DATA_ENG/
├── data/
│   └── users.csv
├── MySQL/
│   ├── dbt/
│   │   ├── models/
│   │   ├── dbt_project.yml
├── MySQL/
│   ├── users.sql
│   ├── loadLocalFile.sql
│   └── my.cnf
├── schema/
│   └── create_tables.sql
├── python/
│   └── access_mysql.py
├── README.md


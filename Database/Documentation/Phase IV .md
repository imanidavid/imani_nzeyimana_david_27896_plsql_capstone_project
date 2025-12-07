## Phase IV – Database Creation & Environment Setup

This phase prepares the Oracle environment for the Profit Margin Monitoring System.  
All scripts are located under `/sql`.

### ✔ 1. PDB Creation
The PDB name (`MON_27896_DAVID_PROFITMARGIN_DB`).  
Script provided: `create_pdb.sql`  

CREATE PLUGGABLE DATABASE mon_27896_David_ProfitMargin_db
ADMIN USER david IDENTIFIED BY david
FILE_NAME_CONVERT = ('C:\APP\ORADATA\ORCL\PDBSEED\', 
                     'C:\APP\ORADATA\ORCL\MON_27896_DAVID_PROFITMARGIN_DB\');

ALTER PLUGGABLE DATABASE MON_27896_DAVID_PROFITMARGIN_DB SAVE STATE;

### ✔ 2. Tablespace Setup
A dedicated tablespace was created:

- Name: `MARGIN_TBS`
- Purpose: Stores all project data objects
- Script: `tablespaces.sql`

CREATE TABLESPACE margin_tbs
  DATAFILE 'C:\APP\ORADATA\ORCL\MON_27896_DAVID_PROFITMARGIN_DB\margin_tbs01.dbf'
  SIZE 100M
  AUTOEXTEND ON NEXT 10M
  MAXSIZE UNLIMITED;


### ✔ 3. Schema User Setup
A restricted schema user was created to hold all application tables and PL/SQL code.

- Username: `margin_user`
- Default tablespace: `MARGIN_TBS`
- Script: `user_setup.sql`
- Granted privileges: create session, tables, views, sequences, triggers, procedures

-- Creates the schema user:

CREATE USER MARGIN_USER IDENTIFIED BY margin_user
  DEFAULT TABLESPACE MARGIN_TBS
  QUOTA UNLIMITED ON MARGIN_TBS;


-- Grants the basic privileges required for this project:

GRANT CREATE SESSION,
      CREATE TABLE,
      CREATE VIEW,
      CREATE SEQUENCE,
      CREATE PROCEDURE,
      CREATE TRIGGER
TO MARGIN_USER;


### ✔ 4. Project Structure
The repository is organized into documentation, SQL scripts, and reporting assets.  
See `project_structure.md` for details.
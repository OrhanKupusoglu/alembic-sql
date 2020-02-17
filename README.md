# alembic-sql

## Alembic

[Alembic](https://pypi.org/project/alembic/) is a database migration tool written in Python.

[Database migration](https://en.wikipedia.org/wiki/Schema_migration) is a special kind of [version control](https://en.wikipedia.org/wiki/Version_control) system:
> In software engineering, schema migration (also database migration, database change management) refers to the management of incremental, reversible changes and version control to relational database schemas. A schema migration is performed on a database whenever it is necessary to update or revert that database's schema to some newer or older version.

**Alembic** is created by [Mike Bayer](https://twitter.com/zzzeek), author of the popular [SQLAlchemy](http://www.sqlalchemy.org/) Database Toolkit for Python.
[Alembic's documentation](https://alembic.sqlalchemy.org/en/latest/) gives a good overview about its capabilities.

Alembic uses Python to manage a given database. This repository is a small shell around Alembic to use actual [SQL DDL](https://en.wikipedia.org/wiki/Data_definition_language) commands instead of Python with SQLAlchemy for the management of a database.

&nbsp;

## Databases

The scripts currently support only [PostgreSQL](https://en.wikipedia.org/wiki/PostgreSQL) Relational DataBase Management System (RDBMS):

&nbsp;

## Python Environment
Two widely-known Python projects are required:

- [pip](https://pypi.org/project/pip/) &mdash; pip is the package installer for Python.

- [Virtualenv](https://pypi.org/project/virtualenv/) &mdash;  a tool for creating isolated virtual python environments.

One of the many ways to install **pip** is by downloading a Python script:

```
$ wget https://bootstrap.pypa.io/get-pip.py

$ sudo python get-pip.py
```

Upgrade **pip** and install **Virtualenv**:

```
$ sudo pip install --upgrade pip

$ sudo pip install virtualenv
```

&nbsp;

## Initialize a Virtual Environment

A requirements file is a list of libraries and versions.
**pip** will install this list.

```
$ cat requirements.txt
alembic==1.4.0
Mako==1.1.1
MarkupSafe==1.1.1
psycopg2==2.8.4
python-dateutil==2.8.1
python-editor==1.0.4
six==1.14.0
SQLAlchemy==1.3.13

```

A virtual environment can be quickly initialized by the supplied shell script [init_venv.sh](./init_venv.sh).

```
$ ./init_venv.sh help
usage: ./init_venv.sh
       + if missing, creates a virtual environment '.venv'.
       + activates the virtual environment
       + installs all the requirements either for PostgreSQL or MySQL
       + if missing, creates a Python path configuration file
       + deactivates the virtual environment

$ ./init_venv.sh
+++ virtual environment
Running virtualenv with interpreter /usr/bin/python3
Already using interpreter /usr/bin/python3
Using base prefix '/usr'
New python executable in /home/orhanku/dev/alembic-sql/.venv/bin/python3
Also creating executable in /home/orhanku/dev/alembic-sql/.venv/bin/python
Installing setuptools, pip, wheel...
done.
 - created: .venv

Processing /home/orhanku/.cache/pip/wheels/54/88/28/d771a55dfb3c62af8b3358c60f8034edcb5c9a57d44a9024cf/alembic-1.4.0-py2.py3-none-any.whl
Processing /home/orhanku/.cache/pip/wheels/43/b1/7c/f14ef20f4683e5087ae684c6447194e09695315f20b9c45575/Mako-1.1.1-py3-none-any.whl
Collecting MarkupSafe==1.1.1
  Using cached MarkupSafe-1.1.1-cp36-cp36m-manylinux1_x86_64.whl (27 kB)
Processing /home/orhanku/.cache/pip/wheels/1e/cb/03/20479d63812e4a01da92afa8753f6ad37f87806c24a620aaa0/psycopg2-2.8.4-cp36-cp36m-linux_x86_64.whl
Collecting python-dateutil==2.8.1
  Using cached python_dateutil-2.8.1-py2.py3-none-any.whl (227 kB)
Collecting python-editor==1.0.4
  Using cached python_editor-1.0.4-py3-none-any.whl (4.9 kB)
Collecting six==1.14.0
  Using cached six-1.14.0-py2.py3-none-any.whl (10 kB)
Processing /home/orhanku/.cache/pip/wheels/28/3e/f9/8eca04781258bb6956ffba37e4e6e6951e5b3a16d4494b91cb/SQLAlchemy-1.3.13-cp36-cp36m-linux_x86_64.whl
Installing collected packages: MarkupSafe, Mako, python-editor, SQLAlchemy, six, python-dateutil, alembic, psycopg2
Successfully installed Mako-1.1.1 MarkupSafe-1.1.1 SQLAlchemy-1.3.13 alembic-1.4.0 psycopg2-2.8.4 python-dateutil-2.8.1 python-editor-1.0.4 six-1.14.0

+++ path configuration file - created: alembic-sql.pth

$ ./init_venv.sh
+++ virtual environment - exists: .venv
+++ path configuration file - exists: alembic-sql.pth

```

You can check whether Alembic is ready by first activating the virtual environment.  Notice that the prompt displays the virtual environment's name.

```
$ source .venv/bin/activate

(.venv) $ alembic list_templates
Available templates:

generic - Generic single-database configuration.
multidb - Rudimentary multi-database configuration.
pylons - Configuration that reads from a Pylons project environment.

Templates are used via the 'init' command, e.g.:

  alembic init --template generic ./scripts

(.venv) $ deactivate
```

&nbsp;

## Initialize an Alembic Instance

An Alembic instance can be quickly initialized by the supplied shell script [init_database.sh](./init_database.sh).

```
$ ./init_database.sh help
usage: ./init_database.sh <database directory> <database name>
                           --absolute path--
       + activates the virtual environment '.venv'
       + creates at the absolute path to the <database directory> a directory named <database name>
       + initializes in the <database name> directory a customized Alembic instance
       + the configuration file's 'sqlalchemy.url' parameter must point to the actual database
       + deactivates the virtual environment

$ ./init_database.sh ~/databases testdb
+++ database directory: /home/orhanku/databases
+++ path to database directory is absolute
+++ database name: testdb
+++ virtual environment: .venv - activated
  Creating directory /home/orhanku/databases/testdb/testdb ...  done
  Creating directory /home/orhanku/databases/testdb/testdb/versions ...  done
  Generating /home/orhanku/databases/testdb/testdb/script.py.mako ...  done
  Generating /home/orhanku/databases/testdb/testdb/README ...  done
  Generating /home/orhanku/databases/testdb/alembic.ini ...  done
  Generating /home/orhanku/databases/testdb/testdb/env.py ...  done
  Please edit configuration/connection/logging settings in '/home/orhanku/databases/testdb/alembic.ini' before proceeding.

!!! ATTENTION: the configuration file's 'sqlalchemy.url' parameter must point to the actual database with username & password

  postgresql://postgres:123456@127.0.0.1:5432/testdb

```

&nbsp;


## Configuration

The configuration file is called **alembic.ini**.
First activate the virtual environment, then cd to the working directory.

```
$ source .venv/bin/activate

(.venv) $ cd ~/databases/testdb

(.venv) $ ls
alembic.ini  alembic.ini.orig  testdb

(.venv) $ cat alembic.ini
# A generic, single database configuration.

[alembic]
# path to migration scripts
script_location = testdb

# template used to generate migration files
# file_template = %%(rev)s_%%(slug)s

# timezone to use when rendering the date
# within the migration file as well as the filename.
# string value is passed to dateutil.tz.gettz()
# leave blank for localtime
# timezone =

# max length of characters to apply to the
# "slug" field
# truncate_slug_length = 40

# set to 'true' to run the environment during
# the 'revision' command, regardless of autogenerate
# revision_environment = false

# set to 'true' to allow .pyc and .pyo files without
# a source .py file to be detected as revisions in the
# versions/ directory
# sourceless = false

# version location specification; this defaults
# to testdb/versions.  When using multiple version
# directories, initial revisions must be specified with --version-path
# version_locations = %(here)s/bar %(here)s/bat testdb/versions

# the output encoding used when revision files
# are written from script.py.mako
# output_encoding = utf-8

sqlalchemy.url = postgresql://postgres:123456@127.0.0.1:5432/testdb

[alembic-sql]
downgrade_enabled = False


[post_write_hooks]
# post_write_hooks defines scripts or Python functions that are run
# on newly generated revision scripts.  See the documentation for further
# detail and examples

# format using "black" - use the console_scripts runner, against the "black" entrypoint
# hooks=black
# black.type=console_scripts
# black.entrypoint=black
# black.options=-l 79

# Logging configuration
[loggers]
keys = root,sqlalchemy,alembic

[handlers]
keys = console

[formatters]
keys = generic

[logger_root]
level = WARN
handlers = console
qualname =

[logger_sqlalchemy]
level = WARN
handlers =
qualname = sqlalchemy.engine

[logger_alembic]
level = INFO
handlers =
qualname = alembic

[handler_console]
class = StreamHandler
args = (sys.stderr,)
level = NOTSET
formatter = generic

[formatter_generic]
format = %(levelname)-5.5s [%(name)s] %(message)s
datefmt = %H:%M:%S
```

### URL to the database

The connection to the database is entered with the **sqlalchemy.url** parameter.

	sqlalchemy.url = postgresql://postgres:123456@127.0.0.1:5432/testdb


### Downgrade Enabled

Downgrade can be enabled or disabled by the boolean **custom.downgrade_enabled** parameter.

Since downgrade can cause data loss, it is by default disabled by the ini file. But downgrade is quite useful during development.

After fixing the connection URL, enable downgrade by editing the **alembic.ini** configuration file.

	[custom]
	downgrade_enabled = True

&nbsp;

## Working with alembic-sql

### Create revisions

Initialize a new revision:

```
(.venv) $ alembic revision -m "initial db"
  Generating /home/orhanku/databases/testdb/testdb/versions/facde2345cb9_initial_db.py ...  done
  Creating directory /home/orhanku/databases/testdb/testdb/versions/facde2345cb9 ...  done
  Creating upgrade file upgrade.sql ...  done
  Creating downgrade file downgrade.sql ...  done

(.venv) $ cd testdb/versions

(.venv) $ ls -F
facde2345cb9/  facde2345cb9_initial_db.py  __pycache__/
```

The Python file is generated by [Mako](https://www.makotemplates.org/) using the template file **~/databases/testdb/script.py.mako**, which is a [symlink](https://en.wikipedia.org/wiki/Symbolic_link) to the script.py.mako residing at the virtual environment's parent directory.

```
$ cat facde2345cb9_initial_db.py
"""initial db

Revision ID: facde2345cb9
Revises:
Create Date: 2020-02-16 15:40:17.383429

"""
from alembic import op
import sqlalchemy as sa


from alembic_sql import common

# revision identifiers, used by Alembic.
revision = 'facde2345cb9'
down_revision = None
branch_labels = None
depends_on = None

u_sqls = ['upgrade.sql']
d_sqls = ['downgrade.sql']

common.create_revision_structure(revision, u_sqls, d_sqls)


def upgrade():
    common.execute_file(op.get_bind(), revision, u_sqls, True)


def downgrade():
    if common.is_downgrade_disabled():
        print(common.get_downgrade_warning())
    else:
        common.execute_file(op.get_bind(), revision, d_sqls, False)
```

Two SQL files are generated in a directory named after revision identifier. The SQL files are initially empty, of course.

```
(.venv) $ cd facde2345cb9/

(.venv) $ ls
downgrade.sql  upgrade.sql

(.venv) $ cat upgrade.sql
-- -----------------------------------------------------------------------------
-- upgrade.sql | facde2345cb9
-- -----------------------------------------------------------------------------


(.venv) $ cat downgrade.sql
-- -----------------------------------------------------------------------------
-- downgrade.sql | facde2345cb9
-- -----------------------------------------------------------------------------


```

The upgrade and downgrade files are to be filled with semicolon-separated SQL commands.

The **semicolon** is important to split the whole file into SQL commands.

```
(.venv) $ cat upgrade.sql
-- -----------------------------------------------------------------------------
-- upgrade.sql | facde2345cb9
-- -----------------------------------------------------------------------------

CREATE TABLE notification
(
   id           NUMERIC NOT NULL,
   created      TIMESTAMP WITH TIME ZONE NOT NULL,
   updated      TIMESTAMP WITH TIME ZONE NOT NULL,
   origin       TEXT NOT NULL,
   email        TEXT NOT NULL
);

ALTER TABLE ONLY notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);

(.venv) $ cat downgrade.sql
-- -----------------------------------------------------------------------------
-- downgrade.sql | facde2345cb9
-- -----------------------------------------------------------------------------

DROP TABLE notification;

```
A second revision is added by first cd'ing to the directory containing **alembic.ini**:

```
(.venv) $ cd ../../..

(.venv) $ alembic revision -m "add relation configuration"
  Generating /home/orhanku/databases/testdb/testdb/versions/c5b84bad4928_add_relation_configuration.py ...  done
  Creating directory /home/orhanku/databases/testdb/testdb/versions/c5b84bad4928 ...  done
  Creating upgrade file upgrade.sql ...  done
  Creating downgrade file downgrade.sql ...  done

(.venv) $ cd testdb/versions/c5b84bad4928
```

After adding SQL commands:

```
(.venv) $ cat upgrade.sql
-- -----------------------------------------------------------------------------
-- upgrade.sql | c5b84bad4928
-- -----------------------------------------------------------------------------

CREATE TABLE configuration (
    conf_key     TEXT NOT NULL,
    conf_val     TEXT NOT NULL
);


(.venv) $ cat downgrade.sql
-- -----------------------------------------------------------------------------
-- downgrade.sql | c5b84bad4928
-- -----------------------------------------------------------------------------

DROP TABLE configuration;

```

A third revision is added:

```
(.venv) $ cd ../../..

(.venv) $ alembic revision -m "fill configuration"
  Generating /home/orhanku/databases/testdb/testdb/versions/445e76328ea7_fill_configuration.py ...  done
  Creating directory /home/orhanku/databases/testdb/testdb/versions/445e76328ea7 ...  done
  Creating upgrade file upgrade.sql ...  done
  Creating downgrade file downgrade.sql ...  done

(.venv) $ cd testdb/versions/445e76328ea7
```

After adding SQL commands:

```
(.venv) $ cat upgrade.sql
-- -----------------------------------------------------------------------------
-- upgrade.sql | 445e76328ea7
-- -----------------------------------------------------------------------------

INSERT INTO configuration (conf_key, conf_val) VALUES
    ('LOG_FILES_MAX_SIZE','1000'),
    ('LOG_FILES_PARENT_DIR_PATH','/disk1/logs'),
    ('SYSTEM_NAME','vulcan'),
    ('MAIL_HOST','mail.example.com'),
    ('MAIL_USER','devops@example.com.tr'),
    ('MAIL_PORT','587'),
    ('PSSWD','123456'),
    ('FROM_ADDRESS','devops@example.com.tr'),
    ('BCC_ADDRESS','it@example.com.tr'),
    ('TO_ADDRESS','boss@example.com.tr');

(.venv) $ cat downgrade.sql
-- -----------------------------------------------------------------------------
-- downgrade.sql | 445e76328ea7
-- -----------------------------------------------------------------------------

TRUNCATE configuration;

```

&nbsp;


### Apply Revisions

Apply revisions one by one:

```
(.venv) $ cd ~/databases/testdb/

(.venv) $ alembic upgrade +1
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
INFO  [alembic.runtime.migration] Running upgrade  -> facde2345cb9, initial db
--------------------------------------------------------------------------------
PATH: /home/orhanku/databases/testdb/testdb/versions/facde2345cb9/upgrade.sql
--------------------------------------------------------------------------------

______________________________________ SQL _____________________________________
CREATE TABLE notification
(
   id           NUMERIC NOT NULL,
   created      TIMESTAMP WITH TIME ZONE NOT NULL,
   updated      TIMESTAMP WITH TIME ZONE NOT NULL,
   origin       TEXT NOT NULL,
   email        TEXT NOT NULL
);

______________________________________ SQL _____________________________________
ALTER TABLE ONLY notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);

+++ UPGRADE LoC:	10

(.venv) $ alembic current
$ alembic current
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
facde2345cb9

(.venv) $ alembic upgrade +1
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
INFO  [alembic.runtime.migration] Running upgrade facde2345cb9 -> c5b84bad4928, add relation configuration
--------------------------------------------------------------------------------
PATH: /home/orhanku/databases/testdb/testdb/versions/c5b84bad4928/upgrade.sql
--------------------------------------------------------------------------------

______________________________________ SQL _____________________________________
CREATE TABLE configuration (
    conf_key     TEXT NOT NULL,
    conf_val     TEXT NOT NULL
);

+++ UPGRADE LoC:	4

(.venv) $ alembic current
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
c5b84bad4928

(.venv) $ alembic upgrade +1
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
INFO  [alembic.runtime.migration] Running upgrade c5b84bad4928 -> 445e76328ea7, fill configuration
--------------------------------------------------------------------------------
PATH: /home/orhanku/databases/testdb/testdb/versions/445e76328ea7/upgrade.sql
--------------------------------------------------------------------------------

______________________________________ SQL _____________________________________
INSERT INTO configuration (conf_key, conf_val) VALUES
    ('LOG_FILES_MAX_SIZE','1000'),
    ('LOG_FILES_PARENT_DIR_PATH','/disk1/logs'),
    ('SYSTEM_NAME','vulcan'),
    ('MAIL_HOST','mail.example.com'),
    ('MAIL_USER','devops@example.com.tr'),
    ('MAIL_PORT','587'),
    ('PSSWD','123456'),
    ('FROM_ADDRESS','devops@example.com.tr'),
    ('BCC_ADDRESS','it@example.com.tr'),
    ('TO_ADDRESS','boss@example.com.tr');

+++ UPGRADE LoC:	11

(.venv) $ alembic current
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
445e76328ea7 (head)

```

Downgrade by one revision:

```
(.venv) $ alembic downgrade -1
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
INFO  [alembic.runtime.migration] Running downgrade 445e76328ea7 -> c5b84bad4928, fill configuration
--------------------------------------------------------------------------------
PATH: /home/orhanku/databases/testdb/testdb/versions/445e76328ea7/downgrade.sql
--------------------------------------------------------------------------------

______________________________________ SQL _____________________________________
TRUNCATE configuration;

+++ DOWNGRADE LoC:	1

(.venv) $ alembic current
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
c5b84bad4928

```

Upgrade to head  (the reverse operation is `alembic downgrade base`):

```
(.venv) $ alembic upgrade head
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
INFO  [alembic.runtime.migration] Running upgrade c5b84bad4928 -> 445e76328ea7, fill configuration
--------------------------------------------------------------------------------
PATH: /home/orhanku/databases/testdb/testdb/versions/445e76328ea7/upgrade.sql
--------------------------------------------------------------------------------

______________________________________ SQL _____________________________________
INSERT INTO configuration (conf_key, conf_val) VALUES
    ('LOG_FILES_MAX_SIZE','1000'),
    ('LOG_FILES_PARENT_DIR_PATH','/disk1/logs'),
    ('SYSTEM_NAME','vulcan'),
    ('MAIL_HOST','mail.example.com'),
    ('MAIL_USER','devops@example.com.tr'),
    ('MAIL_PORT','587'),
    ('PSSWD','123456'),
    ('FROM_ADDRESS','devops@example.com.tr'),
    ('BCC_ADDRESS','it@example.com.tr'),
    ('TO_ADDRESS','boss@example.com.tr');

+++ UPGRADE LoC:	11

(.venv) $ alembic current
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
445e76328ea7 (head)

```

See history:

```
(.venv) $ alembic history
c5b84bad4928 -> 445e76328ea7 (head), fill configuration
facde2345cb9 -> c5b84bad4928, add relation configuration
<base> -> facde2345cb9, initial db

(.venv) $ alembic history --verbose
Rev: 445e76328ea7 (head)
Parent: c5b84bad4928
Path: /home/orhanku/databases/testdb/testdb/versions/445e76328ea7_fill_configuration.py

    fill configuration

    Revision ID: 445e76328ea7
    Revises: c5b84bad4928
    Create Date: 2020-02-16 15:49:29.627843

Rev: c5b84bad4928
Parent: facde2345cb9
Path: /home/orhanku/databases/testdb/testdb/versions/c5b84bad4928_add_relation_configuration.py

    add relation configuration

    Revision ID: c5b84bad4928
    Revises: facde2345cb9
    Create Date: 2020-02-16 15:48:10.378099

Rev: facde2345cb9
Parent: <base>
Path: /home/orhanku/databases/testdb/testdb/versions/facde2345cb9_initial_db.py

    initial db

    Revision ID: facde2345cb9
    Revises:
    Create Date: 2020-02-16 15:40:17.383429
```

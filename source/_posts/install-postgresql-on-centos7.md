---
title: Install PostgreSQL on CentOS7
date: 2019-03-14 09:46:13
tags: 
- CentOS7
- PostgreSQL
- Linux
- 
---

# Install PostgreSQL on CentOS7

## Installation

> if you want install latest version check [official site](https://www.postgresql.org/download/)

I will install postgres9.6 for CentOS7.

> default version of postgres in CentOS7 rpm is not recommanded, I need some new features in postgres9.5+.

<!--more-->

```sh
sudo yum install https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-redhat96-9.6-3.noarch.rpm
sudo yum install postgresql96-server postgresql96-contrib

# initialize the database
sudo postgresql96-setup initdb
```

## Config for remote access

Set listen port to wildcard

```conf
# sudo vim /var/lib/pgsql/9.6/data/postgresql.conf
listen_addresses = '*'
```

Change HBA (host-based authentication) configuration

```conf
# sudo vim /var/lib/pgsql/9.6/data/pg_hba.conf
host    all             all             0.0.0.0/0            md5
```

## Start server

```sh
sudo systemctl enable postgresql-9.6
sudo systemctl start postgresql-9.6

# check listen port
ss -ant | grep 5432
```

## Login default role

```sh
sudo -i -u postgres
# to access PostgreSQL prompt
psql
# for quit PostgreSQL prompt
\q  
```

## Create a new role

```sh
createuser --interactive
```

> My new role is `rwuser`

## Create a new database

```sh
createdb test1
```

## Login new role

```sh
# access PostgreSQL prompt with new role
sudo su -c "psql -d test1" - rwuser
# type following command in  PostgreSQL prompt
\password
# then set your new password
```

You can use navicat to connect pgsql later.

## Reference

* [How To Install and Use PostgreSQL on CentOS 7](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-centos-7#create-a-new-role)
* [Change a Password for PostgreSQL on Linux via Command Line](https://www.liquidweb.com/kb/change-a-password-for-postgresql-on-linux-via-command-line/)
* [Official install guide](https://www.postgresql.org/download/linux/redhat/)
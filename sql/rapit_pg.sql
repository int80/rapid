--
-- Generated from mysql2pgsql.perl
-- http://gborg.postgresql.org/project/mysql2psql/
-- (c) 2001 - 2007 Jose M. Duarte, Joseph Speigle
--

-- warnings are printed for drop tables if they do not exist
-- please see http://archives.postgresql.org/pgsql-novice/2004-10/msg00158.php

-- ##############################################################

CREATE TABLE  "session" (
   "id"   char(72) NOT NULL, 
   "session_data"   text, 
   "expires"   int DEFAULT NULL, 
   primary key ("id")
);

CREATE TABLE  "contact" (
   "id" serial8 ,
   "name"   text, 
   "request"   text, 
   "email"   text, 
   "phone"   text, 
   primary key ("id")
);

CREATE TABLE  "role" (
   "id" serial8 ,
   "role"   text NOT NULL, 
   primary key ("id")
);

CREATE TABLE  "customer" (
   "id" serial8 ,
   "name"   text NOT NULL, 
   "created"   timestamp NOT NULL DEFAULT current_timestamp, 
   "address"   text, 
   "phone"   text, 
   "email"   text, 
   "notes"   text, 
   primary key ("id")
);

CREATE TABLE  "user" (
   "id" serial8 ,
   "username"   varchar(64) NOT NULL, 
   "password"   varchar(128) DEFAULT NULL, 
   "customer"   int, 
   "email"   VARCHAR(255), 
   primary key ("id")
);

CREATE TABLE  "user_role" (
   "id" serial8 ,
   "user_id"   integer NOT NULL, 
   "role_id"   integer NOT NULL,
   primary key ("id")
);

CREATE TABLE  "customer_host" (
   "id" serial8 ,
   "customer"   int NOT NULL, 
   "hostname"   varchar(255) NOT NULL, 
   "created"   TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
   primary key ("id"),
 unique ("customer", "hostname") 
);

CREATE TABLE  "registry" (
   "id" serial8 ,
   "app"   varchar(127) NOT NULL, 
   "ip"   varchar(63) NOT NULL, 
   "customer_host"   int NOT NULL, 
   "created"   timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, 
   "updated"   timestamp NULL DEFAULT NULL, 
   primary key ("id"),
 unique ("app", "customer_host") 
);

ALTER TABLE "user" ADD FOREIGN KEY ("customer") REFERENCES "customer" ("id");
ALTER TABLE "user_role" ADD FOREIGN KEY ("role_id") REFERENCES "role" ("id");
ALTER TABLE "user_role" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");
ALTER TABLE "customer_host" ADD FOREIGN KEY ("customer") REFERENCES "customer" ("id");
CREATE INDEX "registry_customer_host_idx" ON "registry" USING btree ("customer_host");
ALTER TABLE "registry" ADD FOREIGN KEY ("customer_host") REFERENCES "customer_host" ("id");

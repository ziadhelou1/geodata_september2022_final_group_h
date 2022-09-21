
-- connect as user postgres to the maintenance database postgres and create the database countries.
-- psql -U postgres -d postgres -f 010_create_database_countries_create_role_001.sql

CREATE ROLE postgres WITH
	LOGIN
	NOSUPERUSER
	NOCREATEDB
	CREATEROLE
	INHERIT
	NOREPLICATION
	CONNECTION LIMIT -1
	PASSWORD 'xxxxxx';
COMMENT ON ROLE postgres IS 'The countries database master user.';

CREATE DATABASE countries
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;

COMMENT ON DATABASE countries
    IS 'Geospatial database for training with PostGIS / QGIS';

\c countries

CREATE SCHEMA public
    AUTHORIZATION postgres;

COMMENT ON SCHEMA public
    IS 'Schema / namespace to store Covid data.';
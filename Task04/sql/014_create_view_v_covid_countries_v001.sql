-- connect as user postgres to the new database countries and create the view 
-- which joins covid_19 data, time and geometry
-- psql -U postgres -d countries -f 014_create_view_v_covid_countries_001.sql

create view public.covid_countries as(
 
 SELECT t1."Country" ,
    t1."Date_reported",
    t1."New_cases" ,
	t1."New_deaths",
    t2.geom
   FROM public.covid_19 t1,
    public.countries t2
  WHERE t1."Country" = t2."name")

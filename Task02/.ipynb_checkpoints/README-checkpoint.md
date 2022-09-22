# Task02

Produce a rainfall video over a 7-day period in 2021 that covers the heavy rains that led to the catastrophic flooding. The animation should cover all DWD stations in NRW with hourly precipitation. Create a point layer in QGIS showing the stations in NRW with time dependent precipitation rate data (mm per hour) in the attribute table. This layer has to come from a PostGIS view, which joins the two tables with 1) static station info including coordinates and 2) time dependent precipitation rates. Use the QGIS Temporal Controller to produce an animation.

## Sub-Task 2.1 Question: Create and fill your own geodatabase

Create and fill your own geodatabase with DWD precipitation station data as well as hourly precipitation time series.Follow the Jupyter Notebook tutorial of geo0930_PostGIS_Insert_DWD_Stations_and_TS (main notebook geo0930_PostGIS_DWD_Stations_and_TS_V002.ipynb) together with the respective YouTube tutorial.
The TimeManager plugin is deprecated! The new way is to use the QGIS Temporal Controller, which is integrated in recent QGIS versions. I have no video on that, yet.

### Before we start to avoid confusion, the username and password of QGIS file for this task are:
### Username: "geo_master"
### Password: "xxxxxx"

## Sub-Task 2.1 Answer:

In this task we are going to create a new database and a new schema so we can import the data from DWD website and create the tables of precipitation and stations, so we can create the view later in task 2.2 and use the view as a layer in QGIS in task 2.3, using the following steps:

1- Open windows powershell
2- Type the following code so we can access the sql folder created:
cd C:\Users\HP\Desktop\Ziad\University\Geodata\geodata_september2022_final_group_h\Task02\sql

3- Type the following code to create a database:
psql -U postgres -d postgres -f .\010_create_database_geo_create_role_v001.sql

This file "010_create_database_geo_create_role_v001.sql" consists of this code that create a database geo and schema dwd

CREATE ROLE geo_master WITH
    LOGIN
    NOSUPERUSER
    NOCREATEDB
    CREATEROLE
    INHERIT
    NOREPLICATION
    CONNECTION LIMIT -1
    PASSWORD 'xxxxxx';
COMMENT ON ROLE geo_master IS 'The geo database master user.';

CREATE DATABASE geo
    WITH 
    OWNER = geo_master
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;

COMMENT ON DATABASE geo
    IS 'Geospatial database for training with PostGIS / QGIS';

\c geo

CREATE SCHEMA dwd
    AUTHORIZATION geo_master;

COMMENT ON SCHEMA dwd
    IS 'Schema / namespace to store DWD data.';

4- Password: "xxxxxx"

5- Type the following code to connect as postgres to geo
psql -U postgres -d geo

6- Password: "xxxxxx"

7- Type the following code:
create extension postgis;

8- Then the next step is to run the jupyter notebook file name "Task02" so we can extract the stations information automatically from DWD website.

9- Open pgadmin 4 and refreshing the tables to see the precipitation and the stations tables.

![Hourly Precipitation Time Series](sub-task_2.1_hourly_precipitation_time_series.PNG)
![Reordering by Timestamp from Old to New](sub-task_2.1_identifying_data_with_timestamp.PNG)
![Hourly Precipitation data of NRW Stations Table](sub-task_2.1_DWD_precipitation_station_data_screenshot.PNG)


## Sub-Task 2.2 Question: Add the PostGIS view v_stations_prec as a layer to your QGIS project

After having finalized the tutorial above the geodatabase geo contains the two tables dwd.precand dwd.stations as well as the view v_stations_prec. The view joins the two tables. Add the geo-enabled view as a PostGIS layer to your project.

## Sub-Task 2.2 Answer:

Creating the view by ordering and extracting specific columns needed from the 2 tables, by typing the following in the Query in pgAdmin 4:

create view dwd.v_station_prec as (select t1.station_id, t2.ts, t2.val, t1.name, t1.geometry from dwd.stations t1, dwd.prec t2
where t1.station_id = t2.station_id)


Refreshing the view and "v_station_prec" is shown in the view.

Next steps: 
1- Open QGIS new project
2- Add the view that we created as a layer: Layer > Add Layer > Add PostGIS Layers
3- Creacting a new connection.
4- In the Authentication, filling inside the basic tab the user name and we store it.
Username: "geo_master"
5- Clicking ok and typing the password: "xxxxxx"
Password: "xxxxxx"
6- To find the view, we have to drop it. So we open the windows powershell where we stopped after step number 7 in Task 2.1 and we type the following code:
drop view dwd.v_stations_prec;
6- Finding the view table in the dwd Schema so we can add it as a layer > click on it "v_stations_prec" > edit the Feature id and turn on station_id and ts > Add it
Now we can see the stations popping up.
We define a date range so QGIS will read the information only during the flooding event, by right clicking on v_stations_prec > update sql layer, we add a second condition:
where ts > '2021-07-10 00:00:00' and ts < '2021-07-17 00:00:00'
We used this date so we can have the flooding date in the middle of the start date and end date.

We added the stations also as PostGIS layer but it was not necessary since we are going to use only the stations that are collecting precipitation information during the flooding event.

Now we can see the stations. We fix the color of the precipitations value so we can use them later in task2.3 for the animation, and we fix the size of the circle of the stations so they can be shown clearly using the following steps:

1- Right click on the v_stations_prec
2- Symbology
3- Graduated
4- Colors we use wiki-precip-mm, a specified colors for precipitation in mm in QGIS.
5- Symbol size 4.4mm

## Sub-Task 2.3 Question: Use the QGIS Temporal Controller to produce an animation
Follow the tutorial https://www.qgistutorials.com/en/docs/3/animating_time_series.html on QGIS Temporal Controller to produce an animation.

The time period of data and animation, respectively, has to cover 7 days with hourly resolution. You have to change the creation of the view in the Jupyter Notebook to extend the time span. The catastrophic rain event of 2021 (less than two days) should be roughly in the middle of the view's selected time interval.

Import the NRW administrative boundary (vector layer) as a Web Feature Service (WFS). We discussed in class how to import and use the web services (WMS, WFS, WCS) provided by NRW (as part of opengeodata.nrw.de). Import the topographic map from the NRW WMS collection as the background map.

Use the menu view -> decorations to add title, legend, scale, north arrow, time stamp, etc.

Save/export the created images and make a video from it. Add it to your gitlab repo.

## Sub-Task 2.3 Answer:

Now we need to Import the NRW administrative boundary (vector layer) as a Web Feature Service (WFS),following the steps below:

1- Open QGIS, Layer > Add Layer > Add WMS/WMTS Layer
2- New connection:
3- Name: NW Digitale Topographische Karten; DTK [WMTS]
4- URL: https://www.wms.nrw.de/geobasis/wms_nw_dtk
Source of the link from https://www.bezreg-koeln.nrw.de/brk_internet/geobasis/webdienste/geodatendienste/index.html
5- Click ok
6- Add DTK Farbe

We put the layers in order so the v_stations_prec is on top, and the DTK Farbe in the bottom.
Adding north arrow, title and a scale bar from the decoration in the view option.

Fixing the temporal control following the steps below:
1- Right click on v_stations_prec layer
2- Properties
3- Temporal
4- Configuration: Single Field with Date/Time
5- Limits: Include Start, Include End
6- Field: ts
7- Event Duration: 1 Hour
8- Apply ok

To view the Temporal control panel we click on view > Panels and we turn on the "Temporal Control" option.
Setting the dates between 2021-07-10 00:00:00 and 2021-07-17 00:00:00 so we can have the flooding event in the middle.
Clicking play to see the animation.

![Flooding July 2022 Animated](sub-task_2.3_animation screenshot.PNG)

A video was uploaded on youtube to show the flooding event: https://youtu.be/iGqAIjkFptU
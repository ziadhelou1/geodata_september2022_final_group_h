# Task04: Choropleth Covid-19 Worldwide Animated Map 2020-2022

### The username and password of QGIS file for this task are:
### Username: "postgres"
### Password: "xxxxxx"

## Covid-19 Map

The main idea in Task04 is to do a Covid-19 choropleth map based on the numbers of the new weekly cases or weekly deaths by country. The target is to show an animation of the world map showing the updates of either the new weekly cases of Covid-19 or new weekly deaths. The idea is to show each country in different color based on the update of weekly numbers, means if the color is closer to white or light red, the numbers are smaller and when the color is getting more close to ther red color, it means the numbers are bigger.

## Source

The data needed is weekly data based on countries, which was not find. The data used was a daily data from https://covid19.who.int/data
The file is downloaded and stored in the Data folder in Task04 under the name of "WHO-COVID-19-global-data.csv"

## Method

The data was converted from daily to weekly using Jupyter Notebook "task04.ipynb", saved as CSV file UTF-8 so QGIS can read it. <br />
The problem was how to join the countries layers with the Covid-19 data and still show all the date rows, talking about 35,000 rows of data organized by dates showing the weekly Covid-19 new cases/deaths in all countries.

### First failed step done in QGIS

1- Download the world administrative boundaries and add the shape file .shp to the QGIS. <br />
2- Upload the data as delimited text layer <br />
3- Join the data using join option in properties <br />

Joining from the CSV to the shape file was not showing all the dates, only showing the first week for all countries.<br />
Joining from the shape file to the CSV resulted in a table file only without any geometry to reflect on the map.

### Problem Solved

Resolving this problem was very difficult, especially that no information about how to accomplish this step on the internet. It was easier to be done on ArcGIS. No information as well about how to join CSV and shape file in pgAdmin 4.

Next step was to find geometry data in pgAdmin 4. A table was created under the name of countries following this video on youtube https://www.youtube.com/watch?v=rRUO1McesJE&list=LL&index=4 <br />
The table was stored in a new Database named "country" in the Schema public under the table name "countries".<br />
Next step is to upload the CSV Covid-19 data into pgAdmin 4. <br />
The step was done by creating a new table, name it "covid19", name the columns same as they are in the CSV data, adding in the beginning an "id" column.
![Creating Table to Upload CSV in pdAdmin 4](creating_CSV_pgadmin4.PNG)

### Joining Tables and Creating a View in pgAdmin 4


using this code in the Query to read the CSV data in pgADmin 4:

SET datestyle = DMY;<br />
SELECT '13-01-20'::TIMESTAMP;<br />
copy covid19 from 'C:/Users/HP/Desktop/Ziad/University/Geodata/geodata_september2022_final_group_h/Task04/Data/covid19_data_modified.csv' with csv header


The 2 tables were created. The joining was very simple in pgAdmin 4 using:

SELECT t1."Country" ,<br />
    t1."Date_reported",<br />
    t1."New_cases" ,<br />
    t1."New_deaths",<br />
    t2.geom<br />
   FROM public.covid19 t1,<br />
    public.countries t2<br />
  WHERE t1."Country" = t2."name";<br />
  
Here the geometry of the countries from the table named "countries" is extracted, identified as t2, as well as all columns from the table "covid19" identified as t1. And the 2 columns joined each others based on the name of the countries columns in the 2 tables. "Country" column in "covid19" table and "name "column" in "countries" table.  

After having results, the last step on pgAdmin 4 was to create a view so we can connect QGIS and read the information. At this moment I had no idea at all if this will work or not, but I was trying all steps to understand how each software operates.<br />
Creating the view using this code in the Query:

create view public.covid_countries as(
 
 SELECT t1."Country" ,<br />
    t1."Date_reported",<br />
    t1."New_cases" ,<br />
    t1."New_deaths",<br />
    t2.geom<br />
   FROM public.covid19 t1,<br />
    public.countries t2<br />
  WHERE t1."Country" = t2."name")<br />
  
After refreshing the view, a new view popped up under the name of covid_countries.

These steps took 4 days 4-6 hours each, with trials and errors.

### QGIS Steps to use the layers

Next step was to use the geometric layer created on QGIS.<br />
Connecting the QGIS to pgAdmin 4 using these steps: Layer > Add Layer > Add PostGIS Layers<br />
In the Connections, a new connection was established to connect the "countries" database created in pageAdmin 4.<br />
Username: "postgres"<br />
Password: "xxxxxx"

After connecting the database, the "public" schema was shown in the Schema table.<br />
Next step is to fix the Feature id before proceeding. Schrolling to the right and turning on the 2 options "Country" and "Date_reported", then adding the layer twice to use one for the cases and one for the deaths data.

Fixing the Symbology using Graduated option using white to red color ramp, one layer using the "New_cases" value and in the other layer using "New_deaths". Classifying based on Natural Breaks (Jenks), the most logical way after trying all options.

Last step is to fix the temporal control in the option using these steps:<br />
1- Turn on Dynamic Temporal Control<br />
2- Configuration: Single Field with Date/Time<br />
3- Limits: Include Start, Include End<br />
4- Field: Date_reported<br />
5- Event duration 1, Weeks.

After playing the temporal control, the map was showing the animation.<br />
Covid-19 new cases/deaths video animation: https://youtu.be/jyq8y5S_rEI

![Covid-19 new cases/deaths](Task04_results.PNG)

## Discussion and Results

After finishing all steps, we realized a mistake, some of the biggest countries are not giving any data.<br />
Looking into the 2 tables in pgAdmin 4 to identify the problem.<br />
We realized that some of the countries name are different between the columns of the 2 tables joined together. For example, USA country name was "United States" in "countries table" and "United States of America" in "covid19" table, that's why the data resulting in unknown numbers and no data was shown.

To fix this step, the covid19 CSV downloaded from Jupyter Notebook after the editing, was modified manually in Excel. The names of the countries were fixed one by one to match the names of the "countries" table. We didn't find any other way to fix this step automatically.

Redoing all the steps again using the new modified excel named "covid19_data_modified" to get the last results.<br />
A video was uploaded on youtube to show how the countries layers are changing their colors based on weekly Covid-19 new cases/deaths: https://youtu.be/jyq8y5S_rEI

## Conclusion

Analyzing the last results, we found some issues.<br />
"Turkey" country was not showing any values changing, that was a problem from the initial data, seems that Turkey was not providing any information about Covid-19.<br />
Looking at the data, the biggest countries are turning into more red color than small countries, which prooving that the data is not scientific, since the biggest countries have more population and they will result naturally in more Covid-19 cases and more deaths.

It was a challenging task, and I am looking forward to see how it can be done in a more scientific way, maybe to collect the percentage of the data based on the population of each country and work on the percentage values in our tables instead of working on just numbers. That's how we can understand how Covid-19 was conquering the countries in a better way. For example 1.5 million cases in Lebanon during a week means almost 25% of the country's population is affected, but 1.5 million cases in the United States is almost 0.5%. In this case we can see that Covid-19 is more severe in Lebanon than USA, and the color of USA should be lighter than Lebanon during this week. But in our data, if we have the same example, the 2 countries will be showing the same color, which don't show the real reflection of Covid-19.<br />
But in the end, if anyone is interested in seeing only the real numbers animated, it would be useful.
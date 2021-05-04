# ASCII cat says...
#                   ____________________________
#  /)  |'\__|\     / "Get excited for mapping!" \
# ((   |   0 0|   /\____________________________/
#  )) /   =='==  / 
#------)))----)))----#

###################################################-
#---SPATIAL VISUALIZATION OF HEALTH EVENTS IN R----
#------------by Brandon Hayes, DVM MPH-------------
###################################################-

## Install packages if needed
#install.packages("rgdal")
#install.packages("rgeos")
#install.packages("tmap")
#install.packages("tmaptools")
#install.packages("dplyr")
#install.packages("readr")

## Load our spatial packages
library(rgdal)     # for reading and writing data, note how it also loads "sp" package
library(rgeos)     # for reading and writing data
library(tmap)      # for visualization and plotting
library(tmaptools) # for visualization and plotting
git remote add origin
#-------------------------------------------#
#---Session 1: Static boundary/base maps----
#-------------------------------------------#

## **Nota bene: The code for interactive and static maps is the same, and you can switch between the 
##   two modes (plotting and viewing) quickly by running this function: ttm(). However, only static maps
##   can be exported as *.jpg, *.tif etc. We will start with static maps.

## Read-in our Administrative Boundaries shapefile using the function readOGR()
##   - Look in "files" tab to see different layers of shapefiles (adm0, adm1, etc)
##   - Layers correspond to different scales of administrative division (eg regions vs departments)
##   - Lets start with the 0th administrative division 
adm0 <- readOGR(dsn = ".", layer = "gadm36_GBR_0")

## Set our mapping mode to "plot"
tmap_mode("plot")

## Plot the 0th division to see what we have
tm_shape(adm0) + tm_polygons()

## tm_polygons() plots both the border color and the fill color of the polygon.
## You can alternatively use tm_borders() and tm_fill() if you want only the borders or fill, respectively
tm_shape(adm0) + tm_borders()
tm_shape(adm0) + tm_fill()

## Lets view the data associated with the shapefile
## Type the object name (adm0) below followed by @ to see the different slots for S4 objects
adm0@data

## What are we really working with?
class(adm0@data)
class(adm0@polygons)

## This is only the national border, we need finer detail so lets check the levels of the other layers
## Read in the next layer
adm1 <- readOGR(dsn = ".", layer = "gadm36_GBR_1")

## Lets see what data is associated with this layer
adm1@data

## Plot the first layer
tm_shape(adm1) + tm_polygons()

## Lets add some color to differentiate regions
names(adm1@data) # to see the different data frame columns we can subset by

## Subset by the types of divisions (from column ENGTYPE_1)
## Lets use polygon color for differentiation
tm_shape(adm1) + tm_polygons(col = "ENGTYPE_1")

## Now lets subset by the names of divisions (from column NAME_1)
tm_shape(adm1) + tm_polygons(col = "NAME_1")

## Lets pick a better color palette
## Open the tmaptools palette_explorer, an R Shiny internet app to aid color choice from pre-set palettes
palette_explorer()

## We have categorical information, so lets use one of the categorical palettes 
## Don't forget to close the Shiny window when done (note "Listening on http://127.0..." in your terminal)

## Add the palette aesthetic our map with the chosen palette
tm_shape(adm1) + tm_polygons(col ="NAME_1", palette = "Accent")

## Lets reverse the direction of the color palette, maybe that will look nicer
tm_shape(adm1) + tm_polygons(col ="NAME_1", palette = "-Accent") #note the - sign before Accent

## Now lets improve the visual aesthetic by adding tm_layout
## We will add a main title and put the legend outside the frame of the map
## Also, when coding more than 2 map functions or facets, I recommend using separate lines 
tm_shape(adm1) + 
  tm_polygons(col ="NAME_1",
              palette = "-Accent") +
  tm_layout(main.title = "Countries of the United Kingdom",
            legend.outside = TRUE)

## Still not great, we need to fix the legend title and remove the frame
## As we specified our legend parameter to come from tm_polygons(), we must specify the desired title there as well
## To remove the legend title, set it to nothing between " "
tm_shape(adm1) + 
  tm_polygons(col ="NAME_1",
              palette = "-Accent",
              title = "") +
  tm_layout(main.title = "Countries of the United Kingdom",
            legend.outside = TRUE,
            frame = FALSE)

## Lets add some accoutrements, like a compass and scale bar
tm_shape(adm1) + 
  tm_polygons(col ="NAME_1",
              palette = "-Accent",
              title = "") +
  tm_layout(main.title = "Countries of the United Kingdom",
            legend.outside = TRUE,
            frame = FALSE) +
  tm_compass() +
  tm_scale_bar()

## We should specify the type and position
## Bring up the arguments for the function and look at "type" and "position"
?tm_compass
?tm_scale_bar #note same position arguments as tm_compass

## Lets make the following improvements: Place our fancy additions in the bottom left, increase the size of our
## scale bar, make the compass sexy, and export the map as an object
##   - For compass type, options include "arrow", "4star", "8star", "radar", and "rose".
##   - For position, the help file specifies a "vector of two values". This means you must concatenate the location values.
##   - For scale_bar size, the default width is "0.25", corresponding to 1/4 the width of the plot area


tm_shape(adm1) + 
  tm_polygons(col ="NAME_1",
              palette = "-Accent",
              title = "") +
  tm_layout(main.title = "Countries of the United Kingdom",
            legend.outside = TRUE,
            frame = FALSE) +
  tm_compass(type = "rose",
             position = c("left", "bottom"),
             color.dark = "navy") +
  tm_scale_bar(width = 0.3,
               position = c("left", "bottom"),
               color.light = "wheat",
               color.dark = "navy") +
  tm_style("classic")

## feeling exceptionally artsy today? Add this snippet to the above code: + tm_style("classic")

## Nota bene: to see the myriad of color options in R, refer to this pdf: http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf


## Now export the image to your directory


#                   ___________________________
#  /)  |'\__|\     / "That's a beautiful map!" \
# ((   |   0 0|   /\___________________________/
#  )) /   =='==  / 
#------)))----)))----#


## Q: But we are only interested in Northern Ireland, so how can we highlight only that region?
## A: By overlaying polygons

## First make our base map
##   - Lets stick with the soft orange color, so open up the palette explorer and get the
##     hex color value for that color (scroll down and click the "Print color values" option)
palette_explorer() 

## Create base map of one color, then add another shape that is subset to the region of interest
tm_shape(adm1) + tm_polygons(col = "lightgray") + 
  tm_shape(adm1[adm1$NAME_1 %in% "Northern Ireland",]) + tm_polygons(col = "#FDC086") +
  tm_layout(frame = FALSE)

## n.b: tmap (and R in general) process commands in the order given, so it is necessary to put your
##   base/bottom map first, then add on the layers in the order you want them overwritten

###### Brief Aside
## If you are not familiar with operators, "==" and "%in%" are slightly but importantly different.
## "==" is a logical operator whereas "%in%" is for value matching
## Think of %in% as "contains", whereas == means "equals". Using the wrong operator can mess up your maps
##    when are trying to subset multiple polygons, so here's a simple example to illustrate why:
x <- c("1", "2", "3")
y <- c("3", "2", "1")
x
y
x == y
x %in% y
rm(x,y)
# and now back to our maps

#-------------------------------------------------------#
#---Session 2: Interactive maps and data exploration----
#-------------------------------------------------------#
## Read in our case data csv file
## This file is of fictional cases of a disease in Northern Ireland
cases <- read.csv("./cases.csv")

## Examine the head of the data
head(cases)

## We see we have dates, longitude and latitude coordinates, and a host variable
## First let's make R recognize the coordinate data, transforming our dataframe to a spatial object
## We do this by setting the coordinates with the function coordinates()
coordinates(cases) <- ~long+lat #N.B. R assumes the "x" value is given first and "y" value second
                                #N.B. longitude is on the x-axis, latitude on the y-axis  

## Now that our case file is a spatial object, we can treat it as one
## Lets check our projection parameters
cases@proj4string

## We can see that a coordinate reference system is not yet assigned, so first lets do that
## To assign the correct system, we must find the correct EPSG number
## We know that these are GPS coordinates, so to http://epsg.io and search for "GPS"
## Now assign the proper coordinate reference system to our projection using the function proj4string()
proj4string(cases) <- CRS("+init=EPSG:4326")

## Now when we check our projection we can see its features
cases@proj4string

## Now to explore our data
## Set our mapping mode to "view"
tmap_mode("view")

## Now quickly plot our data
## We can do this in tmap using the function qtm() (qtm = "quick thematic map")
## This function combines "tm_shape() + tm_polygons()", and is ideal for easy data exploration
qtm(cases)

## If we click on any data point on the interactive map, we can see the variables associated with it
## We can also see what variables we have available for distinguishing our data points by:
names(cases)

## We have date and host, lets see what the unique host variables are
unique(cases$host)
unique(cases@data$host)

## Ok, so there's feral cats and foxes. Lets visualize the spatial distribution on the interactive map
## We will tell R to set the *color* of the *dots* according to the *host* column
qtm(cases, dots.col = "host")

## If we want to use our own colors, we can set the *palette* of the *dots* too, either with a preset palette or our own.
## If we use our own palette, because we have 2 variables, we must concatenate 2 colors
qtm(cases, dots.col = "host", dots.palette = c("red", "blue"))

## Want a different base map? You can select 3 options in the Viewer window, or you can call specific ones in your code
## There are numerous options and you can explore some using "providers$" 
## Type providers$ to see options
providers$Stamen.Watercolor
  
## Still feeling artistic? Lets set our basemap to "Stamen.Watercolor" (and update our color palette)
qtm(cases, dots.col = "host", dots.palette = c("chartreuse", "seagreen"), basemaps = "Stamen.Watercolor")

## How about if we want to examine temporal trends?
qtm(cases, dots.col = "date")

## Hmm that color palette is confusing, we need a sequential palette for plotting temporal data 
## Open up our palette_explorer, select a sequential palette color, then add it to our quick map
palette_explorer()
qtm(cases, dots.col = "date", dots.palette = "Reds")

## And this is how you interactively explore your spatial data!

## We see we have some data worth plotting, so lets return to the long script notation
## This way will be easier for controlling variables and adding in legends and more to our final map
## Here is the long format code of the previous qtm() script
tm_shape(cases) + tm_dots(col = "date", palette = "Reds")

#----------------------------------------------------#
#---Session 3: Chloropleths, bubble maps and more----
#----------------------------------------------------#

## Let's start making some publication-worthy plots of our data
## Set tmap to "plot" mode
tmap_mode("plot")

## We need a base map on which to plot our points, so read in the base map file with the desired subdivisions
## Lets load the GBR_adm2 shapefile
adm2 <- readOGR(dsn = ".", layer = "gadm36_GBR_2")

## See the scale we can work with
tm_shape(adm2) + tm_polygons()

## Our interest is specifically Northern Ireland, so we can leave out Great Britain
## We do this by subsetting our spatial object
## View the data frame to find out where we want the subset to occur
View(adm2@data) #search for "Northern Ireland" to find the column to use for the subset
## Dataframe rows correspond to polygon ID, so we see that Northern Ireland is polygons (and affiliated data) 118 to 128

## Subset our data using [ ], note the redundant nomenclature of "x"["x$y ..."]
admNI <- adm2[adm2$NAME_1 %in% "Northern Ireland",] # <-- selects all rows (note the comma) containing "Northern Ireland" in the NAME_1 column

## Lets check out that our subset worked
tm_shape(admNI) + tm_polygons()

## Now lets overlay our data points
## First we ensure both spatial objects use the same CRS (coordinate reference system)
## When we examine the projection arguments, they look the same
admNI@proj4string
cases@proj4string
## But apparently there is a slight difference between the two, as we never set the CRS for our adm2 object...
all.equal(admNI@proj4string, cases@proj4string)

## Set the CRS
admNI@proj4string <- CRS("+init=EPSG:4326")

## Now check again
all.equal(admNI@proj4string, cases@proj4string)

## Now our projections are the same, so now we are ready to plot our data
tm_shape(admNI) + tm_polygons() + #plot our base map
  tm_shape(cases) + tm_dots(col = "red") # plot our cases in red

## The dots are a bit small, lets increase the size
?tm_dots
tm_shape(admNI) + tm_polygons() +
  tm_shape(cases) + tm_dots(col = "red", size = .1) 

## Want a symbols of our choosing?
## Examine the tm_symbols function
?tm_symbols

## The main options to focus on are size and shape. The shape number comes from ggplot2 point shapes
## For shapes, you can google "ggplot2 point shapes" to see the options, but the main ones are 21:25, with 21 being a filled circle
## For symbol size, the default value is 1 so you will scale downwards to find an appropriate size
## Lets plot again
tm_shape(admNI) + tm_polygons() + #plot our base map
  tm_shape(cases) + tm_symbols(col = "red", shape = 21, size = .4)  # plot our cases in red

## But point data is not visually intuitive beyond presence
## What do I mean? Can we easily tell which districts are more affected than others? Not really...

## So lets make a chloropleth map - each region shaded based on number of cases in the region
## First need to identify how many points are in each polygon
## To do this:
##     Get logical matrix (T/F) of each polygon and point, and if it is contained or not, with the function gContains()
       polyCases <- gContains(admNI, cases, byid = TRUE)

##     Examine the matrix to understand
       head(polyCases)
##     Each polygon is a column, each point is a row
       
##     If we take the sum of each column (TRUE = 1), we have case counts per polygon
       colSums(polyCases)

##     Save that vector, so we can add it to our SpatialPolygonsDataFrame data
       cases_per_polygon <- colSums(polyCases)

##     Set "cases_per_polygon" as a new column in our admNI dataframe called cases
       admNI@data$cases <- cases_per_polygon

##     you can see it here
       admNI@data

       
#*****************#
#~~~Chloropleth~~~#
#*****************#
       
## Now lets make our chloropleth, using the data column "cases" for the color and the palette "Reds" 
tm_shape(admNI) +
  tm_polygons(col="cases", palette = "Reds")

## But what about polygons with zero cases? R automatically set the breakpoints but we can set them manually
tm_shape(admNI) +
  tm_polygons(col="cases",
              palette = "Reds",
              breaks = c(0, 1, 10, 20, 30, 40))

## Lets improve our legend and set the aesthetics
## We'll set our legend title and legend labels manually, and of course add a compass
## Remember the legend is generated from the polygon data, so its settings must be set inside the tm_polygon (or tm_fill etc) function
tm_shape(admNI) +
  tm_polygons(col="cases",
              palette = "Reds",
              breaks = c(0, 1, 10, 20, 30, 40),
              title = "Cases",
              labels = c("0", "< 10", "10 - 20", "20 - 30", "30 - 40")) +
  tm_layout(main.title = "Case Prevalence by District") +
  tm_compass(position = c("left", "bottom"))

## Now what if you want places of 0 cases to be its own color, or unmapped?
## The best way I've found to do this is, in your cases column, replace 0s with NA using the function is.na()
admNI@data
is.na(admNI@data$cases) <- admNI$cases == 0
admNI@data

## Now replot our map
tm_shape(admNI) + tm_polygons(col="cases", palette = "Reds")

## Set our NA color to white, and remove the "Missing" label from the legend with showNA 
tm_shape(admNI) + tm_polygons(col="cases", palette = "Reds", colorNA = "white", showNA = FALSE)

## But what if we want only the polygons with cases? We need to subset our shape object
## Why? Because if you examine the function tm_shape(), you'll see that the bounding box is specified there

## Create the object of only admNI polygons with cases
admNI_cases <- admNI[!is.na(admNI$cases),] #"in admNI, subset by excluding all data that corresponds to NA values in admNI$cases", and don't forget the comma

## Plot with our new shape, and update our breaks and legend since there are no more areas of 0 cases 
tm_shape(admNI_cases) +
  tm_polygons(col="cases",
              palette = "Reds",
              breaks = c(0, 10, 20, 30, 40),
              title = "Cases",
              labels = c("< 10", "10 - 20", "20 - 30", "30 - 40")) +
  tm_layout(main.title = "Case Prevalence by District") +
  tm_compass(position = c("left", "bottom"))


#**************************#
#~~~Chloropleth + Points~~~#
#**************************#

## Simply overlay our case points, with the color set to "host"
tm_shape(admNI_cases) +
  tm_polygons(col="cases",
              palette = "Reds",
              breaks = c(0, 10, 20, 30, 40),
              title = "Cases",
              labels = c("< 10", "10 - 20", "20 - 30", "30 - 40")) +
  tm_layout(main.title = "Case Prevalence by District") +
  tm_compass(position = c("left", "bottom")) +
  tm_shape(cases) + tm_symbols(col = "host", size = .2)

#****************#
#~~~Bubble map~~~#
#****************#

## We can also display our prevalence data with a bubble map
## Specify what we want our bubble size to correspond to, and R takes care of it
tm_shape(admNI_cases) + tm_polygons() + tm_bubbles("cases")

## Lets color our bubbles and increase the size by setting the scale (the default is automatically determined)
tm_shape(admNI_cases) + tm_polygons() + tm_bubbles("cases", col = "red", scale = 2)

## Since our case data is visualized via bubbles, we can use our polygons for other purposes
## Lets set the polygon color to correspond to the district name, and use the palette Pastel2
head(admNI_cases@data) # Find the column that corresponds to district name

tm_shape(admNI_cases) +
  tm_polygons(col = "NAME_2",
              palette = "Pastel2",
              title = "District") + 
  tm_bubbles("cases",
             col = "red",
             scale = 2)

## Add our layout and compass accoutrements, including a main title and moving the legend outside the frame
tm_shape(admNI_cases) +
  tm_polygons(col = "NAME_2",
              palette = "Pastel2",
              title = "District") + 
  tm_bubbles("cases",
             col = "salmon",
             scale = 2) +
  tm_layout(main.title = "Case Prevalence by District",
            legend.outside = TRUE) +
  tm_compass(position = c("left", "bottom"))
  

#                   ___________________
#  /)  |'\__|\     / "Looking great!!" \
# ((   |   0 0|   /\___________________/
#  )) /   =='==  / 
#------)))----)))----#


#******************************#
#~~~Chloropleth + Bubble map~~~#
#******************************#

## If you had agricultural data for each district, you could color the districts by that variable to create a Chloropleth+Bubble map
## So lets go get some data... https://www.ninis2.nisra.gov.uk/

farmdata <- read.csv("./Dataset 9432_.csv")

## Clean our data
##   See what we have
     head(farmdata)

##   Set column names and remove unwanted rows and columns
     colnames(farmdata) <- farmdata[2,]
     farmdata <- farmdata[-c(1:2),]
     farmdata <- farmdata[,-3]

##   Much better
     head(farmdata)
     
##   See which district names from our new dataset are not in our map data 
     which(!(farmdata$LGD2014 %in% admNI@data$NAME_2))
     farmdata$LGD2014
     admNI@data$NAME_2
     
##   Edit the new data to make district names the same between our map polygons and the new data
     farmdata$LGD2014[c(3,4,7)] <- c("North Down and Ards", "Armagh, Banbridge and Craigavon", "Derry and Strabane")

##   Modify our column names so any space is replaced with an underscore
     colnames(farmdata) <- gsub(" ", "_", colnames(farmdata))
     
##   Make sure R recognizes the data in the columns as numeric data, examine any column to check...
     class(farmdata$Farms)
     
##   R doesn't know these values are numbers, so lets convert them while removing the "," digit separators
     library(readr)
     farmdata[,2:ncol(farmdata)] <- lapply(farmdata[,2:ncol(farmdata)], readr::parse_number)

## Examine our data briefly
View(farmdata)

## Join our farmdata to our map data using the function left_join() from the package "dplyr", saving it to our admNI data slot
library(dplyr)
admNI@data <- left_join(admNI@data, farmdata, by = c("NAME_2" = "LGD2014"))

## Now when we view our spatial object data, we see the new data has been mapped to the appropriate regions
View(admNI@data)

## Make a chloropleth map of the number of sheep
tm_shape(admNI) +
  tm_polygons(col = "Sheep", palette = "Greens") 

## Add on the bubble plot of case size
tm_shape(admNI) +
  tm_polygons(col = "Sheep", palette = "Greens") +
  tm_bubbles("cases", col = "firebrick1")

## Add our layout and design desires
tm_shape(admNI) +
  tm_polygons(col = "Sheep", palette = "Greens") +
  tm_bubbles("cases", col = "firebrick1") +
  tm_layout(main.title = "Sheep population and case prevalence, by district",
            legend.outside = TRUE,
            frame = FALSE) +
  tm_compass(position = c("left", "bottom"))

## What if we want to exclude the districts without cases, without making a new object? Subset in our tm_shape function!
      #the "under the hood" logic
      admNI$cases # get the column with the data we want to subset our map by
      is.na(admNI$cases) # get R to identify which part of the object are NA
      !is.na(admNI$cases) # Now invert so it focuses on the parts of the object that are not NA

tm_shape(admNI[!is.na(admNI$cases),]) +
  tm_polygons(col = "Sheep", palette = "Greens") +
  tm_bubbles("cases", col = "firebrick1") +
  tm_layout(main.title = "Sheep population and case prevalence, by district",
            legend.outside = TRUE,
            frame = FALSE) +
  tm_compass(position = c("left", "bottom"))


#                   ___________________________________________________________________
#  /)  |'\__|\     / "Looking good, but what I really want mapped is sheep density..." \
# ((   |   0 0|   /\___________________________________________________________________/
#  )) /   =='==  / 
#------)))----)))----#


## Ugh what a bossy cat...
## Lets generate one more column to add some density data
##   But we need the area of each polygon, and we're using longlat, a geographic coordinate system without any specified distance units
     admNI@proj4string

##   We need to convert to a projected coordinate system (with distance units), lets find one at http://epsg.io
##   Because we are *transforming* from one coordinate system to another (instead of just specifying a coordinate system), we use a different function
##   Transform our object to the desired projection using the function spTransform()
     admNI <- spTransform(admNI, CRS("+init=EPSG:2157"))

##   Re-examine our projection specifications, and we see our units are in meters
     admNI@proj4string

## Calculate area of each polygon
     polyArea <- gArea(admNI, byid = TRUE)

## Convert from square meters to square kilometers (divide by 1,000,000)
     polyArea <- polyArea/1e6

## Append this data our spatial object's data slot, in a new column called "Area_sqkm"
     admNI@data$Area_sqkm <- polyArea
     admNI@data

## Now we can calculate density data for any variable
## Create a new column for sheep density, and assign it the required calculation
     admNI$Sheep_density <- admNI$Sheep/admNI$Area_sqkm

## And using the same code from before, we will change the polygon color from "Sheep" to "Sheep_density"
     tm_shape(admNI[!is.na(admNI$cases),]) +
       tm_polygons(col = "Sheep_density", palette = "Greens") +
       tm_bubbles("cases", col = "firebrick1") +
       tm_layout(main.title = "Sheep density and case prevalence, by district",
                 legend.outside = TRUE,
                 frame = FALSE) +
       tm_compass(position = c("left", "bottom"))
## (Note the slight rotation that comes from using a different projection, though the North direction has not changed)
     
## Clean up our legend title...
     tm_shape(admNI[!is.na(admNI$cases),]) +
       tm_polygons(col = "Sheep_density", palette = "Greens", title = "Sheep density") +
       tm_bubbles("cases", col = "firebrick1") +
       tm_layout(main.title = "Sheep density and case prevalence, by district",
                 legend.outside = TRUE,
                 frame = FALSE) +
       tm_compass(position = c("left", "bottom"))
 
 #                   ____________________________
 #  /)  |'\__|\     / "Viola! C'est magnifique!" \
 # ((   |   0 0|   /\____________________________/
 #  )) /   =='==  / 
 #------)))----)))----#
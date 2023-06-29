# Load required libraries
library(dsims)
library(sf)
library(dplyr)
library(raster)
library(ggplot2)
library(rasterVis)
library(rgdal)
library(gridExtra)
library(rgeos)

# Convert study area kml to shapefile 
#data <- st_read("SA.kml")
 #head(data)

 #data <- select(data, -Description)
 #data <- select(data, -Name)
#plot(data) 
# Convert the geometry to 2D
#data_2D <- st_zm(data)

#st_write(data_2D, "StudyArea.shp")


# Covert line transect kml to shapefile 
#dataT <- st_read("Transect.kml")
#head(data)

#dataT <- select(dataT, -Description)
#dataT <- select(dataT, -Name)
#plot(dataT) 
# Convert the geometry to 2D
#dataT_2D <- st_zm(dataT)

#st_write(dataT_2D, "Transect.shp")

setwd("C:/Users/Muhammad Asif/OneDrive - Higher Education Commission/Desktop/Distance Sampling/R Work/Asif_Data")

Valley <- st_read("StudyArea.shp")
lineT<- st_read("Transect.shp")
dem <- raster("DEM.tif")

# Crop the DEM to the extent of the shapefile
cropped_dem <- crop(dem, extent(Valley))
plot(cropped_dem)

# Check the CRS of the line and cropped DEM
crs_line <- st_crs(lineT)
crs_cropped_dem <- crs(cropped_dem)

# Assign the CRS of the cropped DEM to the line
st_crs(lineT) <- crs_cropped_dem

# Check the CRS of the line after assignment
crs_line <- st_crs(lineT)

# Convert the line to an sf object with the new CRS
line_sf <- st_as_sf(lineT)

# Convert the raster to points and set the CRS
raster_points <- rasterToPoints(cropped_dem)
raster_sf <- st_as_sf(data.frame(raster_points), coords = c("x", "y"))
st_crs(raster_sf) <- st_crs(line_sf)


# Calculate the distance from the polyline to the raster cells using the `st_distance()` function
distances <- st_distance(line_sf, raster_sf, which = "Euclidean")

# Plotting raster and polyline 
dem_df <- raster::as.data.frame(cropped_dem, xy = TRUE)

ggplot() +
  geom_raster(data = dem_df, aes(x = x, y = y, fill = DEM)) +
  geom_sf(data = lineT, color = "red") +
  scale_fill_gradientn(name = "Elevation", colors = terrain.colors(10)) +
  coord_sf() +
  theme_minimal()

**Version 1.01**

_Bug fixes:_
- fixed wamImport Bug _"Error using ncread
Expected count to be positive."_ by implementing if-condition to increase timecount to 1 in case its 0.

_Log File:_
- Display UTC time 
- Display which sensor is used for each site
- Display mostRecentTime for each site

_Data import:_
- Timestamp for all insitu files describing mid of measuring time window. HIS and GPS data from dwr are timeshifted by -15min.
- Time2eval is now additionally timeshifted by 15min to match adjusted dwr timestamps


_Visualization:_
- Added scientific colormaps (https://www.fabiocrameri.ch/colourmaps/) and option to flip colormaps upside down. New Default: lipari (flipped)
- removed circles 'o' for site location
- New default site indication color: Green. Grey if no data is available.

_Batch:_
- Added f6 to choose colormaps
- Added f7 to flip colormaps
- Added f8,f9,f10 to set fontsize for axes, site indication and title (date)
 

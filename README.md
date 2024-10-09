# Seastate Toolbox German Bight
MATLAB-Toolbox that provides a real-time overview of the significant wave height in the German Bight based on data from 
high resolution coastal wave forecast models and quality controlled insitu measurements. 

# Description
The German Weather Service (DWD) operates a sea state forecasting system as part of the operational numerical weather prediction chain. 
The underlying model is the spectral sea state model CWAM (**C**oastal **WA**ve **M**odel) [1,2], which directly depends on the forcing by analyzed and forecasted 10m-winds of the atmospheric model ICON-EU. 
The spatial resolution is ~900m with an hourly temporal resolution. The forecast is updated twice a day ([DWD Forecast information](https://www.dwd.de/DE/leistungen/opendata/help/modelle/legend_ICON_wave_EN_pdf.pdf?__blob=publicationFile&v=3)) . 
Numerical simulation can offer a good estimation of seastate parameters, but are dependent on the quality of the input parameters (bathymetry, wind fields, ...).
To close this gap, the toolbox uses quality-controlled insitu measurements ([Manual Real-Time Data Quality Control (DQC)](https://www.bsh.de/DE/DATEN/Klima-und-Meer/Seegang/_Anlagen/Downloads/manual_echtzeit-datenqualitaetskontrolle.pdf)) from the BSH 
monitoring network as additional input. The site-specific measurements of the significant wave height (measuring devices either directional waverider buoy (DWR MK-III) by Datawell BV or wave radar by RADC BV) 
are used as sampling points to create an interpolation matrix in order to optimize the underlying WAM forecast. Various figure can be generated as output depicting the adjusted seastate in the German Bight
including the resulting deviations between numerical forecast and insitu measurements. The GSHHG data set [3] is used to visualize the coastlines. 

# Structure

The tool file directory consists of 4 main parts:
<details><summary>10_inputFiles</summary>

Header information for insitu data, coastline datasets, site overview as excel file and available colormaps are stored here.

</details>

<details><summary>20_matlab</summary>

All relevent MATLAB scripts and functions are located here.

</details>

<details><summary>30_execution</summary>

The central seastateInput.bat file as well as the compiled _.exe_ to run the tool in MATLAB runtime environment is located here. The script to compile the tool in your environment is located in _20_matlab\10_scripts_ folder.
</details>

<details><summary>40_changelog</summary>

Changelog files of current and previous versions are saved in this folder.

</details>

# Methodology
After defining mandatory input settings in _seastateInput.bat_ , the toolbox can either be used in MATLAB environment or as precompiled standalone .exe. (see [Execution](# Execution))

The work flow of the tool can be divided into three parts:
<details><summary>1. Data import</summary>

- All relevant parameters for defined point in time _time2Eval_ must be imported. The tool was developed in such a way that the output is generated twice an hour, either XX:15 or XX:45, whichever is closer. Each timestep representing 30 min seastate, whereby the output time is in the middle of this time window. 

- The data for all chosen measuring sites for given time is imported as well as the corresponding WAM forecast. Since WAM forecasts contain gridbased information, site specific  data must be extracted (and interpolated if necessary) from spatial dataset

- Static coastline data (GSHHG) is only dependent on given latitute/longitude boundaries and is imported and processed according to the specifications made.
</details>

<details><summary>2. Calculate scaling matrix</summary>

- After import is completed, two values for the significant wave height are available for each measurement site: _insitu_ and _WAM_. This allows a scaling factor _S_ to be created for each location, which describes the ratio of insitu to WAM. 
- Next, all measurement locations are interconnected via lines and the scaling factors are interpolated between the two end points. Support points containing the respective interpolation values are generated every 1 km along these lines. This leads to increased data density, which can be used as input to create the scaling matrix.
- Scale data from sites and support points are used for scattered data interpolation method [5] to create interpolation matrix for identical longitude/latitude grid points as WAM input. 
- In last step, the initial WAM grid for given point in time is multiplied with calculated scale matrix to get adjusted seastate output.

</details>

<details><summary>3. Visualization</summary>

Result plotting is covered in the function _plt_seastateModule_. A figure containing the following information is created as the default output:
- left: Overview significant wave height (m) German Bight for given point in time. Colorized with _lipari_ colormap [4]. Grey color indicates land area. Measuring sites are indicated in green and with their corresponding abbreviation. 
- right-hand site: 3 Subplots showing the actual measured and forecasted wave height, and the absolute (in m) as well as the relative (in %) deviations.


</details>


# Execution
Tool is developed to run in MATLAB Runtime environment without GUI. All mandatory input information are specified in the _seastateInput.bat_. As alternative, the tool can also be used in MATLAB via the _testSeastateMasterFnc.m_ (_20_matlab\10_scripts_), especially for debugging purposes. _seastateInput.bat_ not needed for this use, all input settings are defined within the script. 

For compilation, adjust the script _compileSeastateMasterFnc.m_ (_20_matlab\10_scripts_) according to your environment, and generate your execution file. You can execute the tool by shell or by double clicking the batch file. Generated figures are saved in the output folder defined in _seastateInput.bat_. 




# Data access
- [Ocean wave forecasts operated by German Weather Service (DWD)](https://opendata.dwd.de/weather/maritime/wave_models/)
- [Quality controlled insitu measurements via seastate portal operated by The Federal Maritime and Hydrographic Agency (BSH)](https://www.bsh.de/EN/DATA/Climate-and-Sea/Sea_state/sea_state_node.html)
- [Global Self-consistent, Hierarchical, High-resolution Geography Database (GSHHG)](https://www.soest.hawaii.edu/pwessel/gshhg/)

# Literature
[1] Wamdi Group (1988). The WAM Model—A Third Generation Ocean Wave Prediction Model. In Journal of Physical Oceanography (Vol. 18, Issue 12, pp. 1775–1810). American Meteorological Society. https://doi.org/10.1175/1520-0485(1988)018<1775:twmtgo>2.0.co;2

[2] Behrens, A. Development of an ensemble prediction system for ocean surface waves in a coastal area. Ocean Dynamics 65, 469–486 (2015). https://doi.org/10.1007/s10236-015-0825-y

[3] Wessel, P., & Smith, W. H. F. (1996). A global, self‐consistent, hierarchical, high‐resolution shoreline database. In Journal of Geophysical Research: Solid Earth (Vol. 101, Issue B4, pp. 8741–8743). American Geophysical Union (AGU). https://doi.org/10.1029/96jb00104

[4] Crameri, F. (2023). Scientific colour maps (8.0.1). Zenodo. https://doi.org/10.5281/ZENODO.1243862

[5] Amidror, I. (2002). Scattered data interpolation methods for electronic imaging systems: a survey. In Journal of Electronic Imaging (Vol. 11, Issue 2, p. 157). SPIE-Intl Soc Optical Eng. https://doi.org/10.1117/1.1455013


# License
   This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or(at your option) any later  version.  

   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
   
   See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.


# Seastate module dummy data
You can directly test the module with the dummy data from the repository. For the time period from 2024-03-22 to 2024-03-25 you can find
- _50_dummyData/10_forecast_: Forecast data as .nc files (either for CWAM or EWAM)
- _50_dummyData/insitu_: Insitu data for 13 sites as .dat files (either from _DWR_ seastate buoys, or _RADAC_ wave radars)

## How to run the module with the dummy data
There are two different ways to use the module:
1. Via **Matlab GUI** by using _20_matlab/10_scripts/testSeastateMasterFnc.m_
2. Via **Matlab runtime environment** by using compiled .exe _seastateModule_vX_Y.exe_ and batch-file _seastateInputDummy.bat_ in the folder _30_execution/_

Both offer the same functionality. You have to set the input parameters either in the batch file (Option 1) or in the _testSeastateMasterFnc.m_ (Option 2) before the actual master function is called (line ~80). Since the toolbox is designed to work with batch-file inputs, some parameters (e.g. cellstrings) have to be defined in an unusual pattern for Option 2. Keep this input format and use the default as a guide. 

### Mandatory Adjustments in _Matlab runtime environment_ / _Batch-File_
- Update paths **p1** - **p9** according to your local system, ensuring that they are pointing to the respective repository directories (**Mandatory!**) You can also create an output-folder outside the repository and adjust the respective parameters **p6**, **p7**, **p8** accordingly. 
- Update insitu settings **i1** - **i12** (_optional_, e.g. switch between CWAM and EWAM settings)
- Update figure settings **f1** - **f15** (_optional_)
- You don't need to change the **l1** setting for manual time shift. As long as dummy mode is activated (**d1=1**), always the same point in time will be evaluated.
- After executing the batch-file or the testScript, logFiles, figures and data output will be generated and saved in .../50_dummyData/30_output





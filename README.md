# Seastate module
short description of the insitu-adjusted WAM Forecast.

# Execution time
Sensor timestamps:
- DWR HIS & GPS: End of measuring interval
- DWR HIW: Beginning of measuring interval
- RADAC & RADAC_SINGLE: Mid of measuring interval

Time convention seastate module: Mid of measuring interval. While importing, timestamps will be adjusted to time convention if needed.
- HIS & GPS --> -15 minutes
- HIW --> + 15 minutes

The evaluation time (time2Eval) is determined by 
- Determining the current UTC time when script starts
- Rounding current time to last half hour
- Substract 15 minutes to be at mid of measuring interval (XX:15 or XX:45)
- Substract manual _timeshift_ which is defined in Batch file

# Seegangsmodul

## Aufbau
Das Repository besteht aus den drei Verzeichnissen 
1. 10_inputFiles
2. 20_matlab
3. 30_execution

### 10_inputFiles
Hier sind die notwendigen Input-Dateien zu insitu Header-Informationen (DWR_GPS, DWR_HIS, DWR_HIW, RADAC und RADAC_SINGLE), GSHHS-Coastline data, sowie der .xlsx siteOverview Datei (enthält Infos Koordinaten, installierte Sensoren, Wassertiefe für jeden Standort) abgelegt. Daten müssen nicht angepasst werden, es müssen lediglich die Pfade zu den jeweiligen Verzeichnissen in der Batch-Datei (siehe unten) definiert werden.

### 20_matlab
Hier befinden sich die erstellten [Skripte](https://gitlab.projekt.uni-hannover.de/lufi-openrave/seegangsmodul/-/tree/master/20_matlab/10_scripts) und die dafür benötigten Funktionen. 

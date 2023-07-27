# Seegangsmodul

## Aufbau
Das Repository besteht aus den drei Verzeichnissen 
- 10_inputFiles
- 20_matlab
- 30_execution


### 10_inputFiles
Hier sind die notwendigen Input-Dateien zu insitu Header-Informationen (DWR_GPS, DWR_HIS, DWR_HIW, RADAC und RADAC_SINGLE), GSHHS-Coastline data, sowie der .xlsx siteOverview Datei (enthält Infos Koordinaten, installierte Sensoren, Wassertiefe für jeden Standort) abgelegt. Daten müssen nicht angepasst werden, es müssen lediglich die Pfade zu den jeweiligen Verzeichnissen in der Batch-Datei (siehe unten) definiert werden.

### 20_matlab
Hier befinden sich die erstellten Matlab [Skripte](https://gitlab.projekt.uni-hannover.de/lufi-openrave/seegangsmodul/-/tree/master/20_matlab/10_scripts) und die ausgelagerten [Funktionen](https://gitlab.uni-hannover.de/lufi_ag_offshore/seegangsmodul/-/tree/main/10_matlab/20_functions). 
Das _Seegangsmodul_ ist als Funktion [seastateMasterFnc](https://gitlab.projekt.uni-hannover.de/lufi-openrave/seegangsmodul/-/blob/master/20_matlab/10_scripts/seastateMasterFnc.m) erstellt worden. Diese kann kompiliert werden kann, um in einer Matlab runtime-Environemnt gestartet zu werden. Zum Kompilieren liegt das Skript [compileSeastateFnc] 

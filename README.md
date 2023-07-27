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
- Das _Seegangsmodul_ ist als Funktion [seastateMasterFnc](https://gitlab.projekt.uni-hannover.de/lufi-openrave/seegangsmodul/-/blob/master/20_matlab/10_scripts/seastateMasterFnc.m) erstellt worden. Diese kann kompiliert werden kann, um in einer Matlab runtime-Environemnt gestartet zu werden. 
- Zum Kompilieren liegt das Skript [compileSeastateMasterFnc](https://gitlab.projekt.uni-hannover.de/lufi-openrave/seegangsmodul/-/blob/master/20_matlab/10_scripts/compileSeastateMasterFnc.m) vor. Nach Anpassen des _scriptPath_ (lokaler Pfad des Matlab-Skripts), _fnctPath_ (lokaler Pfad zu Matlab-Funktionen), _outputFolder_ (Verzeichnis, in dem .exe erstellt werden soll),_outputName_ (Name der .exe), wird das _Seegangsmodul_ mit dem _mcc_ Befehl kompiliert.
- Das Skript [testSeastateMasterFnc](https://gitlab.projekt.uni-hannover.de/lufi-openrave/seegangsmodul/-/blob/master/20_matlab/10_scripts/testSeastateMasterFnc.m) dient zum Testen und Debuggen des _Seegangsmoduls_ in der Matlab-Application Umgebung.

### 30_execution
Hier befindet sich die bereits kompilierte .exe (für die Ausführung am LuFI) und das Batch-Skript [seastateInput.bat](https://gitlab.projekt.uni-hannover.de/lufi-openrave/seegangsmodul/-/blob/master/30_execution/seastateInput.bat). Über die Batch werden die notwendigen Input-Parameter definiert und die kompilierte .exe gestartet. 

### Batch-Input
- **Set Paths**: Die Input-Pfade müssen für das lokale System angepasst werden. Initial sind hier die LuFI-Pfade hinterlegt. Die Matlab-Funktion _seastateMasterFnc_ wurde so programmiert, dass die Pfade in der Batch-Datei im Matlab Cellstring-Format {'...'} definiert werden müssen.
- **Insitu settings**: Wahl der zu berücksichtigen Messstandorte, Hs-Parameternamen, WAM-Modell
- **Spatial settings**: Wahl der lon/lat Grenzen und Auflösung für die flächige 2D-Matrix und dessen Visualisierung. Es können die default Einstellungen für cwam bzw. ewam durch Kommentieren/Auskommentieren der entsprechenden Zeilen übernommen werden.
- **Figure settings**: Wahl von Figure-Typ, Colorbar-Typ, Dateityp für Export und Auflösung.
- **LuFI testing**: Lediglich für Testbetrieb am LuFI notwendig, da hier die aktuellsten insitu Daten nur für den Vortag vorliegen. Das Seegangsmodul ermittelt den aktuellen Ausführungszeitpunkt und rundet die Uhrzeit auf die nächste halbe Stunde ab (18:03 wird z.B. 18:00 Uhr). Durch den in diesem Abschnitt definierten _manuellen Timeshift_ kann der Untersuchungszeitpunkt um X Stunden in die Vergangenheit verschoben werden.

## To Dos zur Test-Implementierung am BSH:

- [ ] Ordnerstruktur vorbereiten:
- Insitu-Daten müssen in folgender Verzeichnis-Struktur vorliegen: _dataPath/Site/Sensor/*.dat_. Mögliche Sensoren sind _dwr_, _radac_, _radacSingle_. Für _Site_ werden die Kürzel aus drei Ziffern (z.B. FN1 für FINO1) verwendet. Die erste Parameter in der Batch-Datei verweist auf das _dataPath_ Verzeichnis.
- WAM-Files (*.nc) müssen in folgender Verzeichnis-Struktur vorliegen: _wamPath/wamType/*.nc_. Mögliche _wamType_ sind _cwam_ oder _ewam_. Der entsprechende Pfad in der Batch-Datei verweist auf das Verzeichnis _wamPath_.
- Lokale Output-Folder anlegen. In der Batch-Datei werden drei Output-Pfade definiert für _log folder_, _figure folder_ und _exportData folder_. Im lokalen System müssen entsprechende Output-Verzeichnisse angelegt werden und in der Batch-Datei darauf verwiesen werden (Es kann auch dasselbe Verzeichnis für alle drei Outputs angegeben werden).
- [ ] Seegangsmodul kompilieren. _[compileSeastateMasterFnc](https://gitlab.projekt.uni-hannover.de/lufi-openrave/seegangsmodul/-/blob/master/20_matlab/10_scripts/compileSeastateMasterFnc.m) entsprechend anpassen und .exe erstellen und testen. 
- [ ] Automatische 30minütige Ausführung für Testbetrieb aufsetzen. 





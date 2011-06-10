mapViewer 0.4 f�r Landwirtschafts Simulator 2011
=================================================
Zeigt die komplette Map auf dem gesamten Bildschirm an. 
Wer kennt es nicht, man ruft die PDA Map auf und hat keinen �berblick �ber die gesamte Fl�che...
Zeigt die Fahrzeuge, Anbauger�te und Spieler auf der Karte an.

Besonders im Multiplayer ist es n�tzlich zu wissen wer sich gerade wo auf der Karte befindet.

Voll Multiplayer f�hig, es werden alle Spieler angezeigt
Informationen dar�ber wie �ber die Point of Interest (PoI) angezeigt werden befinden sich in der PDF im Docs Ordner

Auch welche Parameter in der XML eingestellt werden k�nnen ist dort beschrieben.
Besonders die unabh�ngigkeit zu den Maps war ein Feature was ich schon lange versucht habe umzusetzen. Nun endlich ist es mir gelunden.
Es muss nicht mehr f�r jede Map eine eigene Mapviewer zip angelegt werden.

Taste(n) :
----------
Die Tasten lassen sich �ber die Optionen anpassen
m	 		=	Anzeigen/Ausblenden
N			=	Legende Ein/Ausblenden
NP +/-		=	Transparenz +/-
y           =   Zus�tzliche Overlay umschalet Feldnummern und PoI
Alt * M     = Mapgr�sse wechseln 2048 oder 4096

Anzeige :
---------
Grafiken als Symbole verwendet siehe beigef�gter Beschreibung/Screenshot im Docs Ordner.

*! Abweichende Positionen h�ngen von der Qualit�t der PDA Map ab, also Mapper gebt euch M�he :) !**

Autor: Fox-Alpha
Kontakt: fox-alpha@tarnhoerner.de
Exclusiv Mod www.MODHOSTER.de

RoadMap
=======
0.5		- Infofenster zu einzelnen Fahrzeugen �hnlich dem Inspector
			- Durchschaltbar und permanent anzeige

Changelog
=========
V0.4

      + Dynamisches laden der PDA Map aus der verwendendeten Karte
        - /map01/pda_map.png/.dds
        - Kein manuelles bearbeiten der ZIP Datei mehr notwendig
        - Klappt auf allen getesteten Karten

      + Laden der Feldnummern aus dem Mapzip, wenn vorhanden
        - /map01/MV_Feldnummern.png
      
      + Laden der PoI aus dem Mapzip, wenn vorhanden
        - /map01/MV_PoI.png
      
      + Umschalten der Mapgroesse von 2048 auf 4096
        - Keine Einstellungen mehr in der XML notwendig
        + ALT+M Umschalten der Mapgroesse von 2048 auf 4096

      + Durchschalten der PoI und Feldnummern
        + Kann PoI und Feldnummern als seperates Overlay laden
        - Feldnummern und PoI k�nnen als eigene Overlay Dateien in der xml hinterlegt werden
        + Y Durchschalten der PoI und Feldnummern
        
      + Aufr�umen des Quelltextes
        -- �berfl�ssige Scriptzeilene entfernt
        -- Bessere Kommentare eingef�gt
			
0.34	-Modverzeichnis einwenig umstrukturiert
		-Viele Variable in die Mapviewer.xml ausgelagert
			Es ist nicht mehr n�tigt die LUA zu bearbeiten
		-Maplegende um ein Overlay f�r interessante Orte erweitert + Feldnummerierung
			-PoI l�sst sich in der XML ausschalten
		-Es l�sst sich nun die Karten transparenz einstellen. 
			So ist es m�glich auch w�hrend der Fahrt auf die Map zu schauen.
			Aktueller Wert wird oben in der Mitte angezeigt
		-Es lassen sich alle beliebigen Karten einbinden.
			- Sogar 4096 Karten lassen sich einblenden, hierf�r muss nur eine passende pda_Map.png/dds vorhanden sein.
		-Readme �bersetzung deutsch/englisch

0.31	Tasten lassen sich �ber die Optionen anpassen
		Es l�sst sich auf der Map eine Legende einblenden
		Viele kleine Verbesserungen am Script

0.25	Neue Symbole eingef�gt
		Taste von Space auf 'm' umgelegt

0.2		Erweiterte Version
		- Zeigt die Karten HotSpots jetzt auch in der Gro�ansicht
		- Zeigt die Spielernamen in der PDA Map an
		
0.1		Erste Version zum Download

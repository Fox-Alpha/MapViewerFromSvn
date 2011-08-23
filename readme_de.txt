mapViewer 0.5 f�r Landwirtschafts Simulator 2011
=================================================
Zeigt die komplette Map auf dem gesamten Bildschirm an. 
Wer kennt es nicht, man ruft die PDA Map auf und hat keinen �berblick �ber die gesamte Fl�che...
Zeigt die Fahrzeuge, Anbauger�te und Spieler auf der Karte an.

Besonders im Multiplayer ist es n�tzlich zu wissen wer sich gerade wo auf der Karte befindet.

Voll Multiplayer f�hig, es werden alle Spieler angezeigt

Kompatible mit nahezu allen Maps. Egal ob diese eine Gr��e von 2048 oder 4096 haben. Die Gr��e kann per Taste angepasst werden.
Zus�tzliche Anzeigen wie Feldnummern und PoI m�ssen von der Map unterst�tzt werden. Es ist nicht mehr n�tig f�r jede Map eine eigene MapViewer Version zu haben.

Taste(n) :
----------
Die Tasten lassen sich �ber die Optionen anpassen
Einf�gen	 	=	Anzeigen/Ausblenden
Entfernen		=	Legende Ein/Ausblenden
NP +/-		    =	Transparenz +/-
Ende            =   Zus�tzliche Overlay umschalet Feldnummern und PoI
Alt * M         = Mapgr�sse wechseln 2048 oder 4096

Anzeige :
---------
Grafiken als Symbole verwendet siehe beigef�gter Beschreibung/Screenshot im Docs Ordner.

*! Abweichende Positionen h�ngen von der Qualit�t der PDA Map ab, also Mapper gebt euch M�he :) !**

Autor: Fox-Alpha
Kontakt: fox-alpha@tarnhoerner.de
Exclusiv Mod www.MODHOSTER.de

Aktuelle Version
================
0.5
        - Unterst�tzung des CoursePlay (CP 2.11) 
            - Einblenden der aktiven Kurse aller Fahrzeuge
        - Anzeige von unbrauchbaren Fahrzeugen (z.B. wenn diese zu tief im Wasser stehen) als eigenes Symbol
        - Bottlefinder 
            - Anzeige der Bottlepositionen auf der Map (Single- und Multiplay)
        - Tastenbezeichnungen so angepasst das diese in den Optionen eindeutig erkannt werden k�nnen 
            - Diese beginnen nun mit "MapViewer" in den Spieloptionen
        - Anzeigen des aktiven Modus bei aktiver Karte
        - Fehlermeldungen und andere Logausgaben mehr Aussagekr�ftig und Mehrsprachig und in XML auslagern 
        - Bessere Unterscheidung der Ger�te Typen
            - Jeder Ger�tettyp hat sein Symbol mit eigener Farbe
            - Legende um neue Symbolbeschreibungen erweitert
        - �bersetzungen 
            - Viele Textteile in Englisch und Deutsch vorhanden
            - Fehlermeldungen und Bezeichnungen
        - Tastaturbelegung
            - Standardtasten umbelegt
                - Aktivieren = Einf�gen
                - Legende = Entfernen
                - Overlay durchschalten = Ende
        - Speichern und laden der letzten Einstellungen mit dem Spielstand
            - Transparenz
            - Aktiver Overlay

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

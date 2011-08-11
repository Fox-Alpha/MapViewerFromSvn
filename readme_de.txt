mapViewer 0.4 für Landwirtschafts Simulator 2011
=================================================
Zeigt die komplette Map auf dem gesamten Bildschirm an. 
Wer kennt es nicht, man ruft die PDA Map auf und hat keinen Überblick über die gesamte Fläche...
Zeigt die Fahrzeuge, Anbaugeräte und Spieler auf der Karte an.

Besonders im Multiplayer ist es nützlich zu wissen wer sich gerade wo auf der Karte befindet.

Voll Multiplayer fähig, es werden alle Spieler angezeigt
Informationen darüber wie über die Point of Interest (PoI) angezeigt werden befinden sich in der PDF im Docs Ordner

Auch welche Parameter in der XML eingestellt werden können ist dort beschrieben.
Besonders die unabhängigkeit zu den Maps war ein Feature was ich schon lange versucht habe umzusetzen. Nun endlich ist es mir gelunden.
Es muss nicht mehr für jede Map eine eigene Mapviewer zip angelegt werden.

Taste(n) :
----------
Die Tasten lassen sich über die Optionen anpassen
Einfügen	 	=	Anzeigen/Ausblenden
Entfernen		=	Legende Ein/Ausblenden
NP +/-		    =	Transparenz +/-
Ende            =   Zusätzliche Overlay umschalet Feldnummern und PoI
Alt * M         = Mapgrösse wechseln 2048 oder 4096

Anzeige :
---------
Grafiken als Symbole verwendet siehe beigefügter Beschreibung/Screenshot im Docs Ordner.

*! Abweichende Positionen hängen von der Qualität der PDA Map ab, also Mapper gebt euch Mühe :) !**

Autor: Fox-Alpha
Kontakt: fox-alpha@tarnhoerner.de
Exclusiv Mod www.MODHOSTER.de

Aktuelle Version
================
0.5
        - Unterstützung des CoursePlay (CP 2.11) 
            - Einblenden der aktiven Kurse aller Fahrzeuge
        - Anzeige von unbrauchbaren Fahrzeugen (z.B. wenn diese zu tief im Wasser stehen) als eigenes Symbol
        - Bottlefinder 
            - Anzeige der Bottlepositionen auf der Map (Single- und Multiplay)
        - Tastenbezeichnungen so angepasst das diese in den Optionen eindeutig erkannt werden können 
            - Diese beginnen nun mit "MapViewer" in den Spieloptionen
        - Anzeigen des aktiven Modus bei aktiver Karte
        - Fehlermeldungen und andere Logausgaben mehr Aussagekräftig und Mehrsprachig und in XML auslagern 
        - Bessere Unterscheidung der Geräte Typen
            - Jeder Gerätettyp hat sein Symbol mit eigener Farbe
            - Legende um neue Symbolbeschreibungen erweitert
        - Übersetzungen 
            - Viele Textteile in Englisch und Deutsch vorhanden
            - Fehlermeldungen und Bezeichnungen
        - Tastaturbelegung
            - Standardtasten umbelegt
                - Aktivieren = Einfügen
                - Legende = Entfernen
                - Overlay durchschalten = Ende
        - Speichern der letzten Einstellungen mit dem Spielstand
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
        - Feldnummern und PoI können als eigene Overlay Dateien in der xml hinterlegt werden
        + Y Durchschalten der PoI und Feldnummern
        
      + Aufräumen des Quelltextes
        -- Überflüssige Scriptzeilene entfernt
        -- Bessere Kommentare eingefügt
			
0.34	-Modverzeichnis einwenig umstrukturiert
		-Viele Variable in die Mapviewer.xml ausgelagert
			Es ist nicht mehr nötigt die LUA zu bearbeiten
		-Maplegende um ein Overlay für interessante Orte erweitert + Feldnummerierung
			-PoI lässt sich in der XML ausschalten
		-Es lässt sich nun die Karten transparenz einstellen. 
			So ist es möglich auch während der Fahrt auf die Map zu schauen.
			Aktueller Wert wird oben in der Mitte angezeigt
		-Es lassen sich alle beliebigen Karten einbinden.
			- Sogar 4096 Karten lassen sich einblenden, hierfür muss nur eine passende pda_Map.png/dds vorhanden sein.
		-Readme Übersetzung deutsch/englisch

0.31	Tasten lassen sich über die Optionen anpassen
		Es lässt sich auf der Map eine Legende einblenden
		Viele kleine Verbesserungen am Script

0.25	Neue Symbole eingefügt
		Taste von Space auf 'm' umgelegt

0.2		Erweiterte Version
		- Zeigt die Karten HotSpots jetzt auch in der Großansicht
		- Zeigt die Spielernamen in der PDA Map an
		
0.1		Erste Version zum Download

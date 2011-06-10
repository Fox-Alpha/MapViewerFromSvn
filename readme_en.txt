mapViewer 0.34 for Farming Simulator 2011
=================================================
Shows the complete PDAMap as fullscreen overlay.

Who doesn't know it, you look on the map but you cant't sea where you looking for or you would know where your mate are working.

This map shows all you need. Vehicle, Attachments and all other Play with name.

mapViewer is optimize for FS11 default Map. Now it can be used for all Maps with PDA_Map

Full multiplayer support !

Keys :
----------
You can change all Keybindings in your gameoptions

m	 		=	activate/deactivate the map
N			=	Shows little symbol description
NP +/-		=	increasy/decrease Transparenz +/-
y           =   Change Overlay between Fieldnumber and/or PoI
Alt+m       =   Change Mapsize from 2024 to 4096 and back

Symbols :
---------
Little Grafiks for Vehicles/Attachments/Player look in Docs folder for Screenshots

Author: Fox-Alpha
Kontakt: fox-alpha@tarnhoerner.de
Exclusiv Mod www.MODHOSTER.de


RoadMap
=======
0.5		- Infofenster zu einzelnen Fahrzeugen ähnlich dem Inspector
			- Durchschaltbar und permanent anzeige

Changelog (Sorry no translation, coming soon)
=========
V0.4

      + Dynamisches laden der PDA Map aus der verwendendeten Karte
        - /map01/pda_map.png/.dds
        - Kein manuelles bearbeiten der ZIP Datei mehr notwendig
        - Klappt auf allen getesteten Karten

      + Laden der Feldnummern aus dem Mapzip, wenn vorhanden
        - /map01/MV_Feldnummern.png
        - Grafik für Standardmap im zip enthalten
      
      + Laden der PoI aus dem Mapzip, wenn vorhanden
        - /map01/MV_PoI.png
        - Grafik für Standardmap im zip enthalten
      
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

Attribute VB_Name = "mSymbolischeAdresse"
' Skript zur Ermittlung der symbolischen Adressen
' V1.3
'07.02.2020
'angepasst um alle Leerzeichen zu entfernen in den Symbolischen Adressen
'
' Christian Langrock
' christian.langrock@actemium.de
'@folder (Daten.Symbolische_Adresse)

Option Explicit

Public Sub symbolische_Adresse()


    Dim wkb As Workbook
    Dim ws1 As Worksheet
    Dim tabelleDaten As String
    Dim zeilenanzahl As Long
    Dim i As Long
      
    ' Tabellen definieren
    tabelleDaten = "EplSheet"

    Set wkb = ActiveWorkbook
    Set ws1 = Worksheets.[_Default](tabelleDaten)
   
    Application.ScreenUpdating = False

    ' Tabelle mit Daten bearbeiten
    With ws1
   
        ' Herausfinden der Anzahl der Zeilen
        zeilenanzahl = .Cells.Item(Rows.Count, 2).End(xlUp).Row ' zweite Spalte wird gez�hlt
        'MsgBox zeilenanzahl

        '*********** symbolische Adresse erzeugen und umkopieren ******************


        ' Spaltenbreiten anpassen
        ActiveSheet.Columns.Item("BJ").Select
        Selection.ColumnWidth = 35


        For i = 3 To zeilenanzahl
            .Cells.Item(i, "BJ") = Trim$(.Cells.Item(i, "B")) 'f�hrende Leerzeichen entfernen
        Next i

    End With
End Sub

Attribute VB_Name = "mEinbauorte"
' Skript zur Ermittlung der Anlagen und Ortskennzeichen der IO-Racks
' V0.7
' abgetrennt aus SPSRackBMK
' 02.03.2020
' angepasst f?r MH04
'
' Christian Langrock
' christian.langrock@actemium.de
 '@folder(Kennzeichen.Einbauorte)
Option Explicit

Public Sub EinbauorteSchreiben()
   
    ' lesen der Einbauorte aus der Exceltabelle und schreiben der Felder "Einbauort" und "Einbauort des SPS-Rack?s"
    Dim EinbauorteData As New cEinbauorte        'Klasse anlegen f?r Datenaustausch

    Dim zeilenanzahl As Long
    Dim i As Long
    Dim j As Long
    Dim ws1 As Worksheet
    Dim TabelleDaten As String
    Dim SpalteStationsnummer As String
    Dim spalteEinbauortRack As String
    Dim SpalteEinbauort As String
    Dim spalteStationstyp As String
    Dim sResult As cEinbauorte
    Dim iSearchNumber As Long
    Dim iSpalteStationstyp As Long
    Dim tmpSpalteStationstyp As Long
    Dim ExcelConfig As New cExcelConfig
    
    'Tabellenamen ermitteln
    ' Tabellen definieren
    TabelleDaten = ExcelConfig.TabelleDaten
    
    SpalteStationsnummer = ExcelConfig.Stationsnummer
    spalteEinbauortRack = ExcelConfig.SPSRackEinbauort
    SpalteEinbauort = ExcelConfig.EinbauortEinzel
    spalteStationstyp = ExcelConfig.Kartentyp
    
    Set ws1 = Worksheets.[_Default](TabelleDaten)
    iSpalteStationstyp = SpaltenBuchstaben2Int(spalteStationstyp)
   
    Application.ScreenUpdating = False

    ' Tabelle mit Planungsdaten auslesen
    With ws1
        'Filter aus, aber nicht l?schen
        If ActiveSheet.FilterMode Then ActiveSheet.ShowAllData
                
        'hier einlesen der Daten aus der Exceltabelle Einbauorte f?r die einzelnen Anlagen
        Set EinbauorteData = readEinbauorte(TabelleDaten)
        
        ' Spaltenbreiten anpassen
        ThisWorkbook.Worksheets.[_Default](TabelleDaten).Activate
        ActiveSheet.Columns.Item(SpalteEinbauort).Select
        '.Columns.Item(spalteEinbauort).Select
        Selection.ColumnWidth = 15
        ActiveSheet.Columns.Item(spalteEinbauortRack).Select
        Selection.ColumnWidth = 15

        'Herausfinden der Anzahl der Zeilen im Blatt der Vorplanungsdaten
        zeilenanzahl = .Cells.Item(Rows.Count, 2).End(xlUp).Row ' zweite Spalte wird gez?hlt
        'MsgBox zeilenanzahl

        For i = 3 To zeilenanzahl
            iSearchNumber = .Cells.Item(i, SpalteStationsnummer)

            'Suchen nach den passenden Einbauort zur Station
            Set sResult = Nothing
            Set sResult = EinbauorteData.searchEinbauortDataset(iSearchNumber)
            
            If Not (sResult Is Nothing) Then     ' pr?fen ob etwas zur?ck kam
                If sResult.Count > 0 Then        ' nur weiter wenn Datensatz wirklich da
                    ' Einbauort des SPS-Racks schreiben
                    If .Cells.Item(i, spalteEinbauortRack) = sResult.Item(1).Einbauort And (Not Trim$(sResult.Item(1).Einbauort) = Empty) Then
                        ' Wenn gleich dann gr?n einf?rben
                        .Cells.Item(i, spalteEinbauortRack).Interior.ColorIndex = 35
                    Else                         ' sonst gelb einf?rben
                        .Cells.Item(i, spalteEinbauortRack).Interior.ColorIndex = 6
                    End If
                    .Cells.Item(i, spalteEinbauortRack) = sResult.Item(1).Einbauort
                    If (Left$(sResult.Item(1).Einbauort, 2) <> "S1" And Left$(sResult.Item(1).Einbauort, 2) <> "S2" And Left$(sResult.Item(1).Einbauort, 2) <> "S3" And Left$(sResult.Item(1).Einbauort, 2) <> "Sx" And Left$(sResult.Item(1).Einbauort, 2) <> "SX") Or (Trim$(sResult.Item(1).Einbauort) = Empty) Then
                        ' Einbauort schreiben
                        If .Cells.Item(i, SpalteEinbauort) = sResult.Item(1).Einbauort Then
                            ' Wenn gleich dann gr?n einf?rben
                            .Cells.Item(i, SpalteEinbauort).Interior.ColorIndex = 35
                        Else                     ' sonst gelb einf?rben
                            .Cells.Item(i, SpalteEinbauort).Interior.ColorIndex = 6
                        End If
                        .Cells.Item(i, SpalteEinbauort) = sResult.Item(1).Einbauort
                    Else
                        ' makiere fehlende / falsche Steckplatz Daten
                        .Cells.Item(i, SpalteEinbauort).Interior.ColorIndex = 3
                        .Cells.Item(i, spalteEinbauortRack).Interior.ColorIndex = 3
                    End If
                    ' Stationstyp schreiben wenn IFM Master
                    For j = 0 To 5
                        tmpSpalteStationstyp = iSpalteStationstyp + (j * 14)
                        If .Cells.Item(i, tmpSpalteStationstyp) = "IFM IO-LINK" Or .Cells.Item(i, tmpSpalteStationstyp) = "AL1400" Or .Cells.Item(i, tmpSpalteStationstyp) = "AL1402" Then
                            .Cells.Item(i, tmpSpalteStationstyp) = sResult.Item(1).Geraetetyp
                            .Cells.Item(i, tmpSpalteStationstyp - 1) = "IFM IO-LINK"
                        End If
                    Next j
                    ' FU schreiben
                    If sResult.Item(1).Geraetetyp = "FU" Then
                        .Cells.Item(i, iSpalteStationstyp) = sResult.Item(1).Geraetetyp
                        .Cells.Item(i, iSpalteStationstyp - 1) = sResult.Item(1).Geraetetyp
                        
                    End If
                End If
            End If
        Next i
    End With
    MsgBox "Daten gelesen und geschrieben. Spalte Einbauort kontollieren"

End Sub

Public Function readEinbauorte(ByVal TabelleDaten As String) As cEinbauorte
    'return dataset with all installation locations per project
    Dim tablennameEinbauorte As String
    Dim ws1 As Worksheet
    Dim dataKWSBMK As String
    Dim spalteKWS_BMK As String
    Dim EinbauorteData As New cEinbauorte        'Klasse anlegen f?r Datenaustausch
    Dim ExcelConfig As New cExcelConfig
    
    spalteKWS_BMK = ExcelConfig.KWSBMK
    tablennameEinbauorte = vbNullString
     
    Set ws1 = Worksheets.[_Default](TabelleDaten)
     
    ' Tabelle mit Planungsdaten auslesen
    With ws1
        Application.ScreenUpdating = False
        'Filter aus, aber nicht l?schen
        If ActiveSheet.FilterMode Then ActiveSheet.ShowAllData
        
        dataKWSBMK = LTrim$(.Cells.Item(3, spalteKWS_BMK))
    
        If dataKWSBMK <> vbNullString Then
            If Left$(dataKWSBMK, 3) = "BAP" Then
                tablennameEinbauorte = "Einbauorte_BAP"
            ElseIf Left$(dataKWSBMK, 4) = "SG01" Then
                tablennameEinbauorte = "Einbauorte_H02.SG01"
            ElseIf Left$(dataKWSBMK, 4) = "HDMA" Then
                tablennameEinbauorte = "Einbauorte_H03.HDMA"
            ElseIf Left$(dataKWSBMK, 3) = "PPP" Then
                tablennameEinbauorte = "Einbauorte_MH04.PPP"
            ElseIf Left$(dataKWSBMK, 5) = "SRN01" Then
                tablennameEinbauorte = "Einbauorte_MH04.SRN"
            ElseIf Left$(dataKWSBMK, 5) = "TRP01" Then
                tablennameEinbauorte = "Einbauorte_MH03.TRP01"
            ElseIf Left$(dataKWSBMK, 5) = "TRP03" Then
                tablennameEinbauorte = "Einbauorte_MH03.TRP03"
            ElseIf Left$(dataKWSBMK, 5) = "EPD02" Then
                tablennameEinbauorte = "Einbauorte_H05.EPD02"
            ElseIf Left$(dataKWSBMK, 4) = "TRP." Then
                tablennameEinbauorte = "Einbauorte_MH04.TRP"
            Else
                MsgBox "Keine passenden Daten mit Einbauorten gefunden, f?r KWS-BMK: " & dataKWSBMK
                tablennameEinbauorte = vbNullString
                Exit Function                    ' hier dann Abbruch der ganzen Funktion
            End If
        Else
            MsgBox "Fehler in Daten, KWS-BMK erwartet"
        End If
    
        ' hier einlesen der Daten aus der Exceltabelle Einbauorte f?r die einzelnen Anlagen
        EinbauorteData.ReadExcelDataToCollection tablennameEinbauorte, EinbauorteData
              
    End With
    Set readEinbauorte = EinbauorteData
End Function






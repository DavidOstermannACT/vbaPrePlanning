Attribute VB_Name = "mCPXDatenErgaenzen"
' Skript zur Korrektur der Festo Anschlussdaten
' V0.3
' 08.04.2020
' Christian Langrock
' christian.langrock@actemium.de
' Mohammad Safaadin Hussein
' Mohammad.SafaadinHussein@actemium.de


'@folder (Daten.SPS-Anschl?sse)
 
 Option Explicit

Public Sub CPXDatenErgaenzen()

    Dim TabelleDaten As String
    Dim Karten As Variant
    Dim bAdressLaenge As Long                    'ben?tigte Adresslaenge f?r Berechnungen
    Dim bLastAdressPos As Long                   'ben?tigte Letzte Adress-Stelle f?r Berechnungen
    Dim sPerPLCtypKanaeleAdress2 As String       'Adresse f?r SPSKanal 2
    Dim iSubAnschluss As Long
    
    Dim ExcelConfig As cExcelConfig
    Set ExcelConfig = New cExcelConfig
    Dim sKartentyp As Collection
    Set sKartentyp = New Collection
    Dim dataKanaele As cKanalBelegungen
    Set dataKanaele = New cKanalBelegungen
    Dim sKanaele As cBelegung
    Set sKanaele = New cBelegung
    Dim sPerPLCtypKanaele As cBelegung
    Set sPerPLCtypKanaele = New cBelegung
    Dim sortKanaele As cKanalBelegungen
    'Set sortKanaele = New cKanalBelegungen
    Dim dataSearchPlcTyp As cKanalBelegungen     'neu  CL
    Set dataSearchPlcTyp = New cKanalBelegungen
    Dim rData As cKanalBelegungen
    Set rData = New cKanalBelegungen
    Dim sResult As cBelegung
    Set sResult = New cBelegung
   
    ' Tabellen definieren
    TabelleDaten = ExcelConfig.TabelleDaten

    ' Kartentypen definieren
    sKartentyp.Add "CPX 5/2 bistabil"
    sKartentyp.Add "CPX 2x3/2 mono"
    sKartentyp.Add "CPX 5/2 mono"
    
    iSubAnschluss = 0
  
    '##### lesen der belegten Kan?le aus Excel Tabelle #####
    dataKanaele.ReadExcelDataChanelToCollection TabelleDaten, dataKanaele 'Auslesen der DAten aus Excelliste
    
    Set sortKanaele = dataKanaele.Sort           'Sortieren nach spalteStationsnummer, spalteKartentyp
    '##### Daten bearbeiten #####
    For Each Karten In sKartentyp
    
        Set dataSearchPlcTyp = sortKanaele.searchDatasetPlcModules(Karten) 'neu  CL Suchen nach dem einen Kartentyp
 
        For Each sPerPLCtypKanaele In dataSearchPlcTyp 'neu CL f?r jeden Datensatz mit dem Kartentyp einmal durchlaufen
            'neu CL schreiben der Daten f?r das 2.SPS Signal der 5/2 Bistabilen
            If Karten = "CPX 5/2 bistabil" And sPerPLCtypKanaele.Adress <> vbNullString Then
                bAdressLaenge = Len(Trim(sPerPLCtypKanaele.Adress)) - 1 'Adresslaenge - 1 Z.B. "A8503." => 6
                bLastAdressPos = CInt(Right(Trim(sPerPLCtypKanaele.Adress), 1)) + 1 'Letzte Adress-Stelle + 1 z.B. "A8503.0" => 1
                sPerPLCtypKanaeleAdress2 = Left(Trim(sPerPLCtypKanaele.Adress), bAdressLaenge) & bLastAdressPos 'Adresse f?r SPSKanal 2
                
                rData.Add sPerPLCtypKanaele.Key, sPerPLCtypKanaele.KWSBMK, 2, sPerPLCtypKanaele.Stationsnummer, vbNullString, sPerPLCtypKanaele.Steckplatz, sPerPLCtypKanaele.Kanal + 1, sPerPLCtypKanaele.Segmentvorlage, sPerPLCtypKanaeleAdress2, 0, 0, sPerPLCtypKanaele.SPSBMK
                rData.Item(rData.Count).SymbolischeAdresse = sPerPLCtypKanaele.SymbolischeAdresse
            End If
            
            For Each sKanaele In sortKanaele     'neu CL in allen Kanaele nach den passenden Datens?tzen suchen
                If Left(Trim(sPerPLCtypKanaele.KWSBMK), Len(Trim(sPerPLCtypKanaele.KWSBMK)) - 4) = Left(Trim(sKanaele.KWSBMK), Len(Trim(sKanaele.KWSBMK)) - 5) And Right(Trim(sKanaele.KWSBMK), 5) = ".ES01" Then 'suchen nach den Dates?trzen die zusammengeh?ren, Suchen nach .ES01
                       
                    'Neu Signal 5
                    If sPerPLCtypKanaele.Signal = 1 Then
                        sResult.Key = sKanaele.Key
                        sResult.SymbolischeAdresse = sPerPLCtypKanaele.SymbolischeAdresse
                        sResult.Signal = 5
                        sResult.Steckplatz = sPerPLCtypKanaele.Steckplatz
                        sResult.Kanal = sPerPLCtypKanaele.Kanal
                        sResult.Adress = sPerPLCtypKanaele.Adress
                        sResult.KWSBMK = sPerPLCtypKanaele.KWSBMK
                        sResult.SPSBMK = sPerPLCtypKanaele.SPSBMK
                        sResult.Segmentvorlage = sKanaele.Segmentvorlage
                        ' Anschl?sse schreiben
                        iSubAnschluss = sResult.Kanal Mod 2
                        If iSubAnschluss = 0 Then
                            sResult.Anschluss1 = 2
                        Else
                            sResult.Anschluss1 = 4
                        End If
                        sResult.Anschluss2 = sPerPLCtypKanaele.Anschluss2
                    
                        rData.AddDataSet sResult ' Datens?tze von sKanaele in rData schreiben
                    End If
                    
                    'Neu Signal 6
                    If sPerPLCtypKanaele.Signal = 1 And Karten = "CPX 5/2 bistabil" Then
                        sResult.Key = sKanaele.Key
                        sResult.SymbolischeAdresse = sPerPLCtypKanaele.SymbolischeAdresse
                        sResult.Signal = 6
                        sResult.Steckplatz = sPerPLCtypKanaele.Steckplatz
                        sResult.Kanal = sPerPLCtypKanaele.Kanal + 1
                        sResult.Adress = sPerPLCtypKanaeleAdress2
                        sResult.KWSBMK = sPerPLCtypKanaele.KWSBMK
                        sResult.SPSBMK = sPerPLCtypKanaele.SPSBMK
                        sResult.Segmentvorlage = sKanaele.Segmentvorlage
                        ' Anschl?sse schreiben
                        iSubAnschluss = sResult.Kanal Mod 2
                        If iSubAnschluss = 0 Then
                            sResult.Anschluss1 = 2
                        Else
                            sResult.Anschluss1 = 4
                        End If
                        sResult.Anschluss2 = sPerPLCtypKanaele.Anschluss2
                
                        rData.AddDataSet sResult ' Datens?tze von sKanaele in rData schreiben
                    End If
                End If
            Next
        Next
    Next
    '####### Zur?ckschreiben der Daten in urspr?ngliche Excelliste #######
    rData.writeDatsetsToExcel TabelleDaten
End Sub



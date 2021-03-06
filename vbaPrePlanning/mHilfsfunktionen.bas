Attribute VB_Name = "mHilfsfunktionen"
' Hilfsfunktionen die ?fters ben?tigt werden
' V0.5
' 25.02.2020
' neu: import XML
' Christian Langrock
' christian.langrock@actemium.de
'@folder Hilfsfunktionen
Option Explicit

Public Function SpaltenBuchstaben2Int(ByVal pSpalte As String) As Long
    'ermittel der Spaltennummer aus den Spaltenbuchstaben
    SpaltenBuchstaben2Int = Columns.Item(pSpalte).Column
End Function

Public Sub SortTable(ByVal tablename As String, ByVal SortSpalte1 As String, ByVal SortSpalte2 As String, Optional ByVal SortSpalte3 As String)
    ' sortieren von Daten nach drei oder zwei Spalten
    ' Aufrufen der Tabele und Ausw?hlen dieser
    ThisWorkbook.Worksheets.[_Default](tablename).Activate
    ' Anzeige ausschalten
    Application.ScreenUpdating = False
        
    Dim rTable As Range
    Set rTable = Range("A3")                     ' Ohne die ?berschriften
    If SortSpalte3 = vbNullString Then
        rTable.Sort _
        Key1:=Range(SortSpalte1 & "3"), Order1:=xlAscending, _
        Key2:=Range(SortSpalte2 & "3"), Order1:=xlAscending, _
        Header:=xlYes, MatchCase:=False, _
        Orientation:=xlTopToBottom
    Else
        rTable.Sort _
        Key1:=Range(SortSpalte1 & "3"), Order1:=xlAscending, _
        Key2:=Range(SortSpalte2 & "3"), Order1:=xlAscending, _
        Key3:=Range(SortSpalte3 & "3"), Order1:=xlAscending, _
        Header:=xlYes, MatchCase:=False, _
        Orientation:=xlTopToBottom
    End If

    Set rTable = Nothing
    Exit Sub
End Sub

Public Function newExcelFile(ByVal sNewFileName As String, ByVal sfolder As String) As Boolean

    Dim sFolderFile As String
    Dim sConfigFolder As String
    Dim wbnew As Workbook

    sConfigFolder = "config"
    sfolder = ThisWorkbook.path & "\" & sConfigFolder & "\"
    sFolderFile = ThisWorkbook.path & "\" & sConfigFolder & "\" & sNewFileName

    createFolder sfolder

    newExcelFile = Dir(sFolderFile) = vbNullString

    If newExcelFile = True Then
        Set wbnew = Application.Workbooks.Add
        wbnew.SaveAs filename:=sFolderFile, FileFormat:=xlOpenXMLStrictWorkbook
    
        wbnew.Close
    End If
End Function

Public Function fileExist(ByVal sfilename As String, ByVal sfolder As String) As Boolean

    Dim sTestFile As String
    sTestFile = ThisWorkbook.path & "\" & sfolder & "\" & sfilename
    fileExist = Dir(sTestFile) <> vbNullString
End Function

Public Function createFolder(ByVal foldername As String) As Boolean
    ' create folder if not exist
    If Dir(foldername, vbDirectory) = vbNullString Then
        MkDir (foldername)
        createFolder = True
    Else
        createFolder = False
    End If
End Function

Public Function ReadSecondExcelFile(ByVal sFilname As String, ByVal sfolder As String) As String
    '** Dimensionierung der Variablen
    Dim blatt As String
    Dim bereich As Range
    Dim zelle As Object
    Dim sFullFolder As String

    sFullFolder = ThisWorkbook.path & "\" & sfolder

    '** Angaben zur auszulesenden Zelle
    blatt = "Tabelle1"
    Set bereich = Range("A1")

    '** Bereich auslesen
    For Each zelle In bereich
        '** Zellen umwandeln
        zelle = zelle.Address(False, False)
        '** Eintragen in Bereich
        ReadSecondExcelFile = GetValue(sFullFolder, sFilname, blatt, zelle)
    Next zelle
 
End Function

Private Function GetValue(ByVal path As String, ByVal file As String, ByVal sheet As String, ByVal ref As String) As String
    Dim arg As String
    arg = "'" & path & "\[" & file & "]" & sheet & "'!" & Range(ref).Address(, , xlR1C1)
    GetValue = ExecuteExcel4Macro(arg)
End Function

Public Sub CopySheetFromClosedWB(ByRef sSheetname As String)
    Application.ScreenUpdating = False
 
    Set closedBook = Workbooks.Open("D:\Dropbox\excel\articles\" & sSheetname)
    closedBook.Sheets("Sheet1").Copy Before:=ThisWorkbook.Sheets.[_Default](1)
    closedBook.Close SaveChanges:=False
 
    Application.ScreenUpdating = True
End Sub

Public Sub CopySheetToClosedWB(ByVal sNewFileName As String, ByRef sSheetname As String)
    Application.ScreenUpdating = False
    'works not fine
    Dim sFolderFile As String
    'Dim sfolder As String
    Dim sConfigFolder As String
    Dim closedBook As Workbook

    sConfigFolder = "config"
    'sfolder = ThisWorkbook.path & "\" & sConfigFolder & "\"
    sFolderFile = ThisWorkbook.path & "\" & sConfigFolder & "\" & sNewFileName
    
    Set closedBook = Workbooks.Open(sFolderFile)
    Sheets.[_Default](sSheetname).Copy Before:=closedBook.Sheets.[_Default](sSheetname)
    closedBook.Close SaveChanges:=True
 
    Application.ScreenUpdating = True
End Sub

Public Function ExtractNumber(ByVal str As String) As Long
    Dim i As Byte
    Dim ii As Byte
    ExtractNumber = 0
    'Pr?fe ob Wert nicht leer

    If str <> vbNullString Then
        For i = 1 To Len(str)
            If IsNumeric(Mid(str, i, 1)) Then
                Exit For
            End If
        Next i
        For ii = i To Len(str)
            If Not IsNumeric(Mid(str, ii, 1)) Then
                Exit For
            End If
        Next ii
        ExtractNumber = Mid(str, i, Len(str) - (ii - i))
    Else
        ExtractNumber = 0
    End If
End Function

Public Function WorksheetExist(ByVal sWorksheetName As String, ByVal ws1 As Worksheet) As Boolean
    With ws1
        On Error Resume Next
        WorksheetExist = Worksheets.[_Default](sWorksheetName).Index > 0
    End With
End Function

Public Function ReadXmlPLCconfig(ByRef sfolder As String, ByRef sfilename As String) As cPLCconfig
    Dim sFile As String
    
    sFile = ThisWorkbook.path & "\" & sfolder & "\" & sfilename
  
    Dim xmlObj As Object
    Set xmlObj = CreateObject("MSXML2.DOMDocument")
 
    xmlObj.async = False
    xmlObj.validateOnParse = False
    xmlObj.Load (sFile)
 
    Dim nodesThatMatter As Object
    'Dim node            As Object
    
    Dim rData As New cPLCconfig
    Dim sData As New cPLCconfigData
    
    Set nodesThatMatter = xmlObj.SelectNodes("//PLCconfig")
    ' For Each node In nodesThatMatter
    '     'Task 1 -> print the XML file within the FootballInfo node:
    '     'Debug.Print node.XML
    '     Dim child   As Variant
    '     For Each child In node.ChildNodes
    '         'Task 2 -> print only the information of the clubs.  E.g. NorthClub, EastClub etc.
    '         'Debug.Print child.ChildNodes.Item(3).XML
    '     Next child
    ' Next node
    
    'Dim singleNode As Object
    'Set singleNode = xmlObj.SelectSingleNode("//PLCconfig/Station[@Number='1']")
    'Task 3 -> print only the node with number "1"
    'Debug.Print singleNode.XML
    Set sData = Nothing
    Set rData = Nothing
    
    Dim level1 As Object
    Dim level2 As Object
    Dim level3 As Object
    
    For Each level1 In nodesThatMatter
        For Each level2 In level1.ChildNodes
            Debug.Print level2.Attributes.getNamedItem("Number").NodeValue 'stationnumber
            sData.Stationsnummer = level2.Attributes.getNamedItem("Number").NodeValue
            sData.FirstInputAdress = level2.ChildNodes.Item(1).Text
            sData.FirstOutputAdress = level2.ChildNodes.Item(2).Text
            
            
            For Each level3 In level2.ChildNodes.Item(3).ChildNodes
                'Set sdata = Nothing
                Debug.Print level3.Attributes.Item(0).Text 'Kartentyp
                sData.Kartentyp.Kartentyp = level3.Attributes.Item(0).Text 'Kartentyp
                Debug.Print level3.ChildNodes.Item(0).nodename
                Debug.Print level3.ChildNodes.Item(0).Text & vbCrLf 'ChannelsBeforSlot
                sData.ReserveChannelsBefor = level3.ChildNodes.Item(0).Text
                Debug.Print level3.ChildNodes.Item(1).nodename
                Debug.Print level3.ChildNodes.Item(1).Text & vbCrLf 'ChannelsAfterSlot Value
                sData.ReserveChannelsAfter = level3.ChildNodes.Item(1).Text
                Debug.Print level3.ChildNodes.Item(2).nodename
                Debug.Print level3.ChildNodes.Item(2).Text & vbCrLf 'ReserveChannelsPerSlot Value
                sData.ReserveChannelPerSlot = level3.ChildNodes.Item(2).Text
                Debug.Print level3.ChildNodes.Item(3).nodename
                Debug.Print level3.ChildNodes.Item(3).Text & vbCrLf 'ReserveSlots Value
                sData.ReserveSlot = level3.ChildNodes.Item(3).Text
                rData.Add sData.Stationsnummer, sData.Steckplatz, sData.Kartentyp.Kartentyp, "leer", sData.FirstInputAdress, sData.FirstOutputAdress, sData.ReserveChannelsBefor, sData.ReserveChannelsAfter, sData.ReserveChannelPerSlot, sData.ReserveSlot
            Next
        Next
        
    Next
    
    Set ReadXmlPLCconfig = rData
End Function

Public Function readXMLFile() As cPLCconfig
    ' read XML config File
    Dim sfolder As String
    Dim sFileNameConfig As String
    Dim bConfigFileIsNew As Boolean
    Dim bConfigFileExist As Boolean

    Dim rData As New cPLCconfig
    
    bConfigFileIsNew = False
    sfolder = "config"
    sFileNameConfig = "PLC_Config.xml"
    
    createFolder ThisWorkbook.path & "\" & sfolder
    ' pr?fen ob es die Datei gibt
    bConfigFileExist = fileExist(sFileNameConfig, sfolder)
    
    If bConfigFileExist = False Then
        'create xml file
        XML_Export sfolder, sFileNameConfig
        MsgBox "Bitte die Config Datei bearbeiten"
        bConfigFileIsNew = True
    End If
   

    ' wenn die Datei nicht angelegt wurde pr?fe ob es diese schon gibt
    If bConfigFileIsNew = False Then
        'pr?fe ob Datei vorhanden
        bConfigFileExist = fileExist(sFileNameConfig, sfolder)

        If bConfigFileExist Then
            'hier dann weiter wenn die Datei schon da ist
            'MsgBox "Datei gibt es schon"
            Set rData = ReadXmlPLCconfig(sfolder, sFileNameConfig)
            'MsgBox Result
    
        ElseIf bConfigFileIsNew = True Then
            'todo hier weiter wenn Datei neu
            rData.Add 0, 0, "RESERVE"
        Else
           
            rData.Add 0, 0, "RESERVE"
        End If
    End If
    Set readXMLFile = rData
End Function

Public Sub XML_Export(ByRef sfolder As String, ByRef sFileNameConfig As String)
    '*****************************************
    '** Excel-Inside Solutions - (C)                                *
    '*****************************************
    '** Dimensionierung der Variablen
    Dim strFile As String
    Dim i As Long
    Dim y As Long
    Dim varShow As Variant
    '** Errorhandling
    On Error GoTo Fehlermeldung
    '** XML-Dateipfad und -Name festlegen
    strFile = ThisWorkbook.path & "\" & sfolder & "\" & sFileNameConfig
    '** Datei (ASCII) ?ffnen
    Open strFile For Output As #1
    '** XML-Header schreiben
    Print #1, "<?xml version=""1.0"" encoding=""UTF-8"" standalone=""yes""?> "
    Print #1, "<PLCconfig xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"">"
       
    '** Mit Schleife die ersten 3 Spalten der Tabelle schreiben

    '** Schreiben der Sastionsdaten-Beginn
    For y = 1 To 3
        Print #1, "<Station Number =""" & y & """>"
        Print #1, "<Typ>ET200SP</Typ>"           'Tag Anfang
        '** Schreiben der Felder (Spalten A-C)
        Print #1, "<InputStartAdress>7000</InputStartAdress>"
        Print #1, "<OutputStartAdress>7000</OutputStartAdress>"
        Print #1, "<Modules>"
        For i = 0 To 1
            Print #1, "<Typ name="""; "ET200SP"; " 4IO"; "-"; "LINK"; """>"
            Print #1, "<ChannelsBeforSlot>0</ChannelsBeforSlot>"
            Print #1, "<ChannelsAfterSlot>0</ChannelsAfterSlot>"
            Print #1, "<ReserveChannelsPerSlot>1</ReserveChannelsPerSlot>"
            Print #1, "<ReserveSlots>0</ReserveSlots>"
            Print #1, "</Typ>"
        Next i
        '** Schreiben Datensatz-Ende
        Print #1, "</Modules>"
        Print #1, "</Station>"
    Next y
    '** Daten-Tag schlie?en


    '** Daten-Tag schlie?en
    Print #1, "</PLCconfig>"
    '** XML-Datei schlie?en
    Close #1
    '** Aufruf des Editors mit der geschriebenen xml-Datei
    varShow = Shell(Environ("windir") & "\notepad.exe " & strFile, 1)
    Exit Sub
    '** Errorhandling
Fehlermeldung:
    Close #1
    MsgBox "Fehler-Nr.: " & Err.Number & vbNewLine & vbNewLine _
         & "Beschreibung: " & Err.Description _
           , vbCritical, "Fehler"
End Sub

Public Sub RoundUpPLCaddresses(ByRef iInputAdress As Long, ByRef iOutputAdress As Long)
    'round up PLC adresses
    Dim iInputAdressTmp As Long
    Dim iOutputAdressTmp As Long
    iInputAdressTmp = 0
    iOutputAdressTmp = 0
     
    Do Until iInputAdressTmp > iInputAdress + 10
        iInputAdressTmp = iInputAdressTmp + 50
    Loop
        
    Do Until iOutputAdressTmp > iOutputAdress + 10
        iOutputAdressTmp = iOutputAdressTmp + 50
    Loop
     
    If iInputAdressTmp >= iOutputAdressTmp Then
        iInputAdress = iInputAdressTmp
        iOutputAdress = iInputAdressTmp
    ElseIf iOutputAdressTmp > iInputAdressTmp Then
        iInputAdress = iOutputAdressTmp
        iOutputAdress = iOutputAdressTmp
    End If
           
End Sub









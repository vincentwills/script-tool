Set objShell = CreateObject("WScript.Shell")
	objShell.Run "powershell.exe -ExecutionPolicy Bypass -File ""C:\Scripts\TEMPCleaner.ps1""", 0, False
	objShell.Run "powershell.exe -ExecutionPolicy Bypass -File ""C:\Scripts\TimeZone.ps1""", 0, False
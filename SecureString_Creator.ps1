$ScriptVersion = "1.0.0"
#region GUI
#ERASE ALL THIS AND PUT XAML BELOW between the @" "@
$inputXML = @"
<Window x:Class="Syntaro_SecureString_Creator.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:Syntaro_SecureString_Creator"
        mc:Ignorable="d"
        Title="Syntaro SecureString Creator" Height="343.955" Width="800">
    <Grid Background="#FFE6E6E6">
        <Grid.ColumnDefinitions>
            <ColumnDefinition/>
        </Grid.ColumnDefinitions>
        <Label x:Name="Label_Password" Content="Passwort to secure:" HorizontalAlignment="Left" Margin="10,52,0,0" VerticalAlignment="Top"/>
        <PasswordBox x:Name="PasswordBox_Password" HorizontalAlignment="Left" Margin="126,55,0,0" VerticalAlignment="Top" Width="562"/>
        <Button x:Name="Button_SecureString" Content="Create SecureString" Margin="313,79,0,0" VerticalAlignment="Top" Width="162" HorizontalAlignment="Left"/>
        <Label x:Name="Label_SecureString" Content="Secure String version of the password:" HorizontalAlignment="Left" Margin="10,120,0,0" VerticalAlignment="Top"/>
        <TextBox x:Name="TextBox_SecureString" HorizontalAlignment="Left" Height="126" Margin="18,155,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="764" IsEnabled="False"/>
        <Label x:Name="Label_Version" Content="Version:" HorizontalAlignment="Right" Margin="0,0,10,0" Height="27" VerticalAlignment="Bottom"/>
        <Label x:Name="Label_Messages" Content="Messages:" HorizontalAlignment="Left" Margin="10,7,0,0" VerticalAlignment="Top"/>
        <TextBox x:Name="TextBox_Messages" HorizontalAlignment="Left" Height="23" Margin="126,10,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="562" IsEnabled="False"/>
    </Grid>
</Window>
"@    
 
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'
 

[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML
 
    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
  try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."}
 
#===========================================================================
# Load XAML Objects In PowerShell
#===========================================================================
 
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}
 
Function Get-FormVariables{

#Remove Comment to Debug
<#
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}

write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*

#>

}
 
Get-FormVariables

#endregion

#region Initialize

$WPFLabel_Version.Content = "Version: $ScriptVersion"


$CurrentUser = $env:userdomain +"\" +"$env:USERNAME"

$WPFTextBox_Messages.Text ="The tools was started with the user: $CurrentUser"
$WPFTextBox_Messages.Foreground = "Black"



$Script:ThisScriptParentPath = $MyInvocation.MyCommand.Path -replace $myInvocation.MyCommand.Name,""

#If the Script gets executed as EXE we need another way to get ThisScriptParentPath
If(-not($script:ThisScriptParentPath)){
    $Script:ThisScriptParentPath = [System.Diagnostics.Process]::GetCurrentProcess() | Select-Object -ExpandProperty Path | Split-Path
    $Mode = "EXE"
}
else{
    $Mode = "SCRIPT"
}

#endregion

#region Functions


Function Generate-SecureString {
    $WPFTextBox_SecureString.Text = ""
    $WPFTextBox_SecureString.IsEnabled = "False"

    $VBS = new-object -comobject wscript.shell

    $Password = $null
    $Password = $WPFPasswordBox_Password.Password
    

    If($Password.length -lt 1){
        $WPFTextBox_Messages.Text ="No Password specified."
        $WPFTextBox_Messages.Foreground = "Red"
    }
    else{
        $SecurePassword = ConvertTo-SecureString $WPFPasswordBox_Password.Password -AsPlainText -Force
        $SecureStringAsPlainText = $SecurePassword | ConvertFrom-SecureString
        $WPFTextBox_SecureString.Text =  $SecureStringAsPlainText
        $WPFTextBox_SecureString.IsEnabled = "True"
        $WPFTextBox_SecureString.IsReadOnly = "True"
        $WPFTextBox_SecureString.IsFocused
        $WPFTextBox_Messages.Text ="SecureString created. You can mark it and copy it (Ctrl + C)"
        $WPFTextBox_Messages.Foreground = "Green"

    }
}


#endregion

#region Actions

#Show possible Events for a controll
#$WPFComboBox_WordList | Get-Member -Type Event | Out-GridView


$WPFButton_SecureString.Add_Click({
    Generate-SecureString
})



#endregion Actions

#===========================================================================
# Shows the form
#===========================================================================
$Form.ShowDialog() | out-null
# SIG # Begin signature block
# MIIXxQYJKoZIhvcNAQcCoIIXtjCCF7ICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUIlRldm0RqHTUWWA5d+vPw+ej
# XwmgghL4MIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggUnMIIED6ADAgECAhAB7uHu9sSCKgqVgJoW5mKYMA0GCSqGSIb3DQEBCwUAMHIx
# CzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3
# dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJ
# RCBDb2RlIFNpZ25pbmcgQ0EwHhcNMTkwMzE0MDAwMDAwWhcNMjIwNjExMTIwMDAw
# WjBkMQswCQYDVQQGEwJDSDESMBAGA1UECBMJU29sb3RodXJuMREwDwYDVQQHDAhE
# w6RuaWtlbjEWMBQGA1UEChMNYmFzZVZJU0lPTiBBRzEWMBQGA1UEAxMNYmFzZVZJ
# U0lPTiBBRzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMfM1Zl2D4mV
# Ej7w9rAboqVD3E6JHf3GUOw0cPPP94occ4dCeqITcVME6s2nhVcnff+68FPtJB2g
# BKWIB8zL4bD1SZBgLywRe3F/KvmbULw9gp5Qk8nLeVOLtXsyKEIfNMzMWeMxTMsx
# mtr910G0knpBnuHQgJVNpKF4BgSpIJZ8FQJlvYvLm0y73HXj/YSUJt7bstqnJ9Q6
# s+ngp/en1pykXhzgj76u6yPKc/kdZQwfzsLj2FQ3y7ScWt7Ps1fevkh8JBmJc+ti
# 6oKVDMArOEj7IdXn9rjPkeTSakFoqb1ceNRnMYyMOEaflMFwxylT2NTm4cYTF65m
# HtZEm//K7QECAwEAAaOCAcUwggHBMB8GA1UdIwQYMBaAFFrEuXsqCqOl6nEDwGD5
# LfZldQ5YMB0GA1UdDgQWBBTP/wNYXuPPmMSxVMf7zj/HD4TQbTAOBgNVHQ8BAf8E
# BAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwdwYDVR0fBHAwbjA1oDOgMYYvaHR0
# cDovL2NybDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1jcy1nMS5jcmwwNaAz
# oDGGL2h0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtY3MtZzEu
# Y3JsMEwGA1UdIARFMEMwNwYJYIZIAYb9bAMBMCowKAYIKwYBBQUHAgEWHGh0dHBz
# Oi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwCAYGZ4EMAQQBMIGEBggrBgEFBQcBAQR4
# MHYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBOBggrBgEF
# BQcwAoZCaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0U0hBMkFz
# c3VyZWRJRENvZGVTaWduaW5nQ0EuY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcN
# AQELBQADggEBAJV9TChoYXmc7/3Qc8p9EgcF4I+6cnLSBpQOfYGi3f3bBcATTPle
# cJiruue4AxIpNwtGwZnqneGxAWT4C98yjBQbCq7nt0k3HF1LjeTNdExNx6cVGF4S
# 9HvcSsoqFNnQuMpzjnFredIP0LPvLQouYtEKcvYJDmx0Bb/72anpAlUiY0WzBF6t
# cYU//dNDqiw/0uQqFMuKzUTKSgGlf+bLsebz8XNIcJPrrui3dduig20oOR2V60Yq
# PmZhLDS3CXNvKXZbo/ib02zendVAFYDIoKZOtmNOalBoWwlQRYWmwQWuSJRbQFl1
# ridyuVRrTlCgWJj4547jqr4/cxmFLV+hrZcwggUwMIIEGKADAgECAhAECRgbX9W7
# ZnVTQ7VvlVAIMA0GCSqGSIb3DQEBCwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNV
# BAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0xMzEwMjIxMjAwMDBa
# Fw0yODEwMjIxMjAwMDBaMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lD
# ZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQD407Mcfw4Rr2d3B9MLMUkZz9D7RZmxOttE9X/l
# qJ3bMtdx6nadBS63j/qSQ8Cl+YnUNxnXtqrwnIal2CWsDnkoOn7p0WfTxvspJ8fT
# eyOU5JEjlpB3gvmhhCNmElQzUHSxKCa7JGnCwlLyFGeKiUXULaGj6YgsIJWuHEqH
# CN8M9eJNYBi+qsSyrnAxZjNxPqxwoqvOf+l8y5Kh5TsxHM/q8grkV7tKtel05iv+
# bMt+dDk2DZDv5LVOpKnqagqrhPOsZ061xPeM0SAlI+sIZD5SlsHyDxL0xY4PwaLo
# LFH3c7y9hbFig3NBggfkOItqcyDQD2RzPJ6fpjOp/RnfJZPRAgMBAAGjggHNMIIB
# yTASBgNVHRMBAf8ECDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAK
# BggrBgEFBQcDAzB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9v
# Y3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHow
# eDA6oDigNoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJl
# ZElEUm9vdENBLmNybDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0Rp
# Z2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDBPBgNVHSAESDBGMDgGCmCGSAGG/WwA
# AgQwKjAoBggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzAK
# BghghkgBhv1sAzAdBgNVHQ4EFgQUWsS5eyoKo6XqcQPAYPkt9mV1DlgwHwYDVR0j
# BBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wDQYJKoZIhvcNAQELBQADggEBAD7s
# DVoks/Mi0RXILHwlKXaoHV0cLToaxO8wYdd+C2D9wz0PxK+L/e8q3yBVN7Dh9tGS
# dQ9RtG6ljlriXiSBThCk7j9xjmMOE0ut119EefM2FAaK95xGTlz/kLEbBw6RFfu6
# r7VRwo0kriTGxycqoSkoGjpxKAI8LpGjwCUR4pwUR6F6aGivm6dcIFzZcbEMj7uo
# +MUSaJ/PQMtARKUT8OZkDCUIQjKyNookAv4vcn4c10lFluhZHen6dGRrsutmQ9qz
# sIzV6Q3d9gEgzpkxYz0IGhizgZtPxpMQBvwHgfqL2vmCSfdibqFT+hKUGIUukpHq
# aGxEMrJmoecYpJpkUe8xggQ3MIIEMwIBATCBhjByMQswCQYDVQQGEwJVUzEVMBMG
# A1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEw
# LwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgQ29kZSBTaWduaW5nIENB
# AhAB7uHu9sSCKgqVgJoW5mKYMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQow
# CKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcC
# AQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRu9Oqe7CkL/7Qpimff
# 2tNWiPxxiTANBgkqhkiG9w0BAQEFAASCAQB3oKfO2SU/RKhrIaHhkgC2KiFrN4gW
# CgQpnYzK1mOh4d2NV3mFLVLgIKpO+YeSoaTdzbsbdZ56XENa8bHFgMakyzivsb2f
# t5fRkfTYdRnRMy15/sGHeigdJyPtA/sFRbpDtEfwmcv8xpFiBsDBuBddZ7Qb7Joj
# Cf9z1s0dBj01zhB9NCrHG49mCULuknuRlTlLunkwekAlhFSaP2gdVRj9WLyEy71e
# fnbdzTQLse0TiwzUHEbEuflgHyRdRhxNuidoH0q85ZLbcOSy6bTuRGOtwKU90qQg
# 6yeKs9xLLZhdQq3PN4g/xtVEoXTawH9RJGyMta7PoIcY341I8TXmecDioYICCzCC
# AgcGCSqGSIb3DQEJBjGCAfgwggH0AgEBMHIwXjELMAkGA1UEBhMCVVMxHTAbBgNV
# BAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTAwLgYDVQQDEydTeW1hbnRlYyBUaW1l
# IFN0YW1waW5nIFNlcnZpY2VzIENBIC0gRzICEA7P9DjI/r81bgTYapgbGlAwCQYF
# Kw4DAhoFAKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkF
# MQ8XDTE5MDQwMzE0MTI1OVowIwYJKoZIhvcNAQkEMRYEFAuDuuNK5kv9otAdjTmu
# uifKAx0rMA0GCSqGSIb3DQEBAQUABIIBAG+/uQjAIiFq9SqlKlgHIYtRzstrNDWD
# Ae/quSmnK9notFmgbaMqcsPIIKAbeOnTuppyNHsrWxwcdlZ4VI2OkIrRJcHNFo2U
# HeAZE+lhLsR/RvWhkSjvrvBmUDetsBAHyOfvZp5g0bIOjol8YGaBGp0lTQQItbUg
# r149mTBgw8FlQ6qFNutndbsSyxZdzDDcx0C/cA9CCQpUlxMKPeTzCfyuZfI7r6Yg
# /X50AYhqqDpzqNF1KxNuV88eZSbNVzodGWmbKZJ/8DxGWl9Mqm5lUJDIr8yBt7GP
# hTGMjux31VvEqgzHKhxOuW9Y3gjB9u3cXmRXcpLyKME/sFX9M9R2024=
# SIG # End signature block

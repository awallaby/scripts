<#
.DESCRIPTION
    Set Power settings
.LANGUAGE
    PowerShell
.TIMEOUT
    100
.LINK
    https://github.com/levelrmm/scripts/blob/775e26e4c441a1aed19639ccae96a3bcf2ecc51f/PowerShell/Scripts/Windows-Settings/Change%20Windows%20Power%20Settings.ps1
#>

#Settings when plugged in to external power
Powercfg /Change standby-timeout-ac 0   #Sleep timer
Powercfg /Change hibernate-timeout-ac 0 #Hibernate timer "0" means never
Powercfg /Change monitor-timeout-ac 20  #Monitor sleep timer

#Settings when running on battery power
Powercfg /Change standby-timeout-dc 60  #Sleep timer
Powercfg /Change hibernate-timeout-dc 0 #Hibernate timer "0" means never
Powercfg /Change monitor-timeout-dc 10  #Monitor sleep timer

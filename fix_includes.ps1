# Fix include paths after consolidation
$files = Get-ChildItem "01_SONIC R_MC_FINAL\*.mqh" -Recurse

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    
    # Fix enum includes
    $content = $content -replace '01_Core_10_CoreEnums\.mqh', '01_Core_14_CoreEnums.mqh'
    $content = $content -replace '01_Core_12_SonicEnums\.mqh', '01_Core_22_SonicEnums.mqh'
    
    # Fix other consolidated includes
    $content = $content -replace '01_Core_11_EnumHelpers\.mqh', '01_Core_16_EnumHelpers.mqh'
    $content = $content -replace '01_Core_20_TradeGate\.mqh', '05_Trading_03_TradeGate.mqh'
    
    Set-Content $file.FullName $content -NoNewline
    Write-Host "Fixed: $($file.Name)"
}

Write-Host "Include path fixes completed!"

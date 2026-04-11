Get-ChildItem -Recurse -Filter *.pas | ForEach-Object {
    $content = Get-Content $_.FullName
    $content | Set-Content -Encoding UTF8 $_.FullName
}
# Server tĩnh thuần PowerShell — chạy thử viewer không cần cài Node/Python.
# Cách dùng:  powershell -ExecutionPolicy Bypass -File serve.ps1
# rồi mở     http://localhost:8173
param([int]$Port = 8173)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$mime = @{
    '.html' = 'text/html; charset=utf-8'
    '.js'   = 'text/javascript; charset=utf-8'
    '.mjs'  = 'text/javascript; charset=utf-8'
    '.css'  = 'text/css; charset=utf-8'
    '.json' = 'application/json; charset=utf-8'
    '.sog'  = 'application/octet-stream'
    '.ply'  = 'application/octet-stream'
    '.webp' = 'image/webp'
    '.png'  = 'image/png'
    '.jpg'  = 'image/jpeg'
    '.svg'  = 'image/svg+xml'
    '.md'   = 'text/plain; charset=utf-8'
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "Dang phuc vu '$root' tai http://localhost:$Port/  (Ctrl+C de dung)"

while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    try {
        $rel = [System.Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath).TrimStart('/')
        if ($rel -eq '') { $rel = 'index.html' }
        $full = [System.IO.Path]::GetFullPath((Join-Path $root $rel))
        if ($full.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase) -and (Test-Path $full -PathType Leaf)) {
            $bytes = [System.IO.File]::ReadAllBytes($full)
            $ext = [System.IO.Path]::GetExtension($full).ToLower()
            if ($mime.ContainsKey($ext)) { $ctx.Response.ContentType = $mime[$ext] }
            else { $ctx.Response.ContentType = 'application/octet-stream' }
            $ctx.Response.ContentLength64 = $bytes.Length
            $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $ctx.Response.StatusCode = 404
            $msg = [System.Text.Encoding]::UTF8.GetBytes('404 Not Found')
            $ctx.Response.OutputStream.Write($msg, 0, $msg.Length)
        }
    } catch {
        try { $ctx.Response.StatusCode = 500 } catch {}
    } finally {
        try { $ctx.Response.OutputStream.Close() } catch {}
    }
}

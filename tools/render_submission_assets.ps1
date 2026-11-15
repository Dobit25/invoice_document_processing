param()

Add-Type -AssemblyName System.Drawing

$repoRoot = Split-Path -Parent $PSScriptRoot
$outputDir = Join-Path $repoRoot 'docs\submission\assets'
[System.IO.Directory]::CreateDirectory($outputDir) | Out-Null

$colors = @{
    Ink       = [Drawing.Color]::FromArgb(31, 35, 48)
    Muted     = [Drawing.Color]::FromArgb(102, 112, 133)
    Border    = [Drawing.Color]::FromArgb(210, 216, 228)
    Canvas    = [Drawing.Color]::FromArgb(245, 247, 251)
    White     = [Drawing.Color]::White
    Purple    = [Drawing.Color]::FromArgb(103, 64, 220)
    PurpleLite= [Drawing.Color]::FromArgb(239, 234, 255)
    BlueLite  = [Drawing.Color]::FromArgb(229, 242, 255)
    Green     = [Drawing.Color]::FromArgb(35, 145, 92)
    GreenLite = [Drawing.Color]::FromArgb(226, 247, 237)
    Amber     = [Drawing.Color]::FromArgb(211, 128, 16)
    AmberLite = [Drawing.Color]::FromArgb(255, 244, 218)
    Red       = [Drawing.Color]::FromArgb(200, 52, 65)
    RedLite   = [Drawing.Color]::FromArgb(255, 232, 235)
}

function New-Font([float]$size, [Drawing.FontStyle]$style = [Drawing.FontStyle]::Regular) {
    return [Drawing.Font]::new('Segoe UI', $size, $style, [Drawing.GraphicsUnit]::Pixel)
}

function Draw-Text($g, [string]$text, [float]$x, [float]$y, [float]$w, [float]$h, $font, $color) {
    $brush = [Drawing.SolidBrush]::new($color)
    $format = [Drawing.StringFormat]::new()
    $format.Trimming = [Drawing.StringTrimming]::EllipsisWord
    $format.FormatFlags = [Drawing.StringFormatFlags]::LineLimit
    $g.DrawString($text, $font, $brush, [Drawing.RectangleF]::new($x, $y, $w, $h), $format)
    $format.Dispose(); $brush.Dispose()
}

function Draw-Box($g, [float]$x, [float]$y, [float]$w, [float]$h, $fill, $border = $colors.Border, [float]$line = 2) {
    $brush = [Drawing.SolidBrush]::new($fill)
    $pen = [Drawing.Pen]::new($border, $line)
    $g.FillRectangle($brush, $x, $y, $w, $h)
    $g.DrawRectangle($pen, $x, $y, $w, $h)
    $brush.Dispose(); $pen.Dispose()
}

function Draw-Line($g, [float]$x1, [float]$y1, [float]$x2, [float]$y2, $color = $colors.Border, [float]$line = 2) {
    $pen = [Drawing.Pen]::new($color, $line)
    $g.DrawLine($pen, $x1, $y1, $x2, $y2)
    $pen.Dispose()
}

function Draw-Arrow($g, [float]$x1, [float]$y1, [float]$x2, [float]$y2, $color = $colors.Purple) {
    $pen = [Drawing.Pen]::new($color, 4)
    $pen.EndCap = [Drawing.Drawing2D.LineCap]::ArrowAnchor
    $g.DrawLine($pen, $x1, $y1, $x2, $y2)
    $pen.Dispose()
}

function Draw-Button($g, [string]$label, [float]$x, [float]$y, [float]$w, [float]$h, $fill = $colors.Purple) {
    Draw-Box $g $x $y $w $h $fill $fill 1
    Draw-Text $g $label ($x + 12) ($y + 9) ($w - 24) ($h - 12) (New-Font 18 ([Drawing.FontStyle]::Bold)) $colors.White
}

function Draw-ScreenHeader($g, [string]$number, [string]$title, [string]$role, [float]$x, [float]$y, [float]$w) {
    Draw-Box $g $x $y $w 58 $colors.PurpleLite $colors.Purple 2
    Draw-Text $g $number ($x + 16) ($y + 12) 48 35 (New-Font 22 ([Drawing.FontStyle]::Bold)) $colors.Purple
    Draw-Text $g $title ($x + 66) ($y + 11) ($w - 260) 36 (New-Font 23 ([Drawing.FontStyle]::Bold)) $colors.Ink
    Draw-Text $g $role ($x + $w - 190) ($y + 15) 170 30 (New-Font 17) $colors.Muted
}

function Save-Wireframes {
    $bmp = [Drawing.Bitmap]::new(2400, 1600)
    $g = [Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [Drawing.Text.TextRenderingHint]::ClearTypeGridFit
    $g.Clear($colors.Canvas)

    Draw-Text $g 'StatementReader — Wireframe overview' 70 35 1500 60 (New-Font 38 ([Drawing.FontStyle]::Bold)) $colors.Ink
    Draw-Text $g 'IDP-13 · Evidence-first review · Maker–Checker workflow · 15/11/2026' 72 94 1600 38 (New-Font 21) $colors.Muted

    $screenW = 720; $screenH = 650
    $xs = @(70, 840, 1610); $ys = @(155, 850)

    # S1 Login
    $x=$xs[0]; $y=$ys[0]; Draw-Box $g $x $y $screenW $screenH $colors.White
    Draw-ScreenHeader $g 'S1' 'Login' 'Maker / Checker' $x $y $screenW
    Draw-Text $g 'STATEMENTREADER' ($x+210) ($y+105) 320 40 (New-Font 24 ([Drawing.FontStyle]::Bold)) $colors.Purple
    Draw-Text $g 'Đăng nhập để tiếp tục' ($x+210) ($y+155) 320 32 (New-Font 20) $colors.Ink
    Draw-Text $g 'Email' ($x+165) ($y+220) 390 26 (New-Font 17) $colors.Muted
    Draw-Box $g ($x+165) ($y+250) 390 52 $colors.White
    Draw-Text $g 'name@company.vn' ($x+180) ($y+264) 350 28 (New-Font 17) $colors.Muted
    Draw-Text $g 'Mật khẩu' ($x+165) ($y+325) 390 26 (New-Font 17) $colors.Muted
    Draw-Box $g ($x+165) ($y+355) 390 52 $colors.White
    Draw-Text $g '••••••••••••' ($x+180) ($y+369) 350 28 (New-Font 17) $colors.Muted
    Draw-Button $g 'Đăng nhập' ($x+165) ($y+440) 390 54
    Draw-Box $g ($x+165) ($y+525) 390 62 $colors.RedLite $colors.Red 1
    Draw-Text $g 'Error state: sai thông tin hoặc phiên hết hạn' ($x+180) ($y+540) 350 40 (New-Font 16) $colors.Red

    # S2 Inbox
    $x=$xs[1]; $y=$ys[0]; Draw-Box $g $x $y $screenW $screenH $colors.White
    Draw-ScreenHeader $g 'S2' 'Document Inbox' 'Maker / Checker' $x $y $screenW
    Draw-Box $g ($x+25) ($y+85) 430 48 $colors.White
    Draw-Text $g 'Tìm tên file, trạng thái…' ($x+42) ($y+97) 390 28 (New-Font 17) $colors.Muted
    Draw-Button $g '+ Upload' ($x+530) ($y+85) 160 48
    Draw-Text $g 'Tài liệu' ($x+30) ($y+165) 260 30 (New-Font 18 ([Drawing.FontStyle]::Bold)) $colors.Ink
    Draw-Text $g 'Trạng thái' ($x+340) ($y+165) 190 30 (New-Font 18 ([Drawing.FontStyle]::Bold)) $colors.Ink
    Draw-Text $g 'Issues' ($x+570) ($y+165) 100 30 (New-Font 18 ([Drawing.FontStyle]::Bold)) $colors.Ink
    $rows = @(
      @('statement_001.pdf','Needs review','3','amber'),
      @('scan_batch_02.pdf','Processing','—','blue'),
      @('statement_003.pdf','Awaiting approval','0','purple'),
      @('statement_004.pdf','Approved','0','green'),
      @('bad_file.pdf','Failed','1','red'))
    $ry=$y+205
    foreach($row in $rows){
      Draw-Line $g ($x+25) $ry ($x+690) $ry
      Draw-Text $g $row[0] ($x+35) ($ry+17) 285 30 (New-Font 17) $colors.Ink
      $bg=$colors.BlueLite; $fg=$colors.Muted
      if($row[3]-eq'green'){$bg=$colors.GreenLite;$fg=$colors.Green}; if($row[3]-eq'red'){$bg=$colors.RedLite;$fg=$colors.Red}; if($row[3]-eq'amber'){$bg=$colors.AmberLite;$fg=$colors.Amber}; if($row[3]-eq'purple'){$bg=$colors.PurpleLite;$fg=$colors.Purple}
      Draw-Box $g ($x+335) ($ry+10) 205 40 $bg $bg 1
      Draw-Text $g $row[1] ($x+347) ($ry+20) 180 25 (New-Font 15 ([Drawing.FontStyle]::Bold)) $fg
      Draw-Text $g $row[2] ($x+600) ($ry+17) 50 30 (New-Font 17 ([Drawing.FontStyle]::Bold)) $fg
      $ry += 72
    }

    # S3 Upload
    $x=$xs[2]; $y=$ys[0]; Draw-Box $g $x $y $screenW $screenH $colors.White
    Draw-ScreenHeader $g 'S3' 'Upload Statement' 'Maker' $x $y $screenW
    Draw-Box $g ($x+60) ($y+105) 600 270 $colors.Canvas $colors.Purple 3
    Draw-Text $g 'Kéo thả PDF / PNG / JPG vào đây' ($x+155) ($y+180) 420 40 (New-Font 23 ([Drawing.FontStyle]::Bold)) $colors.Ink
    Draw-Text $g 'hoặc chọn file từ máy tính' ($x+205) ($y+230) 340 35 (New-Font 18) $colors.Muted
    Draw-Button $g 'Chọn file' ($x+260) ($y+290) 200 50
    Draw-Box $g ($x+60) ($y+405) 600 72 $colors.AmberLite $colors.Amber 1
    Draw-Text $g 'Chỉ dùng dữ liệu tổng hợp · tối đa 10 MB / 10 trang' ($x+80) ($y+425) 560 38 (New-Font 17) $colors.Amber
    Draw-Box $g ($x+60) ($y+500) 600 64 $colors.RedLite $colors.Red 1
    Draw-Text $g 'Invalid file: nêu rõ định dạng, mã hóa hoặc giới hạn bị vi phạm' ($x+80) ($y+517) 560 38 (New-Font 16) $colors.Red
    Draw-Button $g 'Bắt đầu xử lý' ($x+430) ($y+585) 230 46

    # S4 Processing
    $x=$xs[0]; $y=$ys[1]; Draw-Box $g $x $y $screenW $screenH $colors.White
    Draw-ScreenHeader $g 'S4' 'Processing Progress' 'Maker; Checker xem' $x $y $screenW
    Draw-Text $g 'scan_batch_02.pdf' ($x+30) ($y+90) 400 38 (New-Font 23 ([Drawing.FontStyle]::Bold)) $colors.Ink
    Draw-Text $g '67% · 4/6 trang · 00:18' ($x+430) ($y+94) 250 32 (New-Font 18) $colors.Purple
    Draw-Box $g ($x+30) ($y+145) 650 22 $colors.Canvas $colors.Canvas 1
    Draw-Box $g ($x+30) ($y+145) 430 22 $colors.Purple $colors.Purple 1
    $steps=@('1  Ingest & validate        ✓','2  Detect text / OCR       Đang chạy','3  Parse transactions      Chờ','4  Validate balances       Chờ')
    $sy=$y+205
    foreach($s in $steps){Draw-Box $g ($x+35) $sy 640 55 $colors.Canvas; Draw-Text $g $s ($x+55) ($sy+14) 600 30 (New-Font 18) $colors.Ink; $sy+=70}
    Draw-Box $g ($x+35) ($y+500) 640 78 $colors.RedLite $colors.Red 1
    Draw-Text $g 'Trang 4: OCR thất bại · giữ kết quả một phần' ($x+55) ($y+516) 430 28 (New-Font 17 ([Drawing.FontStyle]::Bold)) $colors.Red
    Draw-Button $g 'Retry trang' ($x+505) ($y+514) 150 42 $colors.Red

    # S5 Workbench
    $x=$xs[1]; $y=$ys[1]; Draw-Box $g $x $y $screenW $screenH $colors.White
    Draw-ScreenHeader $g 'S5' 'Review Workbench' 'Maker sửa; Checker xem' $x $y $screenW
    Draw-Box $g ($x+20) ($y+80) 300 480 $colors.Canvas
    Draw-Text $g 'PDF · Trang 2/6' ($x+35) ($y+95) 250 28 (New-Font 17 ([Drawing.FontStyle]::Bold)) $colors.Ink
    Draw-Box $g ($x+50) ($y+145) 240 330 $colors.White
    for($i=0;$i -lt 9;$i++){Draw-Line $g ($x+70) ($y+175+$i*29) ($x+270) ($y+175+$i*29) $colors.Border 2}
    Draw-Box $g ($x+65) ($y+275) 210 38 $colors.AmberLite $colors.Amber 3
    Draw-Text $g 'Evidence highlight' ($x+85) ($y+282) 170 24 (New-Font 14 ([Drawing.FontStyle]::Bold)) $colors.Amber
    Draw-Text $g '3 issues · Balance delta 250.000' ($x+345) ($y+90) 345 30 (New-Font 17 ([Drawing.FontStyle]::Bold)) $colors.Red
    $cols=@('Ngày','Mô tả','Ghi nợ','Số dư'); $cx=@(345,430,555,630)
    for($i=0;$i -lt 4;$i++){Draw-Text $g $cols[$i] ($x+$cx[$i]) ($y+140) 90 25 (New-Font 15 ([Drawing.FontStyle]::Bold)) $colors.Ink}
    for($i=0;$i -lt 6;$i++){
      $yy=$y+175+$i*56; $fill=$colors.White; if($i-eq 2){$fill=$colors.RedLite}; if($i-eq 4){$fill=$colors.AmberLite}
      Draw-Box $g ($x+335) $yy 355 48 $fill
      Draw-Text $g ('0{0}/11' -f ($i+1)) ($x+347) ($yy+13) 75 24 (New-Font 14) $colors.Ink
      Draw-Text $g ('Giao dịch {0}' -f ($i+1)) ($x+430) ($yy+13) 115 24 (New-Font 14) $colors.Ink
      Draw-Text $g ('{0:N0}' -f (($i+1)*125000)) ($x+560) ($yy+13) 120 24 (New-Font 14) $colors.Ink
    }
    Draw-Button $g 'Gửi duyệt' ($x+515) ($y+585) 175 44
    Draw-Text $g 'Conflict → reload & merge; không ghi đè im lặng' ($x+25) ($y+590) 470 32 (New-Font 15) $colors.Muted

    # S6 Approval
    $x=$xs[2]; $y=$ys[1]; Draw-Box $g $x $y $screenW $screenH $colors.White
    Draw-ScreenHeader $g 'S6' 'Validation · Approval · Export' 'Checker' $x $y $screenW
    Draw-Text $g 'Kiểm tra trước phê duyệt' ($x+35) ($y+92) 420 35 (New-Font 23 ([Drawing.FontStyle]::Bold)) $colors.Ink
    $cards=@(@('Evidence coverage','100%','green'),@('Balance checks','24/24','green'),@('Open issues','0','green'),@('Audit trail','Sẵn sàng','purple'))
    $cy=$y+145
    foreach($c in $cards){$bg=$colors.GreenLite;$fg=$colors.Green;if($c[2]-eq'purple'){$bg=$colors.PurpleLite;$fg=$colors.Purple};Draw-Box $g ($x+35) $cy 650 58 $bg $bg 1;Draw-Text $g $c[0] ($x+55) ($cy+15) 380 28 (New-Font 17) $colors.Ink;Draw-Text $g $c[1] ($x+500) ($cy+14) 160 28 (New-Font 18 ([Drawing.FontStyle]::Bold)) $fg;$cy+=72}
    Draw-Box $g ($x+35) ($y+455) 650 58 $colors.GreenLite $colors.Green 2
    Draw-Text $g 'APPROVED · Kế toán A · 15/11/2026 22:10' ($x+55) ($y+470) 610 30 (New-Font 17 ([Drawing.FontStyle]::Bold)) $colors.Green
    Draw-Button $g 'Từ chối' ($x+35) ($y+555) 155 46 $colors.Red
    Draw-Button $g 'Phê duyệt' ($x+210) ($y+555) 190 46 $colors.Green
    Draw-Button $g 'Export CSV/XLSX' ($x+420) ($y+555) 265 46

    $path = Join-Path $outputDir 'wireframe-overview.png'
    $bmp.Save($path, [Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
}

function Save-UiFlow {
    $bmp = [Drawing.Bitmap]::new(2400, 1200)
    $g = [Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [Drawing.Text.TextRenderingHint]::ClearTypeGridFit
    $g.Clear($colors.Canvas)
    Draw-Text $g 'StatementReader — UI flow' 70 38 1300 60 (New-Font 38 ([Drawing.FontStyle]::Bold)) $colors.Ink
    Draw-Text $g 'Happy path, quyền và các nhánh lỗi chính' 72 100 1200 38 (New-Font 21) $colors.Muted

    Draw-Box $g 55 170 2290 240 $colors.BlueLite $colors.BlueLite 1
    Draw-Text $g 'MAKER · Nhân viên ngân quỹ' 80 190 520 35 (New-Font 21 ([Drawing.FontStyle]::Bold)) $colors.Purple
    Draw-Box $g 55 460 2290 210 $colors.PurpleLite $colors.PurpleLite 1
    Draw-Text $g 'CHECKER · Kế toán' 80 480 520 35 (New-Font 21 ([Drawing.FontStyle]::Bold)) $colors.Purple

    $nodes = @(
      @(90,270,170,'1 · Login'),@(310,270,180,'2 · Inbox'),@(540,270,190,'3 · Upload'),
      @(780,270,220,'Kiểm tra file'),@(1050,270,230,'4 · Processing'),@(1330,270,245,'5 · Review evidence'),
      @(1625,270,230,'Resolve issues'),@(1905,270,250,'Submit for approval'))
    foreach($n in $nodes){Draw-Box $g $n[0] $n[1] $n[2] 76 $colors.White $colors.Purple 2;Draw-Text $g $n[3] ($n[0]+12) ($n[1]+22) ($n[2]-24) 34 (New-Font 17 ([Drawing.FontStyle]::Bold)) $colors.Ink}
    for($i=0;$i -lt $nodes.Count-1;$i++){Draw-Arrow $g ($nodes[$i][0]+$nodes[$i][2]) 308 ($nodes[$i+1][0]-8) 308}
    Draw-Arrow $g 2030 346 2030 540
    Draw-Box $g 1760 540 260 76 $colors.White $colors.Purple 2
    Draw-Text $g 'Approve / Reject' 1790 562 205 34 (New-Font 18 ([Drawing.FontStyle]::Bold)) $colors.Ink
    Draw-Arrow $g 2020 578 2100 578
    Draw-Box $g 2100 540 200 76 $colors.GreenLite $colors.Green 2
    Draw-Text $g '6 · Export' 2135 562 140 34 (New-Font 18 ([Drawing.FontStyle]::Bold)) $colors.Green

    Draw-Text $g 'ERROR / EXCEPTION BRANCHES' 75 730 520 36 (New-Font 22 ([Drawing.FontStyle]::Bold)) $colors.Ink
    $errors = @(
      @(80,790,430,'File không hợp lệ','Nêu lý do → quay lại Upload','red'),
      @(550,790,430,'Trang OCR thất bại','Giữ partial result → Retry','red'),
      @(1020,790,430,'Lệch số dư / thiếu evidence','Highlight → sửa → revalidate','amber'),
      @(1490,790,390,'Conflict phiên sửa','Không ghi đè → reload & merge','amber'),
      @(1920,790,390,'Checker từ chối','Ghi lý do → trả về Review','red'))
    foreach($e in $errors){$bg=$colors.RedLite;$fg=$colors.Red;if($e[5]-eq'amber'){$bg=$colors.AmberLite;$fg=$colors.Amber};Draw-Box $g $e[0] $e[1] $e[2] 145 $bg $fg 2;Draw-Text $g $e[3] ($e[0]+20) ($e[1]+20) ($e[2]-40) 35 (New-Font 19 ([Drawing.FontStyle]::Bold)) $fg;Draw-Text $g $e[4] ($e[0]+20) ($e[1]+68) ($e[2]-40) 55 (New-Font 17) $colors.Ink}
    Draw-Text $g 'Approved documents are read-only. Mọi chỉnh sửa sau phê duyệt tạo một phiên bản mới.' 80 1010 1800 42 (New-Font 20 ([Drawing.FontStyle]::Bold)) $colors.Green
    Draw-Text $g 'Legend: tím = hành động chính · đỏ = lỗi · vàng = ngoại lệ cần xử lý · xanh = hoàn tất' 80 1070 1800 38 (New-Font 18) $colors.Muted

    $path = Join-Path $outputDir 'ui-flow.png'
    $bmp.Save($path, [Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
}

Save-Wireframes
Save-UiFlow
Write-Output "Generated submission assets in: $outputDir"

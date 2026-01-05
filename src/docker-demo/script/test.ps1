# Docker镜像体积对比实验
Write-Host "=== Docker镜像体积对比实验 ===" -ForegroundColor Green
Write-Host "实验时间: $(Get-Date)" -ForegroundColor Yellow
Write-Host ""

# 创建测试目录
$testResultsDir = "test_results"
if (!(Test-Path $testResultsDir)) {
    New-Item -ItemType Directory -Path $testResultsDir -Force
}

Write-Host "1. 构建普通版本镜像..." -ForegroundColor Cyan
Set-Location "../app-v1"
docker build -t cloud-app:v1 .
docker images cloud-app:v1 --format "table {{.Repository}}`t{{.Tag}}`t{{.Size}}" | Out-File -FilePath "../script/$testResultsDir/v1_size.txt"

Write-Host "2. 构建优化版本镜像..." -ForegroundColor Cyan
Set-Location "../app-v2"
docker build -t cloud-app:v2 .
docker images cloud-app:v2 --format "table {{.Repository}}`t{{.Tag}}`t{{.Size}}" | Out-File -FilePath "../script/$testResultsDir/v2_size.txt"

Write-Host "3. 显示镜像体积对比..." -ForegroundColor Cyan
Write-Host ""
Write-Host "=== 镜像体积对比 ===" -ForegroundColor Green
Write-Host "普通版本 (v1):" -ForegroundColor Yellow
Get-Content "../script/$testResultsDir/v1_size.txt"
Write-Host ""
Write-Host "优化版本 (v2):" -ForegroundColor Yellow
Get-Content "../script/$testResultsDir/v2_size.txt"
Write-Host ""

Write-Host "4. 测试两个版本的运行..." -ForegroundColor Cyan
Write-Host "启动普通版本容器..." -ForegroundColor Yellow
docker run -d --name app-v1 -p 5001:5000 cloud-app:v1
Start-Sleep -Seconds 5

Write-Host "启动优化版本容器..." -ForegroundColor Yellow
docker run -d --name app-v2 -p 5002:5000 cloud-app:v2
Start-Sleep -Seconds 5

Write-Host "5. 验证两个应用是否正常运行..." -ForegroundColor Cyan
Write-Host ""
Write-Host "普通版本 (端口 5001):" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5001/" -UseBasicParsing -TimeoutSec 5
    Write-Host $response.Content
} catch {
    Write-Host "请求失败"
}
Write-Host ""
Write-Host "优化版本 (端口 5002):" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5002/" -UseBasicParsing -TimeoutSec 5
    Write-Host $response.Content
} catch {
    Write-Host "请求失败"
}
Write-Host ""

Write-Host "6. 清理测试容器..." -ForegroundColor Cyan
docker stop app-v1 app-v2
docker rm app-v1 app-v2

Write-Host "7. 生成详细报告..." -ForegroundColor Cyan
Set-Location "../script"
$reportPath = "$testResultsDir/analysis.txt"
"=== 详细分析报告 ===" | Out-File -FilePath $reportPath
"生成时间: $(Get-Date)" | Out-File -FilePath $reportPath -Append
"" | Out-File -FilePath $reportPath -Append
"普通版本镜像信息:" | Out-File -FilePath $reportPath -Append
docker history cloud-app:v1 --no-trunc | Out-File -FilePath $reportPath -Append
"" | Out-File -FilePath $reportPath -Append
"优化版本镜像信息:" | Out-File -FilePath $reportPath -Append
docker history cloud-app:v2 --no-trunc | Out-File -FilePath $reportPath -Append

Write-Host ""
Write-Host "=== 实验完成 ===" -ForegroundColor Green
Write-Host "详细报告已保存到: $reportPath" -ForegroundColor Yellow

# 显示最终对比
Write-Host ""
Write-Host "=== 镜像体积对比结果 ===" -ForegroundColor Green
docker images cloud-app:v1 cloud-app:v2 --format "table {{.Repository}}`t{{.Tag}}`t{{.Size}}`t{{.CreatedSince}}"
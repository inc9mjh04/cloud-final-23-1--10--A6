#!/bin/bash

echo "=== Docker镜像体积对比实验 ==="
echo "实验时间: $(date)"
echo ""

# 创建测试目录
mkdir -p test_results

echo "1. 构建普通版本镜像..."
cd ../app-v1
docker build -t cloud-app:v1 .
docker images cloud-app:v1 --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" > ../script/test_results/v1_size.txt

echo "2. 构建优化版本镜像..."
cd ../app-v2
docker build -t cloud-app:v2 .
docker images cloud-app:v2 --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" > ../script/test_results/v2_size.txt

echo "3. 显示镜像体积对比..."
echo ""
echo "=== 镜像体积对比 ==="
echo "普通版本 (v1):"
cat ../script/test_results/v1_size.txt
echo ""
echo "优化版本 (v2):"
cat ../script/test_results/v2_size.txt
echo ""

echo "4. 测试两个版本的运行..."
echo "启动普通版本容器..."
docker run -d --name app-v1 -p 5001:5000 cloud-app:v1
sleep 5

echo "启动优化版本容器..."
docker run -d --name app-v2 -p 5002:5000 cloud-app:v2
sleep 5

echo "5. 验证两个应用是否正常运行..."
echo ""
echo "普通版本 (端口 5001):"
curl -s http://localhost:5001/ || echo "请求失败"
echo ""
echo "优化版本 (端口 5002):"
curl -s http://localhost:5002/ || echo "请求失败"
echo ""

echo "6. 清理测试容器..."
docker stop app-v1 app-v2
docker rm app-v1 app-v2

echo "7. 生成详细报告..."
cd ../script
echo "=== 详细分析报告 ===" > test_results/analysis.txt
echo "生成时间: $(date)" >> test_results/analysis.txt
echo "" >> test_results/analysis.txt
echo "普通版本镜像信息:" >> test_results/analysis.txt
docker history cloud-app:v1 --no-trunc >> test_results/analysis.txt
echo "" >> test_results/analysis.txt
echo "优化版本镜像信息:" >> test_results/analysis.txt
docker history cloud-app:v2 --no-trunc >> test_results/analysis.txt

echo ""
echo "=== 实验完成 ==="
echo "详细报告已保存到: test_results/analysis.txt"

echo ""
echo "=== 镜像体积对比结果 ==="
docker images cloud-app:v1 cloud-app:v2 --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}"
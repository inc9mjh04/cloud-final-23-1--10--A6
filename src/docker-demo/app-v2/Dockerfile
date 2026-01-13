# Dockerfile - 多阶段构建（体积优化）
# 第一阶段：构建阶段
FROM python:3.9-slim as builder

WORKDIR /app

# 只复制依赖文件
COPY requirements-minimal.txt .

# 创建虚拟环境并安装依赖
RUN python -m venv /opt/venv
# 激活虚拟环境并安装
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir -r requirements-minimal.txt

# 第二阶段：运行阶段 - 使用更小的基础镜像
FROM python:3.9-alpine

# 安装最小的运行时依赖
RUN apk add --no-cache libstdc++

# 从构建阶段复制虚拟环境
COPY --from=builder /opt/venv /opt/venv

# 设置工作目录
WORKDIR /app

# 复制应用代码
COPY app.py .

# 设置环境变量
ENV PATH="/opt/venv/bin:$PATH"

# 创建非root用户
RUN addgroup -g 1001 -S appuser && \
    adduser -u 1001 -S appuser -G appuser
USER appuser

# 暴露端口
EXPOSE 5000

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')"

# 运行应用
CMD ["python", "app.py"]
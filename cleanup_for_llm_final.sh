#!/bin/bash

# ==============================================================================
# FlowPolicy 项目清理脚本
# 用途：减小项目大小以便传给LLM，但保持完整的架构和代码理解
# ==============================================================================

set -e

echo ""
echo "=============================================="
echo "   FlowPolicy 项目清理脚本"
echo "=============================================="
echo ""

# ------------------------------------------------------------------------------
# 1. 删除 Python 缓存
# ------------------------------------------------------------------------------
echo "[1/8] 删除 Python 缓存..."
find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "*.pyc" -type f -exec rm -f {} + 2>/dev/null || true
find . -name "*.pyo" -type f -exec rm -f {} + 2>/dev/null || true
echo "  ✓ 完成"

# ------------------------------------------------------------------------------
# 2. 删除 egg-info
# ------------------------------------------------------------------------------
echo ""
echo "[2/8] 删除 egg-info..."
rm -rf FlowPolicy/flow_policy_3d.egg-info
echo "  ✓ 完成"

# ------------------------------------------------------------------------------
# 3. 删除 results 视频文件夹
# ------------------------------------------------------------------------------
echo ""
echo "[3/8] 删除 results 视频文件夹..."
rm -rf results
echo "  ✓ 完成"

# ------------------------------------------------------------------------------
# 4. 删除预训练模型权重
# ------------------------------------------------------------------------------
echo ""
echo "[4/8] 删除预训练模型权重..."
rm -rf third_party/VRL3/vrl3_ckpts
echo "  ✓ 完成"

# ------------------------------------------------------------------------------
# 5. 删除 Metaworld 的纹理图片
# ------------------------------------------------------------------------------
echo ""
echo "[5/8] 删除 Metaworld 纹理图片..."
rm -rf third_party/Metaworld/metaworld/envs/assets_v2/textures 2>/dev/null || true
rm -rf third_party/Metaworld/metaworld/envs/assets_v2/scene/textures 2>/dev/null || true
echo "  ✓ 完成"

# ------------------------------------------------------------------------------
# 6. 删除 Gym 的测试、文档、脚本
# ------------------------------------------------------------------------------
echo ""
echo "[6/8] 删除 Gym 的测试、文档..."
rm -rf third_party/gym-0.21.0/tests
rm -rf third_party/gym-0.21.0/docs
rm -rf third_party/gym-0.21.0/.github
rm -rf third_party/gym-0.21.0/scripts
rm -f third_party/gym-0.21.0/*.md
rm -f third_party/gym-0.21.0/test_requirements.txt
rm -f third_party/gym-0.21.0/requirements.txt
echo "  ✓ 完成"

# ------------------------------------------------------------------------------
# 7. 删除 Gym 的二进制资源（STL模型、图片等）
# ------------------------------------------------------------------------------
echo ""
echo "[7/8] 删除 Gym 的二进制资源..."
rm -rf third_party/gym-0.21.0/gym/envs/robotics/assets/stls
rm -rf third_party/gym-0.21.0/gym/envs/robotics/assets/textures
rm -rf third_party/gym-0.21.0/gym/envs/classic_control/assets
echo "  ✓ 完成"

# ------------------------------------------------------------------------------
# 8. 删除其他非必要文件
# ------------------------------------------------------------------------------
echo ""
echo "[8/8] 删除其他非必要文件..."
rm -f supp.pdf
rm -f index.html
# 如果存在 visualizer 文件夹，删除其资源但保留代码
if [ -d "visualizer" ]; then
    echo "  检测到 visualizer 文件夹，保留核心代码"
    # 只删除 visualizer 中的大资源文件（如果有）
    find visualizer -name "*.png" -o -name "*.jpg" -o -name "*.gif" -o -name "*.mp4" -o -name "*.zip" -o -name "*.tar" | xargs rm -f 2>/dev/null || true
fi
echo "  ✓ 完成"

# ------------------------------------------------------------------------------
# 完成
# ------------------------------------------------------------------------------
echo ""
echo "=============================================="
echo "   清理完成！"
echo "=============================================="
echo ""
echo "📊 项目大小统计："
du -sh .
echo ""
echo "📁 项目结构（主要文件）："
ls -lh
echo ""
echo "✅ 保留的核心组件："
echo "   - FlowPolicy 完整源代码"
echo "   - 所有配置文件和脚本"
echo "   - 文档（README, install.md, ai.md）"
echo "   - third_party 的所有Python代码"
echo "   - Metaworld 的XML模型文件"
echo ""
echo "❌ 删除的文件（不影响理解）："
echo "   - Python 缓存文件"
echo "   - results/ 视频演示"
echo "   - 预训练模型权重"
echo "   - 纹理、图片、3D模型文件"
echo "   - 测试、文档文件夹"
echo ""
echo "🎯 现在可以安全地将项目传给 LLM 了！"
echo ""

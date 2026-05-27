<br />

## FlowPolicy 项目详解

根据对项目代码和文档的扫描，以下是 **FlowPolicy** 项目的详细讲解：

***

### 📌 项目概述

**FlowPolicy** 是一个用于机器人操控的**3D视觉策略学习框架**，基于\*\*一致性流匹配（Consistency Flow Matching）\*\*技术实现快速且鲁棒的政策生成。该项目是 **AAAI 2025 Oral** 论文的官方实现。

**论文链接**: [arXiv:2412.04987](https://arxiv.org/abs/2412.04987)

***

### 🎯 核心创新点

1. **一致性流匹配（Consistency Flow Matching）**
   - 与传统扩散模型需要多步迭代推理不同，FlowPolicy 通过归一化速度场的自一致性，只需**单步推理**即可生成策略
   - 定义了从噪声分布到动作空间的直线流（straight-line flows）
2. **3D点云条件**
   - 使用 3D 点云作为观测输入，而非 2D 图像
   - 通过 PointNet 编码器提取 3D 视觉特征
3. **7倍推理加速**
   - 在保持竞争性成功率的同时，实现 **7倍推理速度提升**

***

### 🏗️ 项目架构

```
FlowPolicy/
├── flow_policy_3d/
│   ├── policy/flowpolicy.py      # 核心策略实现
│   ├── consistencyfm/            # 一致性流匹配模块
│   │   └── conditional_flow_matching.py
│   ├── sde_lib.py                # SDE/流匹配核心算法
│   ├── model/
│   │   ├── flow/                # ConditionalUnet1D 等模型
│   │   └── vision/              # PointNet 视觉编码器
│   ├── env/
│   │   ├── adroit/              # Adroit 环境接口
│   │   └── metaworld/           # Metaworld 环境接口
│   └── dataset/                 # 数据集加载
├── train.py                      # 训练入口
└── eval.py                       # 评估入口
```

***

### 🔬 技术原理

#### 训练阶段（一致性损失）

在 [flowpolicy.py#L241-L354](file:///home/xx/FlowPolicy-main/FlowPolicy/flow_policy_3d/policy/flowpolicy.py#L241-L354) 中实现：

1. **采样两个时间点**: $t$ 和 $r = \text{clamp}(t + \delta)$
2. **生成中间状态**:
   - $x\_t = t \cdot \text{action} + (1-t) \cdot \epsilon$ (噪声)
   - $x\_r = r \cdot \text{action} + (1-r) \cdot \epsilon$
3. **计算一致性损失**: 强制 $f(t, x\_t) = f(r, x\_r)$，其中 $f$ 是 Euler 积分后的状态

```python
# 核心损失函数
ft = f_euler(t_expand, segment_ends_expand, xt, vt)   # 前向预测
fr = threshold_based_f_euler(...)                      # 边界处预测
loss = torch.mean(losses_f + alpha * losses_v)          # 一致性损失
```

#### 推理阶段（单步生成）

在 [flowpolicy.py#L196-L235](file:///home/xx/FlowPolicy-main/FlowPolicy/flow_policy_3d/policy/flowpolicy.py#L196-L235) 中：

```python
# 仅需1步推理！
for i in range(sde.sample_N):  # sample_N = 1
    pred = self.model(z, t*99, ...)
    z = z + pred * dt
```

***

### 📊 支持的任务

| 环境            | 任务示例                                                            |
| :------------ | :-------------------------------------------------------------- |
| **Adroit**    | door, hammer, pen (灵巧手操作)                                       |
| **Metaworld** | 34个任务: reach, push, pick\_place, assembly, drawer\_open/close 等 |

***

### 🚀 使用方法

```bash
# 1. 生成演示数据
bash scripts/gen_demonstration_adroit.sh hammer

# 2. 训练策略
bash scripts/train_policy.sh flowpolicy adroit_hammer 0129 0 0

# 3. 评估策略
bash scripts/eval_policy.sh flowpolicy adroit_hammer 0129 0 0
```

***

### 📦 核心依赖

- **PyTorch** + **Mujoco** (物理仿真)
- **Mujoco-py** (Python bindings)
- **Gym 0.21.0** + **Metaworld** (强化学习环境)
- **PyTorch3D** (3D点云处理)
- **Diffusers** (扩散模型工具)

***

### 🔑 关键配置参数

在 [flowpolicy.yaml](file:///home/xx/FlowPolicy-main/FlowPolicy/flow_policy_3d/config/flowpolicy.yaml) 中：

| 参数                   | 默认值 | 说明              |
| :------------------- | :-- | :-------------- |
| `horizon`            | 4   | 动作预测视野          |
| `n_obs_steps`        | 2   | 观测步数            |
| `num_inference_step` | 1   | 推理步数 (一致性FM核心！) |
| `encoder_output_dim` | 64  | 视觉编码器输出维度       |

***

### 📝 代码继承来源

该项目代码基于以下优秀工作构建：

- [3D Diffusion Policy](https://github.com/YanjieZe/3D-Diffusion-Policy)
- [Consistency\_FM](https://github.com/YangLing0818/consistency_flow_matching)
- [VRL3](https://github.com/microsoft/VRL3)
- [Metaworld](https://github.com/Farama-Foundation/Metaworld)

## 如何运行 FlowPolicy 项目

根据项目文档和脚本，以下是完整的运行步骤：

***

### 第一步：安装环境

详细安装说明请参考 [install.md](file:///home/xx/FlowPolicy-main/install.md)

```bash
# 1. 创建 Python 环境
conda create -n flowpolicy python=3.8
conda activate flowpolicy

# 2. 安装 PyTorch (根据你的 CUDA 版本选择)
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu117

# 3. 安装 FlowPolicy
cd FlowPolicy && pip install -e . && cd ..

# 4. 安装 Mujoco
cd ~/.mujoco
wget https://github.com/deepmind/mujoco/releases/download/2.1.0/mujoco210-linux-x86_64.tar.gz
tar -xvzf mujoco210.tar.gz

# 5. 设置环境变量 (添加到 ~/.bashrc)
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${HOME}/.mujoco/mujoco210/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/nvidia
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64
export MUJOCO_GL=egl

# 6. 安装 mujoco-py
cd third_party/mujoco-py-2.1.2.14 && pip install -e . && cd ../..

# 7. 安装其他依赖
pip install zarr==2.12.0 wandb ipdb gpustat dm_control omegaconf hydra-core==1.2.0 dill==0.3.5.1 einops==0.4.1 diffusers==0.11.1 numba==0.56.4 moviepy imageio av matplotlib termcolor natsort open3d

# 8. 安装 sim env
pip install setuptools==59.5.0 Cython==0.29.35 patchelf==0.17.2.0
cd third_party/gym-0.21.0 && pip install -e . && cd ..
cd third_party/Metaworld && pip install -e . && cd ..
cd third_party/rrl-dependencies && pip install -e mj_envs/. && pip install -e mjrl/. && cd ..
```

***

### 第二步：登录 WandB (可选但推荐)

```bash
wandb login
```

***

### 第三步：生成演示数据

```bash
# Adroit 环境示例
bash scripts/gen_demonstration_adroit.sh hammer

# Metaworld 环境示例  
bash scripts/gen_demonstration_metaworld.sh reach
```

生成的演示数据会自动保存到 `FlowPolicy/data/` 目录。

***

### 第四步：训练策略

```bash
# 训练 FlowPolicy (Adroit hammer 任务)
bash scripts/train_policy.sh flowpolicy adroit_hammer 0129 0 0

# 参数说明:
#   $1 = alg_name    (算法名称: flowpolicy)
#   $2 = task_name   (任务名称: adroit_hammer, metaworld_door-close 等)
#   $3 = addition_info (实验标识)
#   $4 = seed        (随机种子)
#   $5 = gpu_id      (GPU ID)
```

**支持的 Adroit 任务**: `door`, `hammer`, `pen`

**支持的 Metaworld 任务** (34个): `reach`, `push`, `pick_place`, `assembly`, `drawer-close`, `door-open`, `faucet-open`, 等等

***

### 第五步：评估策略

```bash
# 评估训练好的策略
bash scripts/eval_policy.sh flowpolicy adroit_hammer 0129 0 0 0
```

***

### 目录结构

```
FlowPolicy/
├── FlowPolicy/           # 主代码
│   ├── flow_policy_3d/   # 核心策略、环境、数据集
│   ├── train.py          # 训练入口
│   └── eval.py           # 评估入口
├── data/                 # 演示数据和输出
├── scripts/              # 运行脚本
└── third_party/          # 第三方库 (Mujoco-py, Gym, Metaworld等)
```

***

### 注意事项

1. **路径问题**: 脚本中使用了硬编码路径 `/data/code/FlowPolicy/`，你可能需要根据实际目录修改
2. **GPU**: 确保 CUDA 可用，`nvidia-smi` 验证
3. **WandB**: 用于日志和视频记录，首次使用需要登录


# 选题与语义查重记录

日期：2026-10-14（Asia/Shanghai）。这是一份公开的去秘密工程记录，不是报名申报书。
研究范围内未找到具有相同完整任务闭环的成熟直接替代；这不是唯一性或主办方裁决。

## 流程、范围与限制

实际执行 Milky2018/osc2026-guide 的 Project Research Guide：`moon search <keyword> --limit 100 --json`，
查看 MoonCakes 模块详情/公开归档的 README、接口、实现和测试，再检查关联 GitHub。
源码归档取自官方 `download.mooncakes.io/user/<owner>/<module>/<version>.zip`。
检索覆盖 MoonCakes、GitHub MoonBit 仓库/代码和 moonbitlang/awesome-moonbit，另比较本地永久选题注册表的完整相关指纹。

MoonCakes 扩词：rectangle/packing/maxrects/skyline/guillotine/atlas/bin pack/layout；
robots/robots.txt/crawler/REP/sitemap；design of experiments/DOE/factorial/fractional factorial/
alias matrix/D-optimal/Box Behnken/central composite/Plackett Burman/orthogonal design/
response surface/experimental design/coordinate exchange/foldover/latin hypercube/sobol。

GitHub 检索包括 rectangle packing、maxrects、robots.txt、design experiments 仓库及
fractional factorial、D-optimal、Box-Behnken、experimental design 的 MoonBit 代码。
D-optimal 命中 YuFenfen-ai/FlowLabLite 的 QUICK/TVD CFD schemes，为文本误命中，已读源码排除。
代码搜索和列表不是全网穷尽；搜索结果具有排序、索引延迟、语言分类和100项上限限制。
通用网页检索工具未返回可用结果，不作为完成查重的证据；MoonCakes API/归档和 GitHub 为实际证据。

## 三个不同领域候选

| 候选 | 用户—输入—操作—输出与范围 | 直接重合证据 | 决策 |
|---|---|---|---|
| 矩形/纹理图集装箱库 | 渲染资源作者给出矩形；MaxRects/旋转/页分配；输出装箱布局。也服务UI排版和切割规划 | YM-ai-nb/rectloom@0.1.0 已有匹配装箱闭环；mizchi/kagura_core/packing2d 已有 MaxRects | 硬失败，淘汰；不换名重建 |
| robots 排爬政策解析 | 爬虫/索引/归档用户给出 robots.txt 与URL；规则匹配；输出允许/禁止策略 | 2111950632/robots-gate@0.2.2，cauchyQ/moonbit-robots、JQ-ai-nb/robopolicy 等已有相同核心任务 | 硬失败，淘汰；不增加外壳规避 |
| MoonDOE | 试验工程/仿真/参数规划给出连续因素、模型和预算；有符号混杂/辨识/保护增广；输出可估计性及执行计划 | 相邻 sampling/regression，但未见相同的定义群→响应面→候选交换/锁定增广闭环 | 通过记录范围内的语义门禁，独立建设 |

1–5分是选题判断，不是实验指标。维度为生态广度/用户多样性/复用/重合风险可控/实现深度/可验证/工期/维护：
装箱 5/4/5/1/4/5/4/4=32；robots 5/5/5/1/3/5/5/4=33；DOE 4/4/5/4/5/5/4/4=35。
前两项硬失败不能由评分抵消。DOE 是通过全部门禁的候选。

## 高度相邻与能力矩阵

| 项目/版本与源码 | 用户/工作流 | 实际 inspected 能力 | 与 MoonDOE 的重合/缺口 | 分类 |
|---|---|---|---|---|
| [moonbit_extractor 0.1.2](https://github.com/zhaoyuanjuns/moonbit-extractor) | 提取工艺工程；采样/过程拟合优化 | sampling 的 full_factorial、randomize_runs、assign_blocks、latin_hypercube；process regression 的源码与接口 | 全因子、随机化、回归重合；未见有符号定义群/alias resolution、CCD/BBD、受保护候选 D 交换 | 高度相邻 |
| [moonbit-adsorption 0.2.1](https://github.com/weidekais/moonbit-adsorption) | 吸附工程过程建模 | utils/experiment.mbt 的 factorial 网格 | 网格生成重合，不是领域中立的模型辨识/增广引擎 | 同方向不同任务 |
| [moon-experiment 0.2.3](https://github.com/pla678889/moon-experiment) | A/B 用户分配、指标比较/序贯检验 | README/API/包源码；在整个归档检查 DOE 核心术语 | 实验一词相近，输入/统计行为不同 | 同方向不同任务 |
| jdjjttr/montecarlo 0.1.0 | 仿真采样与方差降低 | Latin hypercube/Sobol 的接口、源码/测试 | 空间采样相邻，不输出有符号混杂/模型可估计性或保护增广 | 同方向不同任务 |
| [rectloom 0.1.0](https://github.com/YM-ai-nb/rectloom) | 图集/矩形装箱 | 多策略装箱README/源代码/接口 | 与被拒绝装箱候选直接重合；与DOE无实质重合 | 外部直接替代 |
| [robots-gate 0.2.2](https://github.com/2111950632/moonrobots-gate) | robots.txt 政策 | 解析/匹配/调试API及实现 | 与被拒绝robots候选直接重合；与DOE无实质重合 | 外部直接替代 |

这些版本在公开registry中可下载，源码和测试可访问；下载数/发布时间不是正确性或成熟度的证明，不能把表中的所有相邻项目一概称为成熟。
被淘汰方案存在公开可复用的直接核心实现，即使不推断维护活跃程度，也无必要重建。

## 独立建设必要性与反向复核

扩展 moonbit_extractor 可以改善提取过程采样；但 MoonDOE 的主合同是连续因素/任意显式单项式的
有符号定义群、秩与遗漏项诊断、响应面设计、有限候选预算和已完成试验锁定。
将这套领域中立合同放入提取工艺模块会引入不必要的领域耦合。因此独立包只依赖标准库，
不复刻工艺模型、A/B序贯推断、LHS/Sobol采样或提取优化器。不把共有网格/回归函数包装成创新。

本地注册表逐项比较 MoonBench（运行时基准）、MoonQP（凸QP）、MoonConcept（形式概念）、
MoonBelief（信念推理）、MoonCSP（约束求解）的已预留/已完成问题、用户、输入输出、算法与非目标；
其核心任务均不等于预算试验设计；保留全部既有记录并排他锁原子预留 MoonDOE。

交付前同日再次反向查询 GitHub `fractional factorial` / `Box-Behnken` MoonBit 代码（100上限）为空，
MoonCakes `D-optimal`（100上限）返回模糊命中，重新检查已相邻 A/B 模块；不能把零命中当唯一性。
自编验收明确落在别名群/秩→foldover、二次响应面、保护选点三个独立复用工作流，未转为其他已预留题目。

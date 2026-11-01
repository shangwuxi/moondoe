# MoonDOE

**可复用的有限预算试验设计与模型可辨识性工具箱** · pure MoonBit · MIT

`shangwuxi/moondoe@0.1.3` 面向试验工程、仿真参数分析和候选集试验计划。
它把「生成点」连接到「哪些效应可估计、如何解混杂、预算内选哪些点、如何导出执行计划」，而不是 A/B 测试或通用优化器。

## 安装

验收要求 moonc 不低于 `0.10.16`；本项目复验与 CI 固定使用 MoonBit 2026-10-28 工具链（moonc `v0.10.18+6c83a7f62`）。新建项目后：

```sh
moon add shangwuxi/moondoe@0.1.3
```

在调用包的 `moon.pkg` 中配置：

```moonbit
import {
  "shangwuxi/moondoe" @doe,
}
```

本模块只依赖 MoonBit 标准库；没有 FFI、Python/R 运行时或外部数值库。
完整公开签名见根目录 `pkg.generated.mbti`，运行时可验证的完整示例见 `examples/`。

## 最小工作流

在 main 包启用 `options("is-main": true)`，保存以下 `main.mbt`：

```moonbit
///|
fn main raise {
  let factors = [@doe.factor("temperature", 20.0, 80.0)]
  let candidates = @doe.factorial(factors, [5])
  let model = @doe.terms(factors, 1)
  let chosen = @doe.d_optimal(candidates, model, 2)
  assert_true(@doe.diagnose(chosen.plan, model).estimable)
  println(@doe.plan_csv(chosen.plan))
}
```

`Factor.low/high` 定义物理量到编码坐标的线性映射：low→−1、high→+1。
所有 `Run.point`、约束、模型和 CSV 数值均为**编码坐标**；用 `actual_points` 显式转换为物理值。
设计点可以超出 [−1,+1]（例如 CCD 轴点），`within_bounds` 报告越界 run ID，不自动截断。

## 三个端到端示例

从仓库根目录运行；每个示例包含断言，不只是打印：

```sh
moon run examples/screening
moon run examples/response
moon run examples/candidates
```

1. **试验工程师**：有符号二水平分式→分辨率 III 和 alias→选定因素 foldover→8 次试验中辨识主效应与交互项→QR 拟合→物理坐标和诊断报告。
2. **仿真建模作者**：15-run Box–Behnken→10 项二次模型→合成响应与重复点扰动→纯误差/失拟拆分→预测、梯度、单位方差轮廓；另检查 CCD 轴点越界。
3. **参数规划工具作者**：25 点网格→线性可行域过滤→4-run D 交换→保护既有候选索引扩增到6次→两区组随机计划→CSV/JSON 双向校验。

合成响应仅用于验证算法闭环，不是实际实验结果；例子不声称优化物理工艺。

## 能力索引

| 阶段 | API / 文件 | 行为 |
|---|---|---|
| 数据边界 | `factor`, `plan`, `coded_plan`, `physical_plan` | 有限值、维度、唯一 ID、复制隔离 |
| 规则设计 | `factorial`, `two_level`, `fraction` | 混合水平全因子；有符号二水平生成元 |
| 混杂分析 | `defining_relation`, `resolution`, `aliases`, `effect_name` | XOR 定义群、最短非单位词、带符号效应别名 |
| 设计扩增 | `foldover`, `replicate`, `add_centers` | 保留区组和来源、生成新的执行 ID |
| 响应面 | `central_composite`, `box_behnken`, `terms` | CCD/BBD；显式0/1/2阶单项式 |
| 线性代数 | `matrix_rank`, `information`, `inverse`, `log_determinant` | 列均衡秩、加权信息、行缩放求逆、SPD Cholesky |
| 模型验证 | `least_squares`, `fit_plan`, `diagnose`, `alias_matrix` | 列主元两遍 MGS QR；可估计性和遗漏项投影 |
| 预测 | `predict`, `gradient`, `covariance`, `leverage`, `variance_profile` | 编码坐标导数和线性模型不确定性 |
| 有限选点 | `d_optimal`, `augment_optimal`, `refine_selection` | 秩递增种子、贪心补齐、有限轮单点交换、锁定前缀 |
| 可行性/执行 | `filter_candidates`, `filter_points`, `unique_points`, `randomize`, `balanced_blocks` | 线性约束、隔离谓词、精确去重、可复现洗牌 |
| 残差拆分 | `partition_error`, `standardized_residuals` | 区组敏感重复组、纯误差/失拟 SS 和自由度 |
| 交换格式 | `plan_csv`, `plan_from_csv`, `plan_json`, `plan_from_json`, `diagnostics_json` | 受限文本；严格字段；`moondoe/1` 模式 |

## 数值与资源边界

- 1–16 factors，1–4096 runs；名称/ID 不允许重复；有限数绝对值≤`1e100`。
- 矩阵输入≤4096行×128列，QR≤64列、行数≥列数；不返回秩亏拟合的伪逆。
- 候选交换≤256候选、≤16模型项、模型项数≤选择数≤64、1–16轮；估算分解工作≤1亿，超额抛出 `Budget`。
- 默认相对阈值`1e-10`；可配置范围`1e-14..0.01`。不同数值例程的阈值含义不同，详见 `docs/numerics.md`。
- CSV/JSON 读写文本均≤200万 UTF-16 单元；序列化结果超限时抛出 `Budget`，不会返回自身读取器拒绝的超大文本；CSV字段≤4096单元、≤18列、≤4097行；JSON嵌套≤8。
- 程序验证结构和资源上限；**不承诺实时执行**，多个校验为二次复杂度。

`DesignError` 区分 `Invalid`（非法输入/数值范围）、`Budget`（资源上限）和 `Singular`（模型不可辨识/求逆失败）。
公开结构的数组可由调用方修改；构造/变换复制数组，并在进入核心操作时重新验证。不要在操作期间并发改写输入。

D-optimal 是候选集上的**局部交换启发式**，不保证全局最优；`converged=false` 表示轮数耗尽，true仅表示完整一轮未发现超过阈值的单点改善。
不含连续坐标交换、重复候选抽样、分类因素、混合物设计、Plackett–Burman、p值、置信区间、贝叶斯/因果推断、仪器控制或安全关键决策。

## 复现检查

```sh
moon info && moon fmt
moon fmt --check
moon check --deny-warn
moon test --deny-warn
moon build --deny-warn
bash scripts/verify.sh wasm-gc
bash scripts/verify.sh wasm
bash scripts/verify.sh js
CC=gcc bash scripts/verify.sh native
python scripts/audit.py
```

CI 在 Ubuntu 24.04 用同一官方快照执行四目标的检查、测试、构建及三个示例，检查接口漂移。
安装脚本使用官方版本化下载地址，并检查 ETag 与 SHA-256 固定同一快照；这些摘要不是独立签名，对象变化时失败而不自动升级。
Windows 本地不具备 C 编译器时，native 运行以真实 CI 结果为证，不伪称本机通过。

## 验证、来源和邻近项目

**v0.1.0 发布快照**的38个具名测试覆盖设计/拟合/执行/格式路径，含枚举52个有符号单生成元设计、126个小网格4选组合的独立行列式校验、解析加权解、尺度/奇异/极端计数以及49个随机种子。
这些是自编数学断言，不是与 R/Python 的自动差分测试，也没有性能优势声明。
该发布快照生产 MoonBit 20个文件共2219物理行（排除测试、示例、生成接口）。当前工作树规模/测试数以 `scripts/audit.py` 实测为准。

[moonbit_extractor](https://github.com/zhaoyuanjuns/moonbit-extractor) 提供提取工程中的 factorial、随机化和回归，属于高度相邻项目。
MoonDOE 的独立价值是领域中立的有符号定义关系、别名/秩诊断、响应面设计以及锁定既有试验的预算选点；全因子/随机化本身不是创新声明。
[moon-experiment](https://github.com/pla678889/moon-experiment) 面向 A/B 检验，不能当作本项目的 DOE 替代。
检索范围和限制见 `docs/competition/duplicate-check.md`；不宣称绝对唯一。

原始实现与测试由本项目编写，未移植上述项目代码。MIT；标准库许可和概念性对标见 `ATTRIBUTION.md`；AI参与说明见 `AI-USE.md`。

## 0.1.1 修订（2026-10-20）

本次补丁增加18项回归测试，当前共56项；v0.1.0的38项测试仍保留。
修复重复扩增/长 ID 的自动命名冲突、极小非正规数区间映射、自动模型标签冲突/超长、序列化输出预算不对称，以及梯度入口缺少维度预算的问题。
另外修复量纲相关的矩阵对称校验、标准化残差及预测方差容差，并对失拟 F 比值执行数值范围检查。
普通生成名称保持不变；发生冲突或超长时使用确定性的有界备用名称，保留模型幂次/顺序和原试验记录。
0.1.1保留原有公开 API；新增校验可能拒绝旧版错误接受的输入或超出数值预算的结果。
v0.1.0 / MoonCakes 0.1.0仍保留旧行为；该段描述0.1.1发布快照；当前复验请使用下节的0.1.2，不以旧发布的CI代替当前修订证据。

## 0.1.2 修订（2026-10-20）

本次增加8项回归测试，当前共64项；保留此前全部56项测试。
修复物理/编码转换在区间中心的消减误差：对称区间中的微小正负坐标不再被 `+1` 或端点相减吞并成同一个中心点，物理计划能够保留可辨识的微小变化。
编码计算补偿区间中点的舍入误差，保留窄区间与非正规数端点行为；解码对中心与端点分别使用稳定表达式，不承诺任意病态尺度下的正确舍入。
同时为 `diagnostics_json` 补齐200万 UTF-16单元输出预算，超限抛 `Budget`；正常诊断报告的9个字段与 `moondoe/1` 计划格式均不变。
公开 API 签名、依赖和支持后端不变。已发布的0.1.0/0.1.1不可变，不包含本次修复；请安装精确版本0.1.2。

## 0.1.3 工具链更新（2026-11-01）

按照验收指南将 CI 固定工具链从 moonc 0.10.15 更新为 0.10.18，并校验官方版本归档的 SHA-256。共享验证脚本在检查、构建、测试前强制要求 moonc ≥ 0.10.16。安装说明同步到 0.1.3，新编译器生成的接口将旧 `Int` 别名显式写为 `Int32`；库实现、API 语义和运行时依赖保持不变；历史 0.1.2 修复继续包含在本版本内。

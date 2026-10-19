# 变更记录

格式：Keep a Changelog；版本号：语义化 `1.x`（库内容用小版本号，见 `README.md` §6）。

**标签规则**：每个 `VERSION` 对应一个 `vX.Y.Z` 标签；库自身的 `vN` 不进标签名（避免与仓库版本混淆）。

## [1.0.0] - 2026-10-19

首次发布：把三个思维模型的常量层从 `dsh-thinking-models` 拆出，成为独立仓库。

### Added
- `knowledge-tree/`：认知树 **v1**（核查 2026-10-18）——`software`（L0，六正交子层：lifecycle/init/dependency/quota/concurrency/config）与 `win-service`（L1）两个节点；4 个待建候选（hardware / network / org-process / data-consistency）留空不实现。
- `relation-table/`：关系表 **v1**（核查 2026-10-19）——两种边分栏（关联边无向／支持边有向）、`权重 = 关系类型 × 机制步数`、九类关系、秩矩阵（①–⑤）、两条硬规则、权重只排序不当概率、新增类型的四道门槛。
- `relation-table/calibration.md`：校准记录首版——收录 `docs/benchmark/after/web.md` 的 `W = S × F` 实例（标注为**支持边**口径，数值不可迁移）、首次秩冲突裁决（同秩看步数）、三条待收候选、季度归并规则。
- `structure-tree/`：结构模式库 **v2.4**（核查 2026-10-18）——12 个基（量六 + 质六）、2 个修饰（sampling-error / irreversibility）、3 条组合规则（叠加／串联／嵌套）、12 条命名复合、识别协议与边界。
- `manifest.md`：三库版本总表 + 共同字段约定 + 共同禁令。
- `scripts/state.ps1`（`.cmd`）：打印仓库状态、三库版本、与技能仓库／安装位的哈希漂移；`-Verify` 漂移即 exit 1。
- `scripts/sync.ps1`（`.cmd`）：三库单向同步到 `dsh-thinking-models/<id>/tree/` 与 `<DSH_HOME>/skills/<id>/tree/`；`-Check` 只比对不写盘。

### Changed（相对拆出前的旧位置）
- 关系表从 `web-association-exhaustive/SKILL.md` §2.1 的**内联表**升级为**独立库**：内联表保留为操作摘要，库版本、校准记录、候选区只在本仓库维护。技能正文补一行指向 `tree/relations.md`。
- 认知树与结构表：正文内容不变，仅迁移；`structure-tree/index.md` 里的路径说明原本就写成 `structure-tree/index.md（随技能分发时同名 tree/index.md）`，迁移后无需改字。

### 未做（刻意）
- 没有把方法正文（五层骨架、四种动作、识别协议中属技能的部分）搬进来——常量与方法分家是本仓库存在的唯一理由。
- 没有给倒推法建库——它与三库零接口。
- 没有做字段级校验脚本（只验文件与哈希），见 `STATE.md` §8。

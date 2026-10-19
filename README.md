# 三种常量库（minds 的只读背景知识）

> 三个思维模型的**常量层**从技能仓库里拆出来，单独维护、单独升版、单独校验。
> 技能正文（方法）在 [`dsh-thinking-models`](https://github.com/plasmaflea/dsh-thinking-models)；**本仓库只放常量**。

**仓库版本**：1.1.1 · **首发**：2026-10-19

---

## 1. 这是什么／不是什么

**是**：三个模型反复要用、且长期累积的背景知识——分类树、关系类型表、结构模式库。它们的共同点：**要查、要改版本、要写核查日期**，而且改一次就影响所有用到它的作答。

**不是**：
- 不是方法正文（「怎么回溯」「怎么穷举」在技能里）；
- 不是产物模板（林状图／穷举表／结构模式表在技能里）；
- 不是知识库或检索库（没有向量、没有问答，只是 markdown 常量 + 索引）。

拆分理由只有一条：**常量的寿命比方法长**。方法的措辞会改十遍，树的结构一年只动几次；混在一个仓库里，改措辞会污染常量的 diff，改常量会拖累技能的发布节奏。

---

## 2. 三个库

| 库 | 目录 | 消费方 | 内容 | 当前版本 |
|---|---|---|---|---|
| 认知树 | [`knowledge-tree/`](knowledge-tree/index.md) | 🌳 `forest-hierarchical-backtracking`（L1 实例化） | L0 类别判据 + 子层分类 + 类根；节点必备「判据」 | v1 |
| 关系表 | [`relation-table/`](relation-table/index.md) | 🕸️ `web-association-exhaustive`（§2.1） | 两种边分栏、权重公式、九类关系、秩矩阵、校准记录 | v1 |
| 结构表 | [`structure-tree/`](structure-tree/index.md) | 📐 `structure-isomorphism-pointmass-substitution` | 12 基 + 2 修饰 + 3 组合规则 + 复合表 + 先例 | v2.4 |

四个技能里的第四个（`presupposed-answer-hypothesis-backderivation`）**没有常量库**，且与本仓库零接口——这是刻意的，见技能仓库 `README.md`。

**版本是两层的**：仓库版本（`VERSION`）管发布；每个库有自己的 `vN`，写在各自 `index.md` 第一行，产物里回填的是**库版本**，不是仓库版本。

---

## 3. 怎么用

**模型侧**（技能运行时）：按技能正文里的读取顺序取库；取不到就降级并在产物第一行挂牌，**不许现编**。

**人侧**（要改库时）：

```powershell
# 1 看状态（三库版本 + 与消费方的漂移）
.\scripts\state.cmd -Verify

# 2 改库（升节点 vN + 写核查日期 + 在 CHANGELOG 记理由）
#    只改本仓库；技能仓库里的 tree/ 是副本，不许就地改

# 3 同步到消费方（技能仓库 + 本机安装位）
.\scripts\sync.cmd

# 4 再校验、提交、打标签、推送
```

**换台机器不用改脚本**：路径解析顺序 = 参数 `-SkillsRepo` / `-InstallDir` > 环境变量 `DSH_THINKING_SKILLS_REPO` / `DSH_THINKING_INSTALL_DIR` > 同级目录自动发现（与 `dsh-thinking-models` clone 在同一父目录时连参数都不用传）> 报错并打印三种解法。安装位缺省为 `$env:USERPROFILE\.dsh\skills`。

---

## 4. 与技能仓库的关系

单向流，不回流：

```
本仓库（真相源）
   │  scripts/sync.ps1
   ├─→ dsh-thinking-models/<id>/tree/        （随技能分发的副本）
   └─→ <DSH_HOME>/skills/<id>/tree/          （本机安装位）
```

- 副本的哈希由 `scripts/state.cmd -Verify` 比对，漂移即 exit 1。
- 技能仓库里改 `tree/` 等于**改了会被覆盖的文件**——要在本仓库改，再同步。
- 一个库改了 → 只同步它，不整仓重发。

---

## 5. 目录

```
knowledge-tree/index.md          索引：L0/L1 节点表、待建候选、节点必备字段
knowledge-tree/software.md       L0：软件类判据 + 六个正交子层
knowledge-tree/win-service.md    L1：Windows 服务形态
relation-table/index.md          索引：文件表、条目必备字段、v2 候选、边界
relation-table/relations.md      九类关系 + 权重公式 + 秩矩阵 + 两条硬规则
relation-table/calibration.md    实测校准记录 + 记录模板 + 归并规则
structure-tree/index.md          结构模式库 v2.4 全索引（含库内协议）
structure-tree/*.md              12 个基节点
scripts/state.ps1  state.cmd     打印仓库状态 + 三库版本 + 漂移校验
scripts/sync.ps1   sync.cmd      三库单向同步到技能仓库与安装位
manifest.md                      三库版本总表 + 不可破坏的不变量
.gitignore
CHANGELOG.md  VERSION  STATE.md  LICENSE
```

---

## 6. 升版规则

- **库版本** `vN`：任何影响作答的改动都升（新增节点、改判据、改强度上限、改公式）。改完写 `核查 YYYY-MM-DD`。
- **仓库版本**（语义化 `1.x`）：
  - `MINOR`：新增一个库、某库新增/删除条目、索引结构变化；
  - `PATCH`：措辞、样例、脚本、文档。
- 一次提交只动一个库，除非是同步性改动（如三个索引同时加字段）。
- 标签 `vX.Y.Z` 与 `VERSION`、`CHANGELOG.md` 三段一致。

---

## 7. 不可破坏的不变量

1. **常量不许每轮现编**：库里没有的分支 → 登记「库外分支／候选」，不许静默丢弃，也不许临时拍一个。
2. **没有判据的条目是标签**：新增节点／关系类型／结构模式，必须写「怎么观测」。
3. **候选不直接入表**：登记 → 攒实例 → 季度归并 → 升 `v(N+1)`。单例不许升格为常量。
4. **方向不越界**：认知树只给「属于哪一类」，关系表只给「近不近」，结构表只给「像哪种结构」。三者不互相代答。
5. **副本只读**：技能仓库与安装位里的 `tree/` 都是生成副本，改动一律回流到本仓库。

---

## 8. 许可

MIT，见 [LICENSE](LICENSE)。

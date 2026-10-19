# 仓库状态与接手说明（常量库）

> 给**下一个会话**看的。读完本文件 + `CHANGELOG.md` + `manifest.md`，应在不知道任何历史的情况下，能独立完成「改库 → 校验 → 同步 → 发布」。
> 权威顺序：`git` 与磁盘 > 本文件 > 任何记忆／摘要。本文件里的版本会过期，**先跑 `scripts/state.cmd` 拉一次真实状态**。

---

## 1. 这是什么

三个思维模型的**常量层**：认知树（🌳 分类）、关系表（🕸️ 边）、结构表（📐 结构模式）。只放要长期累积、要版本化、要核查日期的背景知识；方法正文在 [`dsh-thinking-models`](https://github.com/plasmaflea/dsh-thinking-models)。

第四个技能（倒推法）是审计器，**没有常量库，且与本仓库零接口**——不要为了「对称」给它加一个。

## 2. 上传信息（发布目标）

| 项 | 值 |
|---|---|
| 仓库 | https://github.com/plasmaflea/dsh-thinking-models-constants |
| 远端 | `https://github.com/plasmaflea/dsh-thinking-models-constants.git`（origin） |
| 可见性 | PUBLIC |
| 默认分支 | `main` |
| 当前版本 | 见 `VERSION`（1.0.1）／标签 `v1.0.1` |
| 消费方 | `dsh-thinking-models` 的三个作答技能 |
| git 身份 | `plasmablue <1935153750@qq.com>` |

## 3. 文件地图

```
knowledge-tree/          认知树（v1）：index.md + software.md + win-service.md
relation-table/          关系表（v1）：index.md + relations.md + calibration.md
structure-tree/          结构表（v2.4）：index.md + 12 个基节点
scripts/state.ps1 .cmd   打印仓库状态、三库版本、与消费方的漂移
scripts/sync.ps1  .cmd   三库单向同步到技能仓库与安装位（-Check 只比对）
manifest.md              三库版本总表 + 共同字段约定 + 共同禁令
README.md STATE.md CHANGELOG.md VERSION LICENSE .gitignore
```

## 4. 消费方与本机位置

| 消费方 | 路径 | 说明 |
|---|---|---|
| 技能仓库 | `D:\DeepSeek-levelup\dsh-thinking-models\<id>\tree\` | 随技能分发的副本，**生成物** |
| 本机安装位 | `C:\Users\Administrator\.dsh\skills\<id>\tree\` | DSH 实际读取的副本，**生成物** |

`<id>` 三选一：`forest-hierarchical-backtracking` / `web-association-exhaustive` / `structure-isomorphism-pointmass-substitution`。

**单向流**：本仓库改 → 同步出去。副本里改 = 白改（下次同步覆盖），且 `state.cmd -Verify` 会先报漂移。

## 5. 改一个库的完整流程

```powershell
# 0 先看真实状态（不要凭记忆）
cd D:\DeepSeek-levelup\dsh-thinking-models-constants
.\scripts\state.cmd

# 1 改库
#    升该库 vN、写「核查 YYYY-MM-DD」、必要时在 index.md 候选区登记
#    新增条目：必须写「判据（怎么观测）」+ 反例

# 2 更新 manifest.md 的版本行 + CHANGELOG.md（写理由，不写"优化"）

# 3 校验（仓库内部一致性 + 与副本的漂移）
.\scripts\state.cmd -Verify

# 4 同步到消费方
.\scripts\sync.cmd

# 5 再校验一次，然后提交、打标签、推送
git add -A
git commit -m "feat(knowledge-tree): ..."
.\scripts\state.cmd -Verify
git tag vX.Y.Z
git push; git push --tags

# 6 技能仓库那边：只需在它自己的 CHANGELOG 追一条「副本已同步至常量库 vX」
```

## 6. 版本号规则

- **库版本 `vN`**：影响作答就升。新增节点／改判据／改强度上限／改公式 = 必须升。改措辞不必升，但「核查」日期照改。
- **仓库版本**：`MINOR` = 新增库、某库新增/删条目、索引结构变化；`PATCH` = 措辞、样例、脚本、文档。
- 标签 `vX.Y.Z` 与 `VERSION`、`CHANGELOG.md` 三段一致。

## 7. 不可破坏的约束

1. **常量不许每轮现编**：库里没有 → 登记候选，不临时拍。
2. **没有判据的条目是标签**：新增必须写「怎么观测」。
3. **候选不直接入表**：攒实例 → 季度归并 → 升 `v(N+1)`。
4. **方向不越界**：树只分类、表只定远近、结构只定同构。三者不互相代答。
5. **副本只读**：技能仓库与安装位的 `tree/` 都是生成物。
6. **不写机器绝对路径**：索引与节点里一律相对路径。
7. 测量／操作脚本走 `.cmd`，`.cmd` 纯 ASCII + CRLF；`.ps1` 存 UTF-8 with BOM（PowerShell 5.1 兼容）。

## 8. 已知待办

- **认知树只有 2 个节点**：`hardware` / `network` / `org-process` / `data-consistency` 仍是候选，没有判据，不能当常量用。
- **结构表 6 个 v1 节点缺 `已解决先例`**：用前必须问「这个结构在哪个领域被真正解决过」，问不出降级 `[类比]`。
- **关系表没有跨域阈值**：软件域与商业域共用一套阈值，尚未验证。
- **没有机器校验条目字段**：`state.cmd` 只验文件与哈希，不验「有没有写判据」。下一步可加字段检查（grep 必备字段名）。

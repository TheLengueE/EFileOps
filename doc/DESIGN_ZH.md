# EFileOps 设计文档

## 一、架构概述

EFileOps 是一个基于 Qt/QML 的批量文件重命名工具，采用经典的 MVC 架构模式。这里的 MVC 不是指类的继承关系，而是强调**责任边界**的清晰划分。

```
Model ←→ View ←→ Controller
```

**核心组件：**
- **Model**: `FileListModel`, `FileService`, `RuleEngine`, `FileItem`, `RuleBase`
- **View**: QML UI 层
- **Controller**: `MainController`

**调用流程：**
```
[ QML UI ] 
    ↓ 用户交互
[ MainController ] 
    ↓ 业务协调
[ RuleEngine ]      ← 规则管理与执行
[ FileService ]     ← 文件数据 + 历史管理 + 重命名执行
    ↓ 操作对象
[ FileItem / RuleBase ] ← 领域模型
```

## 二、核心模块

### 2.1 MainController（控制器）
**职责**: 作为 UI 和业务层之间的桥梁，协调各个服务模块的工作。

**关键功能**:
- 暴露 `Q_INVOKABLE` 方法供 QML 调用（如 `addFiles`, `executeRename`）
- 管理 `FileService` 和 `RuleEngine` 的生命周期
- 处理会话持久化（自动保存/恢复工作状态）
- 规则配置的导入导出（JSON 格式）


### 2.2 FileService（文件服务）
**职责**: 管理文件列表、执行重命名操作、维护历史记录。

**核心能力**:
1. **文件管理**: 添加、删除、排序文件
2. **预览生成**: 调用 RuleEngine 生成重命名预览
3. **原子执行**: 批量重命名采用 `all-or-nothing` 策略，任何一个文件失败则全部回滚
4. **历史管理**: 记录重命名历史，支持撤销操作

### 2.3 RuleEngine（规则引擎）
**职责**: 管理规则链，执行规则序列，生成重命名结果。

**规则类型**:
- **Replace**: 查找替换
- **Remove**: 移除包含关键词的文件
- **AddPrefix/AddSuffix**: 添加前缀/后缀
- **CaseTransform**: 大小写转换
- **Numbering**: 序号编号

**执行模型**: 规则按顺序依次应用，每条规则的输出作为下一条规则的输入（管道模式）。

**配置持久化**: 规则配置支持保存为 JSON 文件，可导入导出，便于复用常用规则组合。

### 2.4 FileListModel（数据模型）
**职责**: 作为 QML ListView 的数据源，响应式同步文件列表状态。

**特点**:
- 实现 `QAbstractListModel` 接口
- 监听 FileService 的变化（添加、删除、重命名），实时更新 UI
- 提供序号、原始名、预览名、状态等字段供 UI 绑定

---

## 三、关键流程

### 3.1 重命名执行流程
```
1. 用户点击"执行" → MainController::executeRename()
2. FileService 进行预检查（文件是否存在、权限验证、目标路径冲突检查）
3. 依次执行重命名操作（使用 QDir::rename）
4. 记录每次成功的操作，用于可能的回滚
5. 如果任何文件失败 → 立即回滚所有已成功的操作
6. 更新执行状态，按失败/回滚/成功排序，发送完成信号
```

### 3.2 规则应用流程
```
1. 用户在右侧面板添加规则 → QML 调用 MainController::addRule()
2. MainController 使用 RuleEngine::createRule() 工厂方法创建规则实例
3. 规则添加到 RuleEngine，触发 ruleCountChanged 信号
4. MainController::addRule() 自动调用 updatePreview()
5. RuleEngine 对每个文件依次应用规则链（管道模式），生成新名称
6. FileService::updatePreview() 更新文件的新名称
7. FileListModel 监听变化，UI 实时显示预览结果
```

### 3.3 会话管理
**自动保存**: 应用退出时自动保存当前文件列表和规则配置到本地 JSON 文件。

**自动恢复**: 应用启动时检查设置，如果启用自动恢复，则加载上次的工作状态。

**配置路径**: 使用 `QStandardPaths::AppLocalDataLocation`。
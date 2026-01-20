# EFileOps Design Document

## 1. Architecture Overview

EFileOps is a Qt/QML-based batch file renaming tool that adopts the classic MVC architecture pattern. Here, MVC doesn't refer to class inheritance relationships, but emphasizes the clear separation of **responsibility boundaries**.

```
Model ←→ View ←→ Controller
```

**Core Components:**
- **Model**: `FileListModel`, `FileService`, `RuleEngine`, `FileItem`, `RuleBase`
- **View**: QML UI Layer
- **Controller**: `MainController`

**Call Flow:**
```
[ QML UI ] 
    ↓ User Interaction
[ MainController ] 
    ↓ Business Coordination
[ RuleEngine ]      ← Rule Management & Execution
[ FileService ]     ← File Data + History Management + Rename Execution
    ↓ Operation Objects
[ FileItem / RuleBase ] ← Domain Models
```

Global settings (`AppSettings`) and internationalization (`TranslationManager`) and other modules exist as independent auxiliary modules.

---

## 2. Core Modules

### 2.1 MainController (Controller)
**Responsibility**: Acts as a bridge between UI and business layer, coordinating the work of various service modules.

**Key Features**:
- Exposes `Q_INVOKABLE` methods for QML calls (e.g., `addFiles`, `executeRename`)
- Manages the lifecycle of `FileService` and `RuleEngine`
- Handles session persistence (auto-save/restore working state)
- Import/export rule configurations (JSON format)


### 2.2 FileService (File Service)
**Responsibility**: Manages file list, executes rename operations, maintains history records.

**Core Capabilities**:
1. **File Management**: Add, delete, sort files
2. **Preview Generation**: Calls RuleEngine to generate rename previews
3. **Atomic Execution**: Batch renaming adopts `all-or-nothing` strategy, rollback all if any file fails
4. **History Management**: Records rename history, supports undo operations

### 2.3 RuleEngine (Rule Engine)
**Responsibility**: Manages rule chain, executes rule sequences, generates rename results.

**Rule Types**:
- **Replace**: Find and replace (supports case-sensitive, regular expressions)
- **Remove**: Remove files containing keywords (removes from list, not deleting characters)
- **AddPrefix/AddSuffix**: Add prefix/suffix
- **CaseTransform**: Case transformation (uppercase, lowercase, title case, camel case, snake case, kebab case, and 7 formats total)
- **Numbering**: Number sequencing (supports prefix/suffix position, start value, zero-padding digits)

**Execution Model**: Rules are applied sequentially, with each rule's output serving as input for the next rule (pipeline pattern).

**Configuration Persistence**: Rule configurations can be saved as JSON files, supporting import/export for reusing common rule combinations.

### 2.4 FileListModel (Data Model)
**Responsibility**: Serves as the data source for QML ListView, reactively synchronizing file list state.

**Features**:
- Implements `QAbstractListModel` interface
- Automatically listens to FileService changes (add, delete, rename), updating UI in real-time
- Provides fields like index, original name, preview name, status for UI binding

---

## 3. Key Workflows

### 3.1 Rename Execution Workflow
```
1. User clicks "Execute" → MainController::executeRename()
2. FileService performs pre-checks (file existence, permission validation, target path conflict check)
3. Execute rename operations sequentially (using QDir::rename)
4. Record each successful operation for potential rollback
5. If any file fails → immediately rollback all successful operations
6. Update execution status, sort by failed/rollback/success, emit completion signal
```

### 3.2 Rule Application Workflow
```
1. User adds rule in right panel → QML calls MainController::addRule()
2. MainController uses RuleEngine::createRule() factory method to create rule instance
3. Rule is added to RuleEngine, triggering ruleCountChanged signal
4. MainController::addRule() automatically calls updatePreview()
5. RuleEngine applies rule chain to each file sequentially (pipeline pattern), generating new names
6. FileService::updatePreview() updates file's new name
7. FileListModel listens to changes, UI displays preview results in real-time
```

### 3.3 Session Management
**Auto-save**: Automatically saves current file list and rule configuration to local JSON file when application exits.

**Auto-restore**: Checks settings on application startup, and loads last working state if auto-restore is enabled.

**Configuration Path**: Uses `QStandardPaths::AppLocalDataLocation`.

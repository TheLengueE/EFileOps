# EFileOps

<div align="center">

[中文](README_CN.md) | [English](README.md)

</div>

---

安全、简洁为核心的 Windows 批量文件重命名工具。  
通过组合规则完成复杂改名，并通过预览与回滚机制保障操作安全。

如果你需要下载安装包：
- [Release](https://github.com/TheLengueE/EFileOps/releases/latest)

项目的大致设计请参考：
- [设计文档](doc/DESIGN_ZH.md)

---

## 核心功能

- 批量重命名文件和文件夹
- 基于规则的重命名流程（顺序执行）
- 原文件名与新文件名预览对照
- 如存在任何错误，自动回滚所有修改
- 显示清晰的成功 / 失败统计
- 支持中文、英语、德语
- 无需网络

![Main UI](assets/screenshot-main.png)

---

## 编译构建

已在以下环境中测试通过：

- Visual Studio 2022
- Qt 6.5.3+
- CMake 3.20+
编译方式：

在命令行中运行：

```bash
cmake -B build -G "Visual Studio 17 2022" -A x64

cmake --build build --config Release

cmake --build build --config Debug
```

## 许可协议
本项目采用 **CC BY-NC 4.0（署名-非商业）协议** 开源。
你可以：
- 免费使用
- 修改和学习源码
- 非商业分享
但不允许：
- 任何形式的商业用途
- 转售、收费分发或用于盈利产品
作者本人保留商业化权利。
具体条款请以 LICENSE 文件中的英文原文为准。

---

## 支持项目

如果你觉得这个工具对你有帮助，欢迎通过捐赠支持项目的持续开发。
- Gumroad: https://baileydjoseph.gumroad.com/l/zufxto

---
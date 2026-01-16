cmake_minimum_required(VERSION 3.20)
project(EFileOps LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Enable Qt automatic tools
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick QuickControls2 Concurrent LinguistTools)

# ===========================================================
# Source file grouping
# ===========================================================

# Core framework headers
set(CORE_HEADERS
    src/core/BaseRequest.h
    src/core/BaseResponse.h
    src/core/ErrorCodes.h
    src/core/AppSettings.h
)

# Core framework sources
set(CORE_SOURCES
    src/core/AppSettings.cpp
)

# Model headers
set(MODEL_HEADERS
    src/model/FileItem.h
    src/model/FileListModel.h
)

# Model sources
set(MODEL_SOURCES
    src/model/FileItem.cpp
    src/model/FileListModel.cpp
)

# Service layer headers
set(SERVICE_HEADERS
    src/service/FileService.h
    src/service/RuleEngine.h
)

# Service layer sources
set(SERVICE_SOURCES
    src/service/FileService.cpp
    src/service/RuleEngine.cpp
)

# Rule base headers
set(RULE_BASE_HEADERS
    src/rule/RuleBase.h
)

# Rule base sources
set(RULE_BASE_SOURCES
    src/rule/RuleBase.cpp
)

# Concrete rule headers
set(RULE_IMPL_HEADERS
    src/rule/rules/AddPrefixRule.h
    src/rule/rules/AddSuffixRule.h
    src/rule/rules/ReplaceRule.h
    src/rule/rules/NumberingRule.h
    src/rule/rules/CaseTransformRule.h
    src/rule/rules/RemoveRule.h
)

# Concrete rule sources
set(RULE_IMPL_SOURCES
    src/rule/rules/AddPrefixRule.cpp
    src/rule/rules/AddSuffixRule.cpp
    src/rule/rules/ReplaceRule.cpp
    src/rule/rules/NumberingRule.cpp
    src/rule/rules/CaseTransformRule.cpp
    src/rule/rules/RemoveRule.cpp
)

# Controller headers
set(CONTROLLER_HEADERS
    src/controller/MainController.h
)

# Controller sources
set(CONTROLLER_SOURCES
    src/controller/MainController.cpp
)

# Utility headers
set(UTIL_HEADERS
    src/util/FileSystemHelper.h
)

# Utility sources
set(UTIL_SOURCES
    src/util/FileSystemHelper.cpp
)

# Translation module headers
set(TRANSLATION_HEADERS
    src/translation/TranslationManager.h
)

# Translation module sources
set(TRANSLATION_SOURCES
    src/translation/TranslationManager.cpp
)

# Main program file
set(MAIN_SOURCES
    Main.cpp
)

# Windows resource file for icon and version info
if(WIN32)
    set(WINDOWS_RESOURCES
        EFileOps.rc
    )
endif()

# Combine all headers
set(ALL_HEADERS
    ${CORE_HEADERS}
    ${MODEL_HEADERS}
    ${SERVICE_HEADERS}
    ${RULE_BASE_HEADERS}
    ${RULE_IMPL_HEADERS}
    ${CONTROLLER_HEADERS}
    ${UTIL_HEADERS}
    ${TRANSLATION_HEADERS}
)

# Combine all sources
set(ALL_SOURCES
    ${MAIN_SOURCES}
    ${CORE_SOURCES}
    ${MODEL_SOURCES}
    ${SERVICE_SOURCES}
    ${RULE_BASE_SOURCES}
    ${RULE_IMPL_SOURCES}
    ${CONTROLLER_SOURCES}
    ${UTIL_SOURCES}
    ${TRANSLATION_SOURCES}
    ${WINDOWS_RESOURCES}
)

# ===========================================================
# Translation files
# ===========================================================
set(TS_FILES
    translations/fileops_zh_CN.ts
    translations/fileops_en_US.ts
    translations/fileops_de_DE.ts
)

# Generate translation files
qt_add_translation(QM_FILES ${TS_FILES})

# ===========================================================
# Main executable
# ===========================================================
if(WIN32)
    # Windows executable with icon
    qt_add_executable(${PROJECT_NAME} WIN32
        ${ALL_HEADERS}
        ${ALL_SOURCES}
        ${QM_FILES}
    )
    # Set Windows application icon
    set_target_properties(${PROJECT_NAME} PROPERTIES
        WIN32_EXECUTABLE TRUE
    )
else()
    qt_add_executable(${PROJECT_NAME}
        ${ALL_HEADERS}
        ${ALL_SOURCES}
        ${QM_FILES}
    )
endif()

# Print source file information (for debugging)
message(STATUS "📄 Total header files: ${CMAKE_CURRENT_LIST_DIR}")
list(LENGTH ALL_HEADERS HEADER_COUNT)
list(LENGTH ALL_SOURCES SOURCE_COUNT)
message(STATUS "   - Headers: ${HEADER_COUNT} files")
message(STATUS "   - Sources: ${SOURCE_COUNT} files")

# ===========================================================
# Main application QML module
# ===========================================================
qt_add_qml_module(${PROJECT_NAME}
    URI EFileOps
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/I18n.qml
        qml/RuleConfigDialog.qml
        qml/SettingsDialog.qml
        qml/AboutDialog.qml
        qml/LeftPanel/LeftPanel.qml
        qml/LeftPanel/LeftStatusPanel.qml
        qml/LeftPanel/LeftBottomButtons.qml
        qml/CenterPanel/CenterPanel.qml
        qml/CenterPanel/FileDropArea.qml
        qml/CenterPanel/CenterToolbar.qml
        qml/CenterPanel/EmptyState.qml
        qml/CenterPanel/FileListHeader.qml
        qml/CenterPanel/FileListItem.qml
        qml/CenterPanel/FileListPagination.qml
        qml/RightPanel/RightPanel.qml
        qml/RightPanel/RightAddRuleButton.qml
        qml/RightPanel/RightRuleList.qml
        qml/RightPanel/RightConfigButtons.qml
        qml/rules/RuleTypeSelector.qml
        qml/rules/RuleTypeCard.qml
        qml/rules/ReplaceRuleConfig.qml
        qml/rules/RemoveRuleConfig.qml
        qml/rules/FormatRuleConfig.qml
        qml/rules/AddRuleConfig.qml
        qml/rules/NumberingRuleConfig.qml
    RESOURCES
        qml/qmldir
        qml/LeftPanel/qmldir
        qml/CenterPanel/qmldir
        qml/RightPanel/qmldir
        qml/rules/qmldir
        icons/file-plus.svg
        icons/folder-plus.svg
        icons/trash.svg
        icons/save.svg
        icons/settings.svg
        icons/info.svg
        icons/undo.svg
        icons/folder.svg
        icons/folder-filled.svg
        icons/plus.svg
        icons/download.svg
        icons/clipboard.svg
        icons/clipboard-filled.svg
        icons/refresh.svg
        icons/text.svg
        icons/hash.svg
        icons/clock.svg
        icons/close-x.svg
        icons/arrow-left.svg
        icons/arrow-right.svg
        icons/alert.svg
        icons/EFileOps.png
)

# ===========================================================
# Link libraries
# ===========================================================
target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Concurrent
)

# ===========================================================
# Deployment configuration
# ===========================================================
# Copy translation files to output directory
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:${PROJECT_NAME}>/translations
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${QM_FILES} $<TARGET_FILE_DIR:${PROJECT_NAME}>/translations
    COMMENT "Copying translation files to output directory"
)

# Copy EQtUI directory to output directory for runtime loading
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:${PROJECT_NAME}>/qml
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/EQtUI $<TARGET_FILE_DIR:${PROJECT_NAME}>/qml/EUI
    COMMENT "Copying EQtUI components to output directory"
)

install(FILES ${QM_FILES} DESTINATION translations)

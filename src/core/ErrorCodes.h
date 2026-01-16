#pragma once

/**
 * @brief Extended error code definitions
 *
 * Specific error codes defined for the EFileOps application
 * Extended based on the common error codes in BaseResponse
 */
namespace FileErrorCode
{
// File operation errors
constexpr const char *kFileNotExist      = "FILE_NOT_EXIST";      // File does not exist
constexpr const char *kFileNotAccessible = "FILE_NOT_ACCESSIBLE"; // File is not accessible
constexpr const char *kFileDuplicate     = "FILE_DUPLICATE";      // File already exists in list
constexpr const char *kFileLimitExceeded = "FILE_LIMIT_EXCEEDED"; // File count limit exceeded
constexpr const char *kFileRenameFailed  = "FILE_RENAME_FAILED";  // Rename failed
constexpr const char *kFileInvalidPath   = "FILE_INVALID_PATH";   // Invalid path
constexpr const char *kFolderEmpty       = "FOLDER_EMPTY";        // Folder is empty
constexpr const char *kFolderNotExist    = "FOLDER_NOT_EXIST";    // Folder does not exist
constexpr const char *kFileOpenFailed    = "FILE_OPEN_FAILED";    // Failed to open file
constexpr const char *kFileFormatError   = "FILE_FORMAT_ERROR";   // Invalid file format
} // namespace FileErrorCode

namespace RuleErrorCode
{
// Rule operation errors
constexpr const char *kRuleInvalidType      = "RULE_INVALID_TYPE";       // Invalid rule type
constexpr const char *kRuleInvalidConfig    = "RULE_INVALID_CONFIG";     // Invalid rule configuration
constexpr const char *kRuleNotFound         = "RULE_NOT_FOUND";          // Rule not found
constexpr const char *kRuleIndexOutOfRange  = "RULE_INDEX_OUT_OF_RANGE"; // Rule index out of range
constexpr const char *kRuleValidationFailed = "RULE_VALIDATION_FAILED";  // Rule validation failed
constexpr const char *kRuleEmptyResult      = "RULE_EMPTY_RESULT";       // Rule execution result is empty
} // namespace RuleErrorCode

namespace ProjectErrorCode
{
// Project operation errors
constexpr const char *kProjectLoadFailed    = "PROJECT_LOAD_FAILED";    // Project loading failed
constexpr const char *kProjectSaveFailed    = "PROJECT_SAVE_FAILED";    // Project saving failed
constexpr const char *kProjectInvalidFormat = "PROJECT_INVALID_FORMAT"; // Invalid project format
constexpr const char *kExportFailed         = "EXPORT_FAILED";          // Export failed
} // namespace ProjectErrorCode

namespace OperationErrorCode
{
// Operation execution errors
constexpr const char *kNoFiles            = "NO_FILES";            // No files
constexpr const char *kNoRules            = "NO_RULES";            // No rules
constexpr const char *kPreviewFailed      = "PREVIEW_FAILED";      // Preview failed
constexpr const char *kExecuteFailed      = "EXECUTE_FAILED";      // Execute failed
constexpr const char *kNoUndoHistory      = "NO_UNDO_HISTORY";     // Cannot undo
constexpr const char *kNoRedoHistory      = "NO_REDO_HISTORY";     // Cannot redo
constexpr const char *kOperationCancelled = "OPERATION_CANCELLED"; // Operation cancelled
} // namespace OperationErrorCode

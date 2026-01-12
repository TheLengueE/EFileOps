#pragma once

#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QJsonObject>

/**
 * @brief Base class for generic responses
 * Design principles (compliant with EUI interaction rules):
 * - Clear success/failure status
 * - User-friendly error messages (including reason + expected behavior)
 * - Structured return data
 */
class BaseResponse
{
    Q_GADGET
    Q_PROPERTY(bool success MEMBER success)
    Q_PROPERTY(QString message MEMBER message)
    Q_PROPERTY(QString errorCode MEMBER errorCode)
    Q_PROPERTY(QVariantMap data MEMBER data)

  public:
    bool        success;   // Whether the operation succeeded
    QString     message;   // User-friendly message (success prompt or error description)
    QString     errorCode; // Error code (for program processing)
    QVariantMap data;      // Return data dictionary

    BaseResponse() : success(false) {}

    /**
     * @brief Quick create success response
     * @param msg Success message (optional)
     */
    static BaseResponse Success(QString msg = QString())
    {
        BaseResponse resp;
        resp.success = true;
        resp.message = msg.isEmpty() ? "Operation completed successfully" : msg;
        return resp;
    }

    /**
     * @brief Quick create success response (with data)
     */
    static BaseResponse SuccessWithData(QVariantMap responseData, QString msg = QString())
    {
        BaseResponse resp = Success(msg);
        resp.data         = responseData;
        return resp;
    }

    /**
     * @brief Quick create failure response
     * @param errorMsg Error message (should include reason + expected behavior)
     * @param code Error code (optional)
     */
    static BaseResponse Error(QString errorMsg, QString code = QString())
    {
        BaseResponse resp;
        resp.success   = false;
        resp.message   = errorMsg;
        resp.errorCode = code.isEmpty() ? "UNKNOWN_ERROR" : code;
        return resp;
    }

    /**
     * @brief Convenience method: Set data
     */
    BaseResponse &setData(QString key, QVariant value)
    {
        data[key] = value;
        return *this;
    }

    /**
     * @brief Convenience method: Get data
     */
    QVariant getData(QString key, QVariant defaultValue = QVariant()) const { return data.value(key, defaultValue); }

    /**
     * @brief Convert to JSON object (for logging/debugging)
     */
    QJsonObject toJson() const
    {
        QJsonObject json;
        json["success"]   = success;
        json["message"]   = message;
        json["errorCode"] = errorCode;

        // Convert data
        QJsonObject dataObj;
        for (auto it = data.constBegin(); it != data.constEnd(); ++it)
        {
            dataObj[it.key()] = QJsonValue::fromVariant(it.value());
        }
        json["data"] = dataObj;

        return json;
    }
};

Q_DECLARE_METATYPE(BaseResponse)

/**
 * @brief Common error code definitions
 *
 * Unified error code standard for easy frontend identification and handling
 */
namespace ErrorCode
{
constexpr const char *INVALID_PARAM     = "INVALID_PARAM";     // Invalid parameter
constexpr const char *NOT_FOUND         = "NOT_FOUND";         // Resource not found
constexpr const char *PERMISSION_DENIED = "PERMISSION_DENIED"; // Permission denied
constexpr const char *OPERATION_FAILED  = "OPERATION_FAILED";  // Operation failed
constexpr const char *TIMEOUT           = "TIMEOUT";           // Timeout
constexpr const char *ALREADY_EXISTS    = "ALREADY_EXISTS";    // Already exists
constexpr const char *NOT_IMPLEMENTED   = "NOT_IMPLEMENTED";   // Not implemented
constexpr const char *UNKNOWN_MODULE    = "UNKNOWN_MODULE";    // Unknown module
constexpr const char *UNKNOWN_ACTION    = "UNKNOWN_ACTION";    // Unknown action
} // namespace ErrorCode

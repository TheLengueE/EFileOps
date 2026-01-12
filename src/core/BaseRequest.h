#pragma once

#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QJsonObject>
#include <QDateTime>
#include <QRandomGenerator>

/**
 * @brief Base class for generic requests
 * Design principles:
 * - Type safety: Use enums to define operation types
 * - Traceable: Automatically generate request IDs
 * - Extensible: Pass arbitrary parameters through params
 * - Unified format: All modules use the same request pattern
 */
class BaseRequest
{
    Q_GADGET
    Q_PROPERTY(QString module MEMBER module)
    Q_PROPERTY(QString action MEMBER action)
    Q_PROPERTY(QVariantMap params MEMBER params)

  public:
    QString     module; // Module name, e.g. "translation", "file", "settings"
    QString     action; // Action name, e.g. "switch", "load", "save"
    QVariantMap params; // Parameter dictionary (flexible for passing various parameters)

    BaseRequest() {}

    BaseRequest(QString mod, QString act) : module(mod), action(act) {}

    /**
     * @brief Convenience method: Set parameter
     */
    BaseRequest &setParam(QString key, QVariant value)
    {
        params[key] = value;
        return *this;
    }

    /**
     * @brief Convenience method: Get parameter
     */
    QVariant getParam(QString key, QVariant defaultValue = QVariant()) const { return params.value(key, defaultValue); }

    /**
     * @brief Convert to JSON object (for logging/debugging)
     */
    QJsonObject toJson() const
    {
        QJsonObject json;
        json["module"] = module;
        json["action"] = action;

        // Convert params
        QJsonObject paramsObj;
        for (auto it = params.constBegin(); it != params.constEnd(); ++it)
        {
            paramsObj[it.key()] = QJsonValue::fromVariant(it.value());
        }
        json["params"] = paramsObj;

        return json;
    }
};

Q_DECLARE_METATYPE(BaseRequest)

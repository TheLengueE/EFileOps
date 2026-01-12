#pragma once

#include <QObject>
#include <QTranslator>
#include <QString>
#include <QStringList>
#include "../core/BaseRequest.h"
#include "../core/BaseResponse.h"

/**
 * @brief Translation manager - Business logic layer
 *
 * Compliant with EUI Design System architecture specifications:
 * - Uses common BaseRequest/BaseResponse framework
 * - Separates view layer and business logic
 * - Clear signal notification mechanism
 * - Does not directly expose internal implementation details
 *
 * Module name: translation
 * Supported operations:
 * - switch: Switch language
 * - getState: Get current state
 * - getAvailable: Get available language list
 */
class TranslationManager final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentLocale READ currentLocale NOTIFY currentLocaleChanged)
    Q_PROPERTY(QStringList availableLocales READ availableLocales CONSTANT)

  public:
    explicit TranslationManager(QObject *parent = nullptr);
    ~TranslationManager() override;

    // Property accessors
    QString     currentLocale() const { return current_locale_; }
    QStringList availableLocales() const { return available_locales_; }

    /**
     * @brief Unified request handling entry
     * @param module Module name
     * @param action Operation name
     * @param params Parameter object (JS object from QML automatically converts to QVariantMap)
     * @return BaseResponse Common response object
     *
     * Supported actions:
     * - "switch": Switch language, requires params.locale
     * - "getState": Get current state
     * - "getAvailable": Get available language list
     */
    Q_INVOKABLE BaseResponse handleRequest(QString module, QString action, QVariantMap params);

  signals:
    /**
     * @brief Language switch success signal
     * @param response Response data, contains new language information
     */
    void languageChanged(BaseResponse response);

    /**
     * @brief Current language code change signal (for property binding)
     */
    void currentLocaleChanged();

  private:
    /**
     * @brief Handle switch language request
     */
    BaseResponse HandleSwitchLanguage(QString locale);

    /**
     * @brief Handle get state request
     */
    BaseResponse HandleGetState();

    /**
     * @brief Initialize available language list
     */
    void InitializeAvailableLocales();

    /**
     * @brief Validate if language code is valid
     */
    bool IsValidLocale(QString locale) const;

    QTranslator *translator_;        // Qt translator instance
    QString      translations_path_; // Translation file path
    QString      current_locale_;    // Current language code
    QStringList  available_locales_; // Available language list
};

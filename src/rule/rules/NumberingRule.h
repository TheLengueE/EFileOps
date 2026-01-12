#pragma once

#include "../RuleBase.h"

/**
 * @brief Numbering rule
 *
 * Add numbering before or after file name
 */
class NumberingRule : public RuleBase
{
    Q_OBJECT
    Q_PROPERTY(Position position READ position WRITE setPosition NOTIFY positionChanged)
    Q_PROPERTY(int startNumber READ startNumber WRITE setStartNumber NOTIFY startNumberChanged)
    Q_PROPERTY(int paddingLength READ paddingLength WRITE setPaddingLength NOTIFY paddingLengthChanged)
    Q_PROPERTY(QString separator READ separator WRITE setSeparator NOTIFY separatorChanged)

  public:
    enum Position
    {
        Prefix, // Prefix: 001_name.txt
        Suffix  // Suffix: name_001.txt
    };
    Q_ENUM(Position)

    explicit NumberingRule(QObject *parent = nullptr);

    QString apply(const QString &input, const FileItem *fileItem, int fileIndex = -1) const override;
    QString ruleType() const override { return "Numbering"; }
    QString description() const override;
    bool    validate(QString *errorMessage = nullptr) const override;

    QJsonObject toJson() const override;
    void        fromJson(const QJsonObject &json) override;
    void        applyConfig(const QVariantMap &config) override;
    RuleBase   *clone() const override;

    // Property accessors
    Position position() const { return position_; }
    void     setPosition(Position pos);

    int  startNumber() const { return start_number_; }
    void setStartNumber(int num);

    int  paddingLength() const { return padding_length_; }
    void setPaddingLength(int length);

    QString separator() const { return separator_; }
    void    setSeparator(const QString &sep);

  signals:
    void positionChanged();
    void startNumberChanged();
    void paddingLengthChanged();
    void separatorChanged();

  private:
    Position position_;
    int      start_number_;   // Start number, default 1
    int      padding_length_; // Zero padding digits, 0 means no padding
    QString  separator_;      // Separator, default "_"
};

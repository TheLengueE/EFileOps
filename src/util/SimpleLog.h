#pragma once

#include <QString>
#include <QStringList>
#include <QFile>
#include <QTextStream>
#include <QCoreApplication>
#include <QDateTime>

class SimpleLog
{
public:
    template<typename... Args>
    static void write(const QString& format, Args&&... args)
    {
#ifdef QT_DEBUG
        QStringList list{ toQString(std::forward<Args>(args))... };
        QString msg = formatString(format, list);
        writeLine(msg);
#else
        Q_UNUSED(format);
#endif
    }

private:
    template<typename T>
    static QString toQString(T&& v)
    {
        if constexpr (std::is_same_v<std::decay_t<T>, QString>)
            return v;
        else
            return QString::fromUtf8(QVariant::fromValue(v).toString().toUtf8());
    }

    static QString formatString(const QString& format, const QStringList& args)
    {
        QString result = format;
        for (const auto& arg : args) {
            int idx = result.indexOf("{}");
            if (idx < 0) break;
            result.replace(idx, 2, arg);
        }
        return result;
    }

    static void writeLine(const QString& line)
    {
        QFile file(QCoreApplication::applicationDirPath() + "/debug_log.txt");
        if (!file.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text))
            return;

        QTextStream out(&file);
        out.setEncoding(QStringConverter::Utf8);

        out << "[" 
            << QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss.zzz")
            << "] "
            << line << '\n';
    }

    SimpleLog() = delete;
};

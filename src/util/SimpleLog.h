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
    template <typename... Args> static void write(const QString &format, Args &&...args)
    {
#ifdef QT_DEBUG
        QStringList list{toQString(std::forward<Args>(args))...};
        QString     msg = formatString(format, list);
        writeLine(msg);
#else
        Q_UNUSED(format);
#endif
    }

  private:
    template <typename T> static QString toQString(T &&v)
    {
        using U = std::decay_t<T>;

        if constexpr (std::is_same_v<U, QString>)
        {
            return v;
        }
        else if constexpr (std::is_same_v<U, const char *> || std::is_same_v<U, char *>)
        {
            return QString::fromUtf8(v);
        }
        else if constexpr (std::is_same_v<U, std::string>)
        {
            return QString::fromStdString(v);
        }
        else if constexpr (std::is_arithmetic_v<U>)
        {
            return QString::number(v);
        }
        else
        {
            QString s;
            QDebug  dbg(&s);
            dbg << v;
            return s;
        }
    }

    static QString formatString(const QString &format, const QStringList &args)
    {
        QString result = format;
        for (const auto &arg : args)
        {
            int idx = result.indexOf("{}");
            if (idx < 0)
                break;
            result.replace(idx, 2, arg);
        }
        return result;
    }

    static void writeLine(const QString &line)
    {
        QFile file(QCoreApplication::applicationDirPath() + "/debug_log.txt");
        if (!file.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text))
            return;

        QTextStream out(&file);
        out.setEncoding(QStringConverter::Utf8);

        out << "[" << QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss.zzz") << "] " << line << '\n';
    }

    SimpleLog() = delete;
};

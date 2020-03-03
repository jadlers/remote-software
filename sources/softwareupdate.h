/******************************************************************************
 *
 * Copyright (C) 2020 Markus Zehnder <business@markuszehnder.ch>
 * Copyright (C) 2018-2020 Marton Borzak <hello@martonborzak.com>
 *
 * This file is part of the YIO-Remote software project.
 *
 * YIO-Remote software is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * YIO-Remote software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with YIO-Remote software. If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *****************************************************************************/

#pragma once

#include <QDir>
#include <QGuiApplication>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>
#include <QQmlEngine>
#include <QTimer>

#include "filedownload.h"
#include "hardware/batteryfuelgauge.h"

class SoftwareUpdate : public QObject {
    Q_OBJECT

 public:
    explicit SoftwareUpdate(const QVariantMap& cfg, QString appPath, BatteryFuelGauge* batteryFuelGauge,
                            QObject* parent = nullptr);
    ~SoftwareUpdate();

    Q_PROPERTY(qint64 bytesReceived READ bytesReceived NOTIFY bytesReceivedChanged)
    Q_PROPERTY(qint64 bytesTotal READ bytesTotal NOTIFY bytesTotalChanged)
    Q_PROPERTY(QString downloadSpeed READ downloadSpeed NOTIFY downloadSpeedChanged)
    Q_PROPERTY(bool autoUpdate READ autoUpdate WRITE setAutoUpdate NOTIFY autoUpdateChanged)
    Q_PROPERTY(QString currentVersion READ currentVersion NOTIFY currentVersionChanged)
    Q_PROPERTY(QString newVersion READ newVersion NOTIFY newVersionChanged)
    Q_PROPERTY(bool updateAvailable READ updateAvailable NOTIFY updateAvailableChanged)
    Q_PROPERTY(bool installAvailable READ installAvailable NOTIFY installAvailableChanged)

    Q_INVOKABLE void checkForUpdate();
    Q_INVOKABLE bool startDownload();
    Q_INVOKABLE bool performUpdate();
    Q_INVOKABLE bool startDockUpdate();

    void start();

    qint64  bytesReceived() { return m_bytesReceived; }
    qint64  bytesTotal() { return m_bytesTotal; }
    QString downloadSpeed() { return m_downloadSpeed; }

    bool autoUpdate() { return m_autoUpdate; }
    void setAutoUpdate(bool update);

    QString currentVersion() { return m_currentVersion; }
    QString newVersion() { return m_newVersion; }
    bool    updateAvailable() { return m_updateAvailable; }
    bool    installAvailable();

    static SoftwareUpdate* getInstance() { return s_instance; }
    static QObject*        getQMLInstance(QQmlEngine* engine, QJSEngine* scriptEngine);

 signals:
    void bytesReceivedChanged();
    void bytesTotalChanged();
    void downloadSpeedChanged();
    void autoUpdateChanged();
    void currentVersionChanged();
    void newVersionChanged();
    void updateAvailableChanged();
    void installAvailableChanged();
    void downloadComplete();

 private slots:  // NOLINT open issue: https://github.com/cpplint/cpplint/pull/99
    void checkForUpdateFinished(QNetworkReply* reply);
    void downloadProgress(qint64 bytesReceived, qint64 bytesTotal);
    void downloadFinished();
    void onDownloadFailed();
    void onCheckForUpdateTimerTimeout();
    void onDownloadSpeed(const QString& speed);

 private:
    QString getDeviceType();

 private:
    static SoftwareUpdate* s_instance;

    BatteryFuelGauge* m_batteryFuelGauge;

    QString m_currentVersion = QGuiApplication::applicationVersion();
    QString m_newVersion = "";
    bool    m_updateAvailable = false;

    int  m_checkIntervallSec;
    bool m_autoUpdate;

    QTimer* m_checkForUpdateTimer;

    qint64  m_bytesReceived = 0;
    qint64  m_bytesTotal = 0;
    QString m_downloadSpeed;

    QUrl                   m_updateUrl;
    QUrl                   m_downloadUrl;
    QNetworkAccessManager* m_manager;
    QDir                   m_downloadDir;
    QString                m_appPath;
    QString                m_fileName;
    FileDownload           m_fileDownload;
};

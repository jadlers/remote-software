/******************************************************************************
 *
 * Copyright (C) 2018-2019 Marton Borzak <hello@martonborzak.com>
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

#ifndef INTEGRATIONS_H
#define INTEGRATIONS_H

#include <QObject>
#include <QMap>
#include <QQmlApplicationEngine>
#include <QtDebug>

#include "integrationsinterface.h"
#include "plugininterface.h"

class Integrations : public QObject, IntegrationsInterface
{
    Q_OBJECT
    Q_INTERFACES(IntegrationsInterface)

public:
    // list of all integrations
    Q_PROPERTY  (QList<QObject *>       list                    READ    list         NOTIFY     listChanged)

    // load all integrations from config file
    Q_INVOKABLE void                    load                    ();

    // get all integrations
    QList<QObject *>                    list                    ();

    // get an integration object by id
    Q_INVOKABLE QObject*                get                     (const QString& id);

    // add an integration
    Q_INVOKABLE void                    add                     (const QVariantMap& config, QObject *obj, const QString& type);

    // remove an integraiton
    Q_INVOKABLE void                    remove                  (const QString& id);

    // get friendly name
    Q_INVOKABLE QString                 getFriendlyName         (const QString& id);
    Q_INVOKABLE QString                 getFriendlyName         (QObject* obj);

    // get mdns _tcp name
    Q_INVOKABLE QString                 getMDNS                 (const QString& id);
    Q_INVOKABLE QStringList             getMDNSList             ();

    // get the type of integration by id
    Q_INVOKABLE QString                 getType                 (const QString& id);

    explicit Integrations(QQmlApplicationEngine *engine = nullptr, const QString& appPath = "");
    virtual ~Integrations();

    static Integrations*       getInstance     ()
    { return s_instance; }

signals:
    void listChanged();
    void loadComplete();

public slots:
    void onCreateDone(QMap<QObject *, QVariant> map);

private:
    QMap<QString, QObject*>     m_plugins;
    QMap<QString, QObject*>     m_integrations;
    QMap<QString, QString>      m_integrations_friendly_names;
    QMap<QString, QString>      m_integrations_mdns;
    QMap<QString, QString>      m_integrations_types;
    QString                     m_appPath;
    int                         m_integrationsToLoad = 0;
    int                         m_integrationsLoaded = 0;

    static Integrations*        s_instance;
    QQmlApplicationEngine*      m_engine;


};

#endif // INTEGRATIONS_H
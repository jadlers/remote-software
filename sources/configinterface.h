#ifndef CONFIGINTERFACE_H
#define CONFIGINTERFACE_H
#define CONFIG_COMPATIBLE

#include <QVariant>


/// This interface is implemented by the Entities object and used by integration DLLs to access the entities
class ConfigInterface
{
public:
    virtual ~ConfigInterface();

#ifdef CONFIG_COMPATIBLE
    virtual QVariantMap     read() = 0;
    virtual void            readWrite(QVariantMap config) = 0;
#endif
    virtual QVariantMap     config() = 0;
    virtual void            setConfig(const QVariantMap& config) = 0;
    virtual QVariantMap&    getSettings() = 0;
    virtual QVariantMap     getIntegrations() = 0;
    virtual QVariantMap     getIntegration(const QString& type) = 0;
    virtual QVariantMap     getAllEntities() = 0;
    virtual QVariantList    getEntities(const QString& type) = 0;

    virtual QVariant        getContextProperty (const QString& name) = 0;
};

QT_BEGIN_NAMESPACE
#define ConfigInterface_iid "YIO.ConfigInterface"
Q_DECLARE_INTERFACE(ConfigInterface, ConfigInterface_iid)
QT_END_NAMESPACE

#endif // CONFIGINTERFACE_H

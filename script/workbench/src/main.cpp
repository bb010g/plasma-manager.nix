#include <QApplication>
#include <QQmlApplicationEngine>
#include <QString>
#include <QUrl>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QQmlApplicationEngine qmlEngine;

    qmlEngine.addImportPath(QStringLiteral(":/"));
    qmlEngine.load(QUrl(QStringLiteral("qrc:/org/nixos/PlasmaManager/Workbench/main.qml")));

    return app.exec();
}

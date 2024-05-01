cmake_minimum_required(VERSION 3.16)

project(plasma-manager-workbench VERSION 1.0.0)

set(QT_MIN_VERSION "6.5.0")
set(KF_MIN_VERSION "6.0.0")

find_package(ECM ${KF_MIN_VERSION} REQUIRED)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(ECMOptionalAddSubdirectory)

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)

include(ECMQmlModule)
include(ECMQtDeclareLoggingCategory)

# include(ECMInstallIcons)
include(KDEClangFormat)
include(FeatureSummary)

find_package(Qt6 ${QT_MIN_VERSION} REQUIRED COMPONENTS
    Core
    Gui
    Qml
    Widgets
)

find_package(KF6 ${KF_MIN_VERSION} REQUIRED COMPONENTS
    Crash
    DocTools
    I18n
)

ecm_optional_add_subdirectory(doc)
add_subdirectory(src)
ecm_optional_add_subdirectory(icons)

# Make it possible to use the po files fetched by the fetch-translations step
ki18n_install(po)
kdoctools_install(po)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

add_executable(plasma-manager-workbench)

target_sources(plasma-manager-workbench PRIVATE
    main.cpp
)

# ecm_add_qml_module(plasma-manager-workbench
qt6_add_qml_module(plasma-manager-workbench
    URI org.nixos.PlasmaManager.Workbench
    VERSION 1.0
    # GENERATE_PLUGIN_SOURCE
    QML_FILES
        org/nixos/PlasmaManager/Workbench/main.qml
        org/nixos/PlasmaManager/Workbench/PlatformMenuBar.qml
        org/nixos/PlasmaManager/Workbench/FilterDelegateModel.qml
    SOURCES
)

ecm_qt_declare_logging_category(plasma-manager-workbench
    HEADER plasma-manager-workbench-debug.h
    IDENTIFIER PLASMA_MANAGER_WORKBENCH_LOG
    CATEGORY_NAME org.nixos.plasma-manager.workbench
)

target_link_libraries(plasma-manager-workbench
    PRIVATE
        KF6::I18n
        KF6::Crash
        Qt6::Widgets
)

# ecm_finalize_qml_module(plasma-manager-workbench
#     DESTINATION ${KDE_INSTALL_QMLDIR}
#     VERSION 1.0
# )

install(TARGETS plasma-manager-workbench ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(PROGRAMS org.example.plasma-manager-workbench.desktop DESTINATION ${KDE_INSTALL_APPDIR})
install(FILES org.example.plasma-manager-workbench.metainfo.xml DESTINATION ${KDE_INSTALL_METAINFODIR})

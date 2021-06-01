QT += quick quick3d \
    qml \
    3dcore 3drender 3dinput \
    3dquick 3dquickrender 3dquickinput 3dquickextras

target.path = $$[QT_INSTALL_EXAMPLES]/quick3d/simple
INSTALLS += target

SOURCES += \
    main.cpp

RESOURCES += \
    qml.qrc

OTHER_FILES += \
    doc/src/*.*

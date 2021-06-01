/****************************************************************************
**
** Copyright (C) 2019 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** BSD License Usage
** Alternatively, you may use this file under the terms of the BSD license
** as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.15
import QtQuick.Window 2.14 as QW
import QtQuick.Controls 2.15
import Qt3D.Core 2.0
import Qt3D.Render 2.0
import Qt3D.Input 2.0
import Qt3D.Extras 2.15
import QtQuick.Scene3D 2.0

ApplicationWindow {
    id: window
    width: 1280
    height: 720
    visible: true
    title: qsTr( "dxfExample" )

    Scene3D {
        anchors.fill: parent
        aspects: ["render", "logic", "input"]
        cameraAspectRatioMode: Scene3D.AutomaticAspectRatio

        Entity {
            id: sceneRoot

            components: [
                RenderSettings
                {
                    activeFrameGraph: ForwardRenderer
                    {
                        clearColor: Qt.rgba(0, 0.5, 1, 1)
                        camera: camera
                    }
                },
                InputSettings {}
            ]

            Camera {
                id: camera
                projectionType: CameraLens.PerspectiveProjection
                fieldOfView: 30
                aspectRatio: 16/9
                nearPlane : 0.1
                farPlane : 1000.0
                position: Qt.vector3d( 10.0, 0.0, 0.0 )
                upVector: Qt.vector3d( 0.0, 1.0, 0.0 )
                viewCenter: Qt.vector3d( 0.0, 0.0, 0.0 )
            }

            OrbitCameraController {
                camera: camera
            }

            Entity {
                id: entity

                property real x: 0.0
                property real y: 0.0
                property real z: 0.0
                property real scale: 1.0
                property real theta: 0.0
                property real phi: 0.0
                property Material material

                enabled: false
                components: [ transform, mesh, material ]

                Transform {
                    id: transform
                    translation: Qt.vector3d(0, -1, 0)
                    rotation: 0
                    scale: 1.0
                }

                Mesh {
                    id: mesh
                    source: "qrc:/teapot.obj"
                }

                Material {
                    id: material

                    property color ambient: Qt.rgba( 0.05, 0.05, 0.05, 1.0 )
                    property color diffuse: Qt.rgba( 0.7, 0.7, 0.7, 1.0 )
                    property color specular: Qt.rgba( 0.95, 0.95, 0.95, 1.0 )
                    property real shininess: 150.0
                    property real lineWidth: 0.8
                    property color lineColor: Qt.rgba( 0.0, 0.0, 0.0, 1.0 )

                    effect: effect
                    parameters: [
                        Parameter { name: "ka"; value: Qt.vector3d(material.ambient.r, material.ambient.g, material.ambient.b) },
                        Parameter { name: "kd"; value: Qt.vector3d(material.diffuse.r, material.diffuse.g, material.diffuse.b) },
                        Parameter { name: "ksp"; value: Qt.vector3d(material.specular.r, material.specular.g, material.specular.b) },
                        Parameter { name: "shininess"; value: material.shininess },
                        Parameter { name: "line.width"; value: material.lineWidth },
                        Parameter { name: "line.color"; value: material.lineColor }
                    ]
                }

                Effect {
                    id: effect

                    parameters: [
                        Parameter { name: "ka";   value: Qt.vector3d( 0.1, 0.1, 0.1 ) },
                        Parameter { name: "kd";   value: Qt.vector3d( 0.7, 0.7, 0.7 ) },
                        Parameter { name: "ks";  value: Qt.vector3d( 0.95, 0.95, 0.95 ) },
                        Parameter { name: "shininess"; value: 150.0 }
                    ]

                    techniques: [
                        Technique {
                            graphicsApiFilter {
                                api: GraphicsApiFilter.OpenGL
                                profile: GraphicsApiFilter.CoreProfile
                                majorVersion: 3
                                minorVersion: 1
                            }

                            filterKeys: [ FilterKey { name: "renderingStyle"; value: "forward" } ]

                            parameters: [
                                Parameter { name: "light.position"; value: Qt.vector4d( 0.0, 0.0, 0.0, 1.0 ) },
                                Parameter { name: "light.intensity"; value: Qt.vector3d( 1.0, 1.0, 1.0 ) },
                                Parameter { name: "line.width"; value: 1.0 },
                                Parameter { name: "line.color"; value: Qt.vector4d( 1.0, 1.0, 1.0, 1.0 ) }
                            ]

                            renderPasses: [
                                RenderPass {
                                    shaderProgram: ShaderProgram {
                                        vertexShaderCode:   loadSource("qrc:/shaders/robustwireframe.vert")
                                        geometryShaderCode: loadSource("qrc:/shaders/robustwireframe.geom")
                                        fragmentShaderCode: loadSource("qrc:/shaders/robustwireframe.frag")
                                    }
                                    renderStates: [
                                        CullFace {
                                            mode: CullFace.NoCulling
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                }
            }

            Entity {
                id: sceneLoaderEntity

                enabled: true
                components: [ sceneLoader ]

                SceneLoader {
                    id: sceneLoader

                    source: "qrc:/cube_blender.dxf"
                    onStatusChanged: {
                        if( status == SceneLoader.Ready ) {
                             instantiateMaterials();
                         }
                    }
                }
            }
        }
    }

    Component {
        id: wireFrameMaterial

        Material {
            id: material

            property color ambient: Qt.rgba( 0.05, 0.05, 0.05, 1.0 )
            property color diffuse: Qt.rgba( 0.7, 0.7, 0.7, 1.0 )
            property color specular: Qt.rgba( 0.95, 0.95, 0.95, 1.0 )
            property real shininess: 150.0
            property real lineWidth: 0.8
            property color lineColor: Qt.rgba( 0.0, 0.0, 0.0, 1.0 )

            effect: Effect {
                id: effect

                parameters: [
                    Parameter { name: "ka";   value: Qt.vector3d( 0.1, 0.1, 0.1 ) },
                    Parameter { name: "kd";   value: Qt.vector3d( 0.7, 0.7, 0.7 ) },
                    Parameter { name: "ks";  value: Qt.vector3d( 0.95, 0.95, 0.95 ) },
                    Parameter { name: "shininess"; value: 150.0 }
                ]

                techniques: [
                    Technique {
                        graphicsApiFilter {
                            api: GraphicsApiFilter.OpenGL
                            profile: GraphicsApiFilter.CoreProfile
                            majorVersion: 3
                            minorVersion: 1
                        }

                        filterKeys: [ FilterKey { name: "renderingStyle"; value: "forward" } ]

                        parameters: [
                            Parameter { name: "light.position"; value: Qt.vector4d( 0.0, 0.0, 0.0, 1.0 ) },
                            Parameter { name: "light.intensity"; value: Qt.vector3d( 1.0, 1.0, 1.0 ) },
                            Parameter { name: "line.width"; value: 1.0 },
                            Parameter { name: "line.color"; value: Qt.vector4d( 1.0, 1.0, 1.0, 1.0 ) }
                        ]

                        renderPasses: [
                            RenderPass {
                                shaderProgram: ShaderProgram {
                                    vertexShaderCode:   loadSource("qrc:/shaders/robustwireframe.vert")
                                    geometryShaderCode: loadSource("qrc:/shaders/robustwireframe.geom")
                                    fragmentShaderCode: loadSource("qrc:/shaders/robustwireframe.frag")
                                }
                                renderStates: [
                                    CullFace {
                                        mode: CullFace.NoCulling
                                    }
                                ]
                            }
                        ]
                    }
                ]
            }
            parameters: [
                Parameter { name: "ka"; value: Qt.vector3d(material.ambient.r, material.ambient.g, material.ambient.b) },
                Parameter { name: "kd"; value: Qt.vector3d(material.diffuse.r, material.diffuse.g, material.diffuse.b) },
                Parameter { name: "ksp"; value: Qt.vector3d(material.specular.r, material.specular.g, material.specular.b) },
                Parameter { name: "shininess"; value: material.shininess },
                Parameter { name: "line.width"; value: material.lineWidth },
                Parameter { name: "line.color"; value: material.lineColor }
            ]
        }
    }

    Component {
        id: pbrMatTemplate

        MetalRoughMaterial { baseColor: "red" }
    }

    function instantiateMaterials() {
        // TODO create as many materials as you need here
        var newmat = pbrMatTemplate.createObject( sceneLoader );

        function traverseNodes( node ) {
            if( node.components ) {
                var comps = [];
                for ( var j = 0; j < node.components.length; ++j ) {
                    var cmp = node.components[ j ];
                    var cmp_class = cmp.toString();
                    if( cmp_class.indexOf( "QPhongMaterial" ) >= 0 ) {
                        // TODO: look up material from list of materials you created instead of just using one
                        comps.push( wireFrameMaterial.createObject( sceneLoader ) );
                    } else {
                        comps.push(cmp);
                    }
                }
                // replace whole list of components
                node.components = comps;
            }

            if( node.childNodes ) {
                for( var i = 0; i < node.childNodes.length; i++ ) {
                    if(node.childNodes[ i ] == null) continue;
                    traverseNodes( node.childNodes[ i ]);
                }
            }
        } // traverseNodes()

        traverseNodes( sceneLoaderEntity );
    }
}

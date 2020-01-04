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
pragma Singleton

import QtQuick 2.11

QtObject {
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // COLORS
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    property int cornerRadius: 18 // radius of the buttons, defined here

    property bool darkMode: config.ui_config.darkmode

    property color colorGreen: "#19D37B"
    property color colorRed: "#EA003C"
    property color colorOrange: "#FF7241"
    property color colorBlue: "#19435E"

    property color colorBackground: darkMode ? "#000000" : "#ffffff"
    property color colorBackgroundTransparent: darkMode ? "#00000000" :  "#00000000"

    property color colorText: darkMode ? "#ffffff" : "#000000"
    property color colorLine: darkMode ? "#ffffff" : "#000000"

    property color colorHighlight1: "#918682"
    property color colorHighlight2: "#313247"

    property color colorLight: darkMode ? "#484848" : "#CBCBCB"
    property color colorMedium: darkMode ? "#282828" : "#D4D4D4"
    property color colorDark: darkMode ? "#1C1C1C" : "#ffffff"

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // ICONS
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    readonly property QtObject icons: QtObject {
        readonly property string cool: "\uE91E"
        readonly property string heat: "\uE91F"

        readonly property string circle_full: "\uE91A"
        readonly property string circle: "\uE91B"
        readonly property string square_full: "\uE91C"
        readonly property string square: "\uE91D"

        readonly property string left_arrow: "\uE917"
        readonly property string right_arrow: "\uE918"
        readonly property string up_arrow: "\uE919"
        readonly property string down_arrow: "\uE916"
        readonly property string up_arrow_bold: "\uE923"
        readonly property string down_arrow_bold: "\uE922"

        readonly property string fav_add: "\uE920"
        readonly property string fav_remove: "\uE921"

        readonly property string close: "\uE915"
        readonly property string home: "\uE900"

        readonly property string light: "\uE901"
        readonly property string link: "\uE902"
        readonly property string music: "\uE903"
        readonly property string prev: "\uE909"
        readonly property string next: "\uE904"
        readonly property string pause: "\uE905"
        readonly property string play: "\uE906"
        readonly property string playlist: "\uE907"
        readonly property string search: "\uE90C"
        readonly property string speaker: "\uE90D"
        readonly property string speakers: "\uE90E"
        readonly property string radio: "\uE90A"

        readonly property string power_on: "\uE908"
        readonly property string remote: "\uE90B"
        readonly property string stairs: "\uE90F"
        readonly property string tv: "\uE910"
        readonly property string weather: "\uE911"
        readonly property string climate: "\uE913"
        readonly property string blind: "\uE914"
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // FONT STYLES
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    property font buttonFont: Qt.font({
                                          family: "Open Sans",
                                          weight: Font.Normal,
                                          pixelSize: 27,
                                          lineHeight: 1
                                      })
}

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

import QtQuick 2.11

import DisplayControl 1.0
import TouchEventFilter 1.0
import Proximity 1.0
import Launcher 1.0

import "qrc:/scripts/helper.js" as JSHelper

Item {
    id: standbyControl
    property bool proximityDetected: false
    property bool touchDetected: false
    property bool buttonPressDetected: false

    property string mode: "on" // on, dim, standby, wifi_off

    property int displayDimTime: 20 // seconds
    property int standbyTime: 30 // seconds
    property int wifiOffTime: 0 // seconds
    property int shutdownTime: 0 // seconds

    property int display_brightness: 100
    property int display_brightness_old: 100
    property bool display_autobrightness
    property int display_brightness_ambient: 100
    property int display_brightness_set: 100

    property int screenOnTime: 0
    property int screenOffTime: 0

    signal standByOn()
    signal standByOff()

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // TOUCH EVENT DETECTOR
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    TouchEventFilter {
        id: touchFilter
        source: applicationWindow

        onDetectedChanged: {
            touchDetected = true;
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // PROXIMITY SENSOR APDS9960
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    property alias proximity: proximity

    Proximity {
        id: proximity

        onProximityEvent: {
            standbyControl.proximityDetected = true;
        }
    }

    Timer {
        id: ambientLightReadTimer
        running: false
        repeat: false
        interval: 400

        onTriggered: {
            standbyControl.display_brightness_ambient = JSHelper.mapValues(proximity.readAmbientLight(),0,30,15,100);
            // set the display brightness
            if (standbyControl.display_autobrightness) {
                setBrightness(display_brightness_ambient);
            } else {
                setBrightness(display_brightness_set);
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // STANDBY CONTROL
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    property alias displayControl: displayControl
    DisplayControl {
        id: displayControl
    }

    function setBrightness(brightness) {
        displayControl.setBrightness(display_brightness_old, brightness);
        display_brightness_old = brightness;
        display_brightness = brightness;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // FUNCTIONS
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    Launcher { id: standbyLauncher }
    Launcher { id: wifiLauncher }

    function wifiHandler(state) {
        var cmd;

        if (state === "on") {
            cmd = "systemctl start wpa_supplicant@wlan0.service"
            wifiLauncher.launch(cmd);
        } else {
            cmd = "systemctl stop wpa_supplicant@wlan0.service"
            wifiLauncher.launch(cmd);
        }
    }

    function getCurrentTime(){
        const timeSizeReduction = 1570881231088;
        return (new Date().getTime() - timeSizeReduction);
    }

    function wakeUp() {
        // get battery readings
        //        battery.checkBattery();

        switch (mode) {

            case "dim":
                // set the display brightness
                ambientLightReadTimer.start();

                // set the mode
                mode = "on";
                break;

            case "standby":
                // turn off standby
                if (displayControl.setmode("standbyoff")) {
                    standbyoffDelay.start();
                }

                // set the mode
                mode = "on";
                break;

            case "wifi_off":
                wifiHandler("on")

                // turn off standby
                if (displayControl.setmode("standbyoff")) {
                    standbyoffDelay.start();
                }

                // set the mode
                mode = "on";

                // integration socket on
                for (var i=0; i<integrations.list.length; i++) {
                    integrations.list[i].connect();
                }

                // turn on API
                api.start();

                break;
        }

        // reset elapsed time
        standbyBaseTime = getCurrentTime();

        // start bluetooth scanning
        if (config.settings.bluetootharea) bluetoothArea.startScan();

        // reset battery charging screen
        chargingScreen.item.showClock.start();
    }

    Timer {
        id: standbyoffDelay
        repeat: false
        running: false
        interval: 300

        onTriggered: {
            ambientLightReadTimer.start();
        }
    }

    onTouchDetectedChanged: {
        // if there was a touch event, reset the timers
        if (touchDetected) {
            wakeUp();
            touchDetected = false;
            proximity.proximityDetection(false);
        }
    }

    onProximityDetectedChanged: {
        // if there was a proximity event, reset the timers
        if (proximityDetected) {
            wakeUp();
            proximityDetected = false;
        }
    }

    onButtonPressDetectedChanged: {
        // if there was a button press event, reset the timers
        if (buttonPressDetected) {
            wakeUp();
            buttonPressDetected = false;
            proximity.proximityDetection(false);
        }
    }

    onModeChanged: {
        console.debug("Mode changed: " + mode);
        // if mode is on change processor to ondemand
        if (mode === "on") {
            standbyLauncher.launch("/usr/bin/yio-remote/ondemand.sh");
            standByOff();
        }
        // if mode is standby change processor to powersave
        if (mode === "standby") {
            standbyLauncher.launch("/usr/bin/yio-remote/powersave.sh");
            standByOn();
        }
    }

    // standby timer
    property var standbyBaseTime
    property alias standbyTimer: standbyTimer

    Timer {
        id: standbyTimer
        repeat: true
        running: false
        interval: 1000

        onTriggered: {
            let time = getCurrentTime();


            if (mode == "on" || mode == "dim"){
                screenOnTime += 1000;
            }
            if (mode == "standby" || mode == "wifi_off"){
                screenOffTime += 1000;
            }


            // mode = dim
            if (time - standbyBaseTime > displayDimTime * 1000 && mode == "on") {
                // dim the display
                setBrightness(10);
                mode = "dim";
            }

            // mode = standby
            if (time - standbyBaseTime > standbyTime * 1000 && mode == "dim") {
                // turn on proximity detection
                proximity.proximityDetection(true);

                // turn off the backlight
                setBrightness(0);

                // put the display to standby mode
                displayControl.setmode("standbyon");

                // stop bluetooth scanning
                if (config.settings.bluetootharea) bluetoothArea.stopScan();

                mode = "standby";

                // reset battery charging screen
                chargingScreen.item.resetClock.start();
            }

            // bluetooth turn off
            if (time-standbyBaseTime > (standbyTime+20)* 1000 && config.settings.bluetootharea) {
                // turn off bluetooth
                bluetoothArea.turnOff()
            }

            // mode = wifi_off
            if (time-standbyBaseTime > wifiOffTime * 1000 && wifiOffTime != 0 && mode == "standby" && battery_averagepower <= 0) {
                // integration socket off
                for (var i=0; i<integrations.list.length; i++) {
                    integrations.list[i].disconnect();
                }
                // turn off API
                api.stop();

                // turn off wifi
                wifiHandler("off")

                mode = "wifi_off";
            }

            // mode = shutdown
            if (time-standbyBaseTime > shutdownTime * 1000 && shutdownTime != 0 && (mode == "standby" || mode =="wifi_off") && battery_averagepower <= 0) {
                logger.write("TIMER SHUTDOWN initated");
                logger.write("time variable: " + time);
                logger.write("standbyBaseTime variable: " + standbyBaseTime);
                logger.write("shutdownTime variable:" + shutdownTime);
                logger.write("battery_averagepower: " + battery_averagepower);

                loadingScreen.source = "qrc:/basic_ui/ClosingScreen.qml";
                loadingScreen.active = true;
            }
        }
    }

    Timer {
        running: true
        repeat: false
        interval: 20000

        onTriggered: {
            standbyBaseTime = getCurrentTime();
            if (loader_main.source != "qrc:/wifiSetup.qml") {
                standbyTimer.start()
            }
        }
    }
}
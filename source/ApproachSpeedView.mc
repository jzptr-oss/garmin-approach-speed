using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.AntPlus;
using Toybox.Activity;
using Toybox.Attention;
using Toybox.System;
using Toybox.Application.Properties;

class ApproachSpeedView extends WatchUi.DataField {

    // Radar sensor
    hidden var _radar;
    hidden var _radarInfo;
    
    // Display values
    hidden var _deltaSpeed;        // Delta speed in km/h
    hidden var _vehicleCount;      // Number of vehicles
    hidden var _threatLevel;       // Current threat level (0=none, 1=yellow, 2=red)
    hidden var _lastAlertLevel;    // To avoid repeated alerts
    
    // Thresholds (in km/h delta) - configurable via settings
    hidden var _thresholdYellow = 20;
    hidden var _thresholdRed = 40;
    hidden var _soundEnabled = true;
    
    // Colors
    const COLOR_CLEAR = Graphics.COLOR_DK_GREEN;
    const COLOR_GREEN = Graphics.COLOR_GREEN;
    const COLOR_YELLOW = Graphics.COLOR_YELLOW;
    const COLOR_RED = Graphics.COLOR_RED;
    const COLOR_TEXT = Graphics.COLOR_WHITE;
    const COLOR_TEXT_DARK = Graphics.COLOR_BLACK;

    function initialize() {
        DataField.initialize();
        
        _deltaSpeed = null;
        _vehicleCount = 0;
        _threatLevel = 0;
        _lastAlertLevel = 0;
        
        // Load settings
        loadSettings();
        
        // Initialize bike radar sensor
        try {
            _radar = new AntPlus.BikeRadar(null);
        } catch (e) {
            _radar = null;
        }
    }
    
    // Load user settings
    function loadSettings() {
        try {
            var yellow = Properties.getValue("yellowThreshold");
            if (yellow != null) {
                _thresholdYellow = yellow;
            }
            var red = Properties.getValue("redThreshold");
            if (red != null) {
                _thresholdRed = red;
            }
            var sound = Properties.getValue("soundEnabled");
            if (sound != null) {
                _soundEnabled = sound;
            }
        } catch (e) {
            // Use defaults if settings unavailable
        }
    }

    // Called when this field becomes visible
    function onLayout(dc) {
        // We'll handle all drawing in onUpdate
        return true;
    }

    // Called every second during activity
    function compute(info) {
        // Get current speed (m/s -> km/h)
        var mySpeed = 0.0;
        if (info != null && info.currentSpeed != null) {
            mySpeed = info.currentSpeed * 3.6; // Convert m/s to km/h
        }
        
        // Get radar data
        _vehicleCount = 0;
        _deltaSpeed = null;
        var maxApproachSpeed = 0.0;
        
        if (_radar != null) {
            var targets = _radar.getRadarInfo();
            
            if (targets != null && targets.size() > 0) {
                _vehicleCount = targets.size();
                
                // Find the fastest approaching vehicle
                for (var i = 0; i < targets.size(); i++) {
                    var target = targets[i];
                    if (target != null && target.speed != null) {
                        // target.speed is relative approach speed in m/s
                        var approachSpeedKmh = target.speed * 3.6;
                        if (approachSpeedKmh > maxApproachSpeed) {
                            maxApproachSpeed = approachSpeedKmh;
                        }
                    }
                }
                
                // Delta = how much faster the vehicle is going than me
                // If approach speed is positive, they're getting closer
                _deltaSpeed = maxApproachSpeed;
            }
        }
        
        // Determine threat level
        var newThreatLevel = 0;
        if (_deltaSpeed != null && _deltaSpeed > 0) {
            if (_deltaSpeed >= _thresholdRed) {
                newThreatLevel = 2; // Red
            } else if (_deltaSpeed >= _thresholdYellow) {
                newThreatLevel = 1; // Yellow
            }
        }
        
        // Play alert if threat level increased
        if (newThreatLevel > _lastAlertLevel) {
            playAlert(newThreatLevel);
        }
        
        _threatLevel = newThreatLevel;
        _lastAlertLevel = newThreatLevel;
        
        // Reset alert tracking if no vehicles
        if (_vehicleCount == 0) {
            _lastAlertLevel = 0;
        }
        
        return _deltaSpeed;
    }

    // Play audio/vibration alert
    function playAlert(level) {
        // Play sound if enabled
        if (_soundEnabled && Attention has :playTone) {
            if (level == 1) {
                // Yellow: single beep
                Attention.playTone(Attention.TONE_ALERT_LO);
            } else if (level == 2) {
                // Red: double beep (two tones)
                Attention.playTone(Attention.TONE_ALERT_HI);
            }
        }
        
        // Always vibrate if available
        if (Attention has :vibrate) {
            var vibeData;
            if (level == 1) {
                vibeData = [new Attention.VibeProfile(50, 200)];
            } else {
                // Double vibration for red alert
                vibeData = [
                    new Attention.VibeProfile(100, 200),
                    new Attention.VibeProfile(0, 100),
                    new Attention.VibeProfile(100, 200)
                ];
            }
            Attention.vibrate(vibeData);
        }
    }

    // Draw the data field
    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        // Determine background color based on threat
        var bgColor;
        var textColor;
        
        if (_vehicleCount == 0 || _deltaSpeed == null) {
            bgColor = COLOR_CLEAR;
            textColor = COLOR_TEXT;
        } else if (_threatLevel == 2) {
            bgColor = COLOR_RED;
            textColor = COLOR_TEXT;
        } else if (_threatLevel == 1) {
            bgColor = COLOR_YELLOW;
            textColor = COLOR_TEXT_DARK;
        } else {
            bgColor = COLOR_GREEN;
            textColor = COLOR_TEXT;
        }
        
        // Fill background
        dc.setColor(bgColor, bgColor);
        dc.fillRectangle(0, 0, width, height);
        
        // Draw text
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        
        var displayText;
        var labelText = "";
        
        if (_vehicleCount == 0 || _deltaSpeed == null) {
            displayText = "CLEAR";
        } else {
            // Format delta speed with + sign and down arrow
            var delta = _deltaSpeed.toNumber();
            displayText = "+" + delta.toString();
            labelText = "km/h ↓";
        }
        
        // Calculate font sizes based on field size
        var mainFont = Graphics.FONT_NUMBER_MEDIUM;
        var labelFont = Graphics.FONT_TINY;
        
        if (height < 60) {
            mainFont = Graphics.FONT_MEDIUM;
            labelFont = Graphics.FONT_XTINY;
        } else if (height > 100) {
            mainFont = Graphics.FONT_NUMBER_HOT;
        }
        
        // Draw main value centered
        var mainY = height / 2;
        if (labelText.length() > 0) {
            mainY = height / 2 - 10;
        }
        
        dc.drawText(
            width / 2,
            mainY,
            mainFont,
            displayText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        
        // Draw label below if we have delta
        if (labelText.length() > 0) {
            dc.drawText(
                width / 2,
                mainY + 25,
                labelFont,
                labelText,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }
        
        // Draw vehicle count indicator in corner (small)
        if (_vehicleCount > 0) {
            dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width - 5,
                5,
                Graphics.FONT_XTINY,
                _vehicleCount.toString() + "×",
                Graphics.TEXT_JUSTIFY_RIGHT
            );
        }
    }
}

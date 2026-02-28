using Toybox.Application;
using Toybox.WatchUi;

class ApproachSpeedApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // Return the initial view for the data field
    function getInitialView() {
        return [new ApproachSpeedView()];
    }
}

function isInteger(x) {
    return (typeof x === 'number') && (x % 1 === 0);
}

var mraid = {
    getState: function() {return "loading"},
    listeners: [],
    addEventListener: function(eventName, callback) { this.listeners.push({eventName:eventName, callback:callback}); }
};

(function(mraid, undefined) {

    var isIOS = (/iphone|ipad|ipod/i).test(window.navigator.userAgent.toLowerCase());
    if (isIOS) {
        window.console = {};
        console.log = function(message) {
            nativeExecute("log", {message:message}, undefined);
        };
        console.debug = console.info = console.warn = console.error = console.log;
        console.debug("console logging initialized");
    }


    var listeners = mraid.listeners || [];
    var expandProperties = {
        width : false,
        height : false,
        useCustomClose : false,
        isModal : true // read-only
    };

    var nativeData = {
            placementType: "inline", // "inline", "interstitial"
        isVisible: false,
        state: "loading", // "loading", "default", "expanded", "resized", or "hidden"
        height: false,
        width: false,
        screenWidth: false,
        screenHeight: false,
        x: false,
        y: false
    };

    mraid.getVersion = function() { console.debug("getVersion"); return "2.0"; };

    mraid.getPlacementType = function() { console.debug("getPlacement"); return nativeData.placementType; };

    mraid.getState = function() { console.debug("getState: " + nativeData.state); return nativeData.state; };

    mraid.isViewable = function() {
        var isViewable = nativeData.isVisible;
        console.debug("isViewable is " + (isViewable ? "Viewable" : "NOT Viewable"));
        return nativeData.isVisible; };

    mraid.addEventListener = function(eventName, callback) {
        // available events: "ready", "error", "stateChange", "viewableChange", "sizeChange"
        console.debug("addEventListener: " + eventName + ", " + callback);
        listeners.push({eventName: eventName, callback: callback});
    };

    mraid.removeEventListener = function(eventName, callback) {
        console.debug("removeEventListener");
        for(var i = listeners.length-1; i >= 0; i--) {
            if(listeners[i].eventName == eventName
                && (typeof(callback) == "undefined" || listeners[i].callback == callback)) {
                console.debug("removing {" + listeners[i].eventName + ", " + listeners[i].callback + "}");
                listeners.splice(i,1);
            }
        }
    };

    mraid.close = function() {
        console.debug("close");
        nativeExecute("close");
    };

    mraid.open = function(url) {
        console.debug("open");
        nativeExecute("open", {url: url});
    };

    mraid.setExpandProperties = function(props) {
        var propsStr = "{";
        var counter = 0;
        for(var p in props) {
            if(props.hasOwnProperty(p)) {
                 if(counter == 0) {
                    propsStr += p + ": " + props[p];
                    counter++;
                 } else {
                    propsStr += ", " + p + ": " + props[p];
                 }
            }
        }
        propsStr += "}";
        console.debug("setExpandProperties: " + propsStr);
        if('width' in props) {
            expandProperties.width = props.width;
        }

        if('height' in props) {
            expandProperties.height = props.height;
        }

        if('useCustomClose' in props) {
            expandProperties.useCustomClose = props.useCustomClose;
        }
    };

    mraid.getExpandProperties = function() {
        console.debug("getExpandProperties");
        if(!expandProperties.width) {
            expandProperties.width = nativeData.screenWidth;
            expandProperties.height = nativeData.screenHeight;
        }

        return {
            width : expandProperties.width,
            height : expandProperties.height,
            useCustomClose : expandProperties.useCustomClose,
            isModal : expandProperties.isModal
        };
    };

    mraid.expand = function(url) {
        console.debug("expand");
        var params = mraid.getExpandProperties();
        if(typeof(url) !== 'undefined') {
            params['url'] = url;
        }
        nativeExecute("expand", params);
    };

    mraid.useCustomClose = function(useCustomClose) {
        console.debug("useCustomClose(" + useCustomClose + ")");
        expandProperties.useCustomClose = useCustomClose;
        nativeExecute("useCustomClose", {useCustomClose:useCustomClose});
    };




    // code to handle comms between native app and js

    var unique = 0;
    var responseQueue = {};

    mraid._nativeResponse = function(data, id) {
        if(typeof(id) != 'undefined') {
            console.debug("id defined!");
            if(id in responseQueue) {
//                log("found id: " + id);
                var fn = responseQueue[id];
                delete responseQueue[id];
                fn.apply(data);
            }
        }
        else {
            var msg = "data: ";
            // native app is relaying some sort of state change
            for(var param in data) {
                if(data.hasOwnProperty(param)) {
                    debugger;
                    if(param in nativeData) {
                        nativeData[param] = data[param];
                        msg += param + ": " + data[param] + " ";
                    }
                    else if(param == "_fire_event_") {
                        var evt = data[param];
                        console.debug("trying to fire event named: " + evt.name + " with props " + evt.props);
                        fireEvent(evt.name, evt.props);
                    }
                }
            }
            console.debug(msg)
        }
    };

    function fireEvent(event, params) {
        console.debug("fireEvent: " + event + "(" + params + ")");
        for(var i = 0; i < listeners.length; i++) {
            var lstnr = listeners[i];
            console.debug("checking event: " + lstnr.eventName);
            if(lstnr.eventName.toLowerCase() == event.toLowerCase()) {
                console.debug("calling: " + lstnr.callback);
                if(params) {
                    lstnr.callback.apply(undefined, params);
                }
                else {
                    lstnr.callback();
                }
            }
        }
    }

    function nativeExecute(method, props, callback) {
        if(method != "log" && nativeData.state == "hidden") {
            var message = "Made a call to a disposed ad unit";
            var action = method;
            fireEvent("error", [message, action]);
            return;
        }
        var url = "NATIVECALL://" + method;
        if(callback) {
            // expecting results back from the native call...
            var callId = method + "-" + unique++;
            responseQueue[callId] = callback;
            props['__callback'] = callId;
        }
        if(props) {
            var first = true;
            for(var p in props) {
                if(props.hasOwnProperty(p)) {
                    if(first) {
                        url += "?";
                        first = false;
                    }
                    else {
                        url += "&";
                    }
                    url += p + "=" + encodeURIComponent(props[p]);
                }
            }
        }
//        console.debug("calling command: " + url);
        var iframe = document.createElement("IFRAME");
        iframe.setAttribute("src", url);
        document.documentElement.appendChild(iframe);
        iframe.parentNode.removeChild(iframe);
        iframe = null;
    }


    /***********************************************
     * MRAID 2.0 functionality
     ***********************************************/

    var defaultPosition = {
        x:0,
        y:0,
        width:0,
        height:0
    };
//    var currentPosition = {
//        x:0,
//        y:0,
//        width:0,
//        height:0
//    };
    var orientationProperties = {
        allowOrientationChange : true,
        forceOrientation : "none" // portrait, landscape, none
    };
    var resizeProperties = {
        width : false,
        height : false,
        offsetX : false,
        offsetY : false,
        customClosePosition : "top-right", // "top-left", "top-right", "center", "bottom-left", "bottom-right," "top-center," or "bottom-center"
        allowOffscreen : false
    };

    mraid.getOrientationProperties = function() {
        console.debug("getOrientationProperties");
        return {
            allowOrientationChange: orientationProperties.allowOrientationChange,
            forceOrientation: orientationProperties.forceOrientation
        };
    };

    mraid.getCurrentPosition = function() {
        console.debug("getCurrentPosition");
        return {
            x: nativeData.x,
            y: nativeData.y,
            width: nativeData.width,
            height: nativeData.height
        };
    };
 
     mraid.setCurrentPosition = function(position) {
        var previousSize = mraid.getCurrentPosition();
        console.debug("setCurrentPosition");
        console.debug(previousSize.height);
        console.debug(previousSize.width);
        //currentPosition = position;
        if("x" in position) {
            nativeData.x = position.x;
            defaultPosition.x = position.x;
        }
        if("y" in position) {
            nativeData.y = position.y;
            defaultPosition.y = position.y;
        }
        if("height" in position) {
            nativeData.height = position.height;
            defaultPosition.height = position.height;
        }
        if("width" in position) {
            nativeData.width = position.width;
            defaultPosition.width = position.width;
        }
 
        var currentSize = mraid.getCurrentPosition();
        console.debug(currentSize.height);
        console.debug(currentSize.width);
         // Only send the size changed event if the size in the position
         // was different from the previous position
         if ((previousSize.width === currentSize.width) && (previousSize.height === currentSize.height)) {
            return;
         }
         
         var handlers = listeners["sizeChange"];
         if (handlers) {
            var width = nativeData.width;
            var height = nativeData.height;
         
            for (var i = 0; i < handlers.length; ++i) {
                handlers[i](width, height);
            }
         }
     };
 
    mraid.getDefaultPosition = function() {
        console.debug("getDefaultPosition: " + defaultPosition);
        return {
            x: defaultPosition.x,
            y: defaultPosition.y,
            width: defaultPosition.width,
            height: defaultPosition.height
        };
    };
    mraid.getScreenSize = function() {
        console.debug("getScreenSize");
        return {
            width: nativeData.screenWidth,
            height: nativeData.screenHeight
        };
    };

    mraid.setOrientationProperties = function(props) {
        console.debug("setOrientationProperties");
        if('allowOrientationChange' in props) {
            orientationProperties.allowOrientationChange = props.allowOrientationChange;
        }

        if('forceOrientation' in props) {
            orientationProperties.forceOrientation = props.forceOrientation;
        }
        nativeExecute("setOrientationProperties", orientationProperties, undefined);
    };

    mraid.createCalendarEvent = function(props) {
        nativeExecute("createCalendarEvent", props, undefined);
    };
 
    var maxSize = mraid.maxSize = {
        width:0,
        height:0
    }
 
    mraid.getMaxSize = function() {
        console.debug("getMaxSize: width:" + maxSize.width + " height:" + maxSize.height);
        return maxSize;
    };
 
    mraid.setMaxSize = function(props) {
        maxSize.height = props.height;
        maxSize.width = props.width;
        console.debug("setMaxSize " + maxSize.width + " " + maxSize.height);
    }
    mraid.getResizeProperties = function() {
        console.debug("getResizeProperties");
        if(resizeProperties.width == false || resizeProperties.height == false) {
            mraid.fireErrorEvent("Can't get resize properties for frame without setting resize properties first", "getResizeProperties");
        } else {
            return resizeProperties;
        }
    };
    mraid.playVideo = function(url) {
        console.debug("playVideo");
        nativeExecute("playVideo", {url:url}, undefined);
    };
    mraid.resize = function() {
        console.debug("resize");
        var currentState = mraid.getState();
        if(currentState == "expanded") {
            var message = "Can't resize an expanded ad unit";
            var action = "resize";
            fireEvent("error", [message, action]);
        } else {
            nativeData.height = resizeProperties.height;
            nativeData.width = resizeProperties.width;
            nativeData.state = "resized";
            nativeExecute("resize", {width:nativeData.width, height:nativeData.height});
        }
   };
    mraid.setResizeProperties = function(props) {
        console.debug("setResizeProperties " + props.height + " " + props.width + " " + props.offsetX + " " + props.offsetY + " " + props.allowOffscreen.toString());
        if((!isInteger(props.height) || !isInteger(props.width) || !isInteger(props.offsetX) || !isInteger(props.offsetY)) || (props.height <= 50 &&  props.width <= 50) || (props.height > maxSize.height || props.width > maxSize.width)) {
           resizeProperties = {
             width : false,
             height : false,
             offsetX : false,
             offsetY : false,
             customClosePosition : "top-right", // "top-left", "top-right", "center", "bottom-left", "bottom-right," "top-center," or "bottom-center"
             allowOffscreen : false
           };
           mraid.fireErrorEvent("Invalid data passed to resize properties", "setResizeProperties");
        } else {
            var shouldBeOffscreen;
            if(props.allowOffscreen) {
               shouldBeOffscreen = props.allowOffscreen;
            } else {
               shouldBeOffscreen = false;
            }
            resizeProperties = {
                width : props.width,
                height : props.height,
                offsetX : props.offsetX,
                offsetY : props.offsetY,
                customClosePosition : props.customClosePosition,
                allowOffscreen : shouldBeOffscreen
            };
        }
    };
 
    mraid.storePicture = function(url) {
        console.debug("storePicture");
        nativeExecute("storePicture", {url:url}, undefined);
    };

     var FEATURES = mraid.FEATURES = {
     SMS             :"sms",
     PHONE           :"tel",
     CALENDAR        :"calendar",
     STORE_PICTURE   :"storePicture",
     INLINE_VIDEO    :"inlineVideo"
     };
     
     var supportedFeatures = {};
     
     mraid.setSupports = function(feature, supported) {
        supportedFeatures[feature] = supported;
        console.debug(feature + " is being set to " + supported);
     };
     
     mraid.supports = function(feature) {
        console.debug("supports");
     
        return supportedFeatures[feature];
     };
 
     mraid.fireErrorEvent = function(message, action) {
        console.log("fireErrorEvent handler:" + message + " action:" + action);
         var handlers = listeners[EVENTS.ERROR];
        if (handlers) {
            for (var i = 0; i < handlers.length; ++i) {
                handlers[i](message, action);
            }
        }
     };
} (window.mraid));

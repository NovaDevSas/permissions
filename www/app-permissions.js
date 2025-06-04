var PLUGIN_NAME = "AppPermissionsPlugin";
// @ts-ignore
var exec = require("cordova/exec");
exports.getStorageInfo =
    /**
     * Get storage info
     * @returns {Promise<any>} Promise fulfiled with the storage info
     * @example
     * cordova.plugins.AppPermissions.getStorageInfo().then(function(info) {
     *    console.log("Storage info: ", info.totalspace, info.freespace);
     * });
     */
    function () {
        return new Promise(function (resolve, reject) {
            exec(resolve, reject, PLUGIN_NAME, "getStorageInfo", []);
        });
    };

exports.openURL =
    /**
     *
     * @returns {Promise<void>} Promise fulfiled with the current permission value
     *
     * @example
     * cordova.plugins.AppPermissions.openURL().then(function(value) {
     *     console.log("Permission value: ", value);
     * });
     */
    function (action, uri) {
        return new Promise(function (resolve, reject) {
            exec(resolve, reject, PLUGIN_NAME, "openURL", [action, uri]);
        });
    };

exports.shouldShowRequestPermissionRationale =
    /**
     *
     * @returns {Promise<boolean>} Promise fulfiled with the current permission value
     *
     * @example
     * cordova.plugins.AppPermissions.shouldShowRequestPermissionRationale
     *     ("android.permission.ACCESS_BACKGROUND_LOCATION").then(function(value) {
     *         console.log("Permission value: ", value);
     * });
     */
    function (permission) {
        return new Promise(function (resolve, reject) {
            exec(resolve, reject, PLUGIN_NAME, "shouldShowRequestPermissionRationale", [permission]);
        });
    };
    
exports.requestNearbyDevicesPermission =
    /**
     *
     * Ask for permission to use nearby devices (Bluetooth) for beacon detection.
     * @returns {Promise<void>}
     *
     * @example
     * cordova.plugins.AppPermissions.requestNearbyDevicesPermission().then(function() {
     *     console.log("Requesting authorization to use nearby devices");
     * });
     */
    function () {
        return new Promise(function (resolve, reject) {
            exec(resolve, reject, PLUGIN_NAME, "requestNearbyDevicesPermission", []);
        });
    };

exports.checkNearbyDevicesPermission =
    /**
     *
     * @returns {Promise<any>} Promise fulfiled with the current permission value
     *
     * @example
     * cordova.plugins.AppPermissions.checkNearbyDevicesPermission().then(function(value) {
     *     console.log("Permission value: ", value);
     * });
     */
    function () {
        return new Promise(function (resolve, reject) {
            exec(resolve, reject, PLUGIN_NAME, "checkNearbyDevicesPermission", []);
        });
    };
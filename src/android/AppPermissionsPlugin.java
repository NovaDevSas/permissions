package cl.entel.cordova;

import static by.chemerisuk.cordova.support.ExecutionThread.WORKER;

import android.Manifest;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.util.Log;
import android.content.Intent;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.PluginResult;
import org.json.JSONException;
import org.json.JSONObject;

import by.chemerisuk.cordova.support.CordovaMethod;
import by.chemerisuk.cordova.support.ReflectiveCordovaPlugin;


public class AppPermissionsPlugin extends ReflectiveCordovaPlugin {
    private static final String TAG = "AppPermissionsPlugin";
    private CallbackContext requestPermissionCallback;
    private ActivityResultLauncher<String[]> requestPermissionLauncher;

    @Override
    protected void pluginInitialize() {
        requestPermissionLauncher = cordova.getActivity().registerForActivityResult(new ActivityResultContracts.RequestMultiplePermissions(), isGranted -> {
            requestPermissionCallback.success();
        });
    }

    @CordovaMethod(WORKER)
    private void requestBackgroundLocationPermission(CordovaArgs args, CallbackContext callbackContext) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            requestPermission(new String[]{Manifest.permission.ACCESS_BACKGROUND_LOCATION}, callbackContext);
        } else {
            callbackContext.error("Build.VERSION_CODES.Q > Build.VERSION.SDK_INT -> " + Build.VERSION.SDK_INT);
        }
    }

    @CordovaMethod(WORKER)
    private void requestLocationPermission(CordovaArgs args, CallbackContext callbackContext) {
        requestPermission(new String[]{Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION}, callbackContext);
    }

    @CordovaMethod(WORKER)
    private void requestNearbyDevicesPermission(CordovaArgs args, CallbackContext callbackContext) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                requestPermission(new String[]{
                    Manifest.permission.BLUETOOTH_SCAN,
                    Manifest.permission.BLUETOOTH_CONNECT
                }, callbackContext);
            } else {
                requestPermission(new String[]{
                    Manifest.permission.BLUETOOTH,
                    Manifest.permission.BLUETOOTH_ADMIN
                }, callbackContext);
            }
            
            // Asegurar que siempre se envíe una respuesta
            JSONObject response = new JSONObject();
            response.put("status", "requested");
            response.put("message", "Permiso para dispositivos cercanos solicitado");
            
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, response));
        } catch (Exception e) {
            e.printStackTrace();
            callbackContext.error("Error al solicitar permisos: " + e.getMessage());
        }
    }

    @CordovaMethod(WORKER)
    private void checkNearbyDevicesPermission(CordovaArgs args, CallbackContext callbackContext) {
        try {
            boolean bluetoothPermission = true;
            String permissionStatus = "unknown";
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                boolean bluetoothScan = ContextCompat.checkSelfPermission(cordova.getContext(), 
                    Manifest.permission.BLUETOOTH_SCAN) == PackageManager.PERMISSION_GRANTED;
                boolean bluetoothConnect = ContextCompat.checkSelfPermission(cordova.getContext(), 
                    Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED;
                bluetoothPermission = bluetoothScan && bluetoothConnect;
                
                if (bluetoothScan && bluetoothConnect) {
                    permissionStatus = "granted";
                } else if (!bluetoothScan && !bluetoothConnect) {
                    permissionStatus = "denied";
                } else {
                    permissionStatus = "partial";
                }
            } else {
                boolean bluetooth = ContextCompat.checkSelfPermission(cordova.getContext(), 
                    Manifest.permission.BLUETOOTH) == PackageManager.PERMISSION_GRANTED;
                boolean bluetoothAdmin = ContextCompat.checkSelfPermission(cordova.getContext(), 
                    Manifest.permission.BLUETOOTH_ADMIN) == PackageManager.PERMISSION_GRANTED;
                bluetoothPermission = bluetooth && bluetoothAdmin;
                
                if (bluetooth && bluetoothAdmin) {
                    permissionStatus = "granted";
                } else {
                    permissionStatus = "denied";
                }
            }

            JSONObject jsonObject = new JSONObject();
            jsonObject.put("BLUETOOTH_PERMISSION", bluetoothPermission);
            jsonObject.put("BLUETOOTH_STATUS", permissionStatus);

            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, jsonObject));
        } catch (Exception e) {
            e.printStackTrace();
            callbackContext.error("Error al verificar permisos: " + e.getMessage());
        }
    }

    private void requestPermission(String[] permissions, CallbackContext callbackContext) {
        try {
            this.requestPermissionCallback = callbackContext;
            requestPermissionLauncher.launch(permissions);
            Log.d(TAG, "RequestPermission Launched");
        } catch (Exception e) {
            e.printStackTrace();
            callbackContext.error(e.getMessage());
        }
    }

    @CordovaMethod(WORKER)
    private void checkLocationPermission(CordovaArgs args, CallbackContext callbackContext) {
        try {
            boolean accessFineLocation = ContextCompat.checkSelfPermission(cordova.getContext(), Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED;
            boolean accessCoarseLocation = ContextCompat.checkSelfPermission(cordova.getContext(), Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED;
            boolean accessBackgroundLocation = false;
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
                accessBackgroundLocation = ContextCompat.checkSelfPermission(cordova.getContext(), Manifest.permission.ACCESS_BACKGROUND_LOCATION) == PackageManager.PERMISSION_GRANTED;
            }

            JSONObject jsonObject = new JSONObject();
            jsonObject.put("ACCESS_FINE_LOCATION", accessFineLocation);
            jsonObject.put("ACCESS_COARSE_LOCATION", accessCoarseLocation);
            jsonObject.put("ACCESS_BACKGROUND_LOCATION", accessBackgroundLocation);

            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, jsonObject));
        } catch (Exception e) {
            e.printStackTrace();
            callbackContext.error(e.getMessage());
        }
    }

    @CordovaMethod(WORKER)
    private void openURL(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
        String action = args.isNull(0) ?
                "android.settings.APPLICATION_DETAILS_SETTINGS"
                :args.getString(0);
        Uri uri = args.isNull(1) ?
                Uri.parse("package:" + this.cordova.getActivity().getPackageName())
                :Uri.parse(args.getString(1));
        Intent intent = new Intent(action, uri);
        this.cordova.getActivity().startActivity(intent);
        callbackContext.success();
    }

    @CordovaMethod(WORKER)
    private void shouldShowRequestPermissionRationale(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
        if (args.isNull(0)) {
            callbackContext.error("Invalid args");
            return;
        }
        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK,
                ActivityCompat.shouldShowRequestPermissionRationale(cordova.getActivity(),
                        args.getString(0))));
    }
}
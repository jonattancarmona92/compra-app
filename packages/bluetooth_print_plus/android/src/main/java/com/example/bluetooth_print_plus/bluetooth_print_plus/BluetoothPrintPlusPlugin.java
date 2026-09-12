package com.example.bluetooth_print_plus.bluetooth_print_plus;

import static android.bluetooth.BluetoothDevice.DEVICE_TYPE_LE;

import static androidx.core.app.ActivityCompat.startActivityForResult;

import android.Manifest;
import android.app.Activity;
import android.app.Application;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;

import androidx.annotation.RequiresApi;

import com.example.bluetooth_print_plus.bluetooth_print_plus.payload.BPPState;
import com.example.bluetooth_print_plus.bluetooth_print_plus.payload.BluetoothParameter;
import com.example.bluetooth_print_plus.bluetooth_print_plus.payload.Printer;
import com.example.bluetooth_print_plus.bluetooth_print_plus.payload.ThreadPoolManager;
import com.gprinter.bean.PrinterDevices;
import com.gprinter.io.PortManager;
import com.gprinter.utils.CallbackListener;
import com.gprinter.utils.Command;
import com.gprinter.utils.LogUtils;
import com.gprinter.utils.ConnMethod;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.*;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener;
import pub.devrel.easypermissions.EasyPermissions;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/**
 * BluetoothPrintPlusPlugin
 *
 * @author amoLink
 */
public class BluetoothPrintPlusPlugin
        implements FlutterPlugin, ActivityAware, MethodCallHandler, RequestPermissionsResultListener {
  private static final String TAG = "BluetoothPrintPlusPlugin";
  private static final int REQUEST_LOCATION_PERMISSIONS = 1452;
  private final Object initializationLock = new Object();
  private Context context;
  private Activity activity;
  private Result pendingResult;
  // Bandera: `true` solo mientras ESTE plugin espera el resultado de una
  // solicitud de permisos que él mismo inició. El request code 1452 es
  // compartido con otros plugins (p. ej. permission_handler), así que sin
  // este guardián el plugin responde (o crashea) por resultados ajenos.
  private boolean permissionRequestPending = false;
  public PortManager portManager = null;
  private BluetoothAdapter mBluetoothAdapter;

  private FlutterPluginBinding pluginBinding;
  private ActivityPluginBinding activityBinding;
  private MethodChannel channel;
  private EventSink sink;
  private MethodChannel tscChannel;
  private MethodChannel cpclChannel;
  private MethodChannel escChannel;
  private EventChannel stateChannel;
  private final TscCommandPlugin tscCommandPlugin = new TscCommandPlugin();
  private final CpclCommandPlugin cpclCommandPlugin = new CpclCommandPlugin();
  private final EscCommandPlugin escCommandPlugin = new EscCommandPlugin();

  public BluetoothPrintPlusPlugin() {}

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    pluginBinding = binding;
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    pluginBinding = null;
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    activityBinding = binding;
    setup(
            pluginBinding.getBinaryMessenger(),
            (Application) pluginBinding.getApplicationContext(),
            activityBinding.getActivity(),
            activityBinding
    );
  }

  @Override
  public void onDetachedFromActivity() {
    tearDown();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  private void setup(
          final BinaryMessenger messenger,
          final Application application,
          final Activity activity,
          final ActivityPluginBinding activityBinding
  ) {
    synchronized (initializationLock) {
      LogUtils.i(TAG, "setup");
      this.activity = activity;
      this.context = application;
      channel = new MethodChannel(messenger, "bluetooth_print_plus/methods");
      channel.setMethodCallHandler(this);
      // tsc Channel
      tscChannel = new MethodChannel(messenger, "bluetooth_print_plus_tsc");
      tscCommandPlugin.setUpChannel(tscChannel);
      // cpcl Channel
      cpclChannel = new MethodChannel(messenger, "bluetooth_print_plus_cpcl");
      cpclCommandPlugin.setUpChannel(cpclChannel);
      // esc Channel
      escChannel = new MethodChannel(messenger, "bluetooth_print_plus_esc");
      escCommandPlugin.setUpChannel(escChannel);
      // state Channel
      stateChannel = new EventChannel(messenger, "bluetooth_print_plus/state");
      stateChannel.setStreamHandler(stateHandler);
      mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

      activityBinding.addRequestPermissionsResultListener(this);
      initBroadcast();
    }
  }

  private void tearDown() {
    LogUtils.i(TAG, "teardown");
    context.unregisterReceiver(mFindBlueToothReceiver);
    context = null;
    activityBinding.removeRequestPermissionsResultListener(this);
    activityBinding = null;
    channel.setMethodCallHandler(null);
    channel = null;
    stateChannel.setStreamHandler(null);
    stateChannel = null;
    mBluetoothAdapter = null;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (mBluetoothAdapter == null && !"isAvailable".equals(call.method)) {
      result.error("bluetooth_unavailable", "the device does not have bluetooth", null);
      return;
    }
    switch (call.method) {
      case "state":
        state(result);
        break;
      case "startScan":
        startScan(result);
        break;
      case "stopScan":
        stopScan();
        result.success(null);
        break;
      case "connect":
        Map<String, Object> args = call.arguments();
        assert args != null;
        final String address = (String) args.get("address");
        stopScan();
        connect(address);
        result.success(null);
        break;
      case "disconnect":
        Printer.close();
        // El SDK G-Printer no notifica el cierre del socket: sin este evento
        // la app quedaría para siempre en "Conectando..." tras pulsar
        // Desconectar. Se emite aquí el estado real.
        if (sink != null) sink.success(BPPState.DeviceDisconnected.getValue());
        result.success(null);
        break;
      case "write":
        byte[] bytes = call.argument("data");
        try {
          boolean enviado = write(bytes);
          // Un envío exitoso al socket confirma que la impresora está
          // operativa: re-sincroniza el estado en Dart incluso si el evento
          // `connected` se emitió con el canal aún sin suscriptores.
          if (enviado && sink != null) {
            sink.success(BPPState.DeviceConnected.getValue());
          }
          result.success(enviado);
        } catch (IOException e) {
          result.error("write", e.getMessage(), null);
        }
        break;
      case "bondedDevices":
        bondedDevices(result);
        break;
      case "setBluetoothEnabled":
        Boolean habilitar = call.argument("enable");
        setBluetoothEnabled(result, habilitar != null && habilitar);
        break;
      case "isPrinterConnected":
        isPrinterConnected(result);
        break;
      case "openBluetoothSettings":
        openBluetoothSettings(result);
        break;
      case "removeBondedDevice":
        String mac = call.argument("address");
        removeBondedDevice(result, mac);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void initBroadcast() {
    try {
      IntentFilter filter = new IntentFilter();
      filter.addAction(BluetoothDevice.ACTION_FOUND);
      filter.addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED);
      context.registerReceiver(mFindBlueToothReceiver, filter);
    } catch (Exception ignored) {

    }
  }

  private final BroadcastReceiver mFindBlueToothReceiver = new BroadcastReceiver() {
    @Override
    public void onReceive(Context context, Intent intent) {
      String action = intent.getAction();
      if (BluetoothDevice.ACTION_FOUND.equals(action)) {
        BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
        if (device == null || device.getName() == null) return;
        if (device.getType() == DEVICE_TYPE_LE) return;
        BluetoothParameter parameter = new BluetoothParameter();
        int rssi = Objects.requireNonNull(intent.getExtras()).getShort(BluetoothDevice.EXTRA_RSSI);
        parameter.setBluetoothName(device.getName());
        parameter.setBluetoothMac(device.getAddress());
        parameter.setBluetoothStrength(rssi + "");
        LogUtils.i(TAG, "\nBlueToothName: " + device.getName() + "\nMacAddress: " + device.getAddress() + "\nrssi: " + rssi);
        invokeMethodUIThread(device);
      }
    }
  };

  private void state(Result result) {
    try {
      switch (mBluetoothAdapter.getState()) {
        case BluetoothAdapter.STATE_OFF:
          result.success(BPPState.BlueOff.getValue());
          break;
        case BluetoothAdapter.STATE_ON:
          result.success(BPPState.BlueOn.getValue());
          break;
        default:
          break;
      }
    } catch (SecurityException e) {
      result.error("invalid_argument", "argument 'address' not found", null);
    }
  }

  private void startScan(Result result) {
    LogUtils.i(TAG, "start scan...");
    try {
      // Requisitos por versión de Android, alineados con la guía oficial:
      // API 31+ (BLUETOOTH_SCAN con neverForLocation + BLUETOOTH_CONNECT)
      // no necesita ubicación; API <=30 el descubrimiento clásico exige
      // ACCESS_FINE_LOCATION. Antes el set incluía ACCESS_FINE_LOCATION en
      // todas las versiones, forzando un diálogo extra y fallos en ≥31.
      String[] perms;
      if (Build.VERSION.SDK_INT >= 31) {
        perms = new String[] {
            Manifest.permission.BLUETOOTH_CONNECT,
            Manifest.permission.BLUETOOTH_SCAN,
        };
      } else {
        perms = new String[] {
            Manifest.permission.BLUETOOTH_ADMIN,
            Manifest.permission.ACCESS_FINE_LOCATION,
        };
      }
      if (EasyPermissions.hasPermissions(this.context, perms)) {
        // Already have permission, do the thing
        startScan();
      } else {
        // Do not have permissions, request them now
        permissionRequestPending = true;
        EasyPermissions.requestPermissions(
                this.activity,
                "Bluetooth requires location permission!!!",
                REQUEST_LOCATION_PERMISSIONS,
                perms);
      }
      result.success(null);
    } catch (Exception e) {
      result.error("startScan", e.getMessage(), e);
    }
  }

  private void invokeMethodUIThread(BluetoothDevice device) {
    final Map<String, Object> ret = new HashMap<>();
    ret.put("address", device.getAddress());
    ret.put("name", device.getName());
    ret.put("type", device.getType());
    new Handler(Looper.getMainLooper()).post(() -> {
      if (!ret.isEmpty()) {
        channel.invokeMethod("ScanResult", ret);
      } else {
        LogUtils.w(TAG, "invokeMethodUIThread: tried to call method on closed channel: " + "ScanResult");
      }
    });
  }

  private void startScan() throws IllegalStateException {
    mBluetoothAdapter.startDiscovery();
  }

  private void stopScan() {
    mBluetoothAdapter.cancelDiscovery();
  }

  /// Dispositivos Bluetooth ya vinculados con el teléfono (no requieren
  /// escaneo). Necesita BLUETOOTH_CONNECT en API 31+, BLUETOOTH en el resto.
  /// Nunca fuerza a abrir un diálogo: si faltan permisos retorna el error
  /// `bluetooth_permisos` y es la pantalla quien los solicita.
  private void bondedDevices(Result result) {
    try {
      Set<BluetoothDevice> vinculados = mBluetoothAdapter.getBondedDevices();
      List<Map<String, Object>> lista = new ArrayList<>();
      for (BluetoothDevice d : vinculados) {
        Map<String, Object> m = new HashMap<>();
        m.put("address", d.getAddress());
        m.put("name", d.getName() == null ? "" : d.getName());
        m.put("type", d.getType());
        lista.add(m);
      }
      result.success(lista);
    } catch (SecurityException e) {
      result.error("bluetooth_permisos", e.getMessage(), null);
    } catch (Exception e) {
      result.error("bondedDevices", e.getMessage(), null);
    }
  }

  /// Intenta encender/apagar el adaptador. API 31+ deprecó `enable()`:
  /// en muchos equipos el sistema lo bloquea para apps de terceros y devuelve
  /// `false` aunque no lance excepción; la pantalla recalcula el estado real
  /// leyendo el adaptador y, si no cambió, orienta al usuario a los ajustes.
  private void setBluetoothEnabled(Result result, boolean habilitar) {
    try {
      if (habilitar) {
        result.success(mBluetoothAdapter.enable());
      } else {
        result.success(mBluetoothAdapter.disable());
      }
    } catch (SecurityException e) {
      result.error("bluetooth_permisos", e.getMessage(), null);
    } catch (Exception e) {
      result.error("setBluetoothEnabled", e.getMessage(), null);
    }
  }

  /// Estado real del socket SPP: `true` si el puerto está abierto en este
  /// momento, independientemente de si el evento `connected` llegó a Dart
  /// (puede perderse en el primer arranque o al recrearse la actividad).
  /// Es la fuente veraz con la que la pantalla evita mostrar "Desconectada"
  /// cuando la impresora ya está operativa.
  private void isPrinterConnected(Result result) {
    try {
      PortManager pm = Printer.getPortManager();
      result.success(pm != null && pm.getConnectStatus());
    } catch (Exception e) {
      result.error("isPrinterConnected", e.getMessage(), null);
    }
  }

  /// Abre los ajustes Bluetooth del sistema (fallback cuando la app no
  /// puede encender/apagar el adaptador por sí misma).
  private void openBluetoothSettings(Result result) {
    try {
      Intent intent = new Intent(Settings.ACTION_BLUETOOTH_SETTINGS);
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      context.startActivity(intent);
      result.success(true);
    } catch (Exception e) {
      result.success(false);
    }
  }

  /// Desvincula (elimina) un dispositivo del listado del teléfono.
  private void removeBondedDevice(Result result, String mac) {
    if (mac == null || mac.isEmpty()) {
      result.error("removeBondedDevice", "address vacío", null);
      return;
    }
    try {
      BluetoothDevice d = mBluetoothAdapter.getRemoteDevice(mac);
      result.success(removeBondViaReflexion(d));
    } catch (SecurityException e) {
      result.error("bluetooth_permisos", e.getMessage(), null);
    } catch (Exception e) {
      result.error("removeBondedDevice", e.getMessage(), null);
    }
  }

  /// `removeBond()` se ocultó del SDK público (API 33+): se invoca por
  /// reflexión, que es la práctica estándar para desvincular dispositivos.
  private boolean removeBondViaReflexion(BluetoothDevice d) {
    try {
      java.lang.reflect.Method metodo = d.getClass().getMethod("removeBond");
      return Boolean.TRUE.equals(metodo.invoke(d));
    } catch (Exception e) {
      LogUtils.w(TAG, "removeBond por reflexión falló: " + e.getMessage());
      return false;
    }
  }

  public void connect(final String mac) {
    if (mac == null) {
      connectViaGprinter(null);
      return;
    }
    // Impresoras como la PT-210/MTP-II exigen vínculo (bond) con código de
    // vinculación (0000). Si el dispositivo aún no está emparejado, primero
    // se crea el vínculo y se espera a que el sistema lo confirme antes de
    // abrir el socket SPP; si el socket se abre antes, expira mientras el
    // usuario ingresa el PIN y la conexión falla.
    final BluetoothDevice device;
    try {
      device = mBluetoothAdapter.getRemoteDevice(mac);
    } catch (Exception e) {
      LogUtils.w(TAG, "mac inválida: " + mac);
      return;
    }
    if (device.getBondState() != BluetoothDevice.BOND_BONDED) {
      LogUtils.i(TAG, "creando vínculo con " + mac);
      final IntentFilter bondFilter =
          new IntentFilter(BluetoothDevice.ACTION_BOND_STATE_CHANGED);
      final BroadcastReceiver[] receptor = new BroadcastReceiver[1];
      receptor[0] = new BroadcastReceiver() {
        @Override
        public void onReceive(Context ctx, Intent intent) {
          BluetoothDevice extra =
              intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
          if (extra == null || !device.equals(extra)) return;
          final int estado =
              intent.getIntExtra(BluetoothDevice.EXTRA_BOND_STATE, -1);
          if (estado == BluetoothDevice.BOND_BONDED) {
            LogUtils.i(TAG, "vínculo confirmado, conectando a " + mac);
            try { ctx.unregisterReceiver(receptor[0]); } catch (Exception ignored) {}
            // Xiaomi/MIUI necesita unos segundos tras confirmar el vínculo
            // antes de aceptar el socket SPP: conectarlo en el acto termina
            // colgado en SocketState INIT. Se espera y luego se abre.
            new Handler(Looper.getMainLooper()).postDelayed(
                () -> connectViaGprinter(mac), 3000);
          } else if (estado == BluetoothDevice.BOND_NONE) {
            LogUtils.w(TAG, "vínculo cancelado o fallido con " + mac);
            try { ctx.unregisterReceiver(receptor[0]); } catch (Exception ignored) {}
            // El vínculo no se completó: se notifica para que la pantalla
            // salga de "Conectando..." de inmediato y oriente al usuario
            // (código 0000, impresora encendida, etc.).
            if (sink != null) sink.success(BPPState.DeviceDisconnected.getValue());
          }
        }
      };
      try {
        context.registerReceiver(receptor[0], bondFilter);
      } catch (Exception e) {
        LogUtils.w(TAG, "no se pudo registrar el receptor de vínculo");
      }
      try {
        device.createBond();
      } catch (Exception e) {
        LogUtils.w(TAG, "createBond falló, se intenta conectar igual");
        connectViaGprinter(mac);
      }
    } else {
      LogUtils.i(TAG, "dispositivo ya vinculado, conectando a " + mac);
      connectViaGprinter(mac);
    }
  }

  private void connectViaGprinter(final String mac) {
    ThreadPoolManager.getInstance().addTask(new Runnable() {
      @Override
      public void run() {
        if (portManager != null) {
          portManager.closePort();
          try {
            // Espera amplia: cerrar un socket colgado en INIT y reabrir al
            // instante deja al adaptador MIUI en mal estado.
            Thread.sleep(1500);
          } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
          }
        }
        if (mac != null) {
          PrinterDevices blueTooth = new PrinterDevices.Build()
                  .setContext(context)
                  .setConnMethod(ConnMethod.BLUETOOTH)
                  .setMacAddress(mac)
                  .setCommand(Command.ESC)
                  .setCallbackListener(new CallbackListener() {
                    @Override
                    public void onConnecting() { }

                    @Override
                    public void onCheckCommand() { }

                    @Override
                    public void onSuccess(PrinterDevices printerDevices) {
                      LogUtils.i(TAG, "onSuccess para " + mac);
                      if (sink != null) sink.success(BPPState.DeviceConnected.getValue());
                    }

                    @Override
                    public void onReceive(byte[] data) {
                      if (data == null) return;
                      // LogUtils.d(TAG, "Received Data: " + Arrays.toString(data));
                      new Handler(Looper.getMainLooper()).post(() -> {
                        channel.invokeMethod("ReceivedData", data);
                      });
                    }

                    @Override
                    public void onFailure() {
                      LogUtils.e(TAG, "onFailure para " + mac);
                      if (sink != null) sink.success(BPPState.DeviceDisconnected.getValue());
                    }

                    @Override
                    public void onDisconnect() {
                      LogUtils.e(TAG, "onDisconnect para " + mac);
                      if (sink != null) sink.success(BPPState.DeviceDisconnected.getValue());
                    }
                  })
                  .build();
          // Si el SDK lanza al iniciar la conexión (p. ej. el nivel de luz
          // estado de la impresora no responde), se reporta como fallo para
          // que la app no se quede "Conectando..." para siempre. El socket
          // cuelga con frecuencia en Xiaomi/MIUI; la pantalla reintenta.
          try {
            Printer.connect(blueTooth);
          } catch (Throwable t) {
            LogUtils.e(TAG, "Printer.connect falló: " + t.toString());
            if (sink != null) sink.success(BPPState.DeviceDisconnected.getValue());
          }
          // Verificación diferida del socket: algunos firmwares abren el
          // puerto pero el SDK no llega a emitir `onSuccess` (o el evento se
          // emite con el canal sin suscriptores). Si el puerto quedó abierto
          // poco después, se confirma la conexión para que la app no se
          // quede "Desconectada" con la impresora operativa.
          new Handler(Looper.getMainLooper()).postDelayed(() -> {
            PortManager pm = Printer.getPortManager();
            if (pm != null && pm.getConnectStatus() && sink != null) {
              LogUtils.i(TAG, "socket abierto confirmado para " + mac);
              sink.success(BPPState.DeviceConnected.getValue());
            }
          }, 2500);
        }
      }
    });
  }

  @SuppressWarnings("unchecked")
  private boolean write(byte[] data) throws IOException {
    boolean result = Printer.getPortManager().writeDataImmediately(data);
    LogUtils.d(TAG, result ? "发送成功": "发送失败");
    return result;
  }

  @Override
  public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
    LogUtils.d(TAG, "onRequestPermissionsResult: requestCode=" + requestCode
        + ", pending=" + permissionRequestPending
        + ", granted=" + (grantResults != null && grantResults.length > 0
            && grantResults[0] == PackageManager.PERMISSION_GRANTED));
    if (requestCode != REQUEST_LOCATION_PERMISSIONS || !permissionRequestPending) {
      // Este request code (1452) también lo usa permission_handler: si el
      // resultado no fue iniciado por este plugin, se ignora y se devuelve
      // false. Sin esto el plugin respondía con `pendingResult` (null) y
      // la app moría con NullPointerException al entregar el resultado.
      return false;
    }
    permissionRequestPending = false;
    if (grantResults != null && grantResults.length > 0
        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
      startScan();
    } else {
      LogUtils.d(TAG, "permission denied, skipping startScan");
    }
    return true;
  }

  private final StreamHandler stateHandler = new StreamHandler() {
    // private EventSink sink;
    private final BroadcastReceiver mReceiver = new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        final String action = intent.getAction();
        // LogUtils.d(TAG, "stateStreamHandler, current action: " + action);
        if (BluetoothAdapter.ACTION_STATE_CHANGED.equals(action)) {
          int blueState = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, 0);
          switch (blueState) {
            case BluetoothAdapter.STATE_ON:
              sink.success(BPPState.BlueOn.getValue());
              break;
            case BluetoothAdapter.STATE_OFF:
              sink.success(BPPState.BlueOff.getValue());
              break;
          }
        }
      }
    };

    @Override
    public void onListen(Object o, EventSink eventSink) {
      sink = eventSink;
      IntentFilter filter = new IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED);
      context.registerReceiver(mReceiver, filter);
    }

    @Override
    public void onCancel(Object o) {
      sink = null;
      context.unregisterReceiver(mReceiver);
    }
  };
}


package ui.apptour;

import android.app.Activity;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.graphics.Color;
import android.util.Log;
import android.support.annotation.Nullable;

import com.facebook.common.internal.Objects;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactContext;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;

import com.facebook.react.modules.core.DeviceEventManagerModule;

import ui.apptour.taptargetview.TapTargetSequence;
import ui.apptour.taptargetview.TapTargetView;
import ui.apptour.taptargetview.TapTarget;

import java.util.ArrayList;
import java.util.List;


public class RNAppTourModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;

  public RNAppTourModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNAppTour";
  }

  private void sendEvent(ReactContext reactContext,
                         String eventName,
                         @Nullable WritableMap params) {
      reactContext
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
      .emit(eventName, params);
  }

  @ReactMethod
  public void ShowSequence(final ReadableArray views, final ReadableMap props, final Promise promise) {
      final Activity activity = this.getCurrentActivity();
      final List<TapTarget> targetViews = new ArrayList<TapTarget>();

      for (int i = 0;i < views.size();i++) {
          int view = views.getInt(i);
          targetViews.add(this.generateTapTarget(view, props.getMap(String.valueOf(view))));
      }

      this.getCurrentActivity().runOnUiThread(new Runnable() {
          @Override
          public void run() {
              TapTargetSequence tapTargetSequence = new TapTargetSequence(activity).targets(targetViews);
              tapTargetSequence.listener(new TapTargetSequence.Listener() {
                  @Override
                  public void onSequenceFinish() {
                      WritableMap params = Arguments.createMap();
                      params.putBoolean("finish", true);
                      sendEvent(reactContext, "onFinishSequenceEvent", params);
                  }

                  @Override
                  public void onSequenceStep(TapTarget lastTarget, boolean targetClicked) {
                      WritableMap params = Arguments.createMap();
                      params.putBoolean("next_step", true);
                      sendEvent(reactContext, "onShowSequenceStepEvent", params);
                  }

                  @Override
                  public void onSequenceCanceled(TapTarget lastTarget) {
                      WritableMap params = Arguments.createMap();
                      params.putBoolean("cancel_step", true);
                      sendEvent(reactContext, "onCancelStepEvent", params);
                  }
              })
              .continueOnCancel(true);
              tapTargetSequence.start();
          }
      });

  }

  @ReactMethod
  public void ShowFor(final int view, final ReadableMap props, final Promise promise) {
      final Activity activity = this.getCurrentActivity();
      final TapTarget targetView = generateTapTarget(view, props);

      this.getCurrentActivity().runOnUiThread(new Runnable() {
          @Override
          public void run() {
            TapTargetView.showFor(activity, targetView);
          }
    });
  }

  private TapTarget generateTapTarget(final int view, final ReadableMap props) {
    final Activity activity = this.getCurrentActivity();

    final String title = props.getString("title");
    final String description = props.getString("description");

    String buttonTitle;
    String outerCircleColor = null;
    String targetCircleColor = null;
    String titleTextColor = null;
    String descriptionTextColor = null;
    String textColor = null;
    String dimColor = null;

    //Other Props
    float outerCircleAlpha = 0.96f;
    int titleTextSize = 20;
    int descriptionTextSize = 10;
    boolean drawShadow = true;
    boolean cancelable = true;
    boolean tintTarget = false;
    boolean transparentTarget = false;
    int targetRadius = 60;

    String buttonTextColor = null;
    String buttonBGColor = null;
    int buttonRadius = 16;
    boolean buttonVisable = true;
    int buttonTextSize = 8;

    if (props.hasKey("outerCircleColor") && !props.isNull("outerCircleColor")) {
      outerCircleColor = props.getString("outerCircleColor");
    }
    if (props.hasKey("targetCircleColor") && !props.isNull("targetCircleColor")) {
      targetCircleColor = props.getString("targetCircleColor");
    }
    if (props.hasKey("titleTextColor") && !props.isNull("titleTextColor")) {
      titleTextColor = props.getString("titleTextColor");
    }
    if (props.hasKey("descriptionTextColor") && !props.isNull("descriptionTextColor")) {
      descriptionTextColor = props.getString("descriptionTextColor");
    }
    if (props.hasKey("textColor") && !props.isNull("textColor")) {
      textColor = props.getString("textColor");
    }
    if (props.hasKey("dimColor") && !props.isNull("dimColor")) {
      dimColor = props.getString("dimColor");
    }
    if (props.hasKey("buttonTextColor") && !props.isNull("buttonTextColor")) {
      buttonTextColor = props.getString("buttonTextColor");
    }
    if (props.hasKey("buttonBGColor") && !props.isNull("buttonBGColor")) {
      buttonBGColor = props.getString("buttonBGColor");
    }

    try { outerCircleAlpha = Float.valueOf(props.getString("outerCircleAlpha")); } catch (Exception e) {}
    try { titleTextSize = Integer.valueOf(props.getString("titleTextSize")); } catch (Exception e) {}
    try { descriptionTextSize = Integer.valueOf(props.getString("descriptionTextSize")); } catch (Exception e) {}
    try { drawShadow = Boolean.valueOf(props.getString("drawShadow")); } catch (Exception e) {}
    try { cancelable = Boolean.valueOf(props.getString("cancelable")); } catch (Exception e) {}
    try { tintTarget = Boolean.valueOf(props.getString("tintTarget")); } catch (Exception e) {}
    try { transparentTarget = Boolean.valueOf(props.getString("transparentTarget")); } catch (Exception e) {}
    try { targetRadius = Integer.valueOf(props.getString("targetRadius")); } catch (Exception e) {}
    try { buttonRadius = Integer.valueOf(props.getString("buttonRadius")); } catch (Exception e) {}
    try { buttonVisable = Boolean.valueOf(props.getString("buttonVisable")); } catch (Exception e) {}
    try { buttonTitle = props.getString("buttonText");} catch (Exception e) {buttonTitle = "OK";}
    try { buttonTextSize = Integer.valueOf(props.getString("buttonTextSize")); } catch (Exception e) {}


    float finalOuterCircleAlpha = outerCircleAlpha;
    int finalTitleTextSize = titleTextSize;
    int finalDescriptionTextSize = descriptionTextSize;
    boolean finalDrawShadow = drawShadow;
    boolean finalCancelable = cancelable;
    boolean finalTintTarget = tintTarget;
    boolean finalTransparentTarget = transparentTarget;
    int finalTargetRadius = targetRadius;


    //Populate Props
    TapTarget targetView = TapTarget.forView(activity.findViewById(view), title, description, buttonTitle);

    if (outerCircleColor != null && outerCircleColor.length() > 0) targetView.outerCircleColorInt(Color.parseColor(outerCircleColor));
    if (targetCircleColor != null && targetCircleColor.length() > 0) targetView.targetCircleColorInt(Color.parseColor(targetCircleColor));
    if (titleTextColor != null && titleTextColor.length() > 0) targetView.titleTextColorInt(Color.parseColor(titleTextColor));
    if (descriptionTextColor != null && descriptionTextColor.length() > 0) targetView.descriptionTextColorInt(Color.parseColor(descriptionTextColor));
    if (textColor != null && textColor.length() > 0) targetView.textColorInt(Color.parseColor(textColor));
    if (dimColor != null && dimColor.length() > 0) targetView.dimColorInt(Color.parseColor(dimColor));
    if (buttonVisable) {
      targetView.buttonVisible(true);
      if (buttonBGColor != null && buttonBGColor.length() > 0) targetView.buttonBGColorInt(Color.parseColor(buttonBGColor));
      if (buttonTextColor != null && buttonTextColor.length() > 0) targetView.buttonTextColorInt(Color.parseColor(buttonTextColor));
      targetView.cornersRadius(buttonRadius);
      targetView.buttonTextSize(buttonTextSize);
    } else {
      targetView.buttonVisible(false);
    }
    
    targetView.outerCircleAlpha(finalOuterCircleAlpha);
    targetView.titleTextSize(finalTitleTextSize);
    targetView.descriptionTextSize(finalDescriptionTextSize);
    targetView.drawShadow(finalDrawShadow);
    targetView.cancelable(finalCancelable);
    targetView.tintTarget(finalTintTarget);
    targetView.transparentTarget(finalTransparentTarget);
    targetView.targetRadius(finalTargetRadius);
    

    return targetView;
 }
}

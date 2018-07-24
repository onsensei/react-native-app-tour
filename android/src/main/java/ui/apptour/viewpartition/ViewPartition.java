package ui.apptour.viewpartition;

import android.app.Activity;
import android.view.View;
import android.view.ViewGroup;

public class ViewPartition {

    private static View partitionView;

    private static void initIfNeed(Activity activity) {
        if (partitionView == null) {
            partitionView = new View(activity);
            partitionView.setBackgroundColor(0x00000000);
            partitionView.setClickable(true);
        }
    }

    public static void showViewPartition(Activity activity) {
        if (activity == null) throw new IllegalArgumentException("Activity is null");

        ViewPartition.initIfNeed(activity);

        ViewGroup decor = (ViewGroup) activity.getWindow().getDecorView();
        int childIndex = decor.indexOfChild(partitionView);
        boolean isShowed = (childIndex >= 0);

        if (!isShowed) {
            ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
            decor.addView(partitionView, layoutParams);
        }
    }

    public static void hideViewPartition(Activity activity) {
        if (activity == null) throw new IllegalArgumentException("Activity is null");

        ViewPartition.initIfNeed(activity);

        ViewGroup decor = (ViewGroup) activity.getWindow().getDecorView();
        int childIndex = decor.indexOfChild(partitionView);
        boolean isShowed = (childIndex >= 0);

        if (isShowed) {
            decor.removeView(partitionView);
        }
    }
}
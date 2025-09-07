package com.printer;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ColorMatrix;
import android.graphics.ColorMatrixColorFilter;
import android.graphics.Paint;
import android.text.Layout;
import android.util.Log;

import androidx.annotation.Keep;

import com.zcs.sdk.DriverManager;
import com.zcs.sdk.Printer;
import com.zcs.sdk.SdkResult;
import com.zcs.sdk.Sys;
import com.zcs.sdk.print.PrnStrFormat;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Objects;

@Keep
public class PrinterService {
    private static final String TAG = "PrinterService";

    // Custom error codes
    private static final int ERROR_INVALID_INPUT = -1;
    private static final int ERROR_BITMAP_DECODE = -2;
    private static final int ERROR_GENERAL_EXCEPTION = -3;
    private static final int ERROR_DEVICE_CONNECTION = -1001;
    private static final int ERROR_PRINTER_POWER = -4;
    private static final int ERROR_PRINTER_WIDTH_UNKNOWN = -5;

    private static PrinterService instance;
    private DriverManager mDriverManager;
    private Printer mPrinter;
    private Sys mSys;

    private boolean isInitialized = false;
    private int printerWidth = 384; // default for 58mm

    private PrinterService() {}

    public static synchronized PrinterService getInstance() {
        if (instance == null) {
            instance = new PrinterService();
        }
        return instance;
    }

    public int initializePrinter() {
        try {
            mDriverManager = DriverManager.getInstance();
            if (mDriverManager == null) {
                Log.e(TAG, "DriverManager instance is null");
                return ERROR_DEVICE_CONNECTION;
            }

            mSys = mDriverManager.getBaseSysDevice();
            mPrinter = mDriverManager.getPrinter();

            if (mPrinter == null || mSys == null) {
                Log.e(TAG, "Printer or Sys instance is null");
                return ERROR_DEVICE_CONNECTION;
            }

            // Init SDK
            int status = mSys.sdkInit();
            if (status != SdkResult.SDK_OK) {
                Log.e(TAG, "SDK init failed: " + status);
                return ERROR_PRINTER_POWER;
            }

            printerWidth = 384; // assume 58mm by default
            Log.i(TAG, "Printer initialized, width = " + printerWidth);

            isInitialized = true;
            return SdkResult.SDK_OK;

        } catch (Exception e) {
            Log.e(TAG, "Error initializing printer", e);
            return ERROR_GENERAL_EXCEPTION;
        }
    }

    public int printNow(byte[] imageData) {
        if (imageData == null || imageData.length == 0) {
            Log.e(TAG, "Invalid image data");
            return ERROR_INVALID_INPUT;
        }

        if (!isInitialized) {
            int result = initializePrinter();
            if (result != SdkResult.SDK_OK) return result;
            if (printerWidth <= 0) {
                Log.e(TAG, "Printer width is invalid or not initialized.");
                return ERROR_PRINTER_WIDTH_UNKNOWN;
            }
        }

        try (InputStream inputStream = new ByteArrayInputStream(imageData)) {
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inScaled = false;
            Bitmap bitmap = BitmapFactory.decodeStream(inputStream, null, options);
            if (bitmap == null) {
                Log.e(TAG, "Failed to decode image");
                return ERROR_BITMAP_DECODE;
            }

            Bitmap resized = resizeToPrinterWidth(bitmap, printerWidth);
            bitmap.recycle();

            Bitmap grayscale = toSimpleGrayscale(resized);
            if (grayscale != resized) resized.recycle();

            Bitmap thresholded = applySimpleThreshold(grayscale);
            if (thresholded != grayscale) grayscale.recycle();

            int status = mPrinter.getPrinterStatus();
            if (status == SdkResult.SDK_PRN_STATUS_PAPEROUT) {
                Log.e(TAG, "Printer out of paper");
                thresholded.recycle();
                return status;
            }

            // Append and print
            PrnStrFormat format = new PrnStrFormat();
            mPrinter.setPrintAppendBitmap(thresholded, Layout.Alignment.ALIGN_CENTER);
            mPrinter.setPrintAppendString(" ", format);

            int printResult = mPrinter.setPrintStart();
            thresholded.recycle();
            return printResult;

        } catch (IOException e) {
            Log.e(TAG, "IO error during printing", e);
            return ERROR_GENERAL_EXCEPTION;
        } catch (Exception e) {
            Log.e(TAG, "Unexpected error during printing", e);
            return ERROR_GENERAL_EXCEPTION;
        }
    }

    private Bitmap toSimpleGrayscale(Bitmap bmpOriginal) {
        int width = bmpOriginal.getWidth();
        int height = bmpOriginal.getHeight();
        Bitmap bmpGrayscale = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        Canvas c = new Canvas(bmpGrayscale);
        ColorMatrix cm = new ColorMatrix();
        cm.setSaturation(0);
        Paint paint = new Paint();
        paint.setColorFilter(new ColorMatrixColorFilter(cm));
        c.drawBitmap(bmpOriginal, 0, 0, paint);
        return bmpGrayscale;
    }

    private Bitmap resizeToPrinterWidth(Bitmap bitmap, int printerWidth) {
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        if (width <= printerWidth) return bitmap;
        float scale = (float) printerWidth / width;
        int newHeight = (int) (height * scale);
        return Bitmap.createScaledBitmap(bitmap, printerWidth, newHeight, true);
    }

    private Bitmap applySimpleThreshold(Bitmap bitmap) {
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        Bitmap output = bitmap.copy(Objects.requireNonNull(bitmap.getConfig()), true);
        int[] pixels = new int[width * height];
        output.getPixels(pixels, 0, width, 0, 0, width, height);
        for (int i = 0; i < pixels.length; i++) {
            int gray = Color.red(pixels[i]);
            int bw = (gray > 160) ? 255 : 0;
            pixels[i] = Color.rgb(bw, bw, bw);
        }
        output.setPixels(pixels, 0, width, 0, 0, width, height);
        return output;
    }
}

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
    
    // Image processing constants
    private static final int GRAYSCALE_THRESHOLD = 128; // Lowered from 160 for better text visibility
    private static final int DEFAULT_PRINTER_WIDTH_58MM = 384;
    private static final int DEFAULT_PRINTER_WIDTH_80MM = 576;

    private static PrinterService instance;
    private DriverManager mDriverManager;
    private Printer mPrinter;
    private Sys mSys;

    private boolean isInitialized = false;
    private int printerWidth = DEFAULT_PRINTER_WIDTH_58MM; // default for 58mm

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

            printerWidth = DEFAULT_PRINTER_WIDTH_58MM; // assume 58mm by default
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
        }

        try (InputStream inputStream = new ByteArrayInputStream(imageData)) {
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inScaled = false;
            Bitmap bitmap = BitmapFactory.decodeStream(inputStream, null, options);
            if (bitmap == null) {
                Log.e(TAG, "Failed to decode image");
                return ERROR_BITMAP_DECODE;
            }

            // Process bitmap with improved memory management
            Bitmap processedBitmap = processImageForPrinting(bitmap);
            bitmap.recycle();

            // Check printer status
            int status = mPrinter.getPrinterStatus();
            Log.i(TAG, "Printer status: " + status);
            
            if (status == SdkResult.SDK_PRN_STATUS_PAPEROUT) {
                Log.e(TAG, "Printer out of paper");
                processedBitmap.recycle();
                return -1002;
            }

            // Append bitmap and text
            PrnStrFormat format = new PrnStrFormat();
            mPrinter.setPrintAppendBitmap(processedBitmap, Layout.Alignment.ALIGN_CENTER);
            mPrinter.setPrintAppendString("\n", format);

            // Start printing
            int printResult = mPrinter.setPrintStart();
            Log.i(TAG, "Print result: " + printResult);
            processedBitmap.recycle();
            
            // Handle specific ZCS SDK error codes
            if (printResult == -1403) {
                Log.e(TAG, "ZCS SDK Error -1403: Printer hardware error or not ready");
            }
            
            return printResult;

        } catch (IOException e) {
            Log.e(TAG, "IO error during printing", e);
            return ERROR_GENERAL_EXCEPTION;
        } catch (Exception e) {
            Log.e(TAG, "Unexpected error during printing", e);
            return ERROR_GENERAL_EXCEPTION;
        }
    }

    /**
     * Process image for printing with optimized memory usage and better contrast
     */
    private Bitmap processImageForPrinting(Bitmap original) {
        // Resize first to reduce memory usage
        Bitmap resized = resizeToPrinterWidth(original);
        
        // Convert to grayscale and apply threshold in one step
        return convertToMonochrome(resized);
    }
    
    private Bitmap resizeToPrinterWidth(Bitmap bitmap) {
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        
        if (width <= printerWidth) {
            return bitmap.copy(Bitmap.Config.RGB_565, false); // Use more memory-efficient format
        }
        
        float scale = (float) printerWidth / width;
        int newHeight = (int) (height * scale);
        return Bitmap.createScaledBitmap(bitmap, printerWidth, newHeight, true);
    }
    
    /**
     * Convert bitmap to monochrome (black and white) with improved contrast
     */
    private Bitmap convertToMonochrome(Bitmap bitmap) {
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        
        // Use RGB_565 for better memory efficiency
        Bitmap monochrome = Bitmap.createBitmap(width, height, Bitmap.Config.RGB_565);
        
        // Process pixels directly for better performance
        for (int y = 0; y < height; y++) {
            for (int x = 0; x < width; x++) {
                int pixel = bitmap.getPixel(x, y);
                
                // Calculate luminance using standard formula
                int gray = (int) (0.299 * Color.red(pixel) + 
                                 0.587 * Color.green(pixel) + 
                                 0.114 * Color.blue(pixel));
                
                // Apply threshold - lowered for better text visibility
                int bw = (gray > GRAYSCALE_THRESHOLD) ? Color.WHITE : Color.BLACK;
                monochrome.setPixel(x, y, bw);
            }
        }
        
        // Recycle the input bitmap if it's different from original
        if (bitmap != null && !bitmap.isRecycled()) {
            bitmap.recycle();
        }
        
        return monochrome;
    }
}
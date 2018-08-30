import java.io.*;
import java.net.*;
    
public static void downloadFromUrl(URL url, String filename, String userAgent) throws IOException {
    InputStream inputStream = null;
    FileOutputStream fileOutputStream = null;

    try {
        urlConnectionection urlConnection = url.openConnection();
        urlConnection.setRequestProperty("User-Agent", userAgent);

        inputStream = urlConnection.getInputStream();
        fileOutputStream = new FileOutputStream(filename);

        byte[] buffer = new byte[1024];
        int length;

        while ((length = inputStream.read(buffer)) > 0)
            fileOutputStream.write(buffer, 0, length);
    } finally {
        if (inputStream != null)
            inputStream.close();
        if (fileOutputStream != null)
            fileOutputStream.close();
    }
}
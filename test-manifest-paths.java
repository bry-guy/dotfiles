import java.util.jar.JarFile;
import java.util.jar.Manifest;
import java.io.IOException;

class Test {  
    public static void main(String args[]) throws IOException {  
        System.out.println("Hello Test");  
        JarFile jarFile = new JarFile(args[0]);
        Manifest manifest = jarFile.getManifest();
        System.out.println("Manifest");  
        System.out.println(manifest.toString());  
    }  
}

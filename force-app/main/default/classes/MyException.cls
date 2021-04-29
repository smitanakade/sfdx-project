public class MyException extends Exception {
    public static void throwException(){
        throw new MyException('Exception'); 
    }
}
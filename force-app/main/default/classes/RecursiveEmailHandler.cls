/*
 * Description : This is a helper class used to prevent recursive sending of emails from the ContentDocumentLinkTrigger trigger. 
 * Ticket: PDS-8770
 * Author: Surajsingh Thakur
 * Date  : 07/05/2019
 */ 

public class RecursiveEmailHandler{
     public static Boolean isFirstEmail = true;
     public static ID caseID;
    
}
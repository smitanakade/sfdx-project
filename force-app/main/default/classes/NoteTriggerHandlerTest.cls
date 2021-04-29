/*
 * This is a test class for ContactTriggerHandler
 * Ticket: SF-5145
 * Author: Ronnie Yang
 */
@isTest
public class NoteTriggerHandlerTest {
    private static testMethod void preventClassicNoteInsertionTest(){
        Note testNote = new Note();
        try{
            insert testNote;
        } catch(Exception e){
            System.assert(e.getMessage().contains('we are saying goodbye to this feature.'));
        }
    }
}
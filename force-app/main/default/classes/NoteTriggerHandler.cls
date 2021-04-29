/*
 * This is the handler class for NoteTrigger
 * Ticket: SF-5145
 * Author: Ronnie Yang
 */ 
public with sharing class NoteTriggerHandler {
    public void onBeforeInsert(List<Note> notes){
        preventClassicNoteInsertion(notes);
    }
    
    /*
	 * Since classic note is being retired, we remind the user to use the enhanced note feature
	 * 
	 */
    private void preventClassicNoteInsertion(List<Note> notes){
        for(Note n : notes){
            n.addError('Don\'t panic! You are currently using what is called \'Classic Note\' and we are saying goodbye to this feature. ' + 
                       'Why not try to the new enhanced notes under the \'Notes\' section. Read about it more here: https://enett-help.force.com/vans/s/article/Adopting-Files-and-Enhanced-Notes');
        }
    }
}
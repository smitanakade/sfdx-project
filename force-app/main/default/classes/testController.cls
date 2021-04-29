public class testController {

    public testController() {
    }

    public PageReference redirect() {
        String userAgent = getUserAgent();

        if(userAgent.contains('Chrome/57')) {
            PageReference pr = Page.oldBrowserFriendlyPage;
            pr.setRedirect(true);
            return pr;
        }
        Return null;
    }

    public String getUserAgent() {
        Return ApexPages.currentPage().getHeaders().get('USER-AGENT');
    }

}
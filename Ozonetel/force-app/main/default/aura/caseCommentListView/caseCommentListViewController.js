({
    onPageReferenceChange: function(cmp, evt, helper) {

        var myPageRef = cmp.get("v.pageReference");
        var title = myPageRef.state.c__title;
        cmp.set("v.title", title);
      
    }
})
({
    init: function(cmp, evt, helper) {
        var myPageRef = cmp.get("v.pageReference");
        var article = myPageRef.state.c__article;
        cmp.set("v.article", article);
    }
})
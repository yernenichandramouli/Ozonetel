({
    
    onChatEnded: function (cmp, evt) {
        const recordId = evt.getParam("recordId");
        const omniAPI = cmp.find("omniToolkit");
        omniAPI
        .getAgentWorks()
        .then(function (result) {
            const works = JSON.parse(result.works);
            for (const work of works) {
                
                if (work.workItemId === recordId) {
                    setTimeout(() => {
                        omniAPI.closeAgentWork({ workId: work.workId });
                }, 90000);
            }
        }
              })
        .catch(function(error) {
            console.error(error);
        });    
    }
});
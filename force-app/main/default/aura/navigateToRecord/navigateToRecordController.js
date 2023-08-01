({
    invoke : function(component) {
    //Get the record ID attribute
    let record = component.get("v.recordId");

    //Get the Lightning event that opens a record in a new tab
    let redirect = $A.get("e.force:navigateToSObject");

    //Pass the record ID to the event
    redirect.setParams({
        "recordId": record
    });

    //Open the record
    redirect.fire();
    }
})

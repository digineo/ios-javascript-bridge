
// CALLS USING A DEFINED APP BRIDGE JS-OBJECT
var App = {
    alert : function alert(title, message) {
        NativeBridge.call( "sakAlert", [title,message], function( didDismiss ){
          if( didDismiss ) {
            document.getElementById('date_field').innerText = "Alert wurde bestätigt!";
          }
          else {
            document.getElementById('date_field').innerText = "Alert wurde NICHT bestätigt!";
          }
        } );
    },
    
    idcopyUploader : function idcopyUploader() {
        NativeBridge.call( "sakIdcopyUploader", [], function( hasUploaded ) {
                          if( hasUploaded ) {
                            document.getElementById('date_field').innerText = "Upload erfolgreich!";
                          }
                          else {
                            document.getElementById('date_field').innerText = "Kein erfolgreicher Upload!";
                          }
        } );
    },
    
    datepicker : function datepicker(title, minDate, maxDate) {
        NativeBridge.call( "sakDatepicker", [title,minDate,maxDate], function( resultAsString ){
            if( resultAsString ) {
                document.getElementById('date_field').innerText = resultAsString;
            } else {
                document.getElementById('date_field').innerText = "Kein Datum bekommen.";
            }
        } );
    },
    
    testfail : function testfail() {
        NativeBridge.call( "sakTestfail" );
    },
};


// EXAMPLE CALL FROM Obj-C to WebView
function Web_AlertWithParams( message ) {
    alert( message );
}

// EXAMPLE CALLS FROM WebView to Obj-C
function testChangeColorButton() {
    if( NativeBridge ) {
        NativeBridge.call( "testChangeColor", [1,0,0] );
    }
    else {
        alert( 'Native Bridge missing!' );
    }
}

function testAnimateButton() {
    if( NativeBridge ) {
        NativeBridge.call( "testAnimateButton" );
    }
    else {
        alert( 'Native Bridge missing!' );
    }
}

function testFailingMethodButton() {
    if( NativeBridge ) {
        NativeBridge.call( "testFailingMethod" );
    }
    else {
        alert( 'Native Bridge missing!' );
    }
}

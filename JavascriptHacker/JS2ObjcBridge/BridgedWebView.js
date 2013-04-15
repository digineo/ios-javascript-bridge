
var NativeBridge = {
  callbacksCount : 1,
  callbacks : {},
  
  // called by bridge object when a result is available
  resultForCallback: function resultForCallback(callbackId, resultArray) {
    try {
    var callback = NativeBridge.callbacks[callbackId];
    if (!callback) return;
    
    callback.apply(null,resultArray);
    } catch(e) {alert(e)}
  },
  
  // functionName : refname of method to call via bridge in obj-c
  // args : array of arguments, pass [] for zero args
  // callback : function with n-arguments that is going to be called when the native code returned
  call: function call(functionName, args, callback) {
    
    var hasCallback = callback && typeof callback == "function";
    var callbackId = hasCallback ? NativeBridge.callbacksCount++ : 0;
    
    if (hasCallback)
      NativeBridge.callbacks[callbackId] = callback;
    
    var iframe = document.createElement("IFRAME");
    iframe.setAttribute("src", "js-frame:" + functionName + ":" + callbackId+ ":" + encodeURIComponent(JSON.stringify(args)));
    document.documentElement.appendChild(iframe);
    iframe.parentNode.removeChild(iframe);
    iframe = null;
    
    
  }

};


